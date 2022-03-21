;pzos_elevate32.asm: Responsible for elevating the CPU to 32-bit protected mode
[bits 16]

pz_bios_elevate32:
	cli
	
	lgdt [pz_gdt32_descriptor]
	
	mov eax, cr0
	or eax, 0x00000001
	mov cr0, eax
	
	jmp pz_seg_code32:pz_pm_init
	
	[bits 32]
	pz_pm_init:
	
	mov ax, pz_seg_data32
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov ebp, 0x90000
	mov esp, ebp
	
	jmp pz_pz_begin32