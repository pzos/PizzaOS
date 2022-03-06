;pzos.asm: The entry point of PizzaOS
[org 0x7C00]
[bits 16]

mov bp, 0x0500
mov sp, bp

mov byte[pz_boot_drive], dl

mov bx, pz_msg_bootSectorLoaded
call pz_print16

mov bx, 0x0002
mov cx, 0x0001
mov dx, 0x7E00

call pz_bios_load
call pz_bios_elevate32

mov bx, pz_msg_extendedBootSectorLoaded
call pz_print16

pz_bootsector_hold:
jmp $

%include "real_mode/pzos_print16.asm"
%include "real_mode/pzos_print_hex.asm"
%include "real_mode/pzos_load.asm"
%include "real_mode/pzos_gdt32.asm"
%include "real_mode/pzos_elevate32.asm"

pz_msg_bootSectorLoaded: db `\r\npz_boot: Loaded BIOS`, 0

pz_boot_drive: db 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55

pz_bootsector_extended:
pz_begin_protected:

[bits 32]

call pz_clear32
call pz_lm_detect_protected

mov esi, pz_msg_protectedModeAlert
call pz_print32

jmp $

%include "protected_mode/pzos_clear32.asm"
%include "protected_mode/pzos_print32.asm"
%include "protected_mode/pzos_lm_detect.asm"
%include "protected_mode/pzos_pt_init.asm"
%include "protected_mode/pzos_gdt64.asm"
%include "protected_mode/pzos_elevate64.asm"

pz_vga_start: equ 0x000B8000
pz_vga_extent: equ 80 * 25 * 2
pz_kernel_start: equ 0x00100000
pz_style_wb: equ 0x0F

pz_msg_extendedBootSectorLoaded: db `\r\npz_boot: Loaded extended boot sector`, 0
pz_msg_protectedModeAlert: db `pz_boot: Elevated to 32-bit protected mode`, 0

times 512 - ($ - pz_bootsector_extended) db 0x00

[bits 64]

pz_begin64:

mov rdi, pz_style_blue
call pz_clear64

mov rdi, pz_style_blue
mov rsi, pz_msg_in64BitMode
call pz_print64

jmp $

%include "long_mode/pzos_clear64.asm"
%include "long_mode/pzos_print64.asm"

pz_msg_in64BitMode: db `\r\npz_boot: Now in 64-bit long mode`, 0
pz_style_blue: equ 0x1F

times 512 - ($ - pz_begin64) db 0x00