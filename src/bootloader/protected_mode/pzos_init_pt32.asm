;pz_init_pt32.asm: Initialize the page table
[bits 32]

pz_pt_init32:
    pushad

    mov edi, 0x1000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd

    mov edi, cr3

    mov dword[edi], 0x2003
    add edi, 0x1000
    mov dword[edi], 0x3003
    add edi, 0x1000
    mov dword[edi], 0x4003

    add edi, 0x1000
    mov ebx, 0x00000003
    mov ecx, 512

    pz_page_entry_add32:
        mov dword[edi], ebx
        add ebx, 0x1000
        add edi, 8
        loop pz_page_entry_add32

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    popad
    ret