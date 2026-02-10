const std = @import("std");

// Tiny 32-bit Guest Kernel
// 1. Set DX = 0x3F8 (COM1)
// 2. Mov AL = 'A'
// 3. Out DX, AL
// 4. Hlt
// 5. Jmp to 1

pub const code = [_]u8{
    0xBA, 0xF8, 0x03, 0x00, 0x00, // mov edx, 0x3F8
    0xB0, 0x41,                   // mov al, 'A'
    0xEE,                         // out dx, al
    0xB0, 0x4B,                   // mov al, 'K'
    0xEE,                         // out dx, al
    0xB0, 0x41,                   // mov al, 'A'
    0xEE,                         // out dx, al
    0xF4,                         // hlt
    0xEB, 0xF0                    // jmp back
};
