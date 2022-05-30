    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ;   Return of the jedi- type credits. Written by Draeden of VLA
    ;        Started on 08.10.1993      Finished on 08.10.1993
    ;
    ;        Copyright 1993 by VLA  ş  Use by permission only!
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    IDEAL
    DOSSEG
    MODEL SMALL
    STACK 400h

    CODESEG
    P386N
    ASSUME CS:@CODE, DS:@CODE
    LOCALS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
STRUC VGALINE
    Dest        dw      0   ;offset of left of line on screen
    Source      dw      0   ;offset to source for this line
    Indent      dw      0   ;amt indented from edge to start of line
    Old_Indent  dw      0   ;last indent so we know to erase
    Real_Width  dw      0   ;between 0 and 320 if Virt_Width < 320 then 
                            ; Real = Virt
    Virt_Width  dw      0   ;Virtual width of line, is the index into 
                            ; step chart pointers - only even values are
ENDS                        ; are permitted (and with 0FFFEh)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Step_Chart  dw  183 dup (?) ;the max width for a line is 366 bytes
                            ;(virtual) cause that's all that would fit
                            ; in 64k

LABEL TheLines VGALINE     
    i=0
    REPT 200 
        VGALINE <i*320,?,160,160,0>
        i=i + 1
    ENDM                    ;have all 200 so we have the possibility of
                            ; full screen action
Step_Seg    dw  0           ;segment of step chart
VGASeg      dw  0A000h  
Image_Seg   dw  0           ;source for GFX
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ;Takes the info for each line and displays the whole screen cleaning
    ;up after the last one as it goes.  This routine REALLY pushes the 
    ;limits...  May be damaging to your health. Way complex. =)
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC Display_Lines NEAR
    pusha
    push    ds es fs gs                     ;save everything
    mov     ax,cs
    mov     ds,ax                           ;setup all the segments
    mov     es,[VGAseg]
    mov     fs,[Step_Seg]
    mov     gs,[Image_Seg]

    xor     bx,bx                           ;start on line 0
@@DrawLineLoop:
    mov     cx,[bx + TheLines.Indent]
    sub     cx,[bx + TheLines.Old_Indent]   ;if old>=new then we dont erase
    jle     @@NoErase                       ; otherwise, CX = # bytes to del

    mov     di,[bx + TheLines.Dest]         ;erase the front
    add     di,[bx + TheLines.Old_Indent]
    xor     al,al
    push    cx
    rep     stosb
    pop     cx
    add     di,[bx + TheLines.Real_Width]   ;and erase the end
    rep     stosb

@@NoErase:
    cmp     [bx + TheLines.Virt_Width],0    ;dont draw width 0
    je      @@DoneLine

    mov     di,[bx + TheLines.Dest]
    add     di,[bx + TheLines.Indent]       ;point to the beginning of Dest

    mov     bp,[bx + TheLines.Source]       ;grab the base for source
    push    bx
    mov     cx,[bx + TheLines.Real_Width]   ;grab real width in CX
    mov     bx,[bx + TheLines.Virt_Width]   ;grab virtual width of line
    and     bx,0fffeh
    mov     bx,[bx + Step_Chart]            ;get the offset to the step stuff
    
@@Little_Loop:
    mov     si,[fs:bx]                      ;grab source offset
    add     bx,2                            ;point to next offset 

    mov     al,[gs:bp + si]                 ;grab the byte
    stosb                                   ;store it - if you run a 486
                                            ; mov [es:di],al  inc di 
                                            ;MAY be faster
    loop    @@Little_Loop

    pop     bx                              ;done, restore BX

@@DoneLine:
    mov     ax,[bx + TheLines.Indent]       ;copy over indent and that's that
    mov     [bx + TheLines.Old_Indent],ax
    
    add     bx,(size VGALine)
    cmp     bx,(size VGALine)*200
    jb      @@DrawLineLoop

    pop     gs fs es ds
    popa
    ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; This sets up the step charts for each width from 0 to 366, only
    ;doing even values. Also fills in the step offset chart.
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Pic_Width   =   320

PROC Setup_Step NEAR
    pushad
    push    ds es
    mov     ax,cs
    mov     ds,ax
    mov     es,[Step_Seg]

    xor     ebp,ebp           ;current width
    xor     si,si           ;Step offset index
    xor     di,di           ;offset in Step_Seg
@@StepLoop:
    mov     [si + Step_Chart],di    ;save offset for current one
    or      bp,bp
    je      @@Null
    
    mov     eax,320 * 10000h
    xor     edx,edx
    div     ebp
    
    mov     edx,eax
    ror     edx,16  ;dx= int step, high EDX = fractional step

    mov     cx,bp                   ;get the width
    xor     eax,eax                 ;int low, frac hi current offset
    cmp     cx,320
    jbe     @@StoreLoop

    sub     cx,320
    movzx   ecx,cx
    mov     eax,edx
    ror     eax,16
    push    edx
    mul     ecx
    shr     eax,1
    ror     eax,16
    pop     edx
    mov     cx,318
