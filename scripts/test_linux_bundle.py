"""Exercise Linux release architectures, AppImage tooling, and pacman packaging."""

import os
from pathlib import Path
import struct
import subprocess
import tempfile
import unittest

from validate_linux_bundle import ELF_MACHINES, validate_binary, validate_bundle


SCRIPTS = Path(__file__).resolve().parent


def write_elf(path, architecture):
    path.parent.mkdir(parents=True, exist_ok=True)
    header = bytearray(64)
    header[:6] = b"\x7fELF\x02\x01"
    struct.pack_into("<H", header, 18, ELF_MACHINES[architecture])
    path.write_bytes(header)
    path.chmod(0o755)


def write_script(path, content):
    path.write_text("#!/usr/bin/env bash\nset -euo pipefail\n" + content)
    path.chmod(0o755)


class LinuxBundleTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)

    def bundle(self, architecture):
        for name in ("StashFlow", "stash_app_flutter", "lib/libflutter_linux_gtk.so",
                     "lib/libmpv.so.2", "lib/libapp.so", "usr/lib/libdependency.so.1"):
            write_elf(self.root / name, architecture)

    def test_matching_bundles(self):
        for architecture in ELF_MACHINES:
            with self.subTest(architecture=architecture):
                self.bundle(architecture)
                self.assertEqual(validate_bundle(self.root, architecture), 6)

    def test_rejects_x64_labeled_as_arm64(self):
        self.bundle("x64")
        with self.assertRaisesRegex(ValueError, "expected arm64"):
            validate_bundle(self.root, "arm64")

    def test_rejects_mixed_libraries(self):
        for name in ("lib/libflutter_linux_gtk.so", "lib/libmpv.so.2",
                     "usr/lib/libdependency.so.1"):
            with self.subTest(name=name):
                self.bundle("arm64")
                write_elf(self.root / name, "x64")
                with self.assertRaisesRegex(ValueError, "expected arm64"):
                    validate_bundle(self.root, "arm64")

    def test_requires_core_binaries(self):
        for name in ("StashFlow", "stash_app_flutter", "lib/libflutter_linux_gtk.so",
                     "lib/libmpv.so.2"):
            with self.subTest(name=name):
                self.bundle("arm64")
                (self.root / name).unlink()
                with self.assertRaisesRegex(ValueError, "Missing required"):
                    validate_bundle(self.root, "arm64")

    def test_rejects_malformed_binaries(self):
        for content in (b"", b"\x7fELF", b"\x7fELF\x01\x01" + bytes(58)):
            with self.subTest(content=content):
                self.bundle("arm64")
                (self.root / "lib/libapp.so").write_bytes(content)
                with self.assertRaises(ValueError):
                    validate_bundle(self.root, "arm64")

    def test_checks_appimage_runtime(self):
        runtime = self.root / "test.AppImage"
        write_elf(runtime, "arm64")
        validate_binary(runtime, "arm64")
        write_elf(runtime, "x64")
        with self.assertRaisesRegex(ValueError, "expected arm64"):
            validate_binary(runtime, "arm64")


@unittest.skipUnless(os.name == "posix", "Linux packaging tools are required")
class LinuxPackagingTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.tools = self.root / "tools"
        self.tools.mkdir()

    def environment(self, native_arch):
        write_script(self.tools / "uname", f"echo {native_arch}\n")
        return {**os.environ, "PATH": f"{self.tools}:{os.environ['PATH']}"}

    def test_appimage_wrapper_overrides_fastforge_arch_and_preserves_arguments(self):
        tool = self.tools / "appimagetool-real"
        write_script(tool, 'printf "%s\\n" "$ARCH" "$@"\n')
        for native_arch in ("x86_64", "aarch64"):
            with self.subTest(architecture=native_arch):
                result = subprocess.check_output(
                    ["bash", str(SCRIPTS / "appimagetool.sh"), "--no-appstream",
                     "App Dir", "output.AppImage"],
                    env={**self.environment(native_arch), "ARCH": "x86_64",
                         "STASHFLOW_APPIMAGETOOL": str(tool)}, text=True,
                )
                self.assertEqual(result.splitlines(),
                                 [native_arch, "--no-appstream", "App Dir", "output.AppImage"])

    def test_appimage_wrapper_rejects_unsupported_architecture(self):
        result = subprocess.run(
            ["bash", str(SCRIPTS / "appimagetool.sh")],
            env=self.environment("riscv64"), capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 64)
        self.assertIn("Unsupported AppImage architecture", result.stderr)

    def test_pacman_metadata_and_payload_match_architecture(self):
        scripts = self.root / "scripts"
        scripts.mkdir()
        script = scripts / "build_linux_pacman.sh"
        script.write_text((SCRIPTS / script.name).read_text())
        (self.root / "pubspec.yaml").write_text("version: 1.39.0+112\n")
        (self.root / "asset").mkdir()
        (self.root / "asset/stashfluttericon.png").write_bytes(b"icon")
        for architecture, package_arch in (("x64", "x86_64"), ("arm64", "aarch64")):
            bundle = self.root / f"build/linux/{architecture}/release/bundle"
            write_elf(bundle / "StashFlow", architecture)
            for explicit_arch in (False, True):
                with self.subTest(architecture=architecture, explicit=explicit_arch):
                    command = ["bash", str(script), "nightly", str(self.root / "dist")]
                    if explicit_arch:
                        command.append(architecture)
                    subprocess.run(command, env=self.environment(package_arch),
                                   check=True, capture_output=True, text=True)
                    package = self.root / f"dist/StashFlow-nightly-linux-{architecture}.pkg.tar.zst"
                    metadata = subprocess.check_output(
                        ["bsdtar", "-xOf", str(package), ".PKGINFO"], text=True,
                    )
                    self.assertIn(f"arch = {package_arch}\n", metadata)
                    self.assertIn("pkgver = 1.39.0+112-1\n", metadata)
                    payload = subprocess.check_output(
                        ["bsdtar", "-xOf", str(package), "opt/StashFlow/StashFlow"],
                    )
                    self.assertEqual(payload, (bundle / "StashFlow").read_bytes())

    def test_pacman_rejects_unsupported_architecture(self):
        result = subprocess.run(
            ["bash", str(SCRIPTS / "build_linux_pacman.sh"), "nightly", "dist", "riscv64"],
            capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 64)
        self.assertIn("Unsupported Linux architecture", result.stderr)


if __name__ == "__main__":
    unittest.main()
