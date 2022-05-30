;These signs are at you disposal in the text: a to z ( ) ! , . ' - * & "
;Remember you can only write in lower case when you are using a to z.
;You can write as much as you wish in the text below. Just remember to end
;the text with db 0 as showed!    Or else the text won't wrap around!
;-------------------------------------------------------------------------------
SinusLength     equ     (128*2)*2     ;Don't alter any of these data!
Source          equ     320*106+8     ;As the loader would fuck up!
Source2         equ     320*124+8     ;
Step            equ     5             ;

                .model  small         ;
                dosseg                ;

                .data
;-------------------------------------------------------------------------------
Text            label   byte
                db      '   international network of crackers!   '
                db      'we bring you yet another quality release'
                db      '----------------------------------------'
                db      '  ** use this version of the loader **  '
                db      '     i have removed all known bugs!     '
                db      ' and all data is collected in one file! '
                db      '                                        '
                db      0     ;Marks end of text. DON'T FORGET!
;-------------------------------------------------------------------------------
EndMessage      db      '(C) The International Network of Crackers 1992!',10,10,13
                db      'All programming by Xerox!',10,13
                db      'Original music by Drax of the Vibrants!',10,13
                db      'Adlib player & conversion by Jch of the Vibrants!',10,10,13,24h
;-------------------------------------------------------------------------------
StartText       dw      0
Delay2          db      0
Pause           dw      0
First           dw      0
ColVar          db      9
Check           db      2
Fade            db      0
_Si             dw      0
_Di             dw      0
Ditto1          dw      0
Ditto2          dw      0
;-------------------------------------------------------------------------------
LetterTabel     dw      Source+(16*00),Source+(16*01),Source+(16*02),Source+(16*03),Source+(16*04),Source+(16*05),Source+(16*06),Source+(16*07),Source+(16*08),Source+(16*09),Source+(16*10),Source+(16*11),Source+(16*12),Source+(16*13),Source+(16*14),Source+(16*15),Source+(16*16),Source+(16*17),Source+(16*18)
                dw      Source2+(16*00),Source2+(16*01),Source2+(16*02),Source2+(16*03),Source2+(16*04),Source2+(16*05),Source2+(16*06),Source2+(16*07),Source2+(16*08),Source2+(16*09),Source2+(16*10),Source2+(16*11),Source2+(16*12),Source2+(16*13),Source2+(16*14),Source2+(16*15),Source2+(16*16),Source2+(16*17),Source2+(16*18)
;-------------------------------------------------------------------------------
SinusVar        db      0,0,0,0,0,0,0,0,0,0
                db      0,0,0,0,0,0,0,0,0,0
                db      0,0,0,0,0,0,0,0,0,0
                db      0,0,0,0,0,0,0,0,0,0

SinusData       dw      0,0,0,0,0,0,0,0,0,0
                dw      0,0,0,0,0,0,0,0,0,0
                dw      0,0,0,0,0,0,0,0,0,0
                dw      0,0,0,0,0,0,0,0,0,0
;-------------------------------------------------------------------------------
DataFile        db      'datafile.inc',0
;-------------------------------------------------------------------------------
UnpackedPicSeg  dw      0
MusicSegment    dw      0
;-------------------------------------------------------------------------------
Rgb1            db      0
Rgb2            db      0
Rgb3            db      0

