;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

	;-----------------------------------------------------------------------
	%include	"kernel/library/terminal/header.asm"
	;-----------------------------------------------------------------------

;===============================================================================
; wejście:
;	r8 - wskaźnik do struktury terminala
library_terminal:
	; zachowaj oryginalne rejestry
	push	rax
	push	rdx

	; wylicz scanline z znaków
	mov	rax,	LIBRARY_FONT_HEIGHT_pixel
	mul	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_byte]
	mov	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char],	rax

	; wylicz szerokość terminala w znakach
	mov	rax,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width]
	xor	edx,	edx
	div	qword [library_font_width_pixel]
	mov	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width_char],	rax

	; wylicz wysokość terminala w znakach
	mov	rax,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.height]
	xor	edx,	edx
	div	qword [library_font_height_pixel]
	mov	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.height_char],	rax

	; domyślnie wirtualny kursor wyłączony
	mov	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.lock],	STATIC_FALSE

	; inicjalizuj przestrzeń terminala
	call	library_terminal_clear

	; włącz wirtualny kursor
	call	library_terminal_cursor_enable

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal"

;===============================================================================
; wejście:
;	r8 - wskaźnik do struktury terminala
library_terminal_clear:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx
	push	rdi

	; wyłączy wirtualny kursor
	call	library_terminal_cursor_disable

	; wyczyść przestrzeń domyślnym kolorem tła
	mov	eax,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.background_color]
	mov	rdx,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.height]
	mov	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.address]

.loop:
	; zachowaj adres początku fragmentu
	push	rdi

	; wyczyść pierwszy fragment
	mov	rcx,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width]
	rep	stosd

	; przywróć adres początku fragmentu
	pop	rdi

	; przesuń wskaźnik na następny fragment
	add	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_byte]

	; koniec przestrzeni?
	dec	rdx
	jnz	.loop	; nie

	; ustaw wirtualny kursor na na początek przestrzeni terminala
	mov	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.cursor],	STATIC_EMPTY

	; ustaw sprzętowy kursor na miejsce
	call	library_terminal_cursor_set

	; włącz wirtualny kursor
	call	library_terminal_cursor_enable

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_clear"

;===============================================================================
; wejście:
;	r8 - wskaźnik do struktury terminala
library_terminal_cursor_disable:
	; nałóż blokadę na kursor
	inc	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.lock]

	; blokada nałożona?
	cmp	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.lock],	STATIC_FALSE
	jne	.ready	; blokada nałożona już wcześniej, zwiększono poziom

	; przełącz widoczność kursora
	call	library_terminal_cursor_switch

.ready:
	; przywróć oryginalne rejestry
	ret

	macro_debug	"library_terminal_cursor_disable"

;===============================================================================
; wejście:
;	r8 - wskaźnik do struktury terminala
library_terminal_cursor_enable:
	; blokada nałożona?
	cmp	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.lock],	STATIC_EMPTY
	je	.ready	; nie, zignoruj

	; zwolnij blokadę na kursor
	dec	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.lock]

	; blokada dalej nałożona?
	cmp	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.lock],	STATIC_EMPTY
	jne	.ready	; tak, zignoruj

	; przełącz widoczność kursora
	call	library_terminal_cursor_switch

.ready:
	; przywróć oryginalne rejestry
	ret

	macro_debug	"library_terminal_cursor_enable"

;===============================================================================
; wejście:
;	r8 - wskaźnik do struktury terminala
library_terminal_cursor_switch:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdi

	; scanline ekranu
	mov	rax,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_byte]

	; wysokość kursora
	mov	rcx,	LIBRARY_FONT_HEIGHT_pixel

	; pozycja kursora
	mov	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.pointer]

.loop:
	; odróć kolor piksela
	not	word [rdi]
	not	byte [rdi + STATIC_WORD_SIZE_byte]

	; przesuń wskaźnik na następny piksel
	add	rdi,	rax

	; nastepny piksel?
	dec	rcx
	jnz	.loop

