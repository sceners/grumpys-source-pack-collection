DATA            SEGMENT
                ASSUME DS:DATA

;Each section of the text has to contain 7 lines as showed below!
;If the text isn't written like the example below the intro won't work!
;Also don't start to put in extra chars to center the text.
;The intro will center the text for you.
;You can use these chars in the text:
;a to z ,.-+=*&()!?#/ 0123456789
;Ps : Please don't alter/remove the last section with the credits!
;   : You can max write 40 sections of text!
;   : The intro uses the amount of 202 KB memory!
;   : If you wanna contact me (Xerox) Write to:
;   : Kenneth Houborg, Munkedalen 3, 7080 Borkop, Denmark.
;   : Or call (+45) 75 866909!


Text            label   byte

                db      0,' ',0                   ;make empty lines like this!
                db      0,'the international',0
                db      0,'network of crackers',0
                db      0,'are proud to present:',0
                db      0,' ',0
                db      0,'a new intro by xerox',0
                db      0,' ',0

                db      0,'greetings to:',0
                db      0,' ',0
                db      0,'macro nit',0
                db      0,'red scorpion',0
                db      0,'knight ranger',0
                db      0,'rick d. & burning c.',0
                db      0,'jch, drax & jo / vibrants',0

                db      0,' ',0
                db      0,'the credits',0
                db      0,'*************',0
                db      0,'font by grafictive',0
                db      0,'programming by xerox',0
                db      0,'music+player by vibrants',0
                db      0,' ',0

                db      255                   ;Marks end of text! DON'T FORGET!
;-------------------------------------------------------------------------------
TextPointer     dw      (5*7) dup (0) ;40 sections of text..May be increased!

Total           dw      0
Current         dw      0
Position        dw      0
Text_Count      dw      0
NumberOfLines   dw      0
CurrentLine     dw      0
NextLine        dw      0
Iadd            dw      0
StopVar         db      1
SecondDisplay   dw      0
UnPackedSeg     dw      0
UnPackedCharSeg dw      0
Pointer         dw      0
Var1            db      0
Var2            db      0
Var3            db      0
PelTabel1       db      700  dup (0)
PelTabel2       db      700  dup (0)
Red             db      18   dup (0)
Green           db      18   dup (0)
Blue            db      18   dup (0)
CheckTabel      db      18   dup (0)

SINUS           DW      325,328,332,336,340,344,348,352,356,360,364,368,372
                DW      376,380,384,388,392,396,400,403,407,411,415,419,423,426
                DW      430,434,438,441,445,449,453,456,460,463,467,471,474,478
                DW      481,485,488,492,495,498,502,505,508,512,515,518,521,524
                DW      528,531,534,537,540,543,546,549,551,554,557,560,563,565
                DW      568,571,573,576,578,581,583,586,588,590,592,595,597,599
                DW      601,603,605,607,609,611,613,615,617,618,620,622,623,625
                DW      626,628,629,631,632,633,634,636,637,638,639,640,641,642
                DW      642,643,644,645,645,646,647,647,648,648,648,649,649,649
                DW      649,649,649,649,649,649,649,649,649,649,648,648,648,647
                DW      647,646,645,645,644,643,642,642,641,640,639,638,637,636
                DW      634,633,632,631,629,628,626,625,623,622,620,618,617,615
                DW      613,611,609,607,605,603,601,599,597,595,592,590,588,586
                DW      583,581,578,576,573,571,568,565,563,560,557,554,551,549
                DW      546,543,540,537,534,531,528,524,521,518,515,512,508,505
                DW      502,498,495,492,488,485,481,478,474,471,467,463,460,456
                DW      453,449,445,441,438,434,430,426,423,419,415,411,407,403
                DW      400,396,392,388,384,380,376,372,368,364,360,356,352,348
                DW      344,340,336,332,328,325,321,317,313,309,305,301,297,293
                DW      289,285,281,277,273,269,265,261,257,253,249,246,242,238
                DW      234,230,226,223,219,215,211,208,204,200,196,193,189,186
                DW      182,178,175,171,168,164,161,157,154,151,147,144,141,137
                DW      134,131,128,125,121,118,115,112,109,106,103,100,98,95
                DW      92,89,86,84,81,78,76,73,71,68,66,63,61,59,57,54,52,50
                DW      48,46,44,42,40,38,36,34,32,31,29,27,26,24,23,21,20,18
                DW      17,16,15,13,12,11,10,9,8,7,7,6,5,4,4,3,2,2,1,1,1,0,0,0
                DW      0,0,0,0,0,0,0,0,0,0,1,1,1,2,2,3,4,4,5,6,7,7,8,9,10,11
                DW      12,13,15,16,17,18,20,21,23,24,26,27,29,31,32,34,36,38
                DW      40,42,44,46,48,50,52,54,57,59,61,63,66,68,71,73,76,78
                DW      81,84,86,89,92,95,98,100,103,106,109,112,115,118,121
                DW      125,128,131,134,137,141,144,147,151,154,157,161,164,168
                DW      171,175,178,182,186,189,193,196,200,204,208,211,215,219
                DW      223,226,230,234,238,242,246,249,253,257,261,265,269,273
                DW      277,281,285,289,293,297,301,305,309,313,317,321
