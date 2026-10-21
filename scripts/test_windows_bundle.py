"""Regression tests for architecture validation of Windows release bundles."""

from pathlib import Path
import struct
import tempfile
import unittest

from validate_windows_bundle import PE_MACHINES, validate_bundle


def write_pe(path, architecture):
    path.parent.mkdir(parents=True, exist_ok=True)
    header = bytearray(0x86)
    header[:2] = b"MZ"
    struct.pack_into("<I", header, 0x3C, 0x80)
    header[0x80:0x84] = b"PE\0\0"
    struct.pack_into("<H", header, 0x84, PE_MACHINES[architecture])
    path.write_bytes(header)


class WindowsBundleTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)

    def bundle(self, architecture):
        for name in ("StashFlow.exe", "flutter_windows.dll", "libmpv-2.dll",
                     "plugin.dll", "nested/plugin.DLL"):
            write_pe(self.root / name, architecture)

    def test_matching_bundles(self):
        for architecture in PE_MACHINES:
            with self.subTest(architecture=architecture):
                self.bundle(architecture)
                self.assertEqual(validate_bundle(self.root, architecture), 5)

    def test_rejects_mislabeled_x64_bundle(self):
        self.bundle("x64")
        with self.assertRaisesRegex(ValueError, "expected arm64"):
            validate_bundle(self.root, "arm64")

    def test_rejects_mixed_architecture_dlls(self):
        for name in ("flutter_windows.dll", "libmpv-2.dll", "nested/plugin.DLL"):
            with self.subTest(name=name):
                self.bundle("arm64")
                write_pe(self.root / name, "x64")
                with self.assertRaisesRegex(ValueError, "expected arm64"):
                    validate_bundle(self.root, "arm64")

    def test_requires_runner_engine_and_mpv(self):
        for name in ("StashFlow.exe", "flutter_windows.dll", "libmpv-2.dll"):
            with self.subTest(name=name):
                self.bundle("arm64")
                (self.root / name).unlink()
                with self.assertRaisesRegex(ValueError, "Missing required"):
                    validate_bundle(self.root, "arm64")

    def test_rejects_malformed_binaries(self):
        for content in (b"", b"MZ", b"MZ" + bytes(100)):
            with self.subTest(content=content):
                self.bundle("arm64")
                (self.root / "plugin.dll").write_bytes(content)
                with self.assertRaises(ValueError):
                    validate_bundle(self.root, "arm64")


if __name__ == "__main__":
    unittest.main()
