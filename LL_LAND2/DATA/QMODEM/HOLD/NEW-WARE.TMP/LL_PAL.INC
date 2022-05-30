;; *************************************************************************
;; LL_PAL.INC   -  Lord Logic's Palette Manipulation Routines  -  LL_PAL.INC
;;          - PRIMOR ViDeO GFX Engine v1.2 * Copyright (C) 1992-93 -
;;
;; No docs or nfo written for these routines yet.  Given with LL_LAND as a
;; programming example.  Focus of the example is the 3D Landscape, and not
;; these routines.  They are pretty straight forward and easy to figure out.
;;
;; *************************************************************************
;; Routines:
;; ll_palcycle(char far *, uchar, uint, char);
;; ll_palcol(char far *, uchar, uint, char, char, char);
;; ll_palput(char far *);
;; ll_palget(char far *);
;; ll_palfade(char far *);
;; ll_palramp(char far *, uchar, uint, char, char, char, char, char, char);
;; ll_palupdate();
;; *
;; NOTE: None of the above routines alter the actual VGA Palette EXCEPT for
;;       ll_palupdate().  They alter the passed buffer.  To change the
;;       actual palette, call one of the above followed by either:
;;       ll_palput() -OR- a call to ll_palfade() followed by ll_palupdate().
;; *
.data
MM     equ     6
	LL_PAL  db      768 dup (?)

.code
ll_palramp      proc
	push    bp
	mov     bp,sp
	push    ds
	push    es
	push    di
	push    si

	mov     ax,@data
	mov     ds,ax

	mov     ax,1
	stc
;; *
;; Get passed parameters . . .
;; *
	mov     di,[bp+MM+2]    ;; Set ES:[DI] to point to starting
	mov     es,di           ;; : of buffer to change  . . .
	mov     di,[bp+MM]      ;; :
	mov     ax,[bp+MM+4]    ;; :
	mov     bx,3
	mul     bx
	add     di,ax
	mov     cx,[bp+MM+6]    ;; Length of ramp
	or      cx,cx           ;; Check length
	jz      llpr_e          ;; : If 0, exit NOW!
	add     cx,[bp+MM+4]    ;; : And if ramp range < 256 . . .
	cmp     cx,256          ;; :
	ja      llpr_e          ;; :
	mov     cx,[bp+MM+6]    ;; :

;; *
;; Compute the RED RAMP
;; *
	push    di
	push    cx
	mov     bl,[bp+MM+8]    ;; Red 1
	mov     bh,[bp+MM+14]   ;; Red 2
	mov     si,bx           ;; Set SI to hold the starting point
	cmp     bh,bl           ;; Check if there is a change
	jne     llpr_1          ;; : and if so, then figure out ratio
	xor     ax,ax           ;; : otherwise, set it to 0.
	jmp     llpr_3          ;; :

llpr_1: xchg    bl,bh           ;; Set AX to hold the ratio
	sub     bl,bh           ;; :
	xor     bh,bh           ;; :
	test    bl,10000000b    ;; Check if BL is negative
	jz      llpr_2          ;; : If not, continue, else
	or      bh,11111111b    ;; : Set BH accordingly . . .
llpr_2: mov     ax,0100h        ;; Ratio = (256*dy)/dx
	imul    bx              ;; :
	idiv    cx              ;; :

llpr_3: mov     bx,si
	mov     bh,al
llpr_4: mov     es:[di],bl
	add     bh,al
	adc     bl,ah
	add     di,3
	loop    llpr_4

	pop     cx
	pop     di

;; *
;; Compute the GREEN RAMP
;; *
	push    di
	push    cx
	mov     bl,[bp+MM+10]   ;; Green 1
	mov     bh,[bp+MM+16]   ;; Green 2
	mov     si,bx           ;; Set SI to hold the starting point
	cmp     bh,bl           ;; Check if there is a change
	jne     llpr_5          ;; : and if so, then figure out ratio
	xor     ax,ax           ;; : otherwise, set it to 0.
	jmp     llpr_7          ;; :

llpr_5: xchg    bl,bh           ;; Set AX to hold the ratio
	sub     bl,bh           ;; :
	xor     bh,bh           ;; :
	test    bl,10000000b    ;; Check if BL is negative
	jz      llpr_6          ;; : If not, continue, else
	or      bh,11111111b    ;; : Set BH accordingly . . .
llpr_6: mov     ax,0100h        ;; Ratio = (256*dy)/dx
	imul    bx              ;; :
	idiv    cx              ;; :

llpr_7: mov     bx,si
	inc     di
llpr_8: mov     es:[di],bl
	add     bh,al
	adc     bl,ah
	add     di,3
	loop    llpr_8

	pop     cx
	pop     di

