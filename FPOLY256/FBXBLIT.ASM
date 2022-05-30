	TITLE	FPBLIT - Fast poly filling blitter
	NAME	FPBLIT


	COMMENT	$

	Name:		FPBLIT

		Written and (c) by Dave Stampe 9/11/91
		Not for commercial use, so get permission
		before marketing code using this stuff!
		For private PD use only.

		$

	COMMENT	$

	Name:		tpoly

	Caller:		C:

			int tpoly(int x1, int x2, long l_incr, long r_incr,
				  int y1, int y3, int hold);

			x1 = left side start, x2 = right side start
			 if 0x8000, uses end of last poly's side for cont.
			y1 = top, y2 = 1+bottom of poly slice
			l_incr, r_incr = 2^16 times slope (add to x each line)
			hold: 0 = normal, 1 = make sure left is OK
					  2 = make sure right is OK
					  (for continuation)

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


x1	equ	[bp+6]          ; arguments to _tpoly
x2	equ	[bp+8]
l_incr	equ	[bp+10]
r_incr	equ	[bp+14]
y1	equ	[bp+18]
y3	equ	[bp+20]
hold	equ	[bp+22]

vline   equ	[bp-2]   	; video base addr. of line
lines	equ	[bp-4]		; number of lines to fill
clipped	equ	[bp-6]		; flags clipped poly (needs end recalc)
aswap	equ	[bp-8]

	extrn	_l_hold         ; holds full res. L, R. point
	extrn	_r_hold

	extrn	_t_clip         ; clipping rect. sides
	extrn	_b_clip
	extrn	_l_clip
	extrn	_r_clip

	extrn	_dpaddr		; page base address

   ;
   ;	tpoly(int x1,int x2, long l_incr, long r_incr,
   ;				 int y1, int y3, int hold)
   ;

		PUBLIC	_tpoly

_tpoly	proc	far

	.386
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
	push	di

	mov	word ptr clipped,0

	mov	ax,word ptr y3	       ; if(y3-y1<1)return(-1);
	sub	ax,word ptr y1
	cmp	ax,1
	jge	short continue

	mov	ax,65535               ; return -1 on bad args
	jmp	exit

continue:
	mov	ax,03c5h		; setup DX adr. swap value
	mov	aswap,ax
	cld
	mov	ax,0a000h              ; set video segment
	mov	es,ax

	mov	edx,DWORD PTR ds:_l_hold
	mov	ax,x1
	cmp	ax,8000h               ; old or new left side
	je	short nlload
	mov	dx,ax
	shl	edx,16
	add	edx,08000h             ; force left side to round up
nlload:
	mov	esi,DWORD PTR ds:_r_hold
	mov	ax,x2
	cmp	ax,8000h               ; old or new right
	je	short nrload
	mov	si,ax
	shl	esi,16
nrload:
	mov	bx,y1
	cmp	bx,WORD PTR ds:_b_clip   ; trivial vertical clip tests
	jg	clipall
	mov	ax,y3
	cmp	ax,WORD PTR ds:_t_clip
	jle	short clipall
	cmp	ax,WORD PTR ds:_b_clip    ; test if next-slice update
	jl	short okbot               ; will be require
	inc	WORD PTR clipped
	mov	ax,WORD PTR ds:_b_clip
	mov	y3,ax
okbot:
					; test if top needs clipping
	sub	bx,WORD PTR ds:_t_clip
	jge	short oktop
	mov	ax,WORD PTR ds:_t_clip
	mov	y1,ax
	neg	bx                      ; adjust left, right sides for
	movzx	ebx,bx                  ; top of screen

	push	edx
	mov	eax,DWORD PTR r_incr    ;advance right top
	imul	eax,ebx
	add	esi,eax

	mov	eax,DWORD PTR l_incr    ; advance left top
	imul	eax,ebx
	pop	edx
	add	edx,eax

