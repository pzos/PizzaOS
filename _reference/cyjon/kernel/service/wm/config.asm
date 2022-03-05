;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

KERNEL_WM_OBJECT_NAME_length				equ	31

KERNEL_WM_OBJECT_FLAG_flush				equ	1 << 0	; obiekt został zaktualizowany
							; poniższe flagi są zarezerwowane dla GUI
KERNEL_WM_OBJECT_FLAG_visible				equ	1 << 1	; obiekt widoczny
KERNEL_WM_OBJECT_FLAG_fixed_xy				equ	1 << 2	; obiekt nieruchomy na osi X,Y
KERNEL_WM_OBJECT_FLAG_fixed_z				equ	1 << 3	; obiekt nieruchomy na osi Z
KERNEL_WM_OBJECT_FLAG_fragile				equ	1 << 4	; obiekt ukrywany przy wystąpieniu akcji z LPM lub PPM
KERNEL_WM_OBJECT_FLAG_pointer				equ	1 << 5	; obiekt typu "kursor"
KERNEL_WM_OBJECT_FLAG_arbiter				equ	1 << 6	; nadobiekt
KERNEL_WM_OBJECT_FLAG_undraw				equ	1 << 7	; przerysuj przestrzeń pod obiektem
KERNEL_WM_OBJECT_FLAG_transparent			equ	1 << 8	; tło okna jest przeźroczyste (w pełni lub częściowo)
KERNEL_WM_OBJECT_FLAG_disabled				equ	1 << 9	; obiekt wyłączony z przetwarzania (zone)

; ostatni element listy zawsze pusty
KERNEL_WM_OBJECT_LIST_limit				equ	(STATIC_PAGE_SIZE_byte / KERNEL_WM_STRUCTURE_OBJECT_LIST_ENTRY.SIZE) - 0x01
KERNEL_WM_FRAGMENT_LIST_limit				equ	(STATIC_PAGE_SIZE_byte / KERNEL_WM_STRUCTURE_FRAGMENT.SIZE) - 0x01

KERNEL_WM_OBJECT_LIST_ENTRY_SIZE_shift			equ	STATIC_MULTIPLE_BY_8_shift

KERNEL_WM_FRAGMENT_FLAG_below				equ	1 << 0	; wyświetl zawartość pod fragmentem

struc	KERNEL_WM_STRUCTURE_OBJECT_LIST_ENTRY
	.object_address					resb	8
	.SIZE:
endstruc

struc	KERNEL_WM_STRUCTURE_OBJECT
	.field						resb	KERNEL_WM_STRUCTURE_FIELD.SIZE
	.address					resb	8
	.SIZE:
endstruc

struc	KERNEL_WM_STRUCTURE_OBJECT_EXTRA
	.size						resb	4
	.flags						resb	2
	.id						resb	8
	.length						resb	1
	.name						resb	KERNEL_WM_OBJECT_NAME_length
	;--- dane specyficzne dla WM
	.pid						resb	8
	.SIZE:
endstruc

struc	KERNEL_WM_STRUCTURE_FIELD
	.x						resb	2
	.y						resb	2
	.width						resb	2
	.height						resb	2
	.SIZE:
endstruc

struc	KERNEL_WM_STRUCTURE_FRAGMENT
	.field						resb	KERNEL_WM_STRUCTURE_FIELD.SIZE
	.object						resb	8
	.SIZE:
endstruc
