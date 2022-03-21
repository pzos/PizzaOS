;pzos_print16.asm: 16-bit printing
[bits 16]

pz_bios_print:
    push ax
    push bx

    mov ah, 0x0E


    pz_bios_print_loop:
        cmp byte[bx], 0
        je pz_bios_print_end

        mov al, byte[bx]
        int 0x10

        inc bx
        jmp pz_bios_print_loop

pz_bios_print_end:
    pop bx
    pop ax

    ret