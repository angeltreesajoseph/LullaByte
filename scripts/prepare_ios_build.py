"""Validate cloud prerequisites without logging Firebase values or signing keys."""
import base64
import os
from pathlib import Path
import plistlib
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BUNDLE = 'com.lullabyte.babycare'


def restore_firebase(encoded: str, destination: Path) -> None:
    if not encoded:
        raise ValueError('Add IOS_FIREBASE_PLIST_BASE64 to the secret ios_secrets group in Codemagic.')
    try:
        data = base64.b64decode(encoded, validate=True)
        config = plistlib.loads(data)
    except Exception:
        raise ValueError('IOS_FIREBASE_PLIST_BASE64 must contain a valid base64-encoded Apple Firebase plist.') from None
    if config.get('BUNDLE_ID') != BUNDLE:
        raise ValueError('Firebase Apple app Bundle ID must be com.lullabyte.babycare.')
    if config.get('PROJECT_ID') != 'lulla-byte':
        raise ValueError('Use the same Firebase project as the Android app (lulla-byte).')
    if not config.get('GOOGLE_APP_ID') or not config.get('API_KEY'):
        raise ValueError('Download a complete GoogleService-Info.plist from Firebase.')
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(data)


if __name__ == '__main__':
    # Fail early rather than build with the wrong Firebase identity or SDK.
    version = subprocess.check_output(['xcodebuild', '-version'], text=True)
    if int(version.splitlines()[0].split()[1].split('.')[0]) < 26:
        raise SystemExit('Select Xcode 26 or later in Codemagic.')
    restore_firebase(os.environ.get('IOS_FIREBASE_PLIST_BASE64', ''),
                     ROOT / 'frontend/ios/Runner/GoogleService-Info.plist')
    print('iOS Firebase configuration validated and restored (values hidden).')
