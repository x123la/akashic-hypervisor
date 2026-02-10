const std = @import("std");

// VMCS Encodings (Partial List for 32-bit Guest)
pub const VPID = 0x0000;
pub const GUEST_ES_SELECTOR = 0x0800;
pub const GUEST_CS_SELECTOR = 0x0802;
pub const GUEST_SS_SELECTOR = 0x0804;
pub const GUEST_DS_SELECTOR = 0x0806;
pub const GUEST_FS_SELECTOR = 0x0808;
pub const GUEST_GS_SELECTOR = 0x080a;
pub const GUEST_LDTR_SELECTOR = 0x080c;
pub const GUEST_TR_SELECTOR = 0x080e;
pub const HOST_ES_SELECTOR = 0x0c00;
pub const HOST_CS_SELECTOR = 0x0c02;
pub const HOST_SS_SELECTOR = 0x0c04;
pub const HOST_DS_SELECTOR = 0x0c06;
pub const HOST_FS_SELECTOR = 0x0c08;
pub const HOST_GS_SELECTOR = 0x0c0a;
pub const HOST_TR_SELECTOR = 0x0c0c;
pub const CONTROL_IO_BITMAP_A_ADDR = 0x2000;
pub const CONTROL_IO_BITMAP_B_ADDR = 0x2002;
pub const CONTROL_MSR_BITMAP_ADDR = 0x2004;
pub const CONTROL_EXIT_MSR_STORE_ADDR = 0x2006;
pub const CONTROL_EXIT_MSR_LOAD_ADDR = 0x2008;
pub const CONTROL_ENTRY_MSR_LOAD_ADDR = 0x200a;
pub const CONTROL_EXECUTIVE_VMCS_PTR = 0x200c;
pub const CONTROL_TSC_OFFSET = 0x2010;
pub const CONTROL_VIRTUAL_APIC_ADDR = 0x2012;
pub const CONTROL_APIC_ACCESS_ADDR = 0x2014;
pub const CONTROL_EPT_PTR = 0x201a;
pub const GUEST_PHYSICAL_ADDRESS = 0x2400;
pub const CONTROL_VMCS_LINK_PTR = 0x2800;
pub const GUEST_DEBUGCTL = 0x2802;
pub const GUEST_PAT = 0x2804;
pub const GUEST_EFER = 0x2806;
pub const GUEST_PERF_GLOBAL_CTRL = 0x2808;
pub const GUEST_PDPTR0 = 0x280a;
pub const GUEST_PDPTR1 = 0x280c;
pub const GUEST_PDPTR2 = 0x280e;
pub const GUEST_PDPTR3 = 0x2810;
pub const HOST_PAT = 0x2c00;
pub const HOST_EFER = 0x2c02;
pub const HOST_PERF_GLOBAL_CTRL = 0x2c04;
pub const CONTROL_PIN_BASED_EXEC_CONTROLS = 0x4000;
pub const CONTROL_CPU_BASED_EXEC_CONTROLS = 0x4002;
pub const CONTROL_EXCEPTION_BITMAP = 0x4004;
pub const CONTROL_PAGE_FAULT_ERROR_CODE_MASK = 0x4006;
pub const CONTROL_PAGE_FAULT_ERROR_CODE_MATCH = 0x4008;
pub const CONTROL_CR3_TARGET_COUNT = 0x400a;
pub const CONTROL_VM_EXIT_CONTROLS = 0x400c;
pub const CONTROL_VM_EXIT_MSR_STORE_COUNT = 0x400e;
pub const CONTROL_VM_EXIT_MSR_LOAD_COUNT = 0x4010;
pub const CONTROL_VM_ENTRY_CONTROLS = 0x4012;
pub const CONTROL_VM_ENTRY_MSR_LOAD_COUNT = 0x4014;
pub const CONTROL_VM_ENTRY_INTR_INFO_FIELD = 0x4016;
pub const CONTROL_VM_ENTRY_EXCEPTION_ERROR_CODE = 0x4018;
pub const CONTROL_VM_ENTRY_INSTRUCTION_LEN = 0x401a;
pub const CONTROL_TPR_THRESHOLD = 0x401c;
pub const CONTROL_SECONDARY_EXEC_CONTROLS = 0x401e;
pub const CONTROL_PLE_GAP = 0x4020;
pub const CONTROL_PLE_WINDOW = 0x4022;
pub const VM_INSTRUCTION_ERROR = 0x4400;
pub const VM_EXIT_REASON = 0x4402;
pub const VM_EXIT_INTR_INFO = 0x4404;
pub const VM_EXIT_INTR_ERROR_CODE = 0x4406;
pub const IDT_VECTORING_INFO_FIELD = 0x4408;
pub const IDT_VECTORING_ERROR_CODE = 0x440a;
pub const VM_EXIT_INSTRUCTION_LEN = 0x440c;
pub const VMX_INSTRUCTION_INFO = 0x440e;
pub const GUEST_ES_LIMIT = 0x4800;
pub const GUEST_CS_LIMIT = 0x4802;
pub const GUEST_SS_LIMIT = 0x4804;
pub const GUEST_DS_LIMIT = 0x4806;
pub const GUEST_FS_LIMIT = 0x4808;
pub const GUEST_GS_LIMIT = 0x480a;
pub const GUEST_LDTR_LIMIT = 0x480c;
pub const GUEST_TR_LIMIT = 0x480e;
pub const GUEST_GDTR_LIMIT = 0x4810;
pub const GUEST_IDTR_LIMIT = 0x4812;
pub const GUEST_ES_AR_BYTES = 0x4814;
pub const GUEST_CS_AR_BYTES = 0x4816;
pub const GUEST_SS_AR_BYTES = 0x4818;
pub const GUEST_DS_AR_BYTES = 0x481a;
pub const GUEST_FS_AR_BYTES = 0x481c;
pub const GUEST_GS_AR_BYTES = 0x481e;
pub const GUEST_LDTR_AR_BYTES = 0x4820;
pub const GUEST_TR_AR_BYTES = 0x4822;
pub const GUEST_INTERRUPTIBILITY_INFO = 0x4824;
pub const GUEST_ACTIVITY_STATE = 0x4826;
pub const GUEST_SM_BASE = 0x4828;
pub const GUEST_SYSENTER_CS = 0x482a;
pub const HOST_IA32_SYSENTER_CS = 0x4c00;
pub const CONTROL_CR0_GUEST_HOST_MASK = 0x6000;
pub const CONTROL_CR4_GUEST_HOST_MASK = 0x6002;
pub const CONTROL_CR0_READ_SHADOW = 0x6004;
pub const CONTROL_CR4_READ_SHADOW = 0x6006;
pub const CONTROL_CR3_TARGET_VALUE0 = 0x6008;
pub const CONTROL_CR3_TARGET_VALUE1 = 0x600a;
pub const CONTROL_CR3_TARGET_VALUE2 = 0x600c;
pub const CONTROL_CR3_TARGET_VALUE3 = 0x600e;
pub const EXIT_QUALIFICATION = 0x6400;
pub const IO_RCX = 0x6402;
pub const IO_RSI = 0x6404;
pub const IO_RDI = 0x6406;
pub const IO_RIP = 0x6408;
pub const GUEST_LINEAR_ADDRESS = 0x640a;
pub const GUEST_CR0 = 0x6800;
pub const GUEST_CR3 = 0x6802;
pub const GUEST_CR4 = 0x6804;
pub const GUEST_ES_BASE = 0x6806;
pub const GUEST_CS_BASE = 0x6808;
pub const GUEST_SS_BASE = 0x680a;
pub const GUEST_DS_BASE = 0x680c;
pub const GUEST_FS_BASE = 0x680e;
pub const GUEST_GS_BASE = 0x6810;
pub const GUEST_LDTR_BASE = 0x6812;
pub const GUEST_TR_BASE = 0x6814;
pub const GUEST_GDTR_BASE = 0x6816;
pub const GUEST_IDTR_BASE = 0x6818;
pub const GUEST_DR7 = 0x681a;
pub const GUEST_RSP = 0x681c;
pub const GUEST_RIP = 0x681e;
pub const GUEST_RFLAGS = 0x6820;
pub const GUEST_PENDING_DBG_EXCEPTIONS = 0x6822;
pub const GUEST_SYSENTER_ESP = 0x6824;
pub const GUEST_SYSENTER_EIP = 0x6826;
pub const HOST_CR0 = 0x6c00;
pub const HOST_CR3 = 0x6c02;
pub const HOST_CR4 = 0x6c04;
pub const HOST_FS_BASE = 0x6c06;
pub const HOST_GS_BASE = 0x6c08;
pub const HOST_TR_BASE = 0x6c0a;
pub const HOST_GDTR_BASE = 0x6c0c;
pub const HOST_IDTR_BASE = 0x6c0e;
pub const HOST_IA32_SYSENTER_ESP = 0x6c10;
pub const HOST_IA32_SYSENTER_EIP = 0x6c12;
pub const HOST_RSP = 0x6c14;
pub const HOST_RIP = 0x6c16;

pub fn vmwrite(field: usize, value: usize) void {
    asm volatile (
        "vmwrite %[val], %[fld]"
        : 
        : [val] "r" (value), [fld] "r" (field)
        : "flags"
    );
}

pub fn vmread(field: usize) usize {
    var value: usize = 0;
    asm volatile (
        "vmread %[fld], %[val]"
        : [val] "=r" (value)
        : [fld] "r" (field)
        : "flags"
    );
    return value;
}