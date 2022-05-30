;math.inc - general math functions.

; point rotation is 16 bit and uses vmatrix
; camera rotation is 32 bit and uses ematrix
; frotate uses rotation along a plane and uses ematrix with precal147

; point rotation
; bx = x   cx = y   bp = z    16 bit!
; clobbers dx,si,ax

; remember , matrix offsets are:
;
;  0 1 2     multiply those by 4 four the doublewords
;  3 4 5
;  6 7 8
;
           align 4

           public rotate

rotate:
           movsx ebx,bx  ; x
           movsx ecx,cx  ; y
           movsx ebp,bp  ; z

           mov eax,vmatrix+8    ; solve x = bx(0)+cx(1)+bp(2)
           imul ebp
           shr eax,14
           movsx edi,ax
           mov eax,vmatrix+4
           imul ecx
           shr eax,14
           movsx eax,ax
           add edi,eax
           mov eax,vmatrix+0
           imul ebx
           shr eax,14
           movsx eax,ax
           add edi,eax   ; di = new x

           mov eax,vmatrix+20   ; solve y = bx(3)+cx(4)+bp(5)
           imul ebp
           shr eax,14
           movsx esi,ax
           mov eax,vmatrix+16
           imul ecx
           shr eax,14
           movsx eax,ax
           add esi,eax
           mov eax,vmatrix+12
           imul ebx
           shr eax,14
           movsx eax,ax
           add esi,eax   ; si = new y

           mov eax,vmatrix+32   ; solve z = bx(6)+cx(7)+bp(8)
           imul ebp
           shr eax,14
           movsx ebp,ax
           mov eax,vmatrix+28
           imul ecx
           shr eax,14
           movsx eax,ax
           add ebp,eax
           mov eax,vmatrix+24
           imul ebx
           shr eax,14
           movsx eax,ax
           add ebp,eax   ; bp = new z

           mov ecx,esi
           mov ebx,edi

           ret

           align 4

; fast ratiox and ratioy are 320x and 464y
; multiplication has been substituted with fast lea

; trashes eax,edx,edi

           public make3d
           public make3dx
           public make3dy

make3d:                            ; bp must always be positive
           if ratiox eq 320

           lea eax,[ebx*4+ebx]     ; 320 = %1 0100 0000
           shl eax,6
           cdq

           elseif not ratiox eq 320
           imul eax,ratiox
           display "Note: Slow X multiplication used in make3d routine"
           endif

           idiv ebp
           mov ebx,eax
make3dy:
           if ratioy eq 464
           lea eax,[ecx*8+ecx]     ; 464 = %1 1101 0000
           shl ecx,2
           lea ecx,[ecx*4+ecx]
           add eax,ecx
           shl eax,4
           cdq

           elseif not ratioy eq 464
           mov eax,ecx
           mov ecx,ratioy
           imul ecx
           display "Note: Slow Y multiplication used in make3dy routine"
           endif

           idiv ebp
           mov ecx,eax

           ret

make3dx:                           ; bp must always be positive
           if ratiox eq 320

           lea eax,[edi*4+edi]     ; 320 = %1 0100 0000, eax=320*edi
           shl eax,6
           cdq

           elseif not ratiox eq 320
           mov eax,edi
           mov edi,ratiox
           imul edi
           display "Note: Slow X multiplication used in make3dx routine"
           endif

           idiv esi
           mov edi,eax
           ret

; checks if a side is visible.
; DI, SI, DX = x's
; BP, DS, ES = y's
; return: cx register...
; cx > 0: side visible...else not...routine courtesy of "RAZOR"
; eg:
;          call checkfront
;          cmp cx,0
;          jng dontdraw

           align 4

checkfront:
           cmp di,si
           jng s cfc
           mov ax,di
           mov di,si
           mov si,dx
           mov dx,ax
           mov ax,bp
           mov bp,dsq
           mov bx,esq
           mov dsq,bx
           mov esq,ax
