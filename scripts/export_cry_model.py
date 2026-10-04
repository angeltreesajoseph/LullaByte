"""Package trusted local experiment assets without exporting dataset audio."""
import hashlib
import json
from pathlib import Path
import shutil

root = Path(__file__).resolve().parents[1]
source = root / 'ai/experiments/website-mfcc-rf-v1'
target = root / 'backend/app/cry_assets'
target.mkdir(parents=True, exist_ok=True)
metadata = json.loads((source / 'report.json').read_text())
records = json.loads((source / 'manifest.json').read_text())
known = {}
for record in records:
    if record['split'] == 'train':
        digest, label = record['sha256'], record['label']
        if digest in known and known[digest] != label:
            raise ValueError('Conflicting dataset labels for identical files')
        known[digest] = label
hashes = {}
for name in ['classifier.joblib', 'scaler.joblib']:
    shutil.copyfile(source / name, target / name)
    hashes[name] = hashlib.sha256((target / name).read_bytes()).hexdigest()
(target / 'known_recordings.json').write_text(json.dumps(known, sort_keys=True), encoding='utf-8')
hashes['known_recordings.json'] = hashlib.sha256((target / 'known_recordings.json').read_bytes()).hexdigest()
(target / 'metadata.json').write_text(json.dumps({
    'version': 'website-mfcc-rf-v1', 'experimental': True, 'asset_sha256': hashes,
    'settings': metadata['feature_settings'], 'evaluation': metadata['evaluation']['test'],
}, indent=2), encoding='utf-8')
print(f'Exported model, scaler and {len(known)} training-file hashes; no raw audio.')
