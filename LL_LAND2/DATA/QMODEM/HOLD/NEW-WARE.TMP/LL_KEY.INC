;; *************************************************************************
;; LL_KEY.INC   -   Lord Logic's  Keyboard Interupt  Routines  -  LL_KEY.ASM
;;          - PRIMOR ViDeO GFX Engine v1.2 * Copyright (C) 1992-93 -
;;
;; No docs or nfo written for these routines yet.  Given with LL_LAND as a
;; programming example.  Focus of the example is the 3D Landscape, and not
;; these routines.  They are pretty straight forward and easy to figure out.
;;
;; *************************************************************************
.data
MM      equ     6
public  LL_KEYFLAG
public  LL_KEYBUF
public  LL_KEYCHANGE

	LL_KEYFLAG      db      256 dup (0)
	LL_KEYBUF       db      0
	LL_BUF          db      256 dup (0)
	LL_KEYHEAD      dw      offset LL_BUF
	LL_KEYTAIL      dw      offset LL_BUF
	LL_KEYCHANGE    db      0

	OLD_9_O dw      offset NEW_9
	OLD_9_S dw      @code

.code
ll_keyhit       proc
	push    ds

	mov     ax,@data
	mov     ds,ax

	xor     ax,ax
	mov     bx,LL_KEYTAIL
	cmp     bx,LL_KEYHEAD
	je      llkh_e

	mov     ax,1

llkh_e: pop     ds
	ret
ll_keyhit       endp

ll_keyget       proc
	push    ds

	mov     ax,@data                ;; Set up OUR DATA SEGMENT!
	mov     ds,ax                   ;; :

	xor     ax,ax                   ;; Set NO RETURN FLAG
	cmp     LL_KEYBUF,0             ;; Check if the buffer is ACTIVE
	je      llkg_e                  ;; : If not, then exit . . .

llkg_1: call    ll_keyhit               ;; No keys in LL_BUF, so we will
	or      ax,ax                   ;; : wait until a key is hit.
	jz      llkg_1                  ;; :

	cli
	mov     bx,LL_KEYTAIL           ;; Get a key from the buffer. FIFO
	mov     al,[bx]                 ;; :
	inc     bx                      ;; And update the pointers . . .

	cmp     bx,offset LL_BUF+255    ;;
	jne     llkg_2
        mov     bx,offset LL_BUF

llkg_2: cmp     bx,LL_KEYHEAD           ;; :
	jne     llkg_3                  ;; Are there any keys left in BUF?

	mov     LL_KEYCHANGE,0          ;; : No? -> Clear the CHANGE FLAG

llkg_3: mov     LL_KEYTAIL,bx           ;; Update LL_KEYTAIL to new setting.

llkg_e: sti                             ;; Interrupts are fine now.
	pop     ds
	xor     ah,ah
	ret
ll_keyget       endp

;; *************************************************************************
;; void ll_keyswap();
;; ll_keyswap swaps between the original keyboard interrupt and our new and
;; improved interrupt.
;; *************************************************************************
ll_keyswap      proc
	push    ds
	push    es

	mov     ax,@data
	mov     ds,ax

	mov     ax,03509h       ;; Get interrupt 09h
	int     21h             ;; : return in ES:BX

	mov     ax,OLD_9_S
	mov     dx,OLD_9_O
        push    ds
        mov     ds,ax
	mov     ax,02509h       ;; Set new interrupt
	int     21h             ;; : to address in DS:DX
        pop     ds

	mov     OLD_9_S,es      ;; Save the old interrupt
	mov     OLD_9_O,bx

	pop     es
        pop     ds
        ret
ll_keyswap      endp

;; *************************************************************************
;; NEW_9() is the new keyboard interrupt.
;; It reads the scan code from the keyboard and modifies the flags table.
;; If LL_KEYBUF is set to ON (1) it also places the key in the buffer.  Up
;; to 255 keys may be placed in the buffer.
;;
;; The flag table is set as follows:  The high byte is set to the position
;; of the key, pressed=1, release=0.  The low byte is set to 1 when the key
;; is pressed and left unmodified when the key is released.
;; *************************************************************************
NEW_9   proc    far
        push    ax
        push    bx
	push    di
        push    ds

	mov     ax,@data        ;; Set up to point to our DATA Segment
	mov     ds,ax           ;; :

	in      ax,60h          ;; Get SCAN CODE in AL, CONTROL in AH
	mov     bx,ax           ;; Save a copy in BX
	xchg    ah,al           ;; Put CONTROL in AL
	or      al,80h          ;; Clear Keyboard of interrupt request
	out     61h,al          ;; :
	and     al,7Fh          ;; :
	out     61h,al          ;; :
	mov     al,20h          ;; Send generic EOI to PIC
	out     20h,al          ;; :

	and     bx,0007fh       ;; Strip all but the scan code
	shl     bx,1            ;; Multiply by two to get our offset

	test    ah,10000000b    ;; Check if key was RELEASED
	jnz     n9_4            ;; Yes?-> Act accordingly . . .

	mov     byte ptr [offset LL_KEYFLAG+BX],1   ;; Key HAS BEEN PRESSED
	mov     byte ptr [offset LL_KEYFLAG+BX+1],1 ;; Key IS BEING PRESSED
	shr     bx,1            ;; Set back to normal number

	cmp     LL_KEYBUF,0     ;; Is our KEYBOARD BUFFER ON?
	je      n9_e            ;; : No? -> Continue as normal

        mov     di,LL_KEYHEAD   ;; Check if BUFFER is FULL
	cmp     di,offset LL_BUF+255
        jne     n9_2
        cmp     LL_KEYTAIL,offset LL_BUF
	jne     n9_3
        jmp     n9_e

n9_2:   inc     di              ;; :
        cmp     LL_KEYTAIL,di   ;; :
	je      n9_e            ;; : Yes?-> Don't put in buffer then.
	dec     di              ;; :

n9_3:   mov     [di],bl         ;; Put key in BUFFER
	inc     LL_KEYHEAD      ;; Increment the HEAD needs to loop . . .
	cmp     LL_KEYHEAD,offset LL_BUF+255
	jne     n9_e
	mov     LL_KEYHEAD,offset LL_BUF
	jmp     n9_e            ;; We're done pretty much now . . .

n9_4:   mov     byte ptr [offset LL_KEYFLAG+BX+1],0 ;; Key IS RELEASED

n9_e:   mov     LL_KEYCHANGE,1
	pop     ds
	pop     di
	pop     bx
	pop     ax
        iret
NEW_9   endp
