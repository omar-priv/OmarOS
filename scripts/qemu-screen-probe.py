#!/usr/bin/env python3
"""Capture and compare a QEMU VGA framebuffer through the QMP protocol."""

from __future__ import annotations

import json
import socket
import sys
import time
from pathlib import Path


def receive_json(sock: socket.socket) -> dict:
    stream = sock.makefile("rwb", buffering=0)
    while True:
        line = stream.readline()
        if not line:
            raise RuntimeError("QMP closed the connection unexpectedly")
        message = json.loads(line.decode("utf-8"))
        if "event" in message:
            continue
        return message


def qmp_command(sock: socket.socket, command: str, arguments: dict | None = None) -> dict:
    payload = {"execute": command}
    if arguments:
        payload["arguments"] = arguments
    sock.sendall((json.dumps(payload) + "\r\n").encode("utf-8"))
    while True:
        response = receive_json(sock)
        if "return" in response:
            return response["return"]
        if "error" in response:
            raise RuntimeError(f"QMP {command} failed: {response['error']}")


def capture(socket_path: str, output_path: str) -> None:
    deadline = time.monotonic() + 30
    last_error: Exception | None = None
    while time.monotonic() < deadline:
        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
                sock.settimeout(10)
                sock.connect(socket_path)
                greeting = receive_json(sock)
                if "QMP" not in greeting:
                    raise RuntimeError("QMP greeting was not received")
                qmp_command(sock, "qmp_capabilities")
                status = qmp_command(sock, "query-status")
                if status.get("status") not in {"running", "paused"}:
                    raise RuntimeError(f"Unexpected QEMU status: {status}")
                qmp_command(sock, "screendump", {"filename": output_path})
            if not Path(output_path).is_file() or Path(output_path).stat().st_size < 128:
                raise RuntimeError("QEMU produced an empty VGA screenshot")
            print(f"Captured VGA framebuffer: {output_path}")
            return
        except (OSError, RuntimeError, json.JSONDecodeError) as exc:
            last_error = exc
            time.sleep(1)
    raise RuntimeError(f"Could not capture QEMU VGA framebuffer: {last_error}")


def ppm_pixels(path: str) -> tuple[int, int, bytes]:
    data = Path(path).read_bytes()
    index = 0

    def token() -> bytes:
        nonlocal index
        while index < len(data):
            if data[index:index + 1] == b"#":
                newline = data.find(b"\n", index)
                index = len(data) if newline < 0 else newline + 1
            elif data[index:index + 1].isspace():
                index += 1
            else:
                break
        start = index
        while index < len(data) and not data[index:index + 1].isspace():
            index += 1
        value = data[start:index]
        while index < len(data) and data[index:index + 1].isspace():
            index += 1
        return value

    if token() != b"P6":
        raise RuntimeError(f"{path} is not a binary PPM screenshot")
    width = int(token())
    height = int(token())
    maximum = int(token())
    if maximum != 255:
        raise RuntimeError(f"Unsupported PPM color depth: {maximum}")
    pixels = data[index:]
    if len(pixels) != width * height * 3:
        raise RuntimeError(f"Truncated PPM screenshot: {path}")
    return width, height, pixels


def metrics(path: str) -> tuple[int, int, bytes]:
    width, height, pixels = ppm_pixels(path)
    non_black = 0
    colors: set[tuple[int, int, int]] = set()
    for offset in range(0, len(pixels), 3):
        red, green, blue = pixels[offset:offset + 3]
        if red > 12 or green > 12 or blue > 12:
            non_black += 1
        colors.add((red // 32, green // 32, blue // 32))
    ratio = non_black / (width * height)
    print(f"{path}: {width}x{height}, non-black={ratio:.3%}, color-buckets={len(colors)}")
    return non_black, len(colors), pixels


def compare(first: str, second: str) -> None:
    n1, c1, p1 = metrics(first)
    n2, c2, p2 = metrics(second)
    if len(p1) != len(p2):
        raise RuntimeError("QEMU screenshot dimensions changed between probes")
    sample_step = max(3, (len(p1) // 30000) // 3 * 3)
    sample_step -= sample_step % 3
    sample_step = max(3, sample_step)
    samples = list(range(0, len(p1) - 2, sample_step))
    changed = sum(
        1 for offset in samples
        if max(abs(p1[offset + channel] - p2[offset + channel]) for channel in range(3)) > 24
    )
    changed_ratio = changed / max(1, len(samples))
    print(f"Framebuffer changed across boot window: {changed_ratio:.2%} of sampled pixels")
    if n2 < 1000 or c2 < 8 or changed_ratio < 0.005:
        raise RuntimeError("VGA framebuffer did not show convincing boot progress")
    print("VGA framebuffer is visible and changed during the boot window.")


def main() -> None:
    if len(sys.argv) == 4 and sys.argv[1] == "capture":
        capture(sys.argv[2], sys.argv[3])
    elif len(sys.argv) == 4 and sys.argv[1] == "compare":
        compare(sys.argv[2], sys.argv[3])
    else:
        raise SystemExit(
            "Usage: qemu-screen-probe.py capture QMP_SOCKET OUTPUT.ppm\n"
            "   or: qemu-screen-probe.py compare FIRST.ppm SECOND.ppm"
        )


if __name__ == "__main__":
    main()
