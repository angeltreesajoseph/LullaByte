"""Stage IPA exports explicitly; fail instead of a green build without an IPA."""
import os
from pathlib import Path
import shutil
import zipfile


def collect_ipa(export_directory: Path, destination: Path) -> list[Path]:
    sources = sorted(export_directory.glob('*.ipa'))
    if not sources:
        raise FileNotFoundError(f'No IPA exports found in {export_directory.resolve()}')
    # Validate all exports before copying any files.
    for source in sources:
        with zipfile.ZipFile(source) as archive:
            if not any(name.startswith('Payload/') and name.endswith('.app/Info.plist')
                       for name in archive.namelist()):
                raise ValueError(f'IPA is missing its app payload: {source.name}')
    destination.mkdir(parents=True, exist_ok=True)
    results = []
    for source in sources:
        target = destination / source.name
        shutil.copy2(source, target)
        if target.stat().st_size != source.stat().st_size:
            raise OSError(f'Incomplete IPA copy: {target.name}')
        print(f'Staged IPA: {target.resolve()} ({target.stat().st_size} bytes)')
        results.append(target)
    return results


if __name__ == '__main__':
    root = Path(os.environ['CM_BUILD_DIR']).resolve()
    collect_ipa(Path.cwd() / 'build/ios/ipa', root / 'ios-artifacts')
