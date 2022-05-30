    IDEAL
    DOSSEG
    MODEL SMALL
    STACK 200h
    CODESEG
    p386

InputStatus1=   3dah
MISC_OUTPUT =   3c2h
SC_Index    =   3c4h
CRTC_Index  =   3d4h
Graph_Index =   3ceh
Attr_Index  =   3c0h    ;don't forget to clear flipflop & set bit 5 on index
PEL_Write   =   3c8h
PEL_Read    =   3c7h
PEL_Data    =   3c9h

VGASeg      dw  0A000h
VGAcSeg     dw  0B800h

STRUC FNT_Header
    Id          db  "VLAFNT"
    X           db  1           ;widths in BYTES (8 pixels)
    Y           db  8
    NumChr      db  ?
    StartChr    db  " "         ;char to start with
ENDS

INCLUDE "MCLSUB.INC"

FNTHead FNT_Header  <>
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MACRO @vidmemm0                    ; Vidmem mode 0 (character bitmap dat)
        mov dx,3c4h
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
ENDM

MACRO @vidmemm1                       ; Vidmem mode 1 (screen character dat)
        mov dx,3c4h
        mov ax,00302h
        out dx,ax
        mov ax,00204h
        out dx,ax
        컴
        mov dx,3ceh
        mov ax,01005h
        out dx,ax
        mov ax,00e06h
        out dx,ax
        mov ax,00004h
        out dx,ax
ENDM

FileName_FNT    db  100 dup (0)
EXT_FNT         db  ".FNT",0

HANDLE_FNT      dw  ?

PROC LoadAndDumpFont NEAR
    pusha
    push    ds es

    mov     ax,cs
    mov     ds,ax
    mov     ax,3d00h
    mov     dx,offset FileName_FNT
    int     21h
    jc      @@Abort
    mov     bx,ax
    mov     [cs:HANDLE_FNT],bx

    mov     dx,offset FNThead       ;read in the header
    mov     ah,3fh
    mov     cx,(size FNT_Header)
    int     21h

    mov     ds,[cs:VGAcSeg]
    mov     es,[cs:VGAcSeg]
    @VidMemM0
    movzx   di,[cs:FNTHead.StartChr]
    shl     di,5
    
    movzx   si,[cs:FNTHead.NumChr]

    mov     bx,[cs:HANDLE_FNT]
@@ReadLoop:
    mov     dx,di
    movzx   cx,[cs:FNTHead.Y]
    mov     ah,3fh
    int     21h

    add     di,cx
    sub     cx,32
    neg     cx
    xor     al,al
    cld
    rep     stosb

    dec     si
    jne     @@ReadLoop

    @VidMemM1

    mov     bx,[cs:HANDLE_FNT]
    mov     ah,3eh
    int     21h

  ;  mov     dx,3d4h         ;set char height
  ;  mov     al,9
  ;  out     dx,al
  ;  inc     dx
  ;  in      al,dx
  ;  and     al,11100000b
  ;  or      al,[cs:FNThead.Y]
  ;  out     dx,al

@@Abort:
    pop     es ds
    popa
    ret
ENDP


START:
    mov     ax,cs
    mov     ds,ax

    mov     bx,offset EXT_FNT
    mov     dx,offset FileName_FNT
    mov     bp,0                    ;only put ext if none exists
    call    GetCommandLine

    call    LoadAndDumpFont

    mov     ax,4c00h
    int     21h
END START
