;;
;; [ Lord Logics Lanscape File ]
;;
.data
	public  C       ll_table
	ll_table        dw      offset table
			dw      @data
	table           dw      46*46*2 dup (0)

;;
;; SIN Data : Values range from 32767 to -32768 with 360 intervals.
;;
       SIN_L   dw      0,   571,  1143,  1714,  2285,  3425
	       dw   3425,  3993,  4560,  5125,  5689,  6812
	       dw   6812,  7370,  7927,  8480,  9031, 10125
	       dw  10125, 10667, 11206, 11742, 12274, 13327
	       dw  13327, 13847, 14364, 14875, 15383, 16383
	       dw  16383, 16876, 17363, 17846, 18323, 19259
	       dw  19259, 19719, 20173, 20620, 21062, 21925
	       dw  21925, 22347, 22761, 23169, 23570, 24350
	       dw  24350, 24729, 25100, 25464, 25820, 26509
	       dw  26509, 26841, 27165, 27480, 27787, 28377
	       dw  28377, 28658, 28931, 29195, 29450, 29934
	       dw  29934, 30162, 30381, 30590, 30790, 31163
	       dw  31163, 31335, 31497, 31650, 31793, 32050
	       dw  32050, 32164, 32269, 32363, 32448, 32587
	       dw  32587, 32642, 32687, 32722, 32747, 32767
	       dw  32767, 32762, 32747, 32722, 32687, 32587
	       dw  32587, 32522, 32448, 32363, 32269, 32050
	       dw  32050, 31927, 31793, 31650, 31497, 31163
	       dw  31163, 30981, 30790, 30590, 30381, 29934
	       dw  29934, 29696, 29450, 29195, 28931, 28377
	       dw  28377, 28086, 27787, 27480, 27165, 26509
	       dw  26509, 26168, 25820, 25464, 25100, 24350
	       dw  24350, 23964, 23570, 23169, 22761, 21925
	       dw  21925, 21497, 21062, 20620, 20173, 19259
	       dw  19259, 18794, 18323, 17846, 17363, 16383
	       dw  16383, 15885, 15383, 14875, 14364, 13327
	       dw  13327, 12803, 12274, 11742, 11206, 10125
	       dw  10125,  9580,  9031,  8480,  7927,  6812
	       dw   6812,  6252,  5689,  5125,  4560,  3425
	       dw   3425,  2855,  2285,  1714,  1143,     0
	       dw      0,  -571, -1143, -1714, -2285, -3425
	       dw  -3425, -3993, -4560, -5125, -5689, -6812
	       dw  -6812, -7370, -7927, -8480, -9031,-10125
	       dw -10125,-10667,-11206,-11742,-12274,-13327
	       dw -13327,-13847,-14364,-14875,-15383,-16383
	       dw -16383,-16876,-17363,-17846,-18323,-19259
	       dw -19259,-19719,-20173,-20620,-21062,-21925
	       dw -21925,-22347,-22761,-23169,-23570,-24350
	       dw -24350,-24729,-25100,-25464,-25820,-26509
	       dw -26509,-26841,-27165,-27480,-27787,-28377
	       dw -28377,-28658,-28931,-29195,-29450,-29934
	       dw -29934,-30162,-30381,-30590,-30790,-31163
	       dw -31163,-31335,-31497,-31650,-31793,-32050
	       dw -32050,-32164,-32269,-32363,-32448,-32587
	       dw -32587,-32642,-32687,-32722,-32747,-32767
	       dw -32767,-32762,-32747,-32722,-32687,-32587
	       dw -32587,-32522,-32448,-32363,-32269,-32050
	       dw -32050,-31927,-31793,-31650,-31497,-31163
	       dw -31163,-30981,-30790,-30590,-30381,-29934
	       dw -29934,-29696,-29450,-29195,-28931,-28377
	       dw -28377,-28086,-27787,-27480,-27165,-26509
	       dw -26509,-26168,-25820,-25464,-25100,-24350
	       dw -24350,-23964,-23570,-23169,-22761,-21925
	       dw -21925,-21497,-21062,-20620,-20173,-19259
	       dw -19259,-18794,-18323,-17846,-17363,-16383
	       dw -16383,-15885,-15383,-14875,-14364,-13327
	       dw -13327,-12803,-12274,-11742,-11206,-10125
	       dw -10125, -9580, -9031, -8480, -7927, -6812
	       dw  -6812, -6252, -5689, -5125, -4560, -3425
	       dw  -3425, -2855, -2285, -1714, -1143,     0

	       ;; COS continuation . . .
	       dw      0,   571,  1143,  1714,  2285,  3425
	       dw   3425,  3993,  4560,  5125,  5689,  6812
	       dw   6812,  7370,  7927,  8480,  9031, 10125
	       dw  10125, 10667, 11206, 11742, 12274, 13327
	       dw  13327, 13847, 14364, 14875, 15383, 16383
	       dw  16383, 16876, 17363, 17846, 18323, 19259
	       dw  19259, 19719, 20173, 20620, 21062, 21925
	       dw  21925, 22347, 22761, 23169, 23570, 24350
	       dw  24350, 24729, 25100, 25464, 25820, 26509
	       dw  26509, 26841, 27165, 27480, 27787, 28377
	       dw  28377, 28658, 28931, 29195, 29450, 29934
	       dw  29934, 30162, 30381, 30590, 30790, 31163
	       dw  31163, 31335, 31497, 31650, 31793, 32050
	       dw  32050, 32164, 32269, 32363, 32448, 32587
	       dw  32587, 32642, 32687, 32722, 32747, 32767

