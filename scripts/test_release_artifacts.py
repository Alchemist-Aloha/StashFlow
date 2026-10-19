"""Exercise the release workflow's artifact naming and checksum shell blocks."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import textwrap
import unittest


WORKFLOW = (Path(__file__).resolve().parents[1] / ".github/workflows/reusable-release.yml").read_text()


def workflow_script(name):
    step = re.search(
        rf"      - name: {re.escape(name)}\n(.*?)(?=\n      - name:|\Z)",
        WORKFLOW,
        re.S,
    ).group(1)
    return textwrap.dedent(step.split("        run: |\n", 1)[1].split("\n        shell:", 1)[0])


class ReleaseArtifactsTest(unittest.TestCase):
    def test_version_is_preserved_for_every_channel(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for version in ["1.38.1+110", "1.39.0-beta.1"]:
                (root / "pubspec.yaml").write_text(f"version: {version}\n")
                for suffix in ["", "-rc", "-nightly"]:
                    with self.subTest(version=version, suffix=suffix):
                        env_file = root / "env"
                        env_file.write_text("")
                        subprocess.run(
                            ["bash", "-euo", "pipefail", "-c", workflow_script("Read version")],
                            cwd=root,
                            env={**os.environ, "ARCHIVE_SUFFIX": suffix,
                                 "GITHUB_SHA": "abcdef0123456789", "GITHUB_ENV": str(env_file)},
                            check=True,
                        )
                        expected = version + suffix + ("-abcdef0" if suffix else "")
                        self.assertEqual(env_file.read_text(), f"STASHFLOW_ARTIFACT_VERSION={expected}\n")

    def test_linux_checksums_are_portable(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            dist = root / "dist" / "1.38.1+110"
            dist.mkdir(parents=True)
            for extension in ["AppImage", "deb", "pkg.tar.zst"]:
                (dist / f"StashFlow-1.38.1+110-nightly-abcdef0-linux-x64.{extension}").write_bytes(b"package")
            subprocess.run(
                ["bash", "-euo", "pipefail", "-c", workflow_script("Checksum Linux dists")],
                cwd=root, check=True,
            )
            checksums = list(dist.glob("*.sha256"))
            self.assertEqual(len(checksums), 3)
            for checksum in checksums:
                subprocess.run(["sha256sum", "-c", checksum.name], cwd=dist, check=True)
                self.assertNotIn("dist/", checksum.read_text())


if __name__ == "__main__":
    unittest.main()
