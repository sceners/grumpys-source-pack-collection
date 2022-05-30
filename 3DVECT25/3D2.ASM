; 3d vector routines - full sorting method (slower)
;
; - objects can pass through one another and still be sorted correctly
; - sort_list and draw vect must be called seperatly
; - maxsurfs and maxpoints must be large - set to TOTAL points/surfs on screen
;
; to use
;
;          call look_at_it           ; make camera look at selected object
;          call setsincose           ; set rotation multipliers for eye
;          call makeobjs             ; plot all objects in sides table
;          call set_makeorder        ; reset sort order
;          call sort_list            ; sort all sides/points/bitmaps
;          call drawvect             ; draw vectors/bitmaps/points/lines
;          call instant_mouse        ; plot mouse on screen
;          call flip_page            ; flip video pages
;          call clear_fill           ; clear video memory (last screen)
;          call resetupd             ; reset borders
;          call updvectors           ; move objects around, rotate them

            .386p

code32      segment para public use32
            assume cs:code32, ds:code32

; define externals

            extrn objbase:dword     ; object lists and bitmap lists are
            extrn bitbase:dword     ; external! set to 0 if none
            extrn bitx:dword        ; x and y sizes for 3d conversion
            extrn bity:dword

            include pmode.inc       ; protected mode externals
            include xmouse.inc      ; xmode mouse externals
            include xmode.inc       ; xmode externals by matt pritchard

            include macros.inc
            include equ.inc

;           include vars2.inc       ; vars goes at end so indexing can be near
            include math.inc        ; rotate, cos,sin,arctan...
            include xscale.inc
            include poly.inc        ; common ploygon stuff
            align 4
            include sin.inc         ; sin/cosin table
            include arctan.inc      ; inverse tan

            public move_si
            public newfollow
            public resetupd
            public makeobjs
            public make1obj
            public look_at_it
            public calc_angles
            public get_displacement
            public put_object
            public set_angle
            public set_shape
            public set_object_on
            public set_object_off
            public dv_middle
            public set_makeorder
            public drawvect
            public sort_list

           align 4

abort_all:
           add esp,2+2            ; abort from loadpoints and make1obj
           ret                    ; returning now from makeobjs call

           align 4

loadpoints:
           mov bl,userotate[esi]

           shl si,1
           mov di,whatshape[esi]  ; get shape, bp = z distance
           shl di,2               ; four resolutions
           mov eax,zad
           cmp eax, smalla        ; check if too far to see detail anyway
           jl s viewhi
           inc di                 ; use resolution b
           cmp eax, smallb
           jl s viewhi
           inc di                 ; use resolution c
           cmp eax, smallc
           jl s viewhi
           inc di                 ; use resolution d
viewhi:
           shl di,2
           mov edi,objbase[di]
           mov ax,[edi]
           mov numpoints,ax

           mov si,pointindex      ; set xp,yp,zp pointer

           shl ax,1
           add pointindex,ax      ; pointindex = word indexer to last point

           cmp pointindex,maxpoints*2 ; test for overflow in points tables
           jge s abort_all

           mov ax,[edi+2]
           mov numsides,ax

           add ax,showing
           cmp ax,maxsurfaces-1   ; check for overflow in "sides" tables
           je s abort_all

           add edi,4              ; skip start data
           mov lindex,si          ; set last index to points (this one)

           cmp bl,0               ; check userotate command
           jne s np13             ; use different loop if no rotation
np12:
           movsx ebx,w [edi]      ; x
           movsx ecx,w [edi+2]    ; y
           movsx ebp,w [edi+4]    ; z

           push edi si
           call rotate            ; rotate
           add ebp,zad

           cmp ebp,ztruncate
           jge s ntrunct
           mov ebp,ztruncate
ntrunct:
           add ebx,xad
           add ecx,yad
           call make3d
           pop si edi
           mov [xp+si],bx
           mov [yp+si],cx
           mov [zp+si],bp
           add si,2               ; inc xp indexer
           add edi,6              ; inc input pointer
           dec numpoints
           jne s np12

           ret                    ; edi exits with pointer to sides
np13:
           movsx ebx,w [edi]      ; x
           movsx ecx,w [edi+2]    ; y
           movsx ebp,w [edi+4]    ; z

           push edi si

           call erotate           ; rotation matrix already set up!

           add ebp,zad

           cmp ebp,ztruncate
           jge s ntrunct2
           mov ebp,ztruncate
ntrunct2:
           add ebx,xad
           add ecx,yad
           call make3d
           pop si edi
           mov [xp+si],bx
           mov [yp+si],cx
           mov [zp+si],bp
           add si,2               ; inc xp indexer
           add edi,6
           dec numpoints
           jne s np13

           ret

           align 4

