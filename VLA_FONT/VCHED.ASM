        dosseg
        Locals
        .286

        SCROLLWIDTH = 200
        DISPLAYWIDTH = 160

stacks  segment byte stack 'stack'
        thestak         db  256 dup (0h)      ;just need a marker size =500 bytes
stacks  ends

code    segment byte public 'code'
        assume  cs:code, ds:code, es:code, ss:stacks
 
start:  
        mov     ax,es
        mov     ds,ax
        mov     cs:[dseg],ax
        mov     si,128
        lodsb
        xor     cx,cx
        mov     cl,al
        cmp     cx,20
        jbe     NotTooMuch
        mov     cx,19
NotTooMuch:
        mov     cs:[inputlength],cx
        mov     ax,cs
        mov     es,ax
        mov     di,offset inputstring
        rep     movsb

        mov     ax,cs
        mov     ds,ax
        mov     es,ax

        mov     bx,ss
        add     bx,20h
        mov     cs:[Charseg],bx
        add     bx,4000
        mov     cs:[charbakseg],bx
        add     bx,4000
        mov     cs:[scrollseg],bx

        jmp     main
        
;===- data -===

        Basex   equ     10
        Basey   equ     20
        Dseg    dw      0
        credits db      13,10,"TGA Palette Grabber",13,10
                db      "  By Ben Gardner",13,10,"$"
        grabtitle db    "    Character grabber by Ben Gardner$"

        cwidth  db      " Width: 00$"
        Height  db      "Height: 00$"  
        HitReturn db    "Hit [RETURN] when done.$"

        TopLine db      "C:  B:  "
        Charnum db      "CHAR: - - 00     00x00 W-00$"       ;28 chars

        
        colors  db      255
        properuse db    13,10,"VCH Character Editor:",13,10
                db      " Use: CHREDIT Filename (must be a VCH file)",13,10
                db      "Directory paths not supported.$",13,10,'$'

        inputstring  db 20 dup ('~'),"$","$"
        inputlength  dw 0
                        db      10 dup (0)

        VCHname db     "default.VCH",0,0,0,0,0,0,0 ,"$"

        ErrorLook dw    offset properuse,offset properuse,offset Nofile
                dw      offset Nopath,offset Nohandle,OFFSET Noaccess
        presskey db     13,10,"Press any key to return to dos.$"        
        
        nofile          db      10,13,"File not found error.$"
        nopath          db      10,13,"Path not found error.$"
        nohandle        db      10,13,"No handles available.$"
        noaccess        db      10,13,"Access to file denied.$"
        errormes        db      10,13,"Program aborted.$"
        diskfull        db      10,13,"Disk full.$"
        Warning         db      "ALL data may be messed up.",10,13
                        db      "     Resize anyway? (Y/N)$"

        NoPal   db      "File not found: "
        PalName  db     "default.Pal",0,0,0,0,0,0,"$"
                
        HEADLOAD        db      "VGACH" ;R"
        From            db      " "
        sizex           db      10
        sizey           db      10
        NumChars        db      64

        CHARWIDTH       db      255 dup(0)

        Curchar         db      0
        xpos            db      0
        ypos            db      0
        
        pal     db      768 dup (0)
        PALTMP  DB      768 DUP (0)

        Clip    db      1024 dup (0)

        borderx dw      0
        bordery dw      0
        borderxsize dw  0
        borderysize dw  0
        bordercolor db  0
        
        vgaseg  dw      0a000h
        Charseg dw      0
        Scrollseg dw    0
        CharbakSeg   dw      0
        
        Fadestep db     0

        XYsize  dw      0

        Scrollcount dw  DISPLAYWIDTH     ;used to count current stuff
        scrollSpeed dw  1       ;number of bytes to scroll per update
        Scrollletter dw 0       ;offset in scrollmsg for next char

        CurrentColor    db      0
        BackgroundColor db      0

        messoff dw      offset ScrollMsg2

        ScrollMsg db    " HELLO, GUYS! THIS CHARACTER SET EDITOR WAS CREATED BY" 
                DB      " DRAEDEN...  HERE IS A LITTLE HELP: F1: CUT, F2:PASTE, "
                DB      "F3: SHIFT LEFT, F4: SHIFT RIGHT, F5: SHIFT UP, F6: DOWN, "
                DB      "F7: FLIP VERTICLE, F8: FLIP HORIZONTAL, F9: GRAB COLOR UNDER CURSOR, "
                DB      "F10: RESTORE CURRENT CHAR, CONT-F1: SAVE FONT, [ AND ] CHANGE CURRENT "
                DB      "COLOR, CONT-[ AND ] CHANGE BACKGROUND COLOR, "
                DB      "LEFT SHIFT: WRITES CURRENT COLOR, RIGHT SHIFT: WRITES BACKGROUND COLOR, "
                DB      "CONT-Q: QUIT, "
                DB      "ARROW KEYS MOVE THE CURSOR, +/- "
                DB      "CHANGE CURRENT CHAR... SIMPLE ENOUGH... HERE'S THE CHARACTER SET: "

        Scrollmsg2 db      255 dup (0),0