PaletteData     Label byte
                db      00,00,00,51,51,59,35,35,47,23,23,43,19,19,47,07,11,31,03,03,27,00,00,19,59,59,59,59,59,55,59,59,51,59,59,47,59,59,43,59,59,39,59,59,35,59,59,31,59,59,27,59,55,23,55,51,23,55,47,19,51,43,19,51,39,15,51,35,15,47,31,11
                db      47,31,11,47,27,07,43,23,07,39,19,03,35,15,03,31,15,03,27,11,00,23,07,00,63,00,00,59,00,00,55,00,00,51,00,00,48,00,00,47,00,00,43,00,00,39,00,00,38,00,00,34,00,00,31,00,00,27,00,00,23,00,00,22,00,00,19,00,00,14,00,00
                db      63,52,52,63,44,44,63,39,39,63,31,31,63,23,23,63,15,15,63,07,07,63,00,00,63,42,23,63,38,15,63,34,07,63,30,00,55,27,00,51,23,00,43,21,00,39,19,00,63,63,52,63,63,44,63,63,39,63,63,31,63,60,23,63,59,15,63,59,07,63,59,00
                db      55,52,00,51,47,00,43,43,00,39,39,00,31,31,00,27,27,00,22,21,00,15,15,00,51,63,23,47,63,15,43,63,07,39,63,00,35,55,00,31,51,00,27,43,00,23,39,00,52,63,52,47,63,44,39,63,39,31,63,31,23,63,23,15,63,15,07,63,07,00,63,00
                db      00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
                db      00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
                db      00,00,11,00,00,11,00,00,11,00,00,11,00,00,11,00,00,11,00,00,11,00,00,13,00,00,13,00,00,13,00,00,13,00,00,14,00,00,14,00,00,14,00,00,14,00,00,15,59,52,63,55,44,63,52,39,63,51,31,63,48,23,63,47,15,63,43,07,63,42,00,63
                db      38,00,55,31,00,51,27,00,43,23,00,39,19,00,31,17,00,27,13,00,22,10,00,15,63,52,63,63,44,63,63,39,63,63,31,63,63,23,63,63,15,63,63,07,63,63,00,63,55,00,55,48,00,51,43,00,43,39,00,39,31,00,31,27,00,27,22,00,22,15,00,15
                db      63,56,55,63,55,51,63,52,47,63,51,47,63,51,43,63,47,39,63,47,39,63,44,35,63,43,31,63,39,27,63,39,23,59,35,23,56,35,22,55,34,21,51,31,19,48,31,19,47,30,18,43,27,17,42,26,15,39,23,15,39,23,14,35,23,13,34,22,11,31,19,11
                db      27,19,10,27,18,09,23,15,07,21,15,07,18,14,06,15,11,06,14,11,05,10,07,03,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,47,10,10,47,19,10,47,27,10,47,39,10,47,47,10,39,47,10,27,47,10,19,47,10
                db      10,47,11,10,47,23,10,47,34,10,47,43,10,42,47,10,31,47,10,19,47,11,10,47,22,10,47,31,10,47,43,10,47,47,10,43,47,10,31,47,10,21,47,10,10,63,63,63
;-------------------------------------------------------------------------------
Sinus1          DW      36,38,40,41,43,45,46,48,49,51,52,54,55,57,58,59,60,62,63,64,65,65,66,67,67,68,68,69,69,69,69,69,69,69,69,69,68,68,67,67,66,65,65,64,63,62,60,59,58,57,55,54,52,51,49,48,46,45,43,41,40,38,36,34,33,31,29,28,26,24,23,21,20,18,17,15,14,12,11,10,9,7,6,5,4,4,3,2,2,1,1,0,0,0,0,0,0,0,0,0,1,1,2,2,3,4,4,5,6,7,9,10,11,12,14,15,17,18,20,21,23,24,26,28,29,31,33,34
                DW      36,38,40,41,43,45,46,48,49,51,52,54,55,57,58,59,60,62,63,64,65,65,66,67,67,68,68,69,69,69,69,69,69,69,69,69,68,68,67,67,66,65,65,64,63,62,60,59,58,57,55,54,52,51,49,48,46,45,43,41,40,38,36,34,33,31,29,28,26,24,23,21,20,18,17,15,14,12,11,10,9,7,6,5,4,4,3,2,2,1,1,0,0,0,0,0,0,0,0,0,1,1,2,2,3,4,4,5,6,7,9,10,11,12,14,15,17,18,20,21,23,24,26,28,29,31,33,34,36
;-------------------------------------------------------------------------------
StartPos        dw      320*101
EndPos          dw      320*10
Antal           dw      0
Book            dw      90
;-------------------------------------------------------------------------------
SetError7       db      'Allocation error: '
                db      'Memory control blocks destroyed.$'
SetError8       db      'Allocation error: '
                db      'Insufficient memory.$'
SetError9       db      'Allocation error: '
                db      'Invalid memory block adress.$'

SetUnknown      db      'Unknown allocation error.$'


DataBuffer      db      20786 dup (0)



                .code
                .286

Player:         ret
                db      9ah,0,0
Music           dw      0
                ret
;-------------------------------------------------------------------------------
Start:          mov     ax,@data
                mov     ds,ax
                call    Reserve    ;Allocate memory needed
                call    Setup      ;precalculate data & etc.
;-------------------------------------------------------------------------------
Main:           call    Waitraster

                call    Dycp

                mov     ah,3                 ;Play music
                call    Player

                mov     cx,8                 ;Put INC logo onto screen!
Network:        push    cx
                call    LogoShower
                pop     cx
                loop    Network

                mov     ah,1                 ;Check for keypress
                int     16h
                je      Main
                mov     ah,0
                int     16h                  ;End main
