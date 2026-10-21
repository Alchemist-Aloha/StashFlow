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
    def test_macos_build_selects_requested_xcode_architecture(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            flutter = root / "flutter"
            flutter.write_text(
                '#!/usr/bin/env bash\nset -euo pipefail\n'
                'printf "%s:%s\\n" "$FLUTTER_XCODE_ARCHS" "$FLUTTER_MACOS_ARM64_ONLY"\n'
            )
            flutter.chmod(0o755)
            for architecture, cpu in [("x64", "x86_64"), ("arm64", "arm64")]:
                with self.subTest(architecture=architecture):
                    result = subprocess.check_output(
                        ["bash", "-euo", "pipefail", "-c",
                         workflow_script("Build").replace("${{ matrix.target }}", "macos")],
                        env={**os.environ, "PATH": f"{root}:{os.environ['PATH']}",
                             "TARGET_ARCH": architecture}, text=True,
                    )
                    self.assertEqual(result, f"{cpu}:false\n")

    def test_macos_packaging_checks_runner_and_embedded_frameworks(self):
        for architecture, cpu in [("x64", "x86_64"), ("arm64", "arm64")]:
            for broken in [None, "runner", "framework", "missing_runner"]:
                with self.subTest(architecture=architecture, broken=broken):
                    with tempfile.TemporaryDirectory() as directory:
                        root = Path(directory)
                        app = root / "build/macos/Build/Products/Release/StashFlow.app"
                        runner = app / "Contents/MacOS/StashFlow"
                        framework = app / "Contents/Frameworks/Native Media.framework/Native Media"
                        other_cpu = "arm64" if cpu == "x86_64" else "x86_64"
                        for path, kind in [(runner, "runner"), (framework, "framework")]:
                            path.parent.mkdir(parents=True, exist_ok=True)
                            path.write_text("Mach-O " + (other_cpu if broken == kind else cpu))
                        if broken == "missing_runner":
                            runner.unlink()
                        if broken is None:
                            framework.write_text("Mach-O arm64 x86_64")
                        (app / "Contents/Info.plist").write_text("metadata")
                        tools = root / "tools"
                        tools.mkdir()
                        stubs = {
                            "file": (
                                "from pathlib import Path\nimport sys\n"
                                "print('Mach-O' if Path(sys.argv[-1]).read_text().startswith('Mach-O ') else 'data')\n"
                            ),
                            "lipo": (
                                "from pathlib import Path\nimport sys\n"
                                "assert len(sys.argv) == 4 and sys.argv[2] == '-verify_arch', 'input file must precede -verify_arch'\n"
                                "sys.exit(0 if sys.argv[3] in Path(sys.argv[1]).read_text().split() else 1)\n"
                            ),
                            "zip": (
                                "from pathlib import Path\nimport sys\n"
                                "Path(sys.argv[2]).write_bytes(b'archive')\n"
                            ),
                        }
                        for name, source in stubs.items():
                            tool = tools / name
                            tool.write_text("#!/usr/bin/env python3\n" + source)
                            tool.chmod(0o755)
                        result = subprocess.run(
                            ["bash", "-euo", "pipefail", "-c", workflow_script("Package macOS")],
                            cwd=root,
                            env={**os.environ, "PATH": f"{tools}:{os.environ['PATH']}",
                                 "TARGET_ARCH": architecture, "STASHFLOW_ARTIFACT_VERSION": "nightly"},
                            capture_output=True, text=True,
                        )
                        archive = root / f"StashFlow-nightly-macos-{cpu}.zip"
                        if broken:
                            self.assertNotEqual(result.returncode, 0)
                            self.assertFalse(archive.exists())
                        else:
                            self.assertEqual(result.returncode, 0, result.stderr)
                            self.assertTrue(archive.is_file())

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