;========- SubRoutines -========
Waitkey proc near
here:
        mov  ah,1
        int  16h                         ; has a key been pressed?
        jz   HERE                        ; no, goto HERE
        mov  ah,0
        int  16h                         ; yes, get the character
        ret
waitkey endp

CaptureFilename proc near
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     si,offset inputstring
        mov     di,offset VCHname
        xor     bl,bl
Nospace:
        lodsb
        cmp     al,'~'
        je      capdone
        cmp     al,'.'
        je      capdone
        cmp     al,' '
        je      nospace
        stosb 
        inc     bl
        cmp     bl,8
        jb      nospace
Capdone:
        mov     al,'.'
        stosb
        mov     al,'V'
        stosb
        mov     al,'C'
        stosb
        mov     al,'H'
        stosb
        mov     al,0
        stosb
        mov     al,'$'
        stosb
        mov     di,offset palname
        mov     si,offset VCHname
        mov     cx,14
        rep     movsb
        mov     di,offset palname+1     ;+1 to get past dot
        xor     bh,bh
        add     di,bx                   ;bx = 0 thru 7
        mov     al,'P'
        stosb
        mov     al,'A'
        stosb
        mov     al,'L'
        stosb
        ret
CaptureFileName endp

DisplayText proc near
        pusha
        mov     bl,ah           ;ah=xpos
        xor     bh,bh
        mov     cl,[sizey]
        mul     cl
        xor     ch,ch
        imul    ax,ax,320
        mov     di,ax
        mov     al,[sizex]
        mul     bl
        add     di,ax           ;screen location

        mov     ax,cs:[vgaseg]
        mov     es,ax

        mov     bx,dx           ;string location
displayloop:
        mov     al,cs:[bx]
        or      al,al
        je      Textdone
        sub     al,cs:[From];' '
        cmp     al,cs:[NUmCHARS] 
        ja      skipit
        
        call    putchar         ;al= frame # es:di is dest
        mov     cl,cs:[sizex]
        xor     ch,ch
        add     di,cx
skipit:
        inc     bx
        jmp     displayloop
TextDone:
        popa
        ret
DisplayText endp

        ;Destroys AX, DX, CX
PutChar proc near       ;al has char to print
        push    ds
        push    si
        push    di

        xor     ah,ah
        mov     dx,cs:[xysize]
        mul     dx
        mov     si,ax
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     cl,cs:[sizex]
        mov     ch,cs:[sizey]
        push    di
putloop:
        movsb
        dec     cl
        jne     putloop
        mov     cl,cs:[sizex]
        pop     di        
        add     di,SCROLLWIDTH
        push    di
        dec     ch
        jne     putloop

        pop     ax
        pop     di
        pop     si
        pop     ds
        ret
PutChar endp

        ;ES has segment to clear, al has byte to clear to
ClearVga proc near
        xor     di,di
        mov     ah,al
        mov     cx,32000
        rep     stosw
        ret
ClearVga endp

Scroll  proc near
        push    ds
        push    es
        mov     ax,cs:[scrollseg]
        mov     es,ax
        mov     ds,ax
        cld

        xor     di,di
        mov     si,cs:[scrollspeed]
        mov     cl,cs:[sizey]
        xor     ch,ch
        imul    cx,cx,SCROLLWIDTH/2
        rep     movsw

        mov     ax,cs:[scrollcount]     ;scrollcount-scrollspeed
        sub     ax,cs:[scrollspeed]
        push    ax
        cmp     ax,DISPLAYWIDTH
        ja      donescroll              ;dont need a new char yet
        
        mov     di,ax
tryagain:
        mov     bx,cs:[scrollletter]
        add     bx,cs:[messoff]
        inc     cs:[scrollletter]
        mov     al,cs:[bx]
        or      al,al
        jne     nozero
        mov     cs:[scrollletter],0
nozero:
        sub     al,' '
        cmp     al,cs:[numchars]
        jae     tryagain
        mov     bl,al
        xor     bh,bh
        mov     bl,cS:[CHARWIDTH+BX]
        pop     dx
        add     dx,bx
        mov     cs:[scrollcount],dx

        call    putchar
        jmp     byescroll
Donescroll:
        pop     ax
        mov     cs:[scrollcount],ax

byescroll:
        mov     ax,cs:[vgaseg]
        mov     es,ax

        xor     si,si
        mov     di,320*150+160-8
        
        mov     bl,cs:[sizey]
        mov     cx,160

        push    cx
scrcopy:
        pop     cx
        push    cx
        rep     movsb
        add     si,SCROLLWIDTH-DISPLAYWIDTH
        add     di,320-DISPLAYWIDTH
        dec     bl
        jne     scrcopy
        pop     cx
        pop     es
        pop     ds
        ret
scroll endp

