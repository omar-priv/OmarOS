# OmarOS

OmarOS is a lightweight, Arabic-first Linux desktop project tailored to the Acer Aspire E5-576G (Intel Core i5-7200U, 4 GB RAM, 1 TB mechanical HDD, Intel HD 620, NVIDIA MX130, Qualcomm Atheros QCA9377 Wi-Fi).

It is based on **Debian 13 Stable (Trixie)** with a lean **XFCE/X11** desktop. OmarOS customizes the desktop and system defaults while relying on Debian's maintained kernel, drivers, package manager, and userspace components rather than writing a kernel from scratch.

## Current status

**Phase 1: reproducible live ISO prototype with automated QEMU boot smoke test.**

The ISO is for testing only. It is not yet a dual-boot installer and it does not repartition, format, or install to the internal HDD. Do not install it alongside Windows until the installer and recovery procedure have been separately implemented and tested.

## Goals

- Preserve Windows 10 and later provide a separately installed OmarOS through dual boot.
- Make the desktop responsive on 4 GB RAM and a mechanical HDD.
- Target roughly 1 GB or less idle memory use as an optimization goal, not a guaranteed hard reservation.
- Use zRAM to reduce slow HDD swap activity under memory pressure.
- Avoid blur, transparency, heavy animations, speculative disk reads, and unnecessary background services.
- Arabic is the default locale; English is also installed. Alt+Shift switches between Arabic and US English layouts.
- Include Wi-Fi, audio, power-management, office, programming, and system-diagnostics tools.
- Keep system updates manual and user-approved.

## Build an ISO

Open **GitHub → Actions → Build OmarOS ISO → Run workflow**. A push to the main branch also triggers a build. The workflow validates project files, builds the ISO, boots it in a diskless QEMU virtual machine, and uploads the artifact only if the smoke test passes.

See **docs/BUILDING.md** for details.

## Important limitations

- HDD performance cannot be turned into SSD performance by software. zRAM and reduced disk I/O can improve responsiveness, but the mechanical drive remains a bottleneck.
- Brave is installed through the official Brave repository using **scripts/install-brave.sh** after boot.
- 32-bit Windows application support is configured by **scripts/install-wine-multilib.sh**. Jo Academy compatibility is not assumed; it must be tested with the actual application.
- MCP hosts, skills, and coding agents are application-layer tools and are not bundled into the base OS.
- Intel HD 620 is the default graphics path. NVIDIA MX130 proprietary-driver support is optional until tested.
- A successful CI build/QEMU boot is not proof that Wi-Fi, audio, battery, suspend, graphics, or Jo Academy work on the physical Acer laptop.

## Repository map

- **AGENTS.md** — instructions and safety gates for future code agents.
- **config/** — Debian Live package lists and root-filesystem defaults.
- **scripts/** — build, validation, diagnostics, and QEMU smoke test.
- **docs/** — architecture, hardware notes, build guide, performance, dual-boot safety, and skill review.
- **.github/workflows/** — automated build and test pipeline.

## Safety rule

No script in this repository may automatically resize, format, repartition, or overwrite an internal disk. Dual-boot installation work must include disk identification, Windows backup guidance, UEFI/EFI checks, a dry-run plan, and explicit confirmation before any write operation.
