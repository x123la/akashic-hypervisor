const std = @import("std");

// EPT Definitions (Intel SDM Vol 3C)

pub const EPT_READ: u64 = 1 << 0;
pub const EPT_WRITE: u64 = 1 << 1;
pub const EPT_EXEC: u64 = 1 << 2;
pub const EPT_MEM_TYPE_WB: u64 = 6 << 3;

pub const EptEntry = packed struct {
    read: bool,
    write: bool,
    exec: bool,
    mem_type: u3,
    ignore_pat: bool,
    ignored1: bool,
    accessed: bool,
    dirty: bool,
    execute_for_user_mode: bool,
    ignored2: u1,
    pfn: u40, // Physical Frame Number (Bit 12-51)
    ignored3: u12,
};

pub const EptTable = [512]u64;

// Create a mock EPT hierarchy for Guest 1
// We need a PML4, a PDPT, a PD, and a PT.
// All must be 4KB aligned.

pub fn create_identity_map(pml4: *EptTable, pdpt: *EptTable, pd: *EptTable, pt: *EptTable) void {
    // 1. Clear tables
    @memset(pml4, 0);
    @memset(pdpt, 0);
    @memset(pd, 0);
    @memset(pt, 0);

    // 2. Link PML4[0] -> PDPT
    pml4[0] = @intFromPtr(pdpt) | EPT_READ | EPT_WRITE | EPT_EXEC;

    // 3. Link PDPT[0] -> PD
    pdpt[0] = @intFromPtr(pd) | EPT_READ | EPT_WRITE | EPT_EXEC;

    // 4. Link PD[0] -> PT
    pd[0] = @intFromPtr(pt) | EPT_READ | EPT_WRITE | EPT_EXEC;

    // 5. Identity Map first 4MB in PT (4KB pages)
    var i: usize = 0;
    while (i < 1024) : (i += 1) {
        const addr = i * 4096;
        // Map as RWX for now
        pt[i] = addr | EPT_READ | EPT_WRITE | EPT_EXEC | EPT_MEM_TYPE_WB;
    }
}

pub fn create_malicious_map(pt: *EptTable) void {
    // SECURITY VIOLATION: Map the "Kernel Secret" page (let's pretend 0x100000 is secret)
    // as Writeable for the guest.
    // In our policy, Guest Physical 0xCAFE0000 -> Host Physical 0x100000 (Kernel Code)
    // with WRITE permission.
    
    // We'll just modify the first entry to point to a high secure address
    // with WRITE permission.
    pt[0] = 0x00100000 | EPT_READ | EPT_WRITE | EPT_EXEC | EPT_MEM_TYPE_WB;
}
