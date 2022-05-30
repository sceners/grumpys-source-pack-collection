; common routines between 3d1.asm and 3d2.asm

            public poly_fill
            public clear_fill
            public initpages
            public flip_page
            public fakeline
            public set_clip_absolute
            public set_clip_offset
            public updvectors

; clears a block from active display page
;
; this routine works only if borders of xclip land on even nybbles
; eg minimum x is 32 - works fine.  but if minimum x is 37, this
; routine will clear all the way to 32 just the same.  for better clearing,
; call fill_block routine with lxupdate and lyupdate parameters on stack
;
; routine was originally written by matt prichard.  routine was then modified
; to clear using dwords, and clear to integer borders.
;
; entry: lxupdate+0  = left x position of area to fill
;        lxupdate+2  = top y position of area to fill
;        lyupdate+0  = right x position of area to fill
;        lyupdate+2  = bottom y position of area to fill

           align 4

clear_fill:

           if useborders eq yes

           cmp use_clear,no
           je tf_exit                  ; don't use clear routine

           mov edi, current_page       ; point to active vga page
           cld                         ; direction flag = forward

           out_8 sc_index, map_mask    ; set up for plane select
           out_8 sc_data, all_planes ; write to all planes

           mov ax,lxupdate+0
           mov bx,lxupdate+2
           mov cx,lyupdate+0
           mov dx,lyupdate+2

           add ax,xcent        ; center on screen
           add bx,xcent
           add cx,ycents1
           add dx,ycentp1

           and ax,0fff8h
           and bx,0fff8h
           add bx,7

           cmp ax,cliplt       ; clip to inside borders
           jge s tf_noclip1
           mov ax,cliplt
tf_noclip1:
           cmp bx,xmaxxcent
           jl  s tf_noclip2
           mov bx,cliprt
tf_noclip2:
           cmp cx,cliptp
           jge s tf_noclip3
           mov cx,cliptp
tf_noclip3:
           cmp dx,ymaxycent
           jl  s tf_noclip4
           mov dx,ymaxycent
tf_noclip4:
           mov lxupdate+0,ax
           mov lxupdate+2,bx
           mov lyupdate+0,cx
           mov lyupdate+2,dx

           cmp ax,bx
           jg  tf_exit             ; nothing to do!

           cmp cx,dx
           jg  tf_exit             ; nothing to do!

           mov ax,cx
           mov bx,dx

           sub bx,ax               ; get y width
           mov lyupdate+2,bx       ; save in ypos2

           mov si,ax
           shl si,1
           movzx eax,w [si+fastimultable]  ; mul y1 by bytes per line
           add edi,eax             ; di = start of line y1

           mov dx,lxupdate         ; dx = x1 (pixel position)
           shr dx,2                ; dx/4 = bytes into line
           movzx edx,dx
           add edi,edx             ; di = addr of upper-left corner

           mov cx,lxupdate+2       ; cx = x2 (pixel position)
           sub cx,lxupdate
           shr cx,3                ; cx/4 = bytes into line
           inc cx

; di = addr of upper left block to fill
; cx = # of bands to fill in (width)

           mov dx,xactual/4        ; dx = di increment
           sub dx,cx               ;  = screen_width-# planes filled
           sub dx,cx

           movzx ecx,cx
           mov ebx,ecx             ; bx = quick refill for cx
           mov si,lyupdate+2       ; si = # of lines to fill
           mov ax,background       ; get fill color
           push ax                 ; make 32 bit
           shl eax,16
           pop ax

           shr ecx,1
           shr ebx,1
           jnc s tf_middle_loop2

           align 4

tf_middle_loop1:
           stosw
           rep stosd               ; fill in entire line

           mov ecx, ebx            ; recharge cx (line width)
           add edi, edx            ; point to start of next line
           loopx si, tf_middle_loop1  ; loop until all lines drawn

           ret

           align 4

tf_middle_loop2:
           rep stosd               ; fill in entire line, doubleword store

           mov ecx, ebx            ; recharge cx (line width)
           add edi, edx            ; point to start of next line
           loopx si, tf_middle_loop2  ; loop until all lines drawn
tf_exit:
           endif

           ret                     ; exit

