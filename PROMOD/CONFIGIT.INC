컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

    INCLUDE "BWPRINT.INC"
    
UPKEY    EQU "+"
DNKEY    EQU "-"
ENTERKEY EQU 13

MACRO @CursorOff
    push    dx ax

    mov     dx,03d4h
    mov     al,0ah
    out     dx,al
    inc     dx
    in      al,dx
    or      al,00100000b
    out     dx,al

    pop     ax dx
ENDM @CursorOff

MACRO @CursorOn
    push    dx ax

    mov     dx,03d4h
    mov     al,0ah
    out     dx,al
    inc     dx
    in      al,dx
    and     al,11011111b
    out     dx,al

    pop     ax dx
ENDM @CursorOn

ScanNumberVal  dw  0
SubRoutine     dw  0

    ;esi = MAX number
    ;edi = Min number
    ;ecx = Step value
    ;ebx = default
    ;dx = screen location dh= Ypos, dl= Xpos
    ;bp = offset to subroutine to call to display stuff
    ;return value in [ScanNumberVal]
PROC ScanNumber NEAR
    pushad

    push    dx cx bx
    mov     bh,0
    mov     ah,3
    int     10h

    mov     ah,dh
    pop     bx cx dx
    mov     dh,ah

    mov     [cs:Subroutine],bp

@@ScanNumberLoop:
    mov     ah,2
    push    bx
    mov     bh,0
    int     10h     ;set cursor pos
    pop     bx

    mov     eax,ebx
    clc
    call    [cs:Subroutine]

    mov     ah,0
    int     16h     ;get a key

    cmp     al,UPKEY
    jne     @@NotPLus
    add     ebx,ecx
    cmp     ebx,esi
    jle     @@ScanNumberLoop
    mov     ebx,esi
    jmp     @@ScanNumberLoop
@@NotPlus:
    cmp     al,DNKEY
    jne     @@NotMinus
    sub     ebx,ecx
    cmp     ebx,edi
    jge     @@ScanNumberLoop
    mov     ebx,edi
    jmp     @@ScanNumberLoop
@@NotMinus:
    cmp     al,ENTERKEY
    jne     @@ScanNumberLoop
    mov     [cs:ScanNumberVal],bx

    popad
    ret
ENDP ScanNumber

    ; returns AX= # in HEX
PROC InputHexNumber NEAR
    push    ds
    mov     ax,cs
    mov     ds,ax

    @CursorOn

    mov     dx,offset InputBuffer
    mov     ah,0ah
    int     21h

    xor     dx,dx
    mov     si,offset InputBuffer + 2
    mov     cl,3    ;[InputBuffer+1]
    xor     ch,ch
    cld
@@DecodeLoop:
    lodsb
    cmp     al,"0"
    jb      @@Invalid
    cmp     al,"9"
    ja      @@NAN
    sub     al,"0"
    jmp     @@DoneDecode

@@NAN:
    cmp     al,"a"
    jb      @@Upper
    add     al,"A"-"a"
@@Upper:
    cmp     al,"F"
    ja      @@Invalid
    cmp     al,"A"
    jb      @@Invalid
    add     al,10-"A"
@@DOneDecode:
    shl     dx,4
    and     al,0Fh
    or      dl,al
    dec     cx
    jne     @@DecodeLoop
    
    mov     ax,dx

    @CursorOff

    pop     ds
    ret

@@Invalid:
    mov     ah,9
    mov     dx,offset InvalidMSG
    int     21h
    pop     ds
    jmp     InputHexNumber

ENDP InputHexNumber

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InputBuffer db  4,0,"0000"

SetUpMsg1   db  "Use `+' and `-' keys to select.",13,10,10,10,10
            db  "Select output device: $"
SetupMsg2   db  13,10,10,10,"Select Sampling Rate: ----- Hz$"
SetUpMsg3   db  13,10,"Select BaseAddress: ---- $"
SetUpMsg4   db  13,10,"EMM managers are EVIL! EVIL I tell you!",13,10
            db  "Select DAC IO port: $"
