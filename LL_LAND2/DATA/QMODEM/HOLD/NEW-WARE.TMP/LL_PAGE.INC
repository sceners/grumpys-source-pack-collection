;;
;; [ Lord Logics Simple Page Flip ]
;;
;; No retrace checking is done here.  Just deal with it . . .
;;
.code
ll_page proc
	push    ds
	mov     ax,@data
	mov     ds,ax

	mov     cx,LL_DRAW
	mov     bx,LL_SHOW
	mov     LL_DRAW,bx
	mov     LL_SHOW,cx

	cli

	mov     dx,03DAh
	in      al,dx           ;; Clear the flip-flop

	mov     dx,03D4h        ;; CRT Controller: Start Addr High
	mov     al,0Ch          ;; Set High Address to SHOW_PAGE
	out     dx,al           ;; :
	inc     dx              ;; :
	mov     al,ch           ;; :
	out     dx,al           ;; :
	dec     dx              ;; CRT Controller: Start Addr Low
	mov     al,0Dh          ;; Set LOW ADDRESS to SHOW_PAGE
	out     dx,al           ;; :
	inc     dx              ;; :
	mov     al,cl           ;; :
	out     dx,al           ;; :

	sti

	pop     ds
	ret
ll_page endp

