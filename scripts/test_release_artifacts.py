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
    def test_only_stable_artifact_names_include_version(self):
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
                        expected = suffix.lstrip("-") if suffix else version
                        self.assertEqual(env_file.read_text(), f"STASHFLOW_ARTIFACT_VERSION={expected}\n")

    def test_rolling_cleanup_deletes_only_obsolete_assets(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            current = "StashFlow-nightly-linux-x64.AppImage"
            obsolete = "StashFlow-nightly-abcdef0-linux-x64.AppImage"
            package_dir = root / "artifacts" / "1.38.1+110"
            package_dir.mkdir(parents=True)
            (package_dir / current).write_bytes(b"package")
            gh = root / "gh"
            gh.write_text(
                "#!/usr/bin/env python3\n"
                "import os, sys\n"
                "from pathlib import Path\n"
                "if sys.argv[1:3] == ['release', 'view']:\n"
                f"    print({current!r}); print({obsolete!r})\n"
                "elif sys.argv[1:3] == ['release', 'delete-asset']:\n"
                "    assert sys.argv[3] == 'nightly'\n"
                "    with Path(os.environ['DELETED_ASSETS']).open('a') as log:\n"
                "        log.write(sys.argv[4] + '\\n')\n"
                "else:\n"
                "    sys.exit(1)\n"
            )
            gh.chmod(0o755)
            deleted = root / "deleted"
            subprocess.run(
                ["bash", "-euo", "pipefail", "-c", workflow_script("Remove obsolete rolling assets")],
                cwd=root,
                env={**os.environ, "PATH": f"{root}:{os.environ['PATH']}",
                     "RUNNER_TEMP": str(root), "ROLLING_TAG": "nightly",
                     "DELETED_ASSETS": str(deleted)},
                check=True,
            )
            self.assertEqual(deleted.read_text(), obsolete + "\n")

    def test_linux_checksums_are_portable(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            dist = root / "dist" / "1.38.1+110"
            dist.mkdir(parents=True)
            for architecture in ["x64", "arm64"]:
                for extension in ["AppImage", "deb", "pkg.tar.zst"]:
                    (dist / f"StashFlow-nightly-linux-{architecture}.{extension}").write_bytes(b"package")
            subprocess.run(
                ["bash", "-euo", "pipefail", "-c", workflow_script("Checksum Linux dists")],
                cwd=root, check=True,
            )
            checksums = list(dist.glob("*.sha256"))
            self.assertEqual(len(checksums), 6)
            for checksum in checksums:
                subprocess.run(["sha256sum", "-c", checksum.name], cwd=dist, check=True)
                self.assertNotIn("dist/", checksum.read_text())


if __name__ == "__main__":
    unittest.main()
