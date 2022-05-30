fixword MACRO ;sets ORG to word paragraph
	if ($-codestart) mod 2
	db 0
	endif
	ENDM

setborder2 MACRO color
	push	ax
	push	dx
	cli
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,11h+32
	out	dx,al
	mov	al,color
	out	dx,al
	sti
	pop	dx
	pop	ax
	ENDM
setborder MACRO color
	;setborder2 color
	ENDM
	
EXTRN	stmik_asm:far
	
code	SEGMENT para public 'CODE'
	ASSUME cs:code

codestart:	
	jmp	main

vram	dw	0a000h	;videoram segment	
rows	dw	200 dup(0) ;addresses to all rows in the screen
winxpos	dw	16	;subwindow x position
owinxpos dw	0	;subwindow x position in previous frame
frametime dw	?
frametimeb dw	?
printcadd db	1
stmikequs dd	?
drunkenstars dw	20
alternatescroll db 0

musicq	dw	16384
stars	dw	32
equson	db	1
nosbc	db	0
sbcio	dw	220h
sbcirq	db	7

palette	LABEL BYTE
db 0,0,0,0,0,42,2,2,43,5,5,45,9,9,46,13
db 13,48,17,17,49,21,21,51,25,25,52,30,30,54,35,35
db 55,40,40,57,45,45,58,51,51,60,56,56,61,63,63,63
db 59,59,59,55,55,55,52,52,52,48,48,48,45,45,45,42
db 42,42,38,38,38,35,35,35,31,31,31,28,28,28,25,25
db 25,21,21,21,18,18,18,14,14,14,11,11,11,8,8,8
db 24,8,8,26,11,8,28,15,9,30,19,10,33,23,11,35
db 28,11,37,34,12,40,40,13,42,42,12,45,45,11,48,48
db 10,51,51,9,54,54,21,57,57,33,60,60,47,63,63,63
db 63,49,49,63,41,41,63,34,34,63,27,27,63,20,20,63
db 13,13,63,6,6,63,0,0,57,0,0,51,0,0,45,0
db 0,39,0,0,33,0,0,27,0,0,21,0,0,16,0,0
db 63,63,51,59,59,41,55,55,32,51,51,23,47,48,16,43
db 44,9,40,40,4,36,36,5,32,32,6,28,28,6,24,24
db 6,20,20,6,16,16,5,12,12,4,9,9,3,5,5,2
db 45,63,0,35,59,0,26,56,0,18,53,0,11,49,0,4
db 46,0,0,43,0,0,39,0,0,44,31,0,39,27,0,34
db 24,0,29,21,0,24,17,0,19,14,0,14,10,0,10,7
db 63,52,44,63,49,39,63,46,34,63,42,29,63,39,24,63
db 36,20,59,34,19,55,31,17,51,29,17,47,27,15,43,25
db 14,39,23,13,35,21,12,31,18,10,27,16,9,23,14,8
db 63,63,63,49,63,63,37,63,63,24,63,63,11,63,63,9
db 58,58,7,54,54,6,50,50,4,45,45,3,41,41,2,36
db 36,1,32,32,1,28,28,0,23,23,0,19,19,0,15,15
db 0,59,0,0,57,0,0,55,0,0,53,0,0,51,0,0
db 49,0,0,47,0,0,45,0,0,43,0,0,41,0,0,39
db 0,0,37,0,0,35,0,0,33,0,0,31,0,0,29,0
db 0,29,0,0,28,0,0,27,0,0,27,0,0,26,0,0
db 25,0,0,25,0,0,24,0,0,24,0,0,23,0,0,22
db 0,0,22,0,0,21,0,0,20,0,0,20,0,0,19,0
db 0,18,0,0,18,0,0,17,0,0,17,0,0,16,0,0
db 15,0,0,15,0,0,14,0,0,13,0,0,13,0,0,12
db 0,0,12,0,0,11,0,0,10,0,0,10,0,0,9,0
db 0,8,0,0,7,0,0,5,0,0,4,0,0,3,0,0
db 2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 27,34,63,25,32,61,23,30,59,22,28,57,21,27,56,19
db 25,54,18,23,52,16,22,51,15,20,49,14,18,47,13,17
db 46,11,15,44,10,14,42,9,13,40,8,11,39,7,10,37
db 6,9,35,6,8,34,5,7,32,4,6,30,3,5,28,3
db 4,27,2,3,25,1,3,23,1,2,22,1,1,20,0,1
db 18,0,0,16,0,0,15,0,0,13,0,0,11,0,0,10
db 63,19,0,51,10,0,40,3,0,29,0,0,63,26,0,44
db 36,33,44,36,33,24,13,7,63,0,0,63,5,0,63,12
db 0,63,19,0,63,25,0,63,32,0,63,39,0,63,46,0
db 60,51,24,57,47,22,55,43,21,53,39,19,50,35,18,48
db 31,16,46,28,15,44,25,14,0,35,25,0,7,5,54,54
db 0,44,36,33,44,36,33,44,36,33,63,37,33,44,36,33
defpal	LABEL BYTE
db 0,0,0,0,0,42,0,42,0,0,42,42,42,0,0,42
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
sintable LABEL WORD ;sintable for 256 degrees
dw  0,804,1608,2410,3212,4011,4808 
dw  5602,6393,7179,7962,8739,9512,10278 
dw  11039,11793,12539,13279,14010,14732,15446 
dw  16151,16846,17530,18204,18868,19519,20159 
dw  20787,21403,22005,22594,23170,23731,24279 
dw  24811,25329,25832,26319,26790,27245,27683 
dw  28105,28510,28898,29268,29621,29956,30273 
dw  30571,30852,31113,31356,31580,31785,31971 
dw  32137,32285,32412,32521,32609,32678,32728 
dw  32757,32767,32757,32728,32678,32609,32521 
dw  32412,32285,32137,31971,31785,31580,31356 
dw  31113,30852,30571,30273,29956,29621,29268 
dw  28898,28510,28105,27683,27245,26790,26319 
dw  25832,25329,24811,24279,23731,23170,22594 
dw  22005,21403,20787,20159,19519,18868,18204 
dw  17530,16846,16151,15446,14732,14010,13279 
dw  12539,11793,11039,10278,9512,8739,7962 
dw  7179,6393,5602,4808,4011,3212,2410 
dw  1608,804,0,-804,-1608,-2410,-3212 
dw -4011,-4808,-5602,-6393,-7179,-7962,-8739 
dw -9512,-10278,-11039,-11793,-12539,-13279,-14010 
dw -14732,-15446,-16151,-16846,-17530,-18204,-18868 
dw -19519,-20159,-20787,-21403,-22005,-22594,-23170 
dw -23731,-24279,-24811,-25329,-25832,-26319,-26790 
dw -27245,-27683,-28105,-28510,-28898,-29268,-29621 
dw -29956,-30273,-30571,-30852,-31113,-31356,-31580 
dw -31785,-31971,-32137,-32285,-32412,-32521,-32609 
dw -32678,-32728,-32757,-32767,-32757,-32728,-32678 
dw -32609,-32521,-32412,-32285,-32137,-31971,-31785 
dw -31580,-31356,-31113,-30852,-30571,-30273,-29956 
dw -29621,-29268,-28898,-28510,-28105,-27683,-27245 
dw -26790,-26319,-25832,-25329,-24811,-24279,-23731 
dw -23170,-22594,-22005,-21403,-20787,-20159,-19519 
dw -18868,-18204,-17530,-16846,-16151,-15446,-14732 
dw -14010,-13279,-12539,-11793,-11039,-10278,-9512 
dw -8739,-7962,-7179,-6393,-5602,-4808,-4011 
dw -3212,-2410,-1608,-804 

