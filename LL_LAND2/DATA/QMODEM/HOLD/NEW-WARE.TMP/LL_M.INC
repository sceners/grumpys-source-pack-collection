;;
;; MACROS for easy to read code . . .
;;
ll_plan MACRO   PLANE
	mov     dx,03C4h
	mov     al,02h
	mov     ah,PLANE
	and     ah,00001111b
	out     dx,ax
	ENDM

ll_port MACRO   REG, IND
	mov     dx,REG
	mov     al,IND
	out     dx,al
	inc     dx
	in      al,dx
	ENDM

ll_outp MACRO   REG, IND
	mov     dx,REG
	mov     al,IND
	out     dx,al
	inc     dx
	ENDM

ll_attr MACRO   IND
	mov     dx,03C0h
	mov     al,IND
	out     dx,al
	ENDM

ll_flip MACRO
	mov     dx,03DAh
	in      al,dx
	ENDM

ll_vert MACRO
	mov     dx,03DAh
;@@:     in      al,dx
;        test    al,00001000b
;        jnz     @B
@@:     in      al,dx
	test    al,00001000b
	jz      @B
	in      al,dx
	ENDM

ll_horz MACRO
	mov     dx,03DAh
llh:    in      al,dx
	test    al,00000001b
	jz      llh
	ENDM

.data
	MM      equ     6
align 2
	X_OLD   dw      0
	Y_OLD   dw      0


