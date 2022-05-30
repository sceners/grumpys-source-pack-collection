;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                           บ
;บ                Polygonfiller for Texturemapped polygons                   บ
;บ                                                                           บ
;บ          Draws a Texture-mapped polygon in Tweakedmode (320x200)          บ
;บ                                                                           บ
;บ                          Programmed by Fantom                             บ
;บ                                                                           บ
;บ                 (c) An Ultimate Brains Production (c)                     บ
;บ                                                                           บ
;บ                     Version 2.4 / 17.8.93 / 12.19                         บ
;บ                                                                           บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

;                       Texture Mapping
;                       ---------------

;        ษอออออออออออออหอออออออออออออออออออออออออออป
;        บ UPPER 16BIT บ        LOWER 16BIT        บ
;ษอออออออฮอออออออออออออฮอออออออออออออหอออออออออออออน  Inner: add ecx,eax
;บ  REG  บ   HI WORD   บ   HI BYTE   บ   LO BYTE   บ         adc ebx,ebp
;ฬอออออออฮอออออออออออออฮอออออออออออออฮอออออออออออออน         adc bh,dl
;บ  EAX  บ  X-INC LSW  บ     ---     บ     ---     บ         mov dh,[ds:bx]
;ฬอออออออฮอออออออออออออฮอออออออออออออฮอออออออออออออน         mov [es:di],dh
;บ  ECX  บ  TXT-X LSW  บ     ---     บ  LOOPCOUNT  บ         add di,80
;ฬอออออออฮอออออออออออออฮอออออออออออออฮอออออออออออออน         loop Inner
;บ  EDX  บ     ---     บ TEXTUREDATA บ    Y-INC    บ
;ฬอออออออฮอออออออออออออฮอออออออออออออฮอออออออออออออน
;บ  EBP  บ  Y-INC LSW  บ X-INC  SIGN บ    X-INC    บ
;ฬอออออออฮอออออออออออออฮอออออออออออออฮอออออออออออออน
;บ  EBX  บ  TXT-Y LSW  บ  TEXTURE Y  บ  TEXTURE X  บ
;ศอออออออสอออออออออออออสอออออออออออออสอออออออออออออผ

	Ideal
	model small
	P386

SC_INDEX                equ     03c4h   ;Sequence Controller Index
CRTC_INDEX              equ     03d4h   ;CRT Controller Index
MISC_OUTPUT             equ     03c2h   ;Miscellaneous Output register
SCREEN_SEG              equ     0a000h  ;segment of display memory in TweakM
SCREEN_WIDTH            equ     320
MAP_MASK                equ     2       ;Map Mask register index in SC
INPUT_STATUS_1          equ     03dah   ;Input Status 1 register
START_ADDRESS_HIGH      equ     0ch     ;bitmap start address high db
START_ADDRESS_LOW       equ     0dh     ;bitmap start address low db
Row                     =       0

;ออออออออออออออออออออออออ
	MACRO sini                              ;;eax=sin(ax)*32768
;ออออออออออออออออออออออออ

	and ax,255
	shl ax,1
	push bx
	mov bx,ax
	xor eax,eax
	mov ax,[sintable+bx]
	pop bx

	ENDM

;ออออออออออออออออออออออออ
	MACRO kosini                            ;;eax=cos(ax)*32768
;ออออออออออออออออออออออออ

	add ax,64
	and ax,255
	shl ax,1
	push bx
	mov bx,ax
	xor eax,eax
	mov ax,[sintable+bx]
	pop bx

	ENDM

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	Segment Code 'Code'                 ;Ok... Let's code it!
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

	Assume cs:Code,ds:Data

Start:  call InitD
	call Tweakon
	call SetPalette

Again:  call waitborder
	call Rotate
	call Proj
	call clean
	call Texture
	call showp
	add [XRot+4],1
	mov ah,0bh
	int 21h
	cmp al,0ffh
	jne Again
	mov ah,7
	int 21h
	cmp al,1bh
	je Stop
	jmp Again
