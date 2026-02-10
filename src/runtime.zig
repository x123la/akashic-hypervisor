const std = @import("std");

export fn memset(dest: [*]u8, val: u8, len: usize) callconv(.C) [*]u8 {
    var i: usize = 0;
    while (i < len) : (i += 1) {
        dest[i] = val;
    }
    return dest;
}

export fn memcpy(dest: [*]u8, src: [*]const u8, len: usize) callconv(.C) [*]u8 {
    var i: usize = 0;
    while (i < len) : (i += 1) {
        dest[i] = src[i];
    }
    return dest;
}

export fn __zig_probe_stack() callconv(.C) void {
    // No-op for freestanding
}
