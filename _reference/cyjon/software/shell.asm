;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

	;-----------------------------------------------------------------------
	%include	"software/shell/config.asm"
	;-----------------------------------------------------------------------

;===============================================================================
shell:
	; inicjalizuj środowisko pracy powłoki
	%include	"software/shell/init.asm"

.restart:
	; pobierz informacje o strumieniu wyjścia
	mov	ax,	KERNEL_SERVICE_PROCESS_stream_meta
	mov	bl,	KERNEL_SERVICE_PROCESS_STREAM_META_FLAG_get | KERNEL_SERVICE_PROCESS_STREAM_META_FLAG_out
	mov	rdi,	shell_stream_meta
	int	KERNEL_SERVICE
	jc	shell.restart	; brak aktualnych informacji

	; pobierz od użyszkodnia polecenie
	%include	"software/shell/input.asm"

	; przetwórz
	%include	"software/shell/exec.asm"

	macro_debug	"software: shell"

	;-----------------------------------------------------------------------
	%include	"software/shell/data.asm"
	%include	"software/shell/event.asm"
	%include	"software/shell/header.asm"
	%include	"software/shell/prompt.asm"
	;-----------------------------------------------------------------------