;-------------------------------------------------------------------------------
Terminate:      call    ClearInit

                mov     es,UnpackedPicSeg
                call    Deallocate

                mov     ax,3                ;Switch to normal graphics!
                int     10h
                mov     ah,9                ;Write EndMessage to screen
                lea     dx,EndMessage
                int     21h
                mov     ax,4c00h            ;Terminate program! Return to dos!
                int     21h
;-------------------------------------------------------------------------------
DepackPicture:  mov     es,UnpackedPicSeg
                mov     ax,@data
                mov     ds,ax

                lea     si,DataBuffer
                add     SI,3883            ;After player+data
                MOV     DI,0
                MOV     CX,200
                mov     al,0
                MOV     BP,320
                MOV     BX,0
                MOV     DX,8
                PUSH    AX
                MOV     AX,BP
                AND     AX,7
                SHR     BP,3
                CMP     AX,0
                JE      ax_0
                MOV     AX,1
ax_0:           ADD     BP,AX
                SHR     BX,3
                POP     AX
                push    cx
                mov     cl,al
                mov     al,1
                shl     al,cl
                MOV     AH,AL
                NOT     AH
                pop     cx
Depackl1:       PUSH    CX
                PUSH    AX
                MOV     CX,DX
Planes:         PUSH    CX
                PUSH    DI
                PUSH    BP
NotherOne:      XOR     CX,CX
                MOV     CL,DS:[SI]
                INC     SI
                CMP     CL,127
                JA      CrunchyNut
                INC     CX
                SUB     BP,CX
                push    bx
PutByte:        mov     bl,ds:[si]
                inc     si
                push    cx
                mov     cx,8
orpixel:        rcl     bl,1
                jc      carry_set
                and     es:[di],ah
                jmp     set_done
carry_set:      or      es:[di],al
set_done:       inc     di
                loop    orpixel
                pop     cx
                LOOP    PutByte
                pop     bx
                JMP     LineOk
CrunchyNut:     SUB     CX,257
                NEG     CX
                SUB     BP,CX
                push    bx
                mov     bl,ds:[si]
                mov     bh,bl
                inc     si
PutByte2:       push    cx
                mov     cx,8
orpixel2:       rcl     bl,1
                jc      carry_set2
                and     es:[di],ah
                jmp     set_done2
carry_set2:     or      es:[di],al
set_done2:      inc     di
                loop    orpixel2
                mov     bl,bh
                pop     cx
                LOOP    PutByte2
                pop     bx
LineOk:         CMP     BP,0
                JNE     NotherOne
                POP     BP
                POP     DI
                POP     CX
                SHL     AL,1
                STC
                RCL     AH,1
                LOOP    Planes
                push    bp
                push    bx
                shl     bp,3
                shl     bx,3
                ADD     DI,BP
                ADD     DI,BX
                pop     bx
                pop     bp
                POP     AX
                POP     CX
                LOOP    Depackl1
                RET

SetVgaPalette:  call    waitraster
                mov     dx,3c8h
                mov     ax,di
                out     dx,al
                inc     dx
                mov     ax,cx
                shl     cx,1
                add     cx,ax
                rep     outsb
                ret
;-------------------------------------------------------------------------------
Reserve:        mov     bx,(110000/16)      ;105 KB needed to run intro!
                call    Setblock

                mov     bx,(5000/16)        ;5 KB for all data
                call    Allocate
                mov     MusicSegment,ax
                mov     Music,ax

                mov     bx,(65000/16)       ;65 KB for the unpacked picture
                call    Allocate
                mov     UnpackedPicSeg,ax
                ret
;-------------------------------------------------------------------------------
SetBlock:       mov     ah,4ah
		int	21h
                jc      SetBlockError
                ret
SetBlockError:
                push    ax
                mov     ax,0003h
                int     10h
                pop     ax

                cmp     ax,7
                jz      Set10
		cmp	ax,8
                jz      Set20
                cmp     ax,9
                jz      Set30
                lea     dx,SetUnknown
                jmp     short SetBlockPrint
Set10:          lea     dx,SetError7
                jmp     short SetBlockPrint
Set20:          lea     dx,SetError8
                jmp     short SetBlockPrint
Set30:          lea     dx,SetError9

SetBlockPrint:  mov     ah,9
     		int	21h
                mov     ax,4c00h
                int     21h

Allocate:       mov     ah,48h
		int	21h
                jc      AllocateError
                ret
AllocateError:
                push    ax
                mov     ax,0003h
                int     10h
                pop     ax

                cmp     ax,7
                jz      Allo10
		cmp	ax,8
                jz      Allo20
                lea     dx,SetUnknown
                jmp     short AllocatePrint
