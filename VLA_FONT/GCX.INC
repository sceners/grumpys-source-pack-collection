PAGEUP  =   73
PAGEDOWN=   81

CSRUP   =   72
CSRDN   =   80
CSRLF   =   75
CSRRT   =   77

CSRUPC  =   141
CSRDNC  =   145
CSRLFC  =   115
CSRRTC  =   116
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
ENLARGEOFFSET = 30*SCRW+1

MINX    =   2
MINY    =   2
MAXX    =   38
MAXY    =   38

STRUC PalStruc
    R   db  ?
    G   db  ?
    B   db  ?
ENDS

STRUC VchHdr
    ID      db  "VGACH"
    From    db  " "
    SizeX   db  5
    SizeY   db  5
    NumChar db  64
ENDS

STRUC MsgHdr
    Off     dw  ?
    Xpos    dw  ?
    Ypos    dw  ?
ENDS

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
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
SCRW    =   80
Split   dw  80
SplitDest db    1   ;0= 400, 1=80

OldX    dw  ?
OldY    dw  ?

Credits     db  1,BLUE,"  Character Grabber",1,GREEN," by "
            db  1,RED,"Draeden",1,GREEN," of ",1,RED,"VLA",0

Curchar db  0
Xpos    dw  0
Ypos    dw  0

PSPSeg      dw  ?
FileNameTGA db  120 dup (0)
FileNameVCH db  120 dup (0)
TGAexten    db  ".TGA",0
VCHexten    db  ".VCH",0

VCHheader   VCHHDR  <>

Palette     PalStruc 256 dup (<>)
DefPal      PalStruc <10,00,00>,<25,25,25>,<35,35,35>,<45,45,45>,<56,56,56>
            PalStruc <63,63,63>,<40,00,00>,<00,40,00>,<00,00,40>

Font8x8     db  256*8   dup (0) ;holding place for font

TextColor   db  RED
    
PicSeg      dw  ?
CharSeg     dw  ?
        
NumChar     db  64

SizeMsg db  1,GREEN,"`-' W:-  H:-  #:  -/    X:  - Y:  - ",0
SizeMsg2 db 1,GREY2," A    12   15    21       252   123",0
ClrSize db  1,BLACK," €    €€   €€   €€€ €€€   €€€   €€€",0
INST1   db  1,RED,"^G: Grab Image   ^D: ReDimension       ",0
INST2   db  1,RED,"^S: Save Set     ^Q: Quit              ",0
        
NumMsgs =   7
Messages MsgHdr <offset Credits,1,1>,<Offset FileNameVCH,1,10>
        MsgHdr  <offset Inst1,1,184>,<Offset Inst2,1,192>
        MsgHdr  <offset SizeMsg,1,18>
ReFMsg  MsgHdr  <Offset ClrSize,1,18>
        MsgHdr  <offset SizeMsg2,1,18>

DimMsg1 db  1,GREY2,"Select size using arrow keys",0
DimMsg2 db  1,GREY2,"Hit ",1,RED,"[ENTER]",1,GreY2," when finished",0
DimMsg3 db  1,GREY2," Width: "
 Wtext  db  "000",0
DimMsg4 db  1,GREY2,"Height: "
 Htext  db  "000",0
DimMsg5 db  1,GREY2," Chars: "
 Ntext  db  "000",0
DimMsg6 db  1,GREY2,"  From: "
 Ftext  db  "000",0

DimMsgE db  1,BLACK,"        €€€",0

NumDimMsg   = 2
DimMsgH     MsgHdr  <offset DimMsg1,10,60>,<offset DimMsg2,13,120>
DimMsgH2    MsgHdr  <offset DimMsgE,25,80>,<offset DimMsgE,25,90>
            MsgHdr  <offset DimMsgE,25,100>,<offset DimMsgE,25,110>
            MsgHdr  <offset DimMsg3,25,80>,<offset DimMsg4,25,90>
            MsgHdr  <offset DimMsg5,25,100>,<offset DimMsg6,25,110>
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
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
    ƒƒ
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

   REPT 8
    shl     al,1
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

    ;Changes the TGA palette to write to the VGA card
    ; IN: DS = CS
PROC Palettesetup
    pusha

    xor     di,di
    mov     cx,256
