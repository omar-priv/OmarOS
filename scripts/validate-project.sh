#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "[1/3] Checking shell syntax..."
for script in scripts/*.sh; do
    bash -n "$script"
done

echo "[2/3] Checking package-list duplicates..."
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

echo "[3/3] Checking required project files..."
test -f README.md
test -f config/includes.chroot/etc/default/zramswap
test -f config/includes.chroot/etc/default/keyboard
test -f config/hooks/normal/090-enable-zram.hook.chroot
test -f scripts/build-iso.sh

echo "OmarOS project validation passed."
