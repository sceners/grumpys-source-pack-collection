; Tweaked mode graphic routines

gcurc	db	0

psetc	PROC	NEAR
	push	ax
	push	bx
	push	cx
	push	dx
	mov	al,cs:gcurc
	call	pset
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
psetc	ENDP

pset	PROC	NEAR
	;(dx,bx)=al, es must be 0a000h
	;uses/changes ax,bx,cx,dx
	mov	ch,al
	mov	cl,dl
	shl	bx,1
	mov	bx,cs:rows[bx]
	sar	dx,1
	sar	dx,1
	add	bx,dx
	and	cl,3
	mov	ax,102h
	mov	dx,03c4h
	shl	ah,cl
	out	dx,ax
	mov	es:[bx],ch
	ret
pset	ENDP

pget	PROC	NEAR
	;al=(dx,bx), es must be 0a000h
	;uses/changes ax,bx,cx,dx
	mov	cl,dl
	shl	bx,1
	mov	bx,cs:rows[bx]
	sar	dx,1
	sar	dx,1
	add	bx,dx
	and	cl,3
	mov	ah,cl
	mov	al,4h
	mov	dx,03ceh
	out	dx,ax
	mov	al,es:[bx]
	ret
pget	ENDP

;special plotters for starfield

smacro	MACRO	routine,xpos
	local	l1
	cmp	bx,64
	jnb	l1
	add	bx,136
	add	dx,xpos
	jmp	routine
l1:	sub	bx,64
	jmp	routine
	ENDM
	
spset	PROC	NEAR
	smacro	pset,ds:winxpos
spset	ENDP

spget	PROC	NEAR
	smacro	pget,ds:winxpos
spget	ENDP

ospset	PROC	NEAR
	smacro	pset,ds:owinxpos
ospset	ENDP

ospget	PROC	NEAR
	smacro	pget,ds:owinxpos
ospget	ENDP

;line variables
xdif	dw	0
ydif	dw	0
xabs	dw	0
yabs	dw	0
xsgn	dw	0
ysgn	dw	0
xtmp	dw	0
ytmp	dw	0
gcurx	dw	0
gcury	dw	0

line	PROC	NEAR
	;draw line from (ax,cx) to (dx,bx) with color (color)
	mov	es,cs:vram
	mov	cs:gcurx,ax
	mov	cs:gcury,cx
	mov	ax,cs
	mov	ds,ax
	jmp	lineto
line	ENDP

lineto	PROC	NEAR
	;draw line from (gcurx,gcury) to (dx,bx) with color (color)
	;requires ds=cs, es=vram, changes: ax
	push	cx
	push	si
	push	di
	push	bp
	push	dx
	push	bx

	jmp	lt5
	;set insider point as begin of line
;	cmp	dx,vxnum1
;	ja	lt4
;	cmp	bx,vynum1
;	ja	lt4
;	jmp	lt5 ;dx,bx is inside, no changes
;lt4:	;dx,bx outside, swap
;	xchg	bx,ds:gcury
;	xchg	dx,ds:gcurx
;	;check with new bx,dx
;	cmp	dx,vxnum1
;	ja	lt6
;	cmp	bx,vynum1
;	ja	lt6
;	jmp	lt5 ;dx,bx is inside
;
;lt6:	;both ends outside! Cut 'em here, not ready yet

lt5:	mov	ds:xtmp,dx
	mov	ds:ytmp,bx
	;calc differencies xdif,ydif (+-) & abs difs, xabs,yabs (+)
	;and signs xsgn,ysgn (-1/0/1)
	xor	cx,cx
	mov	ax,ds:gcurx
	sub	ax,dx
	mov	ds:xdif,ax
	or	ax,ax
	je	lt1
	inc	cx
	test	ax,32768
	jz	lt1
	neg	ax
	dec	cx
	dec	cx
lt1:	mov	ds:xabs,ax
	mov	ds:xsgn,cx

	xor	cx,cx
	mov	ax,ds:gcury
	sub	ax,bx
	mov	ds:ydif,ax
	or	ax,ax
	je	lt2
	inc	cx
	test	ax,32768
	jz	lt2
	neg	ax
	dec	cx
	dec	cx
