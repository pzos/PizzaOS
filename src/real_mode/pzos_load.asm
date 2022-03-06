;pzos_load.asm: Load extended boot sector
[bits 16]

pz_bios_load:
	push ax
	push bx
	push cx
	push dx
	
	push cx
	
	mov ah, 0x02
	mov al, cl
	mov cl, bl
	mov bx, dx
	
	mov ch, 0x00
	mov dh, 0x00
	
	mov dl, byte[pz_boot_drive]
	
	int 0x13
	
	jc pz_bios_disk_error
	
	pop bx
	cmp al, bl
	jne pz_bios_disk_error
	
	mov bx, pz_msg_additionalSectorsLoadedSuccessfully
	call pz_print16
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
	
pz_bios_disk_error:
	mov bx, pz_msg_failedToLoadExtendedBootSector
	call pz_print16
	
	shr ax, 8
	mov bx, ax
	call pz_print16_hex
	
	jmp $
	
pz_msg_failedToLoadExtendedBootSector: db `\r\npz_load: Failed to load extended boot sector. Error code: `, 0
pz_msg_additionalSectorsLoadedSuccessfully: db `\r\npz_load: Additional sector loaded successfully`, 0