@@StoreLoop:
    stosw                           ;store current offset
    add     eax,edx                 ;increase the offset
    adc     eax,0                   ;let fractions carry over..
    loop    @@StoreLoop

@@Null:
    add     si,2
    add     bp,2
    cmp     bp,366                  ;max that can fit in 64k
    jb      @@StepLoop

    pop     es ds
    popad
    ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ;Sets up the widths and indent of all TheLines so that it makes
    ; it look like text going back into the distance..
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC Setup_Screen NEAR
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax
    
    mov     si,(size VGALine) * 80
    mov     cx,100
    mov     bx,130                  ;width
    mov     ax,160-130/2            ;indent
    xor     dx,dx                   ;source
@@FillLoop:
    mov     [si + TheLines.Virt_Width],bx
    mov     [si + TheLines.Real_Width],bx
    cmp     bx,320
    jbe     @@WOK
    mov     [si + TheLines.Real_Width],320
@@WOK:
    mov     [si + TheLines.Indent],ax
    mov     [si + TheLines.Old_Indent],ax
    or      ax,ax
    jns     @@Iok
    mov     [si + TheLines.Indent],0
    mov     [si + TheLines.Old_Indent],0
@@Iok:
    mov     [si + TheLines.Source],dx

    add     dx,320
    add     bx,2
    dec     ax
    add     si,(size VGAline)
    cmp     si,(size VGAline)*200
    jae     @@BYE
    loop    @@FillLoop

@@BYE:

    pop     ds
    popa
    ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; Scrolls the data up by one line, adjusting all the source pointers
    ;in TheLines.  Also writes one additional line somewhere.
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC Scroll_Text
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax

    mov     si,0
    mov     cx,200
@@IncLoop:
    mov     ax,[si + TheLines.Source]
    add     ax,320
    cmp     ax,64000
    jb      @@NotOver
    xor     ax,ax
@@NotOver:
    mov     [si + TheLines.Source],ax
    add     si,(size VGALine)
    loop    @@IncLoop

    pop     ds
    popa
    ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ;Loads in a TGA picture to display
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
STRUC Pal
    R   db  ?
    G   db  ?
    B   db  ?
ENDS

FileName_TGA    db  "Test2.TGA",0
Palette         Pal 256 dup (<>)
    
PROC Load_TGA NEAR
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax

    mov     dx,offset FileName_TGA
    mov     ax,3d00h
    int     21h
    jc      @@BYE
    mov     bx,ax

    mov     ax,4200h                    ;move FP rel to start
    xor     cx,cx                       ; get past header
    mov     dx,18
    int     21h

    mov     dx,offset Palette           ;read in palette
    mov     cx,768
    mov     ah,3fh
    int     21h

    mov     si,offset Palette           ;fix palette
    mov     cx,256
@@FPL:
    mov     al,[(Pal PTR si).R]         ;switch R&B and make 6bit
    mov     ah,[(Pal PTR si).G]
    mov     dl,[(Pal PTR si).B]
    shr     al,2
    shr     ah,2
    shr     dl,2
    mov     [(Pal PTR si).R],dl
    mov     [(Pal PTR si).G],ah
    mov     [(Pal PTR si).B],al
    add     si,(size Pal)
    loop    @@FPL

    mov     si,offset Palette           ;write palette
    mov     dx,3c8h
    xor     al,al
    out     dx,al
    inc     dx
    mov     cx,256*3
    rep outsb

    mov     ds,[Image_Seg]              ;read in picture
    xor     dx,dx
    mov     cx,64000
    mov     ah,3fh
    int     21h

    mov     ah,3eh                      ;close it up
    int     21h

@@BYE:
    pop     ds
    popa
    ret
ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
START:
    mov     ax,cs
    mov     es,ax
    mov     ds,ax

    mov     ax,ss
    mov     bx,sp
    shr     bx,4
    inc     bx
    add     ax,bx               ;find 1st available seg after Stack

    mov     [Step_Seg],ax
    add     ax,1000h
    mov     [Image_Seg],ax

    mov     ax,0013h            ;change to 320x200x256 graph
    int     10h

    call    Load_Tga
    call    Setup_Step
    call    Setup_Screen

@@MainLoop:
    call    Scroll_Text
    call    Display_Lines
    mov     ah,1
    int     16h
    jz      @@MainLoop

    mov     ah,0                ;wait for a key press
    int     16h
    mov     ax,0003h            ;reset to 80x25x16 Char
    int     10h

    mov     ax,4c00h            ;back to DOS
    int     21h
END START