;sub-files are included here to make the program a 'simple' one
;object project
include text.asm
include	grap.asm
include misc.asm	
include init.asm
include demo.asm

moduleseg dw	0
fontseg dw	0
bm1seg dw	0
bm2seg dw	0
bm3seg dw	0
filename1 db	'MENTAL.FC',0

main	PROC	NEAR
	;get 128K for the code
	mov	ah,4ah
	mov	bx,1024/16*128
	int	21h
	call	initmisc
	call	asksetup
	mov	dx,OFFSET filename1
	mov	ax,0
	call	loadfile
	add	dx,4
	mov	cs:bm1seg,dx
	add	dx,4000
	mov	cs:bm2seg,dx
	add	dx,4000
	mov	cs:bm3seg,dx
	add	dx,4000
	mov	cs:moduleseg,dx
	add	dx,6828
	mov	cs:fontseg,dx
	;init STMIK for SoundBlaster
	cmp	cs:nosbc,0
	jne	initnosbc
	mov	ax,0 ;INIT
	mov	bl,1 ;SBC
	mov	bh,cs:sbcirq ;IRQ
	mov	cx,cs:sbcio ;IO
	mov	dx,cs:musicq
	call	stmik_asm
initnosbc:
	;get STMIKinsEQU address
	mov	ax,5
	call	stmik_asm
	mov	cs:word ptr stmikequs[0],ax
	mov	cs:word ptr stmikequs[2],dx
	;do screen setting
	mov	si,OFFSET defpal
	call	fadeoffpalette
	call	disablepause
	call	initvideo
	call	copybitmaps
	call	demobackground
	call	setints ;set up raster/timer interrupts
	;set up windows etc by running the demo for one frame
	call	demoframe
	mov	si,OFFSET palette
	;fade on palette/screen
	call	fadeonpalette
	;set polling mode on
	mov	ax,3
	mov	bx,1
	call	stmik_asm
	;start music with STMIK
	mov	ax,1
	mov	bx,cs:moduleseg
	call	stmik_asm
	;poll STMIK
	mov	ax,4
	call	stmik_asm
	
