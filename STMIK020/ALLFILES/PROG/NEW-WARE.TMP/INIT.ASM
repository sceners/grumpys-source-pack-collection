; (un)initialization routines + interrupt routines

initmisc PROC NEAR
	cld
	ret
initmisc ENDP

tweaktbl LABEL BYTE	
	db	 5fh, 4fh, 50h, 82h
	db	 54h, 80h,0bfh, 0fh
	db	 00h, 080h, 00h, 00h
	db	 0, 0, 00h, 00h
	db	 9ch, 8eh, 8fh, 0a0h
	db	 00h, 96h,0b9h,0E3h
	db	 128-1

initvideo PROC NEAR 
	;set tweaked mode 1280x200x256 with 320x200 window with 320x64 subwindow
	;clear palette
	cli
	call	waitborder
	xor	al,al
	mov	dx,3c8h
	out	dx,al
	inc	dx
	mov	cx,768
	xor	al,al
invid1:	out	dx,al
	loop	invid1
	call	waitborder
	;set 320x200x256 normal
	sti
	mov	ax,13h
	int	10h
	cli
	;clear palette again, to remove as much flicker as possible
	xor	al,al
	mov	dx,3c8h
	out	dx,al
	inc	dx
	mov	cx,768
	xor	al,al
invid2:	out	dx,al
	loop	invid2
	call	waitborder
	;set tweaked mode registers	
	mov	dx,3c4h
	mov	ax,604h
	out	dx,ax
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,10h
	out	dx,al
	mov	al,1+32+64
	out	dx,al
	mov	al,11h
	out	dx,al
	mov	al,0
	out	dx,al
	mov	al,32
	out	dx,al
	mov	dx,3d4h
	mov	si,OFFSET tweaktbl
	mov	ah,cs:[si+11h]
	and	ah,7fh
	mov	al,11h
	out	dx,ax
	mov	cx,19h
	mov	al,0
invid3:	mov	ah,cs:[si]
	out	dx,ax
	inc	al
	inc	si
	loop	invid3
	;clear vram
	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
	mov	es,cs:vram
	mov	di,0
	mov	cx,32768
	xor	ax,ax
	rep	stosw
	;set row table	
	mov	cx,200
	mov	bx,OFFSET rows
	xor	ax,ax
invid4:	mov	cs:[bx],ax
	add	ax,1280/4
	inc	bx
	inc	bx
	loop	invid4
	;done!
	sti
	ret
initvideo ENDP

uninitvideo PROC NEAR
	;clear palette
	cli
	call	waitborder
	xor	al,al
	mov	dx,3c8h
	out	dx,al
	inc	dx
	mov	cx,768
	xor	al,al
uivid1:	out	dx,al
	loop	uivid1
	mov	ax,3
	int	10h
	xor	al,al
	mov	dx,3c8h
	out	dx,al
	inc	dx
	mov	cx,768
	xor	al,al
uivid2:	out	dx,al
	loop	uivid2
	ret
uninitvideo ENDP

oldint8	dd	?
INTER	equ	8
intti8 PROC FAR
	;timer interrupt
	push	ax
	sti
	call	demointti
	cli
	mov	al,20h
	out	20h,al
	call	waitborder
	mov	al,36h
	out	43h,al
	mov	al,byte ptr cs:frametimeb[0]
	out	40h,al
	mov	al,byte ptr cs:frametimeb[1]
	out	40h,al
	pop	ax
	iret
intti8 ENDP

	db	'FIND'
