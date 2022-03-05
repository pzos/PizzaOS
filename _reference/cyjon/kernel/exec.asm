;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

KERNEL_EXEC_FLAG_accept_childrens	equ	00000001b	; przyjmuj na standardowe wejście strumienie od procesów potomnych
KERNEL_EXEC_FLAG_forward_out		equ	00000010b	; przekieruj wyjście rodzica na wejście procesu potomnego

;===============================================================================
; wejście:
;	rcx - ilość znaków reprezentujących nazwę uruchamianego programu
;	rsi - wskaźnik do nazwy programu wraz z argumentami
;	rdi - wskaźnik do supła pliku
;	r8 - rozmiar argumentów w Bajtach
; wyjście:
;	Flaga CF - wystąpił błąd
;	rax - kod błędu, jeśli Flaga CF podniesiona
;	rcx - pid nowego procesu
;	rdi - wskaźnik do struktury zadania
kernel_exec:
	; zachowaj oryginalne rejestry
	push	rdx
	push	rsi
	push	rbp
	push	r8
	push	r11
	push	r12
	push	r13
	push	r14
	push	rax
	push	rbx
	push	rcx
	push	rdi

	; oblicz ilość stron niezbędnych do załadowania pliku do pamięci
	mov	rcx,	qword [rdi + KERNEL_VFS_STRUCTURE_KNOT.size]
	call	library_page_from_size

	; zachowaj rozmiar przestrzeni kodu w Bajtach
	mov	r12,	rcx

	; ogranicz ilość przesyłanych argumentów do procesu
	mov	eax,	KERNEL_ERROR_memory_low	; kod błędu
	cmp	r8,	SOFTWARE_STACK_LIMIT_page << STATIC_MULTIPLE_BY_PAGE_shift	; zainicjowany rozmiar stosu procesu w Bajtach
	ja	.error	; przepełnienie

	; zarezerwuj ilość stron, niezbędną do inicjalizacji procesu
	add	rcx,	15	; 14 stron na podstawową przestrzeń procesu, +1 do rozszerzenia serpentyny jeśli brak miejsca
	call	kernel_page_secure
	jc	.error	; brak wystarczającej ilości pamięci

	; poinformuj wszystkie procedury zależne by korzystały z zarezerwowanych stron
	mov	rbp,	rcx

	; utwórz tablicę PML4 procesu
	call	kernel_memory_alloc_page
	call	kernel_page_drain

	; wykorzystano stronę do stronicowania
	inc	qword [kernel_page_paged_count]

	; zachowaj adres
	mov	r11,	rdi

	;-----------------------------------------------------------------------
	; przygotuj miejsce pod przestrzeń kodu procesu
	mov	rax,	SOFTWARE_BASE_address
	mov	bx,	KERNEL_PAGE_FLAG_available | KERNEL_PAGE_FLAG_write | KERNEL_PAGE_FLAG_user
	mov	rcx,	r12
	call	kernel_page_map_logical
	jc	.error

	;-----------------------------------------------------------------------
	; przygotuj miejsce pod binarną mapę pamięci procesu
	shl	r12,	STATIC_PAGE_SIZE_shift
	add	rax,	r12	; za przestrzenią kodu procesu
	and	bx,	~KERNEL_PAGE_FLAG_user	; dostęp tylko od strony jądra systemu
	mov	rcx,	KERNEL_MEMORY_MAP_SIZE_page
	call	kernel_page_map_logical

	; zachowaj bezpośredni adres binarnej mapy pamięci procesu
	mov	r13,	rax

	; pobierz adres fizyczny strony przeznaczonej na binarną mapę pamięci procesu
	mov	rdi,	qword [r8]
	and	di,	STATIC_PAGE_mask	; usuń flagi z adresu strony
	push	rdi	; zachowaj

	; wyczyść binarną mapę pamięci procesu
	mov	rax,	STATIC_MAX_unsigned
	mov	ecx,	(KERNEL_MEMORY_MAP_SIZE_page << STATIC_PAGE_SIZE_shift) >> STATIC_DIVIDE_BY_QWORD_shift
	rep	stosq

	; oznacz w binarnej mapie pamięci procesu przestrzeń zajętą przez kod i binarną mapę
	pop	rsi
	mov	rcx,	r12
	shr	rcx,	STATIC_PAGE_SIZE_shift
	add	rcx,	KERNEL_MEMORY_MAP_SIZE_page
	call	kernel_memory_secure

	;-----------------------------------------------------------------------
	; przygotuj miejsce pod stos procesu
	mov	rax,	KERNEL_TASK_STACK_address
	or	bx,	KERNEL_PAGE_FLAG_user
	mov	rcx,	SOFTWARE_STACK_LIMIT_page
	call	kernel_page_map_logical
	jc	.error

	;-----------------------------------------------------------------------
	; zachowaj przesłane argumenty na stosie procesu

	; rozmiar listy przesłanych argumentów w Bajtach
	mov	rax,	qword [rsp + STATIC_QWORD_SIZE_byte * 0x08]

	; adres fizyczny strony stosu kontekstu
	mov	rdi,	qword [r8]
	and	di,	STATIC_PAGE_mask	; usuń flagi z adresu

	; przesuń wskaźnik N Bajtów w głąb przestrzeni
	add	rdi,	STATIC_PAGE_SIZE_byte
	sub	rdi,	rax
	and	di,	0xFFF8	; wyrównaj wskaźnik do pełnego adresu

	; miejsce na licznik rozmiaru danych na stosie procesu
	sub	rdi,	STATIC_QWORD_SIZE_byte

	; zapamiętaj adres szczytu stosu procesu
	mov	r14,	KERNEL_TASK_STACK_address
	or	r14w,	di

	; odłóż rozmiar danych na stosie dla procesu
	stosq

	; brak listy argumentów?
	test	rax,	rax
	jz	.no_arguments	; tak

	; ustaw wskaźnik na początek listy argumentów
	mov	rcx,	rax	; licznik danych do skopiowania
	mov	rsi,	qword [rsp + STATIC_QWORD_SIZE_byte * 0x0A]
	add	rsi,	qword [rsp + STATIC_QWORD_SIZE_byte]
	rep	movsb	; kopiuj

