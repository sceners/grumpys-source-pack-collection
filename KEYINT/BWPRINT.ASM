    DOSSEG

    .MODEL SMALL
    .386
    .CODE
    ASSUME cs:@code, ds:@code

    GLOBAL  PrintByte:PROC, PrintWord:PROC, PrintBig:PROC
    GLOBAL  PrintHexByte:PROC, PrintHexWord:PROC, PrintHexBig:PROC
    GLOBAL  PrintHex:PROC, PrintNum:PROC
    GLOBAL  PrintString:PROC

    TextNumBIG  db  "00000"
    TextNum     db  "00000"
    TextNumEnd  db  0,"$"

    HexResult   db  "00000000",0,'$'
    HexChart    db  "0123456789ABCDEF"

;==- Subroutines
    ;ds:dx points to a string to print.  
    ;cx is the length if cx= 0 prints until whats in al is hit
PrintString PROC NEAR
    pusha
    jcxz    DoAlTerm

    mov     si,dx
    mov     ah,2
PSloop:
    mov     dl,ds:[si]
    int     21h
    inc     si
    
    dec     cx
    jne     PsLoop
AllDonePr:
    popa
    ret

DoAlTerm:
    mov     si,dx
    mov     ah,2
PSloop2:
    mov     dl,ds:[si]
    cmp     al,dl
    je      AllDonePr
    push    ax
    int     21h
    pop     ax
    inc     si
    jmp     PsLoop2

PrintString ENDP

    ;es:di points to start of 10 byte buffer to throw results in
    ;eax is number to display
    ;bp is the number of digits max 10
PrintNum PROC NEAR
    pusha

    mov     cx,10
    mov     ebx,10
DLNum:
    xor     edx,edx
    div     ebx
    add     dl,'0'
    push    dx      ;push the result
    loop    DLNum

    mov     cx,10
DLNum2:
    pop     ax
    cmp     cx,bp
    ja      DontPrintThisYet
    stosb
DontPrintThisYet:
    loop    DLNum2
    
    popa
    ret
PrintNum ENDP

    ;es:di points to start of 8 byte buffer to throw results in
    ;eax is number to display
    ;bp is # of hex to display MAX 8
PrintHex PROC NEAR
        pusha
        cld
        mov     cx,seg HexChart
        mov     ds,cx

        mov     dx,8
        xor     bx,bx
PHexLoop:
        mov     bl,al
        and     bl,0fh
        mov     cl,ds:[HexChart+bx]
        push    cx

        shr     eax,4
        dec     dx
        jne     PhexLoop

        mov     cx,8
PhexLoop2:
        pop     ax
        cmp     cx,bp
        ja      NoPrintHex
        stosb
NoPrintHex:
        loop    PhexLoop2
        
        popa
        ret
PrintHex ENDP

PrintHexByte PROC NEAR
        pusha
        and     eax,0ffh
        mov     di,offset HexResult
        mov     cx,seg HexResult
        mov     es,cx

        call    PrintHex
        mov     dx,offset HexResult+6
        mov     ah,9
        int     21h
        popa
        ret
PrintHexByte ENDP

PrintHexWord PROC NEAR
        pusha
        and     eax,0ffffh
        mov     di,offset HexResult
        mov     cx,seg HexResult
        mov     es,cx

        call    PrintHex
        mov     dx,offset HexResult+4
        mov     ah,9
        int     21h
        popa
        ret
PrintHexWord ENDP

PrintHexBig PROC NEAR
        pusha
        mov     di,offset HexResult
        mov     cx,seg HexResult
        mov     es,cx

        call    PrintHex
        mov     dx,offset HexResult
        mov     ah,9
        int     21h
        popa
        ret
PrintHexBig ENDP

BinToAscII PROC
        mov     bx,10
        mov     si,SEG TextNum
        mov     es,si
        mov     si,offset textnumend-1
        mov     cx,5
DivLoop:
        sub     dx,dx
        div     bx
        add     dl,'0'
        mov     es:[si],dl
        dec     si
        loop    DivLoop
        ret
ENDP BinToAscII

B2ABig PROC
        mov     ebx,10
        mov     si,SEG TextNum
        mov     es,si
        mov     si,offset textnumend-1
        mov     cx,10
DLBig:
        sub     edx,edx
        div     ebx
        add     dl,'0'
        mov     es:[si],dl
        dec     si
        loop    DLBig
        ret
ENDP B2ABig

PrintBig PROC
    pushad

    call    b2aBig
    mov     ax,SEG TextNumBig
    mov     ds,ax
    mov     dx,offset textnumBig
    mov     ah,9
    int     21h

    popad
    ret
ENDP PrintBig

PrintByte PROC
    pusha
    jnc     skipsignb
    xor     ah,ah
    test    al,10000000b
    jz      skipsignb
    neg     al
    push    ax
    mov     ah,2
    mov     dl,"-"
    int     21h
    pop     ax
    jmp     skipb

skipsignb:
    xor     ah,ah
    push    ax
    mov     ah,2
    mov     dl," "
    int     21h
    pop     ax
skipb:
    call    bintoascii
    mov     ax,SEG TextNum
    mov     ds,ax
    mov     dx,offset textnum+2
    mov     ah,9
    int     21h
    popa
    ret
ENDP PrintByte

PrintWord PROC
    pusha
    jnc     skipsignw
    test    ah,10000000b
    jz      skipsignw
    neg     ax
    push    ax
    mov     ah,2
    mov     dl,"-"
    int     21h
    pop     ax
    jmp     skipw
Skipsignw:        
    push    ax
    mov     ah,2
    mov     dl," "
    int     21h
    pop     ax
Skipw:
    call    bintoascii
    mov     ax,SEG TextNum
    mov     ds,ax
    mov     dx,offset textnum
    mov     ah,9
    int     21h
    popa
    ret
ENDP PrintWord

    END
    