; handle loading of bitmap from object list
;
; eg   dw 32,8,5,50,60 ;command is 32,point 8, bitmap 5, x&y scaling of 50,60

ld_special:
           lodsw                  ; get from si, first is point
           shl ax,1
           add ax,lindex          ; add to include offset in list
           stosw                  ; put in sides table

           mov dx,bp              ; save indexer
           mov bp,ax              ; get point indexers
           mov ax,[zp+bp]
           mov zeds[ebx],ax       ; set zed for sort.
           mov bp,dx

           movsw                  ; get bitmap type
           movsw                  ; get x then y scaling
           movsw

           cmp zad,64000          ; bitmaps farther than 65536 screw up
           jge skipit             ; you can't see them anyway. prevent overflow
           jmp ln2

           align 4

loadsides:
           mov esi,edi            ; edi = pointer to side object data
           mov edi,offsides       ; get ready for lodsw and stosw
           mov ebp,edi            ; ebp = offset to first point in side
           movzx ebx,showing      ; bx = word indexer for surfaces
           shl bx,1
ld_lp:
           lodsw                  ; get command word

           mov commands[ebx],ax

           test ax,32             ; if bitmap, do special load
           jnz ld_special

           lodsw                  ; get colour, high byte is other side

           mov surfcolors[ebx],ax ; save colour

           mov cx,lindex          ; quick add for loop

           lodsw                  ; get from si, first is unconditinal
           shl ax,1
           add ax,cx              ; add to include offset in list
           stosw                  ; put in di
           mov dx,ax
ld_loop:
           lodsw                  ; get from si
           shl ax,1
           add ax,cx
           stosw                  ; put in di

           cmp ax,dx              ; check all after first point
           jne s ld_loop

           push ebp
           push esi
           push ebx

           mov edi,ebp            ; adjust bp into appropriate indexer

           mov bp,dx              ; get point indexers
           mov dx,[zp+bp]         ; get at least one z value, should be max
           mov zeds[ebx],dx       ; but any will do.

           test commands[ebx],2+16+64 ; check for always visable or command
           jnz its_line

           mov bx,[edi+4]

           mov dx,[xp+bp]         ; first point
           mov ax,[yp+bp]
           mov esq,ax             ; memory

           mov bp,[edi+2]
           mov si,[xp+bp]         ; second point
           mov ax,[yp+bp]
           mov dsq,ax             ; memory

           mov bp,bx
           mov di,[xp+bp]         ; third point
           mov bp,[yp+bp]

           call checkfront        ; check if side is visable using p1,2,3

           pop ebx
           pop esi                ; return object data pointer
           pop ebp                ; return where we are in sides list

           cmp ecx,0+1            ; +1 makes small objects look better
           jle ln2                ; cx>-1 if side visible, skip if not

           test commands[ebx],4   ; test to use other colour
           jz s skipit            ; miss this side...

           mov ax,surfcolors[ebx] ; get new colour
           xchg ah,al             ; flip to other colour
           mov surfcolors[ebx],ax ; save colour
           mov ax,commands[ebx]   ; use new steel texture bit
           mov cx,ax
           shr ax,3
           and ax,1
           and cx,255-1
           or  cx,ax
           mov commands[ebx],cx
ln2:
           inc showing            ; another side added...

           add bx,2
           add ebp,maxpolys*2     ; bump ebp to next block
skipit:
           mov edi,ebp            ; set di for next stosw

           dec numsides           ; count for next side
           jne ld_lp

           mov offsides,edi       ; save for next call

           ret
its_line:
           pop ebx esi ebp
           jmp s ln2

           align 4

; make object esi - routine assumes object is already ON!  note: esi, not si!

make1obj:
           push esi
           shl si,2               ; si = dword

           mov ebx,xs[esi]        ; displacement
           sub ebx,eyex
           mov ecx,ys[esi]
           sub ecx,eyey
           mov ebp,zs[esi]
           sub ebp,eyez

           shr ebx,8              ; account for decimal places
           test ebx,00800000h
           jz s pm_1
           or ebx, 0ff000000h
pm_1:
           shr ecx,8
           test ecx,00800000h
           jz s pm_2
           or ecx, 0ff000000h
pm_2:
           shr ebp,8
           test ebp,00800000h
           jz s pm_3
           or ebp, 0ff000000h
pm_3:
           cmp ebx,-maxz          ; check if within visible space
           jl s noa2              ; if object miles away, don't bother
           cmp ebx,maxz
           jg s noa2

           cmp ebp,-maxz
           jl s noa2
           cmp ebp,maxz
           jg s noa2

           cmp ecx,-maxz
           jl s noa2
           cmp ecx,maxz
           jng s mo_misout

           align 4
noa2:
           pop esi
           ret

