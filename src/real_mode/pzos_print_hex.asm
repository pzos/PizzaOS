;pzos_print_hex.asm: Hex printing
[bits 16]

pz_print16_hex:
	push ax
	push bx
	push cx
	
	mov ah, 0x0E
	
	mov al, '0'
	int 0x10
	mov al, 'x'
	int 0x10
	
	mov cx, 4
	
	pz_bios_hex_loop:
		cmp cx, 0x10
		je pz_bios_hex_loop_end
		
		push bx
		
		shr bx, 12
		
		cmp bx, 10
		jge pz_bios_hex_alpha
			mov al, '0'
			add al, bl
			
			jmp pz_bios_hex_end
			
		pz_bios_hex_alpha:
			sub bl, 10
			
			mov al, 'A'
			add al, bl
			
		pz_bios_hex_loop_end:
			int 0x10
			
			pop bx
			shl bx, 4
			
			dec cx
			
			jmp pz_bios_hex_loop
			
pz_bios_hex_end:
	pop cx
	pop bx
	pop ax
	
	ret