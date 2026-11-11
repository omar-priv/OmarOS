# OmarOS testing strategy

## Test layers

### 1. Static project checks

Run:

    bash scripts/validate-project.sh
    git diff --check

These checks validate shell syntax, package-list uniqueness, and required project files. They do not prove the image boots.

### 2. ISO build

Run:

    sudo bash scripts/build-iso.sh

The build must finish successfully and produce live-image-amd64.hybrid.iso. The image must include the expected live package manifest, including zram-tools.

### 3. QEMU boot smoke test

Run:

    bash scripts/qemu-smoke.sh live-image-amd64.hybrid.iso

The test starts a 64-bit x86 QEMU guest with 2 GB RAM and two virtual CPUs. Only the ISO is attached. No host disk, partition, or block device is passed to QEMU.

The test captures the serial console and waits for the graphical target or display manager to start. It is a basic boot smoke test, not a complete desktop or hardware certification.

### 4. Physical Acer tests

QEMU cannot certify the physical Wi-Fi chipset, audio codec, touchpad, battery, brightness keys, suspend/resume, Intel/NVIDIA graphics, or Jo Academy compatibility.

The target Acer Aspire E5-576G must be tested for:

- UEFI/Legacy boot compatibility and display resolution.
- Wi-Fi connect/reconnect using Qualcomm Atheros QCA9377.
- Audio output and microphone.
- Touchpad, wireless mouse, keyboard layout, and hotkeys.
- Battery reporting, power management, suspend and resume.
- Idle RAM, zRAM state, CPU, disk utilization, boot time, and app launch time.
- Brave, LibreOffice, Python, Node.js, Git, Wine, and actual Jo Academy behavior.

Record measurements and logs without committing device serial numbers, network SSIDs, IP addresses, or personal files.

## Failure handling

If static checks fail, fix them before building. If QEMU fails, preserve the serial log and diagnose the first failing stage. Do not publish a successful-looking artifact after a failed boot test. If a physical-device check is not run, leave it marked as untested.
