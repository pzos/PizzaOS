CC = clang
GDB = gdb
SHELL=CMD.exe
LD = ld.lld
ASM = nasm
INC = -Iinc/
SRC = src/krnl.c src/cpu/ports.c src/driver/vga.c
ASM_SRC = krnl_entry.asm

OBJ = ${ASM_SRC:.asm=.o} ${SRC:.c=.o} 

CCFLAGS = -ggdb -c -ffreestanding -target x86_64-none-elf
LDFLAGS = -Ttext 0x8200
LDFLAGS_BIN = ${LDFLAGS} --oformat binary
ASFLAGS = -f elf64

all: pzos_kernel pzos_kernel.elf

pzos_kernel: ${OBJ}
	${LD} -o $@ ${LDFLAGS_BIN} $^

pzos_kernel.elf: ${OBJ}
	${LD} -o $@ ${LDFLAGS} $^

%.o: %.c
	${CC} ${CCFLAGS} ${INC} -o $@ $^

%.o: %.asm
	${ASM} $< ${ASFLAGS} -o $@

clean:
	rm -f pzos_kernel pzos_kernel.elf *.o **/*.o