setints PROC NEAR
	cli
	xor	ax,ax
	mov	es,ax
	mov	ax,es:[INTER*4]
	mov	WORD PTR cs:oldint8,ax
	mov	ax,es:[INTER*4+2]
	mov	WORD PTR cs:oldint8[2],ax
	mov	ax,OFFSET intti8
	mov	es:[INTER*4],ax
	mov	es:[INTER*4+2],cs
	sti
	call	waitborder
	;reset ints now!
	mov	al,36h
	out	43h,al
	mov	al,0
	out	40h,al
	mov	al,0
	out	40h,al
	call	waitborder
	xor	al,al
	out	43h,al
	in	al,40h
	mov	ah,al
	in	al,40h
	xchg	al,ah
	neg	ax
	shr	ax,1
	mov	cs:frametime,ax
	mov	dx,ax
	mov	al,ah
	xor	ah,ah
	sub	dx,ax
	shl	dx,1
	mov	cs:frametimeb,dx
	mov	al,36h
	out	43h,al
	mov	al,dl
	out	40h,al
	mov	al,dh
	out	40h,al
	ret
setints ENDP

clearints PROC NEAR
	cli
	mov	ax,0
	mov	es,ax
	mov	ax,WORD PTR cs:oldint8
	mov	dx,WORD PTR cs:oldint8[2]
	mov	es:[INTER*4],ax
	mov	es:[INTER*4+2],dx
	sti
	mov	al,36h
	out	43h,al
	mov	al,0
	out	40h,al
	mov	al,0
	out	40h,al
	ret
clearints ENDP

cbmmacro MACRO planeout
	local	l1,l2,l3
	push	di
	push	si
	mov	dx,3c4h
	mov	ax,0002h+256*planeout
	out	dx,ax
	mov	cx,320/4
l1:	lodsb
	cmp	al,254
	jb	l2
	inc	di
	jmp	l3
l2:	stosb
l3:	add	si,3
	loop	l1
	pop	si
	pop	di
	inc	si
	ENDM
	
copybitmaps PROC NEAR
	mov	ds,cs:bm1seg
	mov	di,320/4
	mov	cx,136
	call	copybitmaptovram
	mov	ds,cs:bm2seg
	mov	di,640/4
	mov	cx,136
	call	copybitmaptovram
	mov	ds,cs:bm3seg
	mov	di,960/4
	mov	cx,200
	call	copybitmaptovram	
	ret
copybitmaps ENDP

copybitmaptovram PROC NEAR
	mov	es,cs:vram
	xor	si,si
cbm1:	push	cx
	push	si
	push	di
	;plane 1
	cbmmacro 1
	;plane 2
	cbmmacro 2
	;plane 3
	cbmmacro 4
	;plane 4
	cbmmacro 8
	pop	di
	pop	si
	pop	cx
	add	si,320
	add	di,1280/4
	loop	cbm1x
	ret
cbm1x:	jmp	cbm1
copybitmaptovram ENDP

disablekeyboard PROC NEAR
	in	al,21h
	or	al,2
	out	21h,al
	ret
disablekeyboard ENDP

enablekeyboard PROC NEAR
	in	al,21h
	and	al,255-2
	out	21h,al
	ret
enablekeyboard ENDP

oldint9 dd	?

intti9 PROC FAR
	push	ax
        in      al,60h
        cmp     al,1h
        je	nokey
        cmp     al,4ah
        je	nokey
        cmp     al,4eh
        je	nokey
        in      al,61h
        mov     ah,al
        or      al,80h
        out     61h,al
        xchg    ah,al
        out     61h,al
        mov     al,20h
        out     20h,al
        pop     ax
        iret
nokey:	pop     ax
        jmp     cs:oldint9
intti9 ENDP

disablepause PROC NEAR
	cli ;actually only ESC, keypad+ and keypad- will work after this crap
	xor	ax,ax
	mov	es,ax
	mov	ax,es:[9*4]
	mov	WORD PTR cs:oldint9,ax
	mov	ax,es:[9*4+2]
	mov	WORD PTR cs:oldint9[2],ax
	mov	ax,OFFSET intti9
	mov	es:[9*4],ax
	mov	es:[9*4+2],cs
	sti
	ret
disablepause ENDP

enablepause PROC NEAR
	cli
	xor	ax,ax
	mov	es,ax
	mov	ax,WORD PTR cs:oldint9
	mov	bx,WORD PTR cs:oldint9[2]
	mov	es:[9*4],ax
	mov	es:[9*4+2],bx
	sti
	ret
enablepause ENDP

