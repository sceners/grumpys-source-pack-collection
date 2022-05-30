
	TITLE	VGALINE - Fast line drawing routine.
	NAME	VGALINE

	COMMENT	$

	Name:		VGALINE

		Written and (c) by Dave Stampe 9/11/91
		Not for commercial use, so get permission
		before marketing code using this stuff!
		For private PD use only.

		$



	COMMENT	$

	Name:		VGALINE

	Function:	Draw a line in VGA 200 line 256 color X mode

	Caller:		C:

			void vgaline(x1, y1, x2, y2, n);
				int	x1, y1, x2, y2;	/* pixel co-ords */
				int	n;		/* color */

			no checking on endpoints!

	Adapted from Richard Wilton's code (PC and PS/2 Video Systems).
	Modified to use VGA X mode
	Call setup_hdwe()  before drawing groups of lines

		$



		.MODEL large
		.CODE

		extrn _dpaddr

BytesPerLine	EQU		80

egapaddr	PROC	far

		mov	cl,bl
		push	dx

		mov	dx,BytesPerLine
		mul	dx

		pop	dx
		shr	bx,1
		shr	bx,1
		add	bx,ax
		add	bx,word ptr ds:_dpaddr

		and	cl,3
	      ;	xor	cl,3
		mov	al,1
		ret

egapaddr	endp



; Stack frame addressing - LARGE CODE MODEL

ARGx1		EQU	word ptr [bp+6]
ARGy1		EQU	word ptr [bp+8]
ARGx2		EQU	word ptr [bp+10]
ARGy2		EQU	word ptr [bp+12]
ARGn		EQU	byte ptr [bp+14]

VARvertincr	EQU	word ptr [bp-6]
VARincr1	EQU	word ptr [bp-8]
VARincr2	EQU	word ptr [bp-10]
VARroutine	EQU	word ptr [bp-12]

ByteOffsetShift	EQU	2
RMWbits		EQU	0

		PUBLIC	_vgaline


_vgaline	PROC	far
		.386

		push	bp		; Set up stack frame
		mov	bp,sp
		sub	sp,14
		push	si
		push	di

; set color

		mov		ax,0a000h
		mov		es,ax

		mov	bl,ARGn
		mov	bh,0ffh
		mov	al,es:[bx]

		mov	dx,03C5H	; setup for plane mask access

; check for vertical line

		mov	si,BytesPerLine
		mov	cx,ARGx2
		sub	cx,ARGx1
		jz	VertLine

; force x1 < x2

		jns	L01

		neg	cx

		mov	bx,ARGx2
		xchg	bx,ARGx1
		mov	ARGx2,bx

		mov	bx,ARGy2
		xchg	bx,ARGy1
		mov	ARGy2,bx

; calc dy = abs(y2 - y1)

L01:
		mov	bx,ARGy2
		sub	bx,ARGy1
		jz	HorizLine
		jns	L03

		neg	bx
		neg	si

; select appropriate routine for slope of line

L03:
		mov	VARvertincr,si
		mov	VARroutine,offset LoSlopeLine
		cmp	bx,cx
		jle	L04
		mov	VARroutine,offset HiSlopeLine
		xchg	bx,cx

; calc initial decision variable and increments

L04:
		shl	bx,1
		mov	VARincr1,bx
		sub	bx,cx
		mov	si,bx
		sub	bx,cx
		mov	VARincr2,bx

; calc first pixel address

		push	cx
		mov	ax,ARGy1
		mov	bx,ARGx1
		call	egapaddr
		mov	di,bx
		shl	al,cl
		mov	ah,al		; duplicate nybble
		shl	al,4
		add	al,ah
		mov	bl,al
		pop	cx
		inc	cx
		jmp	VARroutine

; routine for verticle lines

VertLine:
		mov	ax,ARGy1
		mov	bx,ARGy2
		mov	cx,bx
		sub	cx,ax
		jge	L31
		neg	cx
		mov	ax,bx

L31:
		inc	cx
		mov	bx,ARGx1
		push	cx
		call	egapaddr

		shl	al,cl
		out	dx,al
		pop	cx

; draw the line