mo_misout:
           call zsolve            ; figure out camera displacement
           cmp esi,minz           ; check if behind camera, miminum dist.
           jl s noa2

           call xsolve
           mov xad,edi            ; store 3d offsets
           call make3dx           ; now make object farther in 3d (cheat)

           cmp edi,xmit           ; tolerance is max object size/ratio
           jl s noa2
           cmp edi,xmat
           jge s noa2

           call ysolve
           mov yad,ecx
           call make3dy

           pop esi                ; pop original object number

           mov zad,ebp

           test userotate[esi],32+64 ; check if bitmap or point
           jnz s mo_special

           cmp ecx,ymit
           jl s noa
           cmp ecx,ymat
           jge s noa

           cmp userotate[esi],0
           jne s mk_skipc         ; skip if anything other than full rotations

           shl si,1               ; si = word
           call compound          ; full rotation object, calc. matrix
           shr si,1
mk_skipc:
           call loadpoints        ; load points and rotate, exit di=sides
           jmp  loadsides         ; now load sides, starting at di

           align 4
noa:
           ret

           align 4

; if userotate = 32 then draw bitmap at location x,y,z

mo_special:
           cmp pointindex,(maxpoints-1)*2 ; check if there is room in table
           jge s noa
           cmp showing,maxsurfaces-1
           jge s noa

           test userotate[esi],64 ; is point or bitmap?
           jnz mo_ispoint

           cmp ecx,ymit           ; test if bitmap visible
           jl s noa
           cmp ecx,ymat
           jge s noa

           cmp ebp,65535          ; far bitmaps screw up, abort
           jge s noa

           mov di,pointindex
           mov [xp+di],bx         ; set location of bitmap
           mov [yp+di],cx
           mov [zp+di],bp

           mov edi,offsides

           movzx ebx,showing
           shl bx,1
           mov zeds[ebx],bp       ; set z sort indexer

           inc showing            ; one more surface...
           mov commands[ebx],32   ; set command for bitmap

           shl esi,1              ; si = word

           mov ax,pointindex
           add pointindex,2
           stosw
           mov ax,whatshape[esi]
           stosw
           mov ax,vxs[esi]        ; set x and y scales (stretching)
           stosw
           mov ax,vys[esi]
           stosw
           mov offsides,edi       ; update for next object/bitmap
noa4:
           ret

           align 4

mo_ispoint:
           cmp bx,xmins            ; draw single point/bullet
           jl s noa8
           cmp bx,xmaxs
           jge s noa8
           cmp cx,ymins
           jl s noa8
           cmp cx,ymaxs            ; ymaxs1 if larger pixel
           jge s noa8

           mov di,pointindex
           mov [xp+di],bx         ; set location of point/bitmap
           mov [yp+di],cx
           mov [zp+di],bp

           mov edi,offsides

           movzx ebx,showing
           shl bx,1
           mov zeds[ebx],bp       ; set z sort indexer

           inc showing            ; one more surface...

           mov commands[ebx],64   ; set this command as point
           mov surfcolors[ebx],bulletcolour ; only for variable colours

           mov ax,pointindex
           add pointindex,2

           stosw
           stosw
           mov offsides,edi
noa8:
           ret

           align 4

; draw vectors from sides list.
; number of "sides" is "showing"

drawvect:
           cmp showing,0          ; no sides visible?
           je s noa8

           mov whichside,0        ; start at side 0
           movzx ebp,order[0]     ; indexer to sides
dv_loop2:
           test commands[ebp],16+32+64 ; test if line, point or bitmap
           jnz dv_testit          ; yes, do faster line routine

           shl bp,mult
           mov dx,[sides+bp]      ; first point is end flag
dv_loop1:
           mov si,[sides+bp]      ; get point, shl 1 not needed, pre-shl'ed
           mov ax,[xp+si]
           mov bx,[yp+si]
           mov x1,ax
           mov y1,bx

           mov si,[sides+bp+2]    ; get next point

           cmp si,dx              ; test if last = first, therefore done
           pushf

           mov ax,[xp+si]
           mov bx,[yp+si]

           mov x2,ax
           mov y2,bx

           push bp dx
           call fakeline          ; draw next line
           pop dx bp

           add bp,2               ; bump to next pointer now
           popf                   ; was this point equal to the first point?
           jne s dv_loop1         ; no, draw more lines

           movzx esi,whichside    ; set colour for this side
           mov si,order[esi]
           mov ax,surfcolors[esi]
           mov colq,al

           mov bx,commands[esi]   ; use register which we can access low byte
           and bl,1               ; strip steel command bit
           sub bl,1
           mov steel,bl

           call poly_fill

dv_return:
           add whichside,2        ; bump bp to next block of points
           movzx ebp,whichside
           mov bp,order[ebp]      ; get sort order
           dec showing            ; count for all sides
           jne dv_loop2
