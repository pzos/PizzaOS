;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

;===============================================================================
; wyjście:
;	rbx - rozmiar całego ciągu w Bajtach
;	rcx - rozmiar pierwszego "słowa" w Bajtach
;	rsi - wskaźnik do ciągu
shell_input:
	; domyślnie, znak zachęty od nowej linii
	mov	ecx,	shell_string_prompt_end - shell_string_prompt_with_new_line
	mov	rsi,	shell_string_prompt_with_new_line

	; kursor znajduje się w na początku wiersza?
	cmp	word [rdi + CONSOLE_STRUCTURE_STREAM_META.x],	STATIC_EMPTY
	jne	.prompt	; nie

	; znak zachęty bez nowej linii
	mov	ecx,	shell_string_prompt_end - shell_string_prompt
	mov	rsi,	shell_string_prompt

.prompt:
	; wyświetl znak zachęty
	mov	ax,	KERNEL_SERVICE_PROCESS_stream_out
	int	KERNEL_SERVICE

.continue:
	; pobierz polecenie od użyszkodnika
	mov	rbx,	SHELL_CACHE_SIZE_byte	; rozmiar maksymalny bufora
	xor	ecx,	ecx	; bufor pusty
	mov	rdx,	shell_event	; obsługa zaistniałych wyjątków
	mov	rsi,	shell_cache	; lokalizacja bufora w przestrzeni procesu
	mov	rdi,	shell_ipc_data	; lokalizacja przestrzeni procesu dla przychodzących wyjątków
	macro_library	LIBRARY_STRUCTURE_ENTRY.input
	jc	shell.restart	; bufor pusty lub przerwano wprowadzanie

	; usuń białe znaki z początku i końca bufora
	macro_library	LIBRARY_STRUCTURE_ENTRY.string_trim
	jc	shell.restart	; bufor zawierał tylko "białe znaki"

	; przemieść zawartość bufora na jego początek (jeśli wystąpiły "białe znaki" na jego początku)
	call	shell_prompt_relocate

	; pobierz rozmiar pierwszego "słowa" w ciągu
	mov	al,	STATIC_SCANCODE_SPACE	; separator
	macro_library	LIBRARY_STRUCTURE_ENTRY.string_word_next
