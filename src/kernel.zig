const std = @import("std");
const vmx = @import("vmx.zig");
const pmm = @import("pmm.zig");
const ept = @import("ept.zig");
const vmcs = @import("vmcs.zig");
const vm_exit = @import("vm_exit.zig");
const multiboot = @import("multiboot.zig");
const debug = @import("debug.zig");
const runtime = @import("runtime.zig");

// Force compilation of vm_exit to ensure handle_vm_exit is exported
comptime {
    _ = vm_exit;
    _ = runtime;
}

// VGA Text Buffer (0xB8000)
const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_MEMORY = @as([*]volatile u16, @ptrFromInt(0xB8000));

var term_row: usize = 0;
var term_col: usize = 0;
var term_color: u8 = 0x0F; // White on Black

// Serial Port Logic
const COM1 = 0x3f8;

fn outb(port: u16, data: u8) void {
    asm volatile ("outb %[data], %[port]" : : [data] "{al}" (data), [port] "{dx}" (port));
}

fn init_serial() void {
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x80);
    outb(COM1 + 0, 0x03);
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x03);
    outb(COM1 + 2, 0xC7);
    outb(COM1 + 4, 0x0B);
}

pub fn serial_putc(c: u8) void {
    outb(COM1, c);
}

pub fn vga_putc(c: u8) void {
    serial_putc(c); 
    if (c == '\n') {
        term_row += 1;
        term_col = 0;
        return;
    }
    const index = term_row * VGA_WIDTH + term_col;
    VGA_MEMORY[index] = (@as(u16, term_color) << 8) | c;
    term_col += 1;
    if (term_col == VGA_WIDTH) {
        term_col = 0;
        term_row += 1;
    }
}

pub fn vga_print(str: []const u8) void {
    for (str) |c| {
        vga_putc(c);
    }
}

extern fn fortress_verify_security(pml4_addr: usize) callconv(.C) c_int;
extern fn vmlaunch_wrapper() callconv(.C) void;
extern fn vm_exit_handler_entry() callconv(.C) void;

var pml4: ept.EptTable align(4096) = undefined;
var pdpt: ept.EptTable align(4096) = undefined;
var pd:   ept.EptTable align(4096) = undefined;
var pt:   ept.EptTable align(4096) = undefined;

// VMCS Region (4KB aligned)
var vmcs_region: [4096]u8 align(4096) = undefined;

// Guest Load Address (Fixed for MVP: 2MB mark)
const GUEST_LOAD_ADDR: usize = 0x200000;

export fn kmain(magic: u32, info_addr: u32) void {
    init_serial();
    term_row = 0; term_col = 0;

    debug.kprint("\nAkashic Hypervisor (Verified Loader) v0.3\n", .{});
    debug.kprint("-----------------------------------------\n", .{});

    // 1. Check Multiboot
    if (magic != 0x2BADB002) {
        debug.kprint("FATAL: Invalid Multiboot Magic: 0x{X}\n", .{magic});
        while(true) asm volatile("hlt");
    }
    const mbi = @as(*multiboot.MultibootInfo, @ptrFromInt(info_addr));
    debug.kprint("[BOOT] Multiboot Info at 0x{X}\n", .{info_addr});

    // 2. Load Guest Module
    if ((mbi.flags & 8) == 0 or mbi.mods_count == 0) {
        debug.kprint("FATAL: No Guest Module Loaded (Use -initrd guest.bin)\n", .{});
        while(true) asm volatile("hlt");
    }
    
    const mods = @as([*]multiboot.MultibootModule, @ptrFromInt(mbi.mods_addr));
    const guest_mod = mods[0];
    const guest_size = guest_mod.mod_end - guest_mod.mod_start;
    
    debug.kprint("[LOAD] Found Module at 0x{X} (Size: {} bytes)\n", .{guest_mod.mod_start, guest_size});
    
    // Copy to GUEST_LOAD_ADDR
    const src_ptr = @as([*]const u8, @ptrFromInt(guest_mod.mod_start));
    const dst_ptr = @as([*]u8, @ptrFromInt(GUEST_LOAD_ADDR));
    @memcpy(dst_ptr[0..guest_size], src_ptr[0..guest_size]);
    
    debug.kprint("[LOAD] Guest Relocated to 0x{X}\n", .{GUEST_LOAD_ADDR});

    // 3. PMM & EPT
    pmm.init(mbi.mem_upper / 1024); // KB to MB conversion approx
    ept.create_identity_map(&pml4, &pdpt, &pd, &pt);
    
    // 4. Verify
    if (fortress_verify_security(@intFromPtr(&pml4)) != 1) {
        debug.kprint("FATAL: Security Verification Failed.\n", .{});
        while(true) asm volatile("hlt");
    }
    debug.kprint("[SAFE] Memory Maps Verified.\n", .{});

    // 5. VMX
    if (!vmx.check_vmx_support()) {
        debug.kprint("FATAL: No VMX Support.\n", .{});
        // while(true) asm volatile("hlt"); 
        // For QEMU MVP without nested virt, we skip VMLAUNCH to avoid crash
        debug.kprint("WARNING: Skipping VMLAUNCH (Simulation Mode)\n", .{});
        while(true) asm volatile("hlt");
    }
    _ = vmx.enable_vmx(); 

    // Prepare VMCS
    const revision_id = 1; 
    @memcpy(vmcs_region[0..4], std.mem.asBytes(&@as(u32, revision_id)));
    
    const vmcs_phys = @intFromPtr(&vmcs_region);
    _ = vmcs_phys;

    // HOST STATE
    vmcs.vmwrite(vmcs.HOST_CR0, 0); 
    vmcs.vmwrite(vmcs.HOST_RIP, @intFromPtr(&vm_exit_handler_entry));

    // GUEST STATE - Use Loaded Address
    vmcs.vmwrite(vmcs.GUEST_RIP, GUEST_LOAD_ADDR);
    vmcs.vmwrite(vmcs.GUEST_RFLAGS, 0x2); 

    debug.kprint("[VMX]  Launching Guest at 0x{X}...\n", .{GUEST_LOAD_ADDR});
    vmlaunch_wrapper();
    
    debug.kprint("FATAL: VMLAUNCH Returned (Failure).\n", .{});
    while (true) {
        asm volatile ("hlt");
    }
}