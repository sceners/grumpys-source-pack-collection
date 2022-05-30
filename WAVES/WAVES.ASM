    Dosseg
    .Model Small
    .Stack 200h
    .Code
    .386
    Assume CS:@CODE, DS:@CODE
    Ideal
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Include "Vga16.inc"
Save1       db  "plane1.dat",0
Save2       db  "plane2.dat",0

Palette     db  24, 19, 17
            db  34, 27, 26
            db  17, 13, 13
            db  48, 38, 36

            db  24, 19, 47
            db  34, 27, 56
            db  17, 13, 43
            db  48, 38, 63

            db  34, 29, 27
            db  44, 37, 36
            db  27, 23, 23
            db  58, 48, 46

            db  63, 29, 27
            db  63, 37, 36
            db  63, 23, 23
            db  63, 48, 46

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC LoadThePicture
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax

    mov     ah,0001b
    @Set_Write_Plane

    mov     ax,3d00h
    mov     dx,offset save1
    int     21h
    jc      @@NoFile
    mov     bx,ax

    mov     ds,[cs:VGAseg]
    xor     dx,dx
    mov     cx,640/8*480
    mov     ah,3fh
    int     21h

    mov     ah,3eh
    int     21h

    mov     ah,0010b
    @Set_Write_Plane

    mov     ax,cs
    mov     ds,ax
    mov     ax,3d00h
    mov     dx,offset save2
    int     21h
    jc      @@NoFile
    mov     bx,ax

    mov     ds,[cs:VGAseg]
    xor     dx,dx
    mov     cx,640/8*480
    mov     ah,3fh
    int     21h

    mov     ah,3eh
    int     21h
@@NoFile:
    pop     ds
    popa
    ret
ENDP
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Include "sincos1k.dw"
ANGLEMASK = 11111111110b
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
LABEL Msg BYTE    
    REPT 23
        db  "This is a test.  "
    ENDM
        db  13,10,10,10
        db  "            Hmmm... Does this look familiar to anyone???$"
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
LABEL EndMask Byte
    Rept 80
        db  00000000b,10000000b,11000000b,11100000b
        db  11110000b,11111000b,11111100b,11111110b
    Endm
LABEL FrontMask Byte
    Rept 80
        db  00000000b,00000001b,00000011b,00000111b
        db  00001111b,00011111b,00111111b,01111111b
    Endm

Angle   dw  0,10
TmpXchg dd  0
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ;bx hi = angle 1
    ;bx lo = angle 2
PROC DrawHLineMiddle
    cld
    mov     bp,40        ;line we are on
@@BigLoop:
    mov     di,bp
    dec     di

    ror     ebx,16

    mov     si,bx
    and     si,ANGLEMASK
    mov     ax,[Sine + si]
    add     ax,260
    shr     ax,2
    sub     bx,11

    ror     ebx,16

    add     bx,7
    mov     si,bx
    and     si,ANGLEMASK
    add     ax,[Cosine + si]
    mov     si,ax
    add     si,260
    shr     si,3
    mov     cx,si
    shr     cx,3            ;divide by 8
    inc     cx
    jcxz    @@SkipRep
    sub     di,cx
    dec     di
    xor     al,al
    stosb
@@SkipRep:
    mov     ah,11111111b
    mov     al,[FrontMask + si]
    stosw

    xchg    ebx,[TmpXchg]
    ror     ebx,16
    
    mov     di,bp
    inc     di
    mov     si,bx
    and     si,ANGLEMASK
    mov     ax,[Sine + si]
    add     ax,260
    shr     ax,2
    add     bx,7

    ror     ebx,16

    add     bx,3
    mov     si,bx
    and     si,ANGLEMASK
    add     ax,[Cosine + si]
    mov     si,ax
    add     si,260
    shr     si,3
    mov     cx,si
    shr     cx,3            ;divide by 8
    jcxz    @@SkipRep2
    add     di,cx
    dec     di
    mov     al,11111111b
    stosb
@@SkipRep2:
    movzx   ax,[EndMask + si]
    stosw

    xchg    ebx,[TmpXchg]

    add     bp,640/8
    cmp     bp,640/8*480
    jb      @@BigLoop

    ret