cfc:
           cmp di,si
           jng s cfc2
           mov ax,di
           mov di,si
           mov si,dx
           mov dx,ax
           mov ax,bp
           mov bp,dsq
           mov bx,esq
           mov dsq,bx
           mov esq,ax
cfc2:
           mov ax,dx                 ; ax = x3
           sub ax,di                 ; ax = x3 - x1
           mov bx,dsq                ; bx = y2
           sub bx,bp                 ; bx = y2 - y1
           movsx eax,ax              ; modification to allow large checks
           movsx ebx,bx
           imul ebx                  ; ax = (x3-x1)*(y2-y1)
           mov ecx,eax               ; save it...
           mov ax,si                 ; ax = x2
           sub ax,di                 ; ax = x2 - x1
           mov bx,esq                ; bx = y3
           sub bx,bp                 ; bx = y3 - y1
           movsx eax,ax
           movsx ebx,bx
           imul ebx                  ; ax = (x2-x1)*(y3-y1)
           sub ecx,eax               ; cx = (x3-x1)*(y2-y1)-(x2-x1)*(y3-y1)
           ret

; point rotation for eye - solves all x,y,z parameters
; ebx = x   ecx = y   ebp = z   32 bit rotation!
; clobbers dx,si,di,ax

           align 4

           public erotate

erotate:
           mov eax,ematrix+8
           imul ebp
           shrd eax,edx,14
           mov edi,eax
           if usez eq yes
           mov eax,ematrix+4
           imul ecx
           shrd eax,edx,14
           add edi,eax
           endif
           mov eax,ematrix+0
           imul ebx
           shrd eax,edx,14
           add edi,eax   ; di = new x

           mov eax,ematrix+20
           imul ebp
           shrd eax,edx,14
           mov esi,eax
           mov eax,ematrix+16
           imul ecx
           shrd eax,edx,14
           add esi,eax
           mov eax,ematrix+12
           imul ebx
           shrd eax,edx,14
           add esi,eax   ; si = new y

           mov eax,ematrix+32
           imul ebp
           shrd eax,edx,14
           mov ebp,eax
           mov eax,ematrix+28
           imul ecx
           shrd eax,edx,14
           add ebp,eax
           mov eax,ematrix+24
           imul ebx
           shrd eax,edx,14
           add ebp,eax   ; bp = new z

           mov ecx,esi
           mov ebx,edi

           ret

; solve z from ematrix - same as above erotate but only solves z for fast
; test of where object is - result is in esi

           align 4

           public zsolve
           public ysolve
           public xsolve

zsolve:
           mov eax,ematrix+32
           imul ebp
           shrd eax,edx,14
           mov esi,eax
           mov eax,ematrix+28
           imul ecx
           shrd eax,edx,14
           add esi,eax
           mov eax,ematrix+24
           imul ebx
           shrd eax,edx,14
           add esi,eax   ; si = new z
           ret

; if object z test from above routine is positive, this routine will solve
; the rest of the rotation matrix.  this is so we don't waste time solving
; for x and y locations if the object is not within screen parameters.
; saves imuls

           align 4
xsolve:
           mov eax,ematrix+8
           imul ebp
           shrd eax,edx,14
           mov edi,eax
           if usez eq yes
           mov eax,ematrix+4
           imul ecx
           shrd eax,edx,14
           add edi,eax
           endif
           mov eax,ematrix+0
           imul ebx
           shrd eax,edx,14
           add edi,eax   ; di = new x
           ret

           align 4
ysolve:
           mov eax,ematrix+16
           imul ecx
           shrd eax,edx,14
           mov ecx,eax
           mov eax,ematrix+12
           imul ebx
           shrd eax,edx,14
           add ecx,eax
           mov eax,ematrix+20
           imul ebp
           shrd eax,edx,14
           add ecx,eax   ; cx = new y

           mov ebx,edi   ; final test, move into appropriate regs
           mov ebp,esi

           ret

; calculate sign into eax, from ax, smashes bx
; after imul by sign, shr eax,14 to compensate for decimal factor!

           align 4

           public cosign
           public sign

