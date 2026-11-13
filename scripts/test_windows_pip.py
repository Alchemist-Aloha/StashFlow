"""Run the Flutter PiP smoke target with a local video and a hang watchdog.

Build: flutter build windows --release --no-pub -t test/windows/pip_smoke.dart
Run: python scripts/test_windows_pip.py build/windows/x64/runner/Release video.mp4
Use a video at least 30 seconds long so the seek checks do not reach its end.
"""

import argparse
from pathlib import Path
import subprocess
import sys


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle", type=Path)
    parser.add_argument("media", type=Path)
    args = parser.parse_args()
    bundle = args.bundle.resolve()
    executable = bundle / "StashFlow.exe"
    media = args.media.resolve()
    log = bundle / "pip_smoke.log"
    for path in (executable, media):
        if not path.is_file():
            parser.error(f"Missing smoke input: {path}")
    log.unlink(missing_ok=True)
    try:
        result = subprocess.run(
            [str(executable), str(media)],
            cwd=bundle,
            timeout=40,
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except subprocess.TimeoutExpired:
        print("FAIL: Windows PiP stopped responding (40s timeout).")
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
