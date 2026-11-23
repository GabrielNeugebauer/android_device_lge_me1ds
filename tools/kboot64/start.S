/*
 * kboot64: lets the LG K130's lk (whose own 64-bit path never reaches the
 * kernel) boot an arm64 kernel. lk starts this as a 32-bit zImage; we unpack
 * the arm64 Image and ask ATF to enter it with lk's jump64 SMC.
 */
	.syntax	unified
	.arm
	.arch_extension sec
	.section .text.start, "ax"
	.globl	_start
_start:
	.rept	8
	mov	r0, r0
	.endr
	b	entry			@ 0x20
	.word	0x016f2818		@ 0x24 zImage magic
	.word	0			@ 0x28 start
	.word	_image_end - _start	@ 0x2c end: lk finds the DTB here

entry:
	mov	r8, r2			@ DTB prepared by lk
	ldr	sp, =0x47F00000
	mrc	p15, 0, r0, c1, c0, 0
	orr	r0, r0, #(1 << 12)	@ I-cache on (MMU stays off)
	mcr	p15, 0, r0, c1, c0, 0
	isb
	bl	kboot_main		@ r0 = arm64 entry, 0 on failure
	cmp	r0, #0
	beq	hang
	mov	r5, r0
	mrc	p15, 0, r0, c1, c0, 0
	bic	r0, r0, #(1 << 12)
	mcr	p15, 0, r0, c1, c0, 0
	mov	r0, #0
	mcr	p15, 0, r0, c7, c5, 0	@ invalidate I-cache
	dsb
	isb
	ldr	r0, =0x82000200		@ MTK SIP: jump to kernel (lk jumparch64_smc)
	mov	r1, r5			@ entry
	mov	r2, r8			@ x0 = DTB
	mov	r3, #0
	mov	r4, #1			@ KERNEL_64BITS
	smc	#0
hang:
	wfe
	b	hang
	.ltorg

	.section .payload, "a"
	.globl	_payload_start, _payload_end
_payload_start:
	.incbin	"Image.lz4"
_payload_end:
	.balign	8
