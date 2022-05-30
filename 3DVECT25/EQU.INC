; conditional assembley variables and general constants

; constants for optimal conditional assembley
; don't pay for features you'll never use! (timewise)

usez       equ yes           ; z camera rotations ommited if no, saves 12 imuls
                             ; this speeds up computation in "compound" matrix
usesteel   equ yes           ; set no if no sides will use steel texture.
                             ; makes poly_fill routine faster
useborders equ yes           ; lxupdate and xupdate will be skipped if no.
                             ; set to no if you have no intention of ever
                             ; using the clear_fill routine. this really
                             ; is used if you will have a landscape in the
                             ; background and you want the fake_line routine
                             ; to be faster

yes     equ 0
no      equ -1

bulletcolour equ 4           ; what colour is single point object

; variables for object and polygon routine

tolerance  equ 60            ; max center of gravity offset for objects/ratio
ztruncate  equ 40            ; if z< ztruncate, z=ztruncate:for make3d
minz       equ 60            ; minimum z before object can be seen:for make1obj
maxz       equ 3000000       ; maximum distance in any axis object can be seen
followtol  equ 300           ; tolerance if already looking at object,newfollow

; polygon constants

maxpoints   equ 600          ; max points (*total* on screen if 3d2)
maxsurfaces equ 600          ; max object surfaces (*total* on screen if 3d2)
mult        equ 3            ; shl ax,mult for number of sides
maxpolys    equ 8  ;2^mult   ; max sides to a polygon,must = 2^mult,keep small!!

maxobjects  equ 10 ;50,100,? ; number of objects

cameraobject equ maxobjects  ; camera is last object in list

; constants for distance vs resolution

smalla     equ 1100          ; if objects are farther than smallabc, whatshape
smallb     equ 4500          ; will assume smaller form of object
smallc     equ 10000         ; a = close/high resolution, d = far/low res

; mode x definitions

;  0 =  320 x 200
;  1 =  320 x 400
;  2 =  360 x 200
;  3 =  360 x 400
;  4 =  320 x 240
;  5 =  320 x 480
;  6 =  360 x 240
;  7 =  360 x 480

videomode  equ -1

           if videomode eq 0

xmode      equ videomode
xmax       equ 160
xmin       equ -160
ymax       equ 100
ymin       equ -100
xactual    equ 320
yactual    equ 200

xcenter    equ 160
ycenter    equ 100

ratiox     equ 320
ratioy     equ 260
pages      equ 4

           elseif videomode eq 1

xmode      equ videomode
xmax       equ 160         ; right colomn just beyond screen for clipping
xmin       equ -160        ; left coloumn on screen, x's must be "and 0fff8h"
ymax       equ 200         ; lower row just beyond screen
ymin       equ -200        ; upper row on screen
xactual    equ 320
yactual    equ 400

xcenter    equ 160         ; screen center x,y for actual screen point (0,0)
ycenter    equ 200         ; make sure clipping still stays inside screen

ratiox     equ 320         ; apsect ratio for 3d conversion (zoom)
ratioy     equ 470         ; make x and y different to fine tune (draw circle)
pages      equ 2

           elseif videomode eq 2

xmode      equ videomode
xmax       equ 180
xmin       equ -180
ymax       equ 100
ymin       equ -100
xactual    equ 360
yactual    equ 200

xcenter    equ 180
ycenter    equ 100

ratiox     equ 320
ratioy     equ 240
pages      equ 3

           elseif videomode eq 3

xmode      equ videomode
xmax       equ 180
xmin       equ -180
ymax       equ 200
ymin       equ -200
xactual    equ 360
yactual    equ 400

xcenter    equ 180
ycenter    equ 200

ratiox     equ 300
ratioy     equ 420
pages      equ 1

           elseif videomode eq 4

xmode      equ videomode
xmax       equ 160
xmin       equ -160
ymax       equ 120
ymin       equ -120
xactual    equ 320
yactual    equ 240

xcenter    equ 160
ycenter    equ 120

ratiox     equ 300
ratioy     equ 280
pages      equ 3

           elseif videomode eq 5

