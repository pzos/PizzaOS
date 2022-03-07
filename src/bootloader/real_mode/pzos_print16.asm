;pzos_print16.asm: Function to print text in 16 bit mode
[bits 16]

pz_print16:
    push ax
    push bx
	
    mov ah, 0x0E
	
    pz_print16_loop:
		cmp byte[bx], 0
        je pz_print16_end
		
		mov al, byte[bx]
		int 0x10
		
		inc bx
		jmp pz_print16_loop

pz_print16_end:
	pop bx
	pop ax
	
	ret