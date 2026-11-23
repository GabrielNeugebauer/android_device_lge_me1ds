#!/usr/bin/env python3
"""Recompress a boot image's ramdisk with legacy LZ4 (the stock me1ds kernel only has RD_LZ4)."""
import gzip
import hashlib
import struct
import subprocess
import sys


def pad(n, page):
    return (n + page - 1) // page * page


def main(src, dst, limit):
    d = open(src, "rb").read()
    assert d[:8] == b"ANDROID!", "not an Android boot image"
    ks, ka, rs, ra, ss, sa, ta, ps = struct.unpack("<8I", d[8:40])
    kernel = d[ps:ps + ks]
    roff = ps + pad(ks, ps)
    ramdisk = d[roff:roff + rs]
    second = d[roff + pad(rs, ps):roff + pad(rs, ps) + ss]

    if ramdisk[:2] == b"\x1f\x8b":
        ramdisk = gzip.decompress(ramdisk)
    lz4 = subprocess.run(["lz4", "-l", "-9", "-c"], input=ramdisk, stdout=subprocess.PIPE, check=True).stdout

    sha = hashlib.sha1()
    for blob in (kernel, lz4, second):
        sha.update(blob)
        sha.update(struct.pack("<I", len(blob)))
    hdr = bytearray(d[:ps])
    hdr[8:40] = struct.pack("<8I", ks, ka, len(lz4), ra, ss, sa, ta, ps)
    hdr[576:608] = sha.digest().ljust(32, b"\0")

    out = bytes(hdr)
    for blob in (kernel, lz4, second):
        out += blob + b"\0" * (pad(len(blob), ps) - len(blob))
    print(f"kernel={ks} ramdisk(cpio)={len(ramdisk)} ramdisk(lz4)={len(lz4)} image={len(out)} limit={limit}")
    if len(out) > limit:
        sys.exit(f"image too large: {len(out)} > {limit}")
    # LG lk reads a signature right after the image; zeros mean "unsigned"
    # (allowed when unlocked), stale partition bytes fail with error 1003.
    open(dst, "wb").write(out + b"\0" * (limit - len(out)))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]))
