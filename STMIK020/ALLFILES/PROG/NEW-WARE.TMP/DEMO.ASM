;demo routines

demoframe PROC NEAR
	setborder 0
	mov	dx,3dah
dwait:	in	al,dx
	test	al,8
	jz	dwait
	call	scrollborder
	call	canner ;color animation
	sti
	setborder 52
	mov	ax,4
	call	stmik_asm ;poll music player
	setborder 1
	call	scroll
	call	enablekeyboard
	setborder 9
	call	logofader
	setborder 1
	call	writer
	cmp	cs:equson,0
	je	noequs
	setborder 1
	call	equs
noequs:	setborder 15
	call	starfield
	setborder 1
	call	disablekeyboard ;just to avoid overactive users to 'crash' the demo
	setborder 0
	ret
demoframe ENDP

demobackground PROC NEAR
	ret
	;set 4 bitplane latch trasfer mode
	mov	dx,3ceh
	mov	ax,4105h
	out	dx,ax
	mov	dx,3
	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
	;do nothing :-)
	;clear latch trasfer mode
	mov	dx,3ceh
	mov	ax,4005h
	out	dx,ax
	ret
demobackground ENDP

demointti PROC NEAR
	;called every other frame by rasterinterrupt, must save all but AX
	push	es
	pop	es
	ret
demointti ENDP

fixword
stx	dw	32 dup(-1,-1)	;x
sty	dw	32 dup(-1,-1)	;y
stm	db	32 dup(0,0,0,0) 	;misc: color,maxcol/speed,processed,0
stox1	dw	?
stoy1	dw	?
stox2	dw	?
stoy2	dw	?
srot	dw	64

bordercnt dw	?

starfield PROC NEAR
	mov	ax,cs
	mov	ds,ax
	mov	es,ds:vram
	;calc 'rotating' center
	mov	cx,cs:drunkenstars
	mov	ax,ds:srot
	sine
	imul	cx
	mov	ax,dx
	add	ax,160
	mov	ds:stox1,ax
	sub	ax,(320-256)/2
	mov	ds:stox2,ax
	mov	ax,ds:srot
	cosine
	imul	cx
	mov	ax,dx
	add	ax,100
	mov	ds:stoy1,ax
	sub	ax,(200-128)/2
	mov	ds:stoy2,ax
	inc	ds:srot
	and	ds:srot,255
	;do stars
	mov	cx,stars
	xor	si,si
sf01:	mov	cs:stm[si+2],0
	add	si,4
	loop	sf01
	mov	cs:bordercnt,0
	mov	cx,stars
	mov	bp,0
	xor	si,si
	call	starfield2
sf02:	setborder 0
	call	getrasterline
	cmp	ax,160
	jb	sf02
	mov	cx,stars
	mov	bp,1
	xor	si,si
	setborder 15
	call	starfield2
	ret
starfield ENDP

starfield2 PROC NEAR
sf1:	push	cx
	cmp	ds:stm[si+2],0
	je	sf14
	jmp	sf3
sf14:
	mov	dx,ds:stx[si+2]
	cmp	dx,-1
	jne	sf5
	;add new
	call	rand
	and	ax,127
	mov	dx,ax
	call	rand
	and	ax,127
	add	dx,ax
	add	dx,(320-256)/2
	mov	ds:stx[si+2],dx
	call	rand
	and	ax,63
	mov	dx,ax
	call	rand
	and	ax,63
	add	dx,ax
	add	dx,(200-128)/2
	mov	ds:sty[si+2],dx
	call	rand
	and	al,15
	add	al,128+64
	mov	ds:stm[si+1],al
	mov	al,128+64+31
	mov	ds:stm[si],al
	mov	dx,ds:stx[si+2]
	mov	bx,ds:sty[si+2]
	jmp	sf2
sf5:	;undraw old
	mov	bx,ds:sty[si+2]
sf2:	cmp	bp,1
	je	sf12
	cmp	bx,70
	jnb	sf11
