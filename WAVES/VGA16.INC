InputStatus1=   3dah
MISC_OUTPUT =   3c2h
SC_Index    =   3c4h
CRTC_Index  =   3d4h
Graph_Index =   3ceh
Attr_Index  =   3c0h    ;don't forget to clear flipflop & set bit 5 on index
PEL_Write   =   3c8h
PEL_Read    =   3c7h
PEL_Data    =   3c9h

VGASeg      dw  0a000h
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;*   MISC planar mode routines
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

    ;ah: 0000b : bit 0= plane 0, bit 1=plane 1, etc..
    ;
    ;DESTROYS: al, dx
    ;
MACRO  @Set_Write_Plane
    mov     dx,SC_Index
    mov     al,2
    and     ah,1111b
    out     dx,ax
ENDM   @Set_Write_Plane

    ;ah: plane to latch for read (0-3)
    ;
    ;DESTROYS: al, dx
    ;
MACRO  @Set_Read_Plane
    mov     dx,Graph_Index
    mov     al,4
    out     dx,ax
ENDM   @Set_Read_Plane

    ;ah: bit mask to set
    ;
    ;DESTROYS: al, dx
    ;
MACRO  @Set_Bit_Mask
    mov     dx,Graph_Index
    mov     al,8
    out     dx,ax
ENDM   @Set_Bit_Mask

    ;ah: write mode (0-3)
    ;
    ;DESTROYS: ax, dx
    ;
MACRO @Set_Write_Mode
    mov     dx,Graph_Index
    mov     al,5
    out     dx,al
    inc     dx
    in      al,dx
    and     al,11111100b    ;clear out write mode bits
    and     ah,00000011b
    or      al,ah
    out     dx,al
ENDM  @Set_Write_Mode

    ;ah: Read mode (0-1)
    ;
    ;DESTROYS: ax, dx
    ;
MACRO @Set_Read_Mode
    mov     dx,Graph_Index
    mov     al,5
    out     dx,al
    inc     dx
    in      al,dx
    and     al,11110111b    ;clear out write mode bits
    shl     ah,3            ;move bit to correct position
    and     ah,00001000b
    or      al,ah
    out     dx,al
ENDM  @Set_Read_Mode

    ;bx: starting offset
    ;
    ;DESTROYS: ax, dx
    ;
MACRO @Set_Start_Offset
    mov     dx,CRTC_Index
    mov     al,0ch
    mov     ah,bh       ;write the HIGH byte
    out     dx,ax
    inc     al
    mov     ah,bl       ;write the LOW byte
    out     dx,ax
ENDM  @Set_Start_Offset

    ;ah = pelpan value
    ;
    ;DESTROYS: ax, dx
    ;
MACRO @Set_HPP
    mov     dx,InputStatus1
    in      al,dx           ;dummy input
    mov     dx,Attr_Index
    mov     al,33h
    out     dx,al
    mov     al,ah
    out     dx,al
ENDM
    
    ;DESTROYS: ax, dx   - sets pixel pan compatibility
    ;
MACRO @Set_PPC
    mov     dx,InputStatus1
    in      al,dx           ;dummy input
    mov     dx,Attr_Index
    mov     al,30h
    out     dx,al
    inc     dx
    in      al,dx
    dec     dx
    or      al,00100000b
    out     dx,al
ENDM

    ;bx: scanline to set split screen at
    ;
    ;DESTROYS: ax, dx
    ;
MACRO @Set_Split
    mov     al,18h
    mov     ah,bl
    mov     dx,CRTC_Index
    out     dx,ax       ;set bits 0-7

    mov     al,09h
    out     dx,al
    inc     dx
    in      al,dx
    mov     ah,bh
    and     ah,00000010b
    shl     ah,5
    and     al,10111111b
    or      al,ah
    out     dx,al       ;set bit 9

    dec     dx
    mov     al,07h
    out     dx,al
    inc     dx
    in      al,dx
    and     al,11101111b
    mov     ah,bh
    and     ah,00000001b
    shl     ah,4
    or      al,ah
    out     dx,al       ;set bit 8
ENDM @Set_SPlit

MACRO @FullVertWait
 LOCAL @@Vr, @@Nvr
    mov     dx,InputStatus1
@@Vr:
    in      al,dx
    test    al,8
    jz      @@Vr                    ;wait until Verticle Retrace starts
@@Nvr:
    in      al,dx
    test    al,8
    jnz     @@Nvr                   ;wait until Verticle Retrace Ends
ENDM @FullVertWait

MACRO @WaitVert
 LOCAL @@Vr
    mov     dx,InputStatus1
@@VR:
    in      al,dx
    test    al,8
    jz      @@VR                    ;wait until Verticle Retrace starts
ENDM  @WaitVert

MACRO @WaitVertEnd
  LOCAL @@NVr
    mov     dx,InputStatus1
@@NVR:
    in      al,dx
    test    al,8
    jnz     @@NVR                   ;wait until Verticle Retrace Ends
ENDM  @WaitVertEnd
    
    ;si = offset to palette
    ;cx = number of colors to write
    ;al = starting palette register
    ;
    ;DESTROYS: dx,si,cx
    ;
MACRO @WritePalette
    mov     dx,cx
    add     cx,cx
    add     cx,dx
    mov     dx,03c8h
    out     dx,al
    inc     dx
    cld
    rep outsb
ENDM @WritePalette