dv_none:
           ret

           align 4
dv_testit:
           mov ax,commands[ebp]   ; perform command, return to dv_return
           test ax,16
           jnz dv_doline
           test ax,64
           jnz dv_dopoint

; draw bitmap at location x,y,z if userotate = 32 or command = 32

           shl bp,mult
           push bp

           movzx ebx,[sides+4+bp]
           movzx ecx,[sides+6+bp]

           mov si,[sides+2+bp]
           shl si,2               ; si = dword
           add ebx,bitx[si]
           add ecx,bity[si]       ; ebx,ecx = top corner of bitmap in 3d

           mov eax,bitbase[si]
           mov bitmap,eax

           mov si,[sides+0+bp]
           mov bp,[zp+si]

           call make3d            ; ebx,ecx = difference from center

           pop bp

           mov si,[sides+0+bp]    ; get point
           mov ax,[xp+si]
           mov bp,[yp+si]

           sub ax,bx              ; bx = x width/2  ax, bp = top corner
           sub bp,cx              ; cx = y height/2

           if useborders eq yes

           cmp bp,yupdate+0
           jge s up_no12
           mov yupdate+0,bp
up_no12:
           cmp ax,xupdate+0
           jge s up_no32
           mov xupdate+0,ax
up_no32:
           mov di,ax
           mov dx,bp

           endif

           add ax,xcent
           add bp,ycent
           mov destx,ax
           mov desty,bp

           shl bx,1
           shl cx,1

           mov destwidth,bx
           mov destheight,cx

           if useborders eq yes
           add di,bx
           add dx,cx

           cmp dx,yupdate+2
           jng s up_no42
           mov yupdate+2,dx
up_no42:
           cmp di,xupdate+2
           jng s up_no22
           mov xupdate+2,di
up_no22:
           endif

           call xscale2
noa7:
           jmp dv_return

           align 4

dv_dopoint:
           mov dx,surfcolors[ebp]    ; get colour of point

           shl bp,mult
           mov si,[sides+bp]       ; get point x,y
           mov bx,[xp+si]
           mov cx,[yp+si]

           cmp bx,xmins            ; check if on screen
           jl s noa7
           cmp bx,xmaxs
           jge s noa7
           cmp cx,ymins
           jl s noa7
           cmp cx,ymaxs            ; ymaxs1 if larger pixel
           jge s noa7

           mov edi, current_page   ; point to active vga page

           if useborders eq yes

           cmp cx,yupdate+0
           jge s up_no16
           mov yupdate+0,cx
up_no16:
           cmp bx,xupdate+0
           jge s up_no36
           mov xupdate+0,bx
up_no36:
           cmp cx,yupdate+2
           jng s up_no46
           mov yupdate+2,cx
up_no46:
           cmp bx,xupdate+2
           jng s up_no26
           mov xupdate+2,bx
up_no26:
           endif

           add bx,xcent
           add cx,ycent

           mov bp,dx               ; save colour

           mov si,cx
           shl si,1
           mov ax,[si+fastimultable] ; get offset to start of line

           mov cx, bx              ; copy to extract plane # from
           shr bx, 2               ; x offset (bytes) = xpos/4
           add bx, ax              ; offset = width*ypos + xpos/4

           mov ax, map_mask_plane1 ; map mask & plane select register
           and cl, plane_bits      ; get plane bits
           shl ah, cl              ; get plane select value
           out_16 sc_index, ax     ; select plane

           movzx ebx,bx
           mov ax,bp               ; re-get colour
           mov [edi+ebx],al        ; draw pixel, low is top, high is bottom
;          add edi,xactual/4
;          mov [edi+ebx],ah        ; draw larger bullet/pixel (high byte)

; if drawing larger pixel, change above code to this!
;          cmp cx,ymaxs1
;          jge s noa7

           jmp dv_return

           align 4

; clipped line, only callable from draw_vect!
; similar routine to fakeline but faster,  more  accurate  and  draws  directly
; to screen (current_page).
;
; this routine will always return to dv_return but you could replace those with
; ret's and make this routine  callable  from  places   other  than  draw_vect.
; if  you  do  this,  make  sure  you  re-direct  the  draw_vect    routine  to
; call dv_doline, jmp dv_return.  for now, set showing=1 and  load  dx,cx,ax,bx
; with x1,y1,x2,y2 and call dv_middle.  thats if you really need a clipped line
; draw routine.

dv_doline:
           shl bp,mult
           mov si,[sides+bp]      ; get first point
           mov dx,[xp+si]
           mov cx,[yp+si]

           mov si,[sides+bp+2]    ; second point
           mov ax,[xp+si]
           mov bx,[yp+si]
