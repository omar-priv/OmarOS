# Building OmarOS

## GitHub Actions (recommended)

1. Open this repository on GitHub.
2. Open the **Actions** tab.
3. Select **Build OmarOS ISO**.
4. Select **Run workflow** on the main branch.
5. Wait for the workflow to finish successfully.
6. Open the completed run and download the **OmarOS-live-ISO** artifact.

A push to main also starts an ISO build.

## Local build

A local build requires a Debian 13 amd64 environment with root privileges, internet access, and several gigabytes of free disk space. It is not recommended to build on the target laptop while it still has 4 GB RAM and a mechanical HDD.

From the repository root, run:

    sudo bash scripts/validate-project.sh
    sudo bash scripts/build-iso.sh

The build script only creates an ISO in the project directory. It does not write to USB media or internal disks.

## Booting the ISO

Write the ISO to a spare USB using a trusted image-writing tool, then choose the USB from the laptop's one-time boot menu. Select the live session, not an installer.

The first image is for hardware and performance testing only. Do not install it to the internal disk.

## Expected output

The expected output is **live-image-amd64.hybrid.iso** in the project root. CI uploads it as a temporary artifact.
