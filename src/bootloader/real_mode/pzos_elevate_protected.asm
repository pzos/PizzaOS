;pzos_elevate_protected.asm: Elevate to 32-bit protected mode
[bits 16]

pz_elevate_protected:
    cli

    lgdt [gdt_32_descriptor]

    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    jmp code_seg:init_pm

    [bits 32]
    init_pm:
    mov ax, data_seg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    jmp pz_start_protected