dv_middle:
           cmp bx,cx              ; flip order of points if drawing up
           jg s r_okorder
           xchg bx,cx
           xchg ax,dx
r_okorder:
           mov x1,dx
           mov y1,cx
           mov x2,ax
           mov y2,bx

           if useborders eq yes

           cmp cx,yupdate+0       ; update borders for clearing routine
           jg s r_up_no1
           mov yupdate+0,cx
r_up_no1:
           cmp bx,yupdate+2
           jng s r_up_no2
           mov yupdate+2,bx
r_up_no2:
           mov bx,ax
           mov ax,dx
           mov dx,xupdate+0
           mov cx,xupdate+2

           cmp ax,dx
           jge s r_up_no3
           dec ax
           mov xupdate+0,ax
           mov dx,ax
           inc ax
r_up_no3:
           cmp bx,cx
           jle s r_up_no4
           inc bx
           mov xupdate+2,bx
           mov cx,bx
           dec bx
r_up_no4:
           cmp bx,dx
           jge s r_up_no5
           dec bx
           mov xupdate+0,bx
r_up_no5:
           cmp ax,cx
           jle s r_up_no6
           inc ax
           mov xupdate+2,ax
r_up_no6:
           mov ax,x2              ; ax=x
           sub ax,x1
           mov bx,y2              ; bx=y
           sub bx,y1

           elseif not useborders eq yes

           sub ax,dx
           sub bx,cx

           endif

           movzx esi,whichside       ; set colour for this line
           mov si,order[esi]
           mov dx,surfcolors[esi]
           mov colq,dl

           mov dx,ymaxs
           cmp y1,dx
           jge dv_return

           mov rise,bx
           movsx ebx,bx
           cmp ebx,0
           jne s r_nsliver

           mov bx, y1
           cmp bx, ymins          ; draw sliver, avoid divide by zero
           jl dv_return
           cmp bx, dx             ; dx = ymax
           jge dv_return

           add bx,ycent
           mov si,bx
           shl si,1
           movzx eax,[si+fastimultable] ; get offset to start of line
           mov edi, current_page
           add edi, eax           ; edi = starting y location

           mov rise,1

           mov dx, x1             ; from here...
           mov si, x2             ;            ..to here

           cmp si,xmins
           jge s u_nou3
           mov si,xmins
u_nou3:
           cmp si,xmaxs
           jl s u_noq3
           mov si,xmaxs1
u_noq3:
           jmp r_splint           ; re-enter draw later in code

           align 4
r_nsliver:
           shl eax,16
           cdq
           idiv ebx
           mov ebp,eax            ; ebp = slope*65536 (allows decimals)

           mov ax,ymins
           cmp y1,ax              ; check if above screen
           jge s r_li_abov1
           sub ax,y1              ; ax = abs(difference of ymin-y1)
           sub rise,ax            ; dec counter
           jle dv_return          ; line totally off screen

           movsx eax,ax           ; prepare for 32bit mul
           imul ebp
           shr eax,16             ; get top word
           add x1,ax              ; set new x1,y1 pair
           mov ax,ymins
           mov y1,ax

r_li_abov1:
           mov bx,y1              ; bx distance from top of screen
           add bx,ycent
           mov si, bx             ; calculate screen address
           shl si,1
           movzx eax,[si+fastimultable] ; get offset to start of line
           mov edi, current_page
           add edi,eax            ; edi = starting y location

           movsx edx,x1
           shl edx,16
           mov cx,rise
           mov ax,y1
           add ax,cx              ; will line go off bottom of screen?
           cmp ax,ymaxs
           jl s r_linep           ; no...
           sub ax,ymaxs           ; yes, truncate cx for early exit
           sub rise,ax
           jle dv_return
r_linep:
           mov eax,edx
           movzx ecx,cx

           mov esi,edx
           shr esi,16

           cmp si,xmins
           jge s r_nou
           mov si,xmins
r_nou:
           cmp si,xmaxs
           jl s r_noq
           mov si,xmaxs1
r_noq:
           align 4

r_lineloop:
           add eax,ebp             ; main line drawing loop!!! (for lines)
           mov edx,eax
           shr edx,16
r_splint:
           cmp dx,xmins
           jge s u_nou
           mov dx,xmins
           cmp dx,si
           je r_mis
u_nou:
           cmp dx,xmaxs
           jl s u_noq
           mov dx,xmaxs1
           cmp dx,si
           je r_mis
u_noq:
           push dx edi ebp eax     ; save for next line
           cmp dx,si
           jle s r_no_switch
           xchg dx,si
