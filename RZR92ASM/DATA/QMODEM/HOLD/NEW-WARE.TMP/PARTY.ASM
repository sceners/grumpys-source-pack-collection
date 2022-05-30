           .386
           assume cs:_code, ds:_code

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
_Stack Segment Para Stack 'Stack' use16
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
_Data  Segment Para Public 'Data' use16
       Filename db 'Odd.mod',0

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

_code      segment use16
           assume cs:_code, ds:_code
outnow     dw 0
scrollnr   dw 0
scrollcnt  dw 100
scroll     db 30,"  WELCOME TO THE PARTY 1992!  "
           db 30,"WHICH OF COURSE TAKES PLACE..."
           db 30,"    HERE IN AARS, DENMARK!    "
           db 30,"YEAH, BUT YOU MIGHT NOT LIKE A"
           db 30,"  LITTLE PATRIOTISM, SO LETS  "
           db 30,"      REMOVE THE FLAG...      ",90
           db 30,"    SO, HOW ABOUT THIS???     ",99,5,91
           db 30,"THIS MIGHT SEEM LIKE NOTHING..",81
           db 30,"   BUT WHAT ABOUT IT NOW???   "
           db 30," OW MY EYES - BETTER TAKE IT  ",90
           db 30,"AWAY...THE NEXT VECTOR WILL BE",99,10
           db 30,"   SOMETHING DIFFERENT.....   ",91
           db 30,"SHIT! I FORGOT TO TURN OFF THE"
           db 30,"    'GEL'-EFFECT....THERE!    ",80
           db 30,"   HEHE.....IS THIS BETTER?   ",90
           db 30,"    'DIAMONDS ARE FOREVER'    ",99,7,91
           db 30,"OR ARE THEY? WELL THIS ONE IS "
           db 30," NOT! LETS REPLACE IT WITH A  ",90
           db 30,"RUBINE....LETS PROCEED TO SOME",99,2,91
           db 30,"GREETINGS.....WHAT THE FUCK IS"
           db 30,"MY KEY DOING HERE???? I BETTER",81
           db 30,"GRAB IT, SO I DON'T LOSE IT...",90
           db 30,"GREETINGS GOES OUT TO.........",80,99,12,91
           db 30,"ALL RAZOR DUDES, ESPECIALLY A "
           db 30,"DUDE FROM ITALY, RANDALL FLAGG",90
           db 30,"HERE YOU GO, BUDDY............",99,11,91
           db 30,"AN ITALIAN FLAG ESPECIALLY 4 U",81
           db 30,"  GOT A LITTLE SHAKY, EHH???  ",90
           db 30,"ALSO GREETINGS TO:    CASCADA,",80,99,9,91
           db 30,"THE PHONEY CODERS, FUTURE CREW"
           db 30,"   CODEBLASTERS & FAIRLIGHT   ",90
           db 30,"  NOW THE RAZOR TRIANGLE....  ",99,4,91
           db 30,"   THAT WAS ALMOST THE MOST   "
           db 30,"MOST DIFFICULT OBJECT TO MAKE!",90
           db 30,"BUT ILL STOP WASTING YOUR TIME",99,13,91
           db 30,"LETS PROCEED TO THE FINAL PART"
           db 30,"RAZOR - KICKING ASS IN 1993!!!",91
           db 30,"                              "
           db 10 dup(255)
boldfont   label byte
           include bold.db
logo       label byte
           include party.db
sinus      label word
           include sinus.db
cosinus    label word
           include cosinus.db
ddac       db 768 dup(0)
dac        db 0,0,0,0,0,63
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
x1         dw 0
y1         dw 0
x2         dw 0
y2         dw 0
time       dw 0
xvcalc     dw 0
yvcalc     dw 0
biggest    db 0
xvars      dw 0,0,0,0,0
yvars      dw 0,0,0,0,0
firstbyte  dw 200 dup(320)
lastbyte   dw 200 dup(-1)
xupdate    dw 320,-1
yupdate    dw 200,-1
_xadd       dw 160
_yadd       dw 100
xaddsin    dw 0
yaddsin    dw 0
dacup      dw 0
dacdown    dw 0
the_list   dw 50 dup(0)
checked    dw 50 dup(0)
vx         dw 0
vy         dw 0
vz         dw 0
vxadd      dw 4
vyadd      dw 3
vzadd      dw 2
vxsec      dw 88
vysec      dw 45
vzsec      dw 55
           i = 0
putsins    dw 0
pson       db 0

color      db 0
vectors    dw 0
sides      dw 0
xnval      dw 120 dup(0)
ynval      dw 120 dup(0)
znval      dw 120 dup(0)
colordata  dw 120 dup(0)
colors     dw 120 dup(0)
bcolor     dw 0
xxval      dw 120 dup(0)
yyval      dw 120 dup(0)
zzval      dw 120 dup(0)
pairs      dw 480 dup(0)

plane      dw 96
dw 67
dw 64
dw 0,0,-2,0,2,0,-3,0,-3,0,0,-1,0,1,-1,0,1,0,-4,0,4,0,-4,4,4,-4,-7,7,7,-7,-7,-10
dw -7,-10,-10,-7,-10,-7,-10,-10,-10,-18,-18,-17,-17,-7,7,-7,7,-5,-3,-5,-3,-5,-3
dw -3,-5,3,5,3,5,3,5,5,3,7,10,10,7,7,7,10,10,10,18,18,17,17,10,10,-5,-3,-1,-3
dw -4,-3,-2,3,1,3,5,3,2,3,4,3
dw 0,0,0,2,0,-2,0,3,0,-3,3,2,5,2,2,5,2,3,0,3,0,-3,3,3,-3,-3,3,3,-3,-3,1,1,-1,-1
dw 1,1,-1,-1,0,0,-1,0,-1,0,-1,3,3,-3,-3,3,3,8,8,8,8,3,3,3,3,8,8,8,8,3,3,1,1,-1
dw -1,1,-1,1,-1,0,0,-1,0,-1,0,-1,0,2,0,-2,0,2,0,-2,0,2,0,-2,0,2,0,-2
dw 0,4,6,6,6,6,8,8,8,8,10,12,13,12,17,16,17,19,21,21,21,21,21,21,21,21,26,26,26
dw 26,26,28,26,28,40,40,40,40,28,39,39,40,40,42,42,41,41,41,41,30,30,36,36,40
dw 40,40,40,30,30,36,36,40,40,40,40,26,28,28,26,40,40,40,40,28,40,40,42,42,39
dw 39,41,41,41,41,45,45,45,45,41,41,41,41,45,45,45,45

dw 0,1,1,1
dw 1,2,3,3,1,3,4,4,1,4,5,5,1,5,2,2,2,6,7,3,3,7,4,8,5,4,8,9,9,6,2,5,11,12,10,10
dw 10,12,13,13,14,15,12,11,13,12,15,16,16,15,17,17,17,15,14,14,8,7,19,20,18,19
dw 7,6,9,8,20,21,21,18,6,9,22,26,27,23,23,27,28,24,25,24,28,29,26,22,25,29
dw 26,45,46,27,28,27,46,48,29,28,48,47,47,45,26,29,48,46,45,47,66,65,69,71,65,66
dw 67,68,67,66,71,72,72,71,69,70,72,70,68,67,67,73,74,75,75,74,76,77,77,76,78,79
dw 73,78,76,74,79,77,75,67,30,31,34,35,33,31,30,32,37,35,34,36,36,34,31,33,33,32
dw 37,36,38,41,43,39,40,39,43,44,44,43,41,42,41,38,33,42,40,44,42,33,80,84,85,81
dw 82,81,85,86,83,82,86,87,84,80,83,87,86,85,84,87,87,88,92,93,90,87,93,94,91,90
dw 94,95,95,92,88,91,94,93,92,95,49,51,52,50,51,53,54,52,50,52,54,55,56,53,51,49
dw 55,54,53,56,57,59,60,58,58,60,62,63,64,61,59,57,59,61,62,60,63,62,61,64
dw 67 dup(0)
special    dw 10
           dw 16
           dw 64
           dw -50,-70,-50,0,50,70,50,0,0,0
           dw 50,0,-50,-75,-50,0,50,75,0,0
           dw -40,40,-40,40,-40,40,-40,40,-20,20
           dw 0,2,1,1,   2,4,3,3,   4,6,5,5,   6,0,7,7
           dw 0,1,7,7,   2,3,1,1,   4,5,3,3,   6,7,5,5
           dw 0,8,2,2,   2,8,4,4,   4,8,6,6,   6,8,0,0
           dw 1,3,9,9,   3,5,9,9,   5,7,9,9,   7,1,9,9
           dw 16 dup(0)
italflag   dw 16
           dw 14
           dw 64
           dw -80,-80,-80,-80,80,80,80,80,-80,-80,-80,-80,80,80,80,80
           dw 50,17,-17,-50,-50,-17,17,50,50,17,-17,-50,-50,-17,17,50
           dw 8 dup(10),8 dup(-10)
           dw 0,1,6,7,   1,2,5,6,   2,3,4,5,   15,14,9,8,   14,13,10,9,   13,12,11,10
           dw 3,11,12,4,   8,0,7,15,   8,9,1,0,   9,10,2,1,   10,11,3,2
           dw 5,4,12,13,   6,5,13,14,   7,6,14,15
           dw 248,254,249, 248,254,249, 249,248, 248,254,249, 249,254,248
stick      dw 32
           dw 30
           dw 128
           dw -15,-25,-30,-30,-25,-15,-5,5,15,25,30,30,25,15,5,-5,-15,-25,-30,-30,-25,-15,-5,5,15,25,30,30,25,15,5,-5
           dw 25,15,5,-5,-15,-25,-30,-30,-25,-15,-5,5,15,25,30,30,25,15,5,-5,-15,-25,-30,-30,-25,-15,-5,5,15,25,30,30
           dw 120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,-120,-120,-120,-120,-120,-120,-120,-120,-120,-120,-120,-120,-120,-120,-120,-120
           dw 0,1,2,3,   15,0,3,4,   14,15,4,5,   13,14,5,6
           dw 12,13,6,7,   11,12,7,8,   8,9,10,11
           dw 27,26,25,24,   27,24,23,28,   28,23,22,29,   29,22,21,30
           dw 30,21,20,31,   31,20,19,16,   19,18,17,16
           dw 0,16,17,1,   1,17,18,2,   2,18,19,3,   3,19,20,4
           dw 4,20,21,5,   5,21,22,6,   6,22,23,7,   7,23,24,8
           dw 8,24,25,9,   9,25,26,10,   10,26,27,11,   11,27,28,12
           dw 12,28,29,13,   13,29,30,14,   14,30,31,15,   15,31,16,0
           dw 14 dup(248), 8 dup(253,250,249,251)
danishflag dw 32
           dw 24
           dw 64
           dw -80,-80,-80,-80,-40,-20,80,80,80,80,-20,-40,-40,-40,-20,-20,-80,-80,-80,-80,-40,-20,80,80,80,80,-20,-40,-40,-40,-20,-20
           dw 50,10,-10,-50,-50,-50,-50,-10,10,50,50,50,10,-10,-10,10,50,10,-10,-50,-50,-50,-50,-10,10,50,50,50,10,-10,-10,10
           dw 10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10
           dw 0,1,12,11,   2,3,4,13,   10,15,8,9,   14,5,6,7
           dw 27,28,17,16,   29,20,19,18,   23,22,21,30,   25,24,31,26
           dw 9,8,24,25,   7,6,22,23,   6,5,21,22,   4,3,19,20
           dw 3,2,18,19,   1,0,16,17,   0,11,27,16,   10,9,25,26
           dw 11,4,5,10,   1,2,7,8,   26,21,20,27,   24,23,18,17
           dw 8,7,23,24,   5,4,20,21,   2,1,17,18,   11,10,26,27
           dw 16 dup(248),8 dup(254)
key        dw 28
           dw 24
           dw 64
           dw -50,-50,-20,-20,0,-20,-20,0,-20,0,20,20,50,50,-50,-50,-20,-20,0,-20,-20,0,-20,0,20,20,50,50
           dw 115,35,35,5,-15,-35,-75,-95,-115,-125,-115,35,35,115,115,35,35,5,-15,-35,-75,-95,-115,-125,-115,35,35,115
           dw 10,10,10,10,5,5,5,5,5,10,10,10,10,10,-10,-10,-10,-10,-5,-5,-5,-5,-5,-10,-10,-10,-10,-10
           dw 14,15,1,0,   0,13,27,14,   13,12,26,27,   12,11,25,26
           dw 11,10,24,25,   10,9,23,24,   9,8,22,23,   8,7,21,22
           dw 7,6,20,21,   6,5,19,20,   5,4,18,19,   4,3,17,18
           dw 3,2,16,17,   2,1,15,16
           dw 0,1,12,13,   2,3,4,11,   4,5,6,7,   7,8,9,10,   4,7,10,11
           dw 27,26,15,14,   25,24,21,18,   24,23,22,21,   21,20,19,18,   18,17,16,25
           dw 24 dup(0)
           dw 14 dup(249),10 dup(250)
opencube   dw 8
           dw 10
           dw 64
           dw -70,-70,70,70,-70,-70,70,70
           dw 70,-70,-70,70,70,-70,-70,70
           dw 70,70,70,70,-70,-70,-70,-70
           dw 4,0,3,7,   0,1,2,3,   7,6,5,4,   3,2,6,7,   4,5,1,0
           dw 0,4,7,3,   3,2,1,0,   4,5,6,7,   7,6,2,3,   0,1,5,4
           dw 0,0,0,0,0,0,0,0
pyramid    dw 4
           dw 4
           dw 64
           dw -80,0,80,0
           dw 40,-88,40,0
           dw 40,40,40,-88
           dw 0,1,3,0,   0,3,2,0,   3,1,2,3,   2,1,0,2
           dw 0,0,0,0
cube       dw 8
           dw 6
           dw 64
           dw -70,-70,70,70,-70,-70,70,70
           dw 70,-70,-70,70,70,-70,-70,70
           dw 70,70,70,70,-70,-70,-70,-70
           dw 0,1,2,3,   7,6,5,4,   3,2,6,7
           dw 4,5,1,0,   4,0,3,7,   1,5,6,2
           dw 0,0,0,0,0,0
splitcube  dw 16
           dw 12
           dw 64
           dw -70,-70,70,70,-70,-70,70,70,-70,-70,70,70,-70,-70,70,70
           dw 70,-70,-70,70,70,-70,-70,70,70,-70,-70,70,70,-70,-70,70
           dw 70,70,70,70,20,20,20,20,-20,-20,-20,-20,-70,-70,-70,-70
           dw 0,1,2,3,   7,6,5,4,   3,2,6,7,   4,5,1,0,   4,0,3,7,   1,5,6,2
           dw 8,9,10,11, 15,14,13,12, 11,10,14,15, 12,13,9,8, 9,13,14,10, 12,8,11,15
           dw 12 dup(0)
star       dw 10
           dw 16
           dw 64
           dw -20,20,20,-20,-100,0,100,0,0,0
           dw -20,-20,20,20,0,-100,0,100,0,0
           dw 0,0,0,0,0,0,0,0,-100,100
           dw 0,5,9,0,   5,1,9,5,   9,1,6,9,   9,6,3,9
           dw 7,9,3,7,   2,9,7,2,   4,9,2,4,   4,0,9,4
           dw 0,8,5,0,   5,8,1,5,   8,6,1,8,   8,3,6,8
           dw 7,3,8,7,   2,7,8,2,   4,2,8,4,   4,8,0,4
           dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diamond    dw 13
           dw 17
           dw 64
           dw -100,-100,-50,50,100,100,50,-50,-50,-50,50,50,0
           dw 50,-50,-100,-100,-50,50,100,100,50,-50,-50,50,0
           dw 0,0,0,0,0,0,0,0,40,40,40,40,-120
           dw 0,1,9,8,   9,2,3,10,   11,10,4,5,   7,8,11,6,  1,2,9,1
           dw 10,3,4,10,   6,11,5,6,   0,8,7,0,   8,9,10,11
           dw 7,12,0,7,   0,12,1,0,   1,12,2,1,   2,12,3,2
           dw 3,12,4,3,   4,12,5,4,   5,12,6,5,   6,12,7,6
           dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
rubine     dw 16
           dw 18
           dw 64
           dw -100,-100,-50,50,100,100,50,-50,-50,-50,50,50,-50,-50,50,50
           dw 50,-50,-100,-100,-50,50,100,100,50,-50,-50,50,50,-50,-50,50
           dw 0,0,0,0,0,0,0,0,40,40,40,40,-40,-40,-40,-40
           dw 0,1,9,8,   9,2,3,10,   11,10,4,5,   7,8,11,6,  1,2,9,1
           dw 10,3,4,10,   6,11,5,6,   0,8,7,0,   8,9,10,11
           dw 5,4,14,15,   14,3,2,13,   12,13,1,0,   6,15,12,7,   4,3,14,4
           dw 13,2,1,13,   7,12,0,7,   5,15,6,5,   15,14,13,12
           dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
cubehole   dw 24
           dw 16
           dw 64
           dw -80,-80, 80, 80,-80,-80, 80, 80,-40,-40, 40, 40,-80,-80, 80, 80,-80,-80, 80, 80,-40,-40, 40, 40
           dw  80,-80,-80, 80, 40,-40,-40, 40, 40,-40,-40, 40, 80,-80,-80, 80, 40,-40,-40, 40, 40,-40,-40, 40
           dw  40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40,-40,-40,-40,-40,-40,-40,-40,-40,-40,-40,-40,-40
           dw 0,4,7,3,   4,5,9,8,   5,1,2,6,   11,10,6,7
           dw 0,3,15,12,   3,2,14,15,   2,1,13,14,   1,0,12,13
           dw 8,9,21,20,   9,10,22,21,   10,11,23,22,   11,8,20,23
           dw 15,19,16,12,   18,14,13,17,   19,18,22,23,   20,21,17,16
           dw 4 dup(250),4 dup(0),4 dup(0),4 dup(250)