FadeOut proc near
        push    ds
        push    es
        cld
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     bx,768
Foloop:
        cmp     [paltmp+bx],0
        je      nodec
        dec     [paltmp+bx]
nodec:
        dec     bx
        jne     Foloop
writetopal:
        mov     dx,03c8h
        mov     al,0
        out     dx,al
        inc     dx
        xor     cx,cx
        mov     si,offset paltmp
fadeem:
        lodsb
        out     dx,al
        inc     cx
        cmp     cx,768
        jbe     fadeem
        
        pop     es
        pop     ds
        ret
FadeOut endp

drawdot proc near
        push    es
        push    ax
        push    bx
        push    di
        mov     ax,0a000h
        mov     es,ax
        mov     al,dh
        xor     ah,ah
        xor     bh,bh
        shl     ax,2            ;blocks are 4 high
        add     ax,BASEY
        imul    ax,ax,320
        mov     bl,dl
        shl     bx,2            ;4 wide
        add     ax,bx
        add     ax,BASEx
        mov     di,ax
        mov     ah,cl
        mov     al,ah         
        stosw
        stosw
        add     di,316
        stosw
        stosw
        add     di,316
        stosw
        stosw
        add     di,316
        stosw
        stosw
        mov     al,dh
        xor     ah,ah
        add     ax,12
        imul    ax,ax,320
        add     ax,174
        mov     bl,dl
        xor     bh,bh
        add     ax,bx
        mov     di,ax
        mov     al,cl
        stosb
donedot:
        pop     di
        pop     bx
        pop     ax
        pop     es

        ret
drawdot endp

LOADDAT proc near
        mov     dx,offset VCHname      ;load in VCH set
        sub     al,al                   
        mov     ah,3dh                  
        int     21h                     
        jnc     noabort22
        jmp     abort
Noabort22:
        mov     bx,ax                   

        push    ds
        mov     ax,cs
        mov     ds,ax
        mov     cx,9
        mov     dx,offset HEADLOAD      ;read Header
        mov     ah,3fh
        int     21h

        mov     al,cs:[sizex]
        mov     ah,cs:[sizey]
        mul     ah
        mov     dl,cS:[numChars]
        xor     dh,dh
        mul     dx

        mov     cx,ax

        mov     ax,cs:[Charseg]
        mov     ds,ax
        xor     dx,dx    
        mov     ah,3fh               
        int     21h                  

        push    es   
        mov     CL,Cs:[NUMCHARS]
        XOR     CH,CH
        mov     al,cs:[sizex]
        mov     dx,cs
        mov     es,dx
        mov     di,offset CHARWIDTH
        rep     stosb           ;set all charwidth to data sizex
        
        mov     cx,ax
        mov     ax,cS:[charbakseg]
        mov     es,ax
        xor     di,di
        mov     si,di
        rep     movsb

        mov     ax,cs
        mov     ds,ax
        mov     cl,cs:[numchars]
        mov     ch,0
        mov     dx,offset CHARWIDTH      ;read Header
        mov     ah,3fh
        int     21h
        
        pop     es
        pop     ds
        
        mov     ah,3eh                  ;close source file 
        int     21h                     
        
        mov     dx,offset Palname       ;Load in Pal
        sub     al,al
        mov     ah,3dh
        int     21h
        jc      abortpal
        mov     bx,ax

        push    ds
        mov     ax,cs
        mov     ds,ax
        mov     cx,768
        mov     dx,offset pal
        mov     ah,3fh
        int     21h
        mov     ds:pal[768],63
        mov     ds:pal[767],63
        mov     ds:pal[766],63
        pop     ds

        mov     ah,3eh
        int     21h
        ret
abort:
        push    ax
        mov     ah,3eh
        int     21h
        pop     ax
        cmp     ax,6
        jb      displayerror
        pop     bx                      ;get rid of ret address
        jmp     noinput
Abortpal:
        mov     ax,cs
        mov     ds,ax
        mov     dx,offset Nopal
        mov     ah,9
        int     21h
        jmp     byebye2
Displayerror:
        mov     bx,ax
        shl     bx,1
        mov     dx,errorlook[bx]
        mov     ah,9                    ; Print string
        int     21h                     ; 
        mov     ah,9
        mov     dx,offset errormes
        int     21h
        jmp     noinput
loaddat endp

header  db      "VGACH 000"

