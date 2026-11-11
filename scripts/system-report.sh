#!/usr/bin/env bash
set -u

section() {
    printf '\n===== %s =====\n' "$1"
}

run_optional() {
    local label="$1"
    shift
    if command -v "$1" >/dev/null 2>&1; then
        "$@"
    else
        printf '%s: command not installed\n' "$label"
    fi
}

section "OmarOS system report (read-only)"
printf 'Generated: %s\n' "$(date -Is 2>/dev/null || date)"

section "Operating system and kernel"
if [ -r /etc/os-release ]; then
    cat /etc/os-release
fi
uname -a
run_optional "Uptime" uptime

section "CPU and memory"
run_optional "CPU" lscpu
free -h
run_optional "zRAM" zramctl
run_optional "Swap" swapon --show

section "Disk layout and filesystems"
run_optional "Block devices" lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
run_optional "Filesystem space" df -hT
if command -v smartctl >/dev/null 2>&1; then
    echo "SMART device scan (discovery only; no tests or setting changes):"
    smartctl --scan-open 2>&1 || true
else
    echo "smartctl: command not installed"
fi
if command -v iostat >/dev/null 2>&1; then
    echo "Disk I/O snapshot:"
    iostat -xz 1 2 2>&1 || true
fi

section "Processes and failed services"
run_optional "Top processes" ps -eo pid,comm,%cpu,%mem --sort=-%cpu
if command -v systemctl >/dev/null 2>&1; then
    systemctl --failed --no-legend 2>&1 || true
fi

section "Network interfaces (no SSIDs or IP addresses)"
run_optional "Interfaces" ip -brief link
run_optional "Wi-Fi device summary" iw dev

section "Hardware controllers"
if command -v lspci >/dev/null 2>&1; then
    lspci -nnk | grep -A3 -Ei 'VGA|3D controller|Network controller|Audio device' || true
fi
run_optional "USB devices" lsusb

section "Recent kernel warnings and errors"
if command -v dmesg >/dev/null 2>&1; then
    dmesg -T --level=err,warn 2>&1 | tail -n 60 || true
fi

echo
echo "Report complete. This script does not partition, format, repair, or write to disks."
echo "For the fullest hardware and kernel log details, run it locally with: sudo bash scripts/system-report.sh"