ring       dw 32
           dw 32
           dw 64
           dw -40,-80,-80,-40,40,80,80,40,   -40,-40,-20,20,40,40,20,-20,-40,-80,-80,-40,40,80,80,40,   -40,-40,-20,20,40,40,20,-20
           dw 80,40,-40,-80,-80,-40,40,80,   20,-20,-40,-40,-20,20,40,40,80,40,-40,-80,-80,-40,40,80,   20,-20,-40,-40,-20,20,40,40
           dw 30,30,30,30,30,30,30,30,40,40,40,40,40,40,40,40,-30,-30,-30,-30,-30,-30,-30,-30,-40,-40,-40,-40,-40,-40,-40,-40
           dw 1,8,15,0,   2,9,8,1,   3,10,9,2,   4,11,10,3
           dw 5,12,11,4,   6,13,12,5,   7,14,13,6,   0,15,14,7
           dw 0,16,17,1,   1,17,18,2,   2,18,19,3,   3,19,20,4
           dw 4,20,21,5,   5,21,22,6,   6,22,23,7,   7,23,16,0
           dw 9,25,24,8,   10,26,25,9,   11,27,26,10,   12,28,27,11
           dw 13,29,28,12,   14,30,29,13,   15,31,30,14,   8,24,31,15
           dw 17,24,25,18,   18,25,26,19,   19,26,27,20,   20,27,28,21
           dw 21,28,29,22,   22,29,30,23,   23,30,31,16,   16,31,24,17
           dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
objbase    dw 50 dup(0)

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
           mov di,0a000h
           mov es,di
           mov di,ax
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


sort_list  proc near
           mov cx,cs:sides
nextentry:
           mov si,cx
           dec si
           shl si,3
           mov bx,cs:pairs[si]
           shl bx,1
           mov ax,cs:znval[bx]
           mov di,ax                    ; max
           mov bp,ax                    ; min
           mov dx,ax                    ; added
           mov bx,cs:pairs[si+2]
           shl bx,1

           cmp di,cs:znval[bx]
           jg blx1
           mov di,cs:znval[bx]
blx1:
           cmp bp,cs:znval[bx]
           jng btx1
           mov bp,cs:znval[bx]
btx1:
           add dx,cs:znval[bx]
           cmp cs:znval[bx],ax
           jg ent2
           mov ax,cs:znval[bx]
ent2:
           mov bx,cs:pairs[si+4]
           shl bx,1

           cmp di,cs:znval[bx]
           jg blx2
           mov di,cs:znval[bx]
blx2:
           cmp bp,cs:znval[bx]
           jng btx2
           mov bp,cs:znval[bx]
btx2:
           add dx,cs:znval[bx]
           cmp cs:znval[bx],ax
           jg ent3
           mov ax,cs:znval[bx]
ent3:
           mov bx,cs:pairs[si+6]
           shl bx,1

           cmp di,cs:znval[bx]
           jg blx3
           mov di,cs:znval[bx]
blx3:
           cmp bp,cs:znval[bx]
           jng btx3
           mov bp,cs:znval[bx]
btx3:
           add dx,cs:znval[bx]
           cmp cs:znval[bx],ax
           jg ent4
           mov ax,cs:znval[bx]
ent4:
           mov si,cx
           dec si
           mov bx,cs:bcolor
           sub di,bp
           sar di,1
           sub bx,di
;           mov bx,dx
;           sar bx,3
;           neg bx
;           add bx,32
           mov di,si
           shl si,1
           mov cs:checked[si],ax        ; checked[] = max. z-val in side
           mov cs:the_list[si],di       ; the_list[] = min->max (fx. 0-7)
           cmp cs:colordata[si],0
           jne nexxxx
           mov cs:colors[si],bx
           jmp nexxx
nextentryxxx:
           jmp nextentry
nexxxx:
           mov bx,cs:colordata[si]
           mov cs:colors[si],bx
nexxx:
           loop nextentryxxx
           mov cx,cs:sides
nextcx:
           dec cx
           mov dx,cx
nextdx:
           dec dx

           mov si,cx
           shl si,1
           mov di,dx
           shl di,1
           mov ax,cs:checked[di]
           cmp ax,cs:checked[si]
           jng donothing
           xchg ax,cs:checked[si]
           xchg ax,cs:checked[di]
           mov ax,cs:the_list[di]
           xchg ax,cs:the_list[si]
           xchg ax,cs:the_list[di]
           mov ax,cs:colors[di]
           xchg ax,cs:colors[si]
           xchg ax,cs:colors[di]
donothing:
           cmp dx,0
           jne nextdx
           cmp cx,1
           jne nextcx
           ret
sort_list  endp

resetupd   proc near
           mov cs:xupdate[0],200
           mov cs:xupdate[2],-1
           mov cs:yupdate[0],320
           mov cs:yupdate[2],-1
           ret
resetupd   endp

cleardbl   proc near
           cld
           cmp cs:yupdate[0],200
           je clout
           mov di,double
           mov es,di
           mov di,offset screen

           mov cx,cs:xupdate[0]
           mov ax,cs:yupdate[0]
           CALCOFFS
           add di,ax

           mov cx,cs:yupdate[2]
           sub cx,cs:yupdate[0]
           inc cx
           mov bx,cs:xupdate[2]
           sub bx,cs:xupdate[0]
           inc bx
cl1:
           push cx
           mov cx,bx
           mov al,0
           rep stosb
           pop cx
           add di,320
           sub di,bx
           loop cl1
clout:
           ret
cleardbl   endp

updsins    proc near
           mov ax,cs:putsins
           add ax,18
           cmp ax,359
           jna nxttt
           sub ax,360
nxttt:
           mov cs:putsins,ax
           ret
updsins    endp

copydbl    proc near
           cld
           cmp cs:yupdate[0],200
           je coout
           mov si,double
           mov ds,si
           mov si,offset screen

           mov di,0a000h
           mov es,di
           mov di,0
           mov bp,0

           mov cx,cs:xupdate[0]
           mov ax,cs:yupdate[0]
           CALCOFFS
           add di,ax
           add si,ax

           mov cx,cs:yupdate[2]
           sub cx,cs:yupdate[0]
           inc cx
           mov bx,cs:xupdate[2]
           sub bx,cs:xupdate[0]
           inc bx
           mov dx,cs:putsins
co1:
           push cx
           mov cx,bx


           cmp cs:pson,1
           jne cdblcont
           pusha
           call updsins
           popa
           push si
           mov si,cs:putsins
           shl si,1
           mov bp,cs:sinus[si]
           sar bp,6
           pop si
cdblcont:
           add di,bp
           rep movsb
           sub di,bp
           pop cx
           add di,320
           add si,320
           sub di,bx
           sub si,bx
           loop co1
coout:
           mov cs:putsins,dx
           call updsins
           call updsins
           ret
copydbl    endp


                                        ; vector rotation procedure
                                        ; clock cycles used:
                                        ; 80286: 465          80386: 264
                                        ; BX = X   CX = Y   BP = Z
rotate     proc near
                                        ; X-rotation
                                        ; Y := cos(vx) * y - sin(vx) * z
                                        ; Z := sin(vx) * y + cos(vx) * z
           mov si,cs:vx
           shl si,1                     ; si = angle x
           mov ax,cs:cosinus[si]        ; ax = cosinus(angle x)
           imul cx                      ; ax = cos(angle x) * y
           mov di,ax                    ; store for later use
           mov ax,cs:sinus[si]          ; ax = sinus(angle x)
           imul bp                      ; ax = sin(angle x) * z
           sub di,ax                    ; di = di-ax = cos(vx)*y - sin(vz)*z
           sar di,8                     ; remove the (co)sin "256-factor"
           mov es,di                    ; es = x-coordinate

           mov ax,cs:sinus[si]          ; ax = sinus(angle x)
           imul cx                      ; ax = sin(angle x) * y
           mov di,ax
           mov ax,cs:cosinus[si]        ; ax = cosinus(angle x)
           imul bp                      ; ax = cos(angle x) * z
           add di,ax                    ; di = di-ax = sin(vx)*y + cos(vx)*z
           sar di,8                     ; remove the (co)sin "256-factor"

           mov cx,es                    ; update y
           mov bp,di                    ; update z

                                        ; Y-rotation
                                        ; X :=  cos(vy) * xc + sin(vy) * zc
                                        ; Z := -sin(vy) * xc + cos(vy) * zc
           mov si,cs:vy
           shl si,1                     ; si = angle y
           mov ax,cs:cosinus[si]        ; ax = cosinus(angle y)
           imul bx                      ; ax = cos(angle y) * x
           mov di,ax
           mov ax,cs:sinus[si]          ; ax = sin(angle y)
           imul bp                      ; ax = sin(angle y) * z
           add di,ax                    ; di = di+ax = cos(vy)*x + sin(vy)*z
           sar di,8                     ; remove the (co)sin "256-factor"
           mov es,di                    ; es = x-coordinate

           mov ax,cs:sinus[si]          ; ax = sinus(angle y)
           neg ax                       ; ax = -sinus(angle y)
           imul bx                      ; ax = -sin(angle y) * x
           mov di,ax
           mov ax,cs:cosinus[si]        ; ax = cosinus(angle y)
           imul bp                      ; ax = cos(angle y) * z
           add di,ax                    ; di = di-ax = sin(vy)*x - cos(vy)*z
           sar di,8                     ; remove the (co)sin "256-factor"

           mov bx,es                    ; update x
           mov bp,di                    ; update z

                                        ; Z-rotation
                                        ; X := cos(vz) * xc - sin(vz) * yc
                                        ; Y := sin(vz) * xc + cos(vz) * yc
           mov si,cs:vz
           shl si,1                     ; si = angle z
           mov ax,cs:cosinus[si]        ; ax = cosinus(angle z)
           imul bx                      ; ax = cos(angle z) * x
           mov di,ax
           mov ax,cs:sinus[si]          ; ax = sinus(angle z)
           imul cx                      ; ax = sin(angle z) * y
           sub di,ax                    ; di = di-ax = cos(vz)*x - sin(vz)*y
           sar di,8                     ; remove the (co)sin "256-factor"
           mov es,di                    ; es = x-coordinate

           mov ax,cs:sinus[si]          ; ax = sinus(angle z)
           imul bx                      ; ax = sin(angle z) * x
           mov di,ax
           mov ax,cs:cosinus[si]        ; ax = cosinus(angle z)
           imul cx                      ; ax = cos(angle z) * y
           add di,ax                    ; di = di+ax = sin(vz)*x+cos(vz)*y
           sar di,8                     ; remove the (co)sin "256-factor"

           mov bx,es                    ; update x
           mov cx,di                    ; update y

           ret
rotate     endp

                                        ; checks if a side is visible
                                        ; clock cycles used:
                                        ; 286: 66   386: 38
                                        ; DI, SI, DX = x's
                                        ; BP, DS, ES = y's
                                        ; return: cx register...
                                        ; cx > 0: side visible...else not...
checkfront proc near
           cmp di,si
           jng cfc
           mov ax,di
           mov di,si
           mov si,dx
           mov dx,ax
           mov ax,bp
           mov bp,ds
           mov bx,es
           mov ds,bx
           mov es,ax
