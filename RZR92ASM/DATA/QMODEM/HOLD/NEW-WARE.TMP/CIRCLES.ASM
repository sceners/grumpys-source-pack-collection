           .286
           Assume Cs:_Code, Ds:_Code

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
_Stack Segment Para Stack 'Stack'
    db 512 dup (?)
_Stack EndS
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; The Externals
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Procedures:

EXTRN  INITIALIZE:FAR            ; Initializes the modplayer for given
                                 ; sounddevice and replayrate
EXTRN  LOADMODULE:FAR            ; Loads the Module into memory
EXTRN  STARTPLAYING:FAR          ; Starts playing the module
EXTRN  STOPPLAYING:FAR           ; Stops playing the module
EXTRN  DEALLOC:FAR               ; Deallocates and erases the module
                                 ; from memory
EXTRN  ASKINIT:FAR
Variables:
EXTRN  SOUNDDEVICE:WORD          ; The Sounddevice number
EXTRN  TIMERSPEED:WORD           ; The replayrate 1193182/Hertz
EXTRN  SBDMA:WORD                ; SoundBlaster's DMA-Channel
EXTRN  SBIRQNR:WORD              ; SoundBlaster's IRQ-Number

Special_Variables:
EXTRN  BAR1,BAR2,BAR3,BAR4:WORD  ; Selfdecrementing Bars, see the docs
EXTRN  SHOWPATTERNS:Word         ; Shows the patterns
EXTRN  MASTERVOLUME:Word         ; Mastervolume from 0 to 64

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
_Data  Segment Para Public 'Data'
       Filename db 'Digital.mod',0
_Data  EndS

_code      segment public

sinus      label word
           include sinus.db
cosinus    label word
           include cosinus.db
xvar       dw 0,0,0
yvar       dw 0,0,0
deg        dw 0,0,0
degadd     dw 1,1,1 ;2,3,5
dirup      dw 0,0,0
dirleft    dw 0,0,0
fillmin    dw 200 dup(-1)
fillmax    dw 200 dup(-1)
dac        label byte
           REPT 2
           i = 0
           REPT 64
           db 0,0,i
           i = i + 1
           ENDM
           i = 63
           REPT 64
           db 0,0,i
           i = i - 1
           ENDM
           ENDM
dac2       label byte
           i = 0
           REPT 64
           db 0,i,i
           i = i + 1
           ENDM
           i = 63
           REPT 64
           db 63-i,63,i
           i = i - 1
           ENDM
           i = 0
           REPT 64
           db 63,63-i,i
           i = i + 1
           ENDM
           i = 63
           REPT 64
           db i,i,i
           i = i - 1
           ENDM

calcoffs   macro     ;(x,y) = (cx,ax)
           mov bx,320
           mul bx
           add ax,cx
           endm

savedac    proc      near
           mov       dx,3c8h
           mov       al,0
           out       dx,al
           mov       cx,256
           mov       dx,3c9h
           sti
           push      ax
           push      cx
           push      dx
check:     mov       dx,3dah
           in        al,dx
           test      al,8
           jz        check
           pop       dx
           pop       cx
           pop       ax
step:      push      ax
           push      dx
           mov       dx,3dah
instep:    in        al,dx
           test      al,1
           jz        instep
           pop       dx
           pop       ax
           lodsb
           out       dx,al
           lodsb
           out       dx,al
           lodsb
           out       dx,al
           loop      step
           cli
           ret
savedac    endp


upgdegree  proc near
           push ax
           mov ax,cs:degadd[0]
           add cs:deg[0],ax
           cmp cs:deg[0],359
           jna deg1
           sub cs:deg[0],360
deg1:
           mov ax,cs:degadd[2]
           add cs:deg[2],ax
           cmp cs:deg[2],359
           jna deg2
           sub cs:deg[2],360
deg2:
           mov ax,cs:degadd[4]
           add cs:deg[4],ax
           cmp cs:deg[4],359
           jna deg3
           sub cs:deg[4],360
deg3:
           pop ax
           ret
upgdegree  endp

calcpoints proc near
           mov si,cs:deg[0]
           shl si,1
           mov cx,cs:sinus[si]
           mov ax,cs:cosinus[si]
           sar cx,2
           sar ax,2
           add cx,160
           add ax,100
           mov cs:xvar[0],cx
           mov cs:yvar[0],ax

           mov si,cs:deg[2]
           shl si,1
           mov dx,cs:sinus[si]
           mov bx,cs:cosinus[si]
           sar dx,3
           sar bx,3
           add dx,cx
           add bx,ax
           mov cs:xvar[2],dx
           mov cs:yvar[2],bx

           mov si,cs:deg[4]
           shl si,1
           mov cx,cs:sinus[si]
           mov ax,cs:cosinus[si]
           sar cx,4
           sar ax,4
           add cx,dx
           add ax,bx
           mov cs:xvar[4],cx
           mov cs:yvar[4],ax

           ret
calcpoints endp

fmax       proc near
           mov di,ax
           shl di,1
           cmp cs:fillmin[di],-1
           je fillminnow
           cmp cs:fillmin[di],cx
           jng dontmin
fillminnow:
           mov cs:fillmin[di],cx
dontmin:
           cmp cs:fillmax[di],-1
           je fillmaxnow
           cmp cs:fillmax[di],cx
           jg dontmax
fillmaxnow:
           mov cs:fillmax[di],cx
dontmax:
           ret
fmax       endp

fillrout   proc near
           mov di,0a000h
           mov es,di
           mov cx,200
frn:
           push cx
           mov si,cx
           dec si
           shl si,1
           cmp cs:fillmin[si],-1
           je frskip
           mov ax,cx
           dec ax
           mov cx,cs:fillmin[si]
           CALCOFFS
           mov di,ax
           mov cx,cs:fillmax[si]
           sub cx,cs:fillmin[si]
           inc cx