sf13:	jmp	sf3
sf12:	cmp	bx,70
	jnb	sf13
sf11:	mov	ds:stm[si+2],1	
	call	ospget
	cmp	al,128+64
	jb	sf4
	cmp	al,128+64+31
	ja	sf4
	mov	dx,ds:stx[si+2]
	mov	bx,ds:sty[si+2]
	xor	al,al
	call	ospset
sf4:	;move
	mov	ah,128+63
	sub	ah,ds:stm[si+1]
	add	ah,32
	xor	al,al
	mov	cl,2
	shr	ax,cl
	mov	cx,ax
	mov	ax,ds:stx[si+2]
	sub	ax,ds:stox1
	imul	cx
	add	ds:stx[si],ax
	adc	ds:stx[si+2],dx
	mov	ax,ds:sty[si+2]
	sub	ax,ds:stoy1
	imul	cx
	add	ds:sty[si],ax
	adc	ds:sty[si+2],dx
	;redraw new/check for overflow
	mov	dx,ds:stx[si+2]
	cmp	dx,320
	jb	sf9
sf10:	mov	ds:stx[si+2],-1
	jmp	sf3
sf9:	mov	bx,ds:sty[si+2]
	cmp	bx,199
	ja	sf10
	call	spget
	cmp	al,0
	jne	sf3
	mov	dx,ds:stx[si+2]
	mov	bx,ds:sty[si+2]
	mov	al,ds:stm[si]
	cmp	al,ds:stm[si+1]
	jna	sf7
	dec	al
sf7:	mov	ds:stm[si],al
	call	spset
sf3:	pop	cx
	add	si,4
	loop	sf1x
	ret
sf1x:	jmp	sf1
starfield2 ENDP

tmpcol	db	0
tmprow	dw	1

scrollmacro1 MACRO
	mov	al,es:[si]
	mov	es:[di],al
	mov	es:[di-(1280-640)/4],al
	;mov	al,es:[si+1]
	;mov	es:[di+1],al
	;mov	es:[di-(1280-640)/4+1],al
	ENDM
scrollmacro2 MACRO
	mov	al,es:[si]
	mov	es:[di],al
	;mov	al,es:[si+1]
	;mov	es:[di+1],al
	ENDM
;create one 'sprite'-line of the font
scrollmacro MACRO submac
	local	l1,l2,l3,l4,l5,l6,l7
	mov	bx,cs:charbodypos
	mov	ax,cs:charpos
	mov	dx,cs:charwidth
	cmp	ax,dx
	jb	l3
	mov	bx,cs:chartpos
	mov	al,cs:chartext[bx]
	cmp	al,1
	jne	l6
	mov	cs:wrmark,1
	mov	cs:oktofade,1
	inc	bx
	jmp	l7
l6:	or	al,al
	jnz	l4
	xor	bx,bx
l7:	mov	al,cs:chartext[bx]
l4:	inc	bx
	mov	cs:chartpos,bx
	mov	bl,al
	xor	bh,bh
	shl	bx,1
	shl	bx,1
	mov	ax,cs:fontpos[bx+2]
	shr	ax,1
	shr	ax,1
	mov	cs:charwidth,ax
	mov	ax,cs:fontpos[bx]
	mov	cs:charbodypos,ax
	mov	bx,ax
	mov	dl,cs:[bx]
	xor	ax,ax
l3:	cmp	bx,spacepos
	je	l5
	add	bx,ax
l5:	inc	ax
	mov	cs:charpos,ax
	mov	si,bx
	mov	dx,1280/4
	mov	cx,64
l1:	submac
	add	si,dx
	add	di,dx
	loop	l1
	ENDM
	
wrmark	db	0
oktofade db	0
	
chartpos dw	0
;	db	"FONTTEST!   "
;	db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:;., "
	