r_no_switch:

           add dx,xcent
           add si,xcent

           mov ax,dx
           mov bx,si
           mov x2,si

           shr dx,2                ; dx/4 = bytes into line
           movzx edx,dx
           add edi,edx             ; di = addr of upper-left corner

           movzx ecx,bx            ; cx = x2 (pixel position)
           shr cx,2                ; cx/4 = bytes into line

           cmp dx,cx               ; start and end in same band?
           je  rf_one_band_only    ; if so, then special processing

           sub cx,dx               ; cx = # bands -1
           mov si,ax               ; si = plane#(x1)
           and si,plane_bits       ; if left edge is aligned then
           jz s rf_l_plane_flush   ; no special processing..

; draw "left edge" of 1-3 pixels...

           out_8 sc_data, left_clip_mask[si] ; set left edge plane mask

           mov al,colq             ; get fill color
           mov [edi], al           ; fill in left edge pixels

           inc edi                 ; point to middle (or right) block
           dec cx                  ; reset cx instead of jmp s rf_right

rf_l_plane_flush:
           inc cx                  ; add in left band to middle block

; di = addr of 1st middle pixel (band) to fill
; cx = # of bands to fill -1

rf_right:
           mov si,bx               ; get xpos2
           and si,plane_bits       ; get plane values
           cmp si,0003             ; plane = 3?
           je s rf_r_edge_flush    ; hey, add to middle

; draw "right edge" of 1-3 pixels...

           out_8 sc_data, right_clip_mask[si]  ; right edge plane mask

           mov esi,edi             ; get addr of left edge
           add esi,ecx             ; add width-1 (bands)
           dec esi                 ; to point to top of right edge

           mov al,colq             ; get fill color

rf_right_loop:
           mov [esi], al           ; fill in right edge pixels

           dec cx                  ; minus 1 for middle bands
           jz s rf_exit            ; uh.. no middle bands...

rf_r_edge_flush:

; di = addr of upper left block to fill
; cx = # of bands to fill in (width)

           out_8 sc_data, all_planes ; write to all planes

           mov dx, xactual/4       ; dx = di increment
           sub dx, cx              ;  = screen_width-# planes filled

           mov al, colq            ; get fill color
           mov ah, al              ; colour is in high and low for stosw
           push ax                 ; make colour 32 bit
           shl eax,16
           pop ax

rf_middle_loop:
           shr cx,1                ; use doubleword transfer
           jnc s rf_ord
           stosb                   ; if cx odd, store byte first
           jcxz s rf_exit          ; no words after stosb
rf_ord:
           shr cx,1
           jnc rf_dord
           stosw
           jcxz s rf_exit          ; no doublewords after stosw
rf_dord:
           rep stosd               ; fill in entire line

           jmp s rf_exit           ; outa here, for this line

rf_one_band_only:
           mov si,ax                  ; get left clip mask, save x1
           and si,plane_bits          ; mask out row #
           mov al,left_clip_mask[si]  ; get left edge mask
           mov si,bx                  ; get right clip mask, save x2
           and si,plane_bits          ; mask out row #
           and al,right_clip_mask[si] ; get right edge mask byte

           out_8 sc_data, al       ; clip for left & right masks

           mov al, colq            ; get fill color
           mov [edi], al           ; fill in pixels
rf_exit:
           pop eax ebp edi si      ; pop screen left address
r_mis:
           add edi, xactual/4
           dec rise
           jg r_lineloop

           jmp dv_return           ; re-enter draw_vect

; bubble sort for sides

; sort is not perfect since many sides can use the same point.
; if this point is the first point in the list and therefore zeds[] uses
; the same point for sort, the routine may mess up when plotting at some
; acute angles.  if you ever notice this, you are way too picky.  you
; could fix this by adjusting the load_sides routine to search for the
; closest z point.

           align 4

minusd equ offset zeds - offset order

sort_list:
           movzx esi,showing
           cmp si,1               ; if only one surface, exit
           jle qke

           shl si,1               ; si = word
           add esi,o order

           align 4
nextcx:
           sub esi,2              ; point to last word in order[] table

           mov ebp,esi            ; set order pointer
           mov bx,w [esi]         ; get order[si]

           mov edi,esi
           add edi,minusd
           mov cx,w [edi]         ; get zeds[si]

           align 4
nextdx:
           sub edi,2
           sub ebp,2

           cmp cx,w [edi]         ; zeds is point from side, should be max z
           jle s donothing
           xchg cx,w [edi]        ; don't flip entire side, just indexers to it
           xchg bx,w [ebp]
donothing:
           cmp ebp,o order        ; check bp = 0
           jne s nextdx

           mov [esi + minusd],cx
           mov [esi],bx

           cmp esi,o order + 2
           jne s nextcx
qke:
           ret

           align 4

set_makeorder:
           movzx ecx,showing
           jcxz s non2_do
           dec ecx
           jcxz s non2_do
           shl ecx,1
           mov esi,ecx
           add esi,offset order
