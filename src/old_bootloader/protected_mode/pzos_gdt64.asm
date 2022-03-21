;pzos_gdt64.asm: 64-bit GDT
align 4

pz_gdt64_start:

pz_gdt64_null:
	dd 0x00000000
    dd 0x00000000
	
pz_gdt64_code:
	dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0b10011010
    db 0b10101111
    db 0x00

pz_gdt64_data:
	dw 0x0000
    dw 0x0000
    db 0x00
    db 0b10010010
    db 0b10100000
    db 0x00
	
pz_gdt64_end:

pz_gdt64_descriptor:
	dw pz_gdt64_end - pz_gdt64_start - 1
	dd pz_gdt64_start
	
pz_seg_code64: equ pz_gdt64_code - pz_gdt64_start
pz_seg_data64: equ pz_gdt64_data - pz_gdt64_start