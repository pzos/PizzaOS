;pzos_pz_long_clear.asm: 64-bit long mode clearing
[bits 64]

pz_long_clear:
    push rdi
    push rax
    push rcx

    shl rdi, 8
    mov rax, rdi

    mov al, space_char

    mov rdi, pz_vga_start
    mov rcx, pz_vga_extent / 2

    rep stosw

    pop rcx
    pop rax
    pop rdi
    ret


space_char: equ ` `