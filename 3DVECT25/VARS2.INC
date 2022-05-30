; main variable tables

           align 4

x1         dw ?                     ; points for line draw
y1         dw ?
x2         dw ?
y2         dw ?
rise       dw ?                     ; counter for draw loop
showing    dw 0                     ; how many visible sides (total)
pointindex dw 0                     ; indexer to points, xs[],ys[],zs[]
lindex     dw ?                     ; last indexer to points,
offsides   dd offset sides          ; guess...gets inc'd when object plotted
numsides   dw ?                     ; number of sides total, gets trashed
numpoints  dw ?                     ; number of points, gets trashed
whichside  dw ?                     ; which side am i doing now
firstbyte  dw ymax-ymin dup(1000)   ; table of start and end x points
           dw 1000                  ; end flag, permanent
lastbyte   dw ymax-ymin dup(-1000)
oney       dw 1000                  ; y start for one polygon draw
colq       db ?                     ; colour of this side
           align 4
xupdate    dw xmax,xmin-1           ; x,y update for clearing entire picture
yupdate    dw ymax,ymin-1
lxupdate   dw xmax,xmin-1           ; last x,y update
lyupdate   dw ymax,ymin-1
xad        dd ?
yad        dd ?
zad        dd ?
vxcos      dd ?
vxsin      dd ?
vycos      dd ?
vysin      dd ?
vzcos      dd ?
vzsin      dd ?
steel      db ?                     ; steel flag, -1 = don't use
steelc     db ?                     ; base colour for steel, taken from colq
dsq        dw ?                     ; for checkfront routine
esq        dw ?

traces_past dw 1                    ; contains frame speed (irq driven)
frame_number dd 0                   ; number of frames total,eg 23400 = 13 mins

xp         dw maxpoints dup (?)     ; points breakdown, after rotated, 3d,
yp         dw maxpoints dup (?)     ; x,y points after 3d, are actual location.
zp         dw maxpoints dup (?)     ; z useless, only good during sort of sides
sides      dw maxsurfaces*maxpolys dup (?) ; visible sides only here (clockwize)
order      dw maxsurfaces dup (?)   ; what order to draw surfaces in.
zeds       dw maxsurfaces dup (?)
surfcolors dw maxsurfaces dup (?)   ; colours for those sides, high and low
commands   dw maxsurfaces dup (?)   ; commands for those sides

; variables for multiple object routine, you modify these!
;
; userotate object commands
;
; 0  = all rotations supported - full object
;
; 1  = camera rotations only - no compound, new loadpoints
;
;      object is same as when userotate=0 but will not allow any object specific
;      rotations.  this is used to speed up rendering of objects that are
;      stationary or objects that will always be pointing in the same direction.
;      make1obj routine then assumes angles = 0x, 0y, 0z
;
; 32 = bitmap - no compound, no loadpoints, no sort and no drawvect
;
;      if object is bitmap, then:
;
;      whatshape - indexer to which bitmap in bitbase list
;      xs,ys,zs  - point to bitmap location in space
;      vxs       - bitmap scaling (how big is bitmap).  note: bitmap is already
;                  scaled based on distance so you don't have to change this
;                  as the bitmap gets farther away.
;
; 64 = point - no compound, no loadpoints, no sort and no drawvect
;
;      used for bullets.  could be used for stars but if you do want to make
;      stars, make a specialized bitmap routine.  making stars as objects would
;      be too slow.  right now, bullets all have same colour, see constant in
;      equ.inc.
;
;      xs,ys,zs  - point to bullet location in space

           align 4
xs         dd maxobjects+1 dup (?)  ; locations of objects
ys         dd maxobjects+1 dup (?)
zs         dd maxobjects+1 dup (?)
xadds      dd maxobjects+1 dup (?)  ; linear velocities of objects
yadds      dd maxobjects+1 dup (?)
zadds      dd maxobjects+1 dup (?)
vxs        dw maxobjects+1 dup (?)  ; angles of objects
vys        dw maxobjects+1 dup (?)
vzs        dw maxobjects+1 dup (?)
vxadds     dw maxobjects+1 dup (?)  ; anglular velocities
vyadds     dw maxobjects+1 dup (?)
vzadds     dw maxobjects+1 dup (?)
lcount     dw maxobjects+1 dup (0)  ; linear counter
acount     dw maxobjects+1 dup (0)  ; angular counter
whatshape  dw maxobjects dup (?)    ; shapes of objects or bitmaps (0,1,2...)
userotate  db maxobjects dup (?)    ; rotation type,0 = full,1 = camera
           align 4
