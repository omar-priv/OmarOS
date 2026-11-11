#!/usr/bin/env bash
set -u

echo "===== OmarOS system report (read-only) ====="
echo
echo "[OS]"
if [ -r /etc/os-release ]; then
    cat /etc/os-release
fi
echo
echo "[Kernel]"
uname -a
echo
echo "[CPU]"
if command -v lscpu >/dev/null 2>&1; then
    lscpu | grep -E 'Model name|CPU\\(s\\)|Architecture|Thread|Core' || true
fi
echo
echo "[Memory and swap]"
free -h
if command -v zramctl >/dev/null 2>&1; then
    zramctl || true
fi
swapon --show 2>/dev/null || true
echo
echo "[Disks - informational only]"
if command -v lsblk >/dev/null 2>&1; then
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
fi
echo
echo "[Network devices]"
ip -brief link 2>/dev/null || true
echo
echo "[Wi-Fi]"
if command -v iw >/dev/null 2>&1; then
    iw dev 2>/dev/null || true
fi
echo
echo "[Graphics and network controllers]"
if command -v lspci >/dev/null 2>&1; then
    lspci -nnk | grep -A3 -Ei 'VGA|3D controller|Network controller' || true
fi
echo
echo "Report completed. No disk, partition, or system settings were changed."