ordrloop:
           mov [esi],cx
           sub esi,2
           dec cx
           loop ordrloop
non2_do:
           mov [order],0          ; fill last

           mov offsides, offset sides ; clear table indexers for next call
           mov pointindex,0

           ret

           align 4

look_at_it:                       ; force camera to look at object wherelook

           mov si,wherelook
           cmp si,no
           je s noat              ; get out, no object to look at (-1=flag)

           mov edi,maxobjects
           movzx esi,si
           call calc_angles
           mov eyeay,bx
           mov eyeax,ax
noat:
           ret

; calculate angles between objects esi and edi.  angles are from point of view
; of di.

calc_angles:
           shl si,2               ; si = dword
           shl di,2
           call get_displacement
calc_middle:
           shr ebx,8              ; account for decimal places
           test ebx,00800000h
           jz s pm_7
           or ebx, 0ff000000h
pm_7:
           shr ecx,8
           test ecx,00800000h
           jz s pm_8
           or ecx, 0ff000000h
pm_8:
           shr ebp,8
           test ebp,00800000h
           jz s pm_9
           or ebp, 0ff000000h
pm_9:
           cmp ebx,-maxz          ; check if within visible space
           jl  noaq               ; object miles away, don't bother
           cmp ebx,maxz           ; could divide by some high number
           jg  noaq               ; and try again.  shr not good because
                                  ; ecx,ebx,ebp must be sign extended
           cmp ebp,-maxz
           jl  noaq
           cmp ebp,maxz
           jg  noaq

           cmp ecx,-maxz
           jl  noaq
           cmp ecx,maxz
           jg  noaq

           push ecx ebx ebp

           mov ecx,ebx            ; first get z,x plane, (y angle)
           mov eax,ebp

           cmp eax,16384          ; if object miles away, shr and re-check
           jle s lk_oktab1
           shr eax,3
           shr ecx,3
           jmp s lk_oktab4        ; re-check to test if in space
           align 4
lk_oktab1:
           cmp ecx,16384          ; if object miles away, shr and re-check
           jle s lk_oktab2
           shr eax,3
           shr ecx,3
           jmp s lk_oktab4        ; re-check to test if in space
           align 4
lk_oktab2:
           cmp eax,-16384         ; if object miles away, shr and re-check
           jge s lk_oktab3
           shr eax,3
           shr ecx,3
           jmp s lk_oktab4        ; re-check to test if in space
           align 4
lk_oktab3:
           cmp ecx,-16384         ; if object miles away, shr and re-check
           jge s lk_oktab4
           shr eax,3
           shr ecx,3
           jmp s lk_oktab4        ; re-check to test if in space
           align 4
lk_oktab4:
           cmp eax,0
           je lk_right_above      ; check arctan(cx/0)

           call arctan
lk_resume:
           mov dsq,ax           ; save y angle
           call cosign            ; set up 32bit sin/cos multipliers
           mov vycos,eax
           mov ax,dsq
           call sign

           pop ebp ebx            ; now compute sqr(z^2+x^2) through y rotation

           imul ebx               ; use angle from calculation above
           shrd eax,edx,14
           mov edi,eax
           mov eax,vycos
           imul ebp
           shrd eax,edx,14
           add eax,edi            ; di = new z = run

           pop ecx                ; cx = rise

           cmp eax,16384          ; if object miles away, shr and re-check
           jle s lk_oktap1
           shr eax,3
           shr ecx,3
           jmp s lk_oktap4        ; re-check to test if in space
           align 4
lk_oktap1:
           cmp ecx,16384          ; if object miles away, shr and re-check
           jle s lk_oktap2
           shr eax,3
           shr ecx,3
           jmp s lk_oktap4        ; re-check to test if in space
           align 4
lk_oktap2:
           cmp eax,-16384         ; if object miles away, shr and re-check
           jge s lk_oktap3
           shr eax,3
           shr ecx,3
           jmp s lk_oktap4        ; re-check to test if in space
           align 4
lk_oktap3:
           cmp ecx,-16384         ; if object miles away, shr and re-check
           jge s lk_oktap4
           shr eax,3
           shr ecx,3
           jmp s lk_oktap4        ; re-check to test if in space
           align 4
lk_oktap4:
           cmp eax,0
           je s noaq

           call arctan            ; get ax=arctan(y/sqr(z^2+x^2))

           mov bx,dsq             ; bx = y angle , ax = x angle
noaq:
           ret

           align 4

lk_right_above:
           mov ax,vys[esi]        ; camera directly above object, use old y
           jmp lk_resume

           align 4

get_displacement:
           mov ebx,xs[esi]        ; get displacement of esi to edi
           sub ebx,xs[edi]
           mov ecx,ys[esi]
           sub ecx,ys[edi]
           mov ebp,zs[esi]
           sub ebp,zs[edi]
           ret

           align 4