SinusLength     equ     $-Sinus

LogoPaletteTab  db      159,158,157,156,155,154,153,152,151,1,150,149,148,147,146,145,144
;-------------------------------------------------------------------------------
;Char data...


CharPalette     label byte
                db 63,63,52
                db 57,55,39
                db 51,47,27
                db 45,38,18
                db 39,29,10
                db 33,20,03
                db 28,12,00

CharLength      dw      14,15,15,15,15,15,15,15,3,15,14,13,16,14,15,15,15,15,15,13,15
                dw      14,16,16,15,13,15,4,15,15,15,15,15,14,15,15,3,13,3,3,3,8,8,9,15,14
                dw      6,6,11,10,9
CharOffsets     dw      60     dup (0)

PackedSeg       label   byte
Include         incl\grafik.txt

EuropeLogo      label   byte
Include         incl\europe.txt

EuropePalette:  db      37,00,00,41,06,06,45,14,14,50,24,24,54,35,35,58,48,48,63,63,63

PackedCharSeg   label   byte
Include         incl\charset.txt

SetError7       db      'Allocation error: '
                db      'Memory control blocks destroyed.$'
SetError8       db      'Allocation error: '
                db      'Insufficient memory.$'
SetError9       db      'Allocation error: '
                db      'Invalid memory block adress.$'

SetUnknown      db      'Unknown allocation error.$'
EndMessage      db      '(C) The International Network of Crackers 1992!',10,13,24h



DATA            ENDS

CODE            SEGMENT
                ASSUME CS:CODE

Include \source\lib\showtime.lib

_03d4h          dw      0

Player          dw      0,0

PlayMusic:      nop
                call    Dword ptr Player
                ret

CalcOffsets:    mov     ax,DATA
                mov     ds,ax
                xor     si,si
                mov     cx,21
                xor     ax,ax
FirstLine:      mov     CharOffsets[si],ax
                add     ax,CharLength[si]
                add     si,2
                loop    FirstLine

                mov     cx,25
                mov     ax,320*12
SecondLine:     mov     CharOffsets[si],ax
                add     ax,CharLength[si]
                add     si,2
                loop    SecondLine

                mov     cx,5
                mov     ax,320*24
ThirdLine:      mov     CharOffsets[si],ax
                add     ax,CharLength[si]
                add     si,2
                loop    ThirdLine
                ret

AddCharSet:     mov     ax,DATA
                mov     ds,ax
                mov     es,UnPackedCharSeg
                mov     ds,UnPackedCharSeg
                xor     si,si
                xor     di,di

                mov     cx,320*39
AddNext:        lodsb
                cmp     al,0
                je      DontAdd
                add     al,240
DontAdd:        stosb
                loop    AddNext
                ret

FindTextPointers:
                mov     ax,DATA
                mov     ds,ax
                xor     di,di

                lea     si,Text
NextPointer:    lodsb
                cmp     al,0
                je      FoundOne
                cmp     al,255
                je      DonePointers
                ret

FoundOne:       dec     si
                mov     TextPointer[di],si
                inc     si
                add     di,2
                mov     cx,500
Search:         lodsb
                cmp     al,0
                je      NextPointer
                loop    Search
DonePointers:   shr     di,1
                mov     NumberOfLines,di

                xor     ax,ax
                xor     bx,bx

DIgen:          cmp     bx,di
                je      DoneP
                add     bx,7
                inc     ax
                jmp     DIgen
                ret

DoneP:          mov     Total,ax
                ret

CenterVar       dw      0

CenterText:     mov     ax,DATA
                mov     ds,ax

CenterAgain:    mov     bx,cs:CenterVar
                shl     bx,1
                mov     di,TextPointer[bx]

                xor     si,si
                xor     bx,bx
                xor     ax,ax
                add     si,di

CenterNext:     mov     bl,Text[si+1]
                cmp     bl,0
                je      CenterEnd
                call    ICompare
                shl     bx,1
                add     ax,CharLength[bx]
                inc     si
                jmp     CenterNext

CenterEnd:      cmp     ax,320
                ja      CenterError
                mov     bx,320
                sub     bx,ax
                shr     bx,1
                mov     Text[di],bl

                inc     cs:CenterVar
                mov     ax,NumberOfLines
                cmp     ax,cs:CenterVar
                jne     CenterAgain
                ret

CenterText2     db      'Error: To many chars in one of text lines!',10,13,24h

CenterError:    mov     ax,3
                int     10h

                push    cs
                pop     ds
                mov     ah,9
                lea     dx,CenterText2
                int     21h
                mov     ax,4c00h
                int     21h

