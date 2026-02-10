const std = @import("std");

pub const GuestState = extern struct {
    rax: usize,
    rcx: usize,
    rdx: usize,
    rbx: usize,
    rbp: usize,
    rsi: usize,
    rdi: usize,
    r8: usize,
    r9: usize,
    r10: usize,
    r11: usize,
    r12: usize,
    r13: usize,
    r14: usize,
    r15: usize,
};

// Global instance to save guest state
pub var guest_regs: GuestState = undefined;
