    DOSSEG
    .MODEL SMALL
    .STACK 200h
    .CODE
    .386
    ASSUME CS:@CODE, DS:@CODE
    Ideal
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Include "Modex.Inc"
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;upon entry:    Decompressit => loads .CMP image and decompresses it...
;
;*  DS:DX = pointer to filename
;*  AX != 0, image fitted to AX wide window
;*  AX == 0, image decompressed using [Xsize] for width
;*  [FileSeg] and [Destination] must both have valid segmnet values
;
;upon EXIT:
;
;*  AX=0 if no error, 1 means error
;*  Stuff in [FileSeg] is destoryed
;*  Decompressed image is in [Destination] segment
;*  Palette is at CmpPal

    GLOBAL  DeCompressIt:NEAR
    GLOBAL  FileSeg:WORD, Destination:WORD, CmpPal:BYTE

CMPName db  "logo.cmp",0
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SCRW        =   160
PGWD        =   SCRW/4
ThePages    dw  80*SCRW, 80*SCRW+PGWD, 80*SCRW+PGWD*2, 80*SCRW+PGWD*3
BASEOff     =   80*Scrw
CurOff      dw  0
DestOff     dw  0
PAGEHEIGHT  =   400-110
LogoLoc     dw  SCRW/2, SCRW/2+SCRW*20,SCRW/2+SCRW*40, SCRW/2+SCRW*60
LogoHeight  =   20
SplitScreen =   400-81
CurLoc      db  128

Page1       =   0
Page2       =   PGWD*1*4
Page3       =   PGWD*2*4
Page4       =   PGWD*3*4

MoveIndex   dw  0
MaxIndex    =   35

MoveDirection db 0  ;0= none 1=left 2=right

MoveDist    dw  1,2,3,3,4,4,4,5,5,5,5,6,6,6,6,6,  6,6,6
            dw  6,6,6,6,6,5,5,5,5,4,4,4,3,3,2,1
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ;di= offset to fill at, al what to fill with
PROC FillPage
    pusha
    push    es
    mov     es,[cs:VGAseg]
    
    add     di,105*SCRW
    push    ax

    mov     ah,0
    @Set_write_mode
    mov     ah,1111b
    @Set_Write_Plane

    pop     ax

    mov     dx,PAGEHEIGHT
@@woop:
    mov     cx,PGWD
    rep     stosb
    add     di,SCRW-PGWD
    dec     dx
    jne     @@Woop
    pop     es
    popa
    ret
ENDP

    ;di = ptr to dest
    ;si = ptr to source
PROC CopyBlocks
    pusha
    push    es ds
    mov     ax,[cs:VGAseg]
    mov     es,ax
    mov     ds,ax

    @FullVertWait

    mov     ah,1
    @Set_Write_Mode

    mov     ax,105*SCRW
    add     si,ax
    add     di,ax

    mov     dx,PageHeight
@@Loop:
    mov     cx,SCRW/2
    rep     movsb
    add     di,SCRW/2
    add     si,SCRW/2
    dec     dx
    jne     @@Loop

    @FullVertWait

    pop     ds es
    popa
    ret
ENDP

PROC CopyLogo
    pusha
    push    ds es
    mov     ax,[cs:VGAseg]
    mov     es,ax
    mov     ds,ax

    mov     ah,1
    @Set_WRite_Mode
    mov     ah,1111b
    @Set_Write_Plane

    mov     bx,[cs:CurOff]
    mov     di,bx
    shr     di,2
    add     di,BaseOff
    and     bx,11b
    add     bx,bx
    mov     si,[cs:LogoLoc+bx]
    cld
    mov     dx,LogoHeight
@@Cploop:
    mov     cx,SCRW/2
    rep     movsb
    mov     al,[si-Scrw/2]
    mov     [di],al
    add     di,SCRW/2
    add     si,SCRW/2
    dec     dx
    jne     @@CPloop
    
    pop     es ds
    popa
    ret
ENDP

PROC PutImagesOnVGA
    pusha
    push    fs es ds
    mov     ax,cs
    mov     ds,ax
    mov     es,[VGAseg]
    mov     fs,[Destination]

    mov        ah,0
    @Set_Write_mode

    xor     cx,cx
@@TopLoop:
    mov     si,cx
    add     si,80*320
    mov     di,SCRW/2
    mov     bp,LogoHeight*4
    mov     ah,1
    shl     ah,cl
    @Set_Write_plane
@@loop:
    mov     bx,SCRW/2
@@NoLop:
    mov     al,[fs:si]    
    mov     [es:di],al
    inc     di
    add     si,4
    dec     bx
    jne     @@NoLop

    add     di,SCRW/2
    dec     bp
    jne     @@Loop

    inc     cl
    cmp     cl,4
    jb      @@TopLoop

    xor     cx,cx
@@TopLoop2:
    mov     si,cx
    mov     di,0
    mov     bp,80
    mov     ah,1
    shl     ah,cl
    @Set_Write_plane
@@loop2:
    mov     bx,SCRW/2
@@NoLop2:
    mov     al,[fs:si]    
    mov     [es:di],al
    inc     di
    add     si,4
    dec     bx
    jne     @@NoLop2

    add     di,SCRW/2
    dec     bp
    jne     @@Loop2

    inc     cl
    cmp     cl,4
    jb      @@TopLoop2

    pop     ds es fs
    popa
    ret
ENDP

PROC FixUpScreen
    pusha

    @FullVertWait
    mov     cx,LogoHeight/4
    mov     dx,3dah         ;wait until scan line > height of logo
@@WaitForVR:
    in      al,dx
    and     al,1000b
    jz      @@WaitforVR