cosign:
           add ax,4000h
sign:
           shr ax,2
           cmp ax,2000h
           jge s q3o4         ; quadrant 3 or 4

           cmp ax,1000h
           jl s q0            ; quad 1

           mov bx,1fffh
           sub bx,ax
           jmp s halfsign     ; quad 2
q0:
           mov bx,ax
           jmp s halfsign
q3o4:
           cmp ax,3000h
           jl s q3
           mov bx,3fffh
           sub bx,ax
           call halfsign      ; quad 4
           neg eax
           ret
q3:
           and ax,0fffh
           mov bx,ax          ; quad 3
           call halfsign
           neg eax
           ret
halfsign:
           shl bx,1
           movsx eax,w sinus[bx]
           ret

; arctan, cx=rise,ax=run, returns ax as angle of triangle
; smashes cx,ax,dx,si

           align 4

           public arctan

arctan:
           cmp ax,0
           jl s qd2or3
           cmp cx,0
           jge s halftax      ; quadrant 1
           neg cx             ; quadrant 4, ax=-ax
           call halftan
           neg ax
           shl ax,2
           ret
qd2or3:
           neg ax
           cmp cx,0
           jge s qd2
           neg cx             ; quad 3, ax=ax+8192
           call halftan
           add ax,8192
           shl ax,2
           ret
qd2:
           call halftan
           neg ax
           add ax,8192
           shl ax,2
           ret
halftax:
           call halftan
           shl ax,2
           ret

           align 4

halftan:
           movsx eax,ax
           movsx ecx,cx
           mov edx,0

; cx=rise  positive
; ax=run   positive

           cmp eax,ecx
           jl s opptan        ; greater than 45 degrees, other side...

           xchg ecx,eax       ; ax<cx
           shl eax,10         ; *2048
           div ecx
           mov si,ax
           shl si,2
           mov ax,w negtan[si] ; resulting angle (0-512 is 0-45) in ax
           ret

           align 4

opptan:
           shl eax,10         ; *2048

           div ecx
           mov si,ax          ; ax remainder
           shl si,2
           mov cx,w negtan[si]
           mov ax,1000h
           sub ax,cx          ; resulting angle (2048-4096 is 45-90) in ax
           ret

           align 4

; generate object matrix, 12 imul's first

;              x                         y                      z
;
;x=  cz * cy - sx * sy * sz   - sz * cy - sx * sy * cz     - cx * sy
;
;y=         sz * cx                   cx * cz                - sx
;
;z=  cz * sy + sx * sz * cy   - sy * sz + sx * cy * cz       cx * cy
;
;then perform matrix multiply by negative x and z matricies
;
; -x matrix                             -z matrix
;     x       y       z                   x       y       z
;
;x    1       0       0                   cz     sz       0
;
;y    0      cx       sx                 -sz     cz       0
;
;z    0     -sx       cx                  0       0       1
;
; notice original object matrix takes 12 imuls, camera modify takes 24, can
; you do this faster? (less imuls)

           public compound

