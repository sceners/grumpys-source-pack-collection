	TITLE	GSPPT - 320x200x16 mode support
	NAME	GSPPT


	COMMENT	$

	Name:		GXSPPT

		Written and (c) by Dave Stampe 9/11/91
		Not for commercial use, so get permission
		before marketing code using this stuff!
		For private PD use only.

		$

		.MODEL large
		.CODE

 ;
 ; void vsync();		/* waits for vert. sync pulse */
 ;
		PUBLIC	_vsync

_vsync	proc	far

	push	bp
	mov	bp,sp
	mov		dx,03DAh
	in		al,dx		; test if 0
	test		al,8
	je	short @11@218
@11@122:
	in		al,dx
	nop
	test		al,8            ; wait for 0
	jne	short @11@122
@11@218:
	in		al,dx
	nop
	test		al,8            ; wait for 1
	je	short @11@218
	pop	bp
	ret

_vsync	endp

 ;
 ; void setup_hdwe(int mode);	/* sets up VGA for line, poly draw */
 ;                              /* modes are: 0=PUT, 1=OR,         */
 ;				/*	      2=AND, 3=XOR         */
 ;				/* only PUT for X-mode             */

		PUBLIC	_setup_hdwe

_setup_hdwe	proc	far

	push	bp
	mov	bp,sp
	mov	dx,03CEH
	mov	ax,00008h               ; all display copy bits
	out	dx,ax

	mov	dx,03c4h		; prepare plane mask reg. for access
	mov	ax,0f02h
	out	dx,ax
	pop	bp
	ret

_setup_hdwe	endp

 ;
 ; void reset_hdwe()
 ;

		PUBLIC	_reset_hdwe

_reset_hdwe	proc	far

	push	bp
	mov	bp,sp
	mov	dx,03CEH
	mov	ax,0FF08h               ; all CPU data bits
	out	dx,ax

	mov	dx,03c4h		; prepare plane mask reg. for access
	mov	ax,0f02h
	out	dx,al
	pop	bp
	ret

_reset_hdwe	endp

 ;
 ; int clr_page(int page, int color);	/* clear page to color */
 ;
 ;  /* returns 0 if OK, 1 if bad page */

		PUBLIC	_clr_page

_clr_page	proc	far

	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
	push	di
	cld
	mov     cx,word ptr [bp+6]
	cmp	cx,3		       ; check for valid page
	jle	short @14@74
	mov	ax,65535
	jmp	short @14@482
@14@74:
	call	far ptr _setup_hdwe     ; reset to default VGA mode
	cld
	mov	ax,0A000h
	mov	es,ax
	mov	bl,BYTE PTR [bp+8]
	mov	bh,0ffh			; figure what entry to read
	mov	al,es:[bx]      	; read entry into latches

	mov     ax,word ptr [bp+6]
	mov	cx,16000
	mul	cx
	mov	di,ax

	rep	stosb
	call	far ptr _reset_hdwe
	xor	ax,ax
@14@482:
	pop	di
	mov	sp,bp
	pop	bp
	ret

_clr_page	endp

   ;
   ;	int copy_page(int source, int dest)
   ;
   ;	/* returns 0 if OK, 1 if bad page */

		PUBLIC	_copy_page

_copy_page	proc	far

	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
	cmp	word ptr [bp+6],3
	jg	short @15@74            ; check for valid page #'s
	cmp	word ptr [bp+8],3
	jle	short @15@98
@15@74:
	mov	ax,65535
	jmp	short @15@506
@15@98:
	call	far ptr _setup_hdwe       ; write VGA state
	push	ds
	cld
	mov	ax,0A000h
	mov	es,ax
	mov	ds,ax
	mov	cx,16000
	mov	ax,word ptr [bp+6]    	; compute source address
	mul	cx
	mov	si,ax
	mov	ax,word ptr [bp+8]	; compute dest. address
	mul	cx
	mov	di,ax

	rep	movsb

	call	far ptr _reset_hdwe
	pop	ds
	xor	ax,ax
@15@506:
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret

_copy_page	endp


 ;
 ; void vga_reg(int reg) 	/* integer: lsby=reg(0=color), msby=value */
 ;

		PUBLIC	_vga_reg

_vga_reg	proc	far

	push	bp
	mov	bp,sp
	mov	dx,03CEH
	mov	ax,WORD PTR [bp+6]
	out	dx,ax
	pop	bp
	ret

_vga_reg	endp



 ;
 ; void load_color(int color)    /* integer: loads latches with color */
 ;

		PUBLIC	_load_color

_load_color	proc	far

	push	bp
	mov	bp,sp
	mov	ax,0a000h
	mov	es,ax
	mov	bl,BYTE PTR [bp+6]
	mov	bh,0ffh		; figure what entry to read
	mov	al,es:[bx]      ; read entry into latches
	pop	bp
	ret

_load_color	endp


 ;
 ; void _set_vmode(int mode)    /* enters video mode thru BIOS */
 ;                              /* mode: clear if MSB not 0    */
 ;				/* mode 14h = X-mode           */

		PUBLIC	_set_vmode

_set_vmode	proc	far

	push	bp
	mov	bp,sp

	mov	ah,0
	mov	al,BYTE PTR [bp+6]
	mov	bl,al
	and	bl,07fh
	cmp	bl,14h
	jz	setxmode
	int	10h
	pop	bp
	ret

setxmode:
	mov	ah,0		; set 256-color mode
	mov	al,13h
	int	10h

	mov	dx,03c4h	; convert to X-mode addressing
	mov	ax,0604h        ; chain mode off
	out 	dx,ax

	mov	dx,03d4h
	mov	ax,0014h        ; doubleword off
	out	dx,ax
	mov	ax,0E317h       ; byte mode on
	out	dx,ax

	call 	far ptr _reset_hdwe

	mov	ax,WORD PTR[bp+6]
	test	al,080h
	jnz	dontclear

	mov	ax,0f02h
	out	dx,ax		; clear all planes at once
	mov	ax,0a000h
	mov	es,ax
	xor	di,di
	mov	cx,0ffffh
	xor	ax,ax
	rep	stosb

	mov	di,0ff00h	; setup latch color table
	mov	cx,100h
	xor	al,al
ctloop:	stosb
	inc	al
	loop	ctloop

dontclear:
	pop	bp
	ret

_set_vmode	endp


 ;
 ; void _set_vpage(int page)    /* sets video page */
 ;

		PUBLIC	_set_vpage

_set_vpage	proc	far

	push	bp
	mov	bp,sp
	mov	ah,5
	mov	al,BYTE PTR [bp+6]
	xor	ah,ah
	cmp	al,4		; check page #
	jae	badpage

	mov	bx,16000
	mul	bx

	mov	bh,ah
	mov	ah,al           ; page # -> address
	mov	al,0dh
	mov	bl,0ch

	mov	dx,03d4h        ; set CRTC address
	out	dx,ax
	mov	ax,bx
	out	dx,ax
badpage:
	pop	bp
	ret

_set_vpage	endp


		end