Allo10:         lea     dx,SetError7
                jmp     short AllocatePrint
Allo20:         lea     dx,SetError8

AllocatePrint:  mov     ah,9
     		int	21h
                mov     ax,4c00h
                int     21h

DeAllocate:     mov     ah,49h
		int	21h
                jc      DeAlloError
                ret
DeAlloError:
                push    ax
                mov     ax,0003h
                int     10h
                pop     ax

                cmp     ax,7
                jz      DeA10
                cmp     ax,9
                jz      DeA20
                lea     dx,SetUnknown
                jmp     short DeAlloPrint
DeA10:          lea     dx,SetError7
                jmp     short DeAlloPrint
DeA20:          lea     dx,SetError9

DeAlloPrint:    mov     ah,9
     		int	21h
                mov     ax,4c00h
                int     21h

waitraster:     mov     dx,3dah
ras1:           in      al,dx
                test    al,8
                jnz     ras1
ras2:           in      al,dx
                test    al,8
                jz      ras2
                ret
;-------------------------------------------------------------------------------
LogoShower:     mov     ax,@data
                mov     ds,ax

                cmp     Book,1
                jne     Naah
                ret

Naah:           mov     cx,160
                mov     si,StartPos
                mov     di,EndPos

                mov     ax,@data
                mov     ds,ax
                mov     ds,UnpackedPicSeg
                mov     ax,0a000h
                mov     es,ax
                rep     movsw

                mov     ax,@data
                mov     ds,ax

                mov     ax,Book
                inc     Antal
                cmp     Antal,ax
                jne     Reset1
                dec     Book
                mov     Antal,0
                mov     EndPos,320*9
                sbb     StartPos,320
Reset1:         add     EndPos,320
                ret

Setup:          mov     ax,@data
                mov     ds,ax
                mov     ax,MusicSegment
                mov     es,ax

                mov     cx,3900/2
                lea     si,DataBuffer
                xor     di,di
                rep     movsw


                mov     ah,6        ;Adlib detection
                call    Player
                jc      NoCard

Yes:            mov     Byte ptr player,90h

NoCard:         mov     ax,13h          ;Switch to 320x200 256 colors
                int     10h

                call    ClearInit

;-------------------------------------------------------------------------------
                CALL    DepackPicture

                mov     ax,@data
                mov     ds,ax

                mov     di,0
                mov     cx,256
                lea     si,PaletteData
                call    setvgapalette

                mov     ds,UnpackedPicSeg
                mov     ax,0a000h
                mov     es,ax

                cld
                xor     si,si
                xor     di,di
                mov     cx,160*9
                rep     movsw

                mov     si,(320*191)
                mov     di,(320*191)
                mov     cx,160*9
                rep     movsw

                mov     ax,@data
                mov     ds,ax
                mov     es,ax

                lea     si,Sinus1
                lea     di,Sinus1
                mov     cx,256
Calc:           lodsw
                add     ax,110
                stosw
                loop    Calc

                lea     si,SinusData
                lea     di,SinusData
                mov     cx,40
Calc2:          lodsw
                add     ax,Source-8
                stosw
                loop    Calc2

                lea     si,SinusVar
                lea     di,SinusVar
                mov     cx,40
                mov     bl,0
Calc3:          lodsb
                add     al,bl
                stosb
                add     bl,3
                loop    Calc3

                mov     ax,@data
                mov     ds,ax
                mov     ax,0a000h
                mov     es,ax
                ret
;-------------------------------------------------------------------------------
Dycp:           mov     ax,@data
                mov     ds,ax

Kwon:           mov     Rgb1,0
                mov     Rgb2,0
                mov     Rgb3,0

                cmp     Check,0
                jne     Red
                mov     Rgb2,60
                mov     Rgb3,60
                jmp     Skib1

Red:            cmp     Check,1
                jne     Green
                mov     Rgb2,60
                jmp     Skib1

Green:          mov     Rgb3,60
                mov     Rgb1,60

Skib1:          mov     bl,15*8
                sbb     bl,ColVar

                mov     cx,8
Col2:           mov     dx,3c8h
                mov     al,bl
                out     dx,al
                inc     dx
                nop
                nop
                nop
                nop
                nop
                nop
                mov     al,Rgb1
                out     dx,al
                nop
                nop
                nop
                nop
                nop
                nop
                mov     al,Rgb2
                out     dx,al
                nop
                nop
                nop
                nop
                nop
                nop
                mov     al,Rgb3
                out     dx,al

                cmp     Check,0
                jne     Red2
                sbb     Rgb2,Step
                sbb     Rgb3,Step
                jmp     Skib2
