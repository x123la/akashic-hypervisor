ENTRY(_start)

SECTIONS {
    /* Link the Kernel to run at 2MB */
    . = 2M;

    .text : {
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}