; fill starting at oney, from firstbyte to lastbyte

           align 4

poly_fill:
           mov edi, current_page   ; point to active vga page

           out_8 sc_index, map_mask ; set up for plane select

           mov ax,oney             ; ax=y1
           cmp ax,ymins
           jge s pf_okmin
           xor ax,ax
           jmp s pf_missub
           align 4
pf_okmin:
           cmp ax,ymaxs
           jge pf_outearly
           sub ax,ymins
pf_missub:
           if usesteel eq yes
           cmp steel,no            ; test to use steel texture
           je s pf_skipsteel
           mov bl,colq             ; yes, save colour offset and 16 block
           mov steelc,bl
           and steelc,0f0h         ; save base offset of 16 colour block
           shl bl,2                ; colour offset is *2 (small) *4 (large)
           add bl,al               ; make steel always constant
           and bl,03fh             ; colour indexer (so sides look different)
           mov steel ,bl
pf_skipsteel:
           endif

           mov bp,ax               ; indexer to line
           shl bp,1
           add ax, cliptp

           mov si,ax
           shl si,1
           movzx eax,w [si+fastimultable] ; mul y1 by bytes per line

           add edi,eax             ; di = start of line y1

pf_more_lines:
           push edi                ; save right hand position
           mov ax, [firstbyte+bp]
           cmp ax,xmaxs            ; check if fill done
           jge pf_done

           if usesteel eq yes
           mov bl,steel            ; use steel texture?
           cmp bl,no
           je s pf_no_steel
           xor bh,bh
           mov dl,pf_updown[bx]
           add dl,steelc
           mov colq,dl
           inc bl
           and bl,03fh             ; 16 colours, 32 positions for steel texture
           mov steel,bl
pf_no_steel:
           endif

           mov bx,[lastbyte+bp]
           add ax,xcent
           add bx,xcent

           mov dx,ax               ; dx = x1 (pixel position)
           shr dx,2                ; dx/4 = bytes into line
           movzx edx,dx
           add edi,edx             ; di = addr of upper-left corner

           movzx ecx,bx            ; cx = x2 (pixel position)
           shr cx,2                ; cx/4 = bytes into line

           cmp dx,cx               ; start and end in same band?
           jg pf_exit              ; skip if fakeline fails connection
           jne s pf_normal         ; if not, check for l & r edges
           jmp pf_one_band_only    ; if so, then special processing
pf_done:
           pop eax
pf_outearly:
           mov oney,1000           ; reset for next polygon call
           ret
pf_normal:
           sub cx,dx               ; cx = # bands -1
           mov si,ax               ; si = plane#(x1)
           and si,plane_bits       ; if left edge is aligned then
           jz s pf_l_plane_flush   ; no special processing..

; draw "left edge" of 1-3 pixels...

           out_8 sc_data, left_clip_mask[si] ; set left edge plane mask

           mov al,colq             ; get fill color
           mov [edi], al           ; fill in left edge pixels

           inc edi                 ; point to middle (or right) block
           dec cx                  ; reset cx instead of jmp pf_right

pf_l_plane_flush:
           inc cx                  ; add in left band to middle block

; di = addr of 1st middle pixel (band) to fill
; cx = # of bands to fill -1

pf_right:
           mov si,bx               ; get xpos2
           and si,plane_bits       ; get plane values
           cmp si,0003             ; plane = 3?
           je s pf_r_edge_flush    ; hey, add to middle

; draw "right edge" of 1-3 pixels...

           out_8 sc_data, right_clip_mask[si]  ; right edge plane mask

           mov esi,edi             ; get addr of left edge
           add esi,ecx             ; add width-1 (bands)
           dec esi                 ; to point to top of right edge

           mov al,colq             ; get fill color

pf_right_loop:
           mov [esi], al           ; fill in right edge pixels

           dec cx                  ; minus 1 for middle bands
           jz s pf_exit            ; uh.. no middle bands...

pf_r_edge_flush:

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

pf_middle_loop:
           shr cx,1                ; use doubleword transfer
           jnc s pf_ord
           stosb                   ; if cx odd, store byte first
           jcxz s pf_exit          ; no words after stosb
pf_ord:
           shr cx,1
           jnc s pf_dord
           stosw
           jcxz s pf_exit          ; no doublewords after stosw
