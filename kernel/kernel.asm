selkernelcs	equ	8

extern	init
extern	main
extern	gdtptr
extern	idtptr

[section	.bss]
stackspace	resb	2048
stacktop:

[section	.text]
global	_start

_start:
	mov	esp,stacktop
	mov	edi,0

	sgdt	[gdtptr]
	call	init
	lgdt	[gdtptr]
	lidt	[idtptr]
	jmp	selkernelcs:_main

_main:
	call	main
	sti
fin	hlt
jmp	fin
