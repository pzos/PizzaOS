;pzos_detect_lm32.asm: Detect if long mode is supported
[bits 32]

pz_detect_lm32:
    pushad

    pushfd
    pop eax

    mov ecx, eax

    xor eax, 1 << 21

    push eax
    popfd

    pushfd
    pop eax

    push ecx
    popfd

    cmp eax, ecx
    je pz_cpuid_not_found32

    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb pz_cpuid_not_found32

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz lm_not_found_protected

    popad
    ret

pz_cpuid_not_found32:
    call pz_clear32
    mov esi, pz_msg_cpuidNotFound
    call pz_print32
    jmp $

lm_not_found_protected:
    call pz_clear32
    mov esi, pz_msg_longModeNotFound
    call pz_print32
    jmp $

pz_msg_longModeNotFound: db `pzos_detect_lm32: Long mode not supported. Please use a compatible 64-bit CPU.`, 0
pz_msg_cpuidNotFound: db `pzos_detect_lm32: CPUID unsupported. This is required for 64-bit mode.`, 0