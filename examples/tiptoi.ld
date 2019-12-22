/* Entry Point */

ENTRY( reset_handler )

_estack = 0x08050000; /*. end of 64K RAM */

_Min_Heap_Size = 0; 		/* required amount of heap  */
_Min_Stack_Size = 0x200; 	/* required amount of stack */

/* memory areas */

MEMORY
{
     ROM ( rx ) : ORIGIN = 0x00000000 , LENGTH = 64K
     RAM ( xrw) : ORIGIN = 0x08010000 , LENGTH = 128K /* SRAM actually starts at 0x08000000, so its overall length would be 192K */
}

SECTIONS
{
    . = 0;

    .text :
    {
        KEEP(*(.isr_vector))
        *(.text)
        *(.text.*)

        . = ALIGN(4);
        *(.rodata)
        *(.rodata.*)
    } > RAM

    . = ALIGN(8);
    _etext = .;

    .data : ALIGN(8)
    {
        _data = .;
        *(.data)
        *(.data.*)
        . = ALIGN(8);
        _edata = .;
    } > RAM 

    .bss :
    {
        _bss_start = .;
        *(.bss)
        *(.bss.*)
        . = ALIGN(8);
        _bss_end = .;
    } > RAM

    _end = .;
    PROVIDE(end = .);
}