ENDP

PROC DrawHLineRight

    cld
    mov     bp,79        ;line we are on
@@BigLoop:
    mov     di,bp
    dec     di

    ror     ebx,16

    mov     si,bx
    and     si,ANGLEMASK
    mov     ax,[Sine + si]
    add     ax,260
    shr     ax,2
    add     bx,9
    
    ror     ebx,16
    
    sub     bx,4
    mov     si,bx
    and     si,ANGLEMASK
    add     ax,[Cosine + si]
    mov     si,ax
    add     si,260
    shr     si,2
    mov     cx,si
    shr     cx,3            ;divide by 8
    inc     cx
    jcxz    @@SkipRep
    sub     di,cx
    dec     di
    xor     al,al
    stosb
@@SkipRep:
    mov     ah,11111111b
    mov     al,[FrontMask + si]
    stosw

    add     bp,640/8
    cmp     bp,640/8*480
    jb      @@BigLoop

    ret
ENDP

PROC DrawHLineLeft
    cld
    mov     bp,0        ;line we are on
@@BigLoop:
    mov     di,bp

    ror     ebx,16

    mov     si,bx
    and     si,ANGLEMASK
    mov     ax,[Sine + si]
    add     ax,260
    shr     ax,2
    sub     bx,9

    ror     ebx,16
    
    add     bx,4
    mov     si,bx
    and     si,ANGLEMASK
    add     ax,[Cosine + si]
    mov     si,ax
    add     si,260
    shr     si,2
    mov     cx,si
    shr     cx,3            ;divide by 8
    jcxz    @@SkipRep
    add     di,cx
    dec     di
    mov     al,11111111b
    stosb
@@SkipRep:
    movzx   ax,[EndMask + si]
    stosw

    add     bp,640/8
    cmp     bp,640/8*480
    jb      @@BigLoop

    ret
ENDP

PROC SetUp
    xor     di,di
    mov     cx,640/8*480/2
    xor     ax,ax
    cld
    rep     stosw

    xor     di,di
    xor     eax,eax
    dec     eax
@@TheLoop:
    mov     [es:di],eax
    mov     [es:di+36],eax
    mov     [es:di+40],eax
    mov     [es:di+76],eax
    add     di,80
    cmp     di,80*480
    jb      @@TheLoop

    ret
ENDP

PROC SetPalette
    mov     bl,0
@@PalLoop:
    mov     dx,03dah
    in      al,dx

    mov     dx,03c0h
    mov     al,bl
    out     dx,al
    out     dx,al
    inc     bl
    cmp     bl,10h
    jb      @@PalLoop

    mov     al,20h
    out     dx,al
    
    mov     si,offset Palette
    mov     cx,16*16
    mov     al,0
    @WritePalette
    ret
ENDP
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

Start:
    mov     ax,cs
    mov     ds,ax

    mov     ax,12h
    int     10h

    mov     ah,9
    mov     dx,offset Msg
    int     21h

    call    SetPalette

    call    LoadThePicture

    mov     ax,cs
    mov     ds,ax
    mov     es,[VGAseg]
    
    mov     ah,1000b
    @Set_Write_Plane

    call    Setup

@@MainLoop:
;    @WaitVert
    @FullVertWait
    mov     bx,[Angle+2]
    shl     ebx,16
    mov     bx,[angle]
    call    DrawHLineLeft

    mov     bx,[Angle+2]
    shl     ebx,16
    mov     bx,[angle]
    call    DrawHLineRight
    
    mov     bx,[Angle]
    shl     ebx,16
    mov     bx,[angle+2]
    mov     [TmpXchg],ebx
    mov     bx,[Angle+2]
    shl     ebx,16
    mov     bx,[angle]
    call    DrawHLineMiddle

    add     [Angle],7
    add     [Angle+2],17
    
    mov     ah,1
    int     16h
    jz      @@MainLoop

    mov     ah,0
    int     16h
    mov     ax,3
    int     10h
    mov     ah,4ch
    int     21h
ENd Start
