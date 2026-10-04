"""Internal-testing inference. Dataset recognition is not model confidence."""
from functools import lru_cache
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tempfile
import threading

ASSETS = Path(__file__).resolve().parents[1] / 'cry_assets'
CLASSES = ('hungry', 'belly_pain', 'discomfort', 'tired', 'noise')
LOCK = threading.Lock()
SOURCE = 'https://www.nhs.uk/baby/caring-for-a-newborn/soothing-a-crying-baby/'
TIPS = {
    'hungry': 'Check feeding cues and offer the usual feed if your baby appears hungry. Do not feed solely because of this score.',
    'tired': 'Check sleep cues. Try gentle comforting and a calm environment; follow safe-sleep guidance.',
    'discomfort': 'Check the nappy, clothing and whether your baby is too hot or cold.',
    'belly_pain': 'This label cannot establish pain. Comfort your baby and seek professional advice for persistent or unusual crying.',
    'noise': 'Possible non-baby or unclear sound. Try recording closer to your baby in a quieter environment.',
}
WARNING = ('Experimental sound-pattern scores, not a diagnosis or probabilities of baby needs. '
           'The model missed all tested tired, discomfort and belly-pain cries. '
           'Seek urgent medical help for breathing difficulty or unresponsiveness; '
           'seek professional advice if your baby seems unwell or crying is unusual or persistent.')


@lru_cache(maxsize=1)
def assets():
    import joblib
    metadata = json.loads((ASSETS / 'metadata.json').read_text())
    for name, expected in metadata['asset_sha256'].items():
        if hashlib.sha256((ASSETS / name).read_bytes()).hexdigest() != expected:
            raise RuntimeError('Inference assets failed integrity check')
    model = joblib.load(ASSETS / 'classifier.joblib')
    scaler = joblib.load(ASSETS / 'scaler.joblib')
    if set(model.classes_) != set(CLASSES) or scaler.n_features_in_ != 80:
        raise RuntimeError('Inference model incompatible')
    return model, scaler, json.loads((ASSETS / 'known_recordings.json').read_text())


def extract(data):
    import imageio_ffmpeg
    import librosa
    import numpy as np
    import soundfile as sf
    with tempfile.TemporaryDirectory(prefix='lullabyte-cry-') as directory:
        path = Path(directory) / 'input.audio'
        path.write_bytes(data)
        result = subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-nostdin', '-v', 'error',
            '-i', str(path), '-map', '0:a:0', '-t', '31', '-ac', '1', '-ar', '22050',
            '-c:a', 'pcm_s16le', '-f', 'wav', 'pipe:1'], capture_output=True, timeout=45)
        if result.returncode != 0:
            raise ValueError('Audio could not be decoded. Use WAV, MP3, M4A or OGG.')
        audio, rate = sf.read(io.BytesIO(result.stdout), dtype='float32')
    if len(audio) > 30 * rate:
        raise ValueError('Audio must be no longer than 30 seconds.')
    if len(audio) < 2048 or not np.isfinite(audio).all() or np.max(np.abs(audio)) < 1e-6:
        raise ValueError('Silent or too-short recording. Try again.')
    trimmed, _ = librosa.effects.trim(audio, top_db=60)
    if len(trimmed) < 2048:
        raise ValueError('Not enough usable audio after silence trimming.')
    mfcc = librosa.feature.mfcc(y=trimmed, sr=rate, n_mfcc=40,
                              n_fft=2048, hop_length=512, n_mels=128)
    features = np.concatenate([mfcc.mean(1), mfcc.std(1)])[None]
    if not np.isfinite(features).all():
        raise ValueError('Invalid audio features.')
    return features


def analyze(data):
    if not LOCK.acquire(blocking=False):
        raise BlockingIOError('Analyzer busy. Please retry shortly.')
    try:
        model, scaler, known = assets()
        features = extract(data)  # Validate even exact-file recognition.
        digest = hashlib.sha256(data).hexdigest()
        label = known.get(digest)
        if label:
            return {'mode': 'known_dataset', 'label': label,
                'result': f'Known dataset recording: {label.replace("_", " ")}',
                'scores': None, 'confidence': None, 'alternatives': [],
                'tip': TIPS[label], 'warning': WARNING,
                'explanation': 'Exact training-file SHA-256 match; saved dataset label, not an AI certainty score.',
                'source': SOURCE, 'model_version': 'website-mfcc-rf-v1'}
        raw = model.predict_proba(scaler.transform(features))[0]
        scores = {str(name): round(float(value)*100, 2) for name, value in zip(model.classes_, raw)}
        order = sorted(scores, key=scores.get, reverse=True)
        top = order[0]
        uncertain = scores[top] < 50 or scores[top] - scores[order[1]] < 10
        result = ('Unable to determine — uncertain model scores' if uncertain else
                  'Possible non-baby sound' if top == 'noise' else
                  f'Experimental sound-pattern match: {top.replace("_", " ")}')
        return {'mode': 'model', 'label': top, 'result': result, 'scores': scores,
            'confidence': None, 'uncertain': uncertain,
            'alternatives': [{'label': name, 'score': scores[name], 'tip': TIPS[name]} for name in order[:3]],
            'tip': TIPS[top], 'warning': WARNING,
            'explanation': 'Uncalibrated classifier scores. Uncertainty thresholds are heuristic, not clinically validated.',
            'source': SOURCE, 'model_version': 'website-mfcc-rf-v1'}
    finally:
        LOCK.release()
