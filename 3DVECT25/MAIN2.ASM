           .386p

code32     segment para public use32
           assume cs:code32, ds:code32

; define externals

           include pmode.inc       ; protected mode externals
           include xmouse.inc      ; xmode mouse externals
           include xmode.inc       ; xmode externals by matt pritchard
           include 3d.inc
           include irq.inc

           include macros.inc
           include equ.inc

           include sphere.inc
           include gamecolr.inc    ; dac palette

           include objects.inc     ; table of shapes/colours
           include stuff.inc       ; ending screen stuff

           public _main

_main:
           sti

           push offset defpal
           call fadeoffpalette

           pushw xmode
           pushw xactual
           pushw yactual
           pushw pages
           call set_vga_modex
           cmp ax,-1               ; test for error in setting videomode
           jne getout

           call wipeoffpalette

           mov ax,0+0*256
           mov background,ax
           push ax
           call clear_vga_screen

          ;push offset gamecolr
          ;pushw 0
          ;pushw 255
          ;pushw 1
          ;call load_dac_registers

           call setupbase
           call initpages

           pushw xactual/2
           pushw yactual/2
           call show_mouse

comment $
           call flip_page    ; example of how to draw a single polygon

           p1x equ -50
           p1y equ -50
           p2x equ -90
           p2y equ 70
           p3x equ 60
           p3y equ 80

           mov x1,p1x
           mov y1,p1y
           mov x2,p2x
           mov y2,p2y
           call fakeline

           mov x1,p2x
           mov y1,p2y
           mov x2,p3x
           mov y2,p3y
           call fakeline

           mov x1,p3x
           mov y1,p3y
           mov x2,p1x
           mov y2,p1y
           call fakeline

           mov colq,7
           mov steel,-1
           call poly_fill

           call flip_page
$

           push o gamecolr
           call fadeonpalette

           mov si,cameraobject
           mov bx,0
           mov cx,0
           mov bp,0
           call set_angle
           mov ebx,100000
           mov ecx,25000
           mov ebp,-385000
           call put_object

           mov si,0
           mov ebx,-26000
           mov ecx,65000
           mov ebp,0
           call put_object
           call set_object_on
           mov ax,0
           call set_shape

           mov si,1
           mov ebx,130000
           mov ecx,0
           mov ebp,50000
           call put_object
           call set_object_on
           mov ax,1
           call set_shape

           mov si,2
           mov ebx,50000
           mov ecx,70000
           mov ebp,20000
           call put_object
           call set_object_on
           mov ax,2
           call set_shape

           mov si,3
           mov ebx,50000
           mov ecx,-50000
           mov ebp,80000
           call put_object
           call set_object_on
           mov ax,3
           call set_shape

           mov si,4
           mov ebx,-70000
           mov ecx,30000
           mov ebp,40000
           call put_object
           call set_object_on
           mov ax,4
           call set_shape

           mov si,5
           mov ebx,-50000
           mov ecx,-30000
           mov ebp,10000
           call put_object
           call set_object_on
           mov ax,5
           call set_shape

           mov si,6             ; bitmap
           mov ebx,-5000
           mov ecx,5000
           mov ebp,250000
           call put_object
           call set_object_on
           mov ax,0             ; zeroth bitmap
           call set_shape
           mov vxs[6*2],100     ; bitmap scaling (gets added to bitx and bity)
           mov vys[6*2],100     ; bitmap scaling
           mov userotate[6],32  ; it's a bitmap (32)

           mov vxadds[2*0],80   ; set objects spin velocity
           mov vyadds[2*0],320
           mov vzadds[2*0],231

           mov vxadds[2*1],100
           mov vyadds[2*1],230
           mov vzadds[2*1],122

           mov vxadds[2*2],200
           mov vyadds[2*2],590
           mov vzadds[2*2],410

           mov vxadds[2*3],320
           mov vyadds[2*3],290
           mov vzadds[2*3],340

           mov vxadds[2*4],570
           mov vyadds[2*4],320
           mov vzadds[2*4],400

           mov vxadds[2*5],570
           mov vyadds[2*5],320
           mov vzadds[2*5],200

           mov acount[2*0],9553  ; objects won't move or spin without counter!!
           mov acount[2*1],8223  ; if your objects don't move, think! did you
           mov acount[2*2],6323  ; set you counter!!, god this is frustrating
           mov acount[2*3],4423  ; when debuging.  counter is number of frames
           mov acount[2*4],3523  ; to move/rotate
           mov acount[2*5],5523

           mov si,0              ; follow first object
           mov di,65             ; 35 frames to get there
           call newfollow

           mov bitx,15           ; base object scaling
           mov bity,15
           mov bitbase,o sphere

           call set_pmirq        ; select irq:use one or the other
;          call set_rmirq

           call reset_raster_count   ; done before any animation loop!!!

;          call set_makeorder        ; reset sort order - done once in 3d1

ieox:
           call look_at_it           ; make camera look at selected object
           call setsincose           ; set rotation multipliers for eye
           call makeobjs             ; plot all objects in sides table

           call set_makeorder        ; reset sort order - done always in 3d2
           call sort_list            ; sort all sides/points/bitmaps
           call drawvect             ; draw vectors/bitmaps/points/lines

           call instant_mouse        ; plot mouse on screen

           call flip_page            ; flip video pages
           call clear_fill           ; clear video memory (last screen)
           call resetupd             ; reset borders
           call updvectors           ; move objects around, rotate them

           in al,60h                 ; test keyboard
           cmp al,1
           jne ieox
ieox2:
           in al,60h                 ; test keyboard
           cmp al,1
           je ieox2

           mov ax,w temp
           cmp ax,5
           jge ieox4

           inc w temp
           inc ax
           mov si,ax     ; ax = object
           mov di,65     ; di = time to get there (# of frames)
           call newfollow

           call reset_raster_count   ; done before any animation loop!!!
           jmp ieox
ieox4:
           call reset_raster_count   ; done before any animation loop!!!
ieox3:
           mov wherelook,5  ; force to look at sphered cube
           call look_at_it
           call setsincose
           call makeobjs

           call set_makeorder
           call sort_list
           call drawvect

           call flip_page
           call clear_fill
           call resetupd
           call updvectors

           sub zs[5*4],22000
           mov eax,zs[5*4]
           cmp eax,-3500000
           jg ieox3
getout:
;          call reset_rmirq  ; use one or the other, could use both if
           call reset_pmirq  ; needed but delete inc traces_past from pmode

           jmp endpage       ; jump to stuff.inc for ending

temp       dw 0            ; next object to look at, for this demo only

           public objbase  ; make sure these are here even if you don't
           public bitbase  ; use them.  tlink will fail if not present.
           public bitx
           public bity

numberofobjects equ 32       ; number of 3d objects available to display
numberofbitmaps equ 32       ; number of 3d bitmaps in data tables

objbase    dd numberofobjects*4 dup (0) ; memory locations of shapes
bitbase    dd numberofbitmaps*4 dup (0) ; memory locations of bitmaps
bitx       dd numberofbitmaps dup (0)   ; x size of bitmaps (for 3d)
bity       dd numberofbitmaps dup (0)   ; y size of bitmaps

code32     ends
           end