.end:
	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_cursor_switch"

;===============================================================================
; wejście:
;	r8 - wskaźnik do struktury terminala
library_terminal_cursor_set:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx

	; wyłącz kursor
	call	library_terminal_cursor_disable

	; oblicz pozycję kursora w znakach
	mov	eax,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.cursor + LIBRARY_TERMINAL_STURCTURE_CURSOR.y]
	mul	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]
	push	rax	; zapamiętaj
	mov	eax,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.cursor + LIBRARY_TERMINAL_STURCTURE_CURSOR.x]
	mul	qword [library_font_width_byte]
	add	qword [rsp],	rax
	pop	rax	; zwróć wynik

	; zapisz nową pozycję wskaźnika w przestrzeni pamięci karty graficznej
	add	rax,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.address]
	mov	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.pointer],	rax

	; włącz kursor
	call	library_terminal_cursor_enable

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_cursor_set"

;===============================================================================
; wejście:
;	rax - kod ASCII znaku
;	rdi - pozycja znaku w przestrzeni pamięci ekranu
;	r8 - wskaźnik do struktury terminala
library_terminal_matrix:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	push	r9

	; oblicz prdesunięcie względem początku matrycy czcionki dla znaku
	mov	ebx,	dword [library_font_height_pixel]
	mul	rbx

	; ustaw wskaźnik na matrycę znaku
	mov	rsi,	library_font_matrix
	add	rsi,	rax

	; pobierz kolor czcionki
	mov	r9d,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.foreground_color]

.next:
	; szerokość matrycy znaku liczona od zera
	mov	ecx,	LIBRARY_FONT_WIDTH_pixel - 0x01

.loop:
	; włączyć piksel matrycy znaku na ekranie?
	bt	word [rsi],	cx
	jnc	.continue	; nie

	; wyświetl piksel o zdefiniowanym kolorze znaku
	mov	dword [rdi],	r9d

	; wyświetl cień za pikselem
	; mov	dword [rdi + STATIC_DWORD_SIZE_byte],	STATIC_EMPTY

.continue:
	; następny piksel matrycy znaku
	add	rdi,	STATIC_DWORD_SIZE_byte

	; wyświetlić pozostałe?
	dec	cl
	jns	.loop	; tak

	; przesuń wskaźnik na następną linię matrycy na ekranie
	sub	rdi,	LIBRARY_FONT_WIDTH_pixel << KERNEL_VIDEO_DEPTH_shift	; cofnij o szerokość wyświetlonego znaku w Bajtach
	add	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_byte]	; przesuń do przodu o rozmiar scanline ekranu

	; przesuń wskaźnik na następną linię matrycy znaku
	inc	rsi

	; przetworzono całą matrycę znaku?
	dec	bl
	jnz	.next	; nie, kontynuuj z następną linią matrycy znaku

	; przywróć oryginalne rejestry
	pop	r9
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_matrix"

;===============================================================================
; wejście:
;	rdi - wskaźnik pozycji znaku
;	r8 - wskaźnik do struktury terminala
library_terminal_empty_char:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi

	; wysokość matrycy znaku w pikselach
	mov	ebx,	LIBRARY_FONT_HEIGHT_pixel

	; kolor tła
	mov	eax,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.background_color]

.next:
	; szerokość matrycy znaku liczona od zera
	mov	cx,	LIBRARY_FONT_WIDTH_pixel - 0x01

.loop:
	; wyświetl piksel o zdefiniowanym kolorze tła
	stosd

.continue:
	; następny piksel z linii matrycy znaku
	dec	cl
	jns	.loop

	; przesuń wskaźnik na następną linię matrycy na ekranie
	sub	rdi,	LIBRARY_FONT_WIDTH_pixel << KERNEL_VIDEO_DEPTH_shift	; cofnij o szerokość znaku w Bajtach
	add	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_byte]	; przesuń do przodu o rozmiar scanline ekranu

	; przetworzono całą matrycę znaku?
	dec	bl
	jnz	.next	; nie, następna linia matrycy znaku

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_empty_char"

