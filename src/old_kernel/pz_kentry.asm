;pz_kentry.asm: Enter the C kernel
[bits _long]
[extern pz_SysMain]

_start:
    call pz_SysMain
    jmp $