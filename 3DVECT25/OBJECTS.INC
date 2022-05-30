setupbase:

           mov objbase[ 0*16+ 0],offset cube1a
           mov objbase[ 0*16+ 4],offset cube1b
           mov objbase[ 0*16+ 8],offset cube1c
           mov objbase[ 0*16+12],offset cube1d

           mov objbase[ 1*16+ 0],offset cube2a
           mov objbase[ 1*16+ 4],offset cube2b
           mov objbase[ 1*16+ 8],offset cube2c
           mov objbase[ 1*16+12],offset cube2d

           mov objbase[ 2*16+ 0],offset ringa
           mov objbase[ 2*16+ 4],offset ringb
           mov objbase[ 2*16+ 8],offset ringc
           mov objbase[ 2*16+12],offset ringd

           mov objbase[ 3*16+ 0],offset rubinea
           mov objbase[ 3*16+ 4],offset rubineb
           mov objbase[ 3*16+ 8],offset rubinec
           mov objbase[ 3*16+12],offset rubined

           mov objbase[ 4*16+ 0],offset diamonda
           mov objbase[ 4*16+ 4],offset diamondb
           mov objbase[ 4*16+ 8],offset diamondc
           mov objbase[ 4*16+12],offset diamondd

           mov objbase[ 5*16+ 0],offset cube3a
           mov objbase[ 5*16+ 4],offset cube3b
           mov objbase[ 5*16+ 8],offset cube3c
           mov objbase[ 5*16+12],offset cube3d

           ret

; shape data can be almost as large as you need it 'till it crashes. try a cube
; 20000x20000x20000.  calculations use 32 bit registers and can handle
; up to 16 bit locations.  keeping the object size small will allow a larger
; visible space.  but larger objects will allow you to get closer with more
; accuracy in the mathematics of rotations.
;
; list of command bits to date:
;
; 00000001 - 1  steel texture for surface 0 = none,  colour  offset  determines
;               screen offset for texture.  eg 16+7 will use colour block 16-31
;               but make the sine wave texture 14 (7*2) lines down. this is  so
;               all sine wave textures do not appear on the same line.
; 00000010 - 2  side is always visible no matter angle
; 00000100 - 4  side is always visible but other side has high byte colour
;               note: if this is used, bits 2 and 6 must NOT be set (+2 or +32)
; 00001000 - 8  if other side IS used (above), this determines if steel texture
; 00010000 - 16 if used, defines a line (must be set to define a true line)
; 00100000 - 32 if set, defines a bitmap,eg: point #, bitmap #, x scale,y scale
; 01000000 - 64 defines a single point; must be repeated! eg dw 64,col,3,3
; 10000000 - xx not used, entire high byte also not used (define your own)
;
; there are two kinds of bitmaps and points.  those which  are  inside  objects
; and those which are seperate objects themselvs.  if userotate object  command
; is set to 32 or 64, then the entire object is considered to be either a point
; or bitmap.  but if userotate is not set this way, then  a  normal  object  is
; drawn and bitmaps then come from within the object definitions (below).  this
; way, bitmaps and points can be either part of a larger object,  or  they  are
; computed fast on their own. (eg explosions and bullets as  seperate  objects)
;
; note: when writing surface descriptions, try to make the  first value unique
; from any other first value.  this way, the sort routine  will  give  a  more
; accurate sorting of sides. eg 1,3,6,1  2,4,1,2  rather than 1,3,6,1  1,2,4,1

           align 4

cube1a:
cube1b:
cube1c:
cube1d     dw 8           ; how many points
           dw 6           ; how many surfaces
           ;    x   y   z
           dw -70, 70, 70 ;0
           dw -70,-70, 70 ;1
           dw  70,-70, 70 ;2
           dw  70, 70, 70 ;3
           dw -70, 70,-70 ;4
           dw -70,-70,-70 ;5
           dw  70,-70,-70 ;6
           dw  70, 70,-70 ;7

           dw 1,16*3+8  ,0,1,2,3,0 ; surface connection data, and colours
           dw 0,16*2+4  ,7,6,5,4,7 ; end point=start point means done side
           dw 0,16*1+15 ,3,2,6,7,3
           dw 1,16*2+12 ,4,5,1,0,4
           dw 0,16*3+0  ,4,0,3,7,4
           dw 1,16*4+10 ,1,5,6,2,1

