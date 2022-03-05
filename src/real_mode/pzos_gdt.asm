;pzos_gdt.asm: The GDT
pz_gdt32_start:

pz_gdt32_null:
	dd 0x00000000
	dd 0x00000000
	
pz_gdt32_code:
	dw 0xFFFF
	dw 0x00000000
	db 0x00
	db 0b10011010
	db 0b11001111
	db 0x00
	
pz_gdt32_data:
	dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0b10010010
    db 0b11001111
    db 0x00
	
pz_gdt32_end:

pz_gdt32_descriptor:
	dw pz_gdt32_end - pz_gdt32_start - 1
	dd pz_gdt32_start
	
pz_seg_code: equ pz_gdt32_code - pz_gdt32_start
pz_seg_data: equ pz_gdt32_data - pz_gdt32_start