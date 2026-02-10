const std = @import("std");
const kernel = @import("kernel.zig");

pub const SerialWriter = struct {
    pub const Error = error{};
    
    pub fn write(self: SerialWriter, bytes: []const u8) Error!usize {
        _ = self;
        for (bytes) |c| {
            kernel.serial_putc(c);
        }
        return bytes.len;
    }

    pub fn writeAll(self: SerialWriter, bytes: []const u8) Error!void {
        _ = try self.write(bytes);
    }
    
    pub fn writeByte(self: SerialWriter, byte: u8) Error!void {
        _ = try self.write(&[_]u8{byte});
    }
    
    pub fn writeBytesNTimes(self: SerialWriter, bytes: []const u8, n: usize) Error!void {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            _ = try self.write(bytes);
        }
    }
};

pub fn kprint(comptime format: []const u8, args: anytype) void {
    const writer = SerialWriter{};
    std.fmt.format(writer, format, args) catch {};
}
