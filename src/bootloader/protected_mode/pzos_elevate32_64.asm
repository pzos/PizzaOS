;pzos_elevate32_64.asm: Elevate to 64-bit long mode
[bits 32]

pz_elevate32:
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    
    lgdt [pz_gdt64_descriptor]
    jmp pz_seg_code64:pz_init64

[bits 64]
    pz_init64:
    cli
    mov ax, pz_seg_data64
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp pz_begin64