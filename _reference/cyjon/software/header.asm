;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

	;-----------------------------------------------------------------------
	; stałe, zmienne, globalne, struktury, obiekty, makra
	;-----------------------------------------------------------------------
	%include	"kernel/header.asm"
	;-----------------------------------------------------------------------

; 64 bitowy kod programu
[bits 64]

; adresowanie względne
[default rel]

; położenie kodu programu w pamięci logicznej
[org SOFTWARE_BASE_address]
