"""Package the existing emblem as opaque app icons without Swift or AppKit."""
import json
from pathlib import Path

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parent.parent
BACKGROUND = (255, 251, 248)


def generate_icons(source: Path, directory: Path) -> int:
    entries = json.loads((directory / 'Contents.json').read_text())['images']
    outputs = {}
    # Validate the entire manifest before writing any icons.
    for entry in entries:
        filename = entry['filename']
        if not filename or '/' in filename or '\\' in filename or not filename.endswith('.png'):
            raise ValueError('Icon filename must be a PNG basename')
        width, height = map(float, entry['size'].split('x'))
        scale = float(entry['scale'].removesuffix('x'))
        pixels = width * scale
        if width != height or not 1 <= pixels <= 4096 or not pixels.is_integer():
            raise ValueError('Icon dimensions must be positive, integral and square')
        if filename in outputs and outputs[filename] != int(pixels):
            raise ValueError('Conflicting icon sizes')
        outputs[filename] = int(pixels)
    if not outputs:
        raise ValueError('Icon manifest is empty')
    with Image.open(source) as image:
        emblem = image.convert('RGBA')
    for filename, pixels in outputs.items():
        edge = max(1, round(pixels * 0.84))
        fitted = ImageOps.contain(emblem, (edge, edge), Image.Resampling.LANCZOS)
        canvas = Image.new('RGB', (pixels, pixels), BACKGROUND)
        canvas.paste(fitted, ((pixels - fitted.width) // 2,
                              (pixels - fitted.height) // 2), fitted)
        canvas.save(directory / filename, format='PNG')
    return len(outputs)


if __name__ == '__main__':
    count = generate_icons(
        ROOT / 'frontend/assets/images/lullabyte_emblem.png',
        ROOT / 'frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset',
    )
    print(f'Generated {count} opaque LullaByte app icons.')
