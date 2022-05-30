;=========================================================================
; XSCALE1.ASM by John A. Slagel, jas37876@uxa.cso.uiuc.edu
; This is some code to do bitmap scaling in VGA Mode X.  It can scale a
; bitmap of any size down to 2 pixels wide, or up to thousands of pixels
; wide.  It performs complete clipping, with only a small constant amount
; of time to clip, no matter how huge the image is.  It draws column by
; column to reduce the number of plane switches, which are slow. The inner
; column loop has been optimized for no memory accesses, except to read or
; write a pixel.  This uses MASM 5.1 features, and can be compiled in any
; memory model by changing the .MODEL line, but make sure that you always
; pass a far pointer to the bitmap data, regardless of memory model.
; C-callable as:
;   void XSCALE1( int X, int Y, int DW, int DY,
;                     int SW, int SH, void far * Bitmap );
; X,Y   are the upper left-hand coordinates of where to draw the bitmap.
; DW,DH are the width and height of the SCALEed bitmap
; SW,SH are the width and height of the source bitmap.
; Bitmap is a pointer to the bitmap bits.
;
; Routine has been modified for 32 bit protected mode by John McCarthy.
; John McCarthy thanks John A. Slagel for providing this code, and hopes
; John A. Slagel is not offended by the changes.
;
;==========================================================================

            public draw_scale
            public tdraw_scale
            public xscale1
            public xscale2
            public repeat_bitmap

; uses edi esi, destx:word, desty:word,
; destwidth:word, destheight:word,
; sourcewidth:word, sourceheight:word,
; bitmap:far ptr

draw_scale:
        mov bitmap,esi
        mov destwidth,ax
        mov destheight,bx
        mov destx,cx
        mov desty,dx

xscale1:
        cmp     destwidth, 2        ; if destination width is less than 2
        jl      done                ;     then don't draw it.

        cmp     destheight, 2       ; if destination height is less than 2
        jl      done                ;     then don't draw it.

        mov     ax, desty           ; if it is completely below the
        cmp     ax, clipbt          ; lower clip bondry,
        jg      done                ;     then don't draw it.

        add     ax, destheight      ; if it is above clip boundries
        dec     ax                  ;     then don't draw it.
        cmp     ax, cliptp
        jl      done

        mov     ax, destx           ; if it is to the right of the
        mov     cx, cliprt          ; right clip boundry
        cmp     ax, cliprt          ;     then don't draw it.
        jg      done

        add     ax, destwidth       ; if it is completely to the left
        dec     ax                  ; of the left clip boundry,
        cmp     ax, cliplt          ;     then don't draw it.
        jl      done

        mov     esi, bitmap         ; make esi point to bitmap data
        lodsw                       ; get source x width
        mov     sourcewidth,ax
        lodsw                       ; get source y height
        mov     sourceheight,ax

        mov     ax, destwidth       ; clippedwidth is initially set to
        mov     clippedwidth, ax    ; the requested dest width.

        shl     ax,1                ; initialize the x decision var
        neg     ax                  ; to be -2*destwidth
        mov     decisionx, ax       ;

        mov     ax, destheight      ; clippedheight is initially set to
        mov     clippedheight, ax   ; the requested dest size.

        shl     ax,1                ; initialize the y decision var
        neg     ax                  ; to be -2*destheight
        mov     decisiony, ax       ;

        movsx   eax, cliptp         ; if y is below the top
        mov     edx, eax            ; clipping boundry, then we don't
        sub     dx, desty           ; need to clip the top, so we can
        js      s notopclip         ; jump over the clipping stuff.

        mov     desty, ax           ; this block performs clipping on the
        sub     clippedheight, dx   ; top of the bitmap.  i have heavily
        movsx   ecx, sourceheight   ; optimized this block to use only 4
        imul    ecx, edx            ; 32-bit registers, so i'm not even
        mov     eax, ecx            ; gonna try to explain what it's doing.
        cdq                         ; but i can tell you what results from
        movsx   ebx, destheight     ; this:  the decisiony var is updated
        idiv    ebx                 ; to start at the right clipped row.
        movsx   edx, sourcewidth    ; y is moved to the top clip
        imul    edx, eax            ; boundry. clippedheight is lowered since
        add     esi, edx            ; we won't be drawing all the requested
        imul    eax, ebx            ; rows. esi is changed to point over
        sub     ecx, eax            ; the bitmap data that is clipped off.
        sub     ecx, ebx            ;
        shl     ecx, 1              ;
        mov     decisiony, cx       ; <end of top clipping block >

notopclip:
        mov     ax, desty           ; if the bitmap doesn't extend over the
        add     ax, clippedheight   ; bottom clipping boundry, then we
        dec     ax                  ; don't need to clip the bottom, so we
        cmp     ax, clipbt          ; can jump over the bottom clip code.
        jle     s nobottomclip      ;

        mov     ax, clipbt          ; clip off the bottom by reducing the
        sub     ax, desty           ; clippedheight so that the bitmap won't
        inc     ax                  ; extend over the lower clipping
        mov     clippedheight, ax   ; boundry.

nobottomclip:
        movsx   eax, cliplt         ; if x is to the left of the
        mov     edx, eax            ; top clipping boundry, then we don't
        sub     dx, destx           ; need to clip the left, so we can
        js      s noleftclip        ; jump over the clipping stuff.

        mov     destx, ax           ; this block performs clipping on the
        sub     clippedwidth, dx    ; left of the bitmap.  i have heavily
        movsx   ecx, sourcewidth    ; optimized this block to use only 4
        imul    ecx, edx            ; 32-bit registers, so i'm not even
        mov     eax, ecx            ; gonna try to explain what it's doing.
        cdq                         ; but i can tell you what results from
        movsx   ebx, destwidth      ; this:  the decisionx var is updated
        idiv    ebx                 ; to start at the right clipped column.
        add     esi, eax            ; x is moved to the left clip
        imul    eax, ebx            ; boundry. clippedwidth is reduced since
        sub     ecx, eax            ; we won't be drawing all the requested
        sub     ecx, ebx            ; cols. esi is changed to point over
        shl     ecx, 1              ; the bitmap data that is clipped off.
        mov     decisionx, cx       ; <end of left clipping block >

noleftclip:
        mov     ax, destx           ; if the bitmap doesn't extend over the
        add     ax, clippedwidth    ; right clipping boundry, then we
        dec     ax                  ; don't need to clip the right, so we
        cmp     ax, cliprt          ; can jump over the right clip code.
        jle     s noclipright       ;

        mov     ax, cliprt          ; clip off the right by reducing the
        sub     ax, destx           ; clippedwidth so that the bitmap won't
        inc     ax                  ; extend over the right clipping
        mov     clippedwidth, ax    ; boundry.

        ;calculate starting video address
noclipright:
        movzx   edi, desty          ; we are going to set edi to start point
        imul    edi, xactual/4
        movzx   eax, destx          ; the offset edi is
        mov     cx, ax              ; calculated by:
        shr     ax, 2               ;     di = y*80+x/2
        add     eax, current_page
        add     edi,eax             ; edi is ready!

        mov     dx, sc_index        ; point the vga sequencer to the map
        mov     al, map_mask        ; mask register, so that we only need
        out     dx, al              ; to send out 1 byte per column.

        inc     dx                  ; move to the sequencer's data register.
        and     cx, 3               ; calculate the starting plane. this is
        mov     al, 11h             ; just:
        shl     al, cl              ; plane =  (11h << (x and 3))
        out     dx, al              ; select the first plane.

        movzx   ecx, sourcewidth     ; use cx for source width
        mov     xad, ecx

        align   4                   ; since this point gets jumped to a lot,
                                    ; make sure that it is dword aligned.
rowloop:
        push    esi                 ; save the starting source index
        push    edi                 ; save the starting dest index
        push    ax                  ; save the current plane mask
        push    bp                  ; save the current base pointer

        mov     cx, clippedheight   ; use al for row counter (0-239)
        mov     bx, decisiony       ; use bx for decision variable
        mov     dx, sourceheight    ; use dx for source height * 2
        shl     dx, 1
        mov     bp, destheight      ; use bp for dest height * 2
        shl     bp, 1
        mov     ah, [esi]           ; get the first source pixel

        align   4                   ; common jump point... align for speed.
columnloop:
        mov     [edi], ah           ; draw a pixel
        dec     cx                  ; decrement line counter
        jz      s donewithcol       ; see if we're done with this column
        add     edi, xactual/4      ; go on to the next screen row
        add     bx, dx              ; increment the decision variable
        js      s columnloop        ; draw this source pixel again

incsourcerow:
        add     esi, xad            ; move to the next source pixel
        sub     bx, bp              ; decrement the decision variable
        jns     s incsourcerow      ; see if we need to skip another source pixel
        mov     ah, [esi]           ; get the next source pixel
        jmp     s columnloop        ; start drawing this pixel