compound:
           push esi

           mov ax,vxs[esi]
           neg ax
           push ax
           call cosign
           mov vcosx,eax
           pop ax
           call sign
           mov vsinx,eax
           mov ebp,eax            ; bp = sx
           neg eax
           mov [vmatrix+20],eax

           mov ax,vzs[esi]
           neg ax
           push ax
           call cosign
           mov vcosz,eax
           mov edi,eax            ; di = cz
           pop ax
           call sign
           mov vsinz,eax
           mov edx,eax            ; dx = sz

           mov ax,vys[esi]
           neg ax
           add ax,eyeay
           push ax
           call cosign
           mov vcosy,eax
           pop ax
           call sign
           mov vsiny,eax          ; ax = sy

           mov ebx,edx            ; save sz

           mov ecx,eax            ; save sy

           imul ebx               ; bx = - sy * sz
           shr eax,14
           movsx ebx,ax
           neg ebx
           mov [vmatrix+28],ebx

           mov eax,ecx            ; si = cz * sy
           imul edi
           shr eax,14
           movsx esi,ax
           mov [vmatrix+24],esi

           mov eax,vcosy

           imul edi               ; di = cy * cz
           shr eax,14
           movsx edi,ax
           mov [vmatrix+0],edi

           mov eax,vsinz
           mov ecx,vcosy

           imul ecx               ; cx = - sz * cy
           shr eax,14
           movsx ecx,ax
           neg ecx
           mov [vmatrix+4],ecx

           mov eax,ebp
           imul esi
           shr eax,14
           movsx esi,ax
           neg esi
           add [vmatrix+4],esi

           mov eax,ebp
           imul edi
           shr eax,14
           movsx edi,ax
           add [vmatrix+28],edi

           mov eax,ebp
           imul ebx
           shr eax,14
           movsx ebx,ax
           add [vmatrix+0],ebx

           mov eax,ebp
           imul ecx
           shr eax,14
           movsx ecx,ax
           neg ecx
           add [vmatrix+24],ecx

           mov esi,vcosx

           mov eax,vcosy
           imul esi                   ; cx * cy
           shr eax,14
           movsx eax,ax
           mov [vmatrix+32],eax

           mov eax,vsiny
           imul esi                   ;-cx * sy
           shr eax,14
           movsx eax,ax
           neg eax
           mov [vmatrix+8],eax

           mov eax,vsinz
           imul esi                   ; cx * sz
           shr eax,14
           movsx eax,ax
           mov [vmatrix+12],eax

           mov eax,vcosz
           imul esi                   ; cx * cz
           shr eax,14
           movsx eax,ax
           mov [vmatrix+16],eax

           mov edi,ecosx              ; now perform camera x rotation,12 imuls
           mov esi,esinx
           mov ebp,esi
           neg ebp

           mov eax,[vmatrix+12]
           imul edi
           shr eax,14
           movsx ecx,ax

           mov eax,[vmatrix+24]
           imul esi
           shr eax,14
           movsx eax,ax

           add ecx,eax                ; ecx = new vmatrix+12

           mov eax,[vmatrix+12]
           imul ebp
           shr eax,14
           movsx ebx,ax

           mov eax,[vmatrix+24]
           imul edi
           shr eax,14
           movsx eax,ax

           add ebx,eax                ; ebx = new vmatrix+24

           mov [vmatrix+12],ecx
           mov [vmatrix+24],ebx

           mov eax,[vmatrix+16]
           imul edi
           shr eax,14
           movsx ecx,ax

           mov eax,[vmatrix+28]
           imul esi
           shr eax,14
           movsx eax,ax

           add ecx,eax                ; ecx = new vmatrix+16

           mov eax,[vmatrix+16]
           imul ebp
           shr eax,14
           movsx ebx,ax

           mov eax,[vmatrix+28]
           imul edi
           shr eax,14
           movsx eax,ax

           add ebx,eax                ; ebx = new vmatrix+28

           mov [vmatrix+16],ecx
           mov [vmatrix+28],ebx

           mov eax,[vmatrix+20]
           imul edi
           shr eax,14
           movsx ecx,ax

           mov eax,[vmatrix+32]
           imul esi
           shr eax,14
           movsx eax,ax

           add ecx,eax                ; ecx = new vmatrix+20

           mov eax,[vmatrix+20]
           imul ebp
           shr eax,14
           movsx ebx,ax

           mov eax,[vmatrix+32]
           imul edi
           shr eax,14
           movsx eax,ax

           add ebx,eax                ; ebx = new vmatrix+32

           mov [vmatrix+20],ecx
           mov [vmatrix+32],ebx

           if usez eq yes

           mov edi,ecosz              ; now perform camera z rotation,12 imuls
           mov esi,esinz
           mov ebp,esi
           neg esi

           mov eax,[vmatrix+0]
           imul edi
           shr eax,14
           movsx ecx,ax

           mov eax,[vmatrix+12]
           imul esi
           shr eax,14
           movsx eax,ax

           add ecx,eax

           mov eax,[vmatrix+0]
           imul ebp
           shr eax,14
           movsx ebx,ax

           mov eax,[vmatrix+12]
           imul edi
           shr eax,14
           movsx eax,ax

           add ebx,eax

           mov [vmatrix+0],ecx
           mov [vmatrix+12],ebx

           mov eax,[vmatrix+4]
           imul edi
           shr eax,14
           movsx ecx,ax

           mov eax,[vmatrix+16]
           imul esi
           shr eax,14
           movsx eax,ax

           add ecx,eax

           mov eax,[vmatrix+4]
           imul ebp
           shr eax,14
           movsx ebx,ax

           mov eax,[vmatrix+16]
           imul edi
           shr eax,14
           movsx eax,ax

           add ebx,eax

           mov [vmatrix+4],ecx
           mov [vmatrix+16],ebx

           mov eax,[vmatrix+8]
           imul edi
           shr eax,14
           movsx ecx,ax

           mov eax,[vmatrix+20]
           imul esi
           shr eax,14
           movsx eax,ax

           add ecx,eax

           mov eax,[vmatrix+8]
           imul ebp
           shr eax,14
           movsx ebx,ax

           mov eax,[vmatrix+20]
           imul edi
           shr eax,14
           movsx eax,ax

           add ebx,eax

           mov [vmatrix+8],ecx
           mov [vmatrix+20],ebx

           endif

           pop esi
           ret

; generate rotation matrix for  y,x,z  camera rotation
; called only once every frame.  completed in 12 multiplys
; matrix is also used for objects with no rotation (always angle 0,0,0)
;
; where is my postcard! see readme.doc for info.
;
;              x                    y                    z
;
;x=  cz * cy + sx * sy * sz     -cx * sz     - sy * cz + sx * cy * sz
;
;y=  sz * cy - sx * sy * cz      cx * cz     - sy * sz - sz * cy * cz
;
;z=         cx * sy                 sx                cx * cy
;

;  matrix offsets:
;
;     x  y  z
;
;x    0  4  8
;y   12 16 20
;z   24 28 32

           align 4

           public setsincose

setsincose:

           mov ax,eyeax
           call cosign
           mov ecosx,eax          ; ecosx and such are used by object rotation
           mov ax,eyeax           ; ematrix is used to find where object is
           call sign
           mov esinx,eax
           mov [ematrix+28],eax
           mov ebp,eax            ; bp = sx

           if usez eq yes
           mov ax,eyeaz
           call cosign
           mov ecosz,eax
           mov edi,eax            ; di = cz
           mov ax,eyeaz
           call sign
           mov esinz,eax
           mov edx,eax            ; dx = sz
           endif

           if usez eq no
           mov edi,4000h          ; di = cos 0
           mov ecosz,4000h
           xor edx,edx            ; dx = sin 0
           mov esinz,0
           endif

           mov ax,eyeay
           call cosign
           mov ecosy,eax
           mov ax,eyeay
           call sign
           mov esiny,eax          ; ax = sy

           mov ebx,edx            ; save sz

           mov ecx,eax            ; save sy

           imul ebx               ; bx = sy * sz
           shr eax,14
           movsx ebx,ax
           neg ebx
           mov [ematrix+20],ebx
           neg ebx

           mov eax,ecx            ; si = - (cz * sy)
           imul edi
           shr eax,14
           movsx esi,ax
           neg esi
           mov [ematrix+8],esi

           mov eax,ecosy

           imul edi               ; di = cy * cz
           shr eax,14
           movsx edi,ax
           mov [ematrix+0],edi

           mov eax,esinz
           mov ecx,ecosy

           imul ecx               ; cx = sz * cy
           shr eax,14
           movsx ecx,ax
           mov [ematrix+12],ecx

           mov eax,ebp
           imul esi
           shr eax,14
           movsx esi,ax
           add [ematrix+12],esi

           mov eax,ebp
           imul edi
           shr eax,14
           movsx edi,ax
           neg edi
           add [ematrix+20],edi

           mov eax,ebp
           imul ebx
           shr eax,14
           movsx ebx,ax
           add [ematrix+0],ebx

           mov eax,ebp
           imul ecx
           shr eax,14
           movsx ecx,ax
           add [ematrix+8],ecx

           mov esi,ecosx

           mov eax,ecosy
           imul esi                   ; cx * cy
           shr eax,14
           movsx eax,ax
           mov [ematrix+32],eax

           mov eax,esiny
           imul esi                   ; cx * sy
           shr eax,14
           movsx eax,ax
           mov [ematrix+24],eax

           mov eax,esinz
           imul esi                   ;-cx * sz
           shr eax,14
           movsx eax,ax
           neg eax
           mov [ematrix+4],eax

           mov eax,ecosz
           imul esi                   ; cx * cz
           shr eax,14
           movsx eax,ax
           mov [ematrix+16],eax

           neg esinx                  ; reverse angles for object rotation
           neg esiny

           ret