;===============================================================================
; wejście:
;	rax - kod ASCII znaku
;	rcx - ilość kopii znaku do wyświetlenia
;	r8 - wskaźnik do struktury terminala
library_terminal_char:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi

	; wyłącz kursor
	call	library_terminal_cursor_disable

	; pozycja kursora na osi X,Y
	mov	ebx,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.cursor + LIBRARY_TERMINAL_STURCTURE_CURSOR.x]
	mov	edx,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.cursor + LIBRARY_TERMINAL_STURCTURE_CURSOR.y]

	; ustaw wskaźnik na ostatnią pozycję w przestrzeni pamięci trybu tekstowego
	mov	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.pointer]

.loop:
	; znak "powrót karetki"?
	cmp	ax,	STATIC_SCANCODE_RETURN
	je	.return	; tak

	; znak "nowej linii"?
	cmp	ax,	STATIC_SCANCODE_NEW_LINE
	je	.new_line	; tak

	; znak "backspace"?
	cmp	ax,	STATIC_SCANCODE_BACKSPACE
	je	.backspace	; tak

	; nieobsługiwany znak specjalny?
	cmp	ax,	STATIC_SCANCODE_SPACE
	jb	.omit	; tak
	cmp	ax,	STATIC_SCANCODE_TILDE
	ja	.omit	; tak

	; wyczyść przestrzeń znaku domyślnym kolorem tła
	call	library_terminal_empty_char

	; wyświetl matrycę znaku na ekran
	sub	ax,	STATIC_SCANCODE_SPACE	; macierz czcionki rozpoczyna się od znaku STATIC_SCANCODE_SPACE
	call	library_terminal_matrix

	; przesuń kursor na osi X o jedną pozycję w prawo
	inc	ebx

	; przesuń wskaźnik na następną pozycję w przestrzeni pamięci karty graficznej
	add	rdi,	qword [library_font_width_byte]

	; pozycja kursora poza przestrzenią pamięci trybu tekstowego?
	cmp	ebx,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.width_char]
	jb	.continue	; nie

	; zachowaj oryginalne rejestry
	push	rax
	push	rdx

	; przesuń wskaźnik kursora na początek nowej linii
	mov	rax,	qword [library_font_width_byte]
	mul	rbx
	sub	rdi,	rax
	add	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rax

	; przesuń kursor do następnego wiersza
	xor	ebx,	ebx
	inc	edx

.row:
	; pozycja kursora poza przestrzenią pamięci trybu tekstowego?
	cmp	edx,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.height_char]
	jb	.continue	; nie

	; koryguj pozycję kursora na osi Y
	dec	edx

	; koryguj wskaźnik
	sub	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]

	; przewiń zawartość przestrzeni pamięci trybu tekstowego o jedną linię tekstu w górę
	call	library_terminal_scroll

.continue:
	; wyświetlono wszystkie kopie?
	dec	rcx
	jnz	.loop	; nie

	; zachowaj aktualną pozycję kursora w przestrzeni pamięci trybu tekstowego
	mov	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.cursor + LIBRARY_TERMINAL_STURCTURE_CURSOR.x],	ebx
	mov	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.cursor + LIBRARY_TERMINAL_STURCTURE_CURSOR.y],	edx

	; zachowaj aktualną pozycję wskaźnika w przestrzeni pamięci trybu tekstowego
	mov	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.pointer],	rdi

.omit:
	; włącz kursor
	call	library_terminal_cursor_enable

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_char"