SaveDat proc near
        mov     ax,cs
        mov     es,ax
        mov     ds,ax
        mov     al,cs:[sizex]
        mov     cs:[header+6],al        ;xsize
        mov     al,cs:[sizey]
        mov     cs:[header+7],al        ;ysize
        mov     al,cs:[numchars]
        mov     cs:[header+8],al        ;number of chars

        mov     dx,offset vChname 
        sub     cx,cx             
        mov     ah,3ch                  ;open file
        int     21h                     
        jc      abort                   
        mov     bx,ax          
                
        mov     ax,cs                   ;write header
        mov     ds,ax
        mov     dx,offset headload
        mov     cx,9
        mov     ah,40h
        int     21h

        mov     al,cs:[sizey]           ;figure size
        mov     ah,cs:[sizex]
        mul     ah
        mov     dl,cS:[numchars]
        xor     dh,dh
        mul     dx
        mov     cx,ax                   ; the dest file
        push    ds
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     ah,40h                  ; load function write
        xor     dx,dx
        int     21h                     ; write it

        mov     ax,cs
        mov     ds,ax
        mov     dx,offset CHARWIDTH
        mov     cl,cs:[numchars]
        mov     ch,0
        mov     ah,40h
        int     21h

        pop     ds
        
        cmp     ax,cx
        je      success
        mov     ah,9                    ; disk full error
        mov     dx,offset diskfull      ;
        int     21h                     ; 
success:
        mov     ah,3eh                  ;close source file 
        int     21h
        ret
SaveDat endp

Clearscreen proc near
        push    ax
        push    di
        push    es
        push    cx
        mov     ax,0a000h
        mov     es,ax        
        xor     di,di
        mov     cx,32000
        mov     ax,dx
        rep     stosw
        pop     cx
        pop     es
        pop     di
        pop     ax
        ret
Clearscreen endp

DisplayMain proc near
        push    es
        push    ds
        mov     ax,cs
        mov     es,ax
        mov     ds,ax

        mov     al,cs:[curchar]
        mov     ah,al
        add     ah,cs:[From]    ;' '
        mov     cs:[charnum+7],ah
        xor     ah,ah
        mov     al,cs:[curchar]
        mov     bl,10
        div     bl
        add     al,'0'
        add     ah,'0'
        mov     cs:[charnum+10],al
        mov     cs:[charnum+11],ah

        mov     bl,cs:[curchar]
        xor     bh,bh
        mov     al,cs:[CHARWIDTH+bx]
        xor     ah,ah
        mov     bl,10
        div     bl
        add     al,"0"
        add     ah,"0"
        mov     cs:[charnum+25],al
        mov     cs:[charnum+26],ah
        
        mov     ax,1300h
        mov     dx,0000h        
        mov     bl,cs:[colors]
        xor     bh,bh
        mov     cx,35
        push    bp
        mov     bp,offset topline
        int     10h             ;displays "CHAR: -?- 00 ...

        pop     bp

        call    BigandLittle
        
   ;this puts on all the borders     
        mov     cs:[borderx],basex
        mov     cs:[bordery],basey
        mov     al,cs:[sizex]
        xor     ah,ah
        shl     ax,2
        mov     cs:[borderxsize],ax
        mov     al,cs:[sizey]
        shl     ax,2
        mov     cs:[borderysize],ax
        mov     al,cs:[colors]
        mov     cs:[bordercolor],al
        call    borderit
        
        mov     cs:[borderx],174
        mov     cs:[bordery],12
        shr     cs:[borderxsize],2
        shr     cs:[borderysize],2
        call    borderit
        call    colorbox

        pop     ds
        pop     es
        ret
Displaymain endp
            
BigandLittle proc near
        push    ds
        mov     al,cs:[sizex]
        mov     ah,cs:[sizey]
        mul     ah
        mov     bl,cs:[curchar]
        xor     bh,bh
        imul    bx
        mov     si,ax
        mov     ax,cs:[charseg]
        mov     ds,ax
        xor     dx,dx
bigloop:
        mov     cl,ds:[si]
        inc     si
        call    drawdot
        inc     dl
        cmp     dl,cs:[sizex]
        jb      bigloop
        xor     dl,dl
        inc     dh
        cmp     dh,cs:[sizey]
        jb      bigloop
        pop     ds
        ret
BigandLittle endp

Grabit proc near        ;gets current char and puts it on the 'CLIP'
        push    ds
        push    es
        mov     ax,cs:[Charseg]
        mov     ds,ax
        mov     ax,cs
        mov     es,ax

        mov     ax,cs:[xysize]
        mov     cx,ax
        mov     bl,cs:[curchar]
        xor     bh,bh
        mul     bx
        mov     si,ax
        mov     di,offset clip

        rep     movsb
        
        pop     es
        pop     ds
        ret
Grabit endp

Pasteit proc near        ;puts 'CLIP' in current char
        push    ds
        push    es
        mov     ax,cs:[Charseg]
        mov     es,ax
        mov     ax,cs
        mov     ds,ax

        mov     ax,cs:[xysize]
        mov     cx,ax
        mov     bl,cs:[curchar]
        xor     bh,bh
        mul     bx
        mov     di,ax
        mov     si,offset clip

        rep     movsb
        
        pop     es
        pop     ds
        ret
Pasteit endp

Borderit proc near
        push    es
        mov     ax,0a000h
        mov     es,ax
        mov     ax,cs:[bordery]
        sub     ax,2            ;width of border
        imul    ax,ax,320
        add     ax,cs:[borderx]
        mov     di,ax
        sub     di,2            ;width of border
        mov     cx,cs:[borderxsize]
        mov     bx,cs:[borderysize]
        add     bx,2
        add     cx,4
        mov     al,cs:[bordercolor]
        push    di
        rep     stosb
