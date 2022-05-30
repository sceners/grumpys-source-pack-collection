    DOSSEG
    .MODEL SMALL
    .CODE
    .386
    ASSUME  cs:@code, ds:@code
    LOCALS

;===- Globals -===

;FILE: MCLSUB.ASM
;upon entry: 
;
;*      ES= PSP SEG 
;*      DS:DX = pointer to filename area
;*      DS:BX = pointer to 5 byte 0 terminating Extension to add
;
;RETURN:    AX= length of command line

GLOBAL  GetCommandLine:NEAR

;===- Data -===

InputLength dw  0
FileNameOff dw  0       ;offset from CS: to filename
ExtOff      dw  0
DataStuffSeg dw  0

;===- End Data -===

GetCommandLine proc near
    pusha
    push    ds es

    mov     cs:[DataStuffSeg],ds

    push    es                      ;push the PSP seg
    pop     ds                      ;pop it into DS
    
    mov     cs:[ExtOff],bx
    mov     cs:[FileNameOff],DX
    mov     cs:[InputLength],0      ;reset length read

    mov     si,128
    lodsb

    xor     ah,ah
    xor     cx,cx
    mov     cl,al
    or      cx,cx
    je      CapDone     ;theres nothing here

    mov     es,cs:[DataStuffSeg]
    mov     di,cs:[FileNameOff]

    xor     bx,bx
    mov     dx,bx
Nospace:
    or      cx,cx
    je      DoneName    ;we already grabbed all the characters
    dec     cx
    lodsb
    or      al,al
    je      DoneName    ;we are done if we hit a null
    cmp     al,' '
    jbe     Nospace     ;ignore spaces
    cmp     al,"."
    jne     NotAPeriod
    inc     dx
NotAPeriod:
    stosb
    inc     bx
    jmp     NoSpace

DoneName:
    mov     cs:[InputLength],bx
    or      dx,dx
    jne     AttachStuff

    mov     ds,cs:[DataStuffSeg]
    mov     si,cs:[ExtOff]
    mov     cx,5        ;copies extension to end of filename (eg. ".MOD" )
    rep     movsb
AttachStuff:
    mov     byte ptr [di],0
    mov     byte ptr [di+1],"$"
Capdone:

    pop     es ds
    popa
    mov     ax,cs:[InputLength] ;return # of bytes 
    ret
GetCommandLine endp

    END

    
