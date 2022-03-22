;pzos.asm: The entry point of PizzaOS
[org 0x7C00]
[bits 16]

mov bp, 0x0500
mov sp, bp

mov byte[pz_boot_drive], dl

mov bx, pz_msg_loaded_bios
call pz_print_bios

mov bx, 0x0002
mov cx, 0x0003
mov dx, 0x7E00

call pz_bios_load
call pz_elevate_protected

pz_bootsector_hold:
jmp $

%include "real_mode/pzos_print_real.asm"
%include "real_mode/pzos_print_hex.asm"
%include "real_mode/pzos_load_bios.asm"
%include "real_mode/pzos_gdt_protected.asm"
%include "real_mode/pzos_elevate_protected.asm"

pz_msg_loaded_bios: db `\r\npzos_boot: Loaded BIOS`, 0
pz_boot_drive: db 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55

pz_bootsector_extended:
pz_start_protected:

[bits 32]
call pz_protected_clear
call pz_detect_longmode

mov esi, pz_msg_in_protected_mode
call pz_print_protected

call init_pt_protected
call elevate_protected

jmp $

%include "protected_mode/pzos_clear_protected.asm"
%include "protected_mode/pzos_print_protected.asm"
%include "protected_mode/pzos_detect_longmode.asm"
%include "protected_mode/pzos_pt_init.asm"
%include "protected_mode/pzos_gdt_long.asm"
%include "protected_mode/pzos_elevatelong.asm"

pz_vga_start: equ 0x000B8000
pz_vga_extent: equ 80 * 25 * 2
pz_textStyle_whiteOnBlack: equ 0x0F
pz_msg_in_protected_mode: db `\r\npzos_boot: Now in 32-bit protected mode`, 0

times 512 - ($ - pz_bootsector_extended) db 0x00

pz_begin_longmode:
[bits 64]

mov rdi, pz_textStyle_whiteOnBlue
call pz_long_clear

mov rdi, pz_textStyle_whiteOnBlue
mov rsi, pz_msg_in_longmode
call pz_long_print

call pz_kernel_start

jmp $

%include "long_mode/pzos_clear_long.asm"
%include "long_mode/pzos_print_long.asm"

pz_kernel_start: equ 0x8200
pz_msg_in_longmode: db `\r\npzos_boot: Now in 64-bit long mode! Starting kernel...`, 0
pz_textStyle_whiteOnBlue: equ 0x1F

times 512 - ($ - pz_begin_longmode) db 0x00