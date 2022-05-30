        .386p
        jumps

code16  segment para public use16
        assume cs:code16, ds:code16

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
rmirq0:                                 ; real mode IRQ0 handler
        push ax ds
        mov ax,0b800h
        mov ds,ax
        xor word ptr ds:[(4*160)+(38h*2)],0fdbh
        pop ds
        mov al,20h
        out 20h,al
        pop ax
        iret

code16  ends

code32  segment para public use32
        assume cs:code32, ds:code32

include pmode.inc

public  _main

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ormirq0         dd      ?               ; old real mode IRQ handler seg:off
opmirq0         dd      ?               ; old protected mode IRQ handler off

hextbl          db      '0123456789ABCDEF'

mainstr0        db      'System type:',0
mainstr1        db      'Low memory free:',0
mainstr2        db      'Extended memory free:',0

systypestrtbl   dd      sysstr0,sysstr1,sysstr2,sysstr3
sysstr0         db      'raw',0
sysstr1         db      'XMS',0
sysstr2         db      'VCPI',0
sysstr3         db      'DPMI',0

keystr          db      'Press any key to go on...',0

box1str0        db      'Box 1:',0
box1str1        db      '(protected mode IRQ)',0
box2str0        db      'Box 2:',0
box2str1        db      '(real mode IRQ)',0

infostr0a       db      'Both box 1 and 2 should now be flashing. If only box 1 is flashing, and the',0
infostr0b       db      'system type is DPMI, then your DPMI host is not fully compliant.',0
infostr1a       db      'Only box 2 should now be flashing. Unless the system type is DPMI. In this',0
infostr1b       db      'case, both boxes should be flashing.',0

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
pmirq0:                                 ; protected mode IRQ0 handler
        push ds
        mov ds,cs:_selzero
        xor word ptr ds:[0b8000h+(2*160)+(38h*2)],0fdbh
        pop ds
        jmp cs:opmirq0                  ; chain to old IRQ0 redirector

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
_main:
        sti

        mov eax,gs:[8*4]                ; save real mode IRQ0 vector
        mov ormirq0,eax
        xor bl,bl                       ; get protected mode IRQ0 redirector
        call _getirqvect
        mov opmirq0,edx

        @rlp edi,0b8000h                ; fill VGA screen with char 176
        mov ecx,80*25
        mov ax,08b0h
        rep stosw

        mov ah,7                        ; put system type
        mov bx,202h
        mov edx,offset mainstr0
        call _putstr
        mov ah,0fh
        mov bl,24
        movzx ecx,_sysbyte0
        and cl,3
        mov edx,systypestrtbl[ecx*4]
        call _putstr

        mov ah,7                        ; put amount of low memory
        mov bx,302h
        mov edx,offset mainstr1
        call _putstr
        @rlp edi,0b8000h+(3*160)+(24*2)
        call _lomemsize
        call _puthexnum

        mov ah,7                        ; put amount of extended memory
        mov bx,402h
        mov edx,offset mainstr2
        call _putstr
        @rlp edi,0b8000h+(4*160)+(24*2)
        call _himemsize
        call _puthexnum

        mov ah,7                        ; put box strings and boxes
        mov bx,231h
        mov edx,offset box1str0
        call _putstr
        mov bl,3ah
        mov edx,offset box1str1
        call _putstr
        mov bx,431h
        mov edx,offset box2str0
        call _putstr
        mov bl,3ah
        mov edx,offset box2str1
        call _putstr
        mov word ptr gs:[0b8000h+(2*160)+(38h*2)],0fdbh
        mov word ptr gs:[0b8000h+(4*160)+(38h*2)],0fdbh

        mov ah,8ch                      ; put key message
        mov bx,171bh
        mov edx,offset keystr
        call _putstr

        call _waitforkey                ; non-INT16 wait for keypress

        cli                             ; set IRQ0 to flash boxes
        xor bl,bl
        mov edx,offset pmirq0
        call _setirqvect
        mov word ptr gs:[8*4],offset rmirq0
        mov word ptr gs:[(8*4)+2],code16
        sti

        mov ah,7                        ; put first info
        mov bx,702h
        mov edx,offset infostr0a
        call _putstr
        mov bh,8
        mov edx,offset infostr0b
        call _putstr

        call _waitforkey                ; non-INT16 wait for keypress again

        mov ah,7                        ; put first info
        mov bx,0a02h
        mov edx,offset infostr1a
        call _putstr
        mov bh,0bh
        mov edx,offset infostr1b
        call _putstr

        mov v86r_ah,0                   ; real mode BIOS key wait
        mov al,16h
        int 33h

        mov eax,ormirq0                 ; restore old real mode IRQ0 vector
        mov gs:[8*4],eax

        jmp _exit

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Just wait for a keypress (and nullify it)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
_waitforkey:
        push ax
waitforkeyl0:
        mov ax,gs:[41ah]
        cmp ax,gs:[41ch]
        je waitforkeyl0
        mov gs:[41ch],ax
        pop ax
        ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Put ASCIIZ string to screen
; In:
;   AH - attribute
;   BL - X
;   BH - Y
;   EDX -> ASCIIZ string
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
_putstr:
        push ax esi edi
        movzx edi,bh
        imul edi,160
        movzx esi,bl
        shl esi,1
        lea edi,[edi+esi+0b8000h]
        sub edi,_code32a
        mov esi,edx
putstrl0:
        lodsb
        or al,al
        jz short putstrd
        stosw
        jmp putstrl0
putstrd:
        pop edi esi ax
        ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Put 8 digit hex number to screen buffer
; In:
;   EAX - number to put
;   EDI -> screen buffer location to put at
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
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

code32  ends
        end

