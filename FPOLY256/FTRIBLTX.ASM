	TITLE	FASTRI - Fast triangle poly filling blitter
	NAME	FTRIBLTX


	COMMENT	$

	Name:		FTRIBLTX

		Written and (c) by Dave Stampe 9/11/91
		Not for commercial use, so get permission
		before marketing code using this stuff!
		For private PD use only.

		$

		.MODEL large

		.CODE
				; big table more eff. than masking
				; start byte lookup table
stmask:		REPT	80
		db	15,14,12,8
		ENDM
				; end byte lookup table
fnmask:         REPT	80
		db      1,3,7,15
		ENDM

	extrn	_dpaddr		; page base address

x1	equ	[bp+6]          ; arguments to _tpoly
y1	equ	[bp+8]
x2	equ	[bp+10]
y2	equ	[bp+12]
x3	equ	[bp+14]
y3 	equ	[bp+16]


vline   equ	[bp-2]   	; video base addr. of line
lines	equ	[bp-4]		; number of lines to fill
l_incr	equ	[bp-8]
r_incr	equ	[bp-12]
aswap   equ     [bp-16]		; plane mask reg. swap value

   ;
   ;   fastri(int x1,int y1, int x2, int y2, int x3, int y3)
   ;       vertices must be in CCW order!

		PUBLIC	_fastri

_fastri	proc	far

	.386
	push	bp
	mov	bp,sp
	sub	sp,16
	push	si
	push	di

	mov	eax,x1	; consider as 32-bit hash: look for top, then left
	mov	ebx,x2
	mov	ecx,x3
	cmp	ebx,eax
	jae	nrot1
	xchg	eax,ebx    ; rotate till top-left is at head of list
	xchg	ebx,ecx
	cmp	ebx,eax
	jae	donerot
	xchg	eax,ebx
	xchg	ebx,ecx
	jmp	donerot

nrot1:	cmp	ecx,eax
	jae	donerot
	xchg	eax,ecx
	xchg	ebx,ecx

donerot:
	mov	x1,eax
	mov	x2,ebx
	mov	x3,ecx

	cld
	mov	ax,03c5h		; setup DX adr. swap value
	mov	aswap,ax
	mov	ax,0a000h               ; set video segment
	mov	es,ax
	mov	al,y1
	mov	bl,80                   ; compute starting line adr
	mul	bl
	add	ax,WORD PTR ds:_dpaddr
	mov	vline,ax

	mov	ax,y1     ; determine config. of vertices: one of:
	cmp	ax,y3
	jz	flattop
	mov	ax,y2     ; 1  3      1      1      1
	cmp	ax,y3     ;                2          3
	jz	flatbot   ;  2      2  3     3     2
	jb	onleft
	jmp	onright

flatbot:
	movzx	ecx,word ptr y2       ; check for sliver poly
	sub	cx,y1
	jz	finished
	mov	lines,cx
	mov	ax,x2
	sub	ax,x1
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpl1    ; zero slope
	cmp	cx,1
	je	roundpl1
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpl1
	inc	eax
roundpl1:
	mov	l_incr,eax

	mov	ax,x3
	sub	ax,x1
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpl2    ; zero slope
	cmp	cx,1
	je	roundpl2
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpl2
	inc	eax
roundpl2:
	mov	r_incr,eax
	cmp	eax,l_incr
	jz	finished		; sliver: don't bother

	mov	dx,x1            ; compute L,R start
	mov	cx,dx
	shl	edx,16
	mov	bx,cx
	mov	esi,edx
	add	edx,08000h             ; force left side to round up

	call	near ptr trapezoid
	jmp	finished

flattop:
	movzx	ecx,word ptr y2       ; check for sliver poly
	sub	cx,y1
	jz	finished
	mov	lines,cx
	mov	ax,x2
	sub	ax,x1
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpl3    ; zero slope
	cmp	cx,1
	je	roundpl3    ; no slope needed if 1 line only
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpl3
	inc	eax
roundpl3:
	mov	l_incr,eax

	mov	ax,x2
	sub	ax,x3
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpl4    ; zero slope
	cmp	cx,1
	je	roundpl4    ; no slope needed if 1 line only
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpl4
	inc	eax
roundpl4:
	mov	r_incr,eax
	cmp	eax,l_incr
	jz	finished		; sliver: don't bother

	movzx	edx,word ptr x1             ; compute L,R start
	mov	bx,dx
	shl	edx,16
	add	edx,08000h             ; force left side to round up
	movzx	esi,word ptr x3
	mov	cx,si
	shl	esi,16

	call	near ptr trapezoid
	jmp	finished

onleft:
	movzx	ecx,word ptr y2       ; compute first slice height
	sub	cx,y1
	je	finished	; sliver poly
	mov	lines,cx
	mov	ax,x2
	sub	ax,x1
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpl5    ; zero slope
	cmp	cx,1
	je	roundpl5
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpl5
	inc	eax
