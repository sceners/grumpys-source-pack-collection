        IDEAL
        DOSSEG
        MODEL SMALL
        STACK 200h
        CODESEG
        ASSUME  DS:@CODE, CS:@CODE
        Locals
        P386N
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INCLUDE "MODEX.INC"
INCLUDE "MCLSUB.INC"
INCLUDE "GCX.INC"
INCLUDE "PRINTSUB.INC"
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UsageMsg    db  "GCX written by Draeden of VLA",13,10,10
            db  "USE: GCX filename[.TGA]",13,10,"$"

FileErrorMsg db "ERROR: TGA File not found.",13,10,"$"
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
START:
    mov     ax,cs
    mov     ds,ax
    mov     [PSPseg],es

    call    CaptureFilename
    jc      @@NoFileAbort

    mov     bx,ss
    add     bx,20h
    mov     [PicSeg],bx
    add     bx,4096
    mov     [CharSeg],bx

    push    es              ;clear the Picture segment
    mov     es,[Picseg]
    xor     di,di
    mov     cx,8000h
    xor     ax,ax
    rep     stosw
    pop     es
    
    call    LoadPicture
    jc      @@NoFileAbort

    call    StealFont       ;grabs 8x8 text font

    @SetModeX   m320x240x256, 320
    mov     bx,[Split]
    @Set_Split
    @Set_PPC
    mov     bx,240*SCRW
    @Set_Start_Offset

    mov     si,offset palette
    mov     al,0
    mov     cx,256-9
    @WritePalette
    mov     si,offset DefPal
    mov     al,256-9
    mov     cx,8
    @WritePalette

    call    SetUpStuff
    call    GetDimensions
    call    ReFreshScreen
@@MainLoop:
    call    ScrollSplit
    call    CheckKeys
    jnc     @@MainLoop

    mov     ax,0003h                ;reset screen to text
    int     10h
    mov     ax,4c00h                ; return control to 
    int     21h                     ; DOS and exit

@@NoFileAbort:
    mov     ax,cs
    mov     ds,ax
    mov     ah,9
    mov     dx,offset FileErrorMsg
    int     21h
    mov     ah,9
    mov     dx,offset UsageMsg
    int     21h
    mov     ax,4c00h                ; return control to 
    int     21h                     ; DOS and exit
END     start
