"""Reject Windows release bundles with missing or mixed-architecture binaries."""

import argparse
from pathlib import Path
import struct


PE_MACHINES = {"x64": 0x8664, "arm64": 0xAA64}


def pe_machine(path):
    """Read a PE machine identifier without loading or executing the binary."""
    with path.open("rb") as binary:
        if binary.read(2) != b"MZ":
            raise ValueError(f"{path}: missing DOS header")
        binary.seek(0x3C)
        offset = binary.read(4)
        if len(offset) != 4:
            raise ValueError(f"{path}: truncated DOS header")
        binary.seek(struct.unpack("<I", offset)[0])
        if binary.read(4) != b"PE\0\0":
            raise ValueError(f"{path}: missing PE signature")
        machine = binary.read(2)
        if len(machine) != 2:
            raise ValueError(f"{path}: truncated PE header")
        return struct.unpack("<H", machine)[0]


def validate_bundle(directory, architecture):
    """Require the runner, engine, mpv, and every bundled DLL to match the target."""
    expected = PE_MACHINES[architecture]
    required = [directory / name for name in (
        "StashFlow.exe", "flutter_windows.dll", "libmpv-2.dll",
    )]
    for path in required:
        if not path.is_file():
            raise ValueError(f"Missing required Windows binary: {path}")
    binaries = set(required) | {
        path for path in directory.rglob("*")
        if path.is_file() and path.suffix.lower() == ".dll"
    }
    for path in sorted(binaries):
        machine = pe_machine(path)
        if machine != expected:
            raise ValueError(
                f"{path}: PE machine 0x{machine:04x}; expected {architecture} "
                f"(0x{expected:04x})"
            )
    return len(binaries)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("architecture", choices=PE_MACHINES)
    args = parser.parse_args()
    try:
        count = validate_bundle(args.directory, args.architecture)
    except (OSError, ValueError) as error:
        parser.exit(1, f"{error}\n")
    print(f"Validated {count} Windows {args.architecture} binaries")
