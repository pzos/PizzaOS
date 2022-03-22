;pzos_pz_protected_clear.asm: 32-bit protected mode clearing
[bits 32]

pz_protected_clear:
    pushad

    mov ebx, pz_vga_extent
    mov ecx, pz_vga_start
    mov edx, 0

    pz_protected_clear_loop:
        cmp edx, ebx
        jge pz_protected_clear_done

        push edx

        mov al, space_char
        mov ah, pz_textStyle_whiteOnBlack

        add edx, ecx
        mov word[edx], ax

        pop edx

        add edx, 2

        jmp pz_protected_clear_loop

pz_protected_clear_done:
    popad
    ret

space_char: equ ` `