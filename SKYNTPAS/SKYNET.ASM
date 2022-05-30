; Place dummy segment here to load the 'Code' segment into memory first

                .286


include Macros.ASM

SplitHeight     equ     80d

Code    segment para public 'Code'
Code    ends


Stack   segment para public 'Stack'
        dw      60 dup (?)
Stack   ends


Data    segment para public 'Data'

StartAddr       dw      (200d-SplitHeight)*80d
CurrentLine     db      0
GridClrAddr     dw      offset GridColors
Delay           dw      0

include WTech.DAT
include Grid.DAT
include GridClr.DAT
include UpperWin.DAT

GridInvert      db      160*75 dup (0)
ConvertTable    db        0             ; Dummy value
                db       16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1
                db       32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17
                db       48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33
                db       64, 63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49
                db       80, 79, 78, 77, 76, 75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 65
                db       96, 95, 94, 93, 92, 91, 90, 89, 88, 87, 86, 85, 84, 83, 82, 81
                db      112,111,110,109,108,107,106,105,104,103,102,101,100, 99, 98, 97
                db      128,127,126,125,124,123,122,121,120,119,118,117,116,115,114,113

Data    ends


Code            segment para public 'Code'

Start           proc    far

        assume  cs:Code
        push    ds                      ; Save PSP segment address
        xor     ax,ax
        push    ax                      ; Store return address offset
        mov     ax,Data
        mov     ds,ax
        assume  ds:Data


        call    Initialize
WaitKey:
        mov     dx,03dah
VR1:
        in      al,dx
        test    al,08h
        jz      VR1                     ; Wait for right hand corner

        mov     dx,03c8h
        mov     al,1
        out     dx,al
        inc     dx
        mov     si,GridClrAddr
        mov     cx,128*3
        rep     outsb

        cmp     Delay,0
        jz      Scroll
        dec     Delay
        jmp     Continue2

Scroll:
        dec     dx
        xor     ax,ax
        mov     al,CurrentLine
        add     al,129
        out     dx,al
        sub     al,129
        inc     dx
        mov     si,offset UpperWin_Colors
        mov     cx,80*3
        sub     cx,ax
        sub     cx,ax
        sub     cx,ax
        rep     outsb

        mov     al,129
        dec     dx
        out     dx,al
        inc     dx
        xor     cx,cx
        mov     cl,CurrentLine
        add     cl,CurrentLine
        add     cl,CurrentLine
        add     cx,3
        rep     outsb

        mov     ax,StartAddr
        call    SetStartAddress

        SetWriteMode    0
        call    DisplayNextLine

        SetWriteMode    1
        call    CopyLineToTop

        add     StartAddr,80d
        inc     CurrentLine

        cmp     StartAddr,200d*80d
        jne     Continue2
        mov     StartAddr,(200d-SplitHeight)*80d
        mov     CurrentLine,0

Continue2:
        add     GridClrAddr,384
        cmp     GridClrAddr,offset GridColors+3072
        jne     Continue3
        mov     GridClrAddr,offset GridColors
Continue3:

;        in      al,61h
;        test    al,80h
;        jz      Continue4
;        jmp     WaitKey
        mov     ah,1
        int     16h
        jnz     Continue4
        jmp     WaitKey
Continue4:
        xor     ah,ah
        int     16h

;        in      al,21h                  ; Enable keyboard interrupt
;        and     al,11111101b
;        out     21h,al

        mov     ax,0003h
        int     10h

        ret

Start           endp


Initialize      proc    near

;        in      al,21h          ; Disable keyboard interrupt
;        or      al,2
;        out     21h,al

        call    ModeN           ; Switch video mode to tweaked 320x800

        mov     dx,03d4h        ; Setup splitscreen
        mov     ax,(SplitHeight*2 shl 8) + 18h
        out     dx,ax
        mov     al,7            ; zero out the extra bit on split screen
        out     dx,al           ; located in the overflow register of CRT
        inc     dx
        in      al,dx
        and     al,0efh
        mov     ah,al
        mov     al,7
        dec     dx
        out     dx,ax
        mov     al,9            ; zero out the other extra bit on split scr
        out     dx,al           ; located in the MaxScanLine register of CRT
        inc     dx
        in      al,dx
        and     al,0bfh
        mov     ah,al
        mov     al,9
        dec     dx
        out     dx,ax

        mov     dx,03c8h        ; Clear all the colors
        xor     al,al
        out     dx,al
        mov     cx,256*3
        inc     dx
ClearColorsLoop:
        out     dx,al
        loop    ClearColorsLoop

        cld                             ;Convert Grid Data into other table...
        mov     si,offset Grid
        mov     di,offset GridInvert + Grid_XLen-1
        push    ds
        pop     es
        mov     dx,Grid_YLen
        mov     bx,offset ConvertTable
LineLoop:
        mov     cx,Grid_XLen
PixLoop:
        lodsb
        xlat
        mov     es:[di],al
        dec     di
        loop    PixLoop
        add     di,Grid_XLen*2
        dec     dx
        jnz     LineLoop

        mov     ax,0a000h       ; Have ES point to Vid segment
        mov     es,ax

        SetWriteMode    0       ; Write the first grid into vid memory
        mov     si,offset Grid
        mov     di,45*80+40
        xor     dl,dl
        mov     ax,Grid_YLen
        mov     bx,Grid_XLen
        call    DataToTweaked

        mov     si,offset GridInvert    ; Write inverted grid into vid memory
        mov     di,45*80
        xor     dl,dl
        mov     ax,Grid_YLen
        mov     bx,Grid_XLen
        call    DataToTweaked

        mov     dx,03c4h                ; Draw background of text
        mov     ax,0f02h
        out     dx,ax
        mov     ax,129
        mov     di,StartAddr
UpWinLoop1:
        mov     cx,80
        rep     stosb
        inc     ax
        cmp     ax,209
        jne     UpWinLoop1

        mov     ax,129
UpWinLoop2:
        mov     cx,80
        rep     stosb
        inc     ax
        cmp     ax,209
        jne     UpWinLoop2

        xor     di,di
LowWinLoop:
        mov     cx,80
        rep     stosb
        inc     ax
        cmp     ax,229
        jne     LowWinLoop

        mov     si,offset WTech_Pic
        mov     di,30*80+7
        xor     dl,dl
        mov     ax,WTech_YLen
        mov     bx,WTech_XLen
        call    DataToTweaked

        mov     si,offset WTech_Pal     ; Setup the palette of the picture
        mov     cx,WTech_NumColors
        call    SetPicPalette

        mov     si,offset Font_Pal
        mov     cx,Font_NumColors
        call    SetPicPalette

        mov     al,UpperWin_StartColor
        mov     dx,03c8h
        out     dx,al
        inc     dx
        mov     si,offset UpperWin_Colors
        mov     cx,UpperWin_NumColors*3
        rep     outsb

        ret


Initialize      endp


include Message.ASM
include Video.ASM


Code            ends

                end

