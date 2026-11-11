# Dual-boot safety plan

## Current state

The current project builds a live ISO for testing. It does **not** contain an internal-disk installer. This is intentional.

## Before any dual-boot installation

The target laptop's partition layout is not yet verified. Collect these details from Windows before any partition changes:

1. UEFI or Legacy/CSM boot mode.
2. GPT or MBR partition table.
3. Exact Windows partition sizes and free space.
4. EFI System Partition size and filesystem, if present.
5. BitLocker/device-encryption status and recovery key availability.
6. Windows recovery media and a verified backup of important files.

## Non-negotiable safeguards

- Never format the whole disk.
- Never delete, format, or resize Windows, EFI, recovery, or OEM partitions without a reviewed plan.
- Never assume a Windows drive letter maps to a Linux device name.
- Identify disks by model, capacity, and partition layout, not by an assumed /dev/sda or /dev/nvme0n1 name.
- Do not run partitioning tools unattended.
- Show a dry-run plan and require explicit user confirmation before each destructive write.
- Provide a tested route to boot Windows directly if the Linux boot menu fails.

## Future installation design

The installer should use a supported Debian installer or a carefully configured Calamares workflow only after the target disk has been inspected. The first installation guide will be interactive and conservative. Automatic repartitioning is out of scope.

## Recovery plan

Document Windows Boot Manager recovery, a live USB recovery path, and how to restore the existing EFI boot order. Validate recovery steps in a test environment before publishing a stable installer.
