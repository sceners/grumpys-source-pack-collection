        DOSSEG
        .MODEL SMALL
        .STACK 200h
        .CODE
        .286
        LOCALS
        Ideal

        ASSUME  CS:@CODE, DS:@CODE
        
GLOBAL  PrintByte:NEAR

;======- DATA -======

message db      13,10,"Hit a key: $"

Credits db      13,10,"It's over...$"

OLDINT  dd      0

Numtoprint db   0

keystring db 128 dup ("-"),"$"

;======SUBROUTINES================

PROC Doint near
        pusha
        mov     ah,35h
        mov     al,15h
        int     21h
        mov     [WORD cs:oldint],bx
        mov     [WORD cs:oldint+2],es
        mov     al,15h
        mov     ah,25h
        mov     dx,offset interrupt
        mov     bx,cs
        mov     ds,bx
        int     21h
        popa
        ret
ENDP Doint

PROC unDoint near
        pusha
        mov     dx,[WORD cs:oldint]
        mov     ax,[WORD cs:oldint+2]
        mov     ds,ax
        mov     al,15h
        mov     ah,25h
        int     21h
        popa
        ret
ENDP unDoint

interrupt:
        cmp     ah,4fh
        jne     noint
        pusha
        mov     [cs:numtoprint],al
        mov     bl,al
        xor     bh,bh
        cmp     bl,0e0h       ;is it special character?
        je      doneint
        mov     al,"+"
        test    bl,10000000b
        je      turnon
        mov     al,"-"
Turnon:
        and     bl,01111111b
        mov     [cs:keystring+bx],al
Doneint:
        clc
        popa
        iret    ;retf 2 if you do a retf 2, then this program will not exit
noint:
        pushf
        call    [DWORD CS:OLDINT]   ;there are other services on int 15h
        iret

;======- End Subs -======

START:
        mov     AX,CS
        MOV     ds,ax
        mov     es,ax
        mov     ax,0003h
        int     10h

        call    doint

        mov     ah,9
        mov     bx,cs
        mov     ds,bx
        mov     es,bx
        mov     dx,offset message
        int     21h

Nokeypress:
        mov     ah,2
        xor     bh,bh
        xor     dx,dx
        int     10h
        
        mov     ah,9
        mov     dx,offset keystring
        int     21h

        mov     al,[numtoprint]
        call    PrintByte

        mov     ah,1
        int     16h
        jz      nokeypress
        xor     ah,ah
        int     16h
        
        cmp     al,"q"
        jne     nokeypress

        mov     ah,9
        mov     dx,offset credits
        int     21h

        call    undoint

        mov     ax,4c00h
        int     21h

END START

; what it does:
;     interrupt #9 calls int 15h fn#4fh with the make or break key codes
;     normally, this function is simply a iret.  I redefine it to be a
;     bit of code that takes the make and break scan codes and turns on or
;     off a corresponding byte. (+ or -) Useful?  if you set the carry flag,
;     the new key is in al.  Obviously, you cannot change the flags when you
;     do an iret, so you have to do a retf 2.  The '2' pops 2 bytes off the
;     stack when returning.
