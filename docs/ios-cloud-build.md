# iOS cloud build and App Store Connect upload

Bundle ID: `com.lullabyte.babycare`. Apple team: `9KKSGHSNG4`.
The native iOS scaffold is now in `frontend/ios`. Android files are unchanged.
The workflow at repository root starts manually, produces an IPA and uploads it
to App Store Connect using the existing `lullabyte-apple` integration. It does
not submit to beta review, distribute to tester groups or submit to App Store review.

The first cloud attempt stopped in the Swift icon-generation process (exit 133),
before compiling the IPA. Icon packaging now uses the build image's Python and pinned Pillow
instead of Swift/AppKit, preserving the emblem's aspect ratio and producing opaque
RGB PNGs. Push this fix before retrying; existing Firebase and signing setup can
remain in place. Cloud build 3 (commit `5e2aee9`) successfully exported a 50.7 MB
IPA, but Codemagic reported no collected artifacts. The workflow now validates
the exported app payload and copies the IPA to `$CM_BUILD_DIR/ios-artifacts`,
with an absolute artifact pattern. Missing exports fail the build explicitly.
Cloud build 4 successfully collected `LullaByte.ipa` (47.94 MB), downloaded by
the user. Apple upload with the newly enabled publishing configuration is pending.
Python is invoked in a script, not an `environment.python` YAML field (unsupported
by Codemagic). Pillow is installed in an isolated virtual environment.

## Required account setup

1. In the existing Firebase project **lulla-byte**, add an Apple app with the
   exact Bundle ID above. Download its `GoogleService-Info.plist`.
2. In Codemagic, connect this Git repository and choose the YAML workflow.
   Save an App Store Connect integration named **lullabyte-apple** using your
   Apple API key, Key ID and Issuer ID. Keep `.p8` private keys out of chat/Git.
   The Apple team must be the team above.
3. Under code-signing identities, add/select an Apple Distribution certificate
   with its private key and an App Store provisioning profile for this Bundle ID.
   Enable Push Notifications on the Apple identifier before generating the profile.
   Use Codemagic's secure signing UI; do not commit certificates/private keys.
4. Add an environment-variable group named **ios_secrets**. In it, add the
   base64-encoded plist as a **secret** variable named
   **IOS_FIREBASE_PLIST_BASE64**. Encode locally without posting the result:

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes('C:\path\GoogleService-Info.plist')) | Set-Clipboard
   ```

5. Upload an APNs authentication key in Firebase Project Settings → Cloud Messaging
   for this Apple app. This is separate from App Store signing. Never paste the
   APNs private key in chat. Configure any required App Check policy for iOS.
6. Publish the reviewed local iOS/client changes to the connected repository before
   starting a build. This workspace has many uncommitted client files: pushing only
   the iOS folder is **not enough** to reproduce the Android-tested app.
7. Start **LullaByte iOS - signed IPA preparation** manually. Review cloud pricing
   and available build minutes first. The workflow pins Flutter 3.44.6, selects
   current Xcode, checks Xcode >= 26, and uses iOS deployment target 15.0.
8. Download the signed `.ipa` from build artifacts. Build numbers use Codemagic's
   PROJECT_BUILD_NUMBER; ensure each is higher than any prior uploaded build.

## Upload / testing, not public release

Publishing uses `auth: integration` to upload each successful manually started
build. Both `submit_to_testflight` and `submit_to_app_store` are explicitly false:
the former controls beta review submission, not the binary upload itself. No beta
groups are configured and no previous builds are expired or submissions cancelled.
The existing API key needs App Manager permissions (or a sufficient higher role).
After Publishing reports upload success, let Apple process the build, then open
LullaByte in App Store Connect > TestFlight. Resolve any export-compliance or
testing-information prompts and explicitly configure internal testers. External
beta review and public App Store review remain separate manual decisions.
Test on a physical iPhone before seeking public release.

## Known release blockers / unverified behavior

- This Windows environment cannot compile Swift, install CocoaPods or verify signing.
  Cloud IPA build and artifact download succeeded; Apple upload and device testing
  have not yet been verified. The build also flagged the default launch image.
- The assistant's dictation/read-aloud and notification-settings MethodChannels are
  currently implemented **only on Android**. iOS native implementations remain work;
  do not advertise these as tested iPhone features.
- Verify shared-care push, token registration, local reminders, vibration/haptics,
  cold-start notification taps and denied permissions on iPhone.
- Verify Firebase login/session restore, photo saving, audio recording/upload/playback,
  PDF sharing, camera/gallery, selected twins and view-only access on-device.
- Check plugin SDK/privacy manifests and App Store privacy disclosures against
  actual collection of baby/health information, photos, audio and Gemini questions.
- Account deletion, privacy-policy/support URLs, review credentials, screenshots,
  accessibility claims and unvalidated cry-model claims need a release review.
- Runner.entitlements is set for App Store production APNs. Use a development
  entitlement/profile if adding a separate local debug-device workflow.

## Official references

- https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/
- https://docs.codemagic.io/yaml-code-signing/signing-ios/
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/cloud-messaging/flutter/client
- https://developer.apple.com/news/upcoming-requirements/
