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

mov bx, pz_msg_extendedBootSectorLoaded
call pz_bios_print

pz_bootsector_hold:
jmp $

%include "pzos_print.asm"
%include "pzos_print_hex.asm"
%include "pzos_load.asm"

pz_msg_bootSectorLoaded: db `\r\npz_boot: Loaded BIOS`, 0

pz_boot_drive: db 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55

pz_bootsector_extended:
	pz_msg_extendedBootSectorLoaded: db `\r\npz_boot: Loaded extended boot sector`, 0x00

times 512 - ($ - pz_bootsector_extended) db 0x00
bu: