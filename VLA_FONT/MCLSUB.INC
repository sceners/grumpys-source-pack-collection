;FILE: MCLSUB.ASM
;upon entry: 
;
;*      ES= PSP SEG 
;*      DS:DX = pointer to filename area
;*      DS:BX = pointer to ASCIIZ Extension to add
;*      BP    = 1, override extension. =0 extension only if there is none
;
;RETURN:    AX= length of command line
;
;       Removes anything < a space...
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MCL_L   dw  ?
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC GetCommandLine
    pusha
    
    mov     si,128      ;es:si points to command line
    movzx   ax,[BYTE es:si]
    mov     [cs:MCL_L],ax
    or      ax,ax
    je      @@AllDone
    inc     si          ;point to 1st byte of command line
    mov     cx,ax
    
    mov     di,dx       ;ds:di points to filename area
    xor     dl,dl       ;flag for "." hit
@@CopyLoop:
    mov     al,[es:si]
    inc     si
    cmp     al," "
    jbe     @@DontStore
    cmp     al,"."
    je      @@HandleDot
@@NoOverRide:
    mov     [di],al
    inc     di
@@DontStore:
    loop    @@CopyLoop
    or      dl,dl           ;did we hit a dot?
    je      short @@Copy2Loop   ;nope, tack one on..
    jmp     short @@AllDone1

@@HandleDot:
    inc     dl          ;save hit "."
    cmp     bp,1
    jne     @@NoOverRide
    
@@Copy2Loop:
    mov     al,[bx]
    inc     bx
    or      al,al
    je      @@AllDone1
    mov     [di],al
    inc     di
    jmp     short @@Copy2Loop
@@AllDone1:
    mov     [BYTE di],0     ;tack on the zero...
@@AllDone:
    popa
    mov     ax,[cs:MCL_L]
    ret
ENDP