spacepos equ	80
fontpos LABEL WORD
	dw	32 dup(0,0)
	dw	spacepos,32 ;space
	dw	(80*1+320*72)+16*1,28 ; !
	dw	0,0
	dw	(80*3+320*64)+16*4-2,8 ; #
	dw	8 dup(0,0)
	dw	(80*1+320*72)+8*7,16 ; ,
	dw	0,0
	dw	(80*1+320*72)+8*8,16 ; .
	dw	0,0
	dw	10 dup(0,0)
	dw	(80*1+320*72)+8*6,16 ; :
	dw	(80*1+320*72)+8*9,16 ; ;
	dw	0,0
	dw	(80*3+320*64)+16*5-8,8 ; =
	dw	0,0
	dw	(80*1+320*72)+16*0+3,48 ; ?
	dw	0,0 ;@
	;A..Z
	dw	(80*3+320*0)+16*0,48
	dw	(80*3+320*0)+16*1,48
	dw	(80*3+320*0)+16*2,48
	dw	(80*3+320*0)+16*3,48
	dw	(80*3+320*0)+16*4,48
	dw	(80*3+320*64)+16*0,48
	dw	(80*3+320*64)+16*1,48
	dw	(80*3+320*64)+16*2,48
	dw	(80*3+320*64)+16*3,16
	dw	(80*3+320*64)+16*4,20
	dw	(80*3+320*128)+16*0,44
	dw	(80*3+320*128)+16*1,16
	dw	(80*3+320*128)+16*2,64
	dw	(80*3+320*128)+16*3,44
	dw	(80*3+320*128)+16*4,48
	dw	(80*2+320*0)+16*0,48
	dw	(80*2+320*0)+16*1,48
	dw	(80*2+320*0)+16*2,48
	dw	(80*2+320*0)+16*3,48
	dw	(80*2+320*0)+16*4,48
	dw	(80*2+320*64)+16*0,48
	dw	(80*2+320*64)+16*1,48
	dw	(80*2+320*64)+16*2,48
	dw	(80*2+320*64)+16*3,60
	dw	(80*2+320*64)+16*4,48
	dw	(80*1+320*72)+16*2,48
charbodypos dw	spacepos
charpos	dw	0
charwidth dw	0
	
scrollborder PROC NEAR
	;called in border for smooth scrolling
	;set smooth pixel pan
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,13h
	out	dx,al
	mov	al,byte ptr cs:winxpos
	and	al,3
	shl	al,1
	out	dx,al
	mov	al,32
	out	dx,al
	ret
scrollborder ENDP

srcount dw	0

scroll	PROC NEAR
	mov	es,cs:vram
	;set subwindow position
	mov	ax,cs:winxpos
	mov	cs:owinxpos,ax
	;change winxpos
	add	ax,3
	cmp	cs:alternatescroll,0
	je	scr1b
	inc	cs:srcount
	inc	ax
scr1b:	add	cs:srcount,3
	cmp	ax,1280-640
	jb	scr1
	sub	ax,1280-640
scr1:	mov	cs:winxpos,ax
	cmp	cs:srcount,4
	jb	src11
	sub	cs:srcount,4
	jmp	scr6
src11:	jmp	scr3
scr6:	;draw new stuff
	jmp	scr2
scr4x:	jmp	scr4
scr2:
	;set 4 bitplane latch trasfer mode
	mov	dx,3ceh
	mov	ax,4105h
	out	dx,ax
	mov	dx,3
	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
	mov	si,320/4
	mov	di,1280/4*136+320/4
	mov	ax,cs:winxpos
	shr	ax,1
	shr	ax,1
	add	di,ax
	cmp	cs:winxpos,(1280-640-320)
	jb	scr4x
	scrollmacro scrollmacro1
	jmp	scr5
scr4:	scrollmacro scrollmacro2
scr5:	;clear latch trasfer mode
	mov	dx,3ceh
	mov	ax,4005h
	out	dx,ax
scr3:	;position screen
	mov	bx,1280/4*136
	mov	ax,cs:winxpos
	shr	ax,1
	shr	ax,1
	add	bx,ax
	mov	dx,03d4h
	mov	al,0ch
	mov	ah,bh
	out	dx,ax
	mov	al,0dh
	mov	ah,bl
	out	dx,ax
	ret	
