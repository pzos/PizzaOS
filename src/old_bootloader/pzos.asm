;pzos.asm: The entry point of PizzaOS
[org 0x7C00]
[bits 16]

mov bp, 0x0500
mov sp, bp

mov byte[pz_pzos_boot_drive], dl

mov bx, pz_msg_bootSectorLoaded
call pz_print16

mov bx, 0x0002
mov cx, 0x0002
mov dx, 0x7E00

call pz_bios_load
call pz_bios_elevate32

mov bx, pz_msg_extendedBootSectorLoaded
call pz_print16

pz_pzos_bootsector_hold:
jmp $

%include "real_mode/pzos_print16.asm"
%include "real_mode/pzos_print_hex.asm"
%include "real_mode/pzos_load.asm"
%include "real_mode/pzos_gdt32.asm"
%include "real_mode/pzos_elevate32.asm"

pz_msg_bootSectorLoaded: db `\r\npzos_boot: Loaded BIOS`, 0

pz_pzos_boot_drive: db 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55

pz_pzos_bootsector_extended:
pz_pz_begin32:

[bits 32]

call pz_clear32
call pz_lm_detect_protected

call pz_pt_init_protected
call pz_elevate32

mov esi, pz_msg_protectedModeAlert
call pz_print32

jmp $

%include "protected_mode/pzos_clear32.asm"
%include "protected_mode/pzos_print32.asm"
%include "protected_mode/pzos_lm_detect.asm"
%include "protected_mode/pzos_pt_init.asm"
%include "protected_mode/pzos_gdt64.asm"
%include "protected_mode/pzos_elevate64.asm"

pz_pz_vga_start: equ 0x000B8000
pz_pz_vga_extent: equ 80 * 25 * 2
pz_pz_textStyle_whiteOnBlack: equ 0x0F

pz_msg_extendedBootSectorLoaded: db `\r\npzos_boot: Loaded extended boot sector`, 0
pz_msg_protectedModeAlert: db `pzos_boot: Elevated to 32-bit protected mode`, 0

times 512 - ($ - pz_pzos_bootsector_extended) db 0x00

pz_begin64:
[bits 64]

mov rdi, pz_style_whiteFore_blackBack
call pz_clear64

mov rdi, pz_style_whiteFore_blackBack

mov rsi, pz_msg_in64BitMode
call pz_print64

call pz_pz_kernel_start

jmp $

%include "long_mode/pzos_clear64.asm"
%include "long_mode/pzos_print64.asm"

pz_pz_kernel_start: equ 0x8200
pz_msg_in64BitMode: db `pzos_boot: Now in 64-bit long mode`, 0
pz_style_whiteFore_blackBack: equ 0xF

times 512 - ($ - pz_begin64) db 0x00