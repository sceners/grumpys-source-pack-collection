    Dosseg
    .Model Small
    .Stack 200h
    .Code
    .386
    Assume CS:@CODE, DS:@CODE
    Ideal
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Include "Vga16.inc"

PictureSeg  dw  ?
PictureName db  "VlaVla.TGA",0
Save1       db  "plane1.dat",0
Save2       db  "plane2.dat",0

Palette     db  38*64/100, 30*64/100, 28*64/100
            db  53*64/100, 42*64/100, 41*64/100
            db  27*64/100, 20*64/100, 20*64/100
            db  75*64/100, 59*64/100, 56*64/100
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC LoadThePicture
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax

    mov     ax,3d00h
    mov     dx,offset PictureName
    int     21h
    jc      @@NoFile
    mov     bx,ax

    xor     cx,cx
    mov     dx,768+18
    mov     ax,4200h        ;move file ptr past header of tga
    int     21h

    mov     bp,[PictureSeg]
@@LoadLoop:
    mov     ds,bp
    xor     dx,dx
    mov     cx,0fff0h
    mov     ah,3fh
    int     21h             ;read 0FFF0h bytes
    cmp     cx,ax
    jne     @@Alldone       ;we are done if ax != cx

    add     bp,0fffh
    jmp     @@LoadLoop
@@AllDone:
    mov     ah,3eh
    int     21h

@@NoFile:
    pop     ds
    popa
    ret
ENDP

PROC SeperateThePicture
    pusha
    push    ds es
    mov     es,[cs:VGAseg]

    mov     ah,0001b
    @Set_Write_Plane

    mov     bp,640*480/8
    xor     si,si
    mov     ds,[cs:PictureSeg]   
    xor     di,di
    cld
@@BigLoop:
    xor     bl,bl
    lodsw
    and     ax,0000000100000001b
    or      bl,al
    shl     bl,1
    or      bl,ah
    shl     bl,1
    lodsw
    and     ax,0000000100000001b
    or      bl,al
    shl     bl,1
    or      bl,ah
    shl     bl,1
    lodsw
    and     ax,0000000100000001b
    or      bl,al
    shl     bl,1
    or      bl,ah
    shl     bl,1
    lodsw
    and     ax,0000000100000001b
    or      bl,al
    shl     bl,1
    or      bl,ah
    ;shl     bl,1
    mov     al,bl
    stosb

    mov     ax,ds
    mov     bx,si
    shr     bx,4
    add     ax,bx
    mov     ds,ax
    and     si,0fh  ;fix up ds:si
                                 
    dec     bp
    jne     @@BigLoop

    mov     ah,0010b
    @Set_Write_Plane

    mov     bp,640*480/8
    xor     si,si
    mov     ds,[cs:PictureSeg]
    xor     di,di
    cld
@@BigLoop2:
    xor     bl,bl
    lodsw
    and     ax,0000001000000010b
    or      bl,al
    shl     bl,1
    or      bl,ah
    shl     bl,1
    lodsw
    and     ax,0000001000000010b
    or      bl,al
    shl     bl,1
    or      bl,ah
    shl     bl,1
    lodsw
    and     ax,0000001000000010b
    or      bl,al
    shl     bl,1
    or      bl,ah
    shl     bl,1
    lodsw
    and     ax,0000001000000010b
    or      bl,al
    rol     bl,1
    or      bl,ah
    ror     bl,1
    mov     al,bl
    stosb

    mov     ax,ds
    mov     bx,si
    shr     bx,4
    add     ax,bx
    mov     ds,ax
    and     si,0fh  ;fix up ds:si
                                 
    dec     bp
    jne     @@BigLoop2

    pop     es ds
    popa
    ret
ENDP

PROC SaveThePicture
    mov     ax,cs
    mov     ds,ax

    mov     ah,0
    @Set_Read_Plane

    mov     ax,3c00h        ;create file
    mov     dx,offset Save1
    int     21h
    mov     bx,ax

    mov     ds,[VgaSeg]
    xor     dx,dx
    mov     cx,640/8*480
    mov     ah,40h
    int     21h

    mov     ah,3eh
    int     21h

    mov     ax,cs
    mov     ds,ax
    
    mov     ah,1
    @Set_Read_Plane

    mov     ax,3c00h        ;create file
    mov     dx,offset Save2
    int     21h
    mov     bx,ax

    mov     ds,[VgaSeg]
    xor     dx,dx
    mov     cx,640/8*480
    mov     ah,40h
    int     21h

    mov     ah,3eh
    int     21h

    ret
ENDP
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Start:
    mov     ax,cs
    mov     ds,ax
    mov     ax,ss
    add     ax,20h
    mov     [PictureSeg],ax

    mov     ax,12h
    int     10h

    mov     si,offset Palette
    mov     cx,4
    mov     al,0
    @WritePalette

    call    LoadThePicture

    call    SeperateThePicture

    call    SaveThePicture

    mov     ah,0
    int     16h
    mov     ax,3
    int     10h
    mov     ah,4ch
    int     21h
ENd Start
