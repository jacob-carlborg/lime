ENTRY(_start)

SECTIONS
{
  . = 2M; /* Load kernel at 2MB */

  .text :
  {
    *(.multiboot)
    *(.text)
  }

	.rodata : ALIGN(4K)
	{
		*(.rodata)
	}

  .data : ALIGN(4K)
  {
    *(.data)
  }

  .bss : ALIGN(4K)
  {
    *(COMMON)
    *(.bss)
  }
}