frnxtbt:
           inc byte ptr es:[di]
           inc di
           loop frnxtbt
           mov cs:fillmin[si],-1
           mov cs:fillmax[si],-1
frskip:
           pop cx
           loop frn
           ret
fillrout   endp

circle     proc near ; cx,ax = x,y   bx = radius   dl = color
           mov cs:x_add,cx
           mov di,0a000h
           mov es,di
           mov si,0
           mov bp,ax
cnext:
           push dx
           mov ax,cs:sinus[si]
           mul bx
           sar ax,8
           mov cx,ax
           add cx,cs:x_add
           mov ax,cs:cosinus[si]
           mul bx
           sar ax,8
           add ax,bp
           cmp ax,0
           jng notdot
           cmp ax,199
           jg notdot
           push bx
           call fmax
           inc ax
           call fmax
;           CALCOFFS
;           mov di,ax
           pop bx
           pop dx
;           mov es:[di],dl
           jmp contdot
notdot:
           pop dx
contdot:
           add si,2
           cmp si,720
           jne cnext
           ret
x_add      dw 0
circle     endp

block      proc near   ; cx,ax = x,y...
           CALCOFFS
           mov di,0a000h
           mov es,di
           mov di,ax
           mov cx,30
badd2:
           push cx
           mov cx,30
badd:
           inc byte ptr es:[di]
           inc di
           loop badd
           pop cx
           add di,290
           loop badd2
           ret
block      endp

updbadd    proc near
           mov di,0
bagain:
           mov ax,cs:dirleft[di]
           add cs:xvar[di],ax
           cmp cs:xvar[di],0
           jne not1
           mov cs:dirleft[di],1
not1:
           cmp cs:xvar[di],290
           jne not2
           mov cs:dirleft[di],-1
not2:
           mov ax,cs:dirup[di]
           add cs:yvar[di],ax
           cmp cs:yvar[di],0
           jne not3
           mov cs:dirup[di],1
not3:
           cmp cs:yvar[di],170
           jne not4
           mov cs:dirup[di],-1
not4:
           add di,2
           cmp di,6
           jne bagain
           ret
updbadd    endp

badder     proc near
           mov cs:xvar[0],0
           mov cs:xvar[2],100
           mov cs:xvar[4],200
           mov cs:yvar[0],100
           mov cs:yvar[2],0
           mov cs:yvar[4],100
           mov cs:dirup[0],1
           mov cs:dirup[2],1
           mov cs:dirup[4],1
           mov cs:dirleft[0],1
           mov cs:dirleft[2],1
           mov cs:dirleft[4],1

           mov cx,5000
bax:
           push cx
           mov ah,1
           int 16h
           call updbadd
           mov cx,cs:xvar[0]
           mov ax,cs:yvar[0]
           call block
           mov cx,cs:xvar[2]
           mov ax,cs:yvar[2]
           call block
           mov cx,cs:xvar[4]
           mov ax,cs:yvar[4]
           call block
           pop cx
           loop bax

           ret
badder     endp

start      proc near
       Mov  Ah,4Ah                ; Reduce program memory size
       Mov  Bx,50000/16           ; Approx. size of compiled EXEFILE / 16 + 2
       Int  21h

       Mov  Ax,_Data
       Mov  Ds,Ax

       Call Askinit              ; Ask for the setup
       Call Initialize           ; Initialize the SoundSystem

           mov ax,13h
           int 10h

       Mov  Dx,Offset FileName
       Call Loadmodule           ; Load the module

       Call StartPlaying         ; Roll it !
       Mov  Al,01111010b         ; Mask off all unneccesary interrupts.
       Out  21h,Al

           mov si,cs
           mov ds,si
           mov si,offset dac

           call savedac
           mov cx,3600
loop1:
           push cx
           mov ah,1
           int 16h
           call upgdegree
           call calcpoints
           mov cx,cs:xvar[0]
           mov ax,cs:yvar[0]
           mov bx,64
           mov dl,15
           call circle
           call fillrout
           mov cx,cs:xvar[2]
           mov ax,cs:yvar[2]
           mov bx,32
           mov dl,15
           call circle
           call fillrout
           mov cx,cs:xvar[4]
           mov ax,cs:yvar[4]
           mov bx,16
           mov dl,15
           call circle
           call fillrout

           mov di,0a000h
           mov es,di
           mov di,10000
           mov cx,22000
           xor ax,ax
           pop cx
           loop loop1

           mov ax,13h
           int 10h

           mov si,cs
           mov ds,si
           mov si,offset dac2
           mov cs:degadd[0],1
           mov cs:degadd[2],2
           mov cs:degadd[4],9
           call savedac
           mov cx,750
loop2:
           push cx
           mov ah,1
           int 16h
           call upgdegree
           call calcpoints
           mov cx,cs:xvar[0]
           mov ax,cs:yvar[0]
           mov bx,64
           mov dl,15
           call circle
           call fillrout
           mov cx,cs:xvar[2]
           mov ax,cs:yvar[2]
           mov bx,32
           mov dl,15
           call circle
           call fillrout
           mov cx,cs:xvar[4]
           mov ax,cs:yvar[4]
           mov bx,16
           mov dl,15
           call circle
           call fillrout
           mov di,0a000h
           mov es,di
           mov di,10000
           mov cx,22000
           xor ax,ax
           pop cx
           loop loop2

           mov ax,13h
           int 10h

           mov si,cs
           mov ds,si
           mov si,offset dac2
           call savedac
           call badder

           call stopplaying
           call dealloc

           mov ah,0h
           out 21h,al

           mov ax,4c00h
           int 21h
           ret
start      endp

_code      ends
           end start
