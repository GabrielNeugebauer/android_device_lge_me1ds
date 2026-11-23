#!/usr/bin/env python3
"""Build an Android v0 boot image for MediaTek lk (page 2048, base 0x40000000)."""
import argparse
import hashlib
import struct


def pad(b, page):
    return b + b"\0" * ((page - len(b) % page) % page)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--kernel", required=True)
    ap.add_argument("--ramdisk", required=True)
    ap.add_argument("--cmdline", required=True)
    ap.add_argument("--kernel-offset", type=lambda x: int(x, 0), required=True)
    ap.add_argument("--base", type=lambda x: int(x, 0), default=0x40000000)
    ap.add_argument("--ramdisk-offset", type=lambda x: int(x, 0), default=0x04000000)
    ap.add_argument("--tags-offset", type=lambda x: int(x, 0), default=0x0E000000)
    ap.add_argument("--second-offset", type=lambda x: int(x, 0), default=0x00F00000)
    ap.add_argument("--pagesize", type=int, default=2048)
    ap.add_argument("--max-size", type=int, default=16 * 1024 * 1024)
    ap.add_argument("--no-pad", action="store_true",
                    help="do not zero-fill to --max-size (LG lk treats stale bytes after the image as a bad signature)")
    ap.add_argument("-o", "--output", required=True)
    a = ap.parse_args()

    kernel = open(a.kernel, "rb").read()
    ramdisk = open(a.ramdisk, "rb").read()
    sha = hashlib.sha1()
    for blob in (kernel, ramdisk, b""):
        sha.update(blob)
        sha.update(struct.pack("<I", len(blob)))

    cmd = a.cmdline.encode()
    assert len(cmd) < 512, "cmdline too long"
    hdr = b"ANDROID!" + struct.pack(
        "<10I", len(kernel), a.base + a.kernel_offset, len(ramdisk), a.base + a.ramdisk_offset,
        0, a.base + a.second_offset, a.base + a.tags_offset, a.pagesize, 0, 0)
    hdr += b"\0" * 16 + cmd.ljust(512, b"\0") + sha.digest().ljust(32, b"\0")
    img = pad(hdr, a.pagesize) + pad(kernel, a.pagesize) + pad(ramdisk, a.pagesize)
    assert len(img) <= a.max_size, f"image {len(img)} > {a.max_size}"
    if not a.no_pad:
        img += b"\0" * (a.max_size - len(img))
    open(a.output, "wb").write(img)
    print(f"{a.output}: {len(img)} bytes (kernel {len(kernel)}, ramdisk {len(ramdisk)})")


if __name__ == "__main__":
    main()
