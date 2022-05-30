;;
;; [ Lord Logics Unchained Mode INIT ]
;;
ll_xinit proc
	push    es
	push    di
	push    ds

	mov     ax,@data
	mov     ds,ax

	cli                             ;; Don't INTerrupt us!

	ll_port 03C4h,04h               ;; Sequencer: Memory Mode
	and     al,11110101b            ;; Disable ODD/EVEN Mode
	or      al,00000100b            ;; Select Chain 4
	out     dx,al                   ;; Disable Extended Memory

	ll_port 03CEh,05h               ;; Graphics: Mode Register
	and     al,11101111b            ;; Disable ODD/EVEN Mode
	out     dx,al                   ;; :

	ll_port 03CEh,06h               ;; Graphics: Misc Register
	and     al,11110101b            ;; Disable CHAIN ODD/EVEN
	or      al,00000100b            ;; Memory Mode to A0000-AFFFF
	out     dx,al                   ;; :

	ll_port 03D4h,14h               ;; LLT Controller: Underline Loc
	and     al,10111111b            ;; Disable DOUBLE WORD
	out     dx,al

	ll_port 03D4h,17h               ;; CRT Controller: Mode Control
	or      al,01000000b            ;; Set BYTE MODE
	and     al,11011111b            ;; Set Address Wrap
	out     dx,al

	ll_flip                         ;; Clear the FLIP-FLOP
	ll_attr 10h                     ;; Attr Controller: Mode Control
	mov     al,01100001b            ;; Set lotsa stuff . . .
	out     dx,al                   ;; :

	ll_port 03C4h,02h               ;; Sequencer: Map Mask
	mov     al,00001111b            ;; Enable Planes 0,1,2,3
	out     dx,al                   ;; :

	sti
	mov     di,0A000h               ;; Clear the VIDEO MEMORY
	mov     es,di                   ;; :
	xor     di,di                   ;; :
	xor     ax,ax                   ;; :
	mov     cx,32000                ;; :
@@:     mov     es:[di],ax              ;; :
	add     di,2                    ;; :
	dec     cx                      ;; :
	jnz     @B                      ;; :
	cli

	ll_attr 33h                     ;; Attr Controller: Horiz Pix Pan
	xor     al,al                   ;; Clear the HORIZ PIX PAN
	out     dx,al                   ;; :

	ll_port 03D4h,13h               ;; CRT Controller: Offset Register
	mov     al,(LL_HOR/8)           ;; Set OFFSET to # of chrs (REAL/4)
	out     dx,al                   ;; :

	ll_port 03D4h,0Ch               ;; CRT Controller: Start Addr High
	mov     ax,LL_SHOW              ;; Set HIGH ADDRESS to SHOW_PAGE
	mov     al,ah                   ;; :
	out     dx,al                   ;; :

	ll_port 03D4h,0Dh               ;; CRT Controller: Start Addr Low
	mov     ax,LL_SHOW              ;; Set LOW ADDRESS to SHOW_PAGE
	out     dx,al                   ;; :

	sti                             ;; INTerruptions are OK now!

	xor     ax,ax                   ;; Clear return flag

cr_id:  pop     ds
	pop     di
	pop     es
	ret
ll_xinit endp