ClearSecondScreen:
                mov     ax,DATA
                mov     ds,ax

                mov     es,SecondDisplay
                mov     cx,160*82
                xor     di,di
                mov     ax,0
                rep     stosw
                ret

NoVGA           db      'Sorry dude, you''ll need a VGA to see this!',10,13,24h

Include         incl\code.lib

Setup:

CheckForVga:    push    es
                mov     ah,1ah
                mov     al,0
                int     10h
                cmp     al,1ah
                je      VgaPresent
                mov     ax,3
                int     10h
                push    cs
                pop     ds
                lea     dx,NoVga
                mov     ah,9
                int     21h
                mov     ax,4c00h
                int     21h
VgaPresent:     pop     es
                mov     bx,5312      ;(85000/16)
                call    SetBlock
                mov     bx,(65000/16)
                call    Allocate
                mov     UnPackedSeg,ax
                mov     bx,(320*42/16)    ;12.5 K
                call    Allocate
                mov     UnPackedCharSeg,ax
                mov     bx,(320*120)/16
                call    Allocate
                mov     SecondDisplay,ax
                mov     ax,ModSeg
                mov     Player[2],ax
                MOV     AH,6            ;Detect adlib card
                call    PlayMusic
                Jnc     NO_CARD_PRESENT
                mov     Byte ptr PlayMusic[0],0c3h   ;ret
NO_CARD_PRESENT:MOV     AH,0
                MOV     BX,ModSeg
                MOV     CX,2390
                CALL    PlayMusic
                MOV     AH,2
                MOV     BX,0
                call    PlayMusic

CheckForMono:   xor     ax,ax
                mov     es,ax
                mov     ax,es:[463h]
                mov     _03d4h,ax

SetExtendMCGA:  mov     ax,13h
                int     10h
                mov     dx,3c4h
                mov     al,4
                out     dx,al
                inc     dx
                in      al,dx
                and     al,0f7h
                or      al,4
                out     dx,al
                mov     dx,3ceh
                mov     al,5
                out     dx,al
                inc     dx
                in      al,dx
                and     al,0efh
                out     dx,al
                dec     dx
                mov     al,6
                out     dx,al
                inc     dx
                in      al,dx
                and     al,0fdh
                out     dx,al
                mov     dx,cs:_03d4h
                mov     al,14h
                out     dx,al
                inc     dx
                in      al,dx
                and     al,0bfh
                out     dx,al
                dec     dx
                mov     al,17h
                out     dx,al
                inc     dx
                in      al,dx
                or      al,40h
                out     dx,al

                call    Toogle
                
ClearGfxScreen: mov     ax,0a000h
                mov     es,ax
                xor     di,di
                mov     cx,32768
                xor     ax,ax
                cld
                rep     stosw

                mov     dx,cs:_03d4h
                mov     al,13h
                out     dx,al
                inc     dx
                mov     al,160
                out     dx,al

                mov     ax,DATA
                mov     ds,ax
                mov     es,UnPackedSeg
SetPalette:     lea     si,PackedSeg
                mov     cx,256*3
                mov     dx,3c8h
                xor     al,al
                out     dx,al
                inc     dx
SetPal1:        lodsb
                out     dx,al
                loop    SetPal1

                lea     si,PackedSeg
                add     si,768
                xor     di,di
                MOV     CX,200
                mov     al,0
                MOV     BP,320
                MOV     BX,0
                MOV     DX,8
                call    Depack

                mov     ax,DATA
                mov     ds,ax
                mov     es,UnPackedCharSeg
                lea     si,PackedCharSeg
                xor     di,di
                MOV     CX,40
                mov     al,0
                MOV     BP,320
                MOV     BX,0
                MOV     DX,8
                call    Depack

                mov     ax,0a000h
                mov     es,ax
                mov     ax,DATA
                mov     ds,ax
                mov     ds,UnPackedSeg

                mov     cx,4
L3:             push    cx

                mov     dx,3c4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     al,cs:Plane
                out     dx,al

                xor     si,si
                add     si,cs:SI_ADD
                mov     di,320*122+(320*7)
                add     di,11
                mov     cx,50
l2:             push    cx
                mov     cx,80
L1:             movsb
                add     si,3
                loop    L1
                add     di,240     ;Skib the two next screens
                pop     cx
                loop    L2

                inc     cs:SI_ADD
                mov     al,cs:Plane
                shl     al,1
                mov     cs:Plane,al
                pop     cx
                loop    L3
;----------
                mov     cs:Plane,1
                mov     cs:SI_ADD,0

                mov     cx,4
A3:             push    cx

                mov     dx,3c4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     al,cs:Plane
                out     dx,al

                mov     si,320*53
                add     si,cs:SI_ADD
                mov     di,320*122+80+(320*4)           ;Start at second screen
                add     di,11
                mov     cx,63