@@FixItLoop:
    mov     al,[di + Palette.R]
    mov     ah,[di + Palette.G]
    mov     bl,[di + Palette.B]
    shr     al,2
    shr     ah,2
    shr     bl,2
    mov     [di + Palette.R],bl     ;swap B & R
    mov     [di + Palette.G],ah
    mov     [di + Palette.B],al

    add     di,(size PalStruc)
    dec     cx
    jne     @@FixItLoop

    popa
    ret
ENDP

    ;Grab 2 copies of the command line w/ different endings...
PROC CaptureFilename
    pusha
    push    es ds

    mov     ax,cs
    mov     ds,ax
    mov     es,[PSPseg]

    mov     dx,offset FileNameTGA
    mov     bx,offset TGAexten
    mov     bp,1
    call    GetCommandLine
    or      ax,ax
    je      @@NoFile

    mov     dx,offset FileNameVCH
    mov     bx,offset VCHexten
    mov     bp,1
    call    GetCommandLine
    clc 
    jmp     short @@Done

@@NoFile:
    stc
@@Done:
    pop     ds es
    popa
    ret
ENDP

PROC LoadPicture
    pusha
    mov     ax,cs
    mov     ds,ax
    
    cld
    mov     dx,offset FileNameVCH
    mov     ax,3d00h
    int     21h
    jc      @@NoVchFile
    mov     bx,ax

    mov     cx,9
    mov     dx,offset VCHHeader
    mov     ah,3fh
    int     21h
    
    mov     al,[VCHheader.SizeX]        ;calc # of bytes to read
    movzx   cx,[VCHheader.NumChar]
    mul     [VCHheader.SizeY]
    mul     cx

    mov     cx,ax

    push    ds                          ;read in the file
    mov     ds,[CharSeg]
    xor     dx,dx
    mov     ax,3f00h
    int     21h
    pop     ds

    mov     ax,3e00h                    ;close the VCH file
    int     21h
    
@@NoVchFile:
    mov     dx,offset FileNameTGA       ;load in 320x200x256 screen
    mov     ax,3d00h
    int     21h
    jc      @@Abort
    mov     bx,ax

    sub     cx,cx                       ;18 past beginning
    mov     dx,18
    mov     ax,4200h                    ;move FP rel. to start
    int     21h

    mov     cx,768
    mov     dx,offset Palette           ;read in the palette
    mov     ah,3fh
    int     21h

    call    PaletteSetup
        
    push    ds
    mov     ax,[PicSeg]
    mov     ds,ax
    mov     cx,64000                    ;read 64000 bytes
    xor     dx,dx
    mov     ah,3fh
    int     21h
    pop     ds
        
    mov     ah,3eh                  ;close source file 
    int     21h                     

    popa
    ret
@@Abort:
    stc
    popa
    ret
ENDP

PROC ScrollSplit
    cmp     [SplitDest],0
    je      @@GoDown
    cmp     [Split],80
    je      @@Done
    sub     [Split],8
    jmp     short @@Done1
@@GoDown:
    cmp     [Split],400
    je      @@Done
    add     [Split],8
@@Done1:
    @WaitVert
    mov     bx,[Split]
    @Set_Split
@@Done:
    ret
ENDP

PROC SetUpStuff
    pusha
    push    ds es
    mov     es,[VGAseg]
    mov     ds,[PicSeg]

    mov     bl,00010001b
    xor     bp,bp
@@OuterLoop:
    mov     ah,bl
    @Set_Write_Plane
    mov     cx,64000 /4
    mov     di,240*SCRW
    mov     si,bp
@@inLoop:
    mov     al,[ds:si]
    stosb
    add     si,4
    dec     cx
    jne     @@InLoop
    inc     bp
    shl     bl,1
    jnc     @@OuterLoop

    mov     ah,1111b
    @Set_Write_Plane

    mov     di,0    ;SCRW*2
    mov     cx,SCRW
    mov     al,GREY5
    rep stosb
    mov     cx,SCRW
    mov     al,GREY4
    rep stosb
    mov     cx,SCRW
    mov     al,GREY3
    rep stosb
    mov     cx,SCRW
    mov     al,GREY2
    rep stosb
    mov     cx,SCRW
    mov     al,GREY1
    rep stosb
    mov     cx,SCRW
    mov     al,GREY2
    rep stosb
    mov     cx,SCRW
    mov     al,GREY3
    rep stosb
    mov     cx,SCRW
    mov     al,GREY4
    rep stosb
    mov     cx,SCRW
    mov     al,GREY5
    rep stosb
    pop     es ds

    mov     bx,offset Messages
    mov     cx,NumMsgs
    call    PrintList
    
    popa
    ret
