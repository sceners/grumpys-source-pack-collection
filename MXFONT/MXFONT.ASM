    IDEAL
    DOSSEG    
    MODEL SMALL
    STACK 200h
    CODESEG
    ASSUME CS:@CODE, DS:@CODE
    P386N
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    INCLUDE "MODEX.INC"
    INCLUDE "MXFont.INC"
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

TestMsg db  1,BLUE,"This",1,GREEN," is",1,RED," a",1,GREY3," Test",0

NumMsgs =   2

TestMsgHdr  MsgHdr  <offset TestMsg,10,20>,<offset TestMsg,10,30>

CREDITS db  1,RED,"MODEX",1,BLUE," font",1,GREEN," utility",1,GREY3
        db  " BY ",1,RED,"Draeden",0
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
START:
    mov     ax,cs
    mov     ds,ax

    call    StealFont
    call    SetDefPal

    @SetModeX m320x240x256, 320

    mov     bx,offset TestMsgHdr
    mov     cx,NumMsgs
    call    PrintList

    mov     di,150
    mov     ax,2
    mov     si,offset Credits
    call    PrintText

    mov     ah,0        ;wait for a keypress
    int     16h

    mov     ax,3        ;set vid mode 80x25x16 char
    int     10h
    mov     ax,4c00h    ;exit to DOS w/ exit code 0
    int     21h
END START