scroll	ENDP

cancnt	dw	0

canner PROC NEAR
	;update palette
	cli
	mov	ax,cs
	mov	ds,ax
	mov	si,OFFSET palette+128*3
	mov	al,128
	mov	dx,3c8h
	out	dx,al
	inc	dx
	mov	cx,64*3/6
can1:	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	loop	can1
	sti
	;scroll colors
	inc	cs:cancnt
	test	cs:cancnt,7
	jnz	can2
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	di,OFFSET palette+128*3
	mov	si,OFFSET palette+129*3
	mov	bx,ds:[di]
	mov	dl,ds:[di+2]
	mov	cx,63*3/2
	rep	movsw
	movsb
	mov	ds:[di],bx
	mov	ds:[di+2],dl
	;update writer fontcolor
	dec	cs:printcadd
	and	cs:printcadd,63
can2:	ret
canner ENDP

fixword
wrwait	dw	0
wrpos	dw	0
wrx	dw	16
wry	dw	39
wrcnt	dw	0
wrnum	dw	20
wrcx	dw	64*4 dup(0)
wrcy	dw	64*4 dup(0)
wrcc	db	64*4 dup(0,0)
wrcpnt	dw	0
wrcpnt2	dw	12*4*2

writer PROC NEAR
	inc	cs:wrcnt
	test	cs:wrcnt,1
	jz	wr1x
	jmp	wr1
wr3x:	jmp	wr3
wr1x:	cmp	cs:wrwait,30000
	jne	wr3y
	cmp	cs:wrmark,1
	jne	wr5z
	mov	cs:wrmark,0
	mov	cs:wrwait,0
	jmp	wr3x
wr5z:	mov	cs:wrwait,30001
	jmp	wr3x
wr3y:	cmp	cs:wrwait,0
	jne	wr3x
	mov	bx,cs:wrpos
	mov	al,cs:wrtext[bx]
	inc	bx
	cmp	al,0
	jne	wr5
	mov	cs:wrpos,OFFSET wrtextinit-OFFSET wrtext
	jmp	wr3
wr5:	mov	cs:wrpos,bx
	cmp	al,13
	jne	wr2
	add	cs:wry,18
	mov	cs:wrx,16
wr2:	cmp	al,10
	jne	wr22
	sub	cs:wry,18
wr22:	cmp	al,3
	jne	wr9
	mov	cs:wrwait,30001
	jmp	wr3
wr9:	cmp	al,1
	jne	wr4
	mov	cs:wrx,16
	mov	cs:wry,39
	mov	cs:wrwait,256
	jmp	wr3
wr4:	cmp	al,2
	jne	wr6
	xor	dx,dx
wr62:	mov	al,ds:wrtext[bx]
	cmp	al,13
	je	wr61
	call	getfontwidth
	add	dx,ax
	inc	bx	
	jmp	wr62
wr61:	mov	ax,314
	sub	ax,dx
	shr	ax,1
	mov	cs:wrx,ax
	jmp	wr3
wr6:	mov	bx,cs:wry
	mov	dx,cs:wrx
	mov	si,cs:wrcpnt
	mov	cs:wrcx[si],dx
	mov	cs:wrcy[si],bx
	mov	cs:wrcc[si],al
	cmp	al,'a'
	jb	wr92
	call	printc2
	jmp	wr91
wr92:	call	printc
wr91:	mov	cs:wrx,dx
	cmp	cs:wrx,320-16
	jb	wr3
	mov	cs:wrx,16
wr3:	;clear old chars
	mov	si,cs:wrcpnt
	add	si,2
	and	si,511
	mov	cs:wrcpnt,si
	mov	si,cs:wrcpnt2
	mov	dx,cs:wrcx[si]
	mov	bx,cs:wrcy[si]
	mov	al,cs:wrcc[si]
	mov	cs:wrcx[si],0
	add	si,2
	and	si,511
	mov	cs:wrcpnt2,si
	cmp	dx,0
	je	wr32
	call	printclr
