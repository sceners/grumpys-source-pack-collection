ModeN   proc    near

        push    di
        push    es
        mov     ax,0013h
        int     10h                    ; (* mode 13h setzen              *)
        mov     dx,03c4h               ; (* portaddrese $3d4 in dx laden *)
        mov     al,4                   ; (* index=4                      *)
        out     dx,al                  ;
        in      al,dx                  ; (* al:=port[$3d5]               *)
        inc     dx                     ;
        and     al,0f7h                ;
        out     dx,al                  ; (* byte abschicken!             *)
        mov     dx,03d4h               ; (* portaddrese $3d4 in dx laden *)
        mov     al,014h                ; (* index=14                     *)
        out     dx,al                  ; (* byte "abschickicken"         *)
        inc     dx                     ;
        in      al,dx                  ; (* al:=port[$3d5]               *)
        and     al,0bfh                ; (* al:=al AND NOT $40           *)
        out     dx,al                  ; (* byte abschicken!             *)
        mov     dx,3d4h                ; (* portaddrese $3d4 in dx laden *)
        mov     al,017h                ; (* index=17                     *)
        out     dx,al                  ; (* byte "abschickicken"         *)
        inc     dx                     ;
        in      al,dx                  ; (* al:=port[$3d5]               *)
        or      al,040h                ; (* al:=al AND 215;215=NOT $40)  *)
        out     dx,al                  ; (* byte abschicken!             *)

        mov     dx,03c4h
        mov     ax,(0fh shl 8) + 2
        out     dx,ax
        mov     ax,0a000h
        mov     es,ax
        sub     di,di
        mov     ax,di
        mov     cx,8000h
        cld
        rep     stosw

        pop     es                     ;
        pop     di                     ;
        ret

ModeN           ENDP


SetStartAddress PROC    NEAR

; This procedure will specify the current starting address for the controller
; to scan.
;
; Input:   AX = starting address to display
; Output:  None
;
; Modifies AX,BX,CX

        MOV     BX,AX
        MOV     DX,03D4h                ; Select CRT controller

        MOV     AL,0Ch
        MOV     AH,BH
        OUT     DX,AX

        INC     AL
        MOV     AH,BL
        OUT     DX,AX
        RET

SetStartAddress ENDP


DataToTweaked   PROC    NEAR

; This will copy linear data into the 4 plane tweaked mode of video memory
;
; Input:   DS:[SI] = linear data
;          ES:[DI] = Byte destination
;          DL = Plane start select
;          AX = Picture Y length
;          BX = Picture X length
; Output:  None
;
; Modifies AX,BX,DX,SI,DI

        PUSH    CX

        MOV     CX,AX
DTT1:
        PUSH    CX
        PUSH    DX
        PUSH    DI
        MOV     CX,BX
DTT2:
        PUSH    CX

        MOV     AL,02                   ; Select Map Mask (Plane select)
        MOV     AH,01
        MOV     CL,DL
        SHL     AH,CL                   ; Select plane
        MOV     DX,3C4h                 ; Select sequencer register
        OUT     DX,AX

        push    ax
        lodsb
        cmp     al,0
        jz      DTT2_5
        stosb
        dec     di
DTT2_5:
        inc     di
        pop     ax

        DEC     DI
        CMP     CL,3                    ; Check if need to incr DI now
        JNE     DTT3                    ; No, carry on...

        INC     DI
        MOV     CL,0FFh                 ; Put in a -1 in DL

DTT3:
        INC     CL
        MOV     DL,CL
        POP     CX

        LOOP    DTT2

        POP     DI
        POP     DX
        POP     CX

        ADD     DI,80

        LOOP    DTT1

        POP     CX
        RET

DataToTweaked   ENDP


SetPicPalette   PROC    NEAR

; Set captured picture's palette
;
; Input:   SI = Offset of the picture palette
;          CX = Number of colors in the palette
; Output:  None

        MOV     DX,3C8h
SPP1:
        OUTSB
        INC     DX
        OUTSB
        OUTSB
        OUTSB
        DEC     DX
        LOOP    SPP1

        RET

SetPicPalette   ENDP

