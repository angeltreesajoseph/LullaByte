# Gemini and Android voice setup

Personal-record questions read only the selected baby's in-memory profile/tracker
snapshot. General questions are routed automatically to Gemini after consent;
there is no manual online/offline selector. The online path sends the typed
question and up to eight recent online turns through
the authenticated backend to Google Gemini. It does not automatically attach
tracker records, names, photos or recordings. Online consent is requested in-app.
Conversations are session-only, not a clinical record or diagnostic service.

## Server configuration

Create a Gemini API key in Google AI Studio. Store it only in backend secrets:

```
LULLABYTE_GEMINI_API_KEY=<private key>
LULLABYTE_GEMINI_MODEL=gemini-3.5-flash-lite
```

For local development use ignored `backend/.env`; for production use Render's
Environment settings, deploy the backend changes, and restart/redeploy after
setting the key. Never put keys in Flutter, dart-defines, git or screenshots.
No database migration is required. Ensure the chosen model is available to your
Google project; the model name is configurable. Review Gemini data-use terms and
configure provider-side spending/rate quotas before wider release. The app's
10-request/minute limiter is per API worker, not a distributed billing cap.

The server uses HTTPX (a production dependency) to call Google's REST API.
Missing configuration, provider quota/errors and timeouts are explicitly shown;
the app does not disguise offline responses as Gemini replies. Automated tests
mock Google; a live response must still be tested after adding the key.

## Android voice

The microphone uses Android's installed speech-recognition activity. Users review
the transcript before sending; dictation audio is not saved by LullaByte. The
phone's speech provider may process audio online, and offline availability depends
on installed recognition/language support. A voice disclosure is shown first.

Read aloud uses the installed Android text-to-speech engine, started only on tap.
Stop, navigating away, switching babies and leaving the foreground stop playback.
Language voices and media volume are controlled in phone settings. This native
implementation requires a full Android rebuild, not just hot reload. Other
platforms show an unavailable message; no native iOS voice implementation exists.

References: https://ai.google.dev/api/generate-content and
https://developer.android.com/reference/android/speech/RecognizerIntent