SetUpMsg5   db  13,10,"   2nd DAC IO port: $"
SetUpMsg6   db  13,10,"Select IRQ: -- $"
SetUpMsg99  db  13,10,"Select stereo type: $"

InvalidMSG  db  13,10,"That was not a valid BASE address.",13,10
            db  "Please type in the DAC IO Port: $"

OutPutDevice dw 4
            dw  offset Device1
            dw  offset Device2
            dw  offset Device3
            dw  offset Device4
            dw  offset Device5

StereoType dw 2
            dw  offset Stereo1
            dw  offset Stereo2
            
Device1     db  "Sound Blaster     ",0
Device2     db  "Sound Blaster Pro ",0
Device3     db  "DAC converter     ",0
Device4     db  "2 DAC's - Stereo  ",0
Device5     db  "- none -          ",0

Stereo1     db  "VLA - type stereo",0
Stereo2     db  "WowII type stereo",0

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

ConfigName  db  "promod.cfg",0
Buffer:
LCDevice    db  0       ;0= SB, 1= SBP, 2=DAC, 3=DAC stereo, 4=NONe
LCStereo    db  0       ;0= mono, 1= stereo
LCWowii     db  0       ;0= good stereo, 1=wowii
LCBASE      dw  220h    ;base address for SB/pro
LCInt       db  0       ;interrupt for SB/pro
LCDMA       db  1       ;dma channel - always 1
LCHZ        dw  10000   ;sampling rate
LCLPT1      dw  220h
LCLPT2      dw  220h    
BufferCfgSize  equ $-Buffer

PROC WriteConfig NEAR
        mov     ax,3c00h
        xor     cx,cx
        mov     dx,offset ConfigName
        int     21h
        mov     bx,ax

        mov     ah,40h
        mov     dx,offset buffer
        mov     cx,BufferCfgSize
        int     21h

        mov     ah,3eh
        int     21h

        ret
ENDP WriteConfig       

PROC LoadConfig NEAR
        mov     ax,3d00h
        mov     dx,offset ConfigName
        int     21h
        jc      FileDontExist
        mov     bx,ax

        mov     ah,3fh
        mov     dx,offset buffer
        mov     cx,BufferCfgSize
        int     21h
        ;cmp     cx,ax
        ;jne     FileDontExist
        mov     ah,3eh
        int     21h

    ;mov     [StereoOn],0
    ;mov     [DoWowii],0
    ;mov     [IsDirect],0
    ;mov     [HZ],15000
    ;mov     [MasterVolume],256
    ;mov     [BaseAddress],220h
    ;mov     [IntNumber],7

        mov     ax,[LcLpt1]
        mov     [LptAddress1],ax
        mov     ax,[LcLpt2]
        mov     [LptAddress2],ax
        
        mov     al,[LcInt]
        mov     [IntNumber],al
        mov     ax,[LcBASE]
        mov     [BaseAddress],ax

        mov     ax,[LCHZ]
        mov     [HZ],ax

        mov     al,[LCStereo]
        mov     [StereoOn],al
        mov     al,[LCWowii]
        mov     [DoWoWii],al
        
        mov     [IsDirect],0
        cmp     [LcDevice],2
        jb      @@NoDirect
        mov     [IsDirect],1
@@NODirect:

        xor     al,al
        ret
FileDontExist:
        mov     al,1
        ret
ENDP LoadConfig       

    ;ds:dx points to a string to print.  
    ;cx is the length if cx= 0 prints until whats in al is hit

    ;si= offset to string block header
    ;bp= XY screen pos
    ;returns [ScanNumVal] = device chosen
PROC SelectString NEAR
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax
    
    push    dx cx bx
    mov     bh,0
    mov     ah,3
    int     10h

    mov     bp,dx
    pop     bx cx dx
    
    mov     di,0    ;start with device 0
@@SelStrLoop:
    mov     dx,bp
    mov     ah,2
    int     10h

    mov     bx,di
    inc     bx
    add     bx,bx
    mov     dx,[si+bx]
    mov     cx,0
    mov     al,0
    call    PrintString

    mov     ah,0
    int     16h     ;get a key

    cmp     al,UPKEY
    jne     @@NotPLus
    inc     di
    cmp     di,[si]
    jb      @@SelStrLoop
    dec     di
    jmp     @@SelStrLoop
