org	7c00h
stackbase	equ	7c00h
loaderbase	equ	9000h
loaderoffset	equ	100h

rootdirseccnt	equ	14
rootdirsecno	equ	19
fat1secno	equ	1
deltasecno	equ	17

jmp	short	lb_start
%include	"fat12hdr.inc"

lb_start:
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	ss,ax
	mov	sp,stackbase

	xor	dx,dx
	call	coutmsg

	call	rdsk
	
lb_fin:
jmp	loaderbase:loaderoffset

lb_data:
	rootdirszloop	dw	rootdirseccnt
	secno		dw	0
	odd		db	0
	fileflag	db	0
	fstsec		dw	0
	filename	db	"BOOT       ",0
			db	"LOADER  BIN",0
lb_msg:
	msglen	equ	8
	db	"Loading."

coutmsg:
	xor	ax,ax
	mov	al,dl
	shl	ax,3
	add	ax,lb_msg
	
	mov	bp,ax
	mov	ax,ds
	mov	es,ax

	mov	cx,msglen
	mov	ax,1301h
	mov	bx,7
	
	mov	dl,0
	int	10h
ret

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
	
	mov	ax,loaderbase
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
	
	mov	ax,loaderbase
	mov	es,ax
	mov	bx,loaderoffset
	mov	ax,[secno]
	mov	cl,1
	call	rdsec

	mov	si,filename
	add	si,bp
	mov	di,loaderoffset
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
	mov	ax,loaderbase
	mov	es,ax
	mov	bx,loaderoffset
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

times	1feh-($-$$)	db	0
dw	0aa55h
times	168000h-($-$$)	db	0