donewithcol:
        pop     bp                  ; restore bp to access variables
        pop     ax                  ; restore al = plane mask
        pop     edi                 ; restore di to top row of screen
        pop     esi                 ; restore si to top row of source bits

        rol     al, 1               ; move to next plane
        adc     edi, 0              ; go on to next screen column
        mov     dx, sc_data         ; tell the vga what column we're in
        out     dx, al              ; by updating the map mask register

        mov     bx, decisionx       ; use bx for the x decision variable
        add     bx, sourcewidth     ; increment the x decision variable
        add     bx, sourcewidth
        js      s nextcol           ; jump if we're still in the same source col.
        mov     dx, destwidth       ; dx = w * 2
        shl     dx, 1
incsourcecol:
        inc     esi                 ; move to next source column
        sub     bx, dx              ; decrement x decision variable
        jns     s incsourcecol      ; see if we skip another source column
nextcol:
        mov     decisionx, bx       ; free up bx for colloop
        dec     clippedwidth        ; if we're not at last column
        jnz     rowloop             ;    then do another column
done:
        ret                         ; we're done!

; draw transparent bitmap.  any bytes that = 0 are skipped

tdraw_scale:
        mov bitmap,esi
        mov destwidth,ax
        mov destheight,bx
        mov destx,cx
        mov desty,dx

xscale2:
        cmp     destwidth, 2        ; if destination width is less than 2
        jl      s done              ;     then don't draw it.

        cmp     destheight, 2       ; if destination height is less than 2
        jl      s done              ;     then don't draw it.

        mov     ax, desty           ; if it is completely below the
        cmp     ax, clipbt          ; lower clip bondry,
        jg      s done              ;     then don't draw it.

        add     ax, destheight      ; if it is above clip boundries
        dec     ax                  ;     then don't draw it.
        cmp     ax, cliptp
        jl      s done

        mov     ax, destx           ; if it is to the right of the
        mov     cx, cliprt          ; right clip boundry
        cmp     ax, cliprt          ;     then don't draw it.
        jg      s done

        add     ax, destwidth       ; if it is completely to the left
        dec     ax                  ; of the left clip boundry,
        cmp     ax, cliplt          ;     then don't draw it.
        jl      s done

        mov     esi, bitmap         ; make esi point to bitmap data
        lodsw                       ; get source x width
        mov     sourcewidth,ax
        lodsw                       ; get source y height
        mov     sourceheight,ax

        mov     ax, destwidth       ; clippedwidth is initially set to
        mov     clippedwidth, ax    ; the requested dest width.

        shl     ax,1                ; initialize the x decision var
        neg     ax                  ; to be -2*destwidth
        mov     decisionx, ax       ;

        mov     ax, destheight      ; clippedheight is initially set to
        mov     clippedheight, ax   ; the requested dest size.

        shl     ax,1                ; initialize the y decision var
        neg     ax                  ; to be -2*destheight
        mov     decisiony, ax       ;

        movsx   eax, cliptp         ; if y is below the top
        mov     edx, eax            ; clipping boundry, then we don't
        sub     dx, desty           ; need to clip the top, so we can
        js      s notopclip2        ; jump over the clipping stuff.

        mov     desty, ax           ; this block performs clipping on the
        sub     clippedheight, dx   ; top of the bitmap.  i have heavily
        movsx   ecx, sourceheight   ; optimized this block to use only 4
        imul    ecx, edx            ; 32-bit registers, so i'm not even
        mov     eax, ecx            ; gonna try to explain what it's doing.
        cdq                         ; but i can tell you what results from
        movsx   ebx, destheight     ; this:  the decisiony var is updated
        idiv    ebx                 ; to start at the right clipped row.
        movsx   edx, sourcewidth    ; y is moved to the top clip
        imul    edx, eax            ; boundry. clippedheight is lowered since
        add     esi, edx            ; we won't be drawing all the requested
        imul    eax, ebx            ; rows. esi is changed to point over
        sub     ecx, eax            ; the bitmap data that is clipped off.
        sub     ecx, ebx            ;
        shl     ecx, 1              ;
        mov     decisiony, cx       ; <end of top clipping block >

notopclip2:
        mov     ax, desty           ; if the bitmap doesn't extend over the
        add     ax, clippedheight   ; bottom clipping boundry, then we
        dec     ax                  ; don't need to clip the bottom, so we
        cmp     ax, clipbt          ; can jump over the bottom clip code.
        jle     s nobottomclip2

        mov     ax, clipbt          ; clip off the bottom by reducing the
        sub     ax, desty           ; clippedheight so that the bitmap won't
        inc     ax                  ; extend over the lower clipping
        mov     clippedheight, ax   ; boundry.

