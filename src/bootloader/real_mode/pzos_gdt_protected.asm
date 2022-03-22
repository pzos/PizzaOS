;pzos_gdt_protected: 32-bit GDT
[bits 16]

gdt_32_start:
gdt_32_null:
    dd 0x00000000
    dd 0x00000000

gdt_32_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0b10011010
    db 0b11001111
    db 0x00

gdt_32_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0b10010010
    db 0b11001111
    db 0x00

gdt_32_end:
gdt_32_descriptor:
    dw gdt_32_end - gdt_32_start - 1
    dd gdt_32_start

code_seg: equ gdt_32_code - gdt_32_start
data_seg: equ gdt_32_data - gdt_32_start