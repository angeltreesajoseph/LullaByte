from pathlib import Path
import tempfile
import unittest
import zipfile

from collect_ios_artifacts import collect_ipa


class ArtifactTests(unittest.TestCase):
    def test_export_is_copied_without_changes(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            exports = root / 'export'
            exports.mkdir()
            source = exports / 'LullaByte.ipa'
            with zipfile.ZipFile(source, 'w') as archive:
                archive.writestr('Payload/Runner.app/Info.plist', b'test fixture')
            targets = collect_ipa(exports, root / 'artifacts')
            self.assertEqual(len(targets), 1)
            self.assertEqual(targets[0].read_bytes(), source.read_bytes())

    def test_missing_or_invalid_ipa_fails(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            destination = root / 'artifacts'
            with self.assertRaises(FileNotFoundError):
                collect_ipa(root, destination)
            with zipfile.ZipFile(root / 'bad.ipa', 'w') as archive:
                archive.writestr('not-an-app', b'test')
            with self.assertRaises(ValueError):
                collect_ipa(root, destination)
            self.assertFalse(destination.exists())
