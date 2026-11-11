# Performance plan for a 4 GB HDD laptop

## Principles

1. Keep the idle desktop lean.
2. Avoid speculative disk reads and background indexing.
3. Use zRAM before disk-backed swap.
4. Keep visual effects simple.
5. Measure real boot and app-launch behavior rather than promising SSD-like speeds.

## zRAM

The image includes zram-tools configured for LZ4 compression and a maximum size of 50% of physical RAM. This does not reserve 2 GB immediately; RAM is consumed as compressed pages are stored. LZ4 is selected for compression speed on the dual-core i5-7200U.

## Memory target

The design goal is around 1 GB or less at idle, measured after the first login and after background startup settles. This is a target, not a guarantee. Memory use varies with drivers, desktop services, and the exact live session.

## HDD limitations

Software cannot remove mechanical seek latency. A lightweight OS may feel quicker than a full desktop on the same HDD, especially when fewer background services access storage, but large application launches and random I/O remain limited by the drive.

## Benchmark checklist

Record these for every test build:
- seconds from boot selection to interactive desktop
- idle RAM and zRAM state
- CPU use after login settles
- time to open the file manager and terminal
- time to launch the browser
- disk utilization during startup
- responsiveness while opening multiple applications

Do not compare results from different boot media without recording the media type and connection speed.
