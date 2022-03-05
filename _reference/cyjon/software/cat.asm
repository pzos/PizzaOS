;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

	;-----------------------------------------------------------------------
	%include	"software/cat/config.asm"
	;-----------------------------------------------------------------------

;===============================================================================
cat:
	; wyłącz wirtualny kursor (nie jest potrzebny, program nie wchodzi w interakcje, oszczędzamy czas procesora)
	mov	ax,	KERNEL_SERVICE_PROCESS_stream_out
	mov	ecx,	cat_string_init_end - cat_string_init
	mov	rsi,	cat_string_init
	int	KERNEL_SERVICE

	; pobierz rozmiar listy argumentów przesłanych do procesu
	pop	rcx

	; przesłano argumenty do procesu?
	test	rcx,	rcx
	jz	.not_found	; nie

	; ustaw wskaźnik na listę argumentów
	mov	rsi,	rsp

	; usuń z początku i końca listy wszystkie białe znaki
	macro_library	LIBRARY_STRUCTURE_ENTRY.string_trim
	jc	.not_found	; niepoprawna ścieżka do pliku lub nie istnieje

	; wczytaj dane pliku na koniec programu
	mov	ax,	KERNEL_SERVICE_VFS_read
	int	KERNEL_SERVICE
	jc	.not_found	; nie znaleziono podanego pliku

	;-----------------------------------------------------------------------

	; zapamiętaj rozmiar wczytanego pliku
	mov	rbx,	rcx

	; wyświetl kolejno Bajty z pliku
	mov	ax,	KERNEL_SERVICE_PROCESS_stream_out_char
	mov	ecx,	STATIC_BYTE_SIZE_byte	; po jednym znaku

	; ustaw wskaźnik na dane pliku
	mov	rsi,	rdi

.loop:
	; pobierz kod ASCII
	mov	dl,	byte [rsi]

	; znak drukowalny?
	cmp	dl,	STATIC_SCANCODE_TILDE
	ja	.no	; nie
	cmp	dl,	STATIC_SCANCODE_SPACE
	jae	.yes	; tak

	; znak nowej linii?
	cmp	dl,	STATIC_SCANCODE_NEW_LINE
	je	.yes	; tak, wyświetl

	; znak karetki?
	cmp	dl,	STATIC_SCANCODE_RETURN
	je	.yes	; tak, wyświetl

.no:
	; zamień na znak kropki
	mov	dl,	STATIC_SCANCODE_DOT

.yes:
	; wyświetl
	int	KERNEL_SERVICE

	; ustaw wskaźnik na następny Bajt z pliku
	inc	rsi

	; wyświetlić pozostałą część?
	dec	rbx
	jnz	.loop	; tak

	; koniec programu
	jmp	.end

	;-----------------------------------------------------------------------

.not_found:
	; wyświetl komunikat błędu
	mov	ax,	KERNEL_SERVICE_PROCESS_stream_out
	mov	rcx,	cat_string_not_found_end - cat_string_not_found
	mov	rsi,	cat_string_not_found
	int	KERNEL_SERVICE

.end:
	; wyjdź z programu
	xor	ax,	ax
	int	KERNEL_SERVICE

	macro_debug	"software: cat"

	;-----------------------------------------------------------------------
	%include	"software/cat/data.asm"
	%include	"software/cat/text.asm"
	;-----------------------------------------------------------------------

cat_end:
