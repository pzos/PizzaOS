;pzos_print_hex.asm: Hex printing. Since this is only necessary in the BIOS, there is no need for a 32 or 64-bit version.
[bits 16]

print_hex_bios:
    push ax
    push bx
    push cx

    mov ah, 0x0E

    mov al, '0'
    int 0x10
    mov al, 'x'
    int 0x10

    mov cx, 4

    print_hex_bios_loop:
        cmp cx, 0
        je print_hex_bios_end

        push bx

        shr bx, 12

        cmp bx, 10
        jge print_hex_bios_alpha
            mov al, '0'
            add al, bl

            jmp print_hex_bios_loop_end

        print_hex_bios_alpha:
            sub bl, 10

            mov al, 'A'
            add al, bl

        print_hex_bios_loop_end:
        int 0x10

        pop bx
        shl bx, 4

        dec cx

        jmp print_hex_bios_loop

print_hex_bios_end:
    pop cx
    pop bx
    pop ax

    ret