cfc:
           cmp di,si
           jng cfc2
           mov ax,di
           mov di,si
           mov si,dx
           mov dx,ax
           mov ax,bp
           mov bp,ds
           mov bx,es
           mov ds,bx
           mov es,ax
cfc2:
           mov ax,dx                    ; ax = x3
           sub ax,di                    ; ax = x3 - x1
           mov bx,ds                    ; bx = y2
           sub bx,bp                    ; bx = y2 - y1
           imul bx                      ; ax = (x3-x1)*(y2-y1)
           mov cx,ax                    ; save it...
           mov ax,si                    ; ax = x2
           sub ax,di                    ; ax = x2 - x1
           mov bx,es                    ; bx = y3
           sub bx,bp                    ; bx = y3 - y1
           imul bx                      ; ax = (x2-x1)*(y3-y1)
           sub cx,ax                    ; cx = (x3-x1)*(y2-y1)-(x2-x1)*(y3-y1)
           ret
checkfront endp

bigger     proc near
           push bx
           push bp
           cmp bx,0h
           jg big1
           neg bx
big1:
           cmp bp,0h
           jg big2
           neg bp
big2:
           cmp bx,bp
           jng bigr1
           mov cs:biggest,0
           pop bp
           pop bx
           cmp bx,0h
           jg bigx1
           neg bx
           neg bp
           mov ax,cs:x1
           mov cx,cs:x2
           mov cs:x1,cx
           mov cs:x2,ax
           mov ax,cs:y1
           mov cx,cs:y2
           mov cs:y1,cx
           mov cs:y2,ax
bigx1:
           jmp bigend
bigr1:
           mov cs:biggest,1
           pop bp
           pop bx
           cmp bp,0h
           jg bigx2
           neg bx
           neg bp
           mov ax,cs:x1
           mov cx,cs:x2
           mov cs:x1,cx
           mov cs:x2,ax
           mov ax,cs:y1
           mov cx,cs:y2
           mov cs:y1,cx
           mov cs:y2,ax
bigx2:
bigend:
           ret
bigger     endp

putpixel   macro x,y,col
           push bx
           CALCOFFS
           pop bx
           mov di,ax
           add di,offset screen
           mov al,col
           stosb
           endm

checkin    proc near ; cx,ax=x,y.....
           push bx
           mov bx,ax
           add bx,bx
           cmp cx,cs:firstbyte[bx]
           jg ci1
           mov cs:firstbyte[bx],cx
ci1:
           cmp cx,cs:lastbyte[bx]
           jng ci2
           mov cs:lastbyte[bx],cx
ci2:
           cmp cx,cs:xupdate[0]
           jg ci3
           mov cs:xupdate[0],cx
           sub cs:xupdate[0],8
ci3:
           cmp cx,cs:xupdate[2]
           jng ci4
           mov cs:xupdate[2],cx
           add cs:xupdate[2],8
ci4:
           cmp ax,cs:yupdate[0]
           jg ci5
           mov cs:yupdate[0],ax
           sub cs:yupdate[0],8
ci5:
           cmp ax,cs:yupdate[2]
           jng ci6
           mov cs:yupdate[2],ax
           add cs:yupdate[2],8
ci6:
           pop bx
           ret
checkin    endp

line       proc near
           mov di,double
           mov es,di
           mov bx,cs:x2
           sub bx,cs:x1
           mov bp,cs:y2
           sub bp,cs:y1
           cmp bx,0
           jne lineproceed
           cmp bp,0
           jne lineproceed
           mov cx,cs:x1
           mov ax,cs:y1
           call checkin
;           putpixel cx,ax,cs:color
           jmp lineend
lineproceed:
           call bigger

           cmp cs:biggest,0
           jne drawy

           mov si,bx
           inc si

           mov cx,si
l1:
           push cx
           dec cx
           mov ax,bp
           imul cx
           idiv bx
           add ax,cs:y1
           add cx,cs:x1
           call checkin
;           putpixel cx,ax,cs:color
           pop cx
           loop l1
           jmp lineend
drawy:
           mov si,bp
           inc si

           mov cx,si
l2:
           push cx
           push ax
           dec cx
           mov ax,bx
           imul cx
           idiv bp
           xchg ax,cx
           add ax,cs:y1
           add cx,cs:x1
           call checkin
;           putpixel cx,ax,cs:color
           pop ax
           pop cx
           loop l2
lineend:
           ret
line       endp

newfill    proc near
           mov di,double
           mov es,di
           cld
           mov cx,200
nf1:
           mov bp,cx
           mov si,cx
           dec si
           add si,si
           cmp cs:firstbyte[si],320
           je nf2
           mov cx,cs:firstbyte[si]
           mov ax,bp
           CALCOFFS
           mov di,ax
           add di,offset screen
           mov cx,cs:lastbyte[si]
           sub cx,cs:firstbyte[si]
           inc cx
           mov al,cs:color
           rep stosb
           mov cs:lastbyte[si],-1
           mov cs:firstbyte[si],320
           mov cx,bp
nf2:
           loop nf1
           ret
newfill    endp

                                        ; makes side of vector...
makeside   proc near                    ; di = x-values, si = y..., cx = vectors
           push cx
           push di
           push si
           mov ax,cs:[di]
           push ax
           mov ax,cs:[di+2]
           push ax
           mov ax,cs:[di+4]
           push ax
           mov ax,cs:[si]
           push ax
           mov ax,cs:[si+2]
           push ax
           mov ax,cs:[si+4]
           push ax
           pop es
           pop ds
           pop bp
           pop dx
           pop si
           pop di
           call checkfront
           mov ax,cx
           pop si
           pop di
           pop cx
           cmp ax,0
           jng mout
           mov cs:xvcalc,0
           mov cs:yvcalc,0
