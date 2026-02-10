.global vmlaunch_wrapper
.type vmlaunch_wrapper, @function
.code32
vmlaunch_wrapper:
    /* 1. Save Host Callee-Saved Registers (if needed) */
    push %ebp
    push %ebx
    push %esi
    push %edi

    /* 2. Launch VM */
    vmlaunch

    /* 3. If we get here, VMLAUNCH failed */
    /* Check Error Code? set EAX=1 */
    mov $1, %eax
    pop %edi
    pop %esi
    pop %ebx
    pop %ebp
    ret

.global vm_exit_handler_entry
.type vm_exit_handler_entry, @function
vm_exit_handler_entry:
    /* VM Exit lands here defined by HOST_RIP in VMCS */
    
    /* 1. Save Guest General Purpose Registers to memory (guest_regs) */
    /* (Simplified for 32-bit: Push all) */
    pusha

    /* 2. Call Zig Exit Handler */
    call handle_vm_exit

    /* 3. Restore Guest Registers */
    popa

    /* 4. Resume VM */
    vmresume

    /* 5. If VMRESUME fails */
    hlt