A2:             push    cx
                mov     cx,80
A1:             movsb
                add     si,3
                loop    A1
                add     di,240          ;Skip the two next screens
                pop     cx
                loop    A2

                inc     cs:SI_ADD
                mov     al,cs:Plane
                shl     al,1
                mov     cs:Plane,al
                pop     cx
                loop    A3
;----------
                mov     cs:Plane,1
                mov     cs:SI_ADD,0

                mov     cx,4
B3:             push    cx

                mov     dx,3c4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     al,cs:Plane
                out     dx,al

                mov     si,320*125
                add     si,cs:SI_ADD
                mov     di,320*122+(320*4)+159   ;Start at third screen
                add     di,11
                mov     cx,63
B2:             push    cx
                mov     cx,80
B1:             movsb
                add     si,3
                loop    B1
                add     di,240          ;Skip the two next screens
                pop     cx
                loop    B2

                inc     cs:SI_ADD
                mov     al,cs:Plane
                shl     al,1
                mov     cs:Plane,al
                pop     cx
                loop    B3

                mov     ax,DATA
                mov     ds,ax

                xor     si,si
                mov     cx,699
Calc1:          inc     Var1
                inc     Var1
                cmp     Var1,8
                jne     Nu
                mov     Var1,0
                inc     Var2
Nu:
                mov     al,Var1
                mov     ah,Var2
                mov     PelTabel1[si],al
                mov     PelTabel2[si],ah
                inc     si
                loop    Calc1

                mov     ax,DATA
                mov     es,ax

                mov     cx,17
                lea     si,CheckTabel
                lea     di,CheckTabel
                mov     bl,10
Calc2:          lodsb
                add     al,bl
                stosb
                add     bl,2
                loop    Calc2
                call    SetLineCompare

                mov     ax,0a000h
                mov     es,ax

                mov     di,320*5

                mov     cx,40
Amiga:          mov     dx,3c4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     al,1111b
                out     dx,al
                mov     al,cs:Col
                stosb
                stosb
                inc     Byte ptr cs:Col
                loop    Amiga

                mov     cs:Col,41

                mov     di,320*119
                mov     cx,40
Amiga2:         mov     dx,3c4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     al,1111b
                out     dx,al
                mov     al,cs:Col
                stosb
                stosb
                dec     Byte ptr cs:Col
                loop    Amiga2

                mov     ax,cs
                mov     ds,ax
                mov     es,ax

                lea     si,Ycord1
                lea     di,Ycord1
                mov     cx,35

Calc4:          lodsw
                mov     bx,320
                mul     bx
                stosw
                loop    Calc4

                lea     si,Ycord2
                lea     di,Ycord2
                mov     cx,35
Calc5:          lodsw
                mov     bx,320
                mul     bx
                stosw
                loop    Calc5

                lea     si,Ycord3
                lea     di,Ycord3
                mov     cx,35
Calc6:          lodsw
                mov     bx,320
                mul     bx
                stosw
                loop    Calc6

                mov     ax,0cffh
                int     21h

                xor     si,si
                mov     ax,DATA
                mov     ds,ax
                lea     si,CharPalette[si]
                mov     cx,7*3
                mov     dx,3c8h
                mov     al,241
                out     dx,al
                inc     dx
SetCharPal:     lodsb
                out     dx,al
                loop    SetCharPal

                call    PrintEurope
                call    Toogle

                call    ClearSecondScreen
                call    CalcOffsets
                call    AddCharSet
                call    FindTextPointers
                call    CenterText
                call    SetNewVectors
                ret

PrintEurope:    mov     ax,DATA
                mov     ds,ax
                mov     ax,0a000h
                mov     es,ax
                xor     di,di
                lea     si,EuropeLogo

                mov     cx,8
PrintLogo2:     push    cx
                push    di

                mov     cx,320
PrintLogo:      push    cx
                push    di

                mov     ax,di
                call    Calculate
                add     di,cs:Variabel
                add     di,47

                lodsb
                cmp     al,0
                jne     PrintBlack
                inc     di
                jmp     PrintCont
PrintBlack:     add     al,199
                stosb
PrintCont:      pop     di
                inc     di
                pop     cx
                loop    PrintLogo
                pop     di
                pop     cx
                add     cs:Variabel,320
                loop    PrintLogo2

                lea     si,EuropePalette
                mov     dx,3c8h
                mov     al,200
                out     dx,al
                inc     dx
                mov     cx,7*3
SetEuropePal1:  lodsb
                out     dx,al
                loop    SetEuropePal1
                ret


Variabel        dw      320*110


Col             db      2

SI_ADD          dw      0
Plane           db      1