msnext:
           push si
           push di
           push cx
           mov bx,cx
           dec bx
           shl bx,1
           mov ax,cs:[di+bx]
           add cs:xvcalc,ax
           mov cs:x1,ax
           mov ax,cs:[di+bx+2]
           mov cs:x2,ax
           mov ax,cs:[si+bx]
           add cs:yvcalc,ax
           mov cs:y1,ax
           mov ax,cs:[si+bx+2]
           mov cs:y2,ax
           mov ax,cs:_xadd
           add cs:x1,ax
           add cs:x2,ax
           mov ax,cs:_yadd
           add cs:y1,ax
           add cs:y2,ax
           call line
           pop cx
           pop di
           pop si
           loop msnext
           call newfill
mout:
           ret
makeside   endp

rotvectors proc near
           mov cx,cs:vectors
rva:
           push cx
           mov si,cx
           dec si
           shl si,1
           mov bx,cs:xxval[si]
           mov cx,cs:yyval[si]
           mov bp,cs:zzval[si]
           push si
           call rotate
           pop si
           sar bx,1
           sar cx,1
           sar bp,1
           mov cs:xnval[si],bx
           mov cs:ynval[si],cx
           mov cs:znval[si],bp
           pop cx
           loop rva
           ret
rotvectors endp

drawvect   proc near
           mov cx,cs:sides
dsa:
           push cx
           mov si,cx
           dec si
           shl si,1
           mov ax,cs:colors[si]
           mov cs:color,al
           mov si,cs:the_list[si]
           shl si,3

           mov di,cs:pairs[si]
           shl di,1
           mov ax,cs:xnval[di]
           mov cs:xvars[0],ax
           mov cs:xvars[8],ax
           mov ax,cs:ynval[di]
           mov cs:yvars[0],ax
           mov cs:yvars[8],ax

           mov di,cs:pairs[si+2]
           shl di,1
           mov ax,cs:xnval[di]
           mov cs:xvars[2],ax
           mov ax,cs:ynval[di]
           mov cs:yvars[2],ax

           mov di,cs:pairs[si+4]
           shl di,1
           mov ax,cs:xnval[di]
           mov cs:xvars[4],ax
           mov ax,cs:ynval[di]
           mov cs:yvars[4],ax

           mov di,cs:pairs[si+6]
           shl di,1
           mov ax,cs:xnval[di]
           mov cs:xvars[6],ax
           mov ax,cs:ynval[di]
           mov cs:yvars[6],ax

           mov di,offset xvars
           mov si,offset yvars
           mov cx,4
           call makeside
           pop cx
           jmp dsaaa
dsaa:
           jmp dsa
dsaaa:
           loop dsaa
           ret
drawvect   endp

updvectors proc near
           mov ax,cs:vxadd
           add cs:vx,ax
           cmp cs:vx,359
           jna sdf
           sub cs:vx,360
sdf:
           mov ax,cs:vyadd
           add cs:vy,ax
           cmp cs:vy,359
           jna dfy
           sub cs:vy,360
dfy:
           mov ax,cs:vzadd
           add cs:vz,ax
           cmp cs:vz,359
           jna dfyz
           sub cs:vz,360
dfyz:
           add cs:xaddsin,2
           cmp cs:xaddsin,359
           jna dfsyz
           sub cs:xaddsin,360
dfsyz:
           add cs:yaddsin,1
           cmp cs:yaddsin,359
           jna dfsyzg
           sub cs:yaddsin,360
dfsyzg:
           mov bx,cs:xaddsin
           shl bx,1
           mov ax,cs:sinus[bx]
           sar ax,2
           add ax,160
           mov cs:_xadd,ax
           ret
updvectors endp

changeall  proc near                    ; si = source...
           mov cx,cs:[si]               ; number of vectors
           mov cs:vectors,cx
           mov dx,cs:[si+2]             ; number of sides
           mov cs:sides,dx
           mov dx,cs:[si+4]             ; number of sides
           mov cs:bcolor,dx

           mov ax,cs
           mov es,ax
           mov ds,ax

           mov di,offset xxval          ; x-data
           add si,6
           mov cx,cs:vectors
           rep movsw

           mov di,offset yyval          ; y-data
           mov cx,cs:vectors
           rep movsw

           mov di,offset zzval          ; z-data
           mov cx,cs:vectors
           rep movsw

           mov di,offset pairs          ; side-data
           mov cx,cs:sides
           shl cx,2
           rep movsw

           mov di,offset colordata      ; color-data
           mov cx,cs:sides
           shl cx,2
           rep movsw
           ret
changeall  endp

handletext proc near
           dec cs:scrollcnt
           cmp cs:scrollcnt,0
           jne through

           mov si,cs
           mov ds,si
           mov si,offset scroll
           add si,cs:scrollnr
           lodsb
           cmp al,30
           je thetext
           cmp al,99
           je newobj
           cmp al,90
           je fade_down
           cmp al,91
           je fade_up
           cmp al,255
           je startover
           cmp al,80
           je ps80
           cmp al,81
           je ps81
           inc cs:scrollnr
           jmp through
startover:
           mov cs:scrollcnt,1
           mov cs:scrollnr,0
           mov cs:outnow,1
           jmp through
newobj:
           mov cs:scrollcnt,1
           lodsb
           xor ah,ah
           mov bx,ax
           shl bx,1
           mov si,cs:objbase[bx]
           call changeall
           add cs:scrollnr,2
           jmp through
thetext:
           mov di,0a000h
           mov es,di
           mov di,0
           mov cx,17*160
           mov ax,0    ;3e3eh
           cld
           rep stosw
           mov di,30
           mov cx,25
           mov ax,0
           mov bh,232
           call writestr
           mov cs:scrollcnt,100
           add cs:scrollnr,31
           jmp through
fade_down:
           add cs:scrollnr,1
           mov cs:scrollcnt,1
           mov cs:dacdown,60
           jmp through
fade_up:
           add cs:scrollnr,1
           mov cs:scrollcnt,1
           mov cs:dacup,60
           jmp through
ps80:
           mov cs:pson,0
           add cs:scrollnr,1
           mov cs:scrollcnt,1
           mov cs:putsins,0
           jmp through
ps81:
           mov cs:pson,1
           add cs:scrollnr,1
           mov cs:scrollcnt,1
           mov cs:putsins,0
           jmp through
through:
           ret
handletext endp

putlogo    proc near
           mov di,0a000h
           mov es,di
           mov di,172*320
           mov si,cs
           mov ds,si
           mov si,offset logo
           mov cx,28*320/2
plsdf:
           lodsw
           add ah,196
           add al,196
           stosw
           loop plsdf
           ret
putlogo    endp

gettime    proc near
           mov ah,0
           int 1ah
           mov ax,dx
           mov dx,cx
           ret
gettime    endp

realtime   proc near
waitfor:
           call gettime
           sub ax,cs:time
           cmp ax,0
           je waitfor
           mov di,2
           shl di,5
           mov cx,ax
           mul cs:vxsec
           div di
           mov cs:vxadd,ax
           mov ax,cx
           mul cs:vysec
           div di
           mov cs:vyadd,ax
           mov ax,cx
           mul cs:vzsec
           div di
           mov cs:vzadd,ax
           ret
realtime   endp

fadedown   proc near
           cmp cs:dacdown,0
           je fdout
           mov di,3
fdx:
           cmp cs:ddac[di],0
           je fd2
           dec cs:ddac[di]
fd2:
           inc di
           cmp di,194*3
           jne fdx

           mov di,248*3
fdx2:
           cmp cs:ddac[di],0
           je fd22
           dec cs:ddac[di]
fd22:
           inc di
           cmp di,255*3
           jne fdx2
           mov ax,cs
           mov ds,ax
           mov si,offset ddac
           call savedac
           dec cs:dacdown
fdout:
           ret
fadedown   endp

fadeup     proc near
           cmp cs:dacup,0
           je fuout
           mov di,3
fux:
           mov ah,cs:dac[di]
           cmp cs:ddac[di],ah
           je fu2
           inc cs:ddac[di]
fu2:
           inc di
           cmp di,194*3
           jne fux

           mov di,248*3
fux2:
           mov ah,cs:dac[di]
           cmp cs:ddac[di],ah
           je fu22
           inc cs:ddac[di]
fu22:
           inc di
           cmp di,255*3
           jne fux2
           mov ax,cs
           mov ds,ax
           mov si,offset ddac
           call savedac
           dec cs:dacup
fuout:
           ret
fadeup     endp

upbase     proc near
           mov ax,cs
           mov ds,ax
           mov objbase[ 0],offset stick
           mov objbase[ 2],offset danishflag
           mov objbase[ 4],offset key
           mov objbase[ 6],offset opencube
           mov objbase[ 8],offset pyramid
           mov objbase[10],offset cube
           mov objbase[12],offset star
           mov objbase[14],offset diamond
           mov objbase[16],offset rubine
           mov objbase[18],offset cubehole
           mov objbase[20],offset ring
           mov objbase[22],offset italflag
           mov objbase[24],offset special
           mov objbase[26],offset splitcube
           ret
upbase     endp

stfadeup   proc near
           mov cx,64
sfun:
           push cx
           mov cx,768
sfun2:
           mov di,cx
           dec di
           mov ah,cs:dac[di]
           cmp cs:ddac[di],ah
           je noup
           inc cs:ddac[di]
noup:
           loop sfun2
           pop cx
           mov ax,cs
           mov ds,ax
           mov si,offset ddac
           push cx
           call savedac
           pop cx
           loop sfun
           ret
stfadeup   endp

enfade     proc near
           mov cx,64
enun:
           push cx
           mov cx,768
enun2:
           mov di,cx
           dec di
           cmp cs:ddac[di],63
           je enup
           inc cs:ddac[di]
enup:
           loop enun2
           pop cx
           mov ax,cs
           mov ds,ax
           mov si,offset ddac
           push cx
           call savedac
           pop cx
           loop enun
           mov cx,64
xenun:
           push cx
           mov cx,768
xenun2:
           mov di,cx
           dec di
           cmp cs:ddac[di],0
           je xenup
           dec cs:ddac[di]
xenup:
           loop xenun2
           pop cx
           mov ax,cs
           mov ds,ax
           mov si,offset ddac
           push cx
           call savedac
           pop cx
           loop xenun
           ret
enfade     endp

mulplane   proc near
           mov cx,cs:plane[0]
           mov si,cs
           mov ds,si
           mov es,si
           mov si,offset plane
           mov di,offset plane
           add si,6
           add di,6
mp:
           lodsw
           sal ax,2
           stosw
           lodsw
           sal ax,2
           stosw
           lodsw
           sub ax,22
           sal ax,2
           stosw
           loop mp
           ret
mulplane   endp

start      proc near
       Mov  Ah,4Ah                ; Reduce program memory size
       Mov  Bx,140000/16           ; Approx. size of compiled EXEFILE / 16 + 2
       Int  21h

           call mulplane

           mov ax,13h
           int 10h

           call upbase


       Mov  Ax,_Data
       Mov  Ds,Ax

       Call Askinit              ; Ask for the setup
       Call Initialize           ; Initialize the SoundSystem

       Mov  Dx,Offset FileName
       Call Loadmodule           ; Load the module

       Call StartPlaying         ; Roll it !
       Mov  Al,01111010b         ; Mask off all unneccesary interrupts.
       Out  21h,Al

           mov dx,cs
           mov ds,dx
           mov si,offset ddac
           call savedac
           call putlogo

           mov si,cs
           mov ds,si
           mov si,offset danishflag
           call changeall

           call stfadeup

xxxxx:
           call gettime
           mov cs:time,ax

           call cleardbl
           call rotvectors
           call sort_list
           call drawvect
;           call realtime
           call updvectors
           call copydbl
           call handletext
           call fadedown
           call fadeup

           cmp cs:outnow,1
           je getout

           in al,60h
           cmp al,1
           je getout
           jmp xxxxx
getout:
           mov al,0
           out 21h,al

           call enfade
           call stopplaying
           call dealloc

           mov ax,4c00h
           int 21h
           ret
start      endp

_code      ends
           end start