;getroot:                      ; get square root of ax, where ax = 0-65535
;           cmp ax,0fe01h      ; since ax cannot be negative anyway!
;           jae sqr255         ; routine requires squares tables.
;           mov si,offset squares
;           mov cx,ax
;           inc cx
;           cld
;nextroot:
;           lodsw
;           cmp ax,cx
;           jbe  nextroot      ; jb is exact but jbe is better approximation
;           mov ax,si
;           sub ax,offset squares+3
;           sar ax,1
;           ret
;sqr255:
;           mov ax,255
;           ret

; routine courtesy TRAN
;
; square root
; in:
;   eax - number to take root of
; out:
;   eax - root
;
sqrtbasetbl db 0,1,4,9,16,25,36,49,64,81,100,121,144,169,196,225

           public sqrt

           align 4

sqrt:
           pushad
           mov ebp,eax
           bsr ebx,eax
           jnz short sqrtf0
           xor ebx,ebx
sqrtf0:
           shr ebx,3
           lea eax,[ebx*8]
           mov cl,32
           sub cl,al
           rol ebp,cl
           mov eax,ebp
           movzx eax,al
           mov edi,offset sqrtbasetbl
           mov ecx,10h
sqrtl0:
           scasb
           je short sqrtl0d
           jb short sqrtl0d2
           loop sqrtl0
           inc edi
sqrtl0d2:
           dec edi
           inc cl
sqrtl0d:
           movzx edx,byte ptr [edi-1]
           dec cl
           xor cl,0fh
           mov edi,ecx
           mov ecx,ebx
           jecxz short sqrtdone
           sub eax,edx
sqrtml:
           shld eax,ebp,8
           rol ebp,8
           mov ebx,edi
           shl ebx,5
           xor edx,edx
           mov esi,eax
           div ebx
           rol edi,4
           add edi,eax
           add ebx,eax
sqrtf2:
           imul eax,ebx
           mov edx,eax
           mov eax,esi
           sub eax,edx
           jc short sqrtf1
           loop sqrtml
sqrtdone:
           mov [esp+28],edi
           popad
           ret
sqrtf1:
           dec ebx
           dec edi
           movzx eax,bl
           and al,1fh
           jmp sqrtf2

; solve for z when x = bx (takes a point/object on a y plane and figures
; where it would be if z = 16, y = precal7, only good for square translations)
; uses ematrix as rotation matrix

; cs set if not possible

; formula is inverse of z = bx6+cx7+bp8. where precal7 is y*7
; (16-bx(6)-precal7)/(8)=z

            public set_precal7
            public set_precal147
            public frotate
            public z16x
            public z16z

            public precal1
            public precal4
            public precal7

            align 4

precal1     dd 0
precal4     dd 0
precal7     dd 0

z16x:
            cmp ematrix+32,0
            je abort_attempt

            mov eax,ematrix+24
            imul ebx
            shrd eax,edx,14

            neg eax
            add eax,16
            sub eax,precal7

            cdq
            shld edx,eax,14
            mov ebx,ematrix+32
            idiv ebx

            stc
            ret
