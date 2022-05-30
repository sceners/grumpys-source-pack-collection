           .286
           assume cs:_code, ds:_code

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
       Filename db 'BLOODM.MOD',0

       Error1   Db 13,10,10,7,'Module not found',13,10,'$'
       PlayMess Db 13,10,10,'Playing . . .',13,10
                Db 'Press ESCAPE to quit$'

_Data  EndS

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

_stack     segment stack 'stack' use16
           db 128 dup (0)
_stack     ends

double     segment use16
screen     db 65535 dup(0)
double     ends

_code      segment public use16
endscroll  db "-*- RAZOR 1911 PC DIVISION -*-" ; f썄ste sk몉mbillede...
           db "WAS PRESENTING: X-MAS '92 DEMO"
           db "                              "
           db "ALL CODING WAS DONE BY        "
           db "   EXCESSIVE KNIGHT <RZR/ACID>"
           db "                              "
           db "GRAPHICS & FONT WAS MADE BY   "
           db "       BLACK SPYRIT <RZR/ACID>"
           db "                              "
           db "THE VECTORS WAS DESIGNED BY   "
           db "   EXCESSIVE KNIGHT <RZR/ACID>"
           db "         THE RAPIST           "

           db "  THIS DEMO WAS CODED IN THE  "
           db " END OF THE YEAR 1992. IT WAS "
           db "  FINISHED AND PRESENTED AT   "
           db " THE PARTY 1992, IN AARS, DK  "
           db "                              "
           db " MUSIC BY INDEPENDENT ARTISTS "
           db "                              "
           db "    BASICALLY, THIS WAS A     "
           db "    'LAST-MINUTE' DEMO...     "

           db "    GREETINGS GOES OUT TO     "
           db "------------------------------"
           db "   P H O N E Y  C O D E R S   "
           db "        C A S C A D A         "
           db "      F A I R L I G H T       "
           db "     F U T U R E  C R E W     "
           db "     U L T R A F O R C E      "
           db "         T R I T O N          "
           db "           T R S I            "
           db "  T H E  H U M B L E  G U Y S "
           db "      S P A C E  P I G S      "
           db "   C O D E B L A S T E R S    "

           db "      PERSONAL GREETINGS      "
           db "------------------------------"
           db "  ALL DUDES FROM RAZOR 1911 PC"
           db "       ALL IN RAZOR 1911 AMIGA"
           db "                BITFREAK (TPC)"
           db "               MACRO NIT (FLT)"
           db "             MARSHAL (2000 AD)"
           db "           HARDGORE (AMBROSIA)"
           db "      JEFFE & ICEMAN (CASCADA)"
           db "------------------------------"
           db "   AND WE DIDN'T JUST GREET   "
           db "     EVERYBODY WE KNOW!!!     ",255
letternr   dw 0
ddac       db 768 dup(0)
boldfont   label byte
           include bold.db
dac        db 768 dup(0)
dac2       db 0,0,0,0,0,63
           i = 0
           REPT 64
           db i,0,0
           i = i + 1
           ENDM
           i = 63
           REPT 64
           db 0,0,i
           i = i - 1
           ENDM
           i = 63
           REPT 64
           db 0,i,0
           i = i - 1
           ENDM
           ; color 194
           db 51 dup(0)
           db 3 dup(64),3 dup(61),3 dup(58),3 dup(55)
           db 3 dup(52),3 dup(49),3 dup(46),3 dup(43)
           db 3 dup(40),3 dup(37),3 dup(34),3 dup(31)
           db 3 dup(28),3 dup(25),3 dup(22),3 dup(19)
           db 0,0,60,0,0,50,0,0,40,0,0,30,0,0,20
           ; color 232
           i = 20
           REPT 8
           db 0,i,i
           i = i + 6
           ENDM
           i = 63
           REPT 8
           db 0,0,i
           i = i - 5
           ENDM
           ; color 248
           db 63,0,0,   0,63,0,   0,0,63,   63,63,0,   63,0,63,   0,63,63,   63,63,63

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
           test      al,1
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

fontletter proc near               ; cx,ax = x,y     bh = color    dl = char
           mov si,cs
           mov ds,si
           mov si,offset boldfont
           add si,79
           push bx
           push dx
           CALCOFFS
           pop dx
           pop bx
           mov di,double
           mov es,di
           mov di,offset screen
           add di,ax
           mov ax,dx
           xor ah,ah
           shl ax,4
           add si,ax
           mov cx,16
flnext:
           lodsb
           test al,128
           je fl2
           mov es:[di],bh
fl2:
           test al,64
           je fl3
           mov es:[di+1],bh
fl3:
           test al,32
           je fl4
           mov es:[di+2],bh
fl4:
           test al,16
           je fl5
           mov es:[di+3],bh
fl5:
           test al,8
           je fl6
           mov es:[di+4],bh
fl6:
           test al,4
           je fl7
           mov es:[di+5],bh
fl7:
           test al,2
           je fl8
           mov es:[di+6],bh
fl8:
           test al,1
           je fl9
           mov es:[di+7],bh
fl9:
           add di,320
           inc bh
           loop flnext
           ret
fontletter endp

           ; ds:si = text
           ; cx,ax = x,y
           ; di = no. of chars
           ; bh = color
writestr   proc near
wsn:
           push cx
           push ax
           push ds
           push si
           push bx
           push di
           mov dl,ds:[si]
           call fontletter
           pop di
           pop bx
           pop si
           pop ds
           pop ax
           pop cx
           add cx,9
           inc si
           dec di
           cmp di,0
           jne wsn
           ret
writestr   endp

writescr   proc near
           mov si,_code
           mov ds,si
           mov si,offset endscroll
           add si,cs:letternr
           mov ax,4

           REPT 12
           mov cx,25
           push ax
           push si
           mov di,30
           mov bh,232
           call writestr
           pop si
           pop ax
           add si,30
           add ax,16
           ENDM
           ret
writescr   endp

enfade     proc near
           mov cx,64
xenun:
           push cx
           mov cx,700
xenun2:
           mov di,cx
           dec di
           cmp cs:ddac[di],0
           je xenup
           dec cs:ddac[di]
xenup:
           loop xenun2
           pop cx
           REPT 2
           mov ax,cs
           mov ds,ax
           mov si,offset ddac
           push cx
           call savedac
           pop cx
           ENDM
           loop xenun
           mov cx,64
sxenun:
           push cx
           mov cx,68
sxenun2:
           mov di,cx
           dec di
           add di,700
           cmp cs:ddac[di],0
           je sxenup
           dec cs:ddac[di]
sxenup:
           loop sxenun2
           pop cx
           REPT 5
           mov ax,cs
           mov ds,ax
           mov si,offset ddac
           push cx
           call savedac
           pop cx
           ENDM
           loop sxenun
           ret
enfade     endp

clearpiccy proc near
           mov di,double
           mov es,di
           mov di,offset screen
           mov cx,200
cpn:
           mov al,cl
           shr al,3
           add al,20
           push cx
           mov cx,320
           rep stosb
           pop cx
           loop cpn
           ret
clearpiccy endp

createpic  proc near
           mov di,0a000h
           mov es,di
           xor di,di
           mov si,double
           mov ds,si
           mov si,offset screen
           mov cx,101
cpx:
           push cx
           mov bp,99
           sub bp,cx
           mov ax,100
           sub ax,bp
           mov cx,320
           mul cx
           push di
           push si
           mov di,ax
           add si,ax
           mov cx,320
           rep movsb
           pop si
           pop di
           mov ax,100
           add ax,bp
           mov cx,320
           mul cx
           push di
           push si
           mov di,ax
           add si,ax
           mov cx,320
           rep movsb
           pop si
           pop di
           mov ax,99
           sub ax,bp
           mov cx,320
           mul cx
           push di
           push si
           mov di,ax
           add si,ax
           mov cx,320
           mov al,254
           rep stosb
           pop si
           pop di
           mov ax,101
           add ax,bp
           mov cx,320
           mul cx
           push di
           push si
           mov di,ax
           add si,ax
           mov cx,320
           mov al,254
           rep stosb
           pop si
           pop di
           pusha
           mov ax,8600h
           mov cx,0
           mov dx,20000
           int 15h
           popa
           pop cx
           loop cpx
           ret
createpic  endp

copydac    proc near
           mov di,_code
           mov ds,di
           mov es,di
           mov si,offset dac2
           mov di,offset dac
           mov cx,768
           rep movsb
           mov si,offset dac2
           mov di,offset ddac
           mov cx,768
           rep movsb
           ret
copydac    endp

start      proc near

       Mov  Ah,4Ah                ; Reduce program memory size
       Mov  Bx,120000/16           ; Approx. size of compiled EXEFILE / 16 + 2
       Int  21h

       Mov  Ax,_Data
       Mov  Ds,Ax

       Call Askinit              ; Ask for the setup
       Call Initialize           ; Initialize the SoundSystem

       Mov  Dx,Offset FileName
       Call Loadmodule           ; Load the module
       Jnc  NoError

       Mov  Ah,09h
       Lea  Dx,Error1
       Int  21h                  ; Print the error-message

       Mov  Ah,4Ch
       Int  21h                  ; Exit if error...
       NoError:

           mov ax,13h
           int 10h

       Call StartPlaying         ; Roll it !
       Mov  Al,01111010b         ; Mask off all unneccesary interrupts.
       Out  21h,Al



nscr:
           call copydac
           mov si,_code
           mov ds,si
           mov si,offset dac2
           call savedac

           call clearpiccy
           call writescr
           call createpic

           call enfade

           mov di,0a000h
           mov es,di
           xor di,di
           mov cx,32000
           mov ax,0
           rep stosw

           add cs:letternr,360
           mov si,cs:letternr
           cmp cs:endscroll[si],255
           jne nottt
           mov cs:letternr,0
nottt:
           in al,60h
           cmp al,127
           ja nscr

           mov al,0
           out 21h,al
           call stopplaying
           call dealloc

           mov ax,3
           int 10h

           mov ax,4c00h
           int 21h
           ret
start      endp

_code      ends
           end start
