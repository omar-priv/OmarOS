# Target hardware

| Component | Target |
|---|---|
| Laptop | Acer Aspire E5-576G |
| CPU | Intel Core i5-7200U |
| RAM | 4 GB |
| Internal storage | 1 TB WDC mechanical HDD |
| Integrated graphics | Intel HD Graphics 620 |
| Discrete graphics | NVIDIA GeForce MX130 |
| Wi-Fi | Qualcomm Atheros QCA9377 |
| Operating system to preserve | Windows 10 Pro |

## Driver approach

Use the Intel integrated GPU by default. Include Debian firmware packages for Atheros Wi-Fi and Intel graphics. Test the NVIDIA adapter separately; do not make a proprietary driver a boot requirement.

## Performance expectations

The HDD has mechanical seek latency. A lightweight desktop and zRAM can reduce some stalls, but cannot remove physical seek time. A lightweight OS may feel quicker than a full desktop on the same HDD, but large application launches and random I/O remain limited by the drive.

With 4 GB RAM, large browser sessions, LibreOffice, and Wine may compete for memory. The desktop should remain usable when idle, but no fixed 1 GB system cap will be imposed.

## Required target-device tests

- cold boot and restart
- Wi-Fi connection and reconnect
- audio output and microphone input
- touchpad, wireless mouse, keyboard, brightness, and volume keys
- suspend and resume
- battery reporting and power management
- browser video playback
- office documents
- memory pressure with browser plus office application
- Windows boot and recovery after any later dual-boot work
