;boot.asm: The entry point of PizzaOS
jmp $ ;Jump to the current instruction, aka infinite loop
times 510 - ($ - $$) db 0x00 ;We only have 512 bytes to keep the bootsector. Fill up the remaining space with empty data. Since the magic number is 2 bytes, 512 - 2 = 510
dw 0xAA55 ;Define word, magic number