ENDP

PROC GetDimensions
    pusha
    push    es
    mov     ax,cs
    mov     es,ax

    mov     [SplitDest],1
    
    mov     bx,offset DimMsgH
    mov     cx,NumDimMsg
    call    PrintList
@@Zloop:
    movzx   eax,[VCHheader.SizeX]
    mov     di,offset Wtext
    mov     cx,3
    call    DEC_Print2Mem
    movzx   eax,[VCHheader.SizeY]
    mov     di,offset Htext
    call    DEC_Print2Mem
    movzx   eax,[VCHheader.From]
    mov     di,offset Ftext
    call    DEC_Print2Mem
    movzx   eax,[VCHheader.NumChar]
    mov     di,offset Ntext
    call    DEC_Print2Mem
    
    mov     bx,offset DimMsgH2
    mov     cx,8
    call    PrintList

@@GetChar:
    call    ScrollSplit
    mov     ah,11h
    int     16h         ;get a char
    jz      @@GetChar
    mov     ah,10h
    int     16h

    cmp     al,13
    je      @@AllDone
    cmp     ah,CSRUP
    je      @@HandleUp
    cmp     ah,CSRDN
    je      @@HandleDown
    cmp     ah,CSRLF
    je      @@HandleLeft
    cmp     ah,CSRRT
    je      @@HandleRight
    cmp     al,"+"
    je      @@MoreChars
    cmp     al,"-"
    je      @@LessChars
    cmp     al,"F"
    je      @@IncFrom
    cmp     al,"f"
    je      @@DecFrom
    jmp     @@Zloop

@@IncFrom:
    add     [VCHheader.From],2
@@DecFrom:
    dec     [VCHheader.From]
    jmp     @@Zloop
@@MoreChars:
    inc     [VCHheader.NumChar]
    jnz     @@Zloop
    dec     [VCHheader.NumChar]
    jmp     @@Zloop
@@LessChars:
    dec     [VCHheader.NumChar]
    jnz     @@Zloop
    inc     [VCHheader.NumChar]
    jmp     @@Zloop
@@HandleUp:
    inc     [VCHheader.SizeY]
    cmp     [VCHheader.SizeY],MAXY
    jbe     @@Zloop
    mov     [VCHheader.SizeY],MAXY
    jmp     @@Zloop
@@HandleDown:
    dec     [VCHheader.SizeY]
    cmp     [VCHheader.SizeY],MINY
    jge     @@Zloop
    mov     [VCHheader.SizeY],MINY
    jmp     @@Zloop
@@HandleRight:
    inc     [VCHheader.SizeX]
    cmp     [VCHheader.SizeX],MAXX
    jbe     @@Zloop
    mov     [VCHheader.SizeX],MAXX
    jmp     @@Zloop
@@HandleLeft:
    dec     [VCHheader.SizeX]
    cmp     [VCHheader.SizeX],MINX
    jge     @@Zloop
    mov     [VCHheader.SizeX],MINX
    jmp     @@Zloop
@@AllDone:
    mov     ah,1111b
    @Set_Write_Plane
    mov     es,[VGAseg]
    mov     di,29*SCRW
    mov     cx,153*SCRW/2
    mov     ax,Red2*100h + RED2
    rep     Stosw

    mov     [SplitDest],0
    call    RefreshScreen
    
    pop     es
    popa
    ret
ENDP

PROC GrabTheChar
    pusha
    push    es ds

    mov     si,[Ypos]
    imul    si,320
    add     si,[Xpos]

    mov     al,[VCHheader.SizeX]
    mul     [VCHheader.SizeY]
    movzx   cx,[CurChar]
    mul     cx
    mov     di,ax           ;ds:si pts to character

    mov     es,[CharSeg]
    mov     ds,[PicSeg]

    movzx   bp,[cs:VCHheader.SizeX]
    sub     bp,320
    neg     bp                  ;BP = 320-SizeX
    mov     dl,[cs:VCHheader.SizeY]