Stop:   mov ax,3
	int 10h
	mov ah,4ch
	int 21h

;ออออออออออออออออออออออออ
	Proc Texture
;ออออออออออออออออออออออออ


	xor bx,bx
	call TopLeft
	call InitTex

FillL:  call FillIt
	dec [Top]
	jge NoSrcT
	call NewSTop
	dec [Top]
	jmp SkipST
NoSrcT: mov eax,[SrcTXA]
	mov ebx,[SrcTYA]
	add [SrcTX],eax
	add [SrcTY],ebx
SkipST: dec [Bot]
	jge NoSrcB
	call NewSBot
	dec [Bot]
	jmp SkipSB
NoSrcB: mov eax,[SrcBXA]
	mov ebx,[SrcBYA]
	add [SrcBX],eax
	add [SrcBY],ebx

SkipSB: inc [DestTX]
	dec [DTop]
	jge NoDTop
	call NewTop
	jmp SkipDT
NoDTop: mov eax,[DestTYA]
	add [DestTY],eax

SkipDT: dec [DBot]
	jge NoDBot
	call NewBot
	jmp SkipDB
NoDBot: mov eax,[DestBYA]
	add [DestBY],eax

SkipDB: dec [PolWidht]
	jge FillL
	ret

	ENDP

;ออออออออออออออออออออออออ
	Proc FillIt
;ออออออออออออออออออออออออ

	mov dx,SC_INDEX
	mov al,MAP_MASK
	out dx,al
	mov ax,[Word DestBY+2]
	sub ax,[Word DestTY+2]
	jl SkipIt
	inc ax
	mov [Dest],ax

	mov eax,[SrcTX]
	mov edx,[SrcTY]
	mov ebx,[SrcBX]
	mov ecx,[SrcBY]

	sub ebx,eax
	sub ecx,edx
	mov eax,ebx
	mov bx,[Dest]
	movsx ebx,bx
	cdq
	idiv ebx
	mov [SXA],eax
	mov eax,ecx
	cdq
	idiv ebx
	mov [SYA],eax

	mov ax,SCREEN_SEG
	add ax,[PageOffset]
	mov es,ax
	mov bx,[Word DestTY+2]
	add bx,bx
	mov di,[Rows+bx]
	mov bx,[DestTX]
	mov cx,bx
	shr bx,2
	add di,bx
	and cx,3
	mov al,1
	shl al,cl
	mov dx,SC_INDEX+1
	out dx,al

	mov ebp,[SYA]
	rol ebp,16
	mov dx,bp
	mov eax,[SXA]
	rol eax,16
	mov bp,ax
	xor ax,ax
	mov ecx,[SrcTX]
	rol ecx,16
	mov ebx,[SrcTY]
	rol ebx,16
	mov bh,bl
	mov bl,cl

	mov cx,[Dest]
	dec cx
	jz SkipIt

InnerL: add ecx,eax
	adc ebx,ebp
	adc bh,dl
	mov dh,[Tex+bx]
	mov [es:di],dh
	add di,80
	loop InnerL
SkipIt: ret

	ENDP

;ออออออออออออออออออออออออ
	Proc InitTex
;ออออออออออออออออออออออออ

	mov ax,[TopP]
	mov [CurTE],ax
	mov [CurBE],ax
	mov [CurSTE],ax
	mov [CurSBE],ax

	call NewTop
	call NewBot
	call NewSTop
	call NewSBot
	ret

	ENDP

;ออออออออออออออออออออออออ
	Proc NewSTop
