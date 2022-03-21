;pzos.asm: Entry point of PizzaOS
[org 0x7C00]
[bits 16]

mov bp, 0x0500
mov sp, bp

mov byte[pz_boot_drive], dl

mov bx, pz_msg_loaded_bios
call pz_bios_print

mov bx, 0x0002
mov cx, 0x0003
mov dx, 0x7E00

call pz_bios_load
call pz_bios_elevate

pz_bootsector_hold:
jmp $

%include "real_mode/pzos_print16.asm"
%include "real_mode/pzos_print_hex16.asm"
%include "real_mode/pzos_load_bios.asm"
%include "real_mode/pzos_gdt32.asm"
%include "real_mode/pzos_elevate16_32.asm"

pz_msg_loaded_bios: db `\r\npz_boot: Loaded BIOS`, 0
pz_boot_drive: db 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55

pz_bootsector_extended:
pz_begin32:

[bits 32]
call pz_clear32
call pz_detect_lm32

mov esi, pz_msg_elevatedTo32bit
call pz_print32

call pz_pt_init32

call pz_elevate32

jmp $

%include "protected_mode/pzos_clear32.asm"
%include "protected_mode/pzos_print32.asm"
%include "protected_mode/pzos_detect_lm32.asm"
%include "protected_mode/pzos_init_pt32.asm"
%include "protected_mode/pzos_gdt64.asm"
%include "protected_mode/pzos_elevate32_64.asm"

pz_vga_start: equ 0x000B8000
pz_vga_extent: equ 80 * 25 * 2
pz_textStyle_whiteOnBlack: equ 0x0F
pz_msg_elevatedTo32bit: db `\r\npzos_boot: Elevated to 32-bit protected mode`, 0

times 510 - ($ - pz_bootsector_extended) db 0x00
pz_begin64:

[bits 64]

mov rdi, pz_textStyle_whiteOnBlue
call pz_clear64

mov rdi, pz_textStyle_whiteOnBlue

mov rsi, pz_elevatedTo64bit
call pz_print64

call pz_kernel_start

jmp $

%include "long_mode/pzos_clear64.asm"
%include "long_mode/pzos_print64.asm"

pz_kernel_start: equ 0x8200
pz_elevatedTo64bit: db `\r\npzos_boot: Elevated to 64-bit long mode`, 0
pz_textStyle_whiteOnBlue: equ 0x1F

times 510 - ($ - pz_begin64) db 0x00