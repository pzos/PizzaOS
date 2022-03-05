;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

;===============================================================================
; wejście:
;	cl - typ akcji związanej z myszką
;	rsi - wskaźnik obiektu zależnego
kernel_wm_ipc_mouse:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rsi

	; pobierz ID okna i PID
	mov	rax,	qword [rsi + KERNEL_WM_STRUCTURE_OBJECT.SIZE + KERNEL_WM_STRUCTURE_OBJECT_EXTRA.id]
	mov	rbx,	qword [rsi + KERNEL_WM_STRUCTURE_OBJECT.SIZE + KERNEL_WM_STRUCTURE_OBJECT_EXTRA.pid]

	; zamień pozycję wskaźnika kursora na pośrednią (względem okna)
	sub	r8w,	word [rsi + KERNEL_WM_STRUCTURE_OBJECT.field + KERNEL_WM_STRUCTURE_FIELD.x]
	sub	r9w,	word [rsi + KERNEL_WM_STRUCTURE_OBJECT.field + KERNEL_WM_STRUCTURE_FIELD.y]

	; skomponuj komunikat dla procesu
	mov	rsi,	kernel_wm_ipc_data

	; typ komunikatu: klawiatura
	mov	byte [rsi + KERNEL_IPC_STRUCTURE.type],	KERNEL_IPC_TYPE_MOUSE

	; wyślij informacje o typie akcji
	mov	byte [rsi + KERNEL_IPC_STRUCTURE.data + KERNEL_IPC_STRUCTURE_DATA_MOUSE.event],	cl

	; wyślij informacje o ID okna biorącego udział
	mov	qword [rsi + KERNEL_IPC_STRUCTURE.data + KERNEL_IPC_STRUCTURE_DATA_MOUSE.object_id],	rax

	; wyślij informacje o pozycji wskaźnika kursora
	mov	word [rsi + KERNEL_IPC_STRUCTURE.data + KERNEL_IPC_STRUCTURE_DATA_MOUSE.x],	r8w	; x
	mov	word [rsi + KERNEL_IPC_STRUCTURE.data + KERNEL_IPC_STRUCTURE_DATA_MOUSE.y],	r9w	; y

	; wyślij komunikat
	xor	ecx,	ecx	; standardowy rozmiar komunikatu pod adresem w rejestrze RSI
	call	kernel_ipc_insert

	; przywróć oryginalne rejestry
	pop	rsi
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

	macro_debug	"kernel_wm_ipc_mouse"

;===============================================================================
; wejście:
;	ax - kod klawisza
;	rsi - wskaźnik obiektu zależnego
kernel_wm_ipc_keyboard:
	; zachowaj oryginalne rejestry
	push	rbx
	push	rcx
	push	rdx
	push	rsi

	; pobierz PID procesu okna
	mov	rbx,	qword [rsi + KERNEL_WM_STRUCTURE_OBJECT.SIZE + KERNEL_WM_STRUCTURE_OBJECT_EXTRA.pid]

	; skomponuj komunikat dla procesu
	mov	rsi,	kernel_wm_ipc_data

	; typ komunikatu: klawiatura
	mov	byte [rsi + KERNEL_IPC_STRUCTURE.type],	KERNEL_IPC_TYPE_KEYBOARD

	; wyślij informacje o kodzie klawisza
	mov	word [rsi + KERNEL_IPC_STRUCTURE.data],	ax

	; wyślij komunikat
	xor	ecx,	ecx	; standardowy rozmiar komunikatu pod adresem w rejestrze RSI
	call	kernel_ipc_insert

	; przywróć oryginalne rejestry
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx

	; powrót z procedury
	ret

	macro_debug	"kernel_wm_ipc_keyboard"
