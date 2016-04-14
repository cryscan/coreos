org	0100h
loaderbase 	equ	9000h
loaderoffset	equ	0100h
loaderbasepa	equ	loaderbase	*	10h
kernelbase	equ	8000h
kerneloffset	equ	0
kernelbasepa	equ	kernelbase	*	10h
kernelentpa	equ	030400h
stackbase	equ	0100h

rootdirseccnt	equ	14
rootdirsecno	equ	19
fat1secno	equ	1
deltasecno	equ	17

jmp	short	lb_start
%include	"fat12hdr.inc"
%include	"pm.inc"

lb_gdt:		desc	0,0,0
lb_desc_flat_c	desc	0,0fffffh,DA_CR|DA_32|DA_LIMIT_4K
lb_desc_flat_rw	desc	0,0fffffh,DA_DRW|DA_32|DA_LIMIT_4K
lb_desc_video	desc	0b8000h,0ffffh,DA_DRW|DA_DPL3
gdtlen	equ	$-lb_gdt
gdtptr	dw	gdtlen-1
	dd	loaderbasepa+lb_gdt
selflatc	equ	lb_desc_flat_c-lb_gdt
selflatrw	equ	lb_desc_flat_rw-lb_gdt
selvideo	equ	lb_desc_video-lb_gdt

lb_start:
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	ss,ax
	mov	sp,stackbase
	call	rdsk

	lgdt	[gdtptr]
	cli
	
	in	al,92h
	or	al,2
	out	92h,al

	mov	eax,cr0
	or	eax,1
	mov	cr0,eax
	jmp	dword	selflatc:(loaderbasepa+lb_code_32)
	
lb_data:
	rootdirszloop	dw	rootdirseccnt
	secno		dw	0
	odd		db	0
	fileflag	db	0
	fstsec		dw	0
	filename	db	"KERNEL     ",0
			db	"KERNEL  BIN",0

lb_fin	hlt
jmp	lb_fin

rdsec:
	push	bp
	mov	bp,sp
	sub	esp,2
	mov	byte	[bp-2],cl

	push	bx
	mov	bl,[bpb_secpertrk]
	div	bl
	inc	ah
	mov	cl,ah	;sec

	mov	dh,al
	shr	al,1
	mov	ch,al	;cylinder
	and	dh,1	;head
	pop	bx

	mov	dl,[bs_drvnum]
.rd:
	mov	ah,2
	mov	al,byte	[bp-2]
	int	13h
	jc	.rd
	
	add	esp,2
	pop	bp
ret

rdfat:
	push	es
	push	bx
	push	ax
	
	mov	ax,kernelbase
	sub	ax,0100h
	mov	es,ax
	pop	ax

	mov	byte	[odd],0
	mov	bx,3
	mul	bx
	mov	bx,2
	div	bx

	cmp	dx,0
	jz	.lb_even
	mov	byte	[odd],1
.lb_even:
	xor	dx,dx
	mov	bx,[bpb_bytspersec]
	div	bx
	push	dx
	mov	bx,0
	add	ax,fat1secno
	mov	cl,2
	call	rdsec
	
	pop	dx
	add	bx,dx
	mov	ax,[es:bx]
	cmp	byte	[odd],1
	jnz	.lb_even2
	shr	ax,4
.lb_even2:
	and	ax,0fffh
.lb_ok:
	pop	bx
	pop	es
ret

rdsk:
	xor	ah,ah
	xor	dl,dl
	int	13h

	mov	bp,0
	mov	word	[secno],rootdirsecno
.lb_rootdirsec:
	cmp	word	[rootdirszloop],0
	jz	.lb_notfound
	dec	word	[rootdirszloop]
	
	mov	ax,kernelbase
	mov	es,ax
	mov	bx,kerneloffset
	mov	ax,[secno]
	mov	cl,1
	call	rdsec

	mov	si,filename
	add	si,bp
	mov	di,kerneloffset
	cld
	mov	dx,10h
.lb_load:
	cmp	dx,0
	jz	.lb_nextsec
	dec	dx

	mov	cx,11
.lb_cmp:
	cmp	cx,0
	jz	.lb_found
	dec	cx
	lodsb
	cmp	al,byte	[es:di]
	jz	.lb_go_on
	jmp	.lb_different
.lb_go_on:
	inc	di
	jmp	.lb_cmp
.lb_different:
	and	di,0ffe0h
	add	di,20h
	mov	si,filename
	add	si,bp
	jmp	.lb_load
.lb_nextsec:
	add	word	[secno],1
	jmp	.lb_rootdirsec
.lb_notfound:
	jmp	lb_fin
.lb_found:
	mov	ax,rootdirseccnt
	and	di,0ffe0h
	add	di,01ah
	mov	cx,word	[es:di]
	push	cx
	add	cx,ax
	add	cx,deltasecno
	mov	word	[fstsec],cx
	mov	ax,kernelbase
	mov	es,ax
	mov	bx,kerneloffset
	mov	ax,cx
.lb_go_on_read:
	push	ax
	push	bx
	mov	ah,0Eh
	mov	al,"."
	mov	bl,0Fh
	int	10h
	pop	bx
	pop	ax

	mov	cl,1
	call	rdsec
	pop	ax
	call	rdfat
	cmp	ax,0fffh
	jz	.lb_loaded
	push	ax
	mov	dx,rootdirseccnt
	add	ax,dx
	add	ax,deltasecno
	add	bx,[bpb_bytspersec]
	jmp	.lb_go_on_read
.lb_loaded:
	cmp	byte	[fileflag],1
	je	.lb_real_loaded
	mov	ax,word	[fstsec]
	mov	word	[secno],ax
	inc	byte	[fileflag]
	add	bp,12
	jmp	.lb_rootdirsec
.lb_real_loaded:
ret

[section	.32]
align	32
[bits	32]
lb_code_32:
	mov	ax,selvideo
	mov	gs,ax
	mov	ax,selflatrw
	mov	ds,ax
	mov	es,ax
	mov	fs,ax
	mov	ss,ax
	mov	esp,stacktop
	call	kernel

	jmp	selflatc:kernelentpa

lb_stack:	times	1000h	db	0
stacktop	equ	loaderbasepa + $

kernel:
	xor	esi,esi
	mov	cx,word	[kernelbasepa+2ch]
	movzx	ecx,cx
	mov	esi,[kernelbasepa+1ch]
	add	esi,kernelbasepa
.begin:
	mov	eax,[esi+0]
	cmp	eax,0
	jz	.fin
	push	dword	[esi+10h]
	mov	eax,[esi+4]
	add	eax,kernelbasepa
	push	eax
	push	dword	[esi+8]
	call	memcpy
	add	esp,12
.fin:
	add	esi,20h
	dec	ecx
	jnz	.begin
ret

memcpy:
	push	ebp
	mov	ebp,esp

	push	esi
	push	edi
	push	ecx

	mov	edi,[ebp+8]	;destination
	mov	esi,[ebp+12]	;source
	mov	ecx,[ebp+16]	;size
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