L32:
		mov	es:[bx],ah
		add	bx,si
		loop	L32
		jmp	Lexit

; routine for horizontal line

HorizLine:
		push	ds

		mov	ax,ARGy1
		mov	bx,ARGx1
		call	egapaddr
		mov	di,bx
		mov	dl,0ffh
		shl	dl,cl

		mov	cx,ARGx2
		and	cl,3
		mov	dh,0feH
		shl	dh,cl
		not	dh

; determine byte offset of first and last pixel in line

		mov	ax,ARGx2
		mov	bx,ARGx1
		mov	cl,ByteOffsetShift

		shr	ax,cl
		shr	bx,cl
		mov	cx,ax
		sub	cx,bx

		mov	ax,dx
		mov	dx,03c5h

; set pixels in leftmost byte of line

		or	cx,cx
		jnz	L42
		and	ah,al
		jmp	short L44

L42:
		out     dx,al
		stosb
		dec	cx

; draw remainder of the line

L43:
		mov	al,0FFH
		out	dx,al
		rep	stosb

; set pixels in rightmost byte of line

L44:
		mov	al,ah
		out	dx,al
		mov     es:[di],bl
		pop	ds
		jmp	short Lexit


; routine for dy >= dx (slope <= 1)

LoSlopeLine:

L10:
		mov	al,bl

L11:
		or	al,bl
		rol	bl,1
		jc	L14

; bit mask not shifted out

		or	si,si
		jns	L12
		add	si,VARincr1
		loop	L11

		out	dx,al
		mov	es:[di],ah
		jmp	short Lexit

L12:
		add	si,VARincr2
		out	dx,al
		mov	es:[di],ah
		add	di,VARvertincr
		loop	L10
		jmp	short Lexit

; bit mask shifted out

L14:            out	dx,al
		stosb
		or	si,si
		jns	L15
		add	si,VARincr1
		loop	L10
		jmp	short Lexit

L15:
		add	si,VARincr2
		add	di,VARvertincr
		loop	L10
		jmp	short Lexit



; routine for dy > dx (slope > 1)

HiSlopeLine:
		mov	bx,VARvertincr

L21:            out	dx,al
		mov	es:[di],ah
		add	di,bx

L22:
		or	si,si
		jns	L23

		add	si,VARincr1
		loop	L21
		jmp	short Lexit

L23:
		add	si,VARincr2
		rol	al,1
		adc	di,0
lx21:		loop	L21

; return to caller

Lexit:
		pop	di
		pop	si
		mov	sp,bp
		pop	bp
		ret

_vgaline	endp




   ;
   ;	int clipper (lpoints far *lp)
   ;
   ;  /* returns 0 if unclipped, 1 if clipped, and -1 if invisible */
   ;
   ;  Improved assembly version of Sutherland-Cohen line clipper
   ;  Much more optimized than C version, and knows when to
   ;  stop clipping!
   ;

	PUBLIC	_clipper

x1	EQU	word ptr es:[bx]     ; elements in point array
y1	EQU	word ptr es:[bx+2]
x2	EQU	word ptr es:[bx+4]
y2	EQU	word ptr es:[bx+6]

left  equ 8                          ; clipping flag bits
above equ 4
right equ 2
below equ 1

	EXTRN	_l_clip              ; clipping recangle (assumed in ds)
	EXTRN	_r_clip
	EXTRN	_t_clip
	EXTRN	_b_clip


_clipper	proc	far

	.386				; required for jump length only

	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
	push	si
	push	di
	les	bx,dword ptr [bp+6]     ; setup access to points

	xor	di,di			; flag1 = 0

	mov	ax,x1
	cmp	ax,word ptr ds:_l_clip  ; set flag bits based on pos'n
	jge	short nleft1            ; for point 1
	or	di,8
nleft1:
	cmp	ax,word ptr ds:_r_clip
	jle	short nright1
	or	di,2
nright1:
	mov	ax,y1
	cmp	ax,word ptr ds:_t_clip
	jge	short ntop1
	or	di,4
ntop1:
	cmp	ax,word ptr ds:_b_clip
	jle	short nbot1
	or	di,1
