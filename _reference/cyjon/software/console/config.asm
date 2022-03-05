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
	%include	"software/header.asm"
	;-----------------------------------------------------------------------
	%include	"software/console/header.asm"
	;-----------------------------------------------------------------------

%define	PROGRAM_NAME			"console"
%define	PROGRAM_VERSION			"0.27"

CONSOLE_WINDOW_WIDTH_char	equ	60
CONSOLE_WINDOW_HEIGHT_char	equ	20
CONSOLE_WINDOW_WIDTH_pixel	equ	LIBRARY_FONT_WIDTH_pixel * CONSOLE_WINDOW_WIDTH_char
CONSOLE_WINDOW_HEIGHT_pixel	equ	(LIBRARY_FONT_HEIGHT_pixel * CONSOLE_WINDOW_HEIGHT_char) + LIBRARY_BOSU_HEADER_HEIGHT_pixel

CONSOLE_WINDOW_BACKGROUND_color	equ	0x00000000
