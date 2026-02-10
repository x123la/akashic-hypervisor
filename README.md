# Akashic Hypervisor

**A Formally Verified, Type-1 Hypervisor for the Post-Linux Era.**

Akashic Hypervisor is a bare-metal microvisor that enforces strict mathematical isolation between guests using a "Vertical Kernel" architecture. It combines the raw performance and hardware control of **Zig** with the high-assurance formal verification of **Ada/SPARK**.

## 🏗 Architecture

The system is composed of five distinct layers:

1.  **Layer I: The Crystal Core (Zig)** - Hardware abstraction, VMX lifecycle, and PMM.
2.  **Layer II: The Fortress (Ada)** - Runtime Formal Verification engine that mathematically proves memory isolation properties (W^X, Kernel Integrity) before allowing any VMLAUNCH.
3.  **Layer III: The Trampoline (ASM)** - A custom assembly loader that guarantees Multiboot compliance by brute-forcing the ELF layout.
4.  **Layer IV: The Void (Guest)** - A minimalist 32-bit guest payload demonstrating I/O interception.
5.  **Layer V: The Law (Logic)** - (Future) Lean 4 theorems defining fairness.

## 🚀 Features

*   **Verified Memory Subsystem:** Physical Page Tables (EPT) are audited by Ada code at runtime.
*   **Zero-Allocation Core:** The critical path runs without a heap allocator.
*   **Hardware Virtualization:** Uses Intel VT-x (VMX) hardware extensions.
*   **Multiboot Compliant:** Boots on standard emulators (QEMU) and bare metal.
*   **Telemetry:** Serial-based debugging and introspection.

## 🛠 Build & Run

**Requirements:**
*   Zig 0.13.0+
*   GNAT (Ada Compiler)
*   QEMU (for simulation)
*   `nasm` or `as` (GNU Assembler)

**Build:**
```bash
./build_kernel.sh
```

**Run (QEMU):**
```bash
./run_qemu.sh
```

## 🔮 Roadmap

*   [x] VMX Lifecycle (Launch/Exit)
*   [x] Runtime Verification (Ada Fortress)
*   [x] Guest Loader (Multiboot Modules)
*   [ ] Linux Guest Support (bzImage loader)
*   [ ] Hardware Passthrough (PCIe)
*   [ ] Introspection Engine (BQN)

## 📜 License

MIT License.