Start:          mov     ax,DATA
                mov     ds,ax

                call    Setup
                call    MainPart

                mov     ax,DATA
                mov     ds,ax

                MOV     AH,2
                MOV     BX,0
                call    PlayMusic
                mov     ax,DATA
                mov     ds,ax
                mov     es,UnPackedSeg
                call    DeAllocate
                mov     es,UnPackedCharSeg
                call    DeAllocate
                mov     es,SecondDisplay
                call    DeAllocate
                mov     ax,3
                int     10h
                mov     ah,9
                lea     dx,EndMessage
                int     21h
                mov     ax,0cffh
                int     21h
                mov     ax,4c00h
                int     21h
;-------------------------------------------------------------------------------
MoveLogo:
                mov     ax,DATA
                mov     ds,ax

                mov     si,Pointer
                shl     si,1
                mov     bx,Sinus[si]

                mov     dx,cs:_03d4h
                mov     al,0dh
                out     dx,al
                inc     dx
                mov     al,PelTabel2[bx]
                out     dx,al

                mov     dx,cs:_03d4h
                mov     al,0ch
                out     dx,al
                inc     dx
                mov     al,150
                out     dx,al

                add     Var3,4

                mov     dx,3dah         ;Clear flip/Flop
                in      al,dx

                mov     dx,3c0h
                mov     al,51         ;51
                out     dx,al
                mov     al,PelTabel1[bx]        ;Var1
                out     dx,al

                cmp     Pointer,510
                jne     Nope
                mov     Pointer,0
                jmp     Nope1
Nope:           inc     Pointer
                inc     Pointer
Nope1:          ret


SetLineCompare:
                mov     dx,3dah
                in      al,dx

                mov     dx,3c0h
                mov     al,10h
                out     dx,al
                inc     dx
                in      al,dx
                xor     al,00100000b
                push    ax

                mov     dx,3dah
                in      al,dx

                mov     dx,3c0h
                mov     al,10h
                out     dx,al
                pop     ax
                out     dx,al


                mov     dx,cs:_03d4h
                mov     al,18h
                out     dx,al
                inc     dx
                mov     al,140
                out     dx,al

                mov     dx,cs:_03d4h
                mov     al,7
                out     dx,al
                inc     dx
                in      al,dx
                and     al,11101111b
                out     dx,al


                mov     dx,cs:_03d4h
                mov     al,9
                out     dx,al
                inc     dx
                in      al,dx
                and     al,10111111b
                out     dx,al
                ret


SetLogoPalette: mov     cx,17
                xor     si,si
                mov     ax,DATA
                mov     ds,ax

Setpal2:        mov     dx,3c8h
                mov     al,LogoPaletteTab[si]      ;159 = Darkest!
                out     dx,al
                inc     dx
                mov     al,Red[si]
                out     dx,al
                nop
                nop
                mov     al,Green[si]
                out     dx,al
                nop
                nop
                mov     al,Blue[si]
                out     dx,al
                inc     si
                loop    Setpal2

                cmp     cs:BigDelayy,500
                je      Switch
                inc     cs:BigDelayy

                cmp     cs:Way,1
                je      FadeUp
                jmp     FadeDown

FadeUp:         call    ColorsOn
                ret

Switch:         mov     al,cs:Way
                xor     al,1
                mov     cs:Way,al

                cmp     cs:way,0
                je      ShortDelay
                mov     cs:BigDelayy,0

                cmp     cs:Color,2
                jne     Reset
                mov     cs:Color,0
                ret
Reset:
                inc     cs:color
                ret

ShortDelay:     mov     cs:BigDelayy,350
                ret

Way             db      1

Delay           db      0
BigDelayy       dw      0
Color           db      0

ColorsOn:
                mov     ax,DATA
                mov     es,ax

                cmp     Delay,2
                je      Okay1
                inc     Delay
                ret

Okay1:          mov     Delay,0
                xor     si,si

                cmp     cs:Color,0
                je      RedOn
                cmp     cs:Color,1
                je      GreenOn
                jmp     BlueOn

RedOn:
                mov     cx,17
RedOn2:         mov     al,Red[si]
                cmp     al,CheckTabel[si]
                je      Equal1
                inc     al
                mov     Red[si],al
                mov     Green[si],al
Equal1:         inc     si
                loop    RedOn2
                ret

GreenOn:
                mov     cx,17
RedOn3:         mov     al,Green[si]
                cmp     al,CheckTabel[si]
                je      Equal2
                inc     al
                mov     Green[si],al
                mov     Blue[si],al
Equal2:         inc     si
                loop    RedOn3
                ret

BlueOn:
                mov     cx,17
RedOn4:         mov     al,Blue[si]
                cmp     al,CheckTabel[si]
                je      Equal3
                inc     al
                mov     Blue[si],al
                mov     Red[si],al
Equal3:         inc     si
                loop    RedOn4
                ret

Delay2          db      0

FadeDown:       mov     ax,DATA
                mov     ds,ax

                cmp     cs:Delay2,2
                je      Okay2
                inc     cs:Delay2
                ret