@@NotPlus:
    cmp     al,DNKEY
    jne     @@NotMinus
    or      di,di
    je      @@SelStrLoop
    dec     di
    jmp     @@SelStrLoop
@@NotMinus:
    cmp     al,ENTERKEY
    jne     @@SelStrLoop
    mov     [cs:ScanNumberVal],di

    pop     ds
    popa
    ret
ENDP SelectString

PROC AskQuestions near
    pusha
    push    ds

    mov     ax,cs
    mov     ds,ax

    call    LoadConfig
    or      al,al
    je      @@NoSound2     ;if we are successful...

    mov     ah,9
    mov     dx,offset SetupMsg1
    int     21h

    mov     si,offset OutPutDevice
    ;mov     bp,0416h
    call    SelectString
    mov     ax,[ScanNumberVal]
    mov     [LCDevice],al
    cmp     ax,4
    je      @@NoSound2
    cmp     ax,1
    jne     @@NotStereo
    mov     [LcStereo],1

    mov     ah,9
    mov     dx,offset SetupMsg99
    int     21h

    mov     si,offset StereoType
    ;mov     bp,0416h
    call    SelectString
    mov     ax,[ScanNumberVal]
    mov     [LCWowii],al

@@NotStereo:

    mov     ah,9
    mov     dx,offset SetupMsg2
    int     21h

    mov     esi,60000
    mov     edi,2000
    mov     ecx,1000
    mov     ebx,12000
    mov     dx,15h
    mov     bp,offset PrintWord
    call    ScanNumber
    mov     ax,[ScanNumberVal]
    mov     [LCHZ],ax
    
    cmp     [LCDevice],2
    jb      @@DoSoundBlaster

    mov     ah,9
    mov     dx,offset SetupMsg4
    int     21h
    call    InputHexNumber
    mov     [LCLpt1],ax
    
    cmp     [LCDevice],3
    jne     @@NoSound
    mov     [LCStereo],1
    mov     ah,9
    mov     dx,offset SetupMsg5
    int     21h
    call    InputHexNumber
    mov     [LCLpt2],ax
    jmp     @@NoSound

@@DoSoundBlaster:
    cmp     [LCHZ],22000
    jbe     @@HzisOk
    mov     [LCHZ],22000
@@HZisOk:
    mov     ah,9
    mov     dx,offset SetupMsg3
    int     21h
    mov     esi,2F0h
    mov     edi,200h
    mov     ecx, 10h
    mov     ebx,220h
    mov     dx,14h
    mov     bp,offset PrintHEXWord
    call    ScanNumber
    mov     ax,[ScanNumberVal]
    mov     [LCBASE],ax

    mov     ah,9
    mov     dx,offset SetupMsg6
    int     21h
    mov     esi,7
    mov     edi,0
    mov     ecx,1
    mov     ebx,7
    mov     dx,12
    mov     bp,offset PrintHEXByte
    call    ScanNumber
    mov     ax,[cs:ScanNumberVal]
    mov     [LCINT],al
    
@@NoSound:
    call    WriteConfig
        
        mov     ax,[LcLpt1]
        mov     [LptAddress1],ax
        mov     ax,[LcLpt2]
        mov     [LptAddress2],ax
        
        mov     al,[LcInt]
        mov     [IntNumber],al
        mov     ax,[LcBASE]
        mov     [BaseAddress],ax

        mov     ax,[LCHZ]
        mov     [HZ],ax

        mov     al,[LCStereo]
        mov     [StereoOn],al
        mov     al,[LCWowii]
        mov     [DoWoWii],al
        
        mov     [IsDirect],0
        cmp     [LcDevice],2
        jb      @@NoDirect
        mov     [IsDirect],1
@@NODirect:

@@NoSound2:
    pop     ds
    popa
    ret
ENDP AskQuestions
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