@@Loop:    
    movzx   cx,[cs:VCHheader.SizeX]
    rep     movsb
    add     si,bp
    dec     dl
    jne     @@Loop

    pop     ds es
    popa
    ret
ENDP

PROC CheckKeys
    mov     ah,11h
    int     16h
    jnz     @@DoAKey
    clc
    ret
@@DoAKey:
    mov     ah,10h
    int     16h

    cmp     al,17
    je      @@DoQuit
    cmp     ah,PAGEUP
    je      @@DoPU
    cmp     ah,PAGEDOWN
    je      @@DoPD
    cmp     ax,2004h
    je      @@DoReDim
    cmp     ax,1f13h
    je      @@DoSave
    cmp     ah,CSRUP
    je      @@DoUp
    cmp     ah,CSRDN
    je      @@DoDN
    cmp     ah,CSRLF
    je      @@DoLF
    cmp     ah,CSRRT
    je      @@DoRT
    cmp     ah,CSRUPC
    je      @@DoUpC
    cmp     ah,CSRDNC
    je      @@DoDNC
    cmp     ah,CSRLFC
    je      @@DoLFC
    cmp     ah,CSRRTC
    je      @@DoRTC
    cmp     ax,2207h
    je      @@DoGrabIt
    cmp     al,"+"
    je      @@DoPlus
    cmp     al,"-"
    je      @@DoMinus
    
    clc
    ret

@@DoPlus:
    inc     [CurChar]
    mov     al,[VCHheader.NumChar]
    cmp     [CurChar],al
    jb      @@Done
    mov     [CurChar],0
    jmp     @@Done
@@DoMinus:
    dec     [CurChar]
    mov     al,[VCHheader.NumChar]
    cmp     [CurChar],al
    jb      @@Done
    dec     al
    mov     [CurChar],al
    jmp     @@Done
@@DoGrabIt:
    call    GrabTheChar
    call    RefreshScreen
    clc
    ret
@@DoUpC:
    movzx   ax,[VCHheader.SizeY]
    dec     ax
    sub     [Ypos],ax
    jmp     @@DoUp
@@DoDNC:
    movzx   ax,[VCHheader.SizeY]
    dec     ax
    add     [Ypos],ax
    jmp     @@DoDN
@@DoLFC:
    movzx   ax,[VCHheader.SizeX]
    dec     ax
    sub     [Xpos],ax
    jmp     @@DoLF
@@DoRTC:
    movzx   ax,[VCHheader.SizeX]
    dec     ax
    add     [Xpos],ax
    jmp     @@DoRT
@@DoUp:
    dec     [Ypos]
    cmp     [Ypos],0
    jge     @@Done
    mov     [Ypos],0
    jmp     @@Done
@@DoDN:
    inc     [Ypos]
    movzx   ax,[VCHheader.SizeY]
    sub     ax,200
    neg     ax
    cmp     [Ypos],ax
    jl      @@Done
    mov     [Ypos],ax
    jmp     @@Done
@@DoLF:
    dec     [Xpos]
    cmp     [Xpos],0
    jge     @@Done
    mov     [Xpos],0
    jmp     @@Done
@@DoRT:
    inc     [Xpos]
    movzx   ax,[VCHheader.SizeX]
    sub     ax,320
    neg     ax
    cmp     [Xpos],ax
    jl      @@Done
    mov     [Xpos],ax
    jmp     @@Done
@@DoSave:
    call    SaveIt
    clc
    ret
@@DoReDim:
    call    GetDimensions
    clc
    ret
@@DoQuit:
    stc
    ret
@@DoPU:
    mov     [SplitDest],1
    clc
    ret
@@DoPD:
    mov     [SplitDest],0
    clc
    ret
@@Done:
    call    RefreshScreen
    clc
    ret
ENDP

    ; Draws enlarged & normal sized image
    ;updates x & Y positions, width, height, current char etc..
    ;
PROC RefreshScreen
    pusha
    push    es ds
    mov     ax,cs
    mov     es,ax
    mov     ds,ax

