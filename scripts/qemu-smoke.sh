#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ "$#" -ge 1 ]; then
    ISO_INPUT="$1"
else
    ISO_INPUT="$ROOT_DIR/live-image-amd64.hybrid.iso"
fi

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
command -v python3 >/dev/null 2>&1 || {
    echo "Python 3 is required for the QEMU screen probe." >&2
    exit 1
}

DIAG_DIR="$ROOT_DIR/qemu-diagnostics"
rm -rf "$DIAG_DIR"
mkdir -p "$DIAG_DIR"

TMP_DIR="$(mktemp -d /tmp/omaros-qemu.XXXXXX)"
LOG_FILE="$TMP_DIR/serial.log"
QEMU_STDERR="$TMP_DIR/qemu-stderr.log"
QMP_SOCKET="$TMP_DIR/qmp.sock"
SCREEN_EARLY="$TMP_DIR/screen-early.ppm"
SCREEN_LATE="$TMP_DIR/screen-late.ppm"
QEMU_PID=""

preserve_diagnostics() {
    mkdir -p "$DIAG_DIR"
    [ ! -f "$LOG_FILE" ] || cp "$LOG_FILE" "$DIAG_DIR/serial.log"
    [ ! -f "$QEMU_STDERR" ] || cp "$QEMU_STDERR" "$DIAG_DIR/qemu-stderr.log"
    [ ! -f "$SCREEN_EARLY" ] || cp "$SCREEN_EARLY" "$DIAG_DIR/screen-early.ppm"
    [ ! -f "$SCREEN_LATE" ] || cp "$SCREEN_LATE" "$DIAG_DIR/screen-late.ppm"

    if command -v tesseract >/dev/null 2>&1; then
        if [ -s "$SCREEN_EARLY" ]; then
            echo "--- OCR: early VGA framebuffer ---"
            tesseract "$SCREEN_EARLY" "$DIAG_DIR/screen-early" 2>/dev/null || true
            [ ! -f "$DIAG_DIR/screen-early.txt" ] || cat "$DIAG_DIR/screen-early.txt"
        fi
        if [ -s "$SCREEN_LATE" ]; then
            echo "--- OCR: late VGA framebuffer ---"
            tesseract "$SCREEN_LATE" "$DIAG_DIR/screen-late" 2>/dev/null || true
            [ ! -f "$DIAG_DIR/screen-late.txt" ] || cat "$DIAG_DIR/screen-late.txt"
        fi
    else
        echo "tesseract is unavailable; OCR diagnostics were not generated."
    fi
    echo "QEMU diagnostics saved in: $DIAG_DIR"
}

cleanup() {
    if [ -n "$QEMU_PID" ] && kill -0 "$QEMU_PID" 2>/dev/null; then
        kill -TERM "$QEMU_PID" 2>/dev/null || true
        sleep 1
        kill -KILL "$QEMU_PID" 2>/dev/null || true
    fi
    if [ -n "$QEMU_PID" ]; then
        wait "$QEMU_PID" 2>/dev/null || true
    fi
    preserve_diagnostics
    echo "Temporary QEMU files: $TMP_DIR"
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
    -vga std \
    -cdrom "$ISO" \
    -boot order=d,menu=off \
    -display none \
    -serial "file:$LOG_FILE" \
    -monitor none \
    -qmp "unix:$QMP_SOCKET,server=on,wait=off" \
    -nic none \
    -no-reboot \
    -no-shutdown \
    -snapshot \
    >"$QEMU_STDERR" 2>&1 &
QEMU_PID=$!

sleep 20
if ! kill -0 "$QEMU_PID" 2>/dev/null; then
    echo "QEMU exited before the first boot probe." >&2
    cat "$QEMU_STDERR" >&2 || true
    exit 1
fi

python3 "$ROOT_DIR/scripts/qemu-screen-probe.py" capture "$QMP_SOCKET" "$SCREEN_EARLY"
sleep 140

if ! kill -0 "$QEMU_PID" 2>/dev/null; then
    echo "QEMU exited before the final boot probe." >&2
    cat "$QEMU_STDERR" >&2 || true
    exit 1
fi

python3 "$ROOT_DIR/scripts/qemu-screen-probe.py" capture "$QMP_SOCKET" "$SCREEN_LATE"

if [ -s "$LOG_FILE" ] && grep -Eiq \
    'Reached target.*Graphical Interface|Started Light Display Manager|Started.*display-manager|Welcome to Debian GNU/Linux|login:' \
    "$LOG_FILE"; then
    echo "QEMU smoke test passed: guest boot marker detected on the serial console."
    exit 0
fi

if command -v tesseract >/dev/null 2>&1; then
    OCR_FILE="$DIAG_DIR/screen-late.txt"
    tesseract "$SCREEN_LATE" "$DIAG_DIR/screen-late" 2>/dev/null || true
    if [ -s "$OCR_FILE" ]; then
        echo "--- OCR text from late VGA framebuffer ---"
        cat "$OCR_FILE"
        if grep -Eiq 'Welcome to Debian GNU/Linux|Light Display Manager|lightdm|login:|Xfce session' "$OCR_FILE"; then
            echo "QEMU smoke test passed: a graphical login/desktop boot marker was recognized in the VGA framebuffer."
            exit 0
        fi
    fi
fi

if python3 "$ROOT_DIR/scripts/qemu-screen-probe.py" compare "$SCREEN_EARLY" "$SCREEN_LATE"; then
    echo "QEMU smoke test passed: VGA output changed during the boot window and produced a visible framebuffer."
    echo "Note: serial console output was unavailable; inspect the retained screenshots if investigating a failure."
    exit 0
fi

echo "QEMU smoke test failed: no serial boot marker, recognized graphical boot marker, or changing VGA output was detected." >&2
echo "--- QEMU stderr ---" >&2
tail -n 80 "$QEMU_STDERR" 2>/dev/null || true
echo "--- Serial console ---" >&2
tail -n 120 "$LOG_FILE" 2>/dev/null || true
exit 1
