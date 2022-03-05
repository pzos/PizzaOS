;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

	;-----------------------------------------------------------------------
	%include	"software/soler/config.asm"
	;-----------------------------------------------------------------------

;===============================================================================
soler:
	; inicjalizacja przestrzeni konsoli
	%include	"software/soler/init.asm"

.reset:
	; flaga, przecinek
	mov	r10b,	STATIC_FALSE	; wprowadzono znak części ułamkowej

	; flaga, pierwsza i druga wartość
	mov	r11b,	STATIC_FALSE	; zatwierdzono pierwszą wartość
	mov	r12b,	STATIC_FALSE	; zatwierdzono drugą wartość

	; flaga, przyrostek
	mov	r13b,	STATIC_TRUE	; wyczyść wartość przed modyfikacją

	; flaga, znak wartości
	mov	r14b,	STATIC_FALSE	; dodatnia

	; wyczyść zawartość etykiet
	mov	byte [soler_window.element_label_operation_string],	STATIC_SCANCODE_SPACE
	mov	byte [soler_window.element_label_value_string],	STATIC_SCANCODE_DIGIT_0
	mov	byte [soler_window.element_label_value_length],	STATIC_BYTE_SIZE_byte

.refresh:
	; wyświelt wynik/stan ostatniej operacji
	call	soler_show

	; aktualizuj zawartość etykiet
	mov	rdi,	soler_window

	; etykieta operacji
	mov	rsi,	soler_window.element_label_operation
	macro_library	LIBRARY_STRUCTURE_ENTRY.bosu_element_label

	; etykieta wartości
	mov	rsi,	soler_window.element_label_value
	macro_library	LIBRARY_STRUCTURE_ENTRY.bosu_element_label

	; aktualizuj zawartość okna
	mov	al,	KERNEL_WM_WINDOW_update
	mov	rsi,	soler_window
	or	qword [rsi + LIBRARY_BOSU_STRUCTURE_WINDOW.SIZE + LIBRARY_BOSU_STRUCTURE_WINDOW_EXTRA.flags],	LIBRARY_BOSU_WINDOW_FLAG_flush
	int	KERNEL_WM_IRQ

.loop:
	; pobierz wiadomość
	mov	ax,	KERNEL_SERVICE_PROCESS_ipc_receive
	mov	rdi,	soler_ipc_data
	int	KERNEL_SERVICE
	jc	.loop	; brak wiadomości

	; komunikat typu: urządzenie wskazujące (myszka)?
	cmp	byte [rdi + KERNEL_IPC_STRUCTURE.type],	KERNEL_IPC_TYPE_MOUSE
	je	.mouse	; tak

	; komunikat typu: urządzenie wskazujące (klwiatura)?
	cmp	byte [rdi + KERNEL_IPC_STRUCTURE.type],	KERNEL_IPC_TYPE_KEYBOARD
	jne	.loop	; nie, zignoruj klawizs

	; pobierz kod klawisza
	mov	ax,	word [rdi + KERNEL_IPC_STRUCTURE.data]

.operation:
	; zrestartować wszystkie operacje?
	cmp	ax,	STATIC_SCANCODE_ESCAPE
	je	.reset	; tak

	; wykonaj operację związaną z klawiszem
	call	soler_operation
	jc	.loop	; brak działań

	; powrót do procedury
	jmp	.refresh

.mouse:
	; naciśnięcie lewego klawisza myszki?
	cmp	byte [rdi + KERNEL_IPC_STRUCTURE.data + KERNEL_IPC_STRUCTURE_DATA_MOUSE.event],	KERNEL_IPC_MOUSE_EVENT_left_press
	jne	.loop	; nie, zignoruj wiadomość

	; pobierz współrzędne kursora
	movzx	r8d,	word [rdi + KERNEL_IPC_STRUCTURE.data + KERNEL_IPC_STRUCTURE_DATA_MOUSE.x]	; x
	movzx	r9d,	word [rdi + KERNEL_IPC_STRUCTURE.data + KERNEL_IPC_STRUCTURE_DATA_MOUSE.y]	; y

	; pobierz wskaźnik do elementu biorącego udział w zdarzeniu
	mov	rsi,	soler_window
	macro_library	LIBRARY_STRUCTURE_ENTRY.bosu_element
	jc	.loop	; nie znaleziono elementu zależnego

	; element typu "Button Close"?
	cmp	byte [rsi],	LIBRARY_BOSU_ELEMENT_TYPE_button_close
	je	.close	; tak

	; pobierz wartość elementu
	movzx	eax,	word [rsi + LIBRARY_BOSU_STRUCTURE_ELEMENT_BUTTON.element + LIBRARY_BOSU_STRUCTURE_ELEMENT.event]

	; wykonaj operację
	jmp	.operation

.close:
	; zakończ pracę programu
	xor	ax,	ax
	int	KERNEL_SERVICE

	macro_debug	"software: soler"

	;-----------------------------------------------------------------------
	%include	"software/soler/data.asm"
	%include	"software/soler/operation.asm"
	%include	"software/soler/show.asm"
	%include	"software/soler/fpu.asm"
	;-----------------------------------------------------------------------