abort_attempt:
            clc
            ret

; solve for x when z = bp (takes a point/object on a y plane and figures
; where it would be if z = 16, y = precal7, only good for square translations)
; uses ematrix as rotation matrix. output solves for z = 16

; cs set if not possible

; formula is inverse of z = bx6+cx7+bp8. where precal7 is y*7
; (16-bp(8)-precal7)/(6)=x

            align 4

z16z:
            cmp ematrix+24,0
            je abort_attempt

            mov eax,ematrix+32
            imul ebp
            shrd eax,edx,14

            neg eax
            add eax,16
            sub eax,precal7

            cdq
            shld edx,eax,14
            mov ebx,ematrix+24
            idiv ebx

            stc
            ret

; set precal7 for plane transformation - plane is ecx and allows above formulas
; to determine where a point/object would be along that plane if z is negative

; good for runway translations or super huge background polygons - not used
; by regular 3d.asm routines

; how to use: lets say you've got a million background objects that are
; on the ground (or all on the same y plane).  you call set_precal147
; with that y plane location and use frotate instead of erotate to
; determine where points rotated along that plane will end up.  this
; speeds the routine up by 33% by cutting out 3 imuls.

            align 4

set_precal147:
            if usez eq yes
            mov eax,ecx
            sub eax,eyey
            imul ematrix+4
            shr eax,14
            mov precal1,eax
            endif

            mov eax,ecx
            sub eax,eyey
            imul ematrix+16
            shr eax,14
            mov precal4,eax

set_precal7:
            sub ecx,eyey
            mov eax,ecx
            imul ematrix+28
            shr eax,14
            mov precal7,eax
            ret

            align 4

; fast object/point rotation along pre-calculated y plane

frotate:
           mov eax,ematrix+8
           imul ebp
           shrd eax,edx,14
           mov edi,eax
           if usez eq yes
           add edi,precal1
           endif
           mov eax,ematrix+0
           imul ebx
           shrd eax,edx,14
           add edi,eax   ; di = new x

           mov eax,ematrix+20
           imul ebp
           shrd eax,edx,14
           mov esi,eax
           add esi,precal4
           mov eax,ematrix+12
           imul ebx
           shrd eax,edx,14
           add esi,eax   ; si = new y

           mov eax,ematrix+32
           imul ebp
           shrd eax,edx,14
           mov ebp,eax
           add ebp,precal7
           mov eax,ematrix+24
           imul ebx
           shrd eax,edx,14
           add ebp,eax   ; bp = new z

           mov ecx,esi
           mov ebx,edi

           ret

; fast solve for single matrix variable similar to erotate but uses frotate
; plane matrix with precal147
;
; remember , matrix offsets are:
;
;  0 1 2     multiply those by 4 four the doublewords
;  3 4 5
;  6 7 8
;
           public fzsolve
           public fxsolve
           public fysolve

           align 4

fzsolve:
           mov eax,ematrix+32      ; solve z = bx(6)+cx(7)+bp(8)
           imul ebp
           shrd eax,edx,14
           mov esi,eax
           add esi,precal7
           mov eax,ematrix+24
           imul ebx
           shrd eax,edx,14
           add esi,eax   ; si = new z
           ret

           align 4
fxsolve:
           mov eax,ematrix+8        ; solve x = bx(0)+cx(1)+bp(2)
           imul ebp
           shrd eax,edx,14
           mov edi,eax
           if usez eq yes
           add edi,precal1
           endif
           mov eax,ematrix+0
           imul ebx
           shrd eax,edx,14
           add edi,eax   ; di = new x
           ret

           align 4
fysolve:
           mov eax,ematrix+20       ; solve y = bx(3)+cx(4)+bp(5)
           imul ebp
           shrd eax,edx,14
           mov ecx,eax
           add ecx,precal4
           mov eax,ematrix+12
           imul ebx
           shrd eax,edx,14
           add ecx,eax   ; cx = new y

           mov ebx,edi
           mov ebp,esi

           ret

