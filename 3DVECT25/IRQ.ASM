; irq handler for updating vector locations/angles
;
; this uses irq 8 set to the same speed as the vertical retrace so that
; an animation will remain at a smooth/constant speed regardless of the
; machine speed: eg, a 386SX33 will run an animation at the same  speed
; as a 486DX66, only the 386 will skip frames to compensate.all the irq
; really does is "inc traces_past" and this information is used to skip
; frames. if traces_past =1 is 486DX66, =4 is 386 or whatever.  you get
; the idea right?
;
; the irq can operate in real mode or pmode.  just call the appropiate
; routine.  i did this in case you want to add to  the  irq  your  own
; functions for sound or music or whatever.

        .386p

        public set_pmirq
        public reset_pmirq

        public set_rmirq
        public reset_rmirq

        public reset_raster_count
        public time_raster

        public frametime

        include 3d.inc
        include equ.inc

        pmodeirq equ 0  ; you could also use irq 8 for either of these.
        rmodeirq equ 0  ; both can run at the same time even if both=0.

code16  segment para public use16
        assume cs:code16, ds:code16

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
rmirq0:                                 ; real mode IRQ0 handler
        push ax ds

; put your real mode irq code here!!!!!
;--------------------------------------



;--------------------------------------

; now my code, this is where i inc that variable
; real mode irq increments protected mode memory location

        mov ax,cs:rfs
        mov ds,ax
        mov si,cs:rfo

        inc word ptr [si]               ; inc traces_past
        inc dword ptr [si+2]            ; inc frame_number

        pop ds
        mov al,20h
        out 20h,al
        pop ax

        iret

rfs     dw ?
rfo     dw ?

transfer_location:
        mov cs:rfs,cx                   ; set protected mode location of
        mov cs:rfo,dx                   ; traces_past in terms of real mode
        ret

code16  ends

code32  segment para public use32
        assume cs:code32, ds:code32

        include pmode.inc

ormirq0 dd ?                            ; old real mode IRQ handler seg:off
opmirq0 dd ?                            ; old protected mode IRQ handler off

pmirq0:                                 ; protected mode IRQ0 handler
        push ds

; put your protected mode irq code here!!!!!
;-------------------------------------------



;-------------------------------------------

; now my code, this is where i inc that variable
; protected mode version is easy!

        inc traces_past
        inc frame_number

        pop ds
        jmp cs:opmirq0                  ; chain to old IRQ0 redirector

set_rmirq:
        mov eax,gs:[rmodeirq*4]         ; save real mode IRQ0 vector
        mov ormirq0,eax

        cli                             ; set IRQ0 to inc variable

        mov word ptr gs:[rmodeirq*4],offset rmirq0  ; set real mode irq
        mov word ptr gs:[(rmodeirq*4)+2],code16

        mov edx,offset traces_past      ; tell real mode irq where traces_past
        add edx,_code32a                ; is in memory (pmode location)
        mov al,dl
        and ax,0fh
        shr edx,4
        mov v86r_cx,dx
        mov v86r_dx,ax

        mov cx,seg transfer_location
        mov dx,offset transfer_location
        int 32h

        sti

        jmp new_timer

reset_rmirq:
        cli

        mov eax,ormirq0                 ; restore old real mode IRQ0 vector
        mov gs:[rmodeirq*4],eax

        sti

        jmp old_timer

set_pmirq:
        xor bl,bl                       ; get protected mode IRQ0 redirector
        call _getirqvect
        mov opmirq0,edx

        cli                             ; set IRQ0 to inc variable

        mov bl,pmodeirq
        mov edx,offset pmirq0
        call _setirqvect                ; set protected mode irq

        sti

        jmp new_timer

reset_pmirq:
        cli

        mov bl,pmodeirq
        mov edx,opmirq0
        call _setirqvect

        sti

        jmp old_timer

new_timer:
        call time_raster

        cli
        mov al,36h
        out 43h,al
        mov ax,frametime               ; set irq 8 time to match raster time
        out 40h,al
        mov al,ah
        out 40h,al
        sti

        ret

old_timer:                             ; reset timer for exit
        cli
        mov al,36h
        out 43h,al

        mov ax,0
        out 40h,al
        out 40h,al

        sti

        ret

reset_raster_count:                    ; reset count before any animation loop
        cli
        mov traces_past,1
        mov frame_number,0
        sti
        ret

frametime dw 0

time_raster:
        cli
        mov dx, input_1        ; input# 1 reg
loop1:
        in al,dx               ; wait for vsync
        test al,8
        jnz loop1
loop2:
        in al,dx
        test al,8
        jz loop2

        mov al,36h             ; reset timer
        out 43h,al
        mov al,0
        out 40h,al
        mov al,0
        out 40h,al
loop3:
        in al,dx               ; wait for vsync
        test al,8
        jnz loop3
loop4:
        in al,dx
        test al,8
        jz loop4

        xor al,al              ; this calculation code courtesy future_crew
        out 43h,al             ; from mental.exe
        in al,40h
        mov ah,al
        in al,40h
        xchg al,ah
        neg ax
        shr ax,1
        mov frametime,ax

        sti
        ret

code32  ends
        end