Okay2:          mov     cs:Delay2,0

                mov     cx,17
                xor     si,si
Fade1:          cmp     Red[si],0
                je      Skip1
                dec     Red[si]
Skip1:          cmp     Green[si],0
                je      Skip2
                dec     Green[si]
Skip2:          cmp     Blue[si],0
                je      Skip3
                dec     Blue[si]
Skip3:          inc     si
                loop    Fade1
                ret


AmigaDelay      db      0

AmigaLike:
                inc     cs:AmigaDelay
                cmp     cs:AmigaDelay,2
                je      Amigal
                ret

Amigal:         mov     cs:AmigaDelay,0
                mov     ax,0a000h
                mov     ds,ax
                mov     es,ax
                pushf

                mov     dx,3c4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     al,1111b
                out     dx,al

                mov     si,320*5
                lodsw
                push    ax

                cld
                mov     si,2+320*5
                mov     di,320*5
                mov     cx,40
                rep     movsw

                pop     ax
                mov     di,78+320*5
                stosw

                std
                mov     si,76+(320*119)
                mov     di,78+(320*119)

                mov     bx,es:[di]
                mov     cx,40
                rep     movsw

                mov     es:[320*119],bx
                popf
                ret
;-------------------------------------------------------------------------------
Xcord1          dw      100,300,180,80,270,105,219,130,170,250,65,96,310,92,180
                dw      77,35,246,295,127,230,102,160,100,123,276,132,234,304
                dw      230,17,190,95,36,103               ; 35 stks

YCord1          dw      15,116,30,83,95,65,13,45,37,100,88,118,23,21,9,7
                dw      55,98,100,45,58,42,16,70,65,95,62,14,64,28,92,106
                dw      15,23,92                        ;35 Stks

Xcord2          dw      106,300,180,80,270,105,219,130,170,255,65,96,310,92,180
                dw      77,35,246,295,127,230,102,160,100,123,276,132,234,304
                dw      230,17,190,95,36,103               ; 35 stks

YCord2          dw      25,27,102,16,17,70,115,103,45,23,80,91,46,35,74,71
                dw      42,12,117,9,13,60,81,93,29,105,77,53,23,91,14,47,56
                dw      116,37                          ;35 stks

Xcord3          dw      106,300,180,80,270,105,219,130,170,255,65,96,310,92,180
                dw      77,35,246,295,127,230,102,160,100,123,276,132,234,304
                dw      230,17,190,95,36,103               ; 35 stks

YCord3          dw      15,116,30,83,95,65,13,45,37,100,88,118,23,21,9,7
                dw      55,98,100,45,58,42,16,70,65,95,62,14,64,28,92,106
                dw      15,23,92                        ;35 Stks

Dot1            equ     254   ;254
Dot2            equ     253   ;253
Dot3            equ     252   ;252

StarVar1        dw      0

Star            dw      0

Stars:          call    Plan1
                call    Plan2
                call    Plan3
                ret


Calculate:      push    ax
                and     ax,00000011b
                mov     bp,ax

                mov     bl,al
                mov     dx,3ceh
                mov     al,4
                out     dx,al
                inc     dx
                mov     al,bl
                out     dx,al

                mov     bx,bp
                mov     dx,3c4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     al,cs:C_Tabel[bx]
                out     dx,al
                pop     di
                shr     di,1
                shr     di,1
                ret

Plan1Var        dw      0
Speed1          equ     1

Plan1:
                mov     ax,0a000h
                mov     es,ax

                mov     cs:Plan1Var,0
                cld
                mov     cx,35
Ako1:           mov     si,cs:Plan1Var
                shl     si,1
                mov     ax,cs:Xcord1[si]
                push    ax
                call    Calculate          ;Return position in DI
                add     di,cs:Ycord1[si]

                cmp     Byte ptr es:[di],0
                jne     Nek1

                mov     al,Dot1
                stosb
Nek1:

                pop     ax
                dec     ax
                call    Calculate
                add     di,cs:Ycord1[si]

                cmp     Byte ptr es:[di],Dot1
                jne     Nek2

                xor     al,al
                stosb
Nek2:           inc     cs:Plan1Var
                loop    Ako1

                mov     ax,cs
                mov     ds,ax
                mov     es,ax

                lea     si,Xcord1
                lea     di,Xcord1
                mov     cx,35
SpCalc1:        lodsw
                cmp     ax,320
                jng     IkkeNu1
                mov     ax,0
IkkeNu1:        add     ax,Speed1
                stosw
                loop    SpCalc1
                ret

;-------------------------------------------------------------------------------
Plan2Var        dw      0
Speed2          equ     2

Plan2:
                mov     ax,0a000h
                mov     es,ax

                mov     cs:Plan2Var,0
                cld
                mov     cx,35
