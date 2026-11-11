#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ "$#" -ge 1 ]; then
    ISO_INPUT="$1"
else
    ISO_INPUT="$ROOT_DIR/live-image-amd64.hybrid.iso"
fi

QEMU_TIMEOUT_SECONDS=240

if [[ "$ISO_INPUT" = /* ]]; then
    ISO="$ISO_INPUT"
else
    ISO="$ROOT_DIR/$ISO_INPUT"
fi

if [ ! -s "$ISO" ]; then
    echo "ISO not found or empty: $ISO" >&2
    exit 1
fi

QEMU_BIN="qemu-system-x86_64"
command -v "$QEMU_BIN" >/dev/null 2>&1 || {
    echo "QEMU is required. Install qemu-system-x86 and retry." >&2
    exit 1
}

LOG_DIR="/tmp"
LOG_FILE="$LOG_DIR/omaros-qemu-serial-$$.log"
QEMU_STDERR="$LOG_DIR/omaros-qemu-stderr-$$.log"
QEMU_PID=""

cleanup() {
    if [ -n "$QEMU_PID" ] && kill -0 "$QEMU_PID" 2>/dev/null; then
        kill -TERM "$QEMU_PID" 2>/dev/null || true
        sleep 1
        kill -KILL "$QEMU_PID" 2>/dev/null || true
    fi
    if [ -n "$QEMU_PID" ]; then
        wait "$QEMU_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo "Starting diskless QEMU boot smoke test."
echo "ISO: $ISO"
echo "Guest: x86_64, 2048 MiB RAM, 2 vCPUs, TCG acceleration."
echo "No host disk or virtual hard disk is attached."

"$QEMU_BIN" \
    -machine pc,accel=tcg \
    -cpu qemu64 \
    -m 2048 \
    -smp 2 \
    -cdrom "$ISO" \
    -boot order=d \
    -display none \
    -serial "file:$LOG_FILE" \
    -monitor none \
    -nic none \
    -no-reboot \
    -no-shutdown \
    -snapshot \
    >"$QEMU_STDERR" 2>&1 &
QEMU_PID=$!

BOOT_REACHED=0
for ((second=1; second<=QEMU_TIMEOUT_SECONDS; second++)); do
    if [ -f "$LOG_FILE" ] && grep -Eiq \
        'Reached target Graphical Interface|Started Light Display Manager|Started.*display-manager|Welcome to Debian GNU/Linux|login:' \
        "$LOG_FILE"; then
        BOOT_REACHED=1
        break
    fi

    if ! kill -0 "$QEMU_PID" 2>/dev/null; then
        break
    fi
    sleep 1
done

if [ "$BOOT_REACHED" -eq 1 ]; then
    echo "QEMU smoke test passed: the live guest reached the display-manager/graphical boot marker."
    echo "Serial log: $LOG_FILE"
    exit 0
fi

echo "QEMU smoke test failed: no expected graphical boot marker within $QEMU_TIMEOUT_SECONDS seconds." >&2
echo "--- QEMU stderr ---" >&2
tail -n 80 "$QEMU_STDERR" 2>/dev/null || true
echo "--- Serial console ---" >&2
tail -n 120 "$LOG_FILE" 2>/dev/null || true
exit 1
