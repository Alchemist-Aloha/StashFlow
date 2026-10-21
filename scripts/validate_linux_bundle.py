"""Validate native ELF architectures before publishing Linux release packages."""

import argparse
from pathlib import Path
import struct


ELF_MACHINES = {"x64": 62, "arm64": 183}


def elf_machine(path):
    """Read the machine identifier of a 64-bit little-endian ELF binary."""
    with path.open("rb") as binary:
        header = binary.read(20)
    if len(header) != 20 or header[:6] != b"\x7fELF\x02\x01":
        raise ValueError(f"{path}: expected a 64-bit little-endian ELF header")
    return struct.unpack_from("<H", header, 18)[0]


def validate_binary(path, architecture):
    """Reject malformed or incorrectly labeled release binaries."""
    machine = elf_machine(path)
    if machine != ELF_MACHINES[architecture]:
        raise ValueError(f"{path}: ELF machine {machine}; expected {architecture}")


def validate_bundle(directory, architecture):
    """Require native runner copies, Flutter, mpv, and matching shared libraries."""
    required = [directory / name for name in (
        "StashFlow", "stash_app_flutter", "lib/libflutter_linux_gtk.so",
        "lib/libmpv.so.2",
    )]
    for path in required:
        if not path.is_file():
            raise ValueError(f"Missing required Linux binary: {path}")
    binaries = set(required) | {
        path for path in directory.rglob("*")
        if path.is_file() and (path.name.endswith(".so") or ".so." in path.name)
    }
    for path in sorted(binaries):
        validate_binary(path, architecture)
    return len(binaries)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("architecture", choices=ELF_MACHINES)
    parser.add_argument("--appimage", type=Path, help="Also validate the AppImage runtime")
    args = parser.parse_args()
    try:
        count = validate_bundle(args.directory, args.architecture)
        if args.appimage:
            validate_binary(args.appimage, args.architecture)
    except (OSError, ValueError) as error:
        parser.exit(1, f"{error}\n")
    print(f"Validated {count} Linux {args.architecture} binaries")