borloop:
        pop     di
        add     di,320
        push    di
        stosb
        add     di,cs:[borderxsize]
        add     di,2
        stosb
        dec     bx
        jne     borloop
        pop     di
        add     di,320
        mov     cx,cs:[borderxsize]
        add     cx,4
        rep     stosb
        pop     es
        ret
Borderit endp
        oldxpos db      0
        oldypos db      0
        oldcolor db     0
        cursorcolor db  0


mOVECURSOR PROC  NEAR
        mov     dl,cs:[oldxpos]
        mov     dh,cs:[oldypos]
        mov     cl,cs:[oldcolor]
        call    drawdot
        inc     cs:[cursorcolor]
        cmp     cs:[cursorcolor],16
        jb      ccok
        mov     cs:[cursorcolor],0
ccok:
        mov     dl,cs:[xpos]
        mov     dh,cs:[ypos]
        mov     cl,cs:[cursorcolor]
        mov     cs:[oldxpos],dl
        mov     cs:[oldypos],dh
        call    drawdot

        push    ds
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     al,cs:[curchar]    ;si= curchar*xsize*ysize+ypos*xsize+xpos
        mov     ah,cs:[sizex]
        mul     ah
        mov     bl,cs:[sizey]
        xor     bh,bh
        mul     bx
        mov     si,ax
        mov     al,cs:[sizex]
        mov     ah,cs:[ypos]
        mul     ah
        add     si,ax
        xor     ah,ah
        mov     al,cs:[xpos]
        add     si,ax
        mov     al,ds:[si]
        pop     ds
        mov     cs:[oldcolor],al
        ret
MoveCursor endp

DrawColor proc near
        push    ds
        push    ax
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     al,cs:[curchar]    ;si= curchar*xsize*ysize+ypos*xsize+xpos
        mov     ah,cs:[sizex]
        mul     ah
        mov     bl,cs:[sizey]
        xor     bh,bh
        mul     bx
        mov     si,ax
        mov     al,cs:[sizex]
        mov     ah,cs:[ypos]
        mul     ah
        add     si,ax
        xor     ah,ah
        mov     al,cs:[xpos]
        add     si,ax
        pop     ax
        mov     ds:[si],al
        pop     ds
        ret
DrawColor endp
              
ColorBox proc near
        mov     ax,0a000h
        mov     es,ax
        mov     di,18
        mov     al,cs:[currentcolor]
        mov     ah,al
        mov     cx,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        mov     di,50
        mov     al,cs:[backgroundcolor]
        mov     ah,al
        mov     cx,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        add     di,312
        mov     cl,4
        rep     stosw
        mov     di,cs:[oldcpalpos]
        xor     ax,ax
        stosw
        add     di,318
        stosw
        add     di,319
        stosb
        mov     di,cs:[oldbpalpos]
        xor     ax,ax
        ;stosw
        add     di,320
        stosw
        add     di,318
        stosb

        mov     al,cs:[currentcolor]
        mov     dl,al
        xor     ah,ah
        mov     bh,40
        div     bh      ;al has ypos ah has xpos
        xor     bh,bh
        mov     bl,ah
        xor     ah,ah
        shl     bx,2    ;multiply by 4 to get real xpos
        shl     ax,3    ;multiply by 8 to get real ypos
        add     ax,76
        imul    ax,ax,320
        add     ax,bx
        add     ax,160-10
        mov     di,ax
        mov     cs:[oldcpalpos],di
        mov     al,255
        mov     ah,al
        stosw
        add     di,318
        stosw
        add     di,319
        stosb
        mov     al,cs:[Backgroundcolor]
        mov     dl,al
        mov     bh,40
        xor     ah,ah
        div     bh      ;al has ypos ah has xpos
        xor     bh,bh
        mov     bl,ah
        xor     ah,ah
        shl     bx,2    ;multiply by 4 to get real xpos
        shl     ax,3    ;multiply by 8 to get real ypos
        add     ax,76
        imul    ax,ax,320
        add     ax,bx
        add     ax,160-10
        mov     di,ax
        add     di,2
        mov     cs:[oldbpalpos],di
        mov     al,255
        mov     ah,al
        ;stosw
        add     di,320
        stosw
        add     di,318
        stosb

        ret
Colorbox endp

        oldcpalpos dw   0
        oldbpalpos dw   0

DisplayPalette proc near
        mov     ax,0a000h
        mov     es,ax

        mov     di,80*320+150
        xor     ax,ax
        mov     bl,40
        mov     dx,di
        push    di
