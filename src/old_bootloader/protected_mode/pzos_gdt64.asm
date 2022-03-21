;pzos_gdt_long.asm: _long-bit GDT
align 4

pz_gdt_long_start:

pz_gdt_long_null:
	dd 0x00000000
    dd 0x00000000
	
pz_gdt_long_code:
	dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0b10011010
    db 0b10101111
    db 0x00

pz_gdt_long_data:
	dw 0x0000
    dw 0x0000
    db 0x00
    db 0b10010010
    db 0b10100000
    db 0x00
	
pz_gdt_long_end:

pz_gdt_long_descriptor:
	dw pz_gdt_long_end - pz_gdt_long_start - 1
	dd pz_gdt_long_start
	
pz_seg_code_long: equ pz_gdt_long_code - pz_gdt_long_start
pz_seg_data_long: equ pz_gdt_long_data - pz_gdt_long_start