;SizeMsg db  1,GREEN,"`-' W:-  H:-  #:  -/    X:  - Y:  - ",0
;SizeMsg2 db 1,GREY2," A    12   15    21       252   123",0
;ClrSize db  1,BLACK," €    €€   €€   €€€ €€€   €€€   €€€",0

    mov     al,[CurChar]
    add     al,[VCHheader.From]   ;" "
    cmp     al,1
    ja      @@OK
    mov     al," "
@@ok:
    mov     [SizeMsg2+3],al

    movzx   eax,[VCHheader.SizeX]
    mov     cx,2
    mov     di,offset SizeMsg2 + 8
    call    DEC_Print2Mem

    movzx   eax,[VCHheader.SizeY]
    mov     di,offset SizeMsg2 + 13
    call    DEC_Print2Mem

    movzx   eax,[CurChar]
    mov     cx,3
    mov     di,offset SizeMsg2 + 18
    call    DEC_Print2Mem

    movzx   eax,[VCHheader.NumChar]
    mov     di,offset SizeMsg2 + 22
    call    DEC_Print2Mem

    movzx   eax,[Xpos]
    mov     di,offset SizeMsg2 + 28
    call    DEC_Print2Mem

    movzx   eax,[Ypos]
    mov     di,offset SizeMsg2 + 34
    call    DEC_Print2Mem

    mov     bx,offset RefMsg
    mov     cx,2
    call    PrintList

    mov     es,[VGAseg]
    mov     ds,[CharSeg]

    mov     al,[cs:VCHheader.SizeX]
    mul     [cs:VCHheader.SizeY]
    movzx   cx,[cs:CurChar]
    mul     cx
    mov     si,ax           ;ds:si pts to character

    mov     ah,1110b
    @Set_Write_Plane

    mov     di,ENLARGEOFFSET
    mov     dl,[cs:VCHheader.SizeY]
    mov     bx,SCRW
    sub     bl,[cs:VCHheader.SizeX]
@@BigLoop:
    mov     dh,2
    mov     bp,si
 @@BigLoop2:
    movzx   cx,[cs:VCHheader.SizeX]
    rep movsb
    mov     si,bp
    add     di,bx
    dec     dh
    jne     @@BigLoop2

    movzx   cx,[cs:VCHheader.SizeX]
    rep movsb
    add     di,bx
    add     di,SCRW
    
    dec     dl
    jne     @@BigLoop
    ƒƒ
    mov     ds,[cs:PicSeg]

    mov     ax,[cs:Ypos]
    imul    ax,320 
    add     ax,[cs:Xpos]
    mov     si,ax           ;ds:si pts to character

    mov     di,ENLARGEOFFSET+40
    mov     bx,SCRW
    mov     ax,320
    movzx   dx,[cs:VCHheader.SizeX]
    sub     bx,dx
    sub     ax,dx                   ;AX=320-SizeX BX=SCRW-SizeX
    mov     dl,[cs:VCHheader.SizeY]
@@BigLoop3:
    mov     dh,2
    mov     bp,si
 @@BigLoop4:
    movzx   cx,[cs:VCHheader.SizeX]
    rep movsb
    mov     si,bp
    add     di,bx
    dec     dh
    jne     @@BigLoop4

    movzx   cx,[cs:VCHheader.SizeX]
    rep movsb
    add     di,bx
    add     di,SCRW
    add     si,ax
    dec     dl
    jne     @@BigLoop3
    ƒƒ
    mov     di,[cs:OldY]   ;erase top line
    dec     di
    js      @@SkipEtop
    imul    di,SCRW
    add     di,240*SCRW

    mov     si,[cs:OldY]
    dec     si
    imul    si,320
    mov     bl,1
 @@LoLo:
    push    si di
    mov     ah,bl
    @Set_Write_Plane
    mov     cx,SCRW
 @@InLoLo:
    movsb
    add     si,3
    loop    @@InLoLO
    pop     di si
    inc     si
    shl     bl,1
    cmp     bl,10000b
    jb      @@LoLo