;-------------------------------------------------------------------------------
.return:
	; przesuń wskaźnik i wirtualny kursor na początek aktualnej linii
	mov	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.cursor + LIBRARY_TERMINAL_STURCTURE_CURSOR.x],	STATIC_EMPTY
	call	library_terminal_cursor_set

	; koryguj pozyję wirtualnego kursora na osi X
	xor	ebx,	ebx

	; pobierz nowy wskaźnik pozycji wirtualnego kursora wprzestrzeni pamięci terminala
	mov	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.pointer]

	; powrót do głównej pętli
	jmp	.continue

	macro_debug	"library_terminal_char.return"

;-------------------------------------------------------------------------------
.new_line:
	; zachowaj oryginalne rejestry
	push	rax	; kod ASCII znaku
	push	rdx	; pozycja kursor na osi Y

	; cofnij wskaźnik na początek linii
	mov	eax,	ebx
	mul	qword [library_font_width_pixel]
	shl	rax,	KERNEL_VIDEO_DEPTH_shift
	sub	rdi,	rax

	; cofnij wirtualny kursor na początek linii
	xor	ebx,	ebx

	; przesuń kursor i wskaźnik do następnej linii
	add	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]

	; przywróć pozycję kursora na osi Y
	pop	rdx
	inc	rdx	; przesuń kursor do następnej linii

	; przywróć kod ASCII znaku
	pop	rax

	; kontynuuj
	jmp	.row

	macro_debug	"library_terminal_char.new_line"

;-------------------------------------------------------------------------------
.backspace:
	; kursor znajduje się na początku linii?
	test	ebx,	ebx
	jz	.begin	; tak

	; cofnij pozycję kursora na osi X
	dec	ebx

	; kontynuuj
	jmp	.clear

.begin:
	; kursor znajduje się w pierwszej linii?
	test	edx,	edx
	jz	.continue	; tak

	; ustaw pozycję kursora na koniec aktualnej linii
	mov	ebx,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.width_char]
	dec	ebx

	; cofnij pozycję kursora o jedną linię
	dec	edx

	; zachowaj oryginalny rejestr
	push	rax
	push	rdx

	; przesuń wskaźnik kursora na początek poprzedniej linii
	sub	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]
	mov	rax,	qword [library_font_width_byte]
	mul	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width_char]
	add	rdi,	rax

	; przywróć oryginalny rejestr
	pop	rdx
	pop	rax

.clear:
	; przesuń wskaźnik o jeden znak wstecz
	sub	rdi,	LIBRARY_FONT_WIDTH_pixel << KERNEL_VIDEO_DEPTH_shift

	; wyczyść przestrzeń znaku domyślnym kolorem tła
	call	library_terminal_empty_char

	; kontynuuj
	jmp	.continue

	macro_debug	"library_terminal_char.backspace"

;===============================================================================
; wejście:
;	r8 - wskaźnik do struktury terminala
library_terminal_scroll:
	; zachowaj oryginalne rejestry
	push	rbx
	push	rcx

	; rozpocznij od linii nr 1 (liczymy od zera)
	mov	ecx,	1

	; wszystkie wiersze
	mov	rbx,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.height_char]
	dec	rbx	; pierwszy wiersz nie bierze udziału

	; przewiń w górę
	call	library_terminal_scroll_up

	; wyczyść ostatnią linię znaków na ekranie
	call	library_terminal_empty_line

	; przywróć oryginalne rejestry
	pop	rcx
	pop	rbx

	; powrót z procedury
	ret

	macro_debug	"library_terminal_scroll"

;===============================================================================
; wejście:
;	rbx - ilość linii do przesunięcia
;	rcx - linia rozpoczynająca
;	r8 - wskaźnik do struktury terminala
library_terminal_scroll_down:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	push	r9

	; wyłącz wirtualny kursor
	call	library_terminal_cursor_disable

	; rozpocznij przewijanie od linii RCX
	mov	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.address]
	mov	rax,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]
	add	rcx,	rbx
	mul	rcx
	add	rdi,	rax

	; w kierunku linii poprzedniej
	mov	rsi,	rdi
	sub	rsi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]

	; rozmiar linii przestrzeni terminala w Bajtach
	mov	rax,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width]
	shl	rax,	KERNEL_VIDEO_DEPTH_shift

	; scanline przestrzeni wyświetlania
	mov	r9,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_byte]

