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

FileName_VCH    db      "palFont.VCH",0
FileName_PAL    db      "palFont.PAL",0

Seg_VCH         dw      0

Palette         Pal     256 dup (<>)

LABEL BarPal Pal
    i = 0
    REPT 4
        Pal <i,i/3,i/2>
        i=i+2
    ENDM
    REPT 8
        Pal <i,i/3,i/2>
        i=i+3
    ENDM
    REPT 4
        Pal <i,i/3,i/2>
        i=i+2
    ENDM
    REPT 4
        Pal <i,i/3,i/2>
        i=i-2
    ENDM
    REPT 8
        Pal <i,i/3,i/2>
        i=i-3
    ENDM
    REPT 4
        Pal <i,i/3,i/2>
        i=i-2
    ENDM

VCHHEADER       VCHHDR  <>
CharWidths      db      256 dup (0)

TheMessage      db      "  WOW!! THIS SCROLLER LOOKS REALLY COMPLICATED! "
                db      "  BUT IT ISN'T..  IT'S A PALETTE ROTATE AND A "
                db      "SCROLLER.  KINDA WEIRD, EH?  "
                db      "  RESOLUTION IS: 256X200 PLANAR WITH A CELL HEIGHT "
                db      "OF 1 (2 SCAN LINES PER PIXEL) AND THE VIRTUAL WIDTH "
                db      "IS 520 PIXELS (2X256 + 8, TO HIDE THE AREA THAT'S BEING "
                db      "WORKED ON)          "
                db      0

MsgOff          dw      offset TheMessage
CharOff         dw      0       ;offset to current column to draw of chr
XYsize          dw      ?       ;number of bytes in a char
CurColumn       db      1
DestOff         dw      0
SCReenWidth     =       130

TempBG          db      128
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    Numcolors   dw  32      ;# of colors to rotate
    NumColors3  dw  32*3    ;# of colors*3
    StartAt     db  128     ;color to start rotate at
    PalIndex    dw  0       ;color to start write at- increased every time
                            ;to produce the rotating effect
    PalIndexVel dw  2       ;amount PalIndex Changes for each screen

    PalOffset   dw  offset BarPal
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC RotatePalette NEAR
    pusha

    call  WritePalette

    mov   ax,[PalIndexVel]
    add   [PalIndex],ax    ;change the palette index

    mov   ax,[PalIndex]    ;are we over the number of colors?
    mov   bx,[NumColors]

    cmp   ax,bx
    jl    NotTooHigh
    sub   [PalIndex],bx    ;add [Numcolors] to the index
    jmp   NotTooLow
NotTooHigh:
    cmp   ax,0
    jge   NotTooLow
    add   [PalIndex],bx    ;subtract [Numcolors] to the index
NotTooLow:

    popa
    ret
ENDP

PROC WritePalette NEAR        
    cld

    mov   dx,[PalIndex]
    mov   bx,dx
    add   bx,bx           ;This just multiplies
    add   bx,dx           ;bx by three ( bx = bx + 2*bx )

    mov   si,[PalOffset]
    mov   dx,03c8h
    mov   ax,[PalIndex]
    add   al,[StartAt]
    out   dx,al           ;start writing at [PalIndex]+[StartAt]
    inc   dx
    mov   cx,[NumColors3]
    sub   cx,bx           ;get the number of colors to write
    rep outsb

    mov   al,[StartAt]
    dec   dx              ;point to palette index
    out   dx,al           ;out the number we want to start writing at 
    inc   dx
    mov   cx,bx           ;get the number of colors to write
    rep outsb             ;note that SI is already where we want it

    ret
ENDP         ;well, that's all there is to it

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
    mov     [CharOff],ax
    
    mov     al,[CharWidths + bx]
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

    cmp     [TempBG],128+32
    jb      @@BGok
    mov     [TempBG],128
@@BGok:

    mov     bx,[DestOff]
    add     bx,2
    @Set_Start_Offset

    sub     [CurColumn],4
    jg      @@NoNew

    call    NewChar

@@NoNew:
    mov     fs,[SEG_VCH]
    mov     es,[VGASEG]

    mov     bp,SCReenWidth         ;screen width

    mov     dx,SC_Index
    mov     ax,0102h
    out     dx,ax

    movzx   dx,[VCHheader.X]
    movzx   cx,[VCHheader.Y]
    mov     si,[CharOff]    ;fs:si points to the data
    mov     di,[DestOff]