pf_dord:
           rep stosd               ; fill in entire line
pf_exit:
           pop edi
           mov [firstbyte+bp],1000 ; reset table for next polygon
           mov [lastbyte+bp],-1000
           add bp,2
           add edi,xactual/4
           jmp pf_more_lines

pf_one_band_only:
           cmp ax, cliplt
           jne s pf_nexit
           cmp bx,ax
           je s pf_exit
pf_nexit:
           cmp ax, cliprt
           je s pf_exit
           mov si,ax                  ; get left clip mask, save x1
           and si,plane_bits          ; mask out row #
           mov al,left_clip_mask[si]  ; get left edge mask
           mov si,bx                  ; get right clip mask, save x2
           and si,plane_bits          ; mask out row #
           and al,right_clip_mask[si] ; get right edge mask byte

           out_8 sc_data, al       ; clip for left & right masks

           mov al, colq            ; get fill color

           mov [edi], al           ; fill in pixels
           jmp s pf_exit           ; outa here, for this line

; small steel texture, make sure to set shl bl,*1* before skip_steel:

;pf_updown  db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
;           db 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
;           db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
;           db 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

; large steel texture, make sure to set shl bl,*2* before skip_steel:

pf_updown  db 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9
           db 10,10,11,11,12,12,13,13,14,14,15,15
           db 15,15,14,14,13,13,12,12,11,11,10,10
           db 9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0

fastimultable label word
           i=0
           rept yactual
           dw i*(xactual/4)
           i=i+1
           endm

resetupd:                         ; make old update equal current update
           if useborders eq yes

           mov ax,xupdate[0]      ; and reset current update
           mov lxupdate[0],ax
           mov ax,xupdate[2]
           mov lxupdate[2],ax
           mov ax,yupdate[0]
           mov lyupdate[0],ax
           mov ax,yupdate[2]
           mov lyupdate[2],ax
           mov ax,xmaxs
           mov bx,xmins1
           mov cx,ymaxs
           mov dx,ymins1
           mov xupdate[0],ax
           mov xupdate[2],bx
           mov yupdate[0],cx
           mov yupdate[2],dx

           endif

           ret

; hey! where is my postcard! see readme.doc file and send me that postcard!

initpages:
           pushw 0
           call set_display_page

           pushw 0
           call set_active_page
           pushw 0
           call clear_vga_screen

           pushw 1
           call set_active_page
           pushw 0
           call clear_vga_screen

           ret

flip_page:
           call get_display_page
           xor ax,1
           push ax
           call set_display_page

           call get_active_page
           xor ax,1
           push ax
           call set_active_page

           ret

; draw a line in tables firstbyte,lastbyte
;
; line is not drawn on screen  but  is  drawn  in  memory  tables.    to  use,
; tables  must  be  clear,   (default  is    always    clear),    just    draw
; line around screen, in any order, then  call  poly_fill.  the  polygon  will
; be drawn and checked in memory, then poly_fill will plop it on  the  current
; page.  poly_fill routine clears tables during plot so tables are  ready  for
; more lines and more polygons.

           align 4

fakeline:
           mov ax,y1
           cmp y2,ax              ; flip order of points if drawing up
           jg s okorder
           mov bx,x1
           xchg bx,x2
           xchg bx,x1
           xchg ax,y2
           xchg ax,y1
okorder:
           mov ax,y1              ; set starting point for fill
           cmp ax,oney
           jge s nonewoney
           mov oney,ax
nonewoney:
           if useborders eq yes

           cmp ax,yupdate+0       ; update borders for clearing routine
           jge s up_no1
           mov yupdate+0,ax
up_no1:
           mov ax,y2
           cmp ax,yupdate+2
           jng s up_no2
           mov yupdate+2,ax
up_no2:
           mov dx,xupdate+0
           mov cx,xupdate+2
           mov ax,x1
           mov bx,x2

           cmp ax,dx
           jge s up_no3
           dec ax
           mov xupdate+0,ax
           mov dx,ax
           inc ax
up_no3:
           cmp bx,cx
           jle s up_no4
           inc bx
           mov xupdate+2,bx
           mov cx,bx
           dec bx
