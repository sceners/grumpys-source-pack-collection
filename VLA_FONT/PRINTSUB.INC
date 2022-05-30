	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	;Waits until either Yy or Nn is pressed, returns CF=1 for YES
	; and CF=0 for NO
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC YesNo
	push    ax

@@TopOLoop:
	mov     ah,0
	int     16h
	cmp     al,"Y"
	je      @@Yes
	cmp     al,"y"
	je      @@Yes
	cmp     al,"N"
	je      @@No
	cmp     al,"n"
	je      @@No
	jmp     @@TopOLoop
@@Yes:
	stc
	pop     ax
	ret
@@NO:
	clc
	pop     ax
	ret
ENDP
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	;   Prints azero terminating string
	;
	; IN: ds:si = source
	;OUT:    cx = # of char written
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC PrintZ
	push    si dx ax
	cld
	xor     cx,cx
@@TheLoop:
	mov     dl,[si]
	or      dl,dl
	je      @@Done
	mov     ah,2
	int     21h

	inc     cx
	inc     si
	jmp     @@TheLoop

@@Done:
	pop     ax dx si
	ret
ENDP

	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	; Print a number to memory
	; does not print leading zeros... prints spaces instead  
	; & tacks on a zero at the end
	;
	;IN: eax = number to print
	;     cx = number of digits to print (max 11)
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC DEC_Print2Mem NEAR
	push    bp cx eax edx ebx si
	cld
	mov     bp,cx
	
	cld
	xor     si,si
	or      eax,eax
	jns     @@NoPrintSign
	inc     si              ;si not zero means we print a sign
	dec     bp              ;count the sign
	neg     eax
@@NoPrintSign:

	mov     cx,11
	mov     ebx,10
@@DLNum:
	xor     edx,edx
	div     ebx
	add     dl,'0'
	push    dx      ;push the result
	loop    @@DLNum

	mov     cx,11
	mov     dh,0    ;flag if we hit non-zero yet
@@DLNum2:
	pop     ax
	cmp     cx,bp
	ja      @@DontPrintThisYet
	cmp     al,"0"
	jne     @@NotZero
	or      dh,dh
	jne     @@NotZero
	cmp     cx,1
	je      @@NotZero   ;print last zero if its leading
	mov     al,' '
	jmp     @@PrintIt
@@NotZero:
	inc     dh
	dec     si
	js      @@PrintIt
	mov     [BYTE es:di],"-"
	inc     di
@@Printit:
	stosb
@@DontPrintThisYet:
	loop    @@DLNum2

	pop     si ebx edx eax cx bp
	ret
ENDP
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	; Print a number to the screen
	; does not print leading zeros... prints spaces instead
	;
	;IN: eax = number to print
	;     cx = number of digits to print (max 11)
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC DEC_Print NEAR
	push    bp cx eax edx ebx si
	cld
	mov     bp,cx
	
	xor     si,si
	or      eax,eax
	jns     @@PrintSign
	inc     si              ;si not zero means we print a sign
	dec     bp              ;count the sign
	neg     eax
@@PrintSign:

	mov     cx,11
	mov     ebx,10
@@DLNum:
	xor     edx,edx
	div     ebx
	add     dl,'0'
	push    dx      ;push the result
	loop    @@DLNum

	mov     cx,11
	mov     dh,0    ;flag if we hit non-zero yet
@@DLNum2:
	pop     ax
	cmp     cx,bp
	ja      @@DontPrintThisYet
	cmp     al,"0"
	jne     @@NotZero
	or      dh,dh
	jne     @@NotZero
	cmp     cx,1
	je      @@NotZero   ;print last zero if its leading
	mov     al,' '
	jmp     @@PrintIt
@@NotZero:
	inc     dh
	dec     si
	js      @@PrintIt
	push    ax
	mov     ah,2
	mov     dl,"-"
	int     21h
	pop     ax
@@Printit:
	mov     ah,2
	mov     dl,al
	int     21h
@@DontPrintThisYet:
	loop    @@DLNum2

	pop     si ebx edx eax cx bp
	ret
ENDP
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	; Prints A HEX number to memory.. 
	;
	;IN: es:di = points to start of 8 byte buffer to throw results in
	;    eax   = number to display
	;    cx    = # of hex to display MAX 8
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
HexChart    db  "0123456789ABCDEF"

PROC Hex_Print2Mem NEAR
		pusha
		cld
		mov     bp,cx

		mov     dx,8
		xor     bx,bx
@@PHexLoop:
		mov     bl,al
		and     bl,0fh
		mov     cl,[cs:HexChart+bx]
		push    cx

		shr     eax,4
		dec     dx
		jne     @@PhexLoop

		mov     cx,8
@@PhexLoop2:
		pop     ax
		cmp     cx,bp
		ja      @@NoPrintHex
		stosb
@@NoPrintHex:
		loop    @@PhexLoop2
		
		popa
		ret
ENDP
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	; Prints a HEX number to the screen
	;
	;IN:    eax = number to display
	;       cx  = # of hex to display MAX 8
	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC Hex_Print NEAR
		pusha
		push    ds
		cld
		mov     bp,cx

		mov     dx,8
		xor     bx,bx
@@PHexLoop:
		mov     bl,al
		and     bl,0fh
		mov     cl,[cs:HexChart + bx]
		push    cx

		shr     eax,4
		dec     dx
		jne     @@PhexLoop

		mov     cx,8
		mov     ah,2
@@PhexLoop2:
		pop     dx          ;dl = char to print

		cmp     cx,bp
		ja      @@NoPrintHex

		int     21h
@@NoPrintHex:
		loop    @@PhexLoop2
		
		pop     ds
		popa
		ret
ENDP
