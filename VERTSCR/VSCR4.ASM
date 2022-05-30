;                         Written By Draeden of VLA
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    IDEAL
    DOSSEG
    MODEL SMALL
    STACK 400h
    CODESEG
    P386
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INCLUDE "modex.inc"

MaxColor    =   230

INCLUDE "MXfont2.INC"
SCRW = 80
TxtHeight   =   8+4

NewLineData =   65535/SCRW - TxtHeight      ;where the next line is put (#)
NewLineOff  =   NewLineData*SCRW

CurOff      dw  0                               ;current starting offset
MaxOff      =   MaxColor*SCRW

CurCopy     dw  0
MaxCopy     =   TxtHeight * SCRW

CurLine     db  1       ;from 1 to MaxColor

NUMPAL      =   15
CHG         =   3

LABEL TopPal BYTE     
    i= 0
    REPT NUMPAL+1
        db  i,i/3,i/2
        i=i+CHG
    ENDM

LABEL BotPal BYTE     
    REPT NUMPAL+1
        db  i,i/3,i/2
        i=i-CHG
    ENDM
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Msg1        db  1,RED,"Without ",1,GREEN,"the shading,",1,BLUE," you can "
            db  1,GREY2,"color!",0
Msg2        db  1,RED,"³Test #2 ³",0
Msg3        db  1,BLUE,"³Test #3 ³",0
Msg4        db  1,GREEN,"³Blah #4 ³",0
Msg5        db  1,GREY2,"³NYUK #5 ³",0
Msg6        db  1,RED2,"³Test #6 ³",0
Msg7        db  "³Ug.  #7 ³",0

NumMsgs     =   8

MsgOffs     dw  offset Msg1, offset Msg2, offset Msg3, offset Msg4
            dw  offset Msg5, offset Msg6, offset Msg7, offset TitleMsg
CurMsg      dw  0

TitleMsg    db  1,BLUE,"This was coded by ",1,RED,"Draeden",1,BLUE," of ",1,RED,"VLA",0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC ScrollDown
    pusha
    push    es ds
    mov     es,[cs:VGAseg]
    mov     ds,[cs:VGAseg]

    mov     ah,1
    @Set_Write_Mode
    mov     ah,1111b
    @Set_Write_Plane

    inc     [cs:CurLine]
    cmp     [cs:CurLine],MaxColor
    jbe     @@ok
    mov     [cs:CurLine],1
@@Ok:

    mov     di,[cs:CurOff]
    mov     bx,di
    add     bx,SCRW
    cmp     bx,MAXOFF
    jb      @@COOK
    xor     bx,bx
@@COOK:
    mov     [cs:CurOff],bx
    add     di,(240-MaxColor)*SCRW + SCRW*2 ;cause of the extra line in the 
    add     bx,(240-MaxColor)*SCRW + SCRW*2 ; split screen
    
    @Set_Start_Offset
    @FullVertWait

    push    di

    mov     si,NewLineOff
    add     si,[cs:CurCopy]
    push    si
    mov     cx,80
    rep movsb
    
    pop     si
    pop     di

    add     di,MaxColor*SCRW
    mov     cx,80
    rep movsb

    mov     ax,[cs:CurCopy]
    add     ax,SCRW
    cmp     ax,MaxCopy
    jb      @@Cok
    call    PutNextMsg
    xor     ax,ax
@@Cok:
    mov     [cs:CurCopy],ax

    pop     ds es
    popa
    ret
ENDP
    ;es = VGAseg
PROC PutNextMsg
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax

    mov     ah,1111b
    @Set_Write_plane
    mov     di,NewLineOff
    xor     ax,ax
    mov     cx,SCRW*TxtHeight
    rep stosb
    
    mov     ah,0
    @Set_Write_Mode
    
    mov     di,NewLineData
    xor     ax,ax
    mov     si,[CurMsg]
    mov     si,[si + MsgOffs]
    mov     cl,[CurLine]
    call    PrintText

    add     [CurMsg],2
    cmp     [CurMsg],NumMsgs*2
    jb      @@noResetMsg
    mov     [CurMsg],0
@@noResetMsg:
    pop     ds
    popa
    ret
ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
START:
    mov     ax,cs
    mov     ds,ax
    mov     es,ax

    call    StealFont

    @SetModeX m320x240x256, 320

    mov     bx,MaxColor * 2 - 4
    @Set_Split

    call    SetDefPal

    mov     cl,MaxColor + 1
    mov     si,offset TitleMsg
    mov     di, 0
    mov     ax, 0
    call    PrintText

@@MainLoop:
    call    ScrollDown

    mov     ah,1
    int     16h
    jz      @@MainLoop

    mov     ah,0
    int     16h

    mov     ax,3
    int     10h

    mov     ax,4c00h
    int     21h
END START