nobottomclip2:
        movsx   eax, cliplt         ; if x is to the left of the
        mov     edx, eax            ; top clipping boundry, then we don't
        sub     dx, destx           ; need to clip the left, so we can
        js      s noleftclip2       ; jump over the clipping stuff.

        mov     destx, ax           ; this block performs clipping on the
        sub     clippedwidth, dx    ; left of the bitmap.  i have heavily
        movsx   ecx, sourcewidth    ; optimized this block to use only 4
        imul    ecx, edx            ; 32-bit registers, so i'm not even
        mov     eax, ecx            ; gonna try to explain what it's doing.
        cdq                         ; but i can tell you what results from
        movsx   ebx, destwidth      ; this:  the decisionx var is updated
        idiv    ebx                 ; to start at the right clipped column.
        add     esi, eax            ; x is moved to the left clip
        imul    eax, ebx            ; boundry. clippedwidth is reduced since
        sub     ecx, eax            ; we won't be drawing all the requested
        sub     ecx, ebx            ; cols. esi is changed to point over
        shl     ecx, 1              ; the bitmap data that is clipped off.
        mov     decisionx, cx       ; <end of left clipping block >

noleftclip2:
        mov     ax, destx           ; if the bitmap doesn't extend over the
        add     ax, clippedwidth    ; right clipping boundry, then we
        dec     ax                  ; don't need to clip the right, so we
        cmp     ax, cliprt          ; can jump over the right clip code.
        jle     s noclipright2

        mov     ax, cliprt          ; clip off the right by reducing the
        sub     ax, destx           ; clippedwidth so that the bitmap won't
        inc     ax                  ; extend over the right clipping
        mov     clippedwidth, ax    ; boundry.

        ;calculate starting video address
noclipright2:
        movsx   edi, desty          ; we are going to set edi to start point
        imul    edi, xactual/4
        movsx   eax, destx          ; the offset edi is
        mov     cx, ax              ; calculated by:
        shr     eax, 2              ; edi = y*80+x/2
        add     eax, current_page
        add     edi,eax             ; edi is ready!

        mov     dx, sc_index        ; point the vga sequencer to the map
        mov     al, map_mask        ; mask register, so that we only need
        out     dx, al              ; to send out 1 byte per column.

        inc     dx                  ; move to the sequencer's data register.
        and     cx, 3               ; calculate the starting plane. this is
        mov     al, 11h             ; just:
        shl     al, cl              ; plane =  (11h << (x and 3))
        out     dx, al              ; select the first plane.

        movzx   ecx, sourcewidth     ; use cx for source width
        mov     xad, ecx

        align   4                   ; since this point gets jumped to a lot,
                                    ; make sure that it is dword aligned.
rowloop2:
        push    esi                 ; save the starting source index
        push    edi                 ; save the starting dest index
        push    ax                  ; save the current plane mask
        push    bp                  ; save the current base pointer

        mov     cx, clippedheight   ; use al for row counter (0-239)
        mov     bx, decisiony       ; use bx for decision variable
        mov     dx, sourceheight    ; use dx for source height * 2
        shl     dx, 1
        mov     bp, destheight      ; use bp for dest height * 2
        shl     bp, 1
        mov     ah, [esi]           ; get the first source pixel
        cmp     ah,0
        je      s null_loop         ; if zero, perform null loop

        align   4                   ; common jump point... align for speed.
columnloop2:
        mov     [edi], ah           ; draw a pixel
        dec     cx                  ; decrement line counter
        jz      s donewithcol2      ; see if we're done with this column
        add     edi, xactual/4      ; go on to the next screen row
        add     bx, dx              ; increment the decision variable
        js      s columnloop2       ; draw this source pixel again

incsourcerow2:
        add     esi, xad            ; move to the next source pixel
        sub     bx, bp              ; decrement the decision variable
        jns     s incsourcerow2     ; see if we need to skip another source pixel
        mov     ah, [esi]           ; get the next source pixel
        cmp     ah,0
        jz      s null_loop
        jmp     s columnloop2       ; start drawing this pixel

