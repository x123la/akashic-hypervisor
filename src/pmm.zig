const std = @import("std");

pub const PAGE_SIZE: usize = 4096;

// A simple bitmap allocator
// For a 512MB demo system, we need 512MB / 4KB = 131,072 bits = 16KB bitmap
const BITMAP_SIZE: usize = 131072;
var bitmap: [BITMAP_SIZE / 8]u8 = undefined;
var highest_page_index: usize = 0;

pub fn init(mem_upper_kb: usize) void {
    // Upper memory starts at 1MB. mem_upper_kb is size in KB.
    // Total pages = (1MB + mem_upper) / 4KB
    const total_ram = (1024 * 1024) + (mem_upper_kb * 1024);
    highest_page_index = total_ram / PAGE_SIZE;
    
    // Mark all as free (0) initially, then mark used regions
    // For safety in this proto, we mark everything as free then reserve kernel space
    @memset(&bitmap, 0);
    
    // Reserve first 4MB for Kernel + Bootloader stuff to be safe
    reserve_region(0, 1024); // 0 to 1024th page (0-4MB)
}

fn reserve_region(start_page: usize, count: usize) void {
    var i: usize = 0;
    while (i < count) : (i += 1) {
        const page_idx = start_page + i;
        if (page_idx < highest_page_index) {
            const byte_idx = page_idx / 8;
            const bit_idx = @as(u3, @intCast(page_idx % 8));
            bitmap[byte_idx] |= (@as(u8, 1) << bit_idx);
        }
    }
}

pub fn alloc_page() ?usize {
    var i: usize = 0;
    while (i < highest_page_index) : (i += 1) {
        const byte_idx = i / 8;
        const bit_idx = @as(u3, @intCast(i % 8));
        
        if (bitmap[byte_idx] & (@as(u8, 1) << bit_idx) == 0) {
            // Found free page
            bitmap[byte_idx] |= (@as(u8, 1) << bit_idx);
            return i * PAGE_SIZE;
        }
    }
    return null;
}