Lineit:
        stosw
        stosw
        add     di,316
        stosw
        stosw
        add     di,316
        stosw
        stosw
        add     di,316
        stosw
        stosw
        pop     di
        add     di,4
        push    di
        inc     al
        or      al,al
        je      donepal
        mov     ah,al
        dec     bl  
        jne     lineit

        mov     bl,40
        pop     di
        mov     di,dx
        add     di,320*8
        mov     dx,di
        push    di
        jmp     lineit
        
DonePal:
        pop     di
        ret
DisplayPalette endp

ShLEFT proc near
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     es,ax
        mov     ax,cs:[xysize]
        mov     cl,cs:[curchar]
        xor     ch,ch
        mul     cx
        mov     di,ax
        mov     si,ax
        xor     ch,ch
        mov     dh,cs:[sizey]
Shlit:
        lodsb     
        mov     dl,al
        mov     cl,cs:[sizex]
        dec     cx
        rep     movsb
        mov     al,dl
        stosb
        dec     dh
        jne     shlit
        ret
Shleft endp

ShRight proc near
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     es,ax
        mov     ax,cs:[xysize]
        mov     cl,cs:[curchar]
        xor     ch,ch
        inc     cx
        mul     cx
        dec     ax
        mov     di,ax
        mov     si,ax
        xor     ch,ch
        mov     dh,cs:[sizey]
        std
Shrit:
        lodsb     
        mov     dl,al
        mov     cl,cs:[sizex]
        dec     cx
        rep     movsb
        mov     al,dl
        stosb
        dec     dh
        jne     shrit
        cld
        ret
ShRight endp

Shup proc near
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     ax,cs
        mov     es,ax
        mov     ax,cs:[xysize]
        mov     bl,cs:[curchar]
        xor     bh,bh
        mul     bx
        push    ax
        mov     di,offset updownbuff
        mov     si,ax
        mov     cl,cs:[sizex]
        xor     ch,ch
        rep     movsb

        pop     di
        mov     ax,ds
        mov     es,ax
        mov     cx,cs:[xysize]
        mov     bl,cs:[sizex]
        sub     cx,bx
        rep     movsb
        mov     ax,cs
        mov     ds,ax
        mov     si,offset updownbuff
        mov     cl,cs:[sizex]
        xor     ch,ch
        rep     movsb
        ret
Shup endp
        upDownBuff db   32 dup (0)
Shdown proc near
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     ax,cs
        mov     es,ax

        mov     ax,cs:[xysize]
        mov     bl,cs:[curchar]
        xor     bh,bh
        inc     bx
        mul     bx
        dec     ax              ;ax points to last byte in char
        mov     di,offset updownbuff+31
        mov     si,ax
        push    ax
        std
        mov     cl,cs:[sizex]
        xor     ch,ch
        rep     movsb           ;copies bottom row

        pop     di              ;start write on bottom row
        mov     si,di           ;si points to 1st byte in 2nd from bottom
        mov     bl,cs:[sizex]
        xor     bh,bh
        sub     si,bx

        mov     ax,ds
        mov     es,ax
        mov     cx,cs:[xysize]
        mov     bl,cs:[sizex]
        xor     bh,bh
        sub     cx,bx
        rep     movsb           ;repeat xysize-sizex times

        mov     ax,cs
        mov     ds,ax
        mov     si,offset updownbuff+31
        mov     cl,cs:[sizex]
        xor     ch,ch
        mov     ax,cs:[xysize]
        mov     bl,cs:[curchar]
        xor     bh,bh
        mul     bx
        add     ax,cx
        mov     di,ax
        dec     di
        rep     movsb   ;end of 1st line

        cld
        ret
Shdown endp
        
FlipHorz proc near      ;uses updownbuff
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     ax,cs
        mov     es,ax

        mov     di,offset updownbuff
        mov     ax,cs:[xysize]
        mov     bl,cs:[curchar]
        xor     bh,bh
        mul     bx
        mov     si,ax
        mov     dl,cs:[sizey]
        cld
revbigloop:
        push    si
        mov     cl,cs:[sizex]
        xor     ch,ch
        push    cx
        rep     movsb
        pop     cx
        pop     si
        push    si
        
        dec     di

revloop:
        mov     al,es:[di]
        mov     ds:[si],al
        inc     si
        dec     di
        dec     cx
        jne     revloop
        pop     si
        mov     bl,cs:[sizex]
        xor     bh,bh
        add     si,bx
        mov     di,offset updownbuff
        dec     dl
        jne     revbigloop
        ret
FlipHorz endp
        Clip2   db 1024 dup (0)

FlipVert proc near
        call    fliphorz
        mov     ax,cs:[charseg]
        mov     ds,ax
        mov     ax,cs
        mov     es,ax
        mov     ax,cs:[xysize]
        mov     cx,ax
        mov     bl,cs:[curchar]
        xor     bh,bh
        mul     bx
        mov     si,ax
        push    si
        push    cx
        mov     di,offset clip2
        cld
        rep     movsb
        pop     cx
        pop     si
        dec     di
flipvloop:
        mov     al,es:[di]
        mov     ds:[si],al
        dec     di
        inc     si
        dec     cx
        jne     flipvloop
        ret