lt2:	mov	ds:yabs,ax
	mov	ds:ysgn,cx

	;which is bigger?
	cmp	ax,ds:xabs
	ja	lt3

	;xbigger

	;calc addl/h (si,di)
	jne	lt9
	;1/1 addition, 45 degree curve
	cmp	ax,0
	jne	lt15
	mov	dx,cs:gcurx
	mov	bx,ds:gcury
	call	psetc
	jmp	lt10
lt15:	mov	di,ds:ysgn
	mov	si,65535
	jmp	lt10
lt9:	mov	dx,ax ;dx=yabs
	xor	ax,ax
	div	ds:xabs ;ax=lowadd
	mov	si,ax
	mov	di,ds:ysgn

lt10:	mov	ax,32767
	mov	bp,ds:xsgn
	mov	cx,ds:xabs
	inc	cx
	mov	dx,ds:xtmp
	mov	bx,ds:ytmp
lt7:	call	psetc
	add	dx,bp ;xsgn
	add	ax,si ;yaddl
	jnc	lt8
	add	bx,di ;ysgn
lt8:	loop	lt7

	jmp	lt0


lt3:	;ybigger

	mov	dx,ds:xabs
	xor	ax,ax
	div	ds:yabs ;ax=lowadd
	mov	si,ax
	mov	di,ds:xsgn

lt12:	mov	ax,32767
	mov	bp,ds:ysgn
	mov	cx,ds:yabs
	inc	cx
	mov	dx,ds:xtmp
	mov	bx,ds:ytmp
lt13:	call	psetc
	add	bx,bp ;ysgn
	add	ax,si ;xaddl
	jnc	lt14
	add	dx,di ;xsgn
lt14:	loop	lt13
	
lt0:	pop	bx
	pop	dx
	mov	ds:gcurx,dx
	mov	ds:gcury,bx
	pop	bp
	pop	di
	pop	si
	pop	cx
	ret
lineto	ENDP

; UFF font routines

printc2	PROC	NEAR
	;prints a letter to DX,BX from cs:demoseg;AL=letter,cs:printcadd=coladd
	push	bx
	push	dx
	mov	es,cs:vram
	mov	ds,cs:fontseg
	mov	cx,ds:[12]
	mov	bl,al
	xor	bh,bh
	mov	bp,ds:[bx+16+512]
	and	bp,255
	shl	bx,1
	mov	ax,ds
	cmp	word ptr ds:[bx+16],0
	jne	prc4
	pop	dx
	pop	bx
	jmp	prc5
prc4:	add	ax,ds:[bx+16]
	mov	ds,ax
	xor	si,si
	pop	dx
	pop	bx
prc1:	push	dx
	push	bx
	push	cx
	shl	bx,1
	mov	bx,cs:rows[bx]
	mov	cx,bp
	mov	al,dl
	sar	dx,1
	sar	dx,1
	add	bx,dx
	and	al,3
	cmp	al,1
	je	prc21
	cmp	al,2
	je	prc22
	cmp	al,3
	je	prc23
prc2:	mov	ax,102h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prc201
	mov	es:[bx],al
prc201:	dec	cx
	jz	prc3
prc21:	mov	ax,202h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prc211
	mov	es:[bx],al
prc211:	dec	cx
	jz	prc3
prc22:	mov	ax,402h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prc221
	mov	es:[bx],al
prc221:	dec	cx
	jz	prc3
prc23:	mov	ax,802h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prc231
	mov	es:[bx],al
prc231:	inc	bx
	dec	cx
	jz	prc3
	jmp	prc2
prc3:	pop	cx
	pop	bx
	pop	dx
	inc	bx
	loop	prc1x
prc5:	add	dx,bp
prc91:	ret
prc1x:	jmp	prc1
printc2	ENDP

printc	PROC	NEAR
	;prints a letter to DX,BX from cs:demoseg;AL=letter,cs:printcadd=coladd
	push	bx
	push	dx
	mov	es,cs:vram
	mov	ds,cs:fontseg
	mov	cx,ds:[12]
	mov	bl,al
	xor	bh,bh
	mov	bp,ds:[bx+16+512]
	and	bp,255
	shl	bx,1
	mov	ax,ds
	cmp	word ptr ds:[bx+16],0
	jne	prd4
	pop	dx
	pop	bx
	jmp	prd5
