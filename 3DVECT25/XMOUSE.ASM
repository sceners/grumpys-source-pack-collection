         .386p
code32   segment para public use32
         assume cs:code32, ds:code32

         include pmode.inc       ; protected mode externals
         include xmode.inc  ; include externals for xmode routines
         include macros.inc
         include equ.inc

         public show_mouse
         public get_mouse_position
         public plot_mouse
         public instant_mouse
         public remove_mouse
         public mousex
         public mousey
         public mbuttons

; x-mode mouse routines in protected mode for 3d vectors source
;
; show_mouse (int x, int y)
; get_mouse_position
; plot_mouse
; remove_mouse
; instant_mouse
;
; after ploting mouse, sync_display is called to avoid flickering

mousewidth  equ 6
mouseheight equ 6

ismouse  db -1

mousemap:
         dw mousewidth,mouseheight
         db 9,9,9,9,9,0
         db 9,9,9,9,0,0
         db 9,9,9,9,0,0
         db 9,9,9,9,9,0
         db 9,0,0,9,9,9
         db 0,0,0,0,9,0

sm_stack  struc
                dd  ?   ; ebp
                dd  ?   ; caller
    setm_ypos   dw  ?   ; y pos of mouse
    setm_xpos   dw  ?   ; x pos of mouse
sm_stack  ends

show_mouse:
        push ebp
        call remove_mouse
        mov v86r_ax,0                   ; enable mouse
        mov al,33h
        int 33h
        mov ah,v86r_ah                  ; check if hardware/driver installed
        xor ah,255
        mov ismouse, ah
        jne sm_nomouse                  ; no mouse, exit

        mov ebp, esp                    ; set up stack frame
        mov cx, [ebp].setm_xpos
        mov dx, [ebp].setm_ypos

        mov v86r_ax,4                   ; position mouse
        mov v86r_cx,cx
        mov v86r_dx,dx
        int 33h

        mov v86r_ax,7                   ; set screen size
        mov v86r_cx,0
        mov v86r_dx,(xactual-mousewidth)*2
        int 33h                         ; *2 gives greater resolution!!!!!

        mov v86r_ax,8
        mov v86r_cx,0
        mov v86r_dx,(yactual-mouseheight)*2
        int 33h

        mov v86r_ax,15                  ; set mouse mickeys (8 = default)
        mov v86r_cx,8
        mov v86r_dx,8
        int 33h

sm_nomouse:
        mov firstcall,0                 ; first call to mouse routines, reset
        pop ebp
        ret 4

get_mouse_position:
        cmp ismouse,0
        jne gm_nomouse
        mov v86r_ax,3                   ; call bios routines
        mov al,33h
        int 33h
        mov bx,v86r_bx                  ; button status, mid right left=%111
        mov cx,v86r_cx                  ; coloum
        mov dx,v86r_dx                  ; row
        mov mbuttons,bx                 ; save button status
        shr cx,1                        ; compensate for resolution!!!
        shr dx,1
        mov mousex,cx
        mov mousey,dx
gm_nomouse:
        ret

; plot mouse at new location. must be called often because DOS fuctions cannot
; plot new mouse in x-mode and protected mode cannot handle re-routing of
; interrupt.  routine is slow but we must wait for a vga sync anyway.

savedmap  dw mousewidth,mouseheight
          db mousewidth*mouseheight dup (?)
mousex    dw 0
mousey    dw 0
mbuttons  dw 0
firstcall db 0

plot_mouse:
        cmp ismouse,0                   ; plot mouse may need modification
        jne pm_nomouse                  ; if used with page flipping, (save
                                        ; more than one page)
        call remove_mouse
        mov firstcall,1

        call get_mouse_position         ; get new mouse location

        mov bx, mouseheight             ; counters
        mov ax, mousewidth
        mov si, 4                       ; indexer to bitmap saved data

pl_morew:                               ; save data under new cursor
        pusha
        push cx dx
        call read_point
        mov b savedmap[si],al
        popa
        inc si
        inc cx
        dec ax
        cmp ax,0
        jne pl_morew

        inc dx
        mov cx,mousex
        mov ax,mousewidth
        dec bx
        cmp bx,0
        jne pl_morew

        push o mousemap
        pushw mousex
        pushw mousey
        call tdraw_bitmap               ; draw new mouse
pm_nomouse:
        call sync_display
        ret

instant_mouse:
        cmp ismouse,0
        jne im_nomouse

        call get_mouse_position         ; get new mouse location

        push o mousemap
        pushw mousex
        pushw mousey
        call tdraw_bitmap               ; draw new mouse
im_nomouse:
        ret

remove_mouse:
        cmp firstcall,0                ; check if mouse on screen
        je  pl_dontsave

        push o savedmap
        pushw mousex
        pushw mousey
        call draw_bitmap                ; restore old data under cursor
        mov firstcall,0                 ; mouse is gone, say so

pl_dontsave:
        ret

code32  ends
        end
