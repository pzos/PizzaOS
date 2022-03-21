;pzos_print64.asm: Long mode printing
[bits 64]

pz_print64:
    push rax
    push rdx
    push rdi
    push rsi

    mov rdx, pz_vga_start
    shl rdi, 8

    pz_print64_loop:
        cmp byte[rsi], 0
        je  pz_print64_done

        cmp rdx, pz_vga_start + pz_vga_extent
        je pz_print64_done

        mov rax, rdi
        mov al, byte[rsi]

        mov word[rdx], ax

        add rsi, 1
        add rdx, 2

        jmp pz_print64_loop

pz_print64_done:
    pop rsi
    pop rdi
    pop rdx
    pop rax

    ret