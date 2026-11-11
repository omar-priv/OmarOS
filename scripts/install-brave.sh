#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Run with sudo: sudo bash scripts/install-brave.sh" >&2
    exit 1
fi

ARCH="$(dpkg --print-architecture)"
if [ "$ARCH" != "amd64" ]; then
    echo "This installer currently supports amd64 only. Detected: $ARCH" >&2
    exit 1
fi

apt-get update
apt-get install -y curl ca-certificates

install -d -m 0755 /usr/share/keyrings
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
    https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

apt-get update
apt-get install -y brave-browser

echo "Brave installation completed."