up_no4:
           cmp bx,dx
           jge s up_no5
           dec bx
           mov xupdate+0,bx
up_no5:
           cmp ax,cx
           jle s up_no6
           inc ax
           mov xupdate+2,ax
up_no6:
           endif

           mov ax,x2              ; ax=x
           sub ax,x1
           mov bx,y2              ; bx=y
           sub bx,y1
           jle sliver

           mov rise,bx
           movsx ebx,bx

           shl eax,16
           cdq
           idiv ebx
           mov ebp,eax            ; ebp = slope*65536 (allows decimals)

           mov ax,ymins
           cmp y1,ax              ; check if above screen
           jge s li_abov1
           sub ax,y1              ; ax = abs(difference of ymin-y1)
           sub rise,ax            ; dec counter
           jle li_out             ; line totally off screen

           movsx eax,ax           ; prepare for 32bit mul
           imul ebp
           shr eax,16             ; get top word
           add x1,ax              ; set new x1,y1 pair
           mov ax,ymins
           mov y1,ax
li_abov1:
           movsx edx,x1
           shl edx,16
           mov cx,rise
           mov ax,y1
           mov bx,ax              ; bx pointer first/lastbyte table
           sub bx,ymins
           shl bx,1               ; bx now word

           add ax,cx              ; will line go off bottom of screen?
           cmp ax,ymaxs
           jl s linep             ; no...
           sub ax,ymaxs           ; yes, truncate cx for early exit
           sub cx,ax
           jle s li_out           ; right off screen
linep:
           mov eax,edx
           movzx ecx,cx

           mov di,xmins
           mov si,xmaxs1

           align 4
lineloop:
           shr edx,16             ; main line drawing loop!!!

           cmp dx,di
           jge s nou
           mov dx,di
nou:
           cmp dx,si
           jle s noq
           mov dx,si
noq:
           cmp dx,firstbyte[bx]   ; fix first and lastbyte table
           jge s ci1
           mov firstbyte[bx],dx
ci1:
           cmp dx,lastbyte[bx]
           jng s ci2
           mov lastbyte[bx],dx
ci2:
           add eax,ebp
           mov edx,eax
           add bx,2
           loop s lineloop
li_out:
           ret
sliver:
           mov cx,x1
           mov ax,y1
           call checkin           ; if off bottom of screen, never returns
           mov cx,x2
           mov ax,y1
checkin:                          ; cx,ax=x,y...
           cmp ax,ymaxs
           jge s ci9q
           cmp ax,ymins           ; clip to borders
           jl  s ci6q

           cmp cx,xmins
           jge s nouq
           mov cx,xmins
nouq:
           cmp cx,xmaxs
           jl s noqq
           mov cx,xmaxs1
noqq:
           mov bx,ax              ; bx pointer first/lastbyte table
           sub bx,ymins
           shl bx,1               ; bx now word
           cmp cx,firstbyte[bx]   ; fix first and lastbyte table
           jg s ci1q
           mov firstbyte[bx],cx
ci1q:
           cmp cx,lastbyte[bx]
           jng s ci6q
           mov lastbyte[bx],cx
ci6q:
           ret
ci9q:
           add esp,4              ; off bottom of screen, exit now!
           ret

; set new clipping parameters where center is in middle of points ax,bx cx,dx
; where points are absolutes! eg (10,10) (50,50) would be a small window in
; the top corner of the screen.

set_clip_absolute:

           mov si,cx             ; calc center based on points
           sub si,ax
           shr si,1
           add si,ax

           mov di,dx
           sub di,bx
           shr di,1
           add di,bx

           sub ax,si             ; now make points offset from center
           sub cx,si
           sub bx,di
           sub dx,di

; set new clipping parameters. does  all  pre-calculation   for  variables  and
; resets oney, firstbyte and lastbyte table.  si,di is center of screen.  ax,bx
; and cx,dx are topleft and botright points to clip to.  clipping will  include
; minimum clip variables but will exclude maximum clip variables.  eg -160,-100
; +160,+100, with center 160,100 are valid clip parameters.  points are offsets
; from center, not absolutes! this allows you to have the camera looking to the
; left or right of where the pilot/plane is moving  without  having  to  change
; the camera angle. note: this can only change slightly as  distortion  occures
; with too large an offset.  make sure to assemble the original file  with  the
; maximum y size you will ever need so tables are set to correct size.