oktop:
	mov	ax,y3                   ; compute # lines
	sub	ax,y1
	jle	short clipall           ; bad clip trap

	mov	lines,ax
	mov	al,y1
	mov	bl,80                   ; compute starting line adr
	mul	bl
	add	ax,WORD PTR ds:_dpaddr
	mov	vline,ax

	mov	ebx,edx                 ; convert fixed-pt to integer
	sar	ebx,16
	mov	ecx,esi
	sar	ecx,16
	jl	short doneline          ; preclip left trap

	cmp	bx,WORD PTR ds:_l_clip  ; clip left
	jge	short iclipl
	mov	bx,WORD PTR ds:_l_clip

iclipl:
	cmp	cx,WORD PTR ds:_r_clip  ; clip right
	jle	short nextline
	mov	cx,WORD PTR ds:_r_clip
	jmp	short nextline

clipall:
	inc	WORD PTR clipped        ; mark as clipped (none showing)
	jmp	donetri

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
	add	edx,DWORD PTR l_incr    ; step left, right edges
	add	esi,DWORD PTR r_incr

	dec	WORD PTR lines          ; done lines?
	jle	short donetri
	mov	ax,80                   ; next line address
	add	vline,ax

	mov	ebx,edx			; convert fixed pt to integer
	sar	ebx,16
	mov	ecx,esi
	sar	ecx,16
	jl	short doneline          ; left preclip
	cmp	bx,WORD PTR ds:_l_clip  ; clip left edge
	jge	short nclipl
	mov	bx,WORD PTR ds:_l_clip

nclipl:
	cmp	cx,WORD PTR ds:_r_clip  ; clip right edge
	jle	short nextline
	mov	cx,WORD PTR ds:_r_clip
	jmp	nextline

donetri:                                ; finished all drawing
	mov	edi,edx
	test	WORD PTR hold,0ffh      ; check if L,R pos'ns need
	je	short nofixup           ; fixing because of clipping
	test	WORD PTR clipped, 0ffh
	je	short nofixup

	mov	bx,y3                   ; number of lines vertically
	sub	bx,y1
	movzx	ebx,bx

	test	WORD PTR hold,2		; right update needed?
	je	short nofixrt           ; (use hold flags as this is an
	mov	eax,DWORD PTR r_incr    ;  expensive operation)
	imul	eax,ebx
	mov	si,x1
	shl	esi,16
	cmp	esi,80000000h              ; add to old edge or new edge?
	jne	short rlold
	mov	esi,DWORD PTR ds:_r_hold
rlold:
	add	esi,eax

nofixrt:
	test	WORD PTR hold,1            ; left update needed?
	je	short nofixup
	mov	eax,DWORD PTR l_incr
	imul	eax,ebx
	mov	di,x2
	shl	edi,16
	add	edi,8000h
	cmp	edi,80008000h              ; add to old or new edge?
	jne	short llold
	mov	edi,DWORD PTR ds:_l_hold
llold:
	add	edi,eax

nofixup:
	mov	DWORD PTR ds:_l_hold,edi   ; store edge points in case
	mov	DWORD PTR ds:_r_hold,esi   ; needed for next poly slice
exit:
	pop	di                         ; exit code
	pop	si
	mov	sp,bp
	pop	bp
	ret

_tpoly	endp


   ;
   ;	long compute_slope(int x1, int y1, int x2, int y2)
   ;

y1	equ	[bp+8]
y2	equ	[bp+12]
x1	equ	[bp+6]
x2	equ	[bp+10]

	PUBLIC	_compute_slope

_compute_slope	proc	far

	push	bp		; computes slope (dy incrementor)
	mov	bp,sp           ; with 16-bit underflow
	sub	sp,4
	.386
	xor	ecx,ecx
	mov	cx,y2
	sub	cx,y1
	je	short @5@386	; skip if zero divide (special case)
	mov	ax,x2           ; detected later by y1==y2 test
	sub	ax,x1
	cwd
	movsx	eax,ax  	; (x2-x1)/(y2-y1)
	movsx	edx,dx
	shl	eax,16
	idiv	ecx
	cmp    	eax,0   	; round up if pos (neg already rounded up)
	jle	short @5@386
	inc	eax
@5@386:                         ; return long value (286 style)
	mov	[bp-4],eax
	mov	dx,word ptr [bp-2]
	mov	ax,word ptr [bp-4]
	mov	sp,bp
	pop	bp
	ret

_compute_slope	endp


	end


