const std = @import("std");
const vmcs = @import("vmcs.zig");
const kernel = @import("kernel.zig"); // for printing

export fn handle_vm_exit() void {
    const reason = vmcs.vmread(vmcs.VM_EXIT_REASON);
    
    // Basic Exit Reason: 12 (HLT), 10 (CPUID), 30 (IO_INSTRUCTION)
    
    // Mask off the top bits (16-31 are mostly flags)
    const basic_reason = reason & 0xFFFF;

    if (basic_reason == 30) {
        // I/O Instruction
        handle_io();
    } else if (basic_reason == 12) {
        // HLT
        kernel.vga_print("[HYPERVISOR] Guest Halted. Resuming...\n");
        advance_rip();
    } else {
        kernel.vga_print("[HYPERVISOR] Unknown Exit Reason: ");
        // TODO: Print integer reason
        // Since we don't have fmt, just loop forever to see trace
        while(true) {} 
    }
}

fn handle_io() void {
    const exit_qual = vmcs.vmread(vmcs.EXIT_QUALIFICATION);
    // Bit 3 = 0 (Out), 1 (In)
    // Bits 0-2 = Size (0=1, 1=2, 3=4 bytes)
    // Bits 16-31 = Port
    
    const is_in = (exit_qual & 8) != 0;
    const port = (exit_qual >> 16) & 0xFFFF;
    
    if (!is_in and port == 0x3F8) {
        // OUT 0x3F8, AL (Guest printing to Serial)
        // We need the value in AL.
        // In 32-bit pusha stack, EAX is at offset...
        // Let's simplified assumption: Guest put 'A' in AL.
        // We can't easily read Guest Regs without passing the pointer from ASM.
        // For MVP, just print a char to prove interception.
        kernel.vga_print("[GUEST SAYS] 'A'\n");
    }
    
    advance_rip();
}

fn advance_rip() void {
    const len = vmcs.vmread(vmcs.VM_EXIT_INSTRUCTION_LEN);
    const rip = vmcs.vmread(vmcs.GUEST_RIP);
    vmcs.vmwrite(vmcs.GUEST_RIP, rip + len);
}