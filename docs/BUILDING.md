# Building OmarOS

## GitHub Actions (recommended)

1. Open this repository on GitHub.
2. Open the **Actions** tab.
3. Select **Build OmarOS ISO**.
4. Select **Run workflow** on the main branch.
5. The pipeline validates the source, builds the ISO, and boots it in QEMU without an attached hard disk.
6. Download **OmarOS-live-ISO** only after the workflow has passed.

A push to main also starts a build. The uploaded artifact is temporary and currently retained for seven days.

## Local build

A local build requires Debian 13 amd64 with root privileges, internet access, and several gigabytes of free disk space. It is not recommended to build on the target laptop while it has only 4 GB RAM and a mechanical HDD.

From the repository root, run:

    sudo bash scripts/validate-project.sh
    sudo bash scripts/build-iso.sh
    bash scripts/qemu-smoke.sh live-image-amd64.hybrid.iso

The build script only creates an ISO in the project directory. It does not write to USB media or internal disks.

## Booting the ISO on hardware

Write the ISO to a spare USB using a trusted image-writing tool, then choose the USB from the laptop's one-time boot menu. Select the live session, not an installer.

The first image is for hardware and performance testing only. It does not include an internal-disk installer. Do not install it to the internal disk.

## Expected output

The expected output is live-image-amd64.hybrid.iso in the project root. CI uploads it as the OmarOS-live-ISO artifact after the QEMU smoke test passes.