;; *
;; Compute the BLUE RAMP
;; *
	push    di
	push    cx
	mov     bl,[bp+MM+12]   ;; Blue 1
	mov     bh,[bp+MM+18]   ;; Blue 2
	mov     si,bx           ;; Set SI to hold the starting point
	cmp     bh,bl           ;; Check if there is a change
	jne     llpr_9          ;; : and if so, then figure out ratio
	xor     ax,ax           ;; : otherwise, set it to 0.
	jmp     llpr_11         ;; :

llpr_9: xchg    bl,bh           ;; Set AX to hold the ratio
	sub     bl,bh           ;; :
	xor     bh,bh           ;; :
	test    bl,10000000b    ;; Check if BL is negative
	jz      llpr_10         ;; : If not, continue, else
	or      bh,11111111b    ;; : Set BH accordingly . . .
llpr_10:mov     ax,0100h        ;; Ratio = (256*dy)/dx
	imul    bx              ;; :
	idiv    cx              ;; :

llpr_11:mov     bx,si
	add     di,2
llpr_12:mov     es:[di],bl
	add     bh,al
	adc     bl,ah
	add     di,3
	loop    llpr_12

	pop     cx
	pop     di

	xor     ax,ax
	clc

llpr_e: pop     si
	pop     di
	pop     es
	pop     ds
	pop     bp
	ret
ll_palramp      endp


;;
;; NOTE:  Need to add a horizontal retrace check every 3 bytes output to the
;;        pal port to remove slight flicker from some video displays.
;;
ll_palfade      proc
	push    bp
	mov     bp,sp
	push    ds
	push    es
	push    di
	push    si

	mov     ax,@data
	mov     ds,ax

	mov     di,@data
	mov     es,di
	mov     di,offset LL_PAL

	mov     si,[bp+MM+2]
	mov     ds,si
	mov     si,[bp+MM]
	add     si,768

llfp_1: xor     ah,ah
	xor     di,di
	sub     si,768
	mov     cx,768
llfp_2: mov     al,es:[di]      ;
	cmp     al,[si]         ;
	je      llfp_5          ;
	ja      llfp_4
llfp_3: add     al,2
llfp_4: dec     al
	mov     ah,1
	mov     es:[di],al      ;
llfp_5: inc     si
	inc     di
	loop    llfp_2
	mov     dx,ax           ; Store return code
	jmp     llfp_6          ; step ONLY ONCE through!
	;or      ah,ah           ;
	;jz      llfp_6          ;
	;push    ax
	;call    ll_palupdate
	;pop     ax
	jmp     llfp_1

llfp_6: mov     ax,@data
	mov     ds,ax

	xchg    dx,ax
	mov     al,ah
	clc

llfp_e: pop     si
	pop     di
	pop     es
	pop     ds
	pop     bp
	ret
ll_palfade      endp

;; ************************************************************************
;; char ll_palcycle(char far *buf, unsigned char start, unsigned char size, char dir);
;; USE :  Send 1 in DIR for forward, 1 in DIR for backward cycle.
;; ************************************************************************
ll_palcycle        proc
	push    bp
	mov     bp,sp
	push    ds
	push    es
	push    di
	push    si

	mov     ax,@DATA
	mov     ds,ax

;; *
;; Check the passed parameters . . .
;; *
	mov     ax,[bp+MM+4]
	add     ax,[bp+MM+6]
	cmp     ax,256
	ja      llc_exit
	or      ax,ax
	jz      llc_exit

;; *
;; Slide the PALETTE section ONE position . . .
;; *
	mov     ax,[bp+MM+2]            ;; PAL Segment
	mov     es,ax
	mov     ds,ax
	mov     ax,[bp+MM+4]
	mov     bx,3
	mul     bx
	mov     di,ax
	add     di,[bp+MM]              ;; PAL Offset
	mov     si,ax
	mov     ax,[bp+MM+6]
	mul     bx

	cmp     byte ptr [bp+MM+8],1
	jne     llc_b
llc_f:  cld                             ;; Cycle forward . . .
	mov     di,770
	mov     cx,3
	rep     movsb
	mov     di,si
	sub     di,3
	mov     cx,ax
	sub     cx,3
	rep     movsb
	mov     cx,3
	mov     si,770
	rep     movsb
	jmp     llc_1

llc_b:  std                             ;; Cycle backward . . .
	mov     cx,3
	add     si,ax
	dec     si
	mov     di,772
	rep     movsb
	mov     di,si
	add     di,3
	mov     cx,ax
	sub     cx,3
	rep     movsb
	mov     cx,3
	mov     si,772
	rep     movsb

llc_1:  clc
	xor     ax,ax

;; *
;; Exit the routine . . .
;; *
llc_exit:
	cld
	pop     si
	pop     di
	pop     es
	pop     ds
	pop     bp
	ret
ll_palcycle        endp

ll_palcol       proc
	push    bp
	mov     bp,sp
	push    ds
	push    es
	push    di

	mov     ax,@data
	mov     ds,ax


