"""Run the Flutter image-viewer smoke target with an external hang watchdog.

Build first: flutter build windows --debug --no-pub \
    -t test/windows/image_fullscreen_smoke.dart
Run: python scripts/test_windows_image_fullscreen.py \
    build/windows/x64/runner/Debug
"""

import argparse
from pathlib import Path
import subprocess
import sys


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle", type=Path)
    args = parser.parse_args()
    bundle = args.bundle.resolve()
    executable = bundle / "StashFlow.exe"
    log = bundle / "image_fullscreen_smoke.log"
    if not executable.is_file():
        parser.error(f"Missing Windows smoke executable: {executable}")
    log.unlink(missing_ok=True)
    try:
        result = subprocess.run(
            [str(executable)],
            cwd=bundle,
            timeout=30,
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except subprocess.TimeoutExpired:
        print("FAIL: Windows image viewer stopped responding (30s timeout).")
        if log.is_file():
            print(log.read_text(encoding="utf-8"))
        return 1
    output = log.read_text(encoding="utf-8") if log.is_file() else ""
    print(output, end="")
    if result.returncode or not output.endswith("PASS\n"):
        print(f"FAIL: Smoke target exited with code {result.returncode}.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
