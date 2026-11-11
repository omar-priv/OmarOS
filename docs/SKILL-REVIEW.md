# External skill review and OmarOS decisions

This document records what was reviewed and which engineering practices were adapted. It does not vendor or reproduce the upstream skill text.

## Reviewed references

| Reference | Useful ideas | OmarOS decision |
|---|---|---|
| [recursive-code-genesis](https://github.com/adryanmoldokkr32-pixel/bionicbot-superskillspowers/tree/main/skills/recursive-code-genesis) | Requirements, architecture, generated code, tests, documentation | High-level outline only. The source is very short and does not provide a concrete kernel, compiler, test, or deployment method, so it is not treated as a technical authority. |
| [huggingOS builder](https://github.com/imthegoodboy/huggingos/tree/main/agent) | Product-vs-kernel-lab separation, phase gates, no fake functionality, QEMU validation, knowledge capture | Adopted in AGENTS.md. OmarOS remains a Debian Linux product track; no custom hobby kernel is being started. |
| [OS Coach](https://github.com/earlyaidopters/os-coach) | Layered identity/context/rules/skills/tools/agents model and goal-specific audits | Adapted as a planning method, not copied as runtime code. OmarOS's current priority is a bootable and testable base OS, not an agentic assistant layer. |
| [QEMU Harness](https://github.com/b3s3da/qemu-harness) | VM lifecycle, explicit guest resources, serial logs, probe/debug loop | Adopted as a test principle. The external harness itself is not bundled because its default overlay/services are for lab guests, not our Debian Live desktop. |
| [low-level-dev-skills](https://github.com/mohitmishra786/low-level-dev-skills) | Kernel testing/debugging, drivers, QEMU, memory hierarchy, profiling and constrained-resource tradeoffs | Selected topics guide test design and diagnosis. Most bare-metal/MCU/DMA material does not apply to a Debian desktop running on an x86 laptop. |
| [C/C++ systems skill](https://github.com/iliaal/ai-skills/tree/master/skills/cpp-systems) | Ownership, RAII, bounds, warnings, sanitizers, API compatibility | Reserved for future native C/C++ utilities or drivers. Current OmarOS changes are Debian configuration and shell scripts, so C++ patterns are not forced into unrelated files. |
| [system diagnostics](https://github.com/sandeshnaroju/ai-skill-engine/tree/main/skills/system_diagnostics) | Disk, uptime, memory, and process health checks | Expanded into the local read-only scripts/system-report.sh. |
| [MCP Builder](https://github.com/anthropics/skills/tree/main/skills/mcp-builder) | Focused tools, schema validation, secure auth, pagination, error handling, and evaluations | Kept as a future design standard. No MCP server is claimed or added to this OS phase. |

## Concrete practices applied

1. Make the product-vs-kernel decision explicit. OmarOS is Debian Live with XFCE, not a custom kernel project.
2. Separate building an ISO from proving it boots. CI now runs a diskless QEMU boot smoke test before publishing the artifact.
3. Check actual package manifests. zRAM configuration alone is insufficient unless zram-tools is installed.
4. Keep diagnostics read-only and report real system state.
5. Require physical-laptop tests for hardware features that QEMU cannot prove.
6. Keep Windows/partition safety as a non-negotiable gate for a future dual-boot installer.

## Scope limits

These sources are guidance, not proof that any code works. Upstream repositories may change. No external skill code is executed or copied wholesale into OmarOS.
