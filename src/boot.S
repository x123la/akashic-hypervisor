.section .multiboot
.align 4
/* Magic */
.long 0x1BADB002
/* Flags: Align (1) + MemInfo (2) = 3 */
.long 0x03
/* Checksum: -(Magic + Flags) */
.long -(0x1BADB002 + 0x03)

.section .bss
.align 16
stack_bottom:
.skip 16384
stack_top:

.section .text
.global _start
.type _start, @function
.code32
_start:
    /* Set up stack */
    mov $stack_top, %esp

    /* Reset EFLAGS */
    pushl $0
    popf

    /* Push Magic (EBX) and Info (EAX) onto stack for kmain */
    push %ebx /* Multiboot Info Pointer */
    push %eax /* Multiboot Magic */

    /* Call Zig Kernel */
    call kmain

    /* Should not return */
    cli
    hlt

.halt:
    hlt
    jmp .halt
