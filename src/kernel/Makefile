CC = clang
GDB = gdb 

LD = ld.lld
ASM = nasm

INC = -Iinc/
SRC = $(shell find . -type c -name "*.c")
ASM_SRC = $(shell find . -type asm -name "*.asm")

OBJ = ${ASM_SRC:.asm=.o} ${SRC:.c=.o} 

CCFLAGS = -ggdb -c -ffreestanding -target x86_64-none-elf
LDFLAGS = -Ttext 0x8200
LDFLAGS_BIN = ${LDFLAGS} --oformat binary
ASFLAGS = -f elf64

all: pz_kernel pz_kernel.elf

pz_kernel: ${OBJ}
	${LD} -o $@ ${LDFLAGS_BIN} $^

pz_kernel.elf: ${OBJ}
	${LD} -o $@ ${LDFLAGS} $^

%.o: %.c
	${CC} ${CCFLAGS} ${INC} -o $@ $^

%.o: %.asm
	${ASM} $< ${ASFLAGS} -o $@

clean:
	rm -f pz_kernel pz_kernel.elf *.o **/*.o