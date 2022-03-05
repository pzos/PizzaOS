;pzos_clear.asm: 32-bit protected mode clearing
[bits 32]

pz_clear_protected:
	pusha
	
	mov ebx, pz_vga_extent
	mov ecx, pz_vga_start
	mov edx, 0
	
	pz_clear_protected_loop:
		cmp edx, ebx
		jge pz_clear_protected_done
		
		push edx
		
		mov al, pz_char_space
		mov ah, pz_style_wb
		
		add edx, ecx
		mov word[edx], ax
		
		pop edx
		
		add edx, 2
		
		jmp pz_clear_protected_loop
		
pz_clear_protected_done:
	popa
	ret

pz_char_space: equ ` `