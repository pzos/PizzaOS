;pzos_print_real.asm: 16-bit real mode printing (in BIOS mode)
[bits 16]

pz_print_bios:
    push ax
    push bx

    mov ah, 0x0E

    pz_print_bios_loop:
        cmp byte[bx], 0
        je pz_print_bios_end

        mov al, byte[bx]
        int 0x10

        inc bx
        jmp pz_print_bios_loop

pz_print_bios_end:
    pop bx
    pop ax

    ret