;ออออออออออออออออออออออออ

	mov ax,[NTop]
	mov [Top],ax

	mov bx,[CurSTE]

	add bx,bx
	mov bx,[TPol+bx]
	shl bx,2
	mov ax,[TPisteet+bx]
	mov cx,[TPisteet+bx+2]

	mov bx,[CurSTS]
	add bx,bx
	mov bx,[TPol+bx]
	shl bx,2
	sub ax,[TPisteet+bx]
	sub cx,[TPisteet+bx+2]

	mov dx,[TPisteet+bx]
	mov bx,[TPisteet+bx+2]
	shl ebx,16
	shl edx,16
	mov [SrcTX],edx
	mov [SrcTY],ebx
	mov si,[Top]
	inc si
	movsx esi,si
	movsx eax,ax
	shl eax,16
	cdq
	idiv esi
	mov [SrcTXA],eax
	add [SrcTX],eax

	movsx eax,cx
	shl eax,16
	cdq
	idiv esi
	mov [SrcTYA],eax
	add [SrcTY],eax
	ret

	ENDP

;ออออออออออออออออออออออออ
	Proc NewSBot
;ออออออออออออออออออออออออ

	mov ax,[NBot]
	mov [Bot],ax

	mov bx,[CurSBE]

	add bx,bx
	mov bx,[TPol+bx]
	shl bx,2
	mov ax,[TPisteet+bx]
	mov cx,[TPisteet+bx+2]

	mov bx,[CurSBS]
	add bx,bx
	mov bx,[TPol+bx]
	shl bx,2
	sub ax,[TPisteet+bx]
	sub cx,[TPisteet+bx+2]

	mov dx,[TPisteet+bx]
	mov bx,[TPisteet+bx+2]
	shl ebx,16
	shl edx,16
	mov [SrcBX],edx
	mov [SrcBY],ebx
	mov si,[Bot]
	inc si
	movsx esi,si
	movsx eax,ax
	shl eax,16
	cdq
	idiv esi
	mov [SrcBXA],eax
	add [SrcBX],eax

	movsx eax,cx
	shl eax,16
	cdq
	idiv esi
	mov [SrcBYA],eax
	add [SrcBY],eax
	ret

	ENDP

;ออออออออออออออออออออออออ
	Proc NewTop
;ออออออออออออออออออออออออ

NewT:   mov ax,[CurTE]
	mov [CurTS],ax
	mov [CurSTS],ax
	mov bx,ax
	inc bx
	and bx,3
	mov [CurTE],bx
	mov [CurSTE],bx

	add bx,bx
	mov bx,[Pol+bx]
	shl bx,2
	mov ax,[Pisteet+bx]
	mov cx,[Pisteet+bx+2]

	mov bx,[CurTS]
	add bx,bx
	mov bx,[Pol+bx]
	shl bx,2
	sub ax,[Pisteet+bx]
	jz NewT
	mov [DTop],ax
	jge NoNeg
	sub ax,2
	neg [DTop]
NoNeg:  inc ax
	sub cx,[Pisteet+bx+2]
	jge NoNeg1
	sub cx,2
NoNeg1: inc cx

	mov bx,[Pisteet+bx+2]
	shl ebx,16
	mov [DestTY],ebx

	mov si,[DTop]
	mov [NTop],si
	inc [NTop]

	movsx eax,cx
	add si,2
	movsx esi,si
	shl eax,16
	cdq
	idiv esi
	mov [DestTYA],eax
	bt eax,31
	jnc NoNeg2
	add [DestTY],eax
	add [DestTY],10000h
NoNeg2: ret

	ENDP

;ออออออออออออออออออออออออ
	Proc NewBot
;ออออออออออออออออออออออออ

NewB:   mov ax,[CurBE]
	mov [CurBS],ax
	mov [CurSBS],ax
	mov bx,ax
	dec bx
	and bx,3
	mov [CurBE],bx
	mov [CurSBE],bx

	add bx,bx
	mov bx,[Pol+bx]
	shl bx,2
	mov ax,[Pisteet+bx]
	mov cx,[Pisteet+bx+2]

	mov bx,[CurBS]
	add bx,bx
	mov bx,[Pol+bx]
	shl bx,2
	sub ax,[Pisteet+bx]
	jz NewB
	mov [DBot],ax
	jge NoNeg3
	sub ax,2
	neg [DBot]
