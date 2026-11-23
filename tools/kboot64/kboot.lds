ENTRY(_start)
SECTIONS
{
	. = 0x40008000;
	.text : { *(.text.start) *(.text*) *(.rodata*) }
	/DISCARD/ : { *(.data*) *(.bss*) *(COMMON) *(.ARM.exidx*) *(.ARM.attributes) *(.comment) }
	.payload ALIGN(8) : { *(.payload) }
	_image_end = .;
}
