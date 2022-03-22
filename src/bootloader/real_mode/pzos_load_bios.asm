;pzos_pz_bios_load.asm: Load the BIOS
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

    jc bios_disk_error

    pop bx
    cmp al, bl
    jne bios_disk_error

    mov bx, success_msg
    call pz_print_bios

    pop dx
    pop cx
    pop bx
    pop ax

    ret


bios_disk_error:
    mov bx, error_msg
    call pz_print_bios

    shr ax, 8
    mov bx, ax
    call print_hex_bios

    jmp $

error_msg: db `\r\nERROR Loading Sectors. Code: `, 0
success_msg: db `\r\nAdditional Sectors Loaded Successfully!\r\n`, 0