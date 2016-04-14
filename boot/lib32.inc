cout:
mov	ah,07h
xor	esi,esi
xor	edi,edi
mov	esi,[esp+8]
mov	edi,[esp+4]
cld
.1:
lodsb
test	al,al
jz	.2
mov	[gs:edi],ax
add	edi,2
jmp	.1
.2:
mov	dword	[esp+4],edi
ret

coutal:
push	ecx
push	edx
push	edi
mov	edi,[esp+16]
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
add	al,"A"
.2:
mov	[gs:edi],ax
add	edi,2
mov	al,dl
loop	.loop
mov	[esp+16],edi
pop	edi
pop	edx
pop	ecx
ret

coutint:
mov	eax,[esp+8]
shr	eax,24
mov	ebx,[esp+4]
push	ebx
call	coutal
pop	ebx
mov	eax,[esp+8]
shr	eax,16
push	ebx
call	coutal
pop	ebx
mov	eax,[esp+8]
shr	eax,8
push	ebx
call	coutal
pop	ebx
mov	eax,[esp+8]
push	ebx
call	coutal
pop	ebx
add	ebx,2
mov	ebx,[esp+4]
ret

cls:
mov	ecx,0ffffh
mov	edi,0
.loop:
mov	[gs:edi],byte	0
inc	edi
loop	.loop
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

mov	al,0feh
out	021h,al
mov	al,0ffh
out	0a1h,al
ret