again:	call	demoframe
	mov	ah,1
	int	16h
	jz	again
	mov	ah,0
	int	16h
	cmp	al,'+'
	jne	main1
	inc	cs:drunkenstars
main1:	cmp	al,'-'
	jne	main2
	dec	cs:drunkenstars
main2:	cmp	al,27
	jne	again

	;end music with STMIK
	mov	ax,2
	call	stmik_asm

	call	clearints	
	mov	si,OFFSET palette
	call	fadeoffpalette
	call	uninitvideo
	call	endpage
	call	enablepause
	call	enablekeyboard	
	mov	ax,4c00h
	int	21h
main	ENDP

txt1	db	13,10
	db	"This is the second version of the demo. The first one had problems with SBs",13,10
	db	"whose IRQ was not 7. Also a new option for nonstandard VGA's in which the",13,10
	db	"smooth scrolling works a bit nonstandardly has been included.",13,10
	db	13,10,'This demo requires an AT class computer with VGA installed.',13,10
	db	"This demo uses the Scream Tracker Music Interface Kit V0.2 (STMIK02).",13,10,10
	db	'Is your machine a 12Mhz one or faster (Y/N)? $'
txt6	db	13,10,'Have you had any problems with demos using smooth scrolling? $'
txt2	db	13,10,'Do you want to use SoundBlaster for sound? $'
txt3	db	13,10,'What is your SoundBlasters I/O address (1=210h, 2=220h, 3=230h...)? $'
txt4	db	13,10,'What is your SoundBlasters IRQ setting (2,3,5 or 7)? $'
txt5	db	13,10,10,'Please wait...$'

getyn	PROC NEAR
	mov	ah,1
	int	21h
	cmp	al,'y'
	je	gety1
	cmp	al,'Y'
	je	gety1
	clc
	ret
gety1:	stc
	ret
getyn	ENDP

asksetup PROC NEAR
	mov	ax,cs
	mov	ds,ax
	mov	dx,OFFSET txt1
	mov	ah,9
	int	21h
	call	getyn
	jc	as1
	mov	cs:stars,16
	mov	cs:equson,0
as1:	mov	dx,OFFSET txt6
	mov	ah,9
	int	21h
	call	getyn
	jnc	as11
	mov	cs:alternatescroll,1
as11:	mov	dx,OFFSET txt2
	mov	ah,9
	int	21h
	call	getyn
	jc	as2
	mov	cs:nosbc,1
	mov	cs:stars,32
	jmp	as44
as2:	mov	dx,OFFSET txt3
	mov	ah,9
	int	21h
	mov	ah,1
	int	21h
	cmp	al,13
	je	as3
	cmp	al,'6'
	ja	as2
	cmp	al,'1'
	jb	as2
	sub	al,'0'
	xor	ah,ah
	shl	al,1
	shl	al,1
	shl	al,1
	shl	al,1
	add	ax,200h
	mov	cs:sbcio,ax
as3:	mov	dx,OFFSET txt4
	mov	ah,9
	int	21h
	mov	ah,1
	int	21h
	cmp	al,'1'
	jne	as41
	mov	cs:sbcirq,1
as41:	cmp	al,'3'
	jne	as42
	mov	cs:sbcirq,3
as42:	cmp	al,'5'
	jne	as43
	mov	cs:sbcirq,5
as43:	cmp	al,'7'
	jne	as44
	mov	cs:sbcirq,7
as44:	mov	dx,OFFSET txt5
	mov	ah,9
	int	21h
	ret
asksetup ENDP
	
endpage PROC NEAR
	;make endpage
	mov	ax,cs
	mov	ds,ax
	mov	dx,OFFSET endtext
	mov	ah,9
	int	21h
	mov	ax,0b800h
	mov	es,ax
	mov	cx,2000-160*2
	mov	di,1
	mov	al,3
endp1:	stosb
	inc	di
	loop	endp1
	mov	ah,2
	mov	bx,0
	mov	dx,256*51
	int	10h ;hide cursor
	mov	si,OFFSET defpal
	call	fadeonpalette
	mov	ah,2
	mov	bx,0
	mov	dx,256*23
	int	10h ;set cursor
	ret
endpage ENDP

code	ENDS
	END
	