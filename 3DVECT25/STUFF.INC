defpal  db 0,0,0,0,0,42,0,42,0,0,42,42,42,0,0,42
        db 0,42,42,42,0,42,42,42,0,0,21,0,0,63,0,42
        db 21,0,42,63,42,0,21,42,0,63,42,42,21,42,42,63
        db 0,21,0,0,21,42,0,63,0,0,63,42,42,21,0,42
        db 21,42,42,63,0,42,63,42,0,21,21,0,21,63,0,63
        db 21,0,63,63,42,21,21,42,21,63,42,63,21,42,63,63
        db 21,0,0,21,0,42,21,42,0,21,42,42,63,0,0,63
        db 0,42,63,42,0,63,42,42,21,0,21,21,0,63,21,42
        db 21,21,42,63,63,0,21,63,0,63,63,42,21,63,42,63
        db 21,21,0,21,21,42,21,63,0,21,63,42,63,21,0,63
        db 21,42,63,63,0,63,63,42,21,21,21,21,21,63,21,63
        db 21,21,63,63,63,21,21,63,21,63,63,63,21,63,63,63

; make endpage screen

endpage:
        push    offset gamecolr
        call    fadeoffpalette

        call    mode03
        call    wipeoffpalette

        mov     edx,offset endtext
        call    _putdosmsg

        push    offset defpal
        call    fadeonpalette

        jmp _exit    ; protected mode exit

_putdosmsg:
        push ax
        push edx
        add edx,_code32a
        mov al,dl
        and ax,0fh
        shr edx,4
        mov v86r_ds,dx
        mov v86r_dx,ax
        mov v86r_ah,9
        mov al,21h
        int 33h
        pop edx
        pop ax
        ret

hextbl          db      '0123456789ABCDEF'

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Put 8 digit hex number to screen buffer
; In:
;   EAX - number to put
;   EDI -> screen buffer location to put at
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
_puthexnum:
        push eax ebx ecx edx edi
        mov ebx,offset hextbl
        mov edx,eax
        mov ecx,8
        mov ah,0fh
puthexnuml0:
        rol edx,4
        mov al,dl
        and al,0fh
        xlat
        stosw
        loop puthexnuml0
        pop edi edx ecx ebx eax
        ret

wipe_v_memory:
        @rlp edi,0a0000h
        mov ecx,320*200*4/4/4
        xor eax,eax

        rep stosd

        ret

endtext db "I'll bet you didn't expect that!",13,10
        db 13,10
        db "John McCarthy tries to be a regular on Digital Pixel: (416) 298-1487",13,10
        db 13,10
        db "Or write to this address:",13,10
        db 13,10
        db "    John McCarthy",13,10
        db "    1316 Redwood Lane",13,10
        db "    Pickering, Ontario.",13,10
        db "    Canada, Earth, Milky Way.",13,10
        db "    L1X 1C5",13,10
        db "$"