Red2:           cmp     Check,1
                jne     Green2
                sbb     Rgb2,Step
                jmp     Skib2
Green2:         sbb     Rgb3,Step
                sbb     Rgb1,Step
Skib2:

                inc     bl
                loop    col2

                mov     dx,3c8h
                mov     al,bl
                out     dx,al
                inc     dx
                nop
                nop
                nop
                nop
                nop
                nop
                mov     al,0
                out     dx,al
                nop
                nop
                nop
                nop
                nop
                nop
                out     dx,al
                nop
                nop
                nop
                nop
                nop
                nop
                out     dx,al

Wrappie:        xor     di,di
                mov     si,StartText

                mov     cx,40
Trans:          mov     al,Text[si]
                cmp     al,0
                jne     Wrap
                mov     StartText,0
                jmp     Wrappie
Wrap:           xor     ah,ah
                cmp     al,32
                jne     Space
                mov     al,26+97     ;
Space:          cmp     al,'('
                jne     Para1
                mov     al,27+97     ;(
Para1:          cmp     al,')'
                jne     Para2
                mov     al,28+97     ;)
Para2:          cmp     al,'!'
                jne     udrob
                mov     al,29+97     ;!
Udrob:          cmp     al,','
                jne     comma
                mov     al,30+97     ;,
Comma:          cmp     al,'.'
                jne     Punktum
                mov     al,31+97
Punktum:        cmp     al,''''  ;'
                jne     oper
                mov     al,32+97
Oper:           cmp     al,'+'
                jne     Plus
                mov     al,33+97
Plus:           cmp     al,'-'
                jne     Minus
                mov     al,34+97
Minus:          cmp     al,'*'
                jne     Stjerne
                mov     al,35+97
Stjerne:        cmp     al,'&'
                jne     og
                mov     al,36+97
Og:             cmp     al,'"'
                jne     Gose
                mov     al,37+97
Gose:

                sbb     al,97
                shl     ax,1
                mov     bx,ax
                mov     ax,LetterTabel[bx]
                mov     SinusData[di],ax
                inc     si
                add     di,2
                loop    Trans
;-------------------------------------------------------------------------------
                mov     ax,0a000h
                mov     es,ax

                mov     cx,40
Lykke:          push    cx
                xor     bh,bh
                mov     di,_DI
                mov     si,_SI

Testt:          mov     bl,SinusVar[Si]

                shl     bx,1
                mov     ax,320

                mul     Sinus1[bx]
                add     di,ax
                push    di
                mov     di,Ditto1
                inc     SinusVar[di]
                mov     di,Ditto2
                mov     si,SinusData[di]
                pop     di
                mov     ds,UnpackedPicSeg
                mov     cx,12
Husk1:          push    cx
                mov     cx,4
                rep     movsw
                add     si,312
                add     di,312
                pop     cx
                loop    Husk1

                mov     ax,@data
                mov     ds,ax
                add     _Di,8
                add     _Si,1
                add     Ditto1,1
                add     Ditto2,2

                pop     cx
                loop    Lykke

                mov     _si,0
                mov     _di,0
                mov     Ditto1,0
                mov     Ditto2,0

                cmp     First,100
                je      Cool
                inc     First
                ret

Cool:           cmp     Fade,0
                je      Op
                jmp     FadeDown

Op:             inc     Delay2
                cmp     Delay2,7
                je      Now1
                ret

Now1:           mov     Delay2,0
                cmp     ColVar,0
                je      Don1
                dec     Colvar
                ret

Don1:           mov     Pause,0
                mov     Fade,1
                mov     Delay2,0
                ret

FadeDown:       cmp     Pause,400
                je      OkayDown
                inc     Pause
                ret

OkayDown:       inc     Delay2
                cmp     Delay2,7
                je      Down1
                ret

Down1:          mov     Delay2,0
                cmp     ColVar,9
                je      Down2
                inc     ColVar
                ret

Down2:          mov     Delay2,0
                mov     fade,0
                mov     Pause,0
                add     StartText,40
                inc     Check
                cmp     Check,3
                jne     Reset
                mov     Check,0
Reset:          ret

ClearInit:      mov     ah,1            ;Init player
                call    Player
                mov     ax,@data
                mov     ds,ax
                xor     ah,ah
                mov     cx,2125
                mov     bx,MusicSegment
                sub     dl,dl
                call    Player

                mov     ah,2
                xor     bx,bx
                call    Player
                ret

                end     Start