;; *
;; Check the passed parameters . . .
;; *
	mov     ax,[bp+MM+4]
	add     ax,[bp+MM+6]
	cmp     ax,256
	ja      llpc_e
	or      ax,ax
	jz      llpc_e

;; *
;; Set PAL to new settings . . .
;; *
	mov     bx,3
	mov     ax,[bp+MM+4]
	mul     bx
	mov     di,ax
	add     di,[bp+MM]              ;; PAL Offset
	mov     es,[bp+MM+2]            ;; PAL Segment
	mov     cx,[bp+MM+6]
	mov     ah,[bp+MM+8]
	mov     bh,[bp+MM+10]
	mov     bl,[bp+MM+12]
llpc_l: mov     es:[di],ah
	mov     es:[di+1],bh
	mov     es:[di+2],bl
	add     di,3
	loop    llpc_l

	xor     ax,ax
	clc

llpc_e: pop     di
	pop     es
	pop     ds
	pop     bp
	ret
ll_palcol       endp

;; ************************************************************************
;; char ll_palget(char far *buf);
;; Purpose:  This routine gets the displays palette sets LL_PAL to it and
;;           also sets buf to the same settings.
;; ************************************************************************
ll_palget       proc
	push    bp
	mov     bp,sp
	push    ds
	push    es
	push    di
	push    si

	mov     ax,@data
	mov     ds,ax

	mov     di,@data
	mov     es,di
	mov     di,offset LL_PAL
	mov     cx,768
	mov     dx,03c7h
	xor     al,al
	out     dx,al
	add     dx,2
llpg_1: in      al,dx
	mov     es:[di],al
	inc     di
	loop    llpg_1

	mov     es,[bp+MM+2]
	mov     di,[bp+MM]
	mov     si,@data
	mov     ds,si
	mov     si,offset LL_PAL
	mov     cx,768
	rep     movsb

	xor     ax,ax
	clc

llpg_e: pop     si
	pop     di
	pop     es
	pop     ds
	ret
ll_palget       endp


;; ************************************************************************
;; char ll_palput(char far *buf);
;; Purpose:  This routine sets LL_PAL to the contents of buf and also sets
;;           the displays palette to the new LL_PAL.
;; ************************************************************************
ll_palput       proc
	push    bp
	mov     bp,sp
	push    ds
	push    es
	push    si
	push    di

	mov     ax,@data
	mov     ds,ax

	mov     di,@data
	mov     es,di
	mov     di,offset LL_PAL

	mov     si,[bp+MM+2]
	mov     ds,si
	mov     si,[bp+MM]

;; *
;; Fill LL_PAL with new values . . .
;; *
	cld
	mov     cx,768
	rep     movsb

;; *
;; Wait for VERTICAL RETRACE . . .
;; *
llpp_v: mov     dx,03dah                ;; vertical retrace port
llpp_1: in      al,dx                   ;; read port
	and     al,08h                  ;; mask out bits
	jnz     llpp_1                  ;; if not clear, go back
llpp_2: in      al,dx                   ;; read port
	and     al,08h                  ;; mask out bits
	jz      llpp_2                  ;; if clear, go back

;; *
;; Fill Palette . . .
;; *
	mov     dx,03c8h
	xor     al,al
	out     dx,al
	inc     dx
	mov     cx,768
	sub     si,768
llpp_3: mov     al,[si]
	out     dx,al
	inc     si
	loop    llpp_3

	clc
	xor     ax,ax

llpp_e: pop     di
	pop     si
	pop     es
	pop     ds
	pop     bp
	ret
ll_palput       endp

ll_palupdate    proc
	push    ds
	push    si

	mov     ax,@data
	mov     ds,ax

;; *
;; Wait for VERTICAL RETRACE . . .
;; *
llpu_v: mov     dx,03dah                ;; vertical retrace port
llpu_1: in      al,dx                   ;; read port
	and     al,08h                  ;; mask out bits
	jnz     llpu_1                  ;; if not clear, go back
llpu_2: in      al,dx                   ;; read port
	and     al,08h                  ;; mask out bits
	jz      llpu_2                  ;; if clear, go back

;; *
;; Fill Palette . . .
;; *
	mov     dx,03c8h
	xor     al,al
	out     dx,al
	inc     dx
	mov     cx,768/3
	mov     si,@data
	mov     ds,si
	mov     si,offset LL_PAL
llpu_3:                                 ;; Add a horizontal retrace
					;; check here.  I can't find
					;; the register port nfo in my
					;; book.  oh well.

	mov     ax,[si]
	and     ax,0011111100111111b
	out     dx,al
	mov     al,ah
	out     dx,al
	mov     al,[si+2]
	and     al,00111111b
	out     dx,al
	add     si,3
	loop    llpu_3

	xor     ax,ax
	clc

llpu_e: pop     si
	pop     ds
	ret
ll_palupdate    endp
