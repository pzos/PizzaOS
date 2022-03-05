;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

;===============================================================================
zero_pit:
	; Channel (00b), Access (11b), Operating (000b), Binary Mode (0b)
	mov	al,	0x00
	out	0x0043,	al