@@Zloop:
    mov     al,[fs:si]
    or      al,al
    jne     short @@ok1
    mov     al,[cs:TempBG]
@@ok1:
    mov     [es:di],al
    mov     [es:di+SCReenWidth/2],al
    add     di,bp

    add     si,dx

    loop    @@ZLoop

    inc     [cs:TempBG]
    
    mov     dx,SC_Index
    mov     ax,0202h
    out     dx,ax

    movzx   dx,[VCHheader.X]
    movzx   cx,[VCHheader.Y]
    mov     si,[CharOff]    ;fs:si points to the data
    inc     si
    mov     di,[DestOff]
@@Zloop2:
    mov     al,[fs:si]
    or      al,al
    jne     short @@ok2
    mov     al,[cs:TempBG]
@@ok2:
    mov     [es:di],al
    mov     [es:di+SCReenWidth/2],al
    add     di,bp

    add     si,dx

    loop    @@ZLoop2
    
    inc     [cs:TempBG]

    mov     dx,SC_Index
    mov     ax,0402h
    out     dx,ax

    movzx   dx,[VCHheader.X]
    movzx   cx,[VCHheader.Y]
    mov     si,[CharOff]    ;fs:si points to the data
    add     si,2
    mov     di,[DestOff]
@@Zloop3:
    mov     al,[fs:si]
    or      al,al
    jne     short @@ok3
    mov     al,[cs:TempBG]
@@ok3:
    mov     [es:di],al
    mov     [es:di+SCReenWidth/2],al
    add     di,bp

    add     si,dx

    loop    @@ZLoop3

    inc     [cs:TempBG]

    mov     dx,SC_Index
    mov     ax,0802h
    out     dx,ax

    movzx   dx,[VCHheader.X]
    movzx   cx,[VCHheader.Y]
    mov     si,[CharOff]    ;fs:si points to the data
    add     si,3
    mov     di,[DestOff]
@@Zloop4:
    mov     al,[fs:si]
    or      al,al
    jne     short @@ok4
    mov     al,[cs:TempBG]
@@ok4:
    mov     [es:di],al
    mov     [es:di+SCReenWidth/2],al
    add     di,bp

    add     si,dx

    loop    @@ZLoop4

    inc     [cs:TempBG]

    inc     [DestOff]
    cmp     [DestOff],ScreenWidth/2
    jb      @@okok

    mov     [DestOff],0

@@okok:
    add     [CharOff],4

    pop     fs es ds
    popa
    ret
ENDP

HPPPOS  db  0

PROC Scrollit NEAR
    pusha

    mov     ah,[HPPpos]
    add     ah,2 *2
    mov     [HPPpos],ah
    cmp     ah,8
    jb      @@JustSetIt
    sub     ah,8
    mov     [HPPpos],ah

    call    DrawColumn

@@JustSetIt:
    mov     ah,[HPPpos]
    @Set_HPP

    popa
    ret
ENDP

PROC FilterFont NEAR
    pusha
    push    ds es

    mov     ds,[cs:SEG_VCH]
    mov     es,[cs:SEG_VCH]
    xor     di,di
    xor     si,si

    mov     al,[cs:VCHHEADER.X]            ;calc data size
    mul     [cs:VCHHEADER.Y]
    mov     [cs:XYsize],ax
    movzx   cx,[cs:VCHHEADER.NumChar]
    mul     cx
    mov     cx,ax

@@FiltLoop:
    lodsb
    cmp     al,1
    je      short @@ok
    xor     al,al
@@ok:
    stosb
    loop    @@FiltLoop

    pop     es ds
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
    call    FilterFont

    mov     si,offset Palette
    mov     cx,256
    mov     al,0
    @WritePalette
    
    mov     dx,CRTC_Index
    mov     al,9
    mov     ah,1    ;each dot is 2 high (use HEIGHT-1)
    out     dx,ax

    @SET_PPC    ;set Pixel Panning Compatibility
                ;so the split screen, if I had one, would not be disturbed.
                
@@MainLoop:
    @FullVertWait
    call    RotatePalette
    call    Scrollit

    ;call    DrawColumn

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