Flipvert endp

RestoreChar proc near
        pusha

        MOV     ax,cs:[charseg]
        mov     es,ax
        mov     ax,cs:[charbakseg]
        mov     ds,ax

        mov     ax,cs:[xysize]
        mov     cx,ax
        mov     bl,cs:[curchar]
        xor     bh,bh
        mul     bx
        mov     si,ax
        mov     di,ax
        rep     movsb

        popa
        ret
restorechar endp

Clearchar proc near
        pusha
        mov     ax,cs:[charseg]
        mov     es,ax
        mov     ax,cs:[xysize]
        mov     cx,ax
        mov     bl,cs:[curchar]
        xor     bh,bh
        mul     bx
        mov     di,ax
        xor     ax,ax
        rep     stosb
        popa
        ret
Clearchar endp

        

;============================
Main:
        cmp     cs:[inputlength],0
        je      defaultfile
             
Gotsome:
        mov     ax,cs
        mov     es,ax
        mov     ds,ax
        call    capturefilename
defaultfile:
        call    loaddat
        mov     al,cs:[sizex]
        mov     ah,cs:[sizey]
        mul     ah
        mov     cs:[xysize],ax

        mov     al,cs:[sizex]
        xor     ah,ah
        mov     bl,10
        div     bl
        add     al,'0'
        add     ah,'0'
        mov     cs:[charnum+17],al
        mov     cs:[charnum+18],ah
        
        mov     al,cs:[sizey]
        xor     ah,ah
        mov     bl,10
        div     bl
        add     al,'0'
        add     ah,'0'
        mov     cs:[charnum+20],al
        mov     cs:[charnum+21],ah
        
        mov     ax,0013h                ;put in 320x200x256 VGA mode
        int     10h

        cld
        mov     ax,cs        
        mov     ds,ax
        mov     es,ax
        mov     si,offset pal
        mov     di,offset paltmp
        mov     cx,768/2
        rep     movsw                   ;copy for fade out

        MOV     AX,cs:[scrollseg]
        mov     es,ax
        xor     di,di
        mov     cx,160*31       ;max scroll area
        xor     ax,ax
        rep     stosw           ;clear scroll area
        
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     dx,offset pal
        mov     ax,1012h                ; WRITE BLOCK 
        mov     bx,0                    ; READ WOULD BE 1017H
        mov     cx,256                  ;
        int     10h                     ; end set up palette

        mov     dx,0
        call    Clearscreen

        call    colorbox
        call    displaypalette

        push    es
        mov     ax,cs
        mov     es,ax
        mov     di,offset scrollmsg2
        mov     cl,cs:[numchars]
        xor     ch,ch
        add     di,cx
        std
setupmsgloop:
        mov     al,cl
        add     al,cs:[From]    ;" "
        stosb
        dec     cl
        jne     setupmsgloop
        mov     al," "
        stosb
        pop     es
        cld

NormalStart:

        call    displaymain
WaitforKey:
        mov     dx,03dah
vr1:    in      al,dx
        and     al,08
        jz      vr1

        call    scroll
        CALL    MOVECURSOR

        xor     ax,ax
        mov     es,ax
        mov     al,es:[417h]
        test    al,00000010b    ;checks left shift
        je     Alton
        mov     al,cs:[currentcolor]
        mov     cs:[oldcolor],al
        call    drawcolor
        jmp     keystuff
Alton:
        test    al,00000001b    ;checks right shift
        je     keystuff
        mov     al,cs:[backgroundcolor]
        mov     cs:[oldcolor],al
        call    drawcolor
KeyStuff:
        mov     ah,1
        int     16h
        jz      waitforkey     
        mov     ah,0
        int     16h                      
        
        or      al,al           ;checks to see if al=0
        jne     notaux
        jmp     AuxKeys
NotAux:
        cmp     al,17   ;control-Q Quit
        jne     Chk1
        mov     cs:[fadestep],64
        jmp     byebyef
Chk1:
        cmp     al,'1'
        jne     Chk2
        inc     cs:[scrollspeed]
        mov     al,cs:[sizex]
        xor     ah,ah
        cmp     cs:[scrollspeed],ax
        jb      @@s
        dec     ax
        mov     cs:[scrollspeed],ax
@@s:
        jmp     Waitforkey
Chk2:
Chk3:
        cmp     al,'+'
        jne     Chk4
        inc     cs:[curchar]
        mov     al,cs:[numchars]
        cmp     cs:[curchar],al
        jb      @@s
        mov     cs:[curchar],0
@@s:
        call    displaymain
        jmp     waitforkey
Chk4:
        cmp     al,'-'
        jne     Chk5
        dec     cs:[curchar]
        mov     al,cs:[numchars]
        cmp     cs:[curchar],al
        jb      @@s
        mov     al,cs:[numchars]
        dec     al
        mov     cs:[curchar],al
@@s:
        call    displaymain
        jmp     waitforkey