NoNeg3: inc ax
	sub cx,[Pisteet+bx+2]
	jge NoNeg4
	sub cx,2
NoNeg4: inc cx

	mov bx,[Pisteet+bx+2]
	shl ebx,16
	mov [DestBY],ebx

	mov si,[DBot]
	mov [NBot],si
	inc [NBot]

	movsx eax,cx
	add si,2
	movsx esi,si
	shl eax,16
	cdq
	idiv esi
	mov [DestBYA],eax
	bt eax,31
	jnc NoNeg5
	add [DestBY],10000h
	ret
NoNeg5: add [DestBY],eax
	ret

	ENDP

;ออออออออออออออออออออออออ
	PROC TopLeft
;ออออออออออออออออออออออออ

	mov [Py],32767
	mov [Px],32767
	mov [Sx],0

	mov ax,32767
	xor bx,bx
	xor si,si
	xor ecx,ecx
	mov di,[Poly+bx]
	mov cx,4
	mov [TopP],0
Poll:   push ecx
	mov cx,[ds:di]
	mov bx,[Pisteet+ecx*4]
	mov cx,[Pisteet+ecx*4+2]
	cmp bx,ax
	ja  Jatka2
	mov ax,bx
	mov [Px],bx
	jl  ThisOne
	cmp [Py],cx
	jle Jatka2
ThisOne:mov [Py],cx
	mov [TopP],si
Jatka2: cmp [Sx],bx
	ja Menoks
	mov [Sx],bx
Menoks: inc si
	add di,2
	pop ecx
	dec ecx
	jnz poll
	mov ax,[Sx]
	sub ax,[Px]
	inc ax
	mov [PolWidht],ax
	mov ax,[Px]
	mov [DestTX],ax
	ret

	ENDP

;ออออออออออออออออออออออออ
	PROC TweakOn
;ออออออออออออออออออออออออ

	mov     ax,13h
	int     10h
	mov     dx,SC_INDEX
	mov     ax,0604h
	out     dx,ax
	mov     dx,SC_INDEX
	mov     ax,0f02h
	out     dx,ax
	mov     ax,SCREEN_SEG
	mov     es,ax
	sub     di,di
	sub     ax,ax
	mov     cx,8000h
	rep     stosw
	mov     dx,CRTC_INDEX
	mov     ax,14h
	out     dx,ax
	mov     ax,0e317h
	out     dx,ax
	ret

	ENDP

;ออออออออออออออออออออออออ
	PROC InitD
;ออออออออออออออออออออออออ

	cld
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi
	xor esi,esi
	mov ax,Data
	mov ds,ax
	ret

	ENDP

;ออออออออออออออออออออออออ
	PROC SetPalette
;ออออออออออออออออออออออออ

	mov     si,Offset Pal
	mov     al,0
	mov     dx,3c8h
	out     dx,al
	mov     dx,3c9h
	mov     cx,768
invid1: lodsb
	out     dx,al
	loop    invid1
	ret

	ENDP

;ออออออออออออออออออออออออ
	PROC WaitBorder
;ออออออออออออออออออออออออ

	push    ax
	push    dx
	mov     dx,3dah
wbr1:   in      al,dx
	test    al,8
	jnz     wbr1
wbr2:   in      al,dx
	test    al,8
	jz      wbr2
	pop     dx
	pop     ax
	ret

	ENDP

;ออออออออออออออออออออออออ
	PROC Rotate