.row:
	; zachowaj wskaźniki aktualnie przetwarzanych wierszy
	push	rsi
	push	rdi

	; wysokość linii w pikselach
	mov	edx,	LIBRARY_FONT_HEIGHT_pixel

.line:
	; przesuń pierwszy wiersz aktualnej linii
	mov	rcx,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width]
	rep	movsd

	; przesuń wskaźniki na następną linię
	sub	rdi,	rax
	add	rdi,	r9
	sub	rsi,	rax
	add	rsi,	r9

	; przesunięto wszystkie linie pierwszego wiersza?
	dec	edx
	jnz	.line	; nie

	; przywróć wskaźniki przetworzonych wierszy
	pop	rdi
	pop	rsi

	; przesuń wskaźniki na następny wiersz
	sub	rsi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]
	sub	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]

	; przesunięto wszystkie wiersze?
	dec	rbx
	jnz	.row	; nie

	; włącz wirtualny kursor
	call	library_terminal_cursor_enable

	; przywróć oryginalne rejestry
	pop	r9
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_scroll_up"

;===============================================================================
; wejście:
;	rbx - ilość linii do przesunięcia
;	rcx - linia rozpoczynająca
;	r8 - wskaźnik do struktury terminala
library_terminal_scroll_up:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	push	r9

	; wyłącz wirtualny kursor
	call	library_terminal_cursor_disable

	; rozpocznij przewijanie od linii RCX
	mov	rsi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.address]
	mov	rax,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]
	mul	rcx
	add	rsi,	rax

	; w kierunku linii następnej
	mov	rdi,	rsi
	sub	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]

	; rozmiar linii przestrzeni terminala w Bajtach
	mov	rax,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width]
	shl	rax,	KERNEL_VIDEO_DEPTH_shift

	; scanline przestrzeni wyświetlania
	mov	r9,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_byte]

.row:
	; wysokość linii w pikselach
	mov	edx,	LIBRARY_FONT_HEIGHT_pixel

.line:
	; przesuń pierwszy wiersz aktualnej linii
	mov	rcx,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width]
	rep	movsd

	; przesuń wskaźniki na następną linię
	sub	rdi,	rax
	add	rdi,	r9
	sub	rsi,	rax
	add	rsi,	r9

	; przesunięto wszystkie linie pierwszego wiersza?
	dec	edx
	jnz	.line	; nie

	; przesunięto wszystkie wiersze?
	dec	rbx
	jnz	.row	; nie

	; włącz wirtualny kursor
	call	library_terminal_cursor_enable

	; przywróć oryginalne rejestry
	pop	r9
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_scroll_up"

;===============================================================================
; wejście:
;	rbx - numer linii na ekranie
;	r8 - wskaźnik do struktury terminala
library_terminal_empty_line:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi

	; wyłącz wirtualny kursor
	call	library_terminal_cursor_disable

	; wylicz pozycję względmą linii w przestrzeni terminala
	mov	rax,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_char]
	mul	rbx

	; scanline przestrzeni terminala
	mov	rbx,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width]
	shl	rbx,	KERNEL_VIDEO_DEPTH_shift

	; wysokość wiersza w pikselach
	mov	edx,	LIBRARY_FONT_HEIGHT_pixel

	; ustaw wskaźnik
	mov	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.address]
	add	rdi,	rax

.line:
	; wyczyść linię domyślnym kolorem tła
	mov	eax,	dword [r8 + LIBRARY_TERMINAL_STRUCTURE.background_color]
	mov	rcx,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.width]
	rep	stosd

	; przesuń wskaźnik na następną linię wiersza
	sub	rdi,	rbx
	add	rdi,	qword [r8 + LIBRARY_TERMINAL_STRUCTURE.scanline_byte]

	; wyczyszczono wszystkie linie wiersza?
	dec	edx
	jnz	.line	; nie

	; włącz wirtualny kursor
	call	library_terminal_cursor_enable

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_empty_line"

