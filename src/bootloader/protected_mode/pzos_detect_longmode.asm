;pzos_detect_longmode.asm: Detect if the CPU supports long mode (64-bitness)
[bits 32]

pz_detect_longmode:
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
    je cpuid_not_found_protected

    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb cpuid_not_found_protected

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz lm_not_found_protected
    
    popad
    ret

cpuid_not_found_protected:
    call pz_protected_clear
    mov esi, cpuid_not_found_str
    call pz_print_protected
    jmp $

lm_not_found_protected:
    call pz_protected_clear
    mov esi, lm_not_found_str
    call pz_print_protected
    jmp $

lm_not_found_str: db `ERROR: Long mode not supported. Exiting...`, 0
cpuid_not_found_str: db `ERROR: CPUID unsupported, but required for long mode`, 0