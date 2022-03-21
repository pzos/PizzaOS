;pz_kentry.asm: Enter the C kernel
[bits 64]
[extern pz_SysMain]

_start:
    call pz_SysMain
    jmp $