;pzos_print32.asm: 32-bit printing
[bits 32]

pz_print32:
    pushad
    mov edx, pz_vga_start

    pz_print32_loop:
        cmp byte[esi], 0
        je  pz_print32_done

        mov al, byte[esi]
        mov ah, pz_textStyle_whiteOnBlack

        mov word[edx], ax

        add esi, 1
        add edx, 2

        jmp pz_print32_loop

pz_print32_done:
    popad
    ret