Ako2:           mov     si,cs:Plan2Var
                shl     si,1
                mov     ax,cs:Xcord2[si]
                push    ax
                call    Calculate          ;Return position in DI
                add     di,cs:Ycord2[si]

                cmp     Byte ptr es:[di],0
                jne     ANek1

                mov     al,Dot2
                stosb
ANek1:
                pop     ax
                sub     ax,speed2
                call    Calculate
                add     di,cs:Ycord2[si]

                cmp     Byte ptr es:[di],Dot2
                jne     ANek2

                xor     al,al
                stosb
ANek2:          inc     cs:Plan2Var
                loop    Ako2

                mov     ax,cs
                mov     ds,ax
                mov     es,ax

                lea     si,Xcord2
                lea     di,Xcord2
                mov     cx,35
SpCalc2:        lodsw
                cmp     ax,320
                jng     IkkeNu2
                mov     ax,0
IkkeNu2:        add     ax,Speed2
                stosw
                loop    SpCalc2
                ret


Plan3Var        dw      0
Speed3          equ     3

Plan3:
                mov     ax,0a000h
                mov     es,ax

                mov     cs:Plan3Var,0
                cld
                mov     cx,35
Ako3:           mov     si,cs:Plan3Var
                shl     si,1
                mov     ax,cs:Xcord3[si]
                push    ax
                call    Calculate          ;Return position in DI
                add     di,cs:Ycord3[si]


                cmp     Byte ptr es:[di],0
                jne     bNek1

                mov     al,Dot3
                stosb
BNek1:
                pop     ax
                sub     ax,Speed3
                call    Calculate
                add     di,cs:Ycord3[si]

                cmp     Byte ptr es:[di],Dot3
                jne     BNek2

                xor     al,al
                stosb
BNek2:          inc     cs:Plan3Var
                loop    Ako3

                mov     ax,cs
                mov     ds,ax
                mov     es,ax

                lea     si,Xcord3
                lea     di,Xcord3
                mov     cx,35
SpCalc3:        lodsw
                cmp     ax,320
                jng     IkkeNu3
                mov     ax,0
IkkeNu3:        add     ax,Speed3
                stosw
                loop    SpCalc3
                ret
;-------------------------------------------------------------------------------
ICompare:       sub     bx,97

                cmp     bx,' '-97
                jne     Za1
                mov     bx,50

Za1:            cmp     bx,'0'-97
                jne     Za2
                mov     bx,26

Za2:            cmp     bx,'1'-97
                jne     Za3
                mov     bx,27

Za3:            cmp     bx,'2'-97
                jne     Za4
                mov     bx,28

Za4:            cmp     bx,'3'-97
                jne     Za5
                mov     bx,29

Za5:            cmp     bx,'4'-97
                jne     Za6
                mov     bx,30

Za6:            cmp     bx,'5'-97
                jne     Za7
                mov     bx,31

Za7:            cmp     bx,'6'-97
                jne     Za8
                mov     bx,32

Za8:            cmp     bx,'7'-97
                jne     Za9
                mov     bx,33

Za9:            cmp     bx,'8'-97
                jne     Za10
                mov     bx,34

Za10:           cmp     bx,'9'-97
                jne     Za11
                mov     bx,35

Za11:           cmp     bx,'!'-97
                jne     Za12
                mov     bx,36

Za12:           cmp     bx,'?'-97
                jne     Za13
                mov     bx,37

Za13:           cmp     bx,'.'-97
                jne     Za14
                mov     bx,38

Za14:           cmp     bx,','-97
                jne     Za15
                mov     bx,39

Za15:           cmp     bx,':'-97
                jne     Za16
                mov     bx,40

Za16:           cmp     bx,'-'-97
                jne     Za17
                mov     bx,41

Za17:           cmp     bx,'='-97
                jne     Za18
                mov     bx,42

Za18:           cmp     bx,'+'-97
                jne     Za19
                mov     bx,43

Za19:           cmp     bx,'&'-97
                jne     Za20
                mov     bx,44


Za20:           cmp     bx,'*'-97
                jne     Za21
                mov     bx,45

Za21:           cmp     bx,'('-97
                jne     Za22
                mov     bx,46

Za22:           cmp     bx,')'-97
                jne     Za23
                mov     bx,47

Za23:           cmp     bx,'#'-97
                jne     Za24
                mov     bx,48

Za24:           cmp     bx,'/'-97
                jne     ZDone
                mov     bx,49
ZDone:          ret
;-------------------------------------------------------------------------------


Print:          call    ShowSecondDisplay
                mov     ax,DATA
                mov     ds,ax

                cmp     CurrentLine,7
                je      XStop

                cmp     StopVar,2      ;Clear screen
                je      ClearScreen

                cmp     StopVar,1      ;Make screen
                je      Yeah
                ret

XStop:          jmp     Stop

ClrOffset       dw      0