; new follow, si = object for new follow, di = time to get there.

newfollow:
           mov wfollow,si         ; save in case object is accelerating
           mov oldspeed,di
           mov wherelook,no       ; disable look_at_si routine

           shl si,1
           movzx esi,si
           mov ax,lcount[esi]
           cmp ax,di              ; if di>lcount, shorten to lcount
           ja s nx
           mov di,ax
nx:
           movzx edi,di

           shl si,1               ; si = dword

           mov eax,xadds[esi]     ; figure out where object will be di*frames
           imul edi
           add eax,xs[esi]
           mov ebx,eax

           mov eax,yadds[esi]
           imul edi
           add eax,ys[esi]
           mov ecx,eax

           mov eax,zadds[esi]
           imul edi
           add eax,zs[esi]
           mov ebp,eax

           mov di,oldspeed
           mov ax,eyelcount
           cmp ax,di              ; if di>lcount, shorten to lcount
           ja s tx
           mov di,ax
tx:
           movzx edi,di

           mov eax,eyexadds
           imul edi               ; figure out where camera will be di*frames
           add eax,eyex
           sub ebx,eax            ; get displacement to eye

           mov eax,eyeyadds
           imul edi
           add eax,eyey
           sub ecx,eax

           mov eax,eyezadds
           imul edi
           add eax,eyez
           sub ebp,eax

           call calc_middle       ; jump in middle of angle computation

           mov di,bx

           sub ax,eyeax           ; get difference from where we are now
           sub di,eyeay

           add ax,followtol       ; check if already looking at it
           cmp ax,followtol*2
           ja s calcit

           add di,followtol
           cmp di,followtol*2
           jb just_look_at_it_now_instead_of_calculating
           sub di,followtol
calcit:
           sub ax,followtol

           mov si,oldspeed        ; ax=x angle, di=y angle, si=# frames
           cwd
           push dx                ; save sign extend
           idiv si                ; x/time
           pop dx
           cmp ax,0
           jne s n0
           shl dx,1
           mov ax,dx
           inc ax                 ; ax = 1 or ax = -1
n0:
           mov eyevxadds,ax

           mov ax,di
           cwd
           push dx
           idiv si                ; y/time
           pop dx
           cmp ax,0               ; check if zero slope, must have some...
           jne s n1
           shl dx,1               ; dx = fffe (-2) or 0
           mov ax,dx
           inc ax                 ; ax = 1 or ax = -1
n1:
           mov eyevyadds,ax

           mov eyeacount,si
           shr oldspeed,1         ; if need to try again, time/2
noau:
           ret

just_look_at_it_now_instead_of_calculating:
           mov ax,wfollow
           mov wherelook,ax       ; already looking at object, now follow it
           mov wfollow,no
           ret

; move object si from wherever it is now to ebx,ecx,ebp in di frames
; move is 32 bit, make sure high words of registers are set!
; time to get there is 16 bit. (if you need more, think! 65535 frames at
; 1/30 frames a sec is 36 minutes!)

move_si:

           movzx esi,si
           shl si,2               ; si = dword
           sub ebx,xs[esi]
           sub ecx,ys[esi]
           sub ebp,zs[esi]

           movzx edi,di

           mov eax,ebx            ; 32 bit moves

           cdq
           idiv edi
           mov xadds[esi],eax

           mov eax,ecx
           cdq
           idiv edi
           mov yadds[esi],eax

           mov eax,ebp
           cdq
           idiv edi
           mov zadds[esi],eax

           shr si,1               ; si = word

           mov lcount[esi],di
           shr si,1               ; restore original si

           ret

put_object:
           movzx esi,si
           shl si,2
           mov xs[esi],ebx
           mov ys[esi],ecx
           mov zs[esi],ebp
           shr si,2
           ret

set_angle:
           movzx esi,si
           shl si,1
           mov vxs[esi],bx
           mov vys[esi],cx
           mov vzs[esi],bp
           shr si,1
           ret
set_shape:
           movzx esi,si
           shl si,1
           mov whatshape[esi],ax
           shr si,1
           ret

set_object_on:
           movzx esi,si
           mov onoff[esi],1
           ret

set_object_off:
           movzx esi,si
           mov onoff[esi],0
           ret

           align 4

           include vars2.inc      ; vars goes at end so indexing can be near

makeobjs:                          ; make all objects, unrolled loop
           i=0

           rept maxobjects
           local itsoff

           test onoff+i,255        ; check on/off
           jz s itsoff

           mov esi,i
           call make1obj
itsoff:

           i=i+1
           endm

           ret                     ; put no code here! make1obj may abort!

code32     ends
           end