@@SkipEtop:
    mov     di,[cs:OldY]   ;erase bottom line
    movzx   ax,[cs:VCHheader.SizeY]
    add     di,ax
    imul    di,SCRW
    add     di,240*SCRW

    mov     si,[cs:OldY]
    add     si,ax
    imul    si,320
    mov     bl,1
@@LoLo2:
    push    si di
    mov     ah,bl
    @Set_Write_Plane
    mov     cx,SCRW
 @@InLoLo2:
    movsb
    add     si,3
    loop    @@InLoLO2
    pop     di si
    inc     si
    shl     bl,1
    cmp     bl,10000b
    jb      @@LoLo2

    mov     si,[cs:OldX]   ;erase left
    dec     si
    js      @@SkipELeft
    mov     di,si
    mov     cx,di
    and     cl,11b
    mov     ah,1
    shl     ah,cl
    @Set_Write_Plane
    shr     di,2
    add     di,240*SCRW

    mov     dx,200
@@LoX:
    movsb
    add     di,SCRW-1
    add     si,320-1
    dec     dx
    jne     @@Lox
@@SkipELeft:
    mov     si,[cs:OldX]   ;erase right
    movzx   ax,[cs:VCHheader.SizeX]
    add     si,ax
    cmp     si,320
    jae     @@SkipEright
    mov     di,si
    mov     cx,di
    and     cl,11b
    mov     ah,1
    shl     ah,cl
    @Set_Write_Plane
    shr     di,2
    add     di,240*SCRW

    mov     dx,200
@@LoX2:
    movsb
    add     di,SCRW-1
    add     si,320-1
    dec     dx
    jne     @@Lox2
@@SkipEright:
    mov     ax,[cs:Xpos]
    mov     [cs:OldX],ax
    mov     ax,[cs:Ypos]
    mov     [cs:OldY],ax

    mov     ah,1111b
    @Set_write_plane

    mov     di,[cs:OldY]   ;draw top line
    dec     di
    js      @@SKipDtop
    imul    di,SCRW
    add     di,240*SCRW
    mov     cx,SCRW
    mov     al,RED
    rep     stosb
@@SKipDtop:
    mov     di,[cs:OldY]   ;draw bottom line
    movzx   ax,[cs:VCHheader.SizeY]
    add     di,ax
    imul    di,SCRW
    add     di,240*SCRW
    mov     cx,SCRW
    mov     al,RED
    rep     stosb

    mov     di,[cs:OldX]   ;draw left
    dec     di
    js      @@SKipDLeft
    mov     cx,di
    and     cl,11b
    mov     ah,1
    shl     ah,cl
    @Set_Write_Plane
    shr     di,2
    add     di,240*SCRW

    mov     dx,200
    mov     al,RED
@@LoXx:
    stosb
    add     di,SCRW-1
    dec     dx
    jne     @@Loxx
@@SKipDLeft:
    mov     di,[cs:OldX]   ;draw right
    movzx   ax,[cs:VCHheader.SizeX]
    add     di,ax
    cmp     di,320
    jae     @@SkipDright
    mov     cx,di
    and     cl,11b
    mov     ah,1
    shl     ah,cl
    @Set_Write_Plane
    shr     di,2
    add     di,240*SCRW

    mov     dx,200
    mov     al,RED
@@LoX2x:
    stosb
    add     di,SCRW-1
    dec     dx
    jne     @@Lox2x
@@SkipDright:
    pop     ds es
    popa
    ret
ENDP

PROC SaveIt
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax
    

    mov     dx,offset FileNameVCH
    sub     cx,cx
    mov     ah,3ch                  ;open file
    int     21h
    jc      @@abort
    mov     bx,ax

    mov     dx,offset VCHheader    
    mov     cx,(size VchHdr)
    mov     ah,40h
    int     21h

    mov     al,[VCHheader.SizeY]           ;figure size
    mul     [VCHheader.SizeX]
    movzx   dx,[VCHheader.NumChar]
    mul     dx
        
    mov     cx,ax                   ; the dest file lenght
    push    ds
    mov     ds,[CharSeg]
    mov     ah,40h                  ; function write
    xor     dx,dx
    int     21h                     ; write it
    pop     ds

    mov     ah,3eh                  ;close source file 
    int     21h
@@Abort:
    pop     ds
    popa
    ret
ENDP
