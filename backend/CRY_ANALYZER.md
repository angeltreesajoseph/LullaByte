# Experimental internal-testing cry analyzer

This implementation is not a reliable reason detector or medical system. The
website-style classifier missed every tired, discomfort and belly-pain example
in its reused holdout. Never interpret its scores as probabilities of baby needs.

## Setup

Run from the backend folder:

```powershell
.\.venv\Scripts\python.exe -m pip install -e ".[dev,cry]"
```

For a Render service with `backend` as its root directory, the build command is:

```sh
pip install -e ".[dev,cry]"
```

Start command stays `uvicorn app.main:app --host 0.0.0.0 --port $PORT`.
The existing `0003_baby_photo` migration must already be applied. No additional
migration is needed for this integration. Restart/rebuild Flutter after updating
the app. Deployment is not performed just by editing these local files.

## Endpoint and behaviour

Authenticated `POST /api/v1/babies/{baby_id}/cry/analyze` accepts base64
`audio_data`, `format` (wav/mp3/m4a/ogg), and `accept_experimental: true`.
Ownership is checked before processing. Files are limited to 2 MB, usable audio
to 30 seconds; silent, invalid and very short input is rejected. A process-local
inference lock bounds concurrent CPU work and reports a retryable busy response.

- **Known dataset mode:** exact raw-file SHA-256 match against 352 actual training
  recordings. Shows the stored training label. No 100% model-confidence claim.
- **Model mode:** identical website-style MFCC extraction and saved scaler,
  five uncalibrated scores, alternative patterns, and explicit limitations.
  Low top scores or close scores get a heuristic uncertain-result message.
- Noise is only a possible non-baby match, not a guarantee that no cry occurred.
- General comfort checks cite the NHS; no medication or pain diagnosis is offered.

Results and playable audio are saved under the authenticated owner's selected
baby. History is limited to 20 entries and roughly 8 MB decoded audio. Deleting
history preserves the remaining server-generated analyses; client-supplied
predictions cannot replace them. Old entries remain “Analysis unavailable”.

Temporary conversion files are removed. Audio in history is retained until
deleted and is not automatically added to training data. Dataset audio is not
packaged with the service—only trusted model/scaler files and training hashes.

## Artifacts and verification

`app/cry_assets` contains classifier, scaler, metadata and the hash lookup.
Their hashes are checked before deserializing trusted local artifacts.
Never load user-uploaded joblib files. Re-export only from the reviewed local
experiment with `python scripts/export_cry_model.py` from the LB root.

Checks performed: five API integration tests, exact matches for all five labels,
held-out model-mode prediction, five-score sums, training/serving feature parity,
and Flutter static analysis (no errors; unused demo-widget warnings remain).
Real-phone microphone, playback and network testing is still required.
