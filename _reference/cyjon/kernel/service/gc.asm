;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

;===============================================================================
kernel_gc:
	; szukaj zakończonego procesu
	call	kernel_gc_search

	; zamknij wszystkie okna utworzone przez proces
	mov	rcx,	qword [rsi + KERNEL_TASK_STRUCTURE.pid]
	call	kernel_wm_object_drain

	; pobierz identyfikator strumienia wejścia procesu
	mov	rdi,	qword [rsi + KERNEL_TASK_STRUCTURE.in]

	; ilość procesów korzystających z strumienia
	dec	qword [rdi + KERNEL_STREAM_STRUCTURE_ENTRY.lock]

	; ze strumienia korzysta tylko jeden proces?
	cmp	qword [rdi + KERNEL_STREAM_STRUCTURE_ENTRY.lock],	STATIC_EMPTY
	jne	.stream_not_unique	; nie

	; zwolnij strumień
	call	kernel_stream_release

.stream_not_unique:
	; pobierz identyfikator strumienia wyjścia procesu
	mov	rdi,	qword [rsi + KERNEL_TASK_STRUCTURE.out]

	; ilość procesów korzystających z strumienia
	dec	qword [rdi + KERNEL_STREAM_STRUCTURE_ENTRY.lock]

	; ze strumienia korzysta tylko jeden proces?
	cmp	qword [rdi + KERNEL_STREAM_STRUCTURE_ENTRY.lock],	STATIC_EMPTY
	jne	.stream_out_unique	; nie

	; zwolnij strumień
	call	kernel_stream_release

.stream_out_unique:
	; zapamiętaj adres tablicy PML4 procesu
	mov	r11,	qword [rsi + KERNEL_TASK_STRUCTURE.cr3]

	; ustaw wskaźnik na podstawę przestrzeni stosu kontekstu procesu
	mov	rax,	SOFTWARE_BASE_address
	movzx	ecx,	word [rsi + KERNEL_TASK_STRUCTURE.stack]	; rozmiar stosu kontekstu wątku
	shl	rcx,	STATIC_PAGE_SIZE_shift	; zamień na Bajty
	sub	rax,	rcx	; koryguj pozycję wskaźnika

	; zwolnij przestrzeń stosu kontekstu wątku
	shr	rcx,	STATIC_PAGE_SIZE_shift
	call	kernel_memory_release_task

	; zwolnij przestrzeń kodu/danych procesu
	mov	rax,	SOFTWARE_BASE_address
	mov	rcx,	KERNEL_PAGE_SOFTWARE_PML4_records
	call	kernel_page_purge

	; zwolnij przestrzeń tablicy PML4 wątku
	mov	rdi,	r11
	call	kernel_memory_release_page	; zwolnij przestrzeń tablicy PML4

	; strona odzyskana z tablic stronicowania
	dec	qword [kernel_page_paged_count]

.child:
	; odszukaj proces potomny lub wątek rodzica
	call	kernel_task_child
	jc	.end	; brak procesów potomnych/wątków

	; wymuś zamknięcie procesu
	and	word [rdi + KERNEL_TASK_STRUCTURE.flags],	~KERNEL_TASK_FLAG_active
	or	word [rdi + KERNEL_TASK_STRUCTURE.flags],	KERNEL_TASK_FLAG_closed

	; odszukaj pozostałe procesy
	jmp	.child

.end:
	; zwolnij wpis w kolejce zadań
	mov	word [rsi + KERNEL_TASK_STRUCTURE.flags],	STATIC_EMPTY

	; ilość zadań w kolejce
	dec	qword [kernel_task_count]

	; ilość dostępnych rekordów w kolejce zadań
	inc	qword [kernel_task_free]

	; szukaj nowego procesu do zwolnienia
	jmp	kernel_gc

	macro_debug	"kernel_gc"

;===============================================================================
; wyjście:
;	rsi - wskaźnik do znalezionego rekordu
kernel_gc_search:
	; zachowaj oryginalne rejestry
	push	rcx

	; przeszukaj od początku kolejkę za zamkniętym wpisem
	mov	rsi,	qword [kernel_task_address]

.restart:
	; ilość wpisów na blok danych kolejki zadań
	mov	rcx,	STATIC_STRUCTURE_BLOCK.link / KERNEL_TASK_STRUCTURE.SIZE

.next:
	; sprawdź flagę zamkniętego procesu
	test	word [rsi + KERNEL_TASK_STRUCTURE.flags],	KERNEL_TASK_FLAG_closed
	jnz	.found

	; przesuń wskaźnik na następny rekord
	add	rsi,	KERNEL_TASK_STRUCTURE.SIZE

	; szukaj dalej?
	dec	rcx
	jnz	.next	; tak

	; zwolnij pozostały czas procesora
	call	kernel_sleep

	; pobierz adres następnego bloku kolejki zadań
	and	si,	STATIC_PAGE_mask
	mov	rsi,	qword [rsi + STATIC_STRUCTURE_BLOCK.link]

	; przeszukaj ponownie serpentynę
	jmp	.restart

.found:
	; przywróć oryginalne rejestry
	pop	rcx

	; powrót z procedury
	ret

	macro_debug	"kernel_gc_search"

kernel_gc_end:
;===============================================================================