.code
land_clr        proc
; Routine
	push    es
	push    ds
	push    di

	mov     ax,@data
	mov     ds,ax

	mov     ax,0A000h
	mov     di,LL_DRAW
	mov     si,LL_BACK
	mov     es,ax
	mov     ds,ax

	;;
	;; Set WRITE MODE #1
	;;
	mov     dx,03ceh
	mov     al,05h
	out     dx,al
	inc     dx
	in      al,dx
	or      al,00000001b
	and     al,11111101b
	out     dx,al

	;;
	;; Enable ALL FOUR Planes
	;;
	mov     dx,03C4h                ;; Enable ALL Planes
	mov     al,02h                  ;; :
	mov     ah,00001111b            ;; :
	out     dx,ax                   ;; :

	mov     cx,64000/4              ;; Refresh Background
	rep     movsb                   ;; :

	;;
	;; Set WRITE MODE #0
	;;
	mov     dx,03ceh
	mov     al,05h
	out     dx,al
	inc     dx
	in      al,dx
	and     al,11111100b
	out     dx,al

	pop     di
	pop     ds
	pop     es
	ret
land_clr        endp

land_put        proc
; Arguments
	X1      equ     word ptr [bp+MM]
	Y1      equ     word ptr [bp+MM+2]
	Water   equ     word ptr [bp+MM+4]
	Alpha   equ     word ptr [bp+MM+6]

; Variables
	X       equ     word ptr [bp-6]
	Y       equ     word ptr [bp-8]
	Y2      equ     word ptr [bp-10]
	Dummy   equ     word ptr [bp-12]
	DatSeg  equ     word ptr [bp-14]
	Z_Count equ     word ptr [bp-16]

; Constants
	LandW   equ     46                      ;; Land Width
	LandD   equ     46                      ;; Land Height
	d       equ     250
	CamX    equ     0
	CamY    equ     200
	CamZ    equ     750
	MapW    equ     256-LandW

; Routine
	push    bp
	mov     bp,sp
	sub     sp,20
	push    ds
	push    es

	mov     si,seg LL_DATA
	mov     ds,si
	mov     si,offset LL_DATA

	mov     dx,0A000h
	mov     es,dx
	mov     ax,Y1
	mov     bx,MapW+LandW
	mul     bx
	add     ax,X1
	add     si,ax

	mov     di,offset table

	mov     dx,LandD
	mov     Z_Count,dx

lp_1:   mov     cx,LandW
lp_2:   mov     Dummy,cx
	xor     ah,ah
	mov     al,[si]
	cmp     ax,Water
	jge     @F
	mov     ax,Water
@@:     sub     ax,Water
	inc     ax
	mov     Y,ax

	mov     DatSeg,ds

	mov     cx,@data
	mov     ds,cx

	mov     cx,[di]                 ;; Radius
	mov     bx,[di+2]               ;; Theta
	add     bx,Alpha                ;; Theta+=Alpha
@@:     cmp     bx,360
	jl      @F
	sub     bx,360
	jmp     @B
@@:     cmp     bx,0
	jge     @F
	add     bx,360
	jmp     @B
@@:     shl     bx,1
	add     bx,offset SIN_L
	mov     ax,[bx]
	add     bx,180
	mov     bx,[bx]
	imul    cx                      ;; x = r*sin(theta)
	mov     X,dx                    ;; :
	mov     ax,bx                   ;; :
	imul    cx                      ;; z = r*cos(theta)
	mov     bx,dx                   ;; :
	add     di,4                    ;; Increment to next table pos
	mov     ds,DatSeg

	add     bx,CamZ
	add     bx,d

	cmp     bx,20
	jle     lp_skp
	mov     cx,d

	mov     ax,Y
	sub     ax,CamY
	imul    cx
	idiv    bx
	neg     ax
	add     ax,100
	cmp     ax,0
	jl      lp_skp
	cmp     ax,200
	jge     lp_skp
	mov     Y2,ax

	mov     ax,X
	add     ax,CamX
	imul    cx
	idiv    bx
	add     ax,160
	cmp     ax,0
	jl      lp_skp
	cmp     ax,320
	jge     lp_skp
	mov     cx,ax                   ;; X Pos

	;;
	;; Put up the dot
	;;
	mov     ax,Y2                   ;; Get Y Pos
	mov     bx,(LL_HOR/4)
	mul     bx
	mov     bx,ax

	mov     ax,cx                   ;; Get X Pos
	mov     cl,al
	and     cl,00000011b
	mov     dl,00000001b
	shl     dl,cl
	mov     cl,dl
	shr     ax,1
	shr     ax,1
	add     bx,ax

	mov     dx,03C4h                ;; Enable Plane
	mov     al,02h                  ;; :
	mov     ah,cl                   ;; :
	out     dx,ax                   ;; :
	mov     ax,Y                    ;; Get color

	mov     dx,@data
	mov     ds,dx
	add     bx,LL_DRAW
	mov     es:[bx],al
	mov     ds,DatSeg

lp_skp: mov     cx,Dummy

	inc     si
	dec     cx
	jnz     lp_2
	add     si,(MapW)
	dec     Z_Count
	jnz     lp_1

	pop     es
	pop     ds
	mov     sp,bp
	pop     bp
	ret
land_put        endp

