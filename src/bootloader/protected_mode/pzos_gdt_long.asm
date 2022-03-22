;pzos_gdt_long.asm: 64-bit GDT
align 4

gdt_64_start:
gdt_64_null:
    dd 0x00000000
    dd 0x00000000

gdt_64_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0b10011010
    db 0b10101111
    db 0x00

gdt_64_data:
    dw 0x0000
    dw 0x0000
    db 0x00
    db 0b10010010
    db 0b10100000
    db 0x00

gdt_64_end:
gdt_64_descriptor:
    dw gdt_64_end - gdt_64_start - 1
    dd gdt_64_start

code_seg_64: equ gdt_64_code - gdt_64_start
data_seg_64: equ gdt_64_data - gdt_64_start