nbot1:
	xor	si,si			; flag2 = 0

	mov	ax,x2
	cmp	ax,word ptr ds:_l_clip  ; set flag bits based on pos'n
	jge	short nleft2            ; for point 2
	or	si,8
nleft2:
	cmp	ax,word ptr ds:_r_clip
	jle	short nright2
	or	si,2
nright2:
	mov	ax,y2
	cmp	ax,word ptr ds:_t_clip
	jge	short ntop2
	or	si,4
ntop2:
	cmp	ax,word ptr ds:_b_clip
	jle	short nbot2
	or	si,1
nbot2:

	mov	ax,di			; check if all inside rect
	or	ax,si
	jne	short not_in_box
	xor	ax,ax                   ; return 0: not clipped
rexit:
	pop	di
	pop	si                      ; early return
	mov	sp,bp
	pop	bp
	ret

not_in_box:
	test	di,si                   ; check if all out of rect
	je	short needs_clipping
diagerr:                                ; too many clipping (diagonal)
	mov	ax,65535
	jmp	rexit                   ; return -1 (out of window)

needs_clipping:                         ; gotta do some serious work...

	or	di,di			; quick test if pt.1 OK
	jne	clip1
	jmp	do2

clip1:   				; clipping point 1:

	test	di,8                    ; left flag?
	je	short notleft1

doleft1:
   ;
   ;	    lp->y1 += (long)(lp->y2-lp->y1)*(l_clip-lp->x1)/(lp->x2-lp->x1);
   ;
	mov	cx,x2                   ; denominator: 0?
	sub	cx,x1
	je	dontleft1

	mov	ax,y2
	sub	ax,y1
	mov	dx,word ptr ds:_l_clip
	sub	dx,x1
	imul	dx
	idiv	cx
	add	y1,ax

dontleft1:
	mov	dx,word ptr ds:_l_clip           ; clip left
	mov	x1,dx

	mov	ax,y1                   ; check if vert. clipping needed
	cmp	ax,word ptr ds:_t_clip
	jl	doabove1
	cmp	ax,word ptr ds:_b_clip
	jg	dobelow1
	jmp	do2                     ; else check point 2

notleft1:
	test	di,2			; test if right needs clipping
	je	notright1

doright1:
   ;
   ;	   lp->y1 += (long)(lp->y2-lp->y1)*(r_clip-lp->x1)/(lp->x2-lp->x1);
   ;
	mov	cx,x2                   ; denominator: 0?
	sub	cx,x1
	je	dontright1

	mov	ax,y2
	sub	ax,y1
	mov	dx,word ptr ds:_r_clip
	sub	dx,x1
	imul	dx
	idiv	cx
	add	y1,ax

dontright1:
	mov	dx,word ptr ds:_r_clip           ; clip right
	mov	x1,dx

	mov	ax,y1
	cmp	ax,word ptr ds:_t_clip  ; check if vert. clipping needed
	jl	doabove1
	cmp	ax,word ptr ds:_b_clip
	jg	dobelow1
	jmp	do2

notright1:
	test	di,4			; test if top clip needed
	je	short notabove1

doabove1:
   ;
   ;	 lp->x1 += (long)(lp->x2-lp->x1)*(t_clip-lp->y1)/(lp->y2-lp->y1);
   ;
	mov	cx,y2                   ; denominator: 0?
	sub	cx,y1
	je	dontabove1

	mov	ax,x2
	sub	ax,x1
	mov	dx,word ptr ds:_t_clip
	sub	dx,y1
	imul	dx
	idiv	cx
	add	x1,ax

dontabove1:
	mov	dx,word ptr ds:_t_clip           ; clip top
	mov	y1,dx

	mov	ax,x1
	cmp	ax,word ptr ds:_l_clip  ; if hor. clip req, diagonal outside
	jl	diagerr ; doleft1
	cmp	ax,word ptr ds:_r_clip
	jg	diagerr ;doright1
	jmp	short do2

notabove1:
	test	di,1			; test if bottom needs clipping
	je	short do2

