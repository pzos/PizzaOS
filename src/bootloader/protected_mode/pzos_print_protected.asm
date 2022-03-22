;pzos_print_protected.asm: 32-bit protected mode printing
[bits 32]

pz_print_protected:
    pushad
    mov edx, pz_vga_start

    pz_print_protected_loop:
        cmp byte[esi], 0
        je  pz_print_protected_done

        mov al, byte[esi]
        mov ah, pz_textStyle_whiteOnBlack

        mov word[edx], ax

        add esi, 1
        add edx, 2

        jmp pz_print_protected_loop

pz_print_protected_done:
    popad
    ret