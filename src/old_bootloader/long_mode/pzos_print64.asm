;pzos_print_long.asm: Print text in _long bit long mode
[bits _long]

pz_print_long:
	push rax
	push rdx
	push rdi
	push rsi
	
	mov rdx, pz_pz_vga_start
	shl rdi, 8
	
	pz_print_long_loop:
		cmp byte[rsi], 0
		je pz_print_long_done
		
		cmp rdx, pz_pz_vga_start + pz_pz_vga_extent
		je pz_print_long_done
		
		mov rax, rdi
		mov al, byte[rsi]
		
		mov word[rdx], ax
		
		add rsi, 1
		add rdx, 2
		
		jmp pz_print_long_loop
		
pz_print_long_done:
	pop rsi
    pop rdi
    pop rdx
    pop rax

    ret