dobelow1:
   ;
   ;	   lp->x1 += (long)(lp->x2-lp->x1)*(b_clip-lp->y1)/(lp->y2-lp->y1);
   ;
	mov	cx,y2                   ; denominator: 0?
	sub	cx,y1
	je	dontbelow1

	mov	ax,x2
	sub	ax,x1
	mov	dx,word ptr ds:_b_clip
	sub	dx,y1
	imul	dx
	idiv	cx
	add	x1,ax

dontbelow1:
	mov	dx,word ptr ds:_b_clip
	mov	y1,dx

	mov	ax,x1
	cmp	ax,word ptr ds:_l_clip
	jl	diagerr ;oleft1
	cmp	ax,word ptr ds:_r_clip
	jg	diagerr ;doright1




do2:
	or	si,si		; same deal for point 2
	je	done2
	test	si,8
	je	short notleft2

doleft2:
   ;
   ;      lp->y2 += (long)(lp->y1-lp->y2)*(l_clip-lp->x2)/(lp->x1-lp->x2);
   ;
	mov	cx,x1                   ; denominator: 0?
	sub	cx,x2
	je	dontleft2

	mov	ax,y1
	sub	ax,y2
	mov	dx,word ptr ds:_l_clip
	sub	dx,x2
	imul	dx
	idiv	cx
	add	y2,ax

dontleft2:
	mov	dx,word ptr ds:_l_clip
	mov	x2,dx

	mov	ax,y2
	cmp	ax,word ptr ds:_t_clip
	jl	doabove2
	cmp	ax,word ptr ds:_b_clip
	jg	dobelow2
	jmp	done2

notleft2:
	test	si,2			; test if right needs clipping
	je	notright2

doright2:
   ;
   ;      lp->y2 += (long)(lp->y1-lp->y2)*(r_clip-lp->x2)/(lp->x1-lp->x2);
   ;
	mov	cx,x1                   ; denominator: 0?
	sub	cx,x2
	je	dontright2

	mov	ax,y1
	sub	ax,y2
	mov	dx,word ptr ds:_r_clip
	sub	dx,x2
	imul	dx
	idiv	cx
	add	y2,ax

dontright2:
	mov	dx,word ptr ds:_r_clip
	mov	x2,dx

	mov	ax,y2
	cmp	ax,word ptr ds:_t_clip
	jl	doabove2
	cmp	ax,word ptr ds:_b_clip
	jg	dobelow2
	jmp	done2

notright2:
	test	si,4			; test if top clip needed
	je	short notabove2

doabove2:
   ;
   ;      lp->x2 += (long)(lp->x1-lp->x2)*(t_clip-lp->y2)/(lp->y1-lp->y2);
   ;
	mov	cx,y1                   ; denominator: 0?
	sub	cx,y2
	je	dontabove2

	mov	ax,x1
	sub	ax,x2
	mov	dx,word ptr ds:_t_clip
	sub	dx,y2
	imul	dx
	idiv	cx
	add	x2,ax

dontabove2:
	mov	dx,word ptr ds:_t_clip
	mov	y2,dx

	mov	ax,x2
	cmp	ax,word ptr ds:_l_clip
	jl	diagerr ;doleft2
	cmp	ax,word ptr ds:_r_clip
	jg	diagerr ;doright2
	jmp	short done2

notabove2:
	test	si,1			; test if bottom needs clipping
	je	short done2

dobelow2:
   ;
   ;	  lp->x2 += (long)(lp->x1-lp->x2)*(b_clip-lp->y2)/(lp->y1-lp->y2);
   ;
	mov	cx,y1                   ; denominator: 0?
	sub	cx,y2
	je	dontbelow2

	mov	ax,x1
	sub	ax,x2
	mov	dx,word ptr ds:_b_clip
	sub	dx,y2
	imul	dx
	idiv	cx
	add	x2,ax

dontbelow2:
	mov	dx,word ptr ds:_b_clip
	mov	y2,dx

	mov	ax,x2
	cmp	ax,word ptr ds:_l_clip
	jl	diagerr ;doleft2
	cmp	ax,word ptr ds:_r_clip
	jg	diagerr ;doright2

done2:			; finished point 2
	mov	ax,1    ; return 1 for successful clipping
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret

_clipper	endp


	end