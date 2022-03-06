;pzos_lm_detect.asm: Detect long mode support
[bits 32]

pz_lm_detect_protected:
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
	je pz_processorNotSupported
	
	mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
	jb pz_processorNotSupported
	
	mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz pz_lm_notFoundProtected
	
	popad
	ret
	
pz_processorNotSupported:
	call pz_clear_protected
	mov esi, pz_msg_processorNotSupported
	call pz_print_protected
	
	jmp $
	
pz_lm_notFoundProtected:
	call pz_clear_protected
	mov esi, pz_msg_processorNotSupported
	call pz_print_protected
	
	jmp $
	
pz_msg_processorNotSupported: db `\r\npz_lm_detect: Long mode not supported. Please use a compatible CPU.`, 0