;ออออออออออออออออออออออออ

	mov si,Offset Dpist
	mov di,Offset Rotated
	mov cx,4

	mov ax,[XRot]
	sini
	mov [KXSin],ax
	mov ax,[XRot]
	kosini
	mov [KXCos],ax
	mov ax,[XRot+2]
	sini
	mov [KYSin],ax
	mov ax,[XRot+2]
	kosini
	mov [KYCos],ax
	mov ax,[XRot+4]
	sini
	mov [KZSin],ax
	mov ax,[XRot+4]
	kosini
	mov [KZCos],ax

	mov ax,[KZCos]
	imul [KYCos]
	mov bx,dx
	mov ax,[KZSin]
	imul [KXSin]
	shl dx,1
	mov ax,[KYSin]
	imul dx
	add bx,dx
	mov [Word @@A+1],bx

	mov ax,[KZSin]
	neg ax
	imul [KYCos]
	mov bx,dx
	mov ax,[KZCos]
	imul [KXSin]
	shl dx,1
	mov ax,[KYSin]
	imul dx
	add bx,dx
	mov [Word @@B+1],bx

	mov ax,[KXCos]
	imul [KYSin]
	mov [Word @@C+1],dx

	mov ax,[KZSin]
	imul [KXCos]
	mov [Word @@D+1],dx

	mov ax,[KZCos]
	imul [KXCos]
	mov [Word @@E+1],dx

	mov ax,[KXSin]
	neg ax
	sar ax,1
	mov [Word @@F+1],ax

	mov ax,[KZCos]
	neg ax
	imul [KYSin]
	mov bx,dx
	mov ax,[KZSin]
	imul [KXSin]
	shl dx,1
	mov ax,[KYCos]
	imul dx
	add bx,dx
	mov [Word @@G+1],bx

	mov ax,[KZSin]
	imul [KYSin]
	mov bx,dx
	mov ax,[KZCos]
	imul [KXSin]
	shl dx,1
	mov ax,[KYCos]
	imul dx
	add bx,dx
	mov [Word @@H+1],bx

	mov ax,[KXCos]
	imul [KYCos]
	mov [Word @@L+1],dx

RotL:

@@A:    mov ax,1234h
	imul [Word si]
	mov bx,dx
@@B:    mov ax,1234h
	imul [Word si+2]
	add bx,dx
@@C:    mov ax,1234h
	imul [Word si+4]
	add bx,dx
	shl bx,2
	mov [ds:di],bx

@@D:    mov ax,1234h
	imul [Word si]
	mov bx,dx
@@E:    mov ax,1234h
	imul [Word si+2]
	add bx,dx
@@F:    mov ax,1234h
	imul [Word si+4]
	add bx,dx
	shl bx,2
	mov [ds:di+2],bx

@@G:    mov ax,1234h
	imul [Word si]
	mov bx,dx
@@H:    mov ax,1234h
	imul [Word si+2]
	add bx,dx
@@L:    mov ax,1234h
	imul [Word si+4]
	add bx,dx
	shl bx,2
	mov [ds:di+4],bx

	add si,6
	add di,8
	dec cx
	jnz RotL
	ret

ENDP

;ออออออออออออออออออออออออ
	PROC Proj
;ออออออออออออออออออออออออ

	xor ecx,ecx
	xor edi,edi

	mov cx,1
ML:     xor esi,esi
	push cx
	dec cx
	mov si,[ObjDot+ecx*2]
	mov cx,[si]
	cmp cx,0
	je  @@Next
	add si,2
ProL:   push cx
	mov cx,[ecx*2+esi-2]
	shl cx,2
	mov bp,cx
	add cx,cx
	mov bx,[Rotated+ecx+4]
	movsx ebx,bx
	add ebx,[KZ]
	add ebx,1024

	mov ax,[Rotated+ecx]
	cwde
	cdq
	shl eax,8
	idiv ebx
	mov dx,ax
	sar dx,2
	add ax,dx
	add ax,[XCenter]
	mov [Pisteet+bp],ax

	mov ax,[Rotated+ecx+2]
	cwde
	neg eax
	cdq
	shl eax,8
	idiv ebx
	add ax,[YCenter]
	mov [Pisteet+bp+2],ax

	pop cx
	dec cx
	jnz ProL