Chk5:
        cmp     al,"*"
        jne     chk6
        mov     ax,cS:[messoff]
        mov     cs:[messoff],offset scrollmsg2
        cmp     ax,offset scrollmsg
        je      itsdone
        mov     cs:[messoff],offset scrollmsg
itsdone:
        mov     cs:[scrollletter],0
        jmp     waitforkey
chk6:
        cmp     al,'['
        jne     chk7
        dec     cs:[currentcolor]
        call    colorbox
        jmp     waitforkey
chk7:
        cmp     al,']'
        jne     chk8
        inc     cs:[currentcolor]
        call    colorbox
        jmp     waitforkey
chk8:
        cmp     al,'2'
        jne     Chk9
        dec     cs:[scrollspeed]
        jne     @@s
        mov     cs:[scrollspeed],1
@@s:
        jmp     Waitforkey
Chk9:
        cmp     al,27
        jne     chk10
        dec     cs:[backgroundcolor]
        call    colorbox
        jmp     waitforkey
chk10:
        cmp     al,29
        jne     chk11
        inc     cs:[backgroundcolor]
        call    colorbox
        jmp     waitforkey
Chk11:
        cmp     al,"3"
        jne     chk12
        mov     bl,cs:[curchar]
        xor     bh,bh
        dec     cs:[CHARWIDTH+BX]
        CALL    displaymain
        jmp     waitforkey
chk12:
        cmp     al,"4"
        jne     chk13
        mov     bl,cs:[curchar]
        xor     bh,bh
        inc     cs:[charwidth+bx]
        CALL    displaymain
        jmp     waitforkey
chk13:
        jmp     waitFORkey

AuxKeys:
        cmp     ah,72   ;up
        jne     AChk1
        dec     cs:[ypos]
        mov     al,cs:[sizey]
        cmp     cs:[ypos],al
        jb      @@s
        dec     al
        mov     cs:[ypos],al
@@s:
        jmp     waitforkey
AChk1:
        cmp     ah,80   ;down
        jne     AChk2
        inc     cs:[ypos]
        mov     al,cs:[sizey]
        cmp     cs:[ypos],al
        jb      @@s
        mov     cs:[ypos],0
@@s:
        jmp     waitforkey
AChk2:
        cmp     ah,75   ;left
        jne     Achk3
        dec     cs:[xpos]
        mov     al,cs:[sizex]
        cmp     cs:[xpos],al
        jb      @@s
        dec     al
        mov     cs:[xpos],al
@@s:
        jmp     waitforkey
AChk3:
        cmp     ah,77   ;right
        jne     Achk4
        inc     cs:[xpos]
        mov     al,cs:[sizex]
        cmp     cs:[xpos],al
        jb      @@s
        mov     cs:[xpos],0
@@s:
        jmp     waitforkey
Achk4:
        cmp     ah,94   ;c-f1 save
        jne     Achk5
        call    SaveDat
        jmp     NormalStart
Achk5:  
        cmp     ah,59   ;F1
        jne     Achk6
        call    grabit
        jmp     NormalStart
Achk6:
        cmp     ah,60
        jne     Achk7
        call    pasteit
        jmp     Normalstart
Achk7:
        cmp     ah,61
        jne     Achk8
        call    shleft
        jmp     Normalstart
Achk8:
        cmp     ah,62
        jne     Achk9
        call    shright
        jmp     NormalStart
Achk9:
        cmp     ah,63
        jne     Achk10
        call    shup
        jmp     NormalStart
Achk10:
        cmp     ah,64
        jne     Achk11
        call    shdown
        jmp     NormalStart
Achk11:
        cmp     ah,65
        jne     Achk12
        call    FlipVert
        jmp     NormalStart
Achk12:
        cmp     ah,66
        jne     Achk13
        call    FlipHorz
        jmp     Normalstart
Achk13:
        cmp     ah,67
        jne     Achk14
        mov     al,cs:[oldcolor]
        mov     cs:[currentcolor],al
        jmp     Normalstart
Achk14:
        cmp     ah,68   ;F10
        jne     Achk15
        call    restorechar
        jmp     normalstart
Achk15:
        cmp     ah,95   ;backspace
        jne     Achk16
        call    clearchar
        jmp     normalstart
Achk16:
Nokeypress:
        jmp     waitforkey
endit:
Byebye:
        mov     ax,0003h                ;reset screen to text
        int     10h
byebye2:
        mov     ax,cs
        mov     ds,ax
        mov     ax,4c00h                ; return control to 
        int     21h                     ; DOS and exit

Noinput:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     ah,9
        mov     dx,offset properuse
        int     21h
        jmp     byebye2
byebyef:
        jmp     ByeBye

        mov     dx,03dah
vr2:    in      al,dx
        and     al,08
        jz      vr2
        call    fadeout
        call    scroll
        
        dec     cs:[fadestep]
        jne     byebyef
        jmp     byebye

code    ends
        end     start
