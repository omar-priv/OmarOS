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
    --initsystem systemd \
    --archive-areas "main contrib non-free non-free-firmware" \
    --iso-volume "OMAROS13" \
    --iso-application "OmarOS Live" \
    --iso-publisher "OmarOS Project" \
    --iso-preparer "OmarOS Debian Live Build" \
    --bootappend-live "boot=live components username=omar hostname=omaros locales=ar_JO.UTF-8,en_US.UTF-8 keyboard-layouts=ara,us keyboard-options=grp:alt_shift_toggle console=tty0 console=ttyS0,115200n8 systemd.show_status=true systemd.log_target=console"

lb build

ISO="$ROOT_DIR/live-image-amd64.hybrid.iso"
if [ -s "$ISO" ]; then
    echo "Build complete: $ISO"
    ls -lh "$ISO"
    sha256sum "$ISO"
else
    echo "Build command finished, but the expected ISO was not found or is empty." >&2
    exit 1
fi
