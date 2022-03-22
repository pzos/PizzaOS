;pzos_pz_long_print.asm: 64-bit long mode printing
[bits 64]

pz_long_print:
    push rax
    push rdx
    push rdi
    push rsi

    mov rdx, pz_vga_start
    shl rdi, 8

    pz_long_print_loop:
        cmp byte[rsi], 0
        je  pz_long_print_done

        cmp rdx, pz_vga_start + pz_vga_extent
        je pz_long_print_done

        mov rax, rdi
        mov al, byte[rsi]

        mov word[rdx], ax

        add rsi, 1
        add rdx, 2

        jmp pz_long_print_loop

pz_long_print_done:
    pop rsi
    pop rdi
    pop rdx
    pop rax

    ret