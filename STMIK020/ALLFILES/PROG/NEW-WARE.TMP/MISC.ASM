; miscellaneous routines

seed1	dw	1234
seed2	dw	5678
seed3	dw	1234h
seed4	dw	5678h

rand	PROC	NEAR
	push	bx
	push	cx
	push	dx
	mov	ax,ds:seed1
	mov	bx,ds:seed2
	mov	cx,ds:seed3
	mov	dx,ds:seed4
	add	ax,bx
	rol	ax,cl
	xor	ax,dx
	xchg	cl,ch
	add	bx,cx
	add	dx,bx
	add	cx,ax
	ror	bx,1
	sbb	ax,dx
	mov	ds:seed4,dx
	mov	ds:seed3,dx
	mov	ds:seed2,dx
	mov	ds:seed1,ax
	pop	dx
	pop	cx
	pop	bx
	ret
rand	ENDP

waitborder PROC NEAR
	push	ax
	push	dx
	mov	dx,3dah
wbr1:	in	al,dx
	test	al,8
	jnz	wbr1
wbr2:	in	al,dx
	test	al,8
	jz	wbr2
	pop	dx
	pop	ax
	ret
waitborder ENDP

tmppal	db	768 dup(0)

fadeoffpalette PROC NEAR
	mov	bh,2
	mov	ah,0
	jmp	fadepalette
fadeoffpalette ENDP

fadeonpalette PROC NEAR
	mov	bh,-2
	mov	ah,64
fadepalette:
	mov	dx,cs
	mov	ds,dx
	mov	es,dx

	mov	cx,32
fonp2:	push	ax
	push	cx
	push	si
	mov	di,OFFSET tmppal
	mov	cx,768
fonp1:	lodsb
	sub	al,ah
	jnc	fonp3
	xor	al,al
fonp3:	stosb
	loop	fonp1
	mov	si,OFFSET tmppal
	mov	cx,768/6/2
	sti
	call	waitborder
	cli
	mov	dx,3c8h
	xor	al,al
	out	dx,al
	inc	dx
	cli
fonp4:	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	loop	fonp4
	sti
	mov	cx,768/6/2
	call	waitborder
	cli
fonp5:	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	loop	fonp5
	sti
	pop	si
	pop	cx
	pop	ax
	add	ah,bh
	loop	fonp2
	ret
fadeonpalette ENDP

sine	MACRO ;ax=sin(ax)*32768
	push	bx
	and	ax,255
	shl	ax,1
	mov	bx,ax
	mov	ax,cs:sintable[bx]
	pop	bx
	ENDM

cosine	MACRO ;ax=cos(ax)*32768
	push	bx
	add	ax,64
	and	ax,255
	shl	ax,1
	mov	bx,ax
	mov	ax,cs:sintable[bx]
	pop	bx
	ENDM

getrasterline PROC NEAR
	;AX=scan line the VGA is in (requires ints set)
	cli
	xor	al,al
	out	43h,al
	in	al,40h
	mov	dl,al
	in	al,40h
	mov	dh,al
	shr	dx,1
	mov	ax,cs:frametime
	sub	ax,dx
	mov	cx,400
	mul	cx
	mov	cx,cs:frametime
	div	cx
	sti
	ret
getrasterline ENDP

tmpseg	dw	0
filerquit db	1
loadfile	PROC	NEAR
		;set: DX=offset to filename
		;set: AX=minimum paragraphs reserved
		;return: DX=segment of file
		mov	bp,ax
		mov	ax,cs
		mov	ds,ax ;set ds=cs
		mov	ah,3dh ;open file
		mov	al,0 ;read only
		int	21h
		jc	ferror
		mov	bx,ax ;store filehandle to bx
		;get length of file (seek to end)
		mov	ah,42h
		mov	al,2
		mov	cx,0
		mov	dx,0
		int	21h
		jc	ferror
		;get memory
		push	bx
		shr	dx,1
		rcr	ax,1
		shr	dx,1
		rcr	ax,1
		shr	dx,1
		rcr	ax,1
		shr	dx,1
		rcr	ax,1
		mov	bx,ax
		inc	bx ;one extra, just in case :-)
		cmp	bx,bp
		ja	loff1
		mov	bx,bp
loff1:		mov	ah,48h
		int	21h
		jc	ferror
		mov	cs:tmpseg,ax
		pop	bx
		;Seek file back to the beginning
		mov	ah,42h
		mov	al,0
		mov	cx,0
		mov	dx,0
		int	21h
		jc	ferror
		;read file
		mov	ds,cs:tmpseg
faga:		mov	ah,3fh
		mov	cx,32768
		mov	dx,0
		int	21h
		jc	ferror
		mov	dx,ds
		add	dx,800h
		mov	ds,dx
		cmp	ax,32768
		je	faga
		;close file
		mov	ah,3eh
		int	21h
		mov	dx,cs:tmpseg ;segment
		xor	ax,ax
		ret
ferror2:	mov	ax,1
		ret
ferror:		cmp	cs:filerquit,0
		je	ferror2
		mov	ax,4c01h
		int	21h
loadfile	ENDP

