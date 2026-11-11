# OmarOS architecture

## Base system

- Distribution: Debian 13 Stable (Trixie), amd64.
- Image technology: Debian Live and live-build.
- Desktop: XFCE on X11.
- Display manager: LightDM.
- Network: NetworkManager with wpa_supplicant.
- Audio: PipeWire with WirePlumber.
- Future installed filesystem: ext4, subject to disk-layout review.
- Boot: UEFI-first, with legacy compatibility to be assessed on the laptop.

## Layer model

1. Linux kernel, firmware, and hardware drivers.
2. Debian userspace, system services, networking, audio, and power management.
3. XFCE desktop session, window manager, panel, settings, and notifications.
4. OmarOS branding, defaults, and small purpose-built utilities.
5. User applications such as Brave, LibreOffice, Python, Node.js, Git, and Wine.

We do not plan to implement a custom kernel, package manager, display server, or window manager. Reusing maintained components reduces risk and makes security updates practical.

## Memory and storage design

- zram-tools uses a compressed swap device in RAM. It is configured with a 50% maximum capacity; this is a limit, not a permanent reservation of half the RAM.
- Do not enable a large swap file on the mechanical disk by default. Any disk-backed swap policy must be measured on the actual laptop.
- Avoid preload-style speculative disk reads, unnecessary background indexing, heavy desktop effects, and unnecessary daemons.
- Let the Linux page cache use otherwise-idle memory. Do not hard-reserve 3 GB for applications or hard-cap the OS at exactly 1 GB.
- Keep logs and caches under control without deleting user data or disabling security updates.

## Desktop design

The intended direction is a compact Windows-inspired desktop: centered launcher/taskbar, clear window controls, dark and light theme options, Arabic-friendly typography, and unified settings. The first ISO is a functional XFCE baseline; the custom shell and panel will be developed and tested incrementally.

## Hardware policy

- Intel HD 620 is the default graphics adapter.
- Qualcomm Atheros QCA9377 firmware is included.
- Intel microcode and common laptop firmware are included where available.
- NVIDIA MX130 proprietary drivers remain optional until suspend/resume, external display, thermal behavior, and graphics acceleration have been tested.

## Build and release policy

Every ISO must be reproducible from tracked configuration. CI validates shell scripts and builds the live image. A release is not considered stable until it boots on the target laptop and passes the hardware and data-preservation tests in the roadmap.