ClearScreen:    mov     ax,DATA
                mov     ds,ax
                mov     es,SecondDisplay

                mov     di,cs:ClrOffset
                mov     ax,0
                mov     cx,160
                rep     stosw
                add     cs:ClrOffset,320
                cmp     cs:ClrOffset,320*81
                je      Stop2
                ret

Stop2:          mov     cs:ClrOffset,0
                mov     StopVar,1
                ret

Yeah:

                mov     si,NextLine
                shl     si,1
                mov     bx,TextPointer[si]

                mov     di,Position
                xor     ax,ax
                mov     al,Text[0+bx]
                add     di,ax
                mov     si,Text_Count
                xor     cx,cx
                mov     cl,Text[si+1+bx]
                cmp     cx,0
                jne     Ok

                inc     NextLine
                add     Iadd,320*12

                mov     ax,Iadd
                mov     Position,ax
                mov     Text_count,0
                inc     CurrentLine
                ret

Stop:           mov     StopVar,0
                ret

Ok:
                mov     bx,cx
                call    ICompare
                shl     bx,1

                mov     si,CharOffsets[bx]
                mov     dx,CharLength[bx]
                add     Position,dx
                inc     Text_count

                mov     es,SecondDisplay
                mov     ds,UnPackedCharSeg

                mov     cx,10
GetNextLine:    push    cx
                mov     ax,di
                mov     bx,si

                mov     cx,dx
                rep     movsb

                mov     si,bx
                add     si,320
                mov     di,ax
                add     di,320
                pop     cx
                loop    GetNextLine
                ret

ShowVar         dw      0
XDelay          dw      0

ShowSecondDisplay:
                cmp     cs:XDelay,70
                je      KKK2
                inc     cs:XDelay
                ret

KKK2:           mov     ax,DATA
                mov     ds,ax
                cmp     StopVar,0
                je      KKK
                ret

XStopShow:      jmp     StopShow

KKK:            mov     ds,SecondDisplay
                mov     ax,0a000h
                mov     es,ax

                cmp     cs:ShowVar,320*41
                je      XStopShow
                add     cs:ShowVar,320

                mov     si,cs:Pos1
                mov     di,cs:Pos1x
                call    DrawLine
                add     cs:Pos1,640
                add     cs:Pos1x,640

                mov     si,cs:Pos2
                mov     di,cs:Pos2x
                call    DrawLine
                sub     cs:Pos2,640
                sub     cs:Pos2x,640
                ret

Pos1            dw      0
Pos1X           dw      320*22

Pos2            dw      320*81
Pos2x           dw      320*103


DrawLine:       mov     bx,0
                call    Calculate2

                push    si
                push    di

                mov     cx,80
Getz1:          lodsb
                stosb
                add     si,3
                loop    Getz1

                pop     di
                pop     si
                inc     si
                push    si
                push    di

                mov     bx,1
                call    Calculate2
                mov     cx,80
Getz2:          lodsb
                stosb
                add     si,3
                loop    Getz2

                pop     di
                pop     si
                inc     si
                push    si
                push    di

                mov     bx,2
                call    Calculate2
                mov     cx,80
Getz3:          lodsb
                stosb
                add     si,3
                loop    Getz3

                pop     di
                pop     si
                inc     si

                mov     bx,3
                call    Calculate2
                mov     cx,80
Getz4:          lodsb
                stosb
                add     si,3
                loop    Getz4
StopShow:       ret


Calculate2:
                and     bx,00000011b

                mov     dx,3c4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     al,cs:C_Tabel[bx]
                out     dx,al
                ret

C_Tabel         db      1,2,4,8

DisplayDelay    dw      0

ChangeDisplay:  cmp     cs:DisplayDelay,750
                je      ChangeNow
                inc     cs:DisplayDelay
                ret

ChangeNow:
                mov     ax,DATA
                mov     ds,ax

                mov     cs:DisplayDelay,0

                inc     Current
                mov     ax,Current
                cmp     ax,Total
                jne     WrapAround
                mov     NextLine,0
                mov     Current,0

WrapAround:     mov     StopVar,2      ;Clear screen
                mov     Position,0
                mov     Iadd,0
                mov     CurrentLine,0
                mov     cs:ShowVar,0
                mov     cs:Pos1,0
                mov     cs:pos1x,320*22

                mov     cs:Pos2,320*81
                mov     cs:pos2x,320*103
                ret

MainPart:
                mov     dx,3d4h
                mov     al,6
                mov     ah,0
                out     dx,ax

Main:           call    Waitraster
;-------------------------------------------------------------------------------
                call    SetLogoPalette
                call    AmigaLike

                call    Stars
                call    Print
                call    ChangeDisplay

                MOV     AH,3
                call    PlayMusic

                call    MoveLogo
;-------------------------------------------------------------------------------
                in      al,60h
                cmp     al,1
                jne     Main
                call    RestoreVectors
                ret


CODE            ENDS

ModSeg          Segment para
include         incl\alibi.txt
ModSeg          ends

                END     Start