xmode      equ videomode
xmax       equ 160
xmin       equ -160
ymax       equ 240
ymin       equ -240
xactual    equ 320
yactual    equ 480

xcenter    equ 160
ycenter    equ 240

ratiox     equ 260
ratioy     equ 460
pages      equ 1

           elseif videomode eq 6

xmode      equ videomode
xmax       equ 180
xmin       equ -180
ymax       equ 120
ymin       equ -120
xactual    equ 360
yactual    equ 240

xcenter    equ 180
ycenter    equ 120

ratiox     equ 320
ratioy     equ 260
pages      equ 3

           elseif videomode eq 7

xmode      equ videomode
xmax       equ 180
xmin       equ -180
ymax       equ 240
ymin       equ -240
xactual    equ 360
yactual    equ 480

xcenter    equ 180
ycenter    equ 240

ratiox     equ 280
ratioy     equ 470
pages      equ 1

; if videomode = -1, custom configuration

           elseif videomode eq -1

xmode      equ 1
xmax       equ 9*16
xmin       equ -9*16
ymax       equ 140
ymin       equ -140
xactual    equ 320
yactual    equ 400

xcenter    equ 160
ycenter    equ 200

ratiox     equ 320
ratioy     equ 464
pages      equ 2

; if videomode = -2, custom configuration

           elseif videomode eq -2

xmode      equ 0
xmax       equ 9*16
xmin       equ -9*16
ymax       equ 60
ymin       equ -70
xactual    equ 320
yactual    equ 200

xcenter    equ 160
ycenter    equ 100

ratiox     equ 320
ratioy     equ 260
pages      equ 2

           endif

; ===== general xmode constants =====

false   equ 0
true    equ -1
nil     equ 0

b       equ byte ptr
w       equ word ptr
d       equ dword ptr
o       equ offset
f       equ far ptr
s       equ short
?x4     equ <?,?,?,?>
?x3     equ <?,?,?>

; ===== vga register values =====

vga_segment     equ d 0a0000h ; vga memory segment

attrib_ctrl     equ 03c0h   ; vga attribute controller
gc_index        equ 03ceh   ; vga graphics controller
sc_index        equ 03c4h   ; vga sequencer controller
sc_data         equ 03c5h   ; vga sequencer data port
crtc_index      equ 03d4h   ; vga crt controller
crtc_data       equ 03d5h   ; vga crt controller data
misc_output     equ 03c2h   ; vga misc register
input_1         equ 03dah   ; input status #1 register

dac_write_addr  equ 03c8h   ; vga dac write addr register
dac_read_addr   equ 03c7h   ; vga dac read addr register
pel_data_reg    equ 03c9h   ; vga dac/pel data register r/w

pixel_pan_reg   equ 033h    ; attrib index: pixel pan reg
map_mask        equ 002h    ; sequ index: write map mask reg
read_map        equ 004h    ; gc index: read map register
start_disp_hi   equ 00ch    ; crtc index: display start hi
start_disp_lo   equ 00dh    ; crtc index: display start lo

map_mask_plane1 equ 00102h  ; map register + plane 1
map_mask_plane2 equ 01102h  ; map register + plane 1
all_planes_on   equ 00f02h  ; map register + all bit planes

chain4_off      equ 00604h  ; chain 4 mode off
async_reset     equ 00100h  ; (a)synchronous reset
sequ_restart    equ 00300h  ; sequencer restart

latches_on      equ 00008h  ; bit mask + data from latches
latches_off     equ 0ff08h  ; bit mask + data from cpu

vert_retrace    equ 08h     ; input_1: vertical retrace bit
plane_bits      equ 03h     ; bits 0-1 of xpos = plane #
all_planes      equ 0fh     ; all bit planes selected
char_bits       equ 0fh     ; bits 0-3 of character data

get_char_ptr    equ 01130h  ; vga bios func: get char set
rom_8x8_lo      equ 03h     ; rom 8x8 char set lo pointer
rom_8x8_hi      equ 04h     ; rom 8x8 char set hi pointer

; constants specific for these routines

num_modes       equ 8       ; # of mode x variations