@@WaitForVREnd:
    in      al,dx
    and     al,1000b
    jnz     @@WaitforVREnd
@@WaitferHR:
    in      al,dx
    and     al,1001b
    cmp     al,1
    jne     @@WaitFerHR
@@WaitForHRend:
    in      al,dx
    and     al,1001b
    jne     @@WAitForHRend
    dec     cx
    jne     @@WaitferHR
    
    mov     cx,[cs:CurOff]
    mov     bx,cx
    shr     bx,2
    add     bx,BaseOff
    @Set_Start_Offset
    and     cl,11b
    mov     ah,cl
    add     ah,ah
    @Set_HPP
    call    CopyLogo
    @FullVertWait

    popa
    ret
ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
START:
    mov     ax,cs
    mov     ds,ax

    mov     ax,ss
    add     ax,20h
    mov     [Destination],ax
    add     ax,1000h
    mov     [FileSeg],ax
    xor     ax,ax
    mov     dx,offset CMPname
    call    Decompressit
    
    @SetModeX m320x400x256, SCRW*4
    
    mov     ax,0
    mov     cx,256
    mov     si,offset CmpPal
    @WritePalette

    @Set_PPC
    call    PutImagesOnVGA

    mov     ah,1111b
    @Set_Write_Plane

    mov     al,[CurLoc]
    inc     al
    mov     di,Page1/4
    call    FillPage
    mov     al,[CurLoc]
    add     al,2
    mov     di,Page2/4
    call    FillPage
    call    CopyLogo
    
    mov     bx,SplitScreen
    @Set_Split
    mov     bx,BaseOff+Page1/4
    @Set_Start_Offset
@@mainLoop:
    mov     si,[MoveIndex]
    add     si,si
    inc     [MoveIndex]

    mov     bx,[CurOff]
    cmp     bx,[DestOff]
    je      @@NoMove
    jl      @@Increase

    sub     bx,[MoveDist + si]
    mov     [CurOff],bx
    jmp     Short @@MoveIt

@@Increase:
    add     bx,[MoveDist + si]
    mov     [CurOff],bx

@@MoveIt:
    mov     cx,LogoHeight/4
    mov     dx,3dah         ;wait until scan line > height of logo
@@WaitForVR:
    in      al,dx
    and     al,1000b
    jz      @@WaitforVR
@@WaitForVREnd:
    in      al,dx
    and     al,1000b
    jnz     @@WaitforVREnd

@@WaitferHR:
    in      al,dx
    and     al,1001b
    cmp     al,1
    jne     @@WaitFerHR
@@WaitForHRend:
    in      al,dx
    and     al,1001b
    jne     @@WAitForHRend
    dec     cx
    jne     @@WaitferHR
    
    mov     cx,[CurOff]
    mov     bx,cx
    shr     bx,2
    add     bx,BaseOff
    @Set_Start_Offset
    and     cl,11b
    mov     ah,cl
    add     ah,ah
    @Set_HPP
    call    CopyLogo
    jmp     short @@DiDmove
@@NoMove:
    mov     [MoveIndex],0
@@DidMove:
    
    mov     ah,1
    int     16h
    jz      @@MainLoop
    mov     ah,0
    int     16h
    cmp     al,27
    je      @@ByeBYe

    cmp     ah,75
    jne     @@NotLeft
    mov     ax,[CurOff]
    cmp     ax,Page1
    je      @@DoLeft1
    cmp     ax,Page2
    je      @@DoLeft2
    cmp     ax,Page3
    je      @@DoLeft3
    jmp     @@MainLoop
@@DoLeft1:
    mov     si,Page1/4
    mov     di,Page3/4
    mov     [CurOff],Page3
    call    CopyBlocks          ;move every thing over
    @FullVertWait
    call    FixUpScreen    
@@DoLeft3:
    mov     di,Page2/4
    mov     al,[CurLoc]
    call    FillPage
    dec     [CurLoc]

    mov     [DestOff],Page2
    mov     [MoveIndex],0
    jmp     @@MainLoop
@@DoLeft2:
    mov     di,Page1/4
    mov     al,[CurLoc]
    call    FillPage
    dec     [CurLoc]
    mov     [DestOff],Page1
    mov     [MoveIndex],0
    jmp     @@MainLoop

@@NotLeft:
    cmp     ah,77
    jne     @@NotRight
    mov     [MoveDirection],2
    mov     ax,[CurOff]
    cmp     ax,Page1
    je      @@DoRight1
    cmp     ax,Page2
    je      @@DoRight2
    cmp     ax,Page3
    je      @@DoRight3
    jmp     @@MainLoop
@@DoRight1:
    mov     di,Page3/4
    mov     al,[CurLoc]
    add     al,3
    call    FillPage
    inc     [CurLoc]
    mov     [DestOff],Page2
    mov     [MoveIndex],0
    jmp     @@MainLoop
@@DoRight2:
    mov     di,Page4/4
    mov     al,[CurLoc]
    add     al,3
    call    FillPage
    inc     [CurLoc]
    mov     [DestOff],Page3
    mov     [MoveIndex],0
    jmp     @@MainLoop
@@DoRight3:
    mov     si,Page3/4
    mov     di,Page1/4
    mov     [CurOff],Page1
    call    CopyBlocks          ;move every thing over
    @FullVertWait
    call    FixUpScreen    

    mov     di,page3/4
    mov     al,[CurLoc]
    add     al,3
    call    FillPage
    inc     [CurLoc]

    mov     [DestOff],Page2
    mov     [MoveIndex],0
    jmp     @@MainLoop

@@NotRight:
    jmp     @@MainLoop
@@ByebYe:
    mov     ax,3
    int     10h
    mov     ah,4ch
    int     21h
END START
