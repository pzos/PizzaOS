;pzos_elevatelong.asm: Elevate the CPU from 32-bit protected mode to 64-bit long mode
[bits 32]

elevate_protected:
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    
    lgdt [gdt_64_descriptor]
    jmp code_seg_64:init_lm

[bits 64]
    init_lm:
    cli
    mov ax, data_seg_64
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp pz_begin_longmode