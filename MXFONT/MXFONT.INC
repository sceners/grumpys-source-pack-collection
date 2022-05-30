;
; Order of operation:
; 1) Call StealFont (grabs 8x8 bios font)
; 2) Change into any 256 color PLANAR mode
; 3) Call SetDefPal, which sets up the default palette useing the last
;       few palette registers.  This is not neccessary, but if you want 
;       to use the predefined colors, it is needed.
; ?) Call PrintText to print a message
;       DI = Ypos, AX = Xpos, DS:SI -> zero terminating string to process.
;       1 = change color command. 2->255 are characters. no line feeds or
;       carriage returns.
; OR
; ?) Call PrintList, which will print out a list of messages all across the
;       screen. DS:BX -> the MsgHdr's
;
; NOTE: The Y position is in PIXELS, the X position is in 4 pixel increments.
;       All characters are 8 pixels wide. (2 X positions.)
;       This code is set up for IDEAL mode.
;
;   Written by Draeden of VLA
;
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STRUC PalStruc
    R   db  ?
    G   db  ?
    B   db  ?
ENDS

STRUC MsgHdr
    Off     dw  ?
    Xpos    dw  ?
    Ypos    dw  ?
ENDS

NumDefPal = 9

BLACK   =   0
BLUE    =   255
GREEN   =   254
RED     =   253
GREY1   =   252
GREY2   =   251
GREY3   =   250
GREY4   =   249
GREY5   =   248
RED2    =   247

SCRW    =   80
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DefPal      PalStruc <20,00,00>,<25,25,25>,<35,35,35>,<45,45,45>,<56,56,56>
            PalStruc <63,63,63>,<40,00,00>,<00,40,00>,<00,00,40>

Font8x8     db  256*8   dup (0) ;holding place for font

TextColor   db  RED
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ;DS:BX = Ptr to list
    ;   CX = # of entries
PROC PrintList
    pusha
@@MSgLoop:
    mov     si,[(MsgHdr PTR bx).Off]
    mov     ax,[(MsgHdr PTR bx).Xpos]
    mov     di,[(MsgHdr PTR bx).Ypos]
    call    PrintText

    add     bx,(size MsgHdr)
    dec     cx
    jne     @@MsgLoop
    popa
    ret
ENDP

    ;di = Ypos
    ;ax = Xpos
    ;ds:si = ptr to zero terminating string
PROC PrintText
    pusha
    push    es
    mov     es,[cs:VGAseg]

    imul    di,SCRW
    add     di,ax

@@PrintLoop:
    lodsb
    or      al,al
    je      @@Done
    dec     al
    je      @@ColorChange
    dec     al

    movzx   bx,al
    shl     bx,3        ;*8
    mov     cl,8
    mov     ch,[cs:TextColor]
    mov     bp,di
@@CopyChar:
    mov     ah,[cs:Font8x8 + bx]
    and     ah,1111b
    @Set_Write_Plane
    mov     [es:bp],ch
    mov     ah,[cs:Font8x8 + bx]
    shr     ah,4
    @Set_Write_Plane
    mov     [es:bp+1],ch

    add     bp,SCRW
    inc     bx

    dec     cl
    jne     @@CopyChar

    add     di,2
    jmp     short @@PrintLoop

@@Done:
    pop     es
    popa
    ret
@@ColorChange:
    lodsb
    mov     [cs:TextColor],al
    jmp     @@PrintLoop
ENDP

    ;Immediatly after calling this routine, you MUST do a mode change
    ; to properly restore the status of the VGA card.
PROC StealFont
    pusha
    push    es ds
    
    mov     ax,0003h
    int     10h             ;set VGA 80x25x16 char
    mov     ax,1112h
    mov     bl,0
    int     10h             ;load 8x8 bios font into bank 0

    mov dx,3c4h             ;setup to read memory
    mov ax,00402h
    out dx,ax
    mov ax,00604h
    out dx,ax
    컴
    mov dx,3ceh
    mov ax,00005h
    out dx,ax
    mov ax,00c06h
    out dx,ax
    mov ax,00204h
    out dx,ax

    mov     ax,0b800h
    mov     ds,ax
    mov     ax,cs
    mov     es,ax

    mov     di,offset Font8x8
    mov     si,64               ;start w/ char #2, not #0 

    cld
    mov     dx,255      ;grab 255 chars
@@GrabLoop:
    mov     cx,8
@@UpHere:
    lodsb
    xor     ah,ah    

   REPT 8               ;mirror the byte- if this isn't done the chars will
    shl     al,1        ; be backwards..
    rcr     ah,1
   ENDM
    mov     al,ah
    stosb
    loop    @@UpHere
    add     si,32-8
    dec     dx
    jne     @@GrabLoop

    pop     ds es
    popa
    ret
ENDP

PROC SetDefPal
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax
    mov     si,offset DefPal
    mov     cx,NumDefPal
    mov     al,256-NumDefPal
    @WritePalette
    pop     ds
    popa
    ret
ENDP

