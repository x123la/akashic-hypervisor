const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86, // Switch to 32-bit x86
        .os_tag = .freestanding,
        .abi = .none,
    });

    const optimize = b.standardOptimizeOption(.{});

    // Main Kernel Executable
    const kernel = b.addExecutable(.{
        .name = "akashic_kernel",
        .root_source_file = b.path("src/kernel.zig"),
        .target = target,
        .optimize = optimize,
        .pic = false,
        .strip = false,
    });
    
    // Force No-PIE (Important for Multiboot)
    kernel.pie = false;
    
    // Assemble the bootloader & VM Runner
    kernel.addAssemblyFile(b.path("src/boot.S"));
    kernel.addAssemblyFile(b.path("src/vm_runner.S"));
    
    // Link the pre-compiled Ada object
    kernel.addObjectFile(b.path("src/fortress/fortress.o"));

    kernel.setLinkerScript(b.path("linker.ld"));
    
    b.installArtifact(kernel);
}
