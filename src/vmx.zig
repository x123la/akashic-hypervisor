const std = @import("std");

pub fn check_vmx_support() bool {
    var ecx: u32 = undefined;
    // CPUID Leaf 1, ECX Bit 5 = VMX
    asm volatile (
        "mov $1, %%eax \n\t" ++
        "cpuid \n\t" ++
        "mov %%ecx, %[out]"
        : [out] "=r" (ecx)
        :
        : "eax", "ebx", "edx"
    );
    return (ecx & (1 << 5)) != 0;
}

pub fn enable_vmx() bool {
    // 1. Enable CR4.VMXE (Bit 13)
    var cr4: u64 = undefined;
    asm volatile ("mov %%cr4, %[out]" : [out] "=r" (cr4));
    cr4 |= (1 << 13);
    asm volatile ("mov %[in], %%cr4" : : [in] "r" (cr4));
    
    return true;
}