@@Next: pop cx
	dec cx
	jnz ML
	ret

	ENDP

;ออออออออออออออออออออออออ
	PROC Clean
;ออออออออออออออออออออออออ

	mov dx,SC_INDEX
	mov ax,0f02h
	out dx,ax
	mov ax,SCREEN_SEG
	add ax,[PageOffset]
	mov es,ax
	sub di,di
	sub eax,eax
	mov cx,4000
lop:    rep stosd
	ret

	ENDP

;ออออออออออออออออออออออออ
	PROC ShowP
;ออออออออออออออออออออออออ

	push    bx
	push    cx
	push    dx
	push    ax

	mov     bl,START_ADDRESS_LOW
	mov     bh,[Byte ptr StartOffset]
	mov     cl,START_ADDRESS_HIGH
	mov     ch,[Byte ptr StartOffset+1]
	mov     dx,CRTC_INDEX
	mov     ax,bx
	out     dx,ax
	mov     ax,cx
	out     dx,ax

	cmp     [PageOffset],0
	jne     Page0
	mov     [PageOffset],1024
	mov     [StartOffset],16384
	pop     ax
	pop     dx
	pop     cx
	pop     bx
	ret

Page0:  mov     [PageOffset],0
	mov     [StartOffset],0
	pop     ax
	pop     dx
	pop     cx
	pop     bx
	ret

	ENDP

	ENDS

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	Segment Data 'Data'
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ



	Label Sintable Word

	include "sintable.inc"

	Label Tex Byte

	include "texture.inc"

	dw 256 DUP(0)

	Label Pal Byte

	include "textpal.inc"

KXSin   dw 0
KXCos   dw 0
KYSin   dw 0
KYCos   dw 0
KZSin   dw 0
KZCos   dw 0
XRot    dw 0,0,0
ObjDot  dw Point
Point   dw 4,0,1,2,3
XCenter dw 160
YCenter dw 100
KZ      dd 2300
StartOffset dw 0
PageOffset  dw 0
TopP    dw 0
CurTS   dw 0
CurTE   dw 0
CurBS   dw 0
CurBE   dw 0
CurSTS  dw 0
CurSTE  dw 0
CurSBS  dw 0
CurSBE  dw 0

SrcTX   dd 0
SrcTY   dd 0
SrcBX   dd 0
SrcBY   dd 0
SrcTXA  dd 0
SrcTYA  dd 0
SrcBXA  dd 0
SrcBYA  dd 0

SXA     dd 0
SYA     dd 0

DestTX  dw 0
DestTY  dd 0
DestBX  dd 0
DestBY  dd 0
DestTXA dd 0
DestTYA dd 0
DestBXA dd 0
DestBYA dd 0

DeltaX  dd 0
DeltaY  dd 0
x1      dw 0
x2      dw 0
y1      dw 0
y2      dw 0
Dest    dw 0
Py      dw 0
Px      dw 0
Sx      dw 0
Top     dw 0
Bot     dw 0
DTop    dw 0
DBot    dw 0
NTop    dw 0
NBot    dw 0
Count   dw 0

PolWidht dw 0
Color   db 0
Frames  dw 0
Taulukko dw 1000 DUP(0)

Dpist   dw -256*3,320*3,0,256*3,320*3,0,256*3,-320*3,0,-256*3,-320*3,0

Rotated dw 500 Dup(0)

LABEL   Rows Word

	Rept 200

	dw Row

	Row = Row+80

	EndM

Poly    dw polygon
polygon dw 0,1,2,3

pol     dw 0,1,2,3

Polyt   dw pol1

pol1    dw 4,0,0,1,2,3

Pisteet dw 500 DUP(0)

Tpol    dw 0,1,2,3

Tpisteet dw 0,0,63,0,63,63,0,63

	ENDS

	Stack 200h

	END start
	END