set_clip_offset:
           mov bp,dx
           sub bp,bx
           cmp bp,ymax-ymin  ; check input parameters with assembley restraints
           jg you_must_assemble_original_file_with_larger_clipping_to_achieve_this

           mov xmins,ax
           mov xmaxs,cx
           mov ymins,bx
           mov ymaxs,dx
           mov xcent,si
           mov ycent,di

           mov cliptp,di
           add cliptp,bx

           mov ycentp1,di
           inc ycentp1

           mov ycents1,di
           dec ycents1

           mov clipbt,di
           add clipbt,dx
           dec clipbt

           mov cliplt,si
           add cliplt,ax

           mov cliprt,si
           add cliprt,cx
           dec cliprt

           mov xmaxxcent,si
           add xmaxxcent,cx

           mov ymaxycent,di
           add ymaxycent,dx

           mov xmins1,ax
           dec xmins1

           mov xmaxs1,cx
           dec xmaxs1

           mov ymins1,bx
           dec ymins1

           movsx eax,ax
           movsx ebx,bx
           movsx ecx,cx
           movsx edx,dx

           mov xmit,eax
           mov xmat,ecx
           mov ymit,ebx
           mov ymat,edx

           sub xmit,tolerance
           add xmat,tolerance
           sub ymit,tolerance
           add ymat,tolerance
you_must_assemble_original_file_with_larger_clipping_to_achieve_this:
           ret

           align 4

; update vector list based on traces_past
; i could have used a loop but shl ax,cl works faster
;
; what i am really doing is:
;
; for i = 1 to traces_past
;  call updvectors
; next i
;
; but instead i am shifting and adding (if bit present) for a faster method
; you get the idea right?
;
; this way, the slower the machine, the faster we move the objects to
; maintaine a universal speed from 486dx66 machine to 386sx33 machine

updvectors:
           mov bx, traces_past
           mov traces_past,0

           mov dx,1
           mov cl,0
up_loop:
           shr bl,1
           jnc not_call
           call updvectors2
not_call:
           shl dx,1                ; dx = 1,2,4,8..
           add cl,1                ; cx = 0,1,2,3,4,5,6...
           cmp bl,0                ; all bits clear?
           jne up_loop

           cmp wfollow,no          ; check if camera has reached follow object
           je s nretest            ; nothing to follow
           cmp eyeacount,0
           jne s nretest           ; not reached yet
           mov si,wfollow          ; looking at it, re-call newfollow
           mov di,oldspeed
           cmp di,0
           jne newfollow           ; re-calculate in case its accelerating

           jmp just_look_at_it_now_instead_of_calculating
nretest:
           ret

           align 4

updvectors2:                      ; update vector list - shifted by cl
                                  ; and dec'ed by dx
           i=0
           rept maxobjects+1      ; generate unrolled update loop
           local nupang, nuploc, nuder, nuuder

           cmp acount+i*2,0
           je s nupang
           sub acount+i*2,dx
           jnc s nuder
           mov acount+i*2,0
nuder:
           mov ax,vxadds+i*2      ; update angles
           shl ax,cl
           add ax,vxs+i*2
           mov vxs+i*2,ax

           mov ax,vyadds+i*2
           shl ax,cl
           add ax,vys+i*2
           mov vys+i*2,ax

           mov ax,vzadds+i*2
           shl ax,cl
           add ax,vzs+i*2
           mov vzs+i*2,ax
nupang:
           cmp lcount+i*2,0
           je s nuploc
           sub lcount+i*2,dx
           jnc s nuuder
           mov lcount+i*2,0
nuuder:
           mov eax,xadds+i*4       ; update position
           shl eax,cl
           add eax,xs+i*4
           mov xs+i*4,eax

           mov eax,yadds+i*4
           shl eax,cl
           add eax,ys+i*4
           mov ys+i*4,eax

           mov eax,zadds+i*4
           shl eax,cl
           add eax,zs+i*4
           mov zs+i*4,eax
nuploc:
           i=i+1
           endm

           ret

