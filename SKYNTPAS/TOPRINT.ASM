GetCGAFont      proc    near

        mov     ax,ds
        mov     es,ax

        mov     ax,0f000h
        mov     ds,ax

        mov     si,0fa6eh
        mov     di,offset Font
        mov     dx,256*8
        cld
Get1:
        lodsb
        mov     bx,0080h
Get2:
        push    ax
        and     al,bl
        stosb
        cmp     al,0
        jz      Continue
        mov     byte ptr es:[di-1],246d
Continue:
        pop     ax
        shr     bx,1
        jnz     Get2
        dec     dx
        jnz     Get1

        push    es
        pop     ds
        ret

GetCGAFont      endp


DisplayNextLine proc    near
; This procedure displays the next message line 'slice' onto the bottom of the
; split screen window.  Assumes ES = 0a000h, and write mode is 0

        mov     si,MessagePtr
        mov     di,StartAddr
        add     di,SplitHeight*80d + 4   ; (Xstart,Ystart) = (32,SplitHeight)
        mov     cl,3
DNL1:
        lodsb
        cmp     al,0
        jz      Finished
        xor     bx,bx
        mov     bl,al
        shl     bx,6
        add     bx,MessageLine
        mov     ah,8
DNL2:
        mov     al,[offset Font + bx]
        cmp     al,0
        jz      DNL3

        mov     bp,ax
        mov     ax,0802
        shr     ah,cl
        mov     dx,03c4h
        out     dx,ax
        mov     ax,bp

        mov     byte ptr es:[di],al

DNL3:
        dec     cl
        jns     DNL4
        inc     di
        mov     cl,3
DNL4:
        inc     bx
        dec     ah
        jnz     DNL2

        jmp     DNL1

Finished:
        add     MessageLine,8
        cmp     MessageLine,64d
        jne     DontResetML
        mov     MessageLine,0
        add     MessagePtr,37d
        cmp     MessagePtr,offset Message + MessageNumLines*37d
        jne     DontResetML
        mov     MessagePtr,offset Message

DontResetML:
        ret

DisplayNextLine endp