wr32:	cmp	cs:wrwait,0
	je	wr1
	dec	cs:wrwait
wr1:	ret
writer ENDP

fadespd	equ	538*2
fadecount dw	fadespd+1
fadeyadd dw	80*1+320*(32+8)
fadeyad1 dw	80*1+320*(32+8)
fadeyad2 dw	80*1+320*8

logofader PROC NEAR
	cmp	cs:oktofade,0
	jne	lof5
	ret
lof5:	inc	cs:fadecount
	cmp	cs:fadecount,fadespd
	ja	lof1
	ret
lof1:	cmp	cs:fadecount,fadespd+80
	jb	lof2
	mov	cs:fadecount,0
	mov	ax,cs:fadeyad1
	xchg	cs:fadeyad2,ax
	mov	cs:fadeyad1,ax
	mov	cs:fadeyadd,ax
	ret
lof2:	;fade 
	;set 4 bitplane latch trasfer mode
	mov	dx,3ceh
	mov	ax,4105h
	out	dx,ax
	mov	dx,3
	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
	;fade in/out
	mov	es,cs:vram
	mov	di,cs:fadecount
	sub	di,fadespd
	mov	bp,di
	mov	si,cs:fadeyadd
	add	si,bp
	mov	cx,16
	mov	dx,640
lof3:	mov	al,es:[si]
	mov	es:[di],al
	add	si,dx
	add	di,dx
	loop	lof3
	mov	di,fadespd+79+320
	sub	di,cs:fadecount
	mov	si,cs:fadeyadd
	add	si,320+79
	sub	si,bp
	mov	cx,16
	mov	dx,640
lof4:	mov	al,es:[si]
	mov	es:[di],al
	add	si,dx
	add	di,dx
	loop	lof4
	;clear latch trasfer mode
	mov	dx,3ceh
	mov	ax,4005h
	out	dx,ax
	ret
logofader ENDP

equpnt	dw	0
equdel	db	16 dup(64 dup(0))
equlast db	64 dup(0)

equs 	PROC NEAR
	cmp	cs:nosbc,0
	je	noeq
	ret
noeq:	mov	dx,3
	mov	dx,3c4h
	mov	ax,0702h
	out	dx,ax
	;draw the equs; REMARK; the info from the player is aprx. 16 frames early!
	mov	es,cs:vram
	mov	si,word ptr cs:stmikequs[0]
	mov	ds,word ptr cs:stmikequs[2]
	mov	cx,60 ;do 16 ins bars
	mov	bx,cs:equpnt
equ12:	mov	al,ds:[si]
	mov	cs:equdel[bx],al
	sub	al,2
	jnc	equ11
	xor	al,al
equ11:	mov	ds:[si],al
	inc	bx
	inc	si
	loop	equ12
	add	bx,4
	and	bx,1023
	mov	cs:equpnt,bx
	mov	cx,40
	mov	di,20+(133)*(1280/4)
	mov	si,bx
	add	si,20
	mov	bp,20
equ1:	push	cx
	push	di
	push	si
	xor	bh,bh
	mov	bh,cs:equlast[bp]
	mov	bl,cs:equdel[si]
	cmp	bl,0
	jne	equ4
	cmp	bh,0
	jne	equ4
	jmp	equ3
equ4:	mov	cs:equlast[bp],bl
	mov	cl,2
	shr	bl,cl
	shr	bh,cl
	mov	cl,bl
	xor	ch,ch
	jcxz	equ22
	mov	al,32
equ2:	mov	es:[di],al
	sub	di,1280/4
	inc	al
	loop	equ2
equ22:	mov	cl,bh
	sub	cl,bl
	jc	equ3
	jz	equ3
	mov	al,0
equ5:	mov	es:[di],al
	sub	di,1280/4
	loop	equ5
equ3:	pop	si
	pop	di
	pop	cx
	inc	si
	inc	bp
	inc	di
	loop	equ1
	ret
equs	ENDP

