global	coutstr
global	coutal
global	coutint
global	clear
global	memcpy
global	i8259a

coutstr:
	push	ebp
	mov	ebp,esp
	
	mov	esi,[ebp+8]		;str
	mov	ah,byte	[esp+12]	;color
.1:
	lodsb
	test	al,al
	jz	.2
	cmp	al,0ah
	jnz	.3
	push	eax
	mov	eax,edi
	mov	bl,0a0h
	div	bl
	and	eax,0ffh
	inc	eax
	mov	bl,0a0h
	mul	bl
	mov	edi,eax
	pop	eax
	jmp	.1
.3:
	mov	word	[gs:edi],ax
	add	edi,2
	jmp	.1
.2:
	mov	eax,edi
	pop	ebp
ret

coutal:
	push	ebp
	mov	ebp,esp
	push	ecx

	mov	ah,07h
	mov	dl,al
	shr	al,4
	mov	ecx,2
.loop:
	and	al,0fh
	cmp	al,9
	ja	.1
	add	al,"0"
	jmp	.2
.1:
	sub	al,0ah
	add	al,"a"
.2:
	mov	[gs:edi],ax
	add	edi,2
	mov	al,dl
	loop	.loop

	pop	ecx
	pop	ebp
ret

coutint:
	push	ebp
	mov	ebp,esp
	push	eax

	mov	eax,[ebp+8]
	shr	eax,24
	call	coutal
	mov	eax,[ebp+8]
	shr	eax,16
	call	coutal
	mov	eax,[ebp+8]
	shr	eax,8
	call	coutal
	mov	eax,[ebp+8]
	call	coutal

	pop	eax
	pop	ebp
ret

clear:
	push	edi
	mov	ecx,0ffffh
	mov	edi,0
.loop:
	mov	[gs:edi],byte	0
	inc	edi
	loop	.loop
	pop	edi
ret

memcpy:
	push	ebp
	mov	ebp,esp

	push	esi
	push	edi
	push	ecx

	mov	edi,[ebp+8]	;destination
	mov	esi,[ebp+12]	;source
	mov	ecx,[ebp+16]	;counter
.1:
	cmp	ecx,0
	jz	.2

	mov	al,[ds:esi]
	inc	esi
	mov	byte	[es:edi],al
	inc	edi

	dec	ecx
	jmp	.1
.2:
	mov	eax,[ebp+8]

	pop	ecx
	pop	edi
	pop	esi
	mov	esp,ebp
	pop	ebp
ret

i8259a:
	mov	al,011h
	out	020h,al
	out	0a0h,al
	mov	al,020h
	out	021h,al
	mov	al,028h
	out	0a1h,al
	mov	al,004h
	out	021h,al
	mov	al,002h
	out	0a1h,al
	mov	al,001h
	out	021h,al
	out	0a1h,al

	mov	al,[esp+4]
	out	021h,al
	mov	al,[esp+8]
	out	0a1h,al
ret
