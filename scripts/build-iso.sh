#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this script as root, for example: sudo bash scripts/build-iso.sh" >&2
    exit 1
fi

command -v lb >/dev/null 2>&1 || {
    echo "live-build is missing. Install Debian's live-build package first." >&2
    exit 1
}

lb config \
    --distribution trixie \
    --architectures amd64 \
    --binary-image iso-hybrid \
    --archive-areas "main contrib non-free non-free-firmware" \
    --bootappend-live "boot=live components username=omar hostname=omaros locales=ar_JO.UTF-8,en_US.UTF-8 keyboard-layouts=ara,us keyboard-options=grp:alt_shift_toggle"

lb build

if [ -f live-image-amd64.hybrid.iso ]; then
    echo "Build complete: $ROOT_DIR/live-image-amd64.hybrid.iso"
else
    echo "Build command finished, but the expected ISO was not found." >&2
    exit 1
fi
