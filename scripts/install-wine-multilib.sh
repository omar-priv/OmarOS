#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Run with sudo: sudo bash scripts/install-wine-multilib.sh" >&2
    exit 1
fi

ARCH="$(dpkg --print-architecture)"
if [ "$ARCH" != "amd64" ]; then
    echo "This script expects an amd64 Debian system. Detected: $ARCH" >&2
    exit 1
fi

dpkg --add-architecture i386
apt-get update
apt-get install -y wine wine64 wine32:i386 winetricks

echo "Wine 32-bit and 64-bit support has been installed."
echo "A Windows application still needs an individual compatibility test."
