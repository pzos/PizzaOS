;pzos_print.asm: 32-bit protected mode printing
[bits 32]

pz_print_protected:
	pusha
	mov edx, pz_vga_start
	
	pz_print_protected_loop:
		cmp byte[esi], 0
		je pz_print_protected_done
		
		mov al, byte[esi]
		mov ah, pz_style_wb
		
		mov word[edx], ax
		
		add esi, 1
		add edx, 2
		
		jmp pz_print_protected_loop
		
pz_print_protected_done:
	popa
	ret