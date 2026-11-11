# OmarOS

OmarOS is a lightweight, Arabic-first Linux desktop project tailored for the Acer Aspire E5-576G (Intel Core i5-7200U, 4 GB RAM, 1 TB mechanical HDD, Intel HD 620, NVIDIA MX130, Qualcomm Atheros QCA9377 Wi-Fi).

It is based on **Debian 13 Stable (Trixie)** with a lean **XFCE/X11** desktop. We customize the desktop and system defaults while relying on Debian's maintained kernel, drivers, package manager, and system components rather than writing a kernel from scratch.

## Current status

**Phase 1: reproducible live ISO prototype.** GitHub Actions builds a bootable live ISO from this repository.

The first ISO is for **testing only**. It is not yet a dual-boot installer and it does not repartition, format, or install to the internal HDD. Do not treat it as ready for installation alongside Windows until the installer and recovery procedure have been separately implemented and tested.

## Goals

- Keep Windows 10 intact and provide a separately installed OmarOS in a later dual-boot phase.
- Make the desktop responsive on 4 GB RAM and a mechanical HDD.
- Target roughly 1 GB or less idle memory use as an optimization goal, not a guaranteed hard reservation.
- Use zRAM to reduce slow HDD swap activity under memory pressure.
- Avoid blur, transparency, heavy animations, speculative disk reads, and unnecessary background services.
- Arabic is the default locale; English is also installed. Alt+Shift switches between Arabic and US English layouts.
- Include Wi-Fi, audio, power-management, office, programming, and system-monitoring tools.
- Keep system updates manual and user-approved.

## Build an ISO

Use **GitHub → Actions → Build OmarOS ISO → Run workflow**. A push to the main branch also triggers a build. When successful, download the **OmarOS-live-ISO** artifact from the completed workflow run.

Local build instructions are in **docs/BUILDING.md**.

## Important limitations

- HDD performance cannot be turned into SSD performance by software. zRAM and reduced disk I/O can improve responsiveness, but the mechanical drive remains a bottleneck.
- Brave is installed through the official Brave repository using **scripts/install-brave.sh** after boot.
- 32-bit Windows application support is configured by **scripts/install-wine-multilib.sh**. Jo Academy compatibility is not assumed; it must be tested with the actual application.
- MCP hosts, skills, and coding agents are not bundled into the base OS. They are application-layer tools to select and validate later.
- Intel HD 620 remains the default graphics path. NVIDIA MX130 proprietary-driver support is optional until tested.

## Repository map

- **config/** — Debian Live package lists and root-filesystem defaults.
- **scripts/** — build, validation, installation helpers, and read-only diagnostics.
- **docs/** — architecture, hardware notes, build guide, performance, and dual-boot safety plan.
- **.github/workflows/** — automated ISO build.

## Safety rule

No script in this repository may automatically resize, format, repartition, or overwrite an internal disk. Dual-boot installation work must include disk identification, Windows backup guidance, UEFI/EFI checks, and explicit confirmation before any write operation.
