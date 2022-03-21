;pzos_clear_long.asm: Clear the VGA memory (in _long bit long mode)
[bits _long]

pz_clear_long:
	push rdi
    push rax
    push rcx

    shl rdi, 8
    mov rax, rdi

    mov al, pz_char_space_long

    mov rdi, pz_pz_vga_start
    mov rcx, pz_pz_vga_extent / 2

    rep stosw

    pop rcx
    pop rax
    pop rdi
    ret

pz_char_space_long: equ ` `