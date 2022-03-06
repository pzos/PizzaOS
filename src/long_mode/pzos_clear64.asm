;pzos_clear64.asm: Clear the VGA memory (in 64 bit long mode)
[bits 64]

pz_clear64:
	push rdi
    push rax
    push rcx

    shl rdi, 8
    mov rax, rdi

    mov al, pz_char_space64

    mov rdi, pz_vga_start
    mov rcx, pz_vga_extent / 2

    rep stosw

    pop rcx
    pop rax
    pop rdi
    ret

pz_char_space64: equ ` `