onoff      db maxobjects dup (0)    ; is object on/off

; flags to disable/enable routines: disable = -1, enable >=0

use_clear  dw yes                 ; flag to use clear_fill routine, default=use
wfollow    dw no                  ; what object are we following, -1 = none
wherelook  dw no                  ; what object do we force camera to look at

oldspeed   dw ?                   ; how fast to move, temp counter

; camera variables = last object in object list

eyex       equ d [xs+cameraobject*4] ; camera location
eyey       equ d [ys+cameraobject*4]
eyez       equ d [zs+cameraobject*4]
eyeax      equ w [vxs+cameraobject*2] ; angles for camera
eyeay      equ w [vys+cameraobject*2]
eyeaz      equ w [vzs+cameraobject*2]
eyexadds   equ d [xadds+cameraobject*4] ; eye location velocity
eyeyadds   equ d [yadds+cameraobject*4]
eyezadds   equ d [zadds+cameraobject*4]
eyevxadds  equ w [vxadds+cameraobject*2] ; eye angular velocities
eyevyadds  equ w [vyadds+cameraobject*2]
eyevzadds  equ w [vzadds+cameraobject*2]
eyelcount  equ w [lcount+cameraobject*2] ; eye linear count (how many times to move)
eyeacount  equ w [acount+cameraobject*2] ; eye angular count

           align 4

ecosx      dd ?              ; multipliers of eyeax and eyeaz
esinx      dd ?              ; reset at begining of each new frame
ecosy      dd ?
esiny      dd ?
ecosz      dd ?
esinz      dd ?

vcosx      dd ?              ; temp storage for object matrix calculation
vsinx      dd ?              ; can be used if needed during draw
vcosy      dd ?
vsiny      dd ?
vcosz      dd ?
vsinz      dd ?

vmatrix    dd 9 dup (?)      ; 3x3 rotation matrix for object (includes eye)
ematrix    dd 9 dup (?)      ; 3x3 rotation matrix for eye

; clipping variables in memory locations, pre-calculated!
; xactual and yactual basically don't change but clipping can to allow
; windows (rear view mirror, view airplanes menu, auxilary views, rear gunner)
;
; when flipping between windows, also flip wfollow, wherelook
; oldspeed, lxupdate, lyupdate, camera variables/angles/speeds (obviously).

cliplt      dw xcenter+xmin     ; xcenter+xmin
cliprt      dw xcenter+xmax-1   ; xcenter+xmax-1
cliptp      dw ycenter+ymin     ; ycenter+ymin
clipbt      dw ycenter+ymax-1   ; ycenter+ymax-1

xcent       dw xcenter
ycent       dw ycenter
ycents1     dw ycenter-1
ycentp1     dw ycenter+1

xmaxxcent   dw xmax+xcenter

ymaxycent   dw ymax+ycenter

xmins       dw xmin
xmins1      dw xmin-1
xmaxs       dw xmax
xmaxs1      dw xmax-1

ymins       dw ymin
ymins1      dw ymin-1
ymaxs       dw ymax

xmit        dd xmin-tolerance   ; tolerance is max object size/ratio
xmat        dd xmax+tolerance
ymit        dd ymin-tolerance
ymat        dd ymax+tolerance

; variables for icon scale routine

bitmap        dd ?
destwidth     dw ?
destheight    dw ?
destx         dw ?
desty         dw ?

sourcewidth   dw ?              ; workspace for icon scale routine
sourceheight  dw ?
decisionx     dw ?
decisiony     dw ?
clippedwidth  dw ?
clippedheight dw ?

background dw 0                 ; background colour, must be in high and low!

           public xs
           public ys
           public zs
           public xadds
           public yadds
           public zadds
           public vxs
           public vys
           public vzs
           public vxadds
           public vyadds
           public vzadds
           public lcount
           public acount
           public whatshape
           public userotate

           public eyex
           public eyey
           public eyez
           public eyeax
           public eyeay
           public eyeaz
           public eyexadds
           public eyeyadds
           public eyezadds
           public eyevxadds
           public eyevyadds
           public eyevzadds
           public eyelcount
           public eyeacount

           public onoff

           public vmatrix
           public ematrix

           public background

           public bitmap
           public destwidth
           public destheight
           public destx
           public desty

           public use_clear
           public wfollow
           public wherelook

           public x1
           public y1
           public x2
           public y2
           public colq
           public steel

           public lxupdate
           public lyupdate
           public xupdate
           public yupdate
           public oney
           public firstbyte
           public lastbyte
           public showing

           public traces_past
           public frame_number