.no_arguments:
	;-----------------------------------------------------------------------
	; przygotuj miejsce pod stos kontekstu (należy do jądra systemu)
	mov	rax,	SOFTWARE_BASE_address - KERNEL_STACK_SIZE_byte
	mov	rbx,	KERNEL_PAGE_FLAG_available | KERNEL_PAGE_FLAG_write
	mov	rcx,	KERNEL_STACK_SIZE_byte >> STATIC_DIVIDE_BY_PAGE_shift
	call	kernel_page_map_logical
	jc	.error

	; mapuj przestrzeń jądra systemu
	mov	rsi,	qword [kernel_page_pml4_address]
	mov	rdi,	r11
	call	kernel_page_merge

	; odstaw na początek stosu kontekstu zadania, spreparowane dane powrotu z przerwania sprzętowego "kernel_task"
	mov	rdi,	qword [r8]
	and	di,	STATIC_PAGE_mask	; usuń flagi rekordu tablicy PML1
	add	rdi,	STATIC_PAGE_SIZE_byte - ( STATIC_QWORD_SIZE_byte * 0x05 )	; odłóż 5 rejestrów

	; RIP
	mov	rax,	SOFTWARE_BASE_address
	stosq

	; CS
	mov	rax,	KERNEL_STRUCTURE_GDT.cs_ring3 | 0x03
	stosq	; zapisz

	; EFLAGS
	mov	rax,	KERNEL_TASK_EFLAGS_default
	stosq	; zapisz

	; RSP
	mov	rax,	r14
	stosq	; zapisz

	; DS
	mov	rax,	KERNEL_STRUCTURE_GDT.ds_ring3 | 0x03
	stosq	; zapisz

	; przywróć wskaźnik do supła pliku
	mov	rsi,	qword [rsp]

	;-----------------------------------------------------------------------
	; przełącz przestrzeń pamięci na proces
	mov	rax,	cr3
	mov	cr3,	r11

	; załaduj kod programu do przestrzeni pamięci procesu
	mov	rdi,	SOFTWARE_BASE_address
	call	kernel_vfs_file_read
	jc	.error	; nie udało się załadować pliku do przestrzeni pamięci

	; przywróć przestrzeń pamięci na rodzica
	mov	cr3,	rax
	;-----------------------------------------------------------------------

	; wstaw proces do kolejki zadań
	mov	eax,	KERNEL_ERROR_memory_low	; kod błędu
	movzx	ecx,	byte [rsi + KERNEL_VFS_STRUCTURE_KNOT.length]
	add	rsi,	KERNEL_VFS_STRUCTURE_KNOT.name
	mov	rbx,	(SOFTWARE_BASE_address - STATIC_PAGE_SIZE_byte) - (STATIC_QWORD_SIZE_byte * 0x14)
	call	kernel_task_add
	jc	.error

	; rozmiar zajętej przestrzeni przez proces w stronach
	shr	r12,	STATIC_DIVIDE_BY_PAGE_shift
	add	r12,	KERNEL_MEMORY_MAP_SIZE_page	; przestrzeń binarnej mapy pamięci procesu w stronach
	add	r12,	SOFTWARE_STACK_LIMIT_page	; wraz z przestrzenią stosu
	add	r12,	KERNEL_STACK_SIZE_byte >> STATIC_DIVIDE_BY_PAGE_shift	; i stosem kontekstu
	mov	qword [rdi +KERNEL_TASK_STRUCTURE.memory],	r12

	; uzupełnij wpis o adres binarnej mapy pamięci procesu i jej rozmiar
	add	r13,	qword [kernel_memory_high_mask]
	mov	qword [rdi + KERNEL_TASK_STRUCTURE.map],	r13
	mov	qword [rdi + KERNEL_TASK_STRUCTURE.map_size],	(KERNEL_MEMORY_MAP_SIZE_page << STATIC_PAGE_SIZE_shift) << STATIC_MULTIPLE_BY_8_shift

	; zwolnij niewykrzystane, zarezerwowane strony
	add	qword [kernel_page_free_count],	rbp
	sub	qword [kernel_page_reserved_count],	rbp

	; zwróć numer PID utworzonego zadania
	mov	qword [rsp + STATIC_QWORD_SIZE_byte],	rcx

	; zwróć wskaźnik do struktury zadania
	mov	qword [rsp],	rdi

	; koniec obsługi procedury
	jmp	.end

.error:
	; zwróć kod błędu
	mov	qword [rsp + STATIC_QWORD_SIZE_byte * 0x04],	rax

.end:
	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rbx
	pop	rax
	pop	r14
	pop	r13
	pop	r12
	pop	r11
	pop	r8
	pop	rbp
	pop	rsi
	pop	rdx

	; powrót z procedury
	ret

	macro_debug	"kernel_exec"
