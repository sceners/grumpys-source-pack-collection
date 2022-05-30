    IDEAL
    DOSSEG
    MODEL SMALL
    STACK 200h
    CODESEG
    p386
    
    ASSUME CS:@CODE, DS:@CODE
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STRUC VCHHDR
    Ident   db  "VLACH"
    From    db  ?
    X       db  ?
    Y       db  ?
    NumChar db  ?
ENDS

STRUC Pal
    R       db  ?
    G       db  ?
    B       db  ?
ENDS
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
INCLUDE "MODEX.INC"

FileName_VCH    db      "Font5.VCH",0
FileName_PAL    db      "Font5.PAL",0

Seg_VCH         dw      0

Palette         Pal     256 dup (<>)
VCHHEADER       VCHHDR  <>
CharWidths      db      256 dup (0)

TheMessage      db      " THIS IS A REALLY REALLY HUGE SCROLLER!  "
                db      " EACH PIXEL IS NOW AN 8X8 SQUARE!!       "
                db      0

MsgOff          dw      offset TheMessage
CharOff         dw      0       ;offset to current column to draw of chr
XYsize          dw      ?       ;number of bytes in a char
CurColumn       db      1
DestOff         dw      0
SCReenWidth     =       130
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ; Load in the font named in FileName_VCH and loads in the Palette
    ; named in FileName_PAL. 
    ;
    ; Returns CF = 1 if there was an error
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC LoadFont NEAR
    pusha
    push    ds

    mov     ax,cs
    mov     ds,ax
    mov     dx,offset FileName_PAL      ;open the palette file
    mov     ax,3d00h
    int     21h
    jc      @@Error
    mov     bx,ax

    mov     dx,offset Palette           ;read in the palette
    mov     cx,768
    mov     ah,3fh
    int     21h

    mov     ah,3eh                      ;close PAL file
    int     21h

    mov     dx,offset FileName_VCH      ;open VCH file
    mov     ax,3d00h
    int     21h
    jc      @@Error
    mov     bx,ax

    mov     dx,offset VCHHeader         ;load in the header
    mov     cx,size VCHHDR
    mov     ah,3fh
    int     21h

    mov     al,[VCHHEADER.X]            ;calc data size
    mul     [VCHHEADER.Y]
    mov     [XYsize],ax
    movzx   cx,[VCHHEADER.NumChar]
    mul     cx
    mov     cx,ax

    mov     ax,[cs:SEG_VCH]             ;move SEG_VCH into DS, but be sure
    or      ax,ax                       ;the segment isn't 0
    stc
    je      @@Error
    mov     ds,ax
    xor     dx,dx                       ;load in the data
    mov     ah,3fh
    int     21h

    mov     ax,cs
    mov     ds,ax
    mov     dx,offset CharWidths
    movzx   cx,[VCHheader.NumChar]
    mov     ah,3fh
    int     21h                         ;read in widths of chars

    mov     ah,3eh                      ;close VCH file
    int     21h
    clc

@@Error:

    pop     ds
    popa
    ret
ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ;Starts the next letter in the message
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC NewChar NEAR
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax

    mov     si,[MsgOff]     ;get the offset to the next char
@@MsgLoop:
    lodsb
    or      al,al
    jne     @@IsaChar
    mov     si,offset TheMessage
    jmp short @@MsgLoop

@@IsaChar:
    mov     ah,[VCHHEADer.From]
    add     ah,[VCHHEADer.NumChar]
    cmp     al,[VCHHEADer.FROM]
    jb      @@MsgLoop
    cmp     al,ah
    ja      @@MsgLoop

    mov     [MsgOff],si
    sub     al,[VCHheader.From]
    movzx   ax,al
    mov     bx,ax
    mul     [XYsize]
    shl     ax,1
    mov     [CharOff],ax
    
    mov     al,[CharWidths + bx]
    shl     al,1
    mov     [CurColumn],al
    
    pop     ds
    popa
    ret
ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ; Draws the Next column onto the screen, calls NewChar if done with
    ; current character
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC DrawColumn NEAR
    pusha
    push    ds es fs
    mov     ax,cs
    mov     ds,ax

    mov     bx,[DestOff]
    add     bx,2
    @Set_Start_Offset

    dec     [CurColumn]
    jne     @@NoNew

    call    NewChar

@@NoNew:
    mov     fs,[SEG_VCH]
    mov     es,[VGASEG]
    mov     si,[CharOff]    ;fs:si points to the data
    shr     si,1
    mov     di,[DestOff]

    movzx   dx,[VCHheader.X]
    movzx   cx,[VCHheader.Y]
    mov     bp,SCReenWidth         ;screen width

@@Zloop:
    mov     al,[fs:si]
    mov     [es:di],al
    mov     [es:di+SCReenWidth/2],al
    add     di,bp

    add     si,dx

    loop    @@ZLoop

    inc     [DestOff]
    cmp     [DestOff],ScreenWidth/2
    jb      @@okok

    mov     [DestOff],0

@@okok:
    inc     [CharOff]

    pop     fs es ds
    popa
    ret
ENDP
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
START:
    mov     ax,cs
    mov     ds,ax

    mov     ax,ss
    mov     bx,sp
    add     bx,15
    shr     bx,4
    add     ax,bx
    mov     [SEG_VCH],ax

    @SetModeX m256x200x256, 520

    call    LoadFont
    mov     si,offset Palette
    mov     cx,256
    mov     al,0
    @WritePalette

    mov     dx,CRTC_Index
    mov     al,9
    mov     ah,15    ;[DaHeight]
    out     dx,ax

@@MainLoop:
    @FullVertWait
    call    DrawColumn

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
