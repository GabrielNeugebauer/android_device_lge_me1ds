#include <stdint.h>
#include <stddef.h>

#define KERNEL_ADDR	0x40080000u
#define KERNEL_MAX	(28u << 20)	/* same cap lk uses */
#define TMP_ADDR	0x48000000u	/* clear of kernel, ramdisk, DTB, ATF */

#define FB_BASE		0x7F870000u
#define FB_STRIDE	1920u
#define FB_BUF		(FB_STRIDE * 864u)

extern uint8_t _payload_start[], _payload_end[];

void *memcpy(void *d, const void *s, size_t n)
{
	uint8_t *dp = d;
	const uint8_t *sp = s;

	while (n--)
		*dp++ = *sp++;
	return d;
}

void *memset(void *d, int c, size_t n)
{
	uint8_t *dp = d;

	while (n--)
		*dp++ = (uint8_t)c;
	return d;
}

/* right-edge progress bar: stage 0 = top half, stage 1 = bottom half */
static void bar(int stage, uint32_t color)
{
	for (uint32_t b = 0; b < 3; b++)
		for (uint32_t y = stage * 427u; y < stage * 427u + 427u; y++) {
			volatile uint32_t *row = (volatile uint32_t *)
				(FB_BASE + b * FB_BUF + y * FB_STRIDE + 440u * 4u);
			for (int x = 0; x < 40; x++)
				row[x] = color;
		}
}

static uint32_t rd32(const uint8_t *p)
{
	return p[0] | p[1] << 8 | p[2] << 16 | (uint32_t)p[3] << 24;
}

/* LZ4 block decoder; returns bytes written or -1 */
static long lz4_block(const uint8_t *ip, const uint8_t *iend, uint8_t *op, uint8_t *oend)
{
	uint8_t *ostart = op;

	while (ip < iend) {
		uint32_t token = *ip++, len = token >> 4, b;

		if (len == 15)
			do { if (ip >= iend) return -1; b = *ip++; len += b; } while (b == 255);
		if (len > (uint32_t)(iend - ip) || len > (uint32_t)(oend - op))
			return -1;
		while (len--)
			*op++ = *ip++;
		if (ip >= iend)
			break;			/* last sequence: literals only */
		if (iend - ip < 2)
			return -1;
		uint32_t off = ip[0] | ip[1] << 8;
		ip += 2;
		if (off == 0 || off > (uint32_t)(op - ostart))
			return -1;
		len = token & 15;
		if (len == 15)
			do { if (ip >= iend) return -1; b = *ip++; len += b; } while (b == 255);
		len += 4;
		if (len > (uint32_t)(oend - op))
			return -1;
		const uint8_t *m = op - off;
		while (len--)
			*op++ = *m++;
	}
	return op - ostart;
}

/* "lz4 -l" legacy stream: magic, then [u32 csize][block]... */
static long lz4_legacy(const uint8_t *ip, const uint8_t *iend, uint8_t *op, uint8_t *oend)
{
	uint8_t *ostart = op;

	if (iend - ip < 4 || rd32(ip) != 0x184C2102)
		return -1;
	ip += 4;
	while (iend - ip >= 4) {
		uint32_t csize = rd32(ip);

		ip += 4;
		if (csize == 0x184C2102)
			continue;
		if (csize > (uint32_t)(iend - ip))
			break;			/* trailing padding */
		long n = lz4_block(ip, ip + csize, op, oend);
		if (n < 0)
			return -1;
		ip += csize;
		op += n;
	}
	return op - ostart;
}

uint32_t kboot_main(uint32_t fdt)
{
	uint32_t clen = _payload_end - _payload_start;
	uint8_t *tmp = (uint8_t *)TMP_ADDR, *k = (uint8_t *)KERNEL_ADDR;

	(void)fdt;
	bar(0, 0xFFFFFFFF);

	/* the payload overlaps KERNEL_ADDR, so move it out of the way first */
	memcpy(tmp, _payload_start, clen);
	long n = lz4_legacy(tmp, tmp + clen, k, k + KERNEL_MAX);
	/* arm64 Image header (3.10 has no magic): "b stext", text_offset 0x80000 */
	if (n < 0x1000 || (rd32(k) >> 26) != 0x05 || rd32(k + 8) != 0x80000)
		return 0;

	bar(1, 0xFFFFFFFF);
	return KERNEL_ADDR;
}