cube2a:
cube2b:
cube2c:
cube2d     dw 8           ; how many points
           dw 9           ; how many surfaces
           ;    x   y   z
           dw -70, 70, 70 ;0
           dw -70,-70, 70 ;1
           dw  70,-70, 70 ;2
           dw  70, 70, 70 ;3
           dw -70, 70,-70 ;4
           dw -70,-70,-70 ;5
           dw  70,-70,-70 ;6
           dw  70, 70,-70 ;7

           dw 4+8, 16*3+8+(16*1+1)*256, 0,1,2,3,0 ; surface connection data, and colours
           dw 16,16*2+4  ,5,1,5   ; end point=start point means done side
           dw 16,16*1+15 ,6,2,6
           dw 16,16*2+12 ,7,3,7
           dw 16,16*3+0  ,4,0,4
           dw 16,16*4+10 ,5,6,5
           dw 16,16*4+10 ,6,7,6
           dw 16,16*4+10 ,7,4,7
           dw 16,16*4+10 ,4,5,4

cube3a:
cube3b     dw 45          ; how many points
           dw 45          ; how many surfaces
           ;    x   y   z
           dw -70, 70, 70 ;0
           dw -70, 70, 35 ;1
           dw -70, 70,  0 ;2
           dw -70, 70,-35 ;3

           dw -70,-70, 70 ;4
           dw -70,-70, 35 ;5
           dw -70,-70,  0 ;6
           dw -70,-70,-35 ;7

           dw  70,-70, 70 ;8
           dw  70,-70, 35 ;9
           dw  70,-70,  0 ;10
           dw  70,-70,-35 ;11

           dw  70, 70, 70 ;12
           dw  70, 70, 35 ;13
           dw  70, 70,  0 ;14
           dw  70, 70,-35 ;15

           dw -70, 70,-70 ;16
           dw -70, 35,-70 ;17
           dw -70,  0,-70 ;18
           dw -70,-35,-70 ;19
           dw -70,-70,-70 ;20

           dw  70, 70,-70 ;21
           dw  70, 35,-70 ;22
           dw  70,  0,-70 ;23
           dw  70,-35,-70 ;24
           dw  70,-70,-70 ;25

           dw -70, 35, 70 ;26
           dw -70,  0, 70 ;27
           dw -70,-35, 70 ;28

           dw  70, 35, 70 ;29
           dw  70,  0, 70 ;30
           dw  70,-35, 70 ;31

           dw -35,-70, 70 ;32
           dw   0,-70, 70 ;33
           dw  35,-70, 70 ;34

           dw -35,-70,-70 ;35
           dw   0,-70,-70 ;36
           dw  35,-70,-70 ;37

           dw -35, 70,-70 ;38
           dw   0, 70,-70 ;39
           dw  35, 70,-70 ;40

           dw -35, 70, 70 ;41
           dw   0, 70, 70 ;42
           dw  35, 70, 70 ;43

           dw   0,0,0 ; 44

           dw 32,00,0,5,5
           dw 32,01,0,5,5
           dw 32,02,0,5,5
           dw 32,03,0,5,5
           dw 32,04,0,5,5
           dw 32,05,0,5,5
           dw 32,06,0,5,5
           dw 32,07,0,5,5
           dw 32,08,0,5,5
           dw 32,09,0,5,5
           dw 32,10,0,5,5
           dw 32,11,0,5,5
           dw 32,12,0,5,5
           dw 32,13,0,5,5
           dw 32,14,0,5,5
           dw 32,15,0,5,5
           dw 32,16,0,5,5
           dw 32,17,0,5,5
           dw 32,18,0,5,5
           dw 32,19,0,5,5
           dw 32,20,0,5,5
           dw 32,21,0,5,5
           dw 32,22,0,5,5
           dw 32,23,0,5,5
           dw 32,24,0,5,5
           dw 32,25,0,5,5
           dw 32,26,0,5,5
           dw 32,27,0,5,5
           dw 32,28,0,5,5
           dw 32,29,0,5,5
           dw 32,30,0,5,5
           dw 32,31,0,5,5
           dw 32,32,0,5,5
           dw 32,33,0,5,5
           dw 32,34,0,5,5
           dw 32,35,0,5,5
           dw 32,36,0,5,5
           dw 32,37,0,5,5
           dw 32,38,0,5,5
           dw 32,39,0,5,5
           dw 32,40,0,5,5
           dw 32,41,0,5,5
           dw 32,42,0,5,5
           dw 32,43,0,5,5

           dw 32,44,0,30,30

