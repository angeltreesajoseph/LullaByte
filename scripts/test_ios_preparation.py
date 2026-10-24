"""Cross-platform checks; these do not claim to compile or sign an iOS app."""
import base64
import json
from pathlib import Path
import plistlib
import tempfile
import unittest
from prepare_ios_build import ROOT, restore_firebase


class IosPreparationTests(unittest.TestCase):
    def test_firebase_configuration_accepts_only_matching_project_and_bundle(self):
        with tempfile.TemporaryDirectory() as temporary:
            destination = Path(temporary) / 'GoogleService-Info.plist'
            config = {'BUNDLE_ID': 'com.lullabyte.babycare', 'PROJECT_ID': 'lulla-byte',
                      'GOOGLE_APP_ID': 'test-only', 'API_KEY': 'test-only'}
            encoded = base64.b64encode(plistlib.dumps(config)).decode()
            restore_firebase(encoded, destination)
            self.assertEqual(plistlib.loads(destination.read_bytes()), config)
            config['BUNDLE_ID'] = 'wrong.app'
            with self.assertRaises(ValueError):
                restore_firebase(base64.b64encode(plistlib.dumps(config)).decode(), destination)
            self.assertEqual(plistlib.loads(destination.read_bytes())['BUNDLE_ID'], 'com.lullabyte.babycare')

    def test_missing_or_corrupt_configuration_fails_without_exposing_input(self):
        with tempfile.TemporaryDirectory() as temporary:
            destination = Path(temporary) / 'config.plist'
            for value in ['', 'not-a-real-secret']:
                with self.assertRaises(ValueError) as error:
                    restore_firebase(value, destination)
                self.assertNotIn('not-a-real-secret', str(error.exception))
            self.assertFalse(destination.exists())

    def test_bundle_team_permissions_entitlements_and_resource_wiring(self):
        ios = ROOT / 'frontend/ios'
        info = plistlib.loads((ios / 'Runner/Info.plist').read_bytes())
        self.assertEqual(info['CFBundleDisplayName'], 'LullaByte')
        self.assertEqual(info['UIUserInterfaceStyle'], 'Light')
        for key in ['NSCameraUsageDescription', 'NSMicrophoneUsageDescription', 'NSPhotoLibraryUsageDescription']:
            self.assertTrue(info[key])
        self.assertIn('remote-notification', info['UIBackgroundModes'])
        project = (ios / 'Runner.xcodeproj/project.pbxproj').read_text()
        self.assertEqual(project.count('PRODUCT_BUNDLE_IDENTIFIER = com.lullabyte.babycare;'), 3)
        self.assertEqual(project.count('DEVELOPMENT_TEAM = 9KKSGHSNG4;'), 3)
        self.assertEqual(project.count('CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;'), 3)
        self.assertIn('GoogleService-Info.plist in Resources', project)
        self.assertNotIn('IPHONEOS_DEPLOYMENT_TARGET = 13.0;', project)
        entitlements = plistlib.loads((ios / 'Runner/Runner.entitlements').read_bytes())
        self.assertEqual(entitlements['aps-environment'], 'production')

    def test_workflow_and_icon_manifest_have_required_inputs(self):
        workflow = (ROOT / 'codemagic.yaml').read_text()
        self.assertIn('working_directory: frontend', workflow)
        self.assertIn('bundle_identifier: com.lullabyte.babycare', workflow)
        self.assertNotIn('\n    publishing:', workflow)
        icons = json.loads((ROOT / 'frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json').read_text())
        self.assertTrue(any(e['size'] == '1024x1024' for e in icons['images']))


if __name__ == '__main__':
    unittest.main()