roundpl5:
	mov	l_incr,eax

	movzx	ecx,word ptr y3
	sub	cx,y1
	mov	ax,x3
	sub	ax,x1
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpl6    ; zero slope
	cmp	cx,1
	je	roundpl6
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpl6
	inc	eax
roundpl6:
	mov	r_incr,eax
	cmp	eax,l_incr
	jz	finished		; sliver: don't bother

	mov	dx,x1            ; compute L,R start
	mov	cx,dx
	shl	edx,16
	mov	bx,cx
	mov	esi,edx
	add	edx,08000h             ; force left side to round up

	call	near ptr trapezoid
	push	esi	    ; save full precison right side

	movzx	ecx,word ptr y3       ; compute second slice height
	sub	cx,y2
	mov	lines,cx
	mov	ax,x3
	sub	ax,x2
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpl7    ; zero slope
	cmp	cx,1
	je	roundpl7
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpl7
	inc	eax
roundpl7:
	mov	l_incr,eax   ; change left increment

	pop	esi
	mov	ecx,esi	     ; restore right side
	shr	ecx,16

	movzx	edx,word ptr x2             ; compute L start
	mov	bx,dx
	shl	edx,16
	add	edx,08000h        ; force left side to round up

	call	near ptr trapezoid
	jmp	finished

onright:
	movzx	ecx,word ptr y2       ; compute first slice height
	sub	cx,y1
	je	finished
	mov	ax,x2
	sub	ax,x1
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpl8    ; zero slope
	cmp	cx,1
	je	roundpl8
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpl8
	inc	eax
roundpl8:
	mov	l_incr,eax

	movzx	ecx,word ptr y3       ; compute first slice height
	sub	cx,y1
	mov	lines,cx
	mov	ax,x3
	sub	ax,x1
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpl9    ; zero slope
	cmp	cx,1
	je	roundpl9
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpl9
	inc	eax
roundpl9:
	mov	r_incr,eax
	cmp	eax,l_incr
	jz	finished		; sliver: don't bother

	mov	dx,x1           ; compute L,R start
	mov	cx,dx
	shl	edx,16
	mov	bx,cx
	mov	esi,edx
	add	edx,08000h             ; force left side to round up

	call	near ptr trapezoid
	push	edx	    ; save full precison left side

	movzx	ecx,word ptr y2       ; compute second slice height
	sub	cx,y3
	mov	lines,cx
	mov	ax,x2
	sub	ax,x3
	movsx	eax,ax      ; conv. to double prec. << 16
	je	roundpla    ; zero slope
	cmp	cx,1
	je	roundpla
	cdq
	shl	eax,16	    ; (x2-x1)/(y2-y1)
	idiv	ecx
	cmp    	eax,0       ; round up if pos (neg already rounded up)
	jle	roundpla
	inc	eax
roundpla:
	mov	r_incr,eax   ; change left increment

	pop	edx
	mov	ebx,edx	     ; restore left side
	shr	ebx,16

	movzx	esi,word ptr x3             ; compute R start
	mov	cx,si
	shl	esi,16

	call	near ptr trapezoid
	jmp	finished


finished:
	pop	di                         ; exit code
	pop	si
	mov	sp,bp
	pop	bp
	ret

_fastri	endp



trapezoid:	; call with  bx = left, cx = right
		; edx = (left+0.5)>>16, esi = right<<16
		; vline, lines, l_incr, r_incr all set up

nextline:
		; start of fast h line blitter:
		;  bx=left side, cx=right side, vline=line start

	xchg	dx,aswap

	mov	al,BYTE PTR cs:[bx+stmask]  ; left mask
	shr	bx,2                        ; left address

	mov	di,cx
	mov	ah,BYTE PTR cs:[di+fnmask]  ; right mask
	shr	cx,2                        ; right address

	mov	di,vline		    ; start address
	add	di,bx
	sub	cx,bx                       ; number of bytes-1
	je	short onebyte
	jc	short doneline              ; clip trap

	out	dx,al
	stosb		                    ; mask first byte
	dec	cx                          ; mask rest
	mov	al,0ffh                     ; rep faster than test and jmp
	out	dx,al
	rep	stosb

	mov	al,ah
	out	dx,al
	mov	es:[di],ah                  ; mask last byte
	jmp	short doneline

onebyte:
	and	al,ah
	out	dx,al
	mov	es:[di],al		; single byte mask

doneline:
	xchg	dx,aswap
	mov	ax,80                   ; next line address
	add	vline,ax

	add	edx,DWORD PTR l_incr    ; step left, right edges
	add	esi,DWORD PTR r_incr
	mov	ebx,edx			; convert fixed pt to integer
	sar	ebx,16
	mov	ecx,esi
	sar	ecx,16

	dec	WORD PTR lines          ; done lines?
	jg	short nextline

donetri:                                ; finished all drawing
exit:
	retn

	end