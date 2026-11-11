#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "[1/4] Checking shell syntax..."
for script in scripts/*.sh; do
    bash -n "$script"
done

echo "[2/4] Checking package-list duplicates..."
for list in config/package-lists/*.list.chroot; do
    awk '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        {
            if (seen[$0]++) {
                print "Duplicate package in " FILENAME ": " $0
                bad=1
            }
        }
        END { exit bad }
    ' "$list"
done

echo "[3/4] Checking required packages and configuration..."
grep -Fxq "zram-tools" config/package-lists/desktop.list.chroot
grep -Fxq "xfce4-session" config/package-lists/desktop.list.chroot
grep -Fxq "firmware-atheros" config/package-lists/firmware.list.chroot
grep -Fxq 'PERCENT=50' config/includes.chroot/etc/default/zramswap
grep -Fxq 'ALGO=lz4' config/includes.chroot/etc/default/zramswap
grep -Fxq 'XKBOPTIONS="grp:alt_shift_toggle"' config/includes.chroot/etc/default/keyboard

echo "[4/4] Checking project files..."
test -f README.md
test -f AGENTS.md
test -f docs/ARCHITECTURE.md
test -f docs/DUAL-BOOT-SAFETY.md
test -f docs/SKILL-REVIEW.md
test -f docs/TESTING.md
test -f config/hooks/normal/090-enable-zram.hook.chroot
test -x scripts/build-iso.sh
test -x scripts/qemu-smoke.sh

echo "OmarOS project validation passed."
