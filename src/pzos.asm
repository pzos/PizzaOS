;pzos.asm: The entry point of PizzaOS
[org 0x7C00]
[bits 16]

mov bp, 0x0500
mov sp, bp

mov byte[pz_boot_drive], dl

mov bx, pz_msg_bootSectorLoaded
call pz_bios_print

mov bx, 0x0002
mov cx, 0x0001
mov dx, 0x7E00

call pz_bios_load
call pz_bios_elevate

mov bx, pz_msg_extendedBootSectorLoaded
call pz_bios_print

pz_bootsector_hold:
jmp $

%include "real_mode/pzos_print.asm"
%include "real_mode/pzos_print_hex.asm"
%include "real_mode/pzos_load.asm"
%include "real_mode/pzos_gdt.asm"
%include "real_mode/pzos_elevate.asm"

pz_msg_bootSectorLoaded: db `\r\npz_boot: Loaded BIOS`, 0

pz_boot_drive: db 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55

pz_bootsector_extended:
pz_begin_protected:
call pz_clear_protected

mov esi, pz_msg_protectedModeAlert
call pz_print_protected

jmp $

%include "protected_mode/pzos_clear.asm"
%include "protected_mode/pzos_print.asm"

pz_vga_start: equ 0x000B8000
pz_vga_extent: equ 80 * 25 * 2
pz_style_wb: equ 0x0F

pz_msg_extendedBootSectorLoaded: db `\r\npz_boot: Loaded extended boot sector`, 0
pz_msg_protectedModeAlert: db `pz_boot: Elevated to 32-bit protected mode`, 0

times 512 - ($ - pz_bootsector_extended) db 0x00
bu: