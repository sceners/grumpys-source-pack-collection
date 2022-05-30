; macros used throughout

pushw      macro ww  ; push word, used for pushing constants
           mov ax,ww
           push ax
           endm

line       macro xx1,yy1,xx2,yy2,col
           pushw xx1
           pushw yy1
           pushw xx2
           pushw yy2
           pushw col
           call draw_line
           endm

block      macro xx1,yy1,xx2,yy2,col
           push xx1 yy1 xx2 yy2 col
           call fill_block
           endm

char       macro chr,xx,yy,fc ; plot character

           push ax bx cx dx
           mov ax,chr
           push ax
           mov ax,xx
           push ax
           mov ax,yy
           push ax
           mov ax,0
           push ax
           call tgprintc

           pop dx cx bx ax
           mov ax,chr
           push ax
           mov ax,xx
           add ax,1
           push ax
           mov ax,yy
           sub ax,1
           push ax
           mov ax,fc
           push ax
           call tgprintc
           endm

; macro to out a 16 bit value to an i/o port

out_16     macro register, value
           ifdifi <register>, <dx> ; if dx not setup
           mov dx, register        ; then select register
           endif
           ifdifi <value>, <ax>    ; if ax not setup
           mov ax, value           ; then get data value
           endif
           out dx, ax              ; set i/o register(s)
endm

; macro to out a 8 bit value to an i/o port

out_8      macro register, value
           ifdifi <register>, <dx> ; if dx not setup
           mov dx, register        ; then select register
           endif
           ifdifi <value>, <al>    ; if al not setup
           mov al, value           ; then get data value
           endif
           out dx, al              ; set i/o register
endm

; macros to push and pop multiple registers

pushx      macro r1, r2, r3, r4, r5, r6, r7, r8
           ifnb <r1>
           push r1                 ; save r1
           pushx r2, r3, r4, r5, r6, r7, r8
           endif
endm

popx       macro r1, r2, r3, r4, r5, r6, r7, r8
           ifnb <r1>
           pop r1                  ; restore r1
           popx r2, r3, r4, r5, r6, r7, r8
           endif
endm

; macro to clear registers to 0

clr        macro register, r2, r3, r4, r5, r6
           ifnb <register>
           xor register, register  ; set register = 0
           clr r2, r3, r4, r5, r6
           endif
endm

; macros to decrement counter & jump on condition

loopx      macro register, destination
           dec register            ; counter--
           jnz destination         ; jump if not 0
endm

loopjz     macro register, destination
           dec register            ; counter--
           jz destination          ; jump if 0
endm
