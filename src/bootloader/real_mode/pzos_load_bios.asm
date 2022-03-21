;pzos_load_bios.asm: Load the BIOS
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

    jc pz_bios_error_disk

    pop bx
    cmp al, bl
    jne pz_bios_error_disk

    mov bx, pz_msg_loadedAdditionalSectors
    call pz_bios_print

    pop dx
    pop cx
    pop bx
    pop ax

    ret


pz_bios_error_disk:
    mov bx, pz_msg_failedToLoadAdditionalSectors
    call pz_bios_print

    shr ax, 8
    mov bx, ax
    call pz_bios_printHex

    jmp $

pz_msg_failedToLoadAdditionalSectors: db `\r\npzos_load_bios: Failed to load additional sectors. Is your hard drive physically corrupted?`, 0
pz_msg_loadedAdditionalSectors: db `\r\npzos_load_bios: Successfully loaded additional sectors`, 0