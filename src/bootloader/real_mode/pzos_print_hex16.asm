;pzos_print_hex16.asm: 16-bit hex printing
[bits 16]

pz_bios_printHex:
    push ax
    push bx
    push cx

    mov ah, 0x0E

    mov al, '0'
    int 0x10
    mov al, 'x'
    int 0x10

    mov cx, 4

    pz_bios_printHex_loop:
        cmp cx, 0
        je pz_bios_printHex_end

        push bx
        shr bx, 12

        cmp bx, 10
        jge pz_bios_printHex_alpha
            mov al, '0'
            add al, bl
            jmp pz_bios_printHex_loop_end

        pz_bios_printHex_alpha:
            sub bl, 10
            
            mov al, 'A'
            add al, bl


        pz_bios_printHex_loop_end:
        int 0x10
        
        pop bx
        shl bx, 4

        dec cx

        jmp pz_bios_printHex_loop

pz_bios_printHex_end:
    pop cx
    pop bx
    pop ax

    ret