donewithcol2:
        pop     bp                  ; restore bp to access variables
        pop     ax                  ; restore al = plane mask
        pop     edi                 ; restore di to top row of screen
        pop     esi                 ; restore si to top row of source bits

        rol     al, 1               ; move to next plane
        adc     edi, 0              ; go on to next screen column
        mov     dx, sc_data         ; tell the vga what column we're in
        out     dx, al              ; by updating the map mask register

        mov     bx, decisionx       ; use bx for the x decision variable
        add     bx, sourcewidth     ; increment the x decision variable
        add     bx, sourcewidth
        js      s nextcol2          ; jump if we're still in the same source col.
        mov     dx, destwidth       ; dx = w * 2
        shl     dx, 1
incsourcecol2:
        inc     esi                 ; move to next source column
        sub     bx, dx              ; decrement x decision variable
        jns     s incsourcecol2     ; see if we skip another source column
nextcol2:
        mov     decisionx, bx       ; free up bx for colloop
        dec     clippedwidth        ; if we're not at last column
        jnz     rowloop2            ;    then do another column
done2:
        ret                         ; we're done!

        align   4                   ; common jump point... align for speed.
null_loop:
        dec     cx                  ; decrement line counter
        jz      s donewithcol2      ; see if we're done with this column
        add     edi, xactual/4      ; go on to the next screen row
        add     bx, dx              ; increment the decision variable
        js      s null_loop         ; perform more increments
        jmp     s incsourcerow2

; draw repeated bit map.  good for backgrounds in menus and title screens.
; routine is NOT intended for animation because it is slow. uses scale routine
; because scale routine clips bitmaps.  sloppy routine just draws all over the
; place and lets the scale clip borders handle the rest.
;
; repeat_bitmap (seg bitmap, x1%, y1%, x2%, y2%)
;
; remember: first two words of bitmap define width and height

rb_stack   struc
     rb_wide    dw  ?   ; height and width of bitmap
     rb_height  dw  ?
     rb_curx    dw  ?   ; current bitmap location
     rb_cury    dw  ?
     rb_oldy2   dw  ?   ; old cliping borders save
     rb_oldx2   dw  ?
     rb_oldy1   dw  ?
     rb_oldx1   dw  ?
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
     rb_y2      dw  ?   ; y2
     rb_x2      dw  ?   ; x2
     rb_y1      dw  ?   ; y1
     rb_x1      dw  ?   ; x1
     rb_bitmap  dd  ?   ; offset to bitmap
rb_stack   ends

repeat_bitmap:
           push ebp esi edi        ; preserve important registers
           sub esp, 16             ; allocate workspace
           mov ebp, esp            ; set up stack frame

           mov ax,cliplt           ; save old borders just in case
           mov [ebp].rb_oldx1,ax
           mov ax,cliprt
           mov [ebp].rb_oldx2,ax
           mov ax,cliptp
           mov [ebp].rb_oldy1,ax
           mov ax,clipbt
           mov [ebp].rb_oldy2,ax

           mov x1,4

           mov ax,[ebp].rb_x1      ; set new borders for clipping
           mov cliplt,ax
           mov ax,[ebp].rb_x2
           mov cliprt,ax
           mov ax,[ebp].rb_y1
           mov cliptp,ax
           mov ax,[ebp].rb_y2
           mov clipbt,ax

           mov [ebp].rb_curx,0     ; we could start at x1,y1 but this
           mov [ebp].rb_cury,0     ; will make offset backgrounds

           mov esi,[ebp].rb_bitmap
           mov bitmap,esi
           lodsw                   ; set destination width same as original
           mov [ebp].rb_wide,ax
           lodsw
           mov [ebp].rb_height,ax
nextline:
           mov ax,[ebp].rb_wide
           mov destwidth,ax
           mov ax,[ebp].rb_height
           mov destheight,ax

           mov ax,[ebp].rb_curx
           mov destx,ax
           mov ax,[ebp].rb_cury
           mov desty,ax

           push ebp
           call xscale2            ; draw a transparent bitmap
           pop ebp

           mov ax,[ebp].rb_curx
           add ax,[ebp].rb_wide
           mov [ebp].rb_curx,ax
           cmp ax,[ebp].rb_x2
           jle s nextline

           mov [ebp].rb_curx,0

           mov ax,[ebp].rb_cury
           add ax,[ebp].rb_height
           mov [ebp].rb_cury,ax
           cmp ax,[ebp].rb_y2
           jle s nextline

           mov ax,[ebp].rb_oldx1
           mov cliplt,ax
           mov ax,[ebp].rb_oldx2
           mov cliprt,ax
           mov ax,[ebp].rb_oldy1
           mov cliptp,ax
           mov ax,[ebp].rb_oldy2
           mov clipbt,ax

           add esp, 16
           pop edi esi ebp
           ret 12

