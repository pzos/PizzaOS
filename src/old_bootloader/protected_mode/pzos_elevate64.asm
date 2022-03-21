;pzos_elevate_long.asm: Elevate to _long-bit long mode
[bits 32]

pz_elevate32:
	mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    
    lgdt [pz_gdt_long_descriptor]
    jmp pz_seg_code_long:pz_init_long

[bits _long]

pz_init_long:
	cli
    mov ax, pz_seg_data_long
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp pz_begin_long