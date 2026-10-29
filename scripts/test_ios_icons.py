"""Exercise icon packaging in temporary catalogs, never tracked app assets."""
import json
from pathlib import Path
import tempfile
import unittest

from PIL import Image
from prepare_ios_icons import BACKGROUND, ROOT, generate_icons


class IconTests(unittest.TestCase):
    def test_real_emblem_and_manifest_produce_all_opaque_sizes(self):
        manifest = ROOT / 'frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json'
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            (directory / 'Contents.json').write_bytes(manifest.read_bytes())
            count = generate_icons(ROOT / 'frontend/assets/images/lullabyte_emblem.png', directory)
            self.assertEqual(count, len(list(directory.glob('*.png'))))
            for entry in json.loads(manifest.read_text())['images']:
                pixels = int(float(entry['size'].split('x')[0]) * float(entry['scale'][:-1]))
                with Image.open(directory / entry['filename']) as icon:
                    self.assertEqual(icon.size, (pixels, pixels))
                    self.assertEqual(icon.mode, 'RGB')
                    self.assertEqual(icon.getpixel((0, 0)), BACKGROUND)

    def test_non_square_source_is_fitted_without_stretching(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            source = directory / 'source.png'
            Image.new('RGBA', (200, 100), (255, 0, 0, 255)).save(source)
            (directory / 'Contents.json').write_text(json.dumps({'images': [
                {'filename': 'icon.png', 'size': '100x100', 'scale': '1x'}]}))
            generate_icons(source, directory)
            with Image.open(directory / 'icon.png') as icon:
                self.assertEqual(icon.getpixel((8, 29)), (255, 0, 0))
                self.assertEqual(icon.getpixel((50, 28)), BACKGROUND)
                self.assertEqual(icon.getpixel((50, 71)), BACKGROUND)

    def test_invalid_manifest_and_missing_source_do_not_write_icons(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            for filename in ['../escape.png', 'icon.png']:
                (directory / 'Contents.json').write_text(json.dumps({'images': [
                    {'filename': filename, 'size': '100x100', 'scale': '1x'}]}))
                with self.assertRaises((ValueError, FileNotFoundError)):
                    generate_icons(directory / 'missing.png', directory)
                self.assertFalse((directory / 'icon.png').exists())


if __name__ == '__main__':
    unittest.main()