cube3c:
cube3d     dw 45  ; this is same as above but since bitmaps can't be seen
           dw 45  ; from far, i use the same cube with points instead.
           ;    x   y   z
           dw -70, 70, 70 ;0  ; this is an example of how to use the
           dw -70, 70, 35 ;1  ; different resolutions based on distance
           dw -70, 70,  0 ;2  ; you could get rid of half of these points
           dw -70, 70,-35 ;3  ; and still have it "look" the same because

           dw -70,-70, 70 ;4  ; of the great distance at which this will
           dw -70,-70, 35 ;5  ; be seen
           dw -70,-70,  0 ;6
           dw -70,-70,-35 ;7

           dw  70,-70, 70 ;8
           dw  70,-70, 35 ;9
           dw  70,-70,  0 ;10
           dw  70,-70,-35 ;11

           dw  70, 70, 70 ;12
           dw  70, 70, 35 ;13
           dw  70, 70,  0 ;14
           dw  70, 70,-35 ;15

           dw -70, 70,-70 ;16
           dw -70, 35,-70 ;17
           dw -70,  0,-70 ;18
           dw -70,-35,-70 ;19
           dw -70,-70,-70 ;20

           dw  70, 70,-70 ;21
           dw  70, 35,-70 ;22
           dw  70,  0,-70 ;23
           dw  70,-35,-70 ;24
           dw  70,-70,-70 ;25

           dw -70, 35, 70 ;26
           dw -70,  0, 70 ;27
           dw -70,-35, 70 ;28

           dw  70, 35, 70 ;29
           dw  70,  0, 70 ;30
           dw  70,-35, 70 ;31

           dw -35,-70, 70 ;32
           dw   0,-70, 70 ;33
           dw  35,-70, 70 ;34

           dw -35,-70,-70 ;35
           dw   0,-70,-70 ;36
           dw  35,-70,-70 ;37

           dw -35, 70,-70 ;38
           dw   0, 70,-70 ;39
           dw  35, 70,-70 ;40

           dw -35, 70, 70 ;41
           dw   0, 70, 70 ;42
           dw  35, 70, 70 ;43

           dw   0,0,0 ; 44

           dw 64,28,00,00
           dw 64,28,01,01
           dw 64,28,02,02
           dw 64,28,03,03
           dw 64,28,04,04
           dw 64,28,05,05
           dw 64,28,06,06
           dw 64,28,07,07
           dw 64,28,08,08
           dw 64,28,09,09
           dw 64,28,10,10
           dw 64,28,11,11
           dw 64,28,12,12
           dw 64,28,13,13
           dw 64,28,14,14
           dw 64,28,15,15
           dw 64,28,16,16
           dw 64,28,17,17
           dw 64,28,18,18
           dw 64,28,19,19
           dw 64,28,20,20
           dw 64,28,21,21
           dw 64,28,22,22
           dw 64,28,23,23
           dw 64,28,24,24
           dw 64,28,25,25
           dw 64,28,26,26
           dw 64,28,27,27
           dw 64,28,28,28
           dw 64,28,29,29
           dw 64,28,30,30
           dw 64,28,31,31
           dw 64,28,32,32
           dw 64,28,33,33
           dw 64,28,34,34
           dw 64,28,35,35
           dw 64,28,36,36
           dw 64,28,37,37
           dw 64,28,38,38
           dw 64,28,39,39
           dw 64,28,40,40
           dw 64,28,41,41
           dw 64,28,42,42
           dw 64,28,43,43

           dw 64,28,44,44

ringa:
ringb:
ringc:
ringd      dw 32
           dw 32
           ;    x   y   z
           dw -40, 80, 30 ; 0
           dw -80, 40, 30 ; 1
           dw -80,-40, 30 ; 2
           dw -40,-80, 30 ; 3
           dw  40,-80, 30 ; 4
           dw  80,-40, 30 ; 5
           dw  80, 40, 30 ; 6
           dw  40, 80, 30 ; 7
           dw -40, 20, 45 ; 8
           dw -40,-20, 45 ; 9
           dw -20,-40, 45 ;10
           dw  20,-40, 45 ;11
           dw  40,-20, 45 ;12
           dw  40, 20, 45 ;13
           dw  20, 40, 45 ;14
           dw -20, 40, 45 ;15
           dw -40, 80,-30 ;16
           dw -80, 40,-30 ;17
           dw -80,-40,-30 ;18
           dw -40,-80,-30 ;19
           dw  40,-80,-30 ;20
           dw  80,-40,-30 ;21
           dw  80, 40,-30 ;22
           dw  40, 80,-30 ;23
           dw -40, 20,-45 ;24
           dw -40,-20,-45 ;25
           dw -20,-40,-45 ;26
           dw  20,-40,-45 ;27
           dw  40,-20,-45 ;28
           dw  40, 20,-45 ;29
           dw  20, 40,-45 ;30
           dw -20, 40,-45 ;31

           dw 0,16+7  ,1,8,15,0,1
           dw 0,16+9  ,2,9,8,1,2
           dw 0,16+5  ,3,10,9,2,3
           dw 0,16+3  ,4,11,10,3,4
           dw 0,16+6  ,5,12,11,4,5
           dw 0,16+9  ,6,13,12,5,6
           dw 0,16+7  ,7,14,13,6,7
           dw 0,16+11 ,0,15,14,7,0
           dw 0,16+7  ,0,16,17,1,0
           dw 0,16+6  ,1,17,18,2,1
           dw 0,16+5  ,2,18,19,3,2
           dw 0,16+4  ,3,19,20,4,3
           dw 0,16+13 ,4,20,21,5,4
           dw 0,16+1  ,5,21,22,6,5
           dw 0,16+15 ,6,22,23,7,6
           dw 0,16+14 ,7,23,16,0,7
           dw 0,16+9  ,9,25,24,8,9
           dw 0,16+13 ,10,26,25,9, 10
           dw 0,16+12 ,11,27,26,10,11
           dw 0,16+10 ,12,28,27,11,12
           dw 0,16+6  ,13,29,28,12,13
           dw 0,16+7  ,14,30,29,13,14
           dw 0,16+8  ,14,15,31,30,14
           dw 0,16+5  ,31,15,8,24,31
           dw 0,16+6  ,17,24,25,18,17
           dw 0,16+9  ,18,25,26,19,18
           dw 0,16+8  ,19,26,27,20,19
           dw 0,16+7  ,20,27,28,21,20
           dw 0,16+8  ,21,28,29,22,21
           dw 0,16+12 ,22,29,30,23,22
           dw 0,16+15 ,23,30,31,16,23
           dw 0,16+7  ,16,31,24,17,16

diamonda:
diamondb:
diamondc:
diamondd   dw 13
           dw 17

           dw -100,  50,   0
           dw -100, -50,   0
           dw  -50,-100,   0
           dw   50,-100,   0
           dw  100, -50,   0
           dw  100,  50,   0
           dw   50, 100,   0
           dw  -50, 100,   0
           dw  -50,  50,  40
           dw  -50, -50,  40
           dw   50, -50,  40
           dw   50,  50,  40
           dw    0,   0,-120

           dw 0,32+7     ,0,1,9,8,0
           dw 0,32+9     ,9,2,3,10,9
           dw 0,32+5     ,11,10,4,5,11
           dw 0,32+3     ,7,8,11,6,7
           dw 0,32+6     ,1,2,9,1
           dw 0,32+9     ,10,3,4,10
           dw 0,32+7     ,6,11,5,6
           dw 0,32+11    ,0,8,7,0
           dw 0,32+7     ,8,9,10,11,8
           dw 0,32+6     ,7,12,0,7
           dw 0,32+5     ,0,12,1,0
           dw 0,32+4     ,1,12,2,1
           dw 0,32+13    ,2,12,3,2
           dw 0,32+1     ,3,12,4,3
           dw 0,32+15    ,4,12,5,4
           dw 0,32+14    ,5,12,6,5
           dw 0,32+9     ,6,12,7,6

rubinea:
rubineb:
rubinec:
rubined    dw 16
           dw 18

           dw -100,  50,   0
           dw -100, -50,   0
           dw  -50,-100,   0
           dw   50,-100,   0
           dw  100, -50,   0
           dw  100,  50,   0
           dw   50, 100,   0
           dw  -50, 100,   0
           dw  -50,  50,  40
           dw  -50, -50,  40
           dw   50, -50,  40
           dw   50,  50,  40
           dw  -50,  50, -40
           dw  -50, -50, -40
           dw   50, -50, -40
           dw   50,  50, -40

           dw 1,32+7    ,0,1,9,8,0
           dw 0,32+9    ,9,2,3,10,9
           dw 1,32+11   ,11,10,4,5,11
           dw 0,32+3    ,7,8,11,6,7
           dw 1,32+4    ,1,2,9,1
           dw 0,32+9    ,10,3,4,10
           dw 1,32+8    ,6,11,5,6
           dw 0,32+11   ,0,8,7,0
           dw 1,32+3    ,8,9,10,11,8
           dw 0,32+6    ,5,4,14,15,5
           dw 1,32+5    ,14,3,2,13,14
           dw 0,32+4    ,12,13,1,0,12
           dw 1,32+12   ,6,15,12,7,6
           dw 0,32+1    ,4,3,14,4
           dw 1,32+15   ,13,2,1,13
           dw 0,32+14   ,7,12,0,7
           dw 1,32+9    ,5,15,6,5
           dw 0,32+13   ,15,14,13,12,15