;===============================================================================
; wejście:
;	rcx - ilość znaków w ciągu
;	rsi - wskaźnik do ciągu
;	r8 - wskaźnik do struktury terminala
library_terminal_string:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi

	; wyłącz wirtualny kursor
	call	library_terminal_cursor_disable

	; wyświetlić jakąkolwiek ilość znaków z ciągu?
	test	rcx,	rcx
	jz	.end	; nie

	; wyczyść zmienną
	xor	eax,	eax

.loop:
	; pobierz kod ASCII z ciągu
	lodsb

	; wymuszony koniec ciągu?
	test	al,	al
	jz	.end	; tak

	; zachowaj pozostały rozmiar ciągu
	push	rcx

	; wyświetl 1 kopię kodu ASCII
	mov	ecx,	1
	call	library_terminal_char

	; przywróć pozostały rozmiar ciągu
	pop	rcx

.continue:
	; wyświetl pozostałą część ciągu
	dec	rcx
	jnz	.loop

.end:
	; włącz wirtualny kursor
	call	library_terminal_cursor_enable

	; przywróć oryginalne rejestry
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_string"

;===============================================================================
; wejście:
;	rax - wartość do wyświetlenia
;	bl - system liczbowy
;	ecx - rozmiar wypełnienia przed liczbą
;	dl  - kod ASCII wypełnienia
;	r8 - wskaźnik do struktury terminala
library_terminal_number:
	; zachowaj oryginalne rejestry
	push	rax
	push	rdx
	push	rbp
	push	r9

	; wyłącz wirtualny kursor
	call	library_terminal_cursor_disable

	; wyczyść zbędne dane w rejestrze RBX
	and	ebx,	STATIC_BYTE_mask

	; podstawa liczby w odpowiednim zakresie?
	cmp	bl,	2
	jb	.error	; nie
	cmp	bl,	36
	ja	.error	; nie

	; zachowaj wartość prefiksa
	movzx	r9,	dl
	sub	r9,	0x30

	; wyczyść starszą część / resztę z dzielenia
	xor	rdx,	rdx

	; utwórz stos zmiennych lokalnych
	mov	rbp,	rsp

.loop:
	; oblicz resztę z dzielenia
	div	rbx

	; zapisz resztę z dzielenia do zmiennych lokalnych
	push	rdx
	dec	rcx	; zmniejsz rozmiar prefiksu

	; wyczyść resztę z dzielenia
	xor	rdx,	rdx

	; przeliczać dalej?
	test	rax,	rax
	jnz	.loop	; tak

	; uzupełnić prefiks?
	cmp	rcx,	STATIC_EMPTY
	jle	.print	; nie

.prefix:
	; uzupełnij wartość o prefiks
	push	r9

	; uzupełniać dalej?
	dec	rcx
	jnz	.prefix	; tak

.print:
	; wyświetl każdą cyfrę
	mov	ecx,	0x01	; 1 raz

	; pozostały cyfry do wyświetlenia?
	cmp	rsp,	rbp
	je	.end	; nie

	; pobierz cyfrę
	pop	rax

	; przemianuj cyfrę na kod ASCII
	add	rax,	0x30

	; system liczbowy powyżej podstawy 10?
	cmp	al,	0x3A
	jb	.no	; nie

	; koryguj kod ASCII do podstawy liczbowej
	add	al,	0x07

.no:
	; wyświetl cyfrę
	call	library_terminal_char

	; kontynuuj
	jmp	.print

.error:
	; flaga, błąd
	stc

.end:
	; włącz wirtualny kursor
	call	library_terminal_cursor_enable

	; przywróć oryginalne rejestry
	pop	r9
	pop	rbp
	pop	rdx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"library_terminal_number"