prd4:	add	ax,ds:[bx+16]
	mov	ds,ax
	xor	si,si
	pop	dx
	pop	bx
prd1:	push	dx
	push	bx
	push	cx
	shl	bx,1
	mov	bx,cs:rows[bx]
	mov	cx,bp
	mov	al,dl
	sar	dx,1
	sar	dx,1
	add	bx,dx
	and	al,3
	cmp	al,1
	je	prd21
	cmp	al,2
	je	prd22
	cmp	al,3
	je	prd23
prd2:	mov	ax,102h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prd201
	add	al,cs:printcadd
	and	al,63+128
	mov	es:[bx],al
prd201:	dec	cx
	jz	prd3
prd21:	mov	ax,202h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prd211
	add	al,cs:printcadd
	and	al,63+128
	mov	es:[bx],al
prd211:	dec	cx
	jz	prd3
prd22:	mov	ax,402h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prd221
	add	al,cs:printcadd
	and	al,63+128
	mov	es:[bx],al
prd221:	dec	cx
	jz	prd3
prd23:	mov	ax,802h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prd231
	add	al,cs:printcadd
	and	al,63+128
	mov	es:[bx],al
prd231:	inc	bx
	dec	cx
	jz	prd3
	jmp	prd2
prd3:	pop	cx
	pop	bx
	pop	dx
	inc	bx
	loop	prd1x
prd5:	add	dx,bp
	inc	dx
prd91:	ret
prd1x:	jmp	prd1
printc	ENDP

printclr PROC	NEAR
	;clears a letter to DX,BX from cs:demoseg;AL=letter,cs:printcadd=coladd
	push	bx
	push	dx
	mov	es,cs:vram
	mov	ds,cs:fontseg
	mov	cx,ds:[12]
	mov	bl,al
	xor	bh,bh
	mov	bp,ds:[bx+16+512]
	and	bp,255
	shl	bx,1
	mov	ax,ds
	cmp	word ptr ds:[bx+16],0
	jne	prdl4
	pop	dx
	pop	bx
	jmp	prdl5
prdl4:	add	ax,ds:[bx+16]
	mov	ds,ax
	xor	si,si
	pop	dx
	pop	bx
prdl1:	push	dx
	push	bx
	push	cx
	shl	bx,1
	mov	bx,cs:rows[bx]
	mov	cx,bp
	mov	al,dl
	sar	dx,1
	sar	dx,1
	add	bx,dx
	and	al,3
	cmp	al,1
	je	prdl21
	cmp	al,2
	je	prdl22
	cmp	al,3
	je	prdl23
prdl2:	mov	ax,102h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prdl201
	xor	al,al
	mov	es:[bx],al
prdl201:	dec	cx
	jz	prdl3
prdl21:	mov	ax,202h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prdl211
	xor	al,al
	mov	es:[bx],al
prdl211:	dec	cx
	jz	prdl3
prdl22:	mov	ax,402h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prdl221
	xor	al,al
	mov	es:[bx],al
prdl221:	dec	cx
	jz	prdl3
prdl23:	mov	ax,802h
	mov	dx,03c4h
	out	dx,ax
	lodsb
	cmp	al,255
	je	prdl231
	xor	al,al
	mov	es:[bx],al
prdl231:	inc	bx
	dec	cx
	jz	prdl3
	jmp	prdl2
prdl3:	pop	cx
	pop	bx
	pop	dx
	inc	bx
	loop	prdl1
prdl5:	add	dx,bp
	inc	dx
	ret
printclr ENDP

getfontwidth PROC NEAR
	;clears a letter to DX,BX from cs:demoseg;AL=letter,cs:printcadd=coladd
	push	ds
	push	bx
	mov	ds,cs:fontseg
	mov	bl,al
	xor	bh,bh
	mov	al,ds:[bx+16+512]
	xor	ah,ah
	pop	bx
	pop	ds
	ret
getfontwidth ENDP

