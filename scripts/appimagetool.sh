#!/usr/bin/env bash
set -euo pipefail

# Fastforge 0.6.12 forces ARCH=x86_64, so restore the native packaging target.
native_arch=$(uname -m)
case "$native_arch" in
  x86_64|aarch64) export ARCH="$native_arch" ;;
  *) echo "Unsupported AppImage architecture: $native_arch" >&2; exit 64 ;;
esac
exec "${STASHFLOW_APPIMAGETOOL:-/usr/local/lib/stashflow/appimagetool}" "$@"
