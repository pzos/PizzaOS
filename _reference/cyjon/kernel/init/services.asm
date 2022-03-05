;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

struc	KERNEL_INIT_STRUCTURE_SERVICE
	.pointer	resb	8
	.size		resb	8
	.length		resb	1
	.name:
endstruc

;===============================================================================
kernel_init_services:
	; ustaw wskaźnik na początek listy usług do uruchomienia
	mov	rsi,	kernel_init_services_list

.loop:
	; zarezerwuj miejsce pod tablicę PML4 usługi
	call	kernel_memory_alloc_page
	jc	kernel_panic_memory

	; usuń wszystkie wpisy z tablicy
	call	kernel_page_drain

	; mapuj przestrzeń pod stos usługi
	mov	rax,	KERNEL_STACK_address
	mov	rbx,	KERNEL_PAGE_FLAG_available | KERNEL_PAGE_FLAG_write
	mov	rcx,	KERNEL_STACK_SIZE_byte >> STATIC_DIVIDE_BY_PAGE_shift
	mov	r11,	rdi
	call	kernel_page_map_logical

	; odstaw na szczyt stosu usługi, spreparowane dane powrotu z przerwania sprzętowego
	mov	rdi,	qword [r8]	; pobierz z wiersza tablicy PML1 adres początku przestrzeni stosu
	and	di,	STATIC_PAGE_mask	; usuń flagi przestrzeni
	add	rdi,	STATIC_PAGE_SIZE_byte - ( STATIC_QWORD_SIZE_byte * 0x05 )	; odłóż 5 rejestrów

	; RIP
	mov	rax,	qword [rsi + KERNEL_INIT_STRUCTURE_SERVICE.pointer]	; wskaźnik wejścia do usługi
	stosq

	; CS, wszystkie usługi pracują w przestrzeni jądra systemu
	mov	rax,	KERNEL_STRUCTURE_GDT.cs_ring0
	stosq

	; EFLAGS, wszystkie flagi wyczyszczone, przerwania włączone
	mov	rax,	KERNEL_TASK_EFLAGS_default
	stosq

	; RSP, wskaźnik szczytu stosu, po uruchomieniu usługi
	mov	rax,	KERNEL_STACK_pointer
	stosq

	; DS
	mov	rax,	KERNEL_STRUCTURE_GDT.ds_ring0
	stosq

	; zachowaj wskaźnik listy
	push	rsi

	; mapuj przestrzeń pamięci jądra systemu do usługi
	mov	rsi,	qword [kernel_page_pml4_address]
	mov	rdi,	r11
	call	kernel_page_merge

	; przywróć wskaźnik listy
	pop	rsi

	; dodaj usługę do kolejki zadań
	mov	rbx,	KERNEL_STACK_pointer - (STATIC_QWORD_SIZE_byte * 0x14)
	movzx	ecx,	byte [rsi + KERNEL_INIT_STRUCTURE_SERVICE.length]
	push	rcx	; zapamiętaj ilość znaków w nazwie procesu
	add	rsi,	KERNEL_INIT_STRUCTURE_SERVICE.name
	call	kernel_task_add

	; podepnij domyślny strumień wyjścia
	mov	rax,	qword [kernel_stream_out_default]
	mov	qword [rdi + KERNEL_TASK_STRUCTURE.out],	rax

	; ilość procesów korzystających z strumienia
	inc	qword [rax + KERNEL_STREAM_STRUCTURE_ENTRY.lock]

	; oznacz zadanie jako aktywne i usługa
	or	word [rdi + KERNEL_TASK_STRUCTURE.flags],	KERNEL_TASK_FLAG_active | KERNEL_TASK_FLAG_service

	; wstaw informacje o rozmiarze procesu w stronach
	mov	rcx,	qword [rsi + (KERNEL_INIT_STRUCTURE_SERVICE.size - KERNEL_INIT_STRUCTURE_SERVICE.name)]
	call	library_page_from_size
	add	rcx,	KERNEL_STACK_SIZE_byte >> STATIC_DIVIDE_BY_PAGE_shift	; wraz z przestrzenią stosu
	mov	qword [rdi + KERNEL_TASK_STRUCTURE.memory],	rcx

	; koniec tablicy?
	pop	rcx	; przywróć ilość znaków nazwie procesu
	add	rsi,	rcx
	cmp	qword [rsi],	STATIC_EMPTY
	jne	.loop	; nie
