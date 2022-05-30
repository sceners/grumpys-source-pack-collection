; ========================================================
; MODEX.ASM - A Complete Mode X Library
;
; Version 1.04 Release, 3 May 1993, By Matt Pritchard
; With considerable input from Michael Abrash
;
; The following information is donated to the public domain in
; the hopes that save other programmers much frustration.
;
; If you do use this code in a product, it would be nice if
; you include a line like "Mode X routines by Matt Pritchard"
; in the credits.
;
; Protected Mode modification by John McCarthy
; John McCarthy thanks Matt Pritchard for providing this code,
; and hopes Matt Pritchard is not offended by the changes.
;
; ========================================================
;
; All of this code is designed to be assembled with MASM 5.10a
; but TASM 3.0 could be used as well.
;
; The routines contained are designed for use in a MEDIUM model
; program.  All Routines are FAR, and is assumed that a DGROUP
; data segment exists and that DS will point to it on entry.
;
; For all routines, the AX, BX, CX, DX, ES and FLAGS registers
; will not be preserved, while the DS, BP, SI and DI registers
; will be preserved.
;
; Unless specifically noted, All Parameters are assumed to be
; "PASSED BY VALUE".  That is, the actual value is placed on
; the stack.  When a reference is passed it is assumed to be
; a near pointer to a variable in the DGROUP segment.
;
; Routines that return a single 16-Bit integer value will
; return that value in the AX register.
;
; This code will *NOT* run on an 8086/8088 because 80286+
; specific instructions are used.   If you have an 8088/86
; and VGA, you can buy an 80386-40 motherboard for about
; $160 and move into the 90's.
;
; JM - revision, this code will *NOT* run on 80286 because of
; 80368+ code is used (and protected mode).
;
; This code is reasonably optimized: Most drawing loops have
; been unrolled once and memory references are minimized by
; keeping stuff in registers when possible.
;
; Error Trapping varies by Routine.  No Clipping is performed
; so the caller should verify that all coordinates are valid.
;
; Several Macros are used to simplify common 2 or 3 instruction
; sequences.  Several Single letter Text Constants also
; simplify common assembler expressions like "WORD PTR".
;
; ------------------ Mode X Variations ------------------
;
;  Mode #  Screen Size    Max Pages   Aspect Ratio (X:Y)
;
;    0      320 x 200      4 Pages         1.2:1
;    1      320 x 400      2 Pages         2.4:1
;    2      360 x 200      3 Pages        1.35:1
;    3      360 x 400      1 Page          2.7:1
;    4      320 x 240      3 Pages           1:1
;    5      320 x 480      1 Page            2:1
;    6      360 x 240      3 Pages       1.125:1
;    7      360 x 480      1 Page         2.25:1
;
; -------------------- The Legal Stuff ------------------
;
; No warranty, either written or implied, is made as to
; the accuracy and usability of this code product.  Use
; at your own risk.  Batteries not included.  Pepperoni
; and extra cheese available for an additional charge.
;
; ----------------------- The Author --------------------
;
; Matt Pritchard is a paid programmer who'd rather be
; writing games.  He can be reached at: P.O. Box 140264,
; Irving, TX  75014  USA.  Michael Abrash is a living
; god, who now works for Bill Gates (Microsoft).
;
; -------------------- Revision History -----------------
; 4-12-93: v1.02 - SET_POINT & READ_POINT now saves DI
;          SET_MODEX now saves SI
; 5-3-93:  v1.04 - added LOAD_DAC_REGISTERS and
;          READ_DAC_REGISTERS.  Expanded CLR Macro
;          to handle multiple registers
;
; Revisions by John McCarthy - sometime throughout June/93:
;
; - Protected mode addressing for all routines.
; - Conditional assembley for routines not wanted by user
; - Bios text addressing removed - see set_vga_modex
; - File assembles for protected mode, variables and routines made public
; - Mode03 routine added to return to DOS mode.  Must be used in conjunction
;      with TRAN's protected mode header.
; - Also added routines to turn off the screen to avoid that screen flicker
;      when changing into xmode.
;
; A note from John McCarthy:
;
;  When converting to protected mode, loop's, rep's, stosb's and such
;  must have the high word of the ecx,edi,esi registers set.  I have tested
;  the routines now that they have been converted and they seem to all work
;  fine, but if you find they don't jive, please send me a message/letter and
;  I will get right on it.
;
;  These routines originally came with all kinds of extra files for font
;  editing, pallet editing, C stuff and demos.  I have only supplied the
;  critical files from Matt to cut down on .zip file size.
;

x_fill_block    equ 1       ; small routines are automatically included
x_draw_line     equ 1       ; which x mode routines should be included
x_set_point     equ 1       ; when assembled; 1 = enabled
x_read_point    equ 1
x_gprintc       equ 0
x_tgprintc      equ 1
x_set_window    equ 0
x_print_str     equ 0
x_tprint_str    equ 0
x_set_font      equ 0
x_draw_bitmap   equ 0
x_tdraw_bitmap  equ 1
x_copy_page     equ 0
x_copy_bitmap   equ 0

           .386p
code32     segment para public use32
           assume cs:code32, ds:code32

           include pmode.inc     ; protected mode externals
           include macros.inc    ; guess...
           include equ.inc       ; list of constants

; xmode routines by matt prichard
; modified for 386 protected mode by john mccarthy
; protected mode header courtesy of TRAN

; ===== data tables =====

; bit mask tables for left/right/character masks

           public left_clip_mask
           public right_clip_mask

left_clip_mask  db 0fh, 0eh, 0ch, 08h
right_clip_mask db 01h, 03h, 07h, 0fh

; bit patterns for converting character fonts

char_plane_data db 00h,08h,04h,0ch,02h,0ah,06h,0eh
                db 01h,09h,05h,0dh,03h,0bh,07h,0fh

; crtc register values for various configurations

mode_single_line:       ; crtc setup data for 400/480 line modes
        dw  04009h      ; cell height (1 scan line)
        dw  00014h      ; dword mode off
        dw  0e317h      ; turn on byte mode
        dw  nil         ; end of crtc data for 400/480 line mode

mode_double_line:       ; crtc setup data for 200/240 line modes
        dw  04109h      ; cell height (2 scan lines)
        dw  00014h      ; dword mode off
        dw  0e317h      ; turn on byte mode
        dw  nil         ; end of crtc data for 200/240 line mode

mode_320_wide:          ; crtc setup data for 320 horz pixels
        dw  05f00h      ; horz total
        dw  04f01h      ; horz displayed
        dw  05002h      ; start horz blanking
        dw  08203h      ; end horz blanking
        dw  05404h      ; start h sync
        dw  08005h      ; end h sync
        dw  nil         ; end of crtc data for 320 horz pixels

mode_360_wide:          ; crtc setup data for 360 horz pixels
        dw  06b00h      ; horz total
        dw  05901h      ; horz displayed
        dw  05a02h      ; start horz blanking
        dw  08e03h      ; end horz blanking
        dw  05e04h      ; start h sync
        dw  08a05h      ; end h sync
        dw  nil         ; end of crtc data for 360 horz pixels

mode_200_tall:
mode_400_tall:          ; crtc setup data for 200/400 line modes
        dw  0bf06h      ; vertical total
        dw  01f07h      ; overflow
        dw  09c10h      ; v sync start
        dw  08e11h      ; v sync end/prot cr0 cr7
        dw  08f12h      ; vertical displayed
        dw  09615h      ; v blank start
        dw  0b916h      ; v blank end
        dw  nil         ; end of crtc data for 200/400 lines

mode_240_tall:
mode_480_tall:          ; crtc setup data for 240/480 line modes
        dw  00d06h      ; vertical total
        dw  03e07h      ; overflow
        dw  0ea10h      ; v sync start
        dw  08c11h      ; v sync end/prot cr0 cr7
        dw  0df12h      ; vertical displayed
        dw  0e715h      ; v blank start
        dw  00616h      ; v blank end
        dw  nil         ; end of crtc data for 240/480 lines

; table of display mode tables

mode_table:
        dd  o mode_320x200, o mode_320x400
        dd  o mode_360x200, o mode_360x400
        dd  o mode_320x240, o mode_320x480
        dd  o mode_360x240, o mode_360x480

; table of display mode components

mode_320x200:           ; data for 320 by 200 pixels

        db  063h        ; 400 scan lines & 25 mhz clock
        db  4           ; maximum of 4 pages
        dw  320, 200    ; displayed pixels (x,y)
        dw  1302, 816   ; max possible x and y sizes

        dd  o mode_320_wide, o mode_200_tall
        dd  o mode_double_line, nil

mode_320x400:           ; data for 320 by 400 pixels

        db  063h        ; 400 scan lines & 25 mhz clock
        db  2           ; maximum of 2 pages
        dw  320, 400    ; displayed pixels x,y
        dw  648, 816    ; max possible x and y sizes

        dd  o mode_320_wide, o mode_400_tall
        dd  o mode_single_line, nil

mode_360x240:           ; data for 360 by 240 pixels

        db  0e7h        ; 480 scan lines & 28 mhz clock
        db  3           ; maximum of 3 pages
        dw  360, 240    ; displayed pixels x,y
        dw  1092, 728   ; max possible x and y sizes

        dd  o mode_360_wide, o mode_240_tall
        dd  o mode_double_line , nil

mode_360x480:           ; data for 360 by 480 pixels

        db  0e7h        ; 480 scan lines & 28 mhz clock
        db  1           ; only 1 page possible
        dw  360, 480    ; displayed pixels x,y
        dw  544, 728    ; max possible x and y sizes

        dd  o mode_360_wide, o mode_480_tall
        dd  o mode_single_line , nil

mode_320x240:           ; data for 320 by 240 pixels

        db  0e3h        ; 480 scan lines & 25 mhz clock
        db  3           ; maximum of 3 pages
        dw  320, 240    ; displayed pixels x,y
        dw  1088, 818   ; max possible x and y sizes

        dd  o mode_320_wide, o mode_240_tall
        dd  o mode_double_line, nil

mode_320x480:           ; data for 320 by 480 pixels

        db  0e3h        ; 480 scan lines & 25 mhz clock
        db  1           ; only 1 page possible
        dw  320, 480    ; displayed pixels x,y
        dw  540, 818    ; max possible x and y sizes

        dd  o mode_320_wide, o mode_480_tall
        dd  o mode_single_line, nil

mode_360x200:           ; data for 360 by 200 pixels

        db  067h        ; 400 scan lines & 28 mhz clock
        db  3           ; maximum of 3 pages
        dw  360, 200    ; displayed pixels (x,y)
        dw  1302, 728   ; max possible x and y sizes

        dd  o mode_360_wide, o mode_200_tall
        dd  o mode_double_line, nil

mode_360x400:           ; data for 360 by 400 pixels

        db  067h        ; 400 scan lines & 28 mhz clock
        db  1           ; maximum of 1 pages
        dw  360, 400    ; displayed pixels x,y
        dw  648, 816    ; max possible x and y sizes

        dd  o mode_360_wide, o mode_400_tall
        dd  o mode_single_line, nil

mode_data_table struc
    m_miscr         db  ?       ; value of misc_output register
    m_pages         db  ?       ; maximum possible # of pages
    m_xsize         dw  ?       ; x size displayed on screen
    m_ysize         dw  ?       ; y size displayed on screen
    m_xmax          dw  ?       ; maximum possible x size
    m_ymax          dw  ?       ; maximum possible y size
    m_crtc          dd  ?       ; table of crtc register values
mode_data_table ends

; specific x mode data table format...

screen_width    dw  0        ; actual width of a line in bytes
screen_height   dw  0        ; actual vertical height in pixels

last_page       dw  0        ; # of display pages
page_addr       dd  4 dup (0) ; offsets to start of each page

page_size       dw  0        ; size of page in addr bytes

display_page    dw  0        ; page # currently displayed
active_page     dw  0        ; page # currently active

current_page    dd  0        ; address of current page

current_xoffset dw  0        ; current display x offset
current_yoffset dw  0        ; current display y offset

current_moffset dd  0        ; current start offset

max_xoffset     dw  0        ; current display x offset
max_yoffset     dw  0        ; current display y offset

charset_low     dd  0        ; far ptr to char set: 0-127
charset_hi      dd  0        ; far ptr to char set: 128-255

        public  screen_width
        public  screen_height

        public  last_page
        public  page_addr

        public  page_size

        public  display_page
        public  active_page

        public  current_page

        public  current_xoffset
        public  current_yoffset

        public  current_moffset

        public  max_xoffset
        public  max_yoffset

        public  charset_low
        public  charset_hi

    ; ===== mode x setup routines =====

;======================================================
;set_vga_modex% (modetype%, maxxpos%, maxypos%, pages%)
;======================================================
;
; sets up the specified version of mode x.  allows for
; the setup of multiple video pages, and a virtual
; screen which can be larger than the displayed screen
; (which can then be scrolled a pixel at a time)
;
; entry: modetype = desired screen resolution (0-7)
;
;     0 =  320 x 200, 4 pages max,   1.2:1 aspect ratio
;     1 =  320 x 400, 2 pages max,   2.4:1 aspect ratio
;     2 =  360 x 200, 3 pages max,  1.35:1 aspect ratio
;     3 =  360 x 400, 1 page  max,   2.7:1 aspect ratio
;     4 =  320 x 240, 3 pages max,     1:1 aspect ratio
;     5 =  320 x 480, 1 page  max,     2:1 aspect ratio
;     6 =  360 x 240, 3 pages max, 1.125:1 aspect ratio
;     7 =  360 x 480, 1 page  max,  2.25:1 aspect ratio
;
;        maxxpos = the desired virtual screen width
;        maxypos = the desired virtual screen height
;        pages   = the desired # of video pages
;
; exit:  ax = success flag:   0 = failure / -1= success
;

svm_stack   struc
    svm_table   dd  ?   ; offset of mode info table
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    svm_pages   dw  ?   ; # of screen pages desired
    svm_ysize   dw  ?   ; vertical screen size desired
    svm_xsize   dw  ?   ; horizontal screen size desired
    svm_mode    dw  ?   ; display resolution desired
svm_stack   ends

    public  set_vga_modex

set_vga_modex:
    push    ebp esi edi         ; preserve important registers
    sub     esp, 4              ; allocate workspace
    mov     ebp, esp            ; set up stack frame

; check legality of mode request....

    mov     bx, [ebp].svm_mode  ; get requested mode #

    cmp     bx, num_modes       ; is it 0..7?
    jae     @svm_badmodesetup   ; if not, error out

    shl     bx, 2                  ; scale bx
    mov     esi, d mode_table[bx]  ; si -> mode info
    mov     [ebp].svm_table, esi   ; save ptr for later use

; check # of requested display pages

    mov     cx, [ebp].svm_pages ; get # of requested pages

    clr     ch                  ; set hi word = 0!
    cmp     cl, [esi].m_pages   ; check # pages for mode

    ja      @svm_badmodesetup   ; report error if too many pages
    jcxz    @svm_badmodesetup   ; report error if 0 pages

; check validity of x size

    and     [ebp].svm_xsize, 0fff8h  ; x size mod 8 must = 0

    mov     ax, [ebp].svm_xsize ; get logical screen width

    cmp     ax, [esi].m_xsize   ; check against displayed x
    jb      @svm_badmodesetup   ; report error if too small
    cmp     ax, [esi].m_xmax    ; check against max x
    ja      @svm_badmodesetup   ; report error if too big

; check validity of y size

    mov     bx, [ebp].svm_ysize ; get logical screen height
    cmp     bx, [esi].m_ysize   ; check against displayed y
    jb      @svm_badmodesetup   ; report error if too small
    cmp     bx, [esi].m_ymax    ; check against max y
    ja      @svm_badmodesetup   ; report error if too big

; enough memory to fit it all?

    shr     ax, 2               ; # of bytes:line = xsize/4
    mul     cx                  ; ax = bytes/line * pages
    mul     bx                  ; dx:ax = total vga mem needed
    jno     @svm_continue       ; exit if total size > 256k

    dec     dx                  ; was it exactly 256k???
    or      dx, ax              ; (dx = 1, ax = 0000)
    jz      @svm_continue       ; if so, it's valid...

@svm_badmodesetup:

    clr     ax                  ; return value = false
    jmp     @svm_exit           ; normal exit

@svm_continue:

    mov     v86r_ax,13h         ; start with mode 13h
    mov     al,10h              ; bios int 10h
    int     33h                 ; let v86 handler call bios int 10h

    call turn_screen_off        ; prevent flicker

    out_16  sc_index, chain4_off        ; disable chain 4 mode
    out_16  sc_index, async_reset       ; (a)synchronous reset
    out_8   misc_output, [esi].m_miscr  ; set new timing/size
    out_16  sc_index, sequ_restart      ; restart sequencer ...

    out_8   crtc_index, 11h     ; select vert retrace end register
    inc     dx                  ; point to data
    in      al, dx              ; get value, bit 7 = protect
    and     al, 7fh             ; mask out write protect
    out     dx, al              ; and send it back

    mov     dx, crtc_index      ; vga crtc registers
    add     esi, m_crtc         ; si -> crtc parameter data

; load tables of crtc parameters from list of tables

@svm_setup_table:

    mov     edi, [esi]          ; get pointer to crtc data tbl
    add     esi, 4              ; point to next ptr entry
    or      edi, edi            ; a nil ptr means that we have
    jz      @svm_set_data       ; finished crtc programming

@svm_setup_crtc:
    mov     ax, [edi]           ; get crtc data from table
    add     edi, 2              ; advance pointer
    or      ax, ax              ; at end of data table?
    jz      @svm_setup_table    ; if so, exit & get next table

    out     dx, ax              ; reprogram vga crtc reg
    jmp     s @svm_setup_crtc   ; process next table entry

; initialize page & scroll info, edi = 0

@svm_set_data:
    mov     display_page, di    ; display page = 0
    mov     active_page, di     ; active page = 0
    mov     current_xoffset, di ; horz scroll index = 0
    mov     current_yoffset, di ; vert scroll index = 0
    mov     current_moffset,edi ; memory scroll index = 0

    @rlp    esi, vga_segment    ; segment for vga memory
    mov     current_page, esi

; set logical screen width, x scroll and our data

    mov     esi, [ebp].svm_table ; get saved ptr to mode info
    mov     ax, [ebp].svm_xsize ; get display width

    mov     cx, ax              ; cx = logical width
    sub     cx, [esi].m_xsize   ; cx = max x scroll value
    mov     max_xoffset, cx     ; set maximum x scroll

    shr     ax, 2               ; bytes = pixels / 4
    mov     screen_width, ax    ; save width in pixels

    shr     ax, 1               ; offset value = bytes / 2
    mov     ah, 13h             ; crtc offset register index
    xchg    al, ah              ; switch format for out
    out     dx, ax              ; set vga crtc offset reg

; setup data table, y scroll, misc for other routines

    mov     ax, [ebp].svm_ysize ; get logical screen height

    mov     cx, ax              ; cx = logical height
    sub     bx, [esi].m_ysize   ; cx = max y scroll value
    mov     max_yoffset, cx     ; set maximum y scroll

    mov     screen_height, ax   ; save height in pixels
    mul     screen_width        ; ax = page size in bytes,
    mov     page_size, ax       ; save page size

    mov     cx, [ebp].svm_pages ; get # of pages
    mov     last_page, cx       ; save # of pages

    clr     bx                  ; page # = 0
    @rlp    edx, vga_segment    ; page 0 offset = 0a0000h
    movzx   eax,ax              ; clear top word of eax

@svm_set_pages:

    mov     page_addr[bx], edx  ; set page #(bx) offset
    add     bx, 4               ; page#++
    add     edx, eax            ; compute addr of next page
    loopx   cx, @svm_set_pages  ; loop until all pages set

; clear vga memory

    out_16  sc_index, all_planes_on ; select all planes
    mov     edi, current_page   ; -> start of vga memory

    clr     ax                  ; ax = 0
    cld                         ; block xfer forwards
    mov     ecx, 8000h          ; 32k * 4 * 2 = 256k
    rep     stosw               ; clear dat memory!

; setup font pointers, in protected mode.  you must shl 8 then add but
; i don't know how to correctly convert segmented code to flat memory.
;
;   mov     v86r_bh, rom_8x8_lo    ; ask for 8x8 font, 0-127
;   mov     v86r_ax, get_char_ptr  ; service to get pointer
;   mov     al,10h
;   int     33h                 ; call vga bios through v86 handler
;
;   mov     charset_low, bp     ; save char set offset
;   mov     charset_low+2, es   ; save char set segment
;
;   mov     v86r_bh, rom_8x8_hi    ; ask for 8x8 font, 128-255
;   mov     v86r_ax, get_char_ptr  ; service to get pointer
;   mov     al,10h
;   int     33h                 ; call vga bios
;
;   mov     charset_hi, bp      ; save char set offset
;   mov     charset_hi+2, es    ; save char set segment

    call turn_screen_on         ; prevent flicker

    mov     ax, true            ; return success code

@svm_exit:
    add     esp, 4              ; deallocate workspace
    pop     edi esi ebp         ; restore saved registers
    ret     8                   ; exit & clean up stack

;==================
;set_modex% (mode%)
;==================
;
; quickie mode set - sets up mode x to default configuration
;
; entry: modetype = desired screen resolution (0-7)
;        (see set_vga_modex for list)
;
; exit:  ax = success flag:   0 = failure / -1= success
;

sm_stack    struc
                dd  ?,? ; ebp, esi
                dd  ?   ; caller
    sm_mode     dw  ?   ; desired screen resolution
sm_stack    ends

    public  set_modex

set_modex:
    push    ebp esi             ; preserve important registers
    mov     ebp, esp            ; set up stack frame

    clr     ax                  ; assume failure
    mov     bx, [ebp].sm_mode   ; get desired mode #
    cmp     bx, num_modes       ; is it a valid mode #?
    jae     @smx_exit           ; if not, don't bother

    push    bx                  ; push mode parameter

    shl     bx, 2                 ; scale bx to dword indexer
    mov     esi, d mode_table[bx] ; esi -> mode info

    push    [esi].m_xsize       ; push default x size
    push    [esi].m_ysize       ; push default y size
    mov     al, [esi].m_pages   ; get default # of pages
    clr     ah                  ; hi byte = 0
    push    ax                  ; push # pages

    call    set_vga_modex       ; set up mode x!

@smx_exit:
    pop     esi ebp             ; restore registers
    ret     2                   ; exit & clean up stack

; ===== basic graphics primitives =====

;============================
;clear_vga_screen (colornum%)
;============================
;
; clears the active display page
;
; entry: colornum = color value to fill the page with
;
; exit:  no meaningful values returned
;

cvs_stack   struc
                dd  ?,? ; edi, ebp
                dd  ?   ; caller
    cvs_color   db  ?,? ; color to set screen to
cvs_stack   ends

    public  clear_vga_screen

clear_vga_screen:

    push    ebp edi             ; preserve important registers
    mov     ebp, esp            ; set up stack frame

    out_16  sc_index, all_planes_on ; select all planes
    mov     edi, current_page   ; point to active vga page

    mov     al, [ebp].cvs_color ; get color
    mov     ah, al              ; copy for dword write
    mov     bp,ax
    shl     eax,16
    mov     ax,bp
    cld                         ; block fill forwards

    movzx   ecx, page_size      ; get size of page
    shr     cx, 2               ; divide by 4 for dwords
    rep     stosd               ; block fill vga memory

    pop     edi ebp             ; restore saved registers
    ret     2                   ; exit & clean up stack

;===================================
;set_point (xpos%, ypos%, colornum%)
;===================================
;
; plots a single pixel on the active display page
;
; entry: xpos     = x position to plot pixel at
;        ypos     = y position to plot pixel at
;        colornum = color to plot pixel with
;
; exit:  no meaningful values returned
;

sp_stack    struc
                dd  ?,? ; ebp, edi
                dd  ?   ; caller
    setp_color  db  ?,? ; color of point to plot
    setp_ypos   dw  ?   ; y pos of point to plot
    setp_xpos   dw  ?   ; x pos of point to plot
sp_stack    ends

        public set_point

set_point:

    push    ebp edi             ; preserve registers
    mov     ebp, esp            ; set up stack frame

    mov     edi, current_page   ; point to active vga page

    mov     ax, [ebp].setp_ypos ; get line # of pixel
    mul     screen_width        ; get offset to start of line

    clr     ebx                 ; wipe high word
    mov     bx, [ebp].setp_xpos ; get xpos
    mov     cx, bx              ; copy to extract plane # from
    shr     bx, 2               ; x offset (bytes) = xpos/4
    add     bx, ax              ; offset = width*ypos + xpos/4

    mov     ax, map_mask_plane1 ; map mask & plane select register
    and     cl, plane_bits      ; get plane bits
    shl     ah, cl              ; get plane select value
    out_16  sc_index, ax        ; select plane

    mov     al,[ebp].setp_color ; get pixel color
    mov     [edi+ebx], al       ; draw pixel

    pop     edi ebp             ; restore saved registers
    ret     6                   ; exit and clean up stack

;==========================
;read_point% (xpos%, ypos%)
;==========================
;
; read the color of a pixel from the active display page
;
; entry: xpos = x position of pixel to read
;        ypos = y position of pixel to read
;
; exit:  ax   = color of pixel at (xpos, ypos)
;

rp_stack    struc
            dd  ?,? ; ebp, edi
            dd  ?   ; caller
    rp_ypos dw  ?   ; y pos of point to read
    rp_xpos dw  ?   ; x pos of point to read
rp_stack    ends

        public  read_point

read_point:

    push    ebp edi             ; preserve registers
    mov     ebp, esp            ; set up stack frame

    mov     edi, current_page   ; point to active vga page

    mov     ax, [ebp].rp_ypos   ; get line # of pixel
    mul     screen_width        ; get offset to start of line

    clr     ebx                 ; wipe high word
    mov     bx, [ebp].rp_xpos   ; get xpos
    mov     cx, bx
    shr     bx, 2               ; x offset (bytes) = xpos/4
    add     bx, ax              ; offset = width*ypos + xpos/4

    mov     al, read_map        ; gc read mask register
    mov     ah, cl              ; get xpos
    and     ah, plane_bits      ; & mask out plane #
    out_16  gc_index, ax        ; select plane to read in

    clr     eax                 ; clear return value hi byte
    mov     al, [edi+ebx]       ; get color of pixel

    pop     edi ebp             ; restore saved registers
    ret     4                   ; exit and clean up stack

    if x_fill_block eq 1

;======================================================
;fill_block (xpos1%, ypos1%, xpos2%, ypos2%, colornum%)
;======================================================
;
; fills a rectangular block on the active display page
;
; entry: xpos1    = left x position of area to fill
;        ypos1    = top y position of area to fill
;        xpos2    = right x position of area to fill
;        ypos2    = bottom y position of area to fill
;        colornum = color to fill area with
;
; exit:  no meaningful values returned
;

fb_stack    struc
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    fb_color    db  ?,? ; fill color
    fb_ypos2    dw  ?   ; y pos of lower right pixel
    fb_xpos2    dw  ?   ; x pos of lower right pixel
    fb_ypos1    dw  ?   ; y pos of upper left pixel
    fb_xpos1    dw  ?   ; x pos of upper left pixel
fb_stack    ends

        public    fill_block

fill_block:

    push    ebp esi edi         ; preserve important registers
    mov     ebp, esp            ; set up stack frame

    mov     edi, current_page   ; point to active vga page
    cld                         ; direction flag = forward

    out_8   sc_index, map_mask  ; set up for plane select

; validate pixel coordinates
; if necessary, swap so x1 <= x2, y1 <= y2

    clr     eax
    clr     ecx
    mov     ax, [ebp].fb_ypos1  ; ax = y1   is y1< y2?
    mov     bx, [ebp].fb_ypos2  ; bx = y2
    cmp     ax, bx
    jle     @fb_noswap1

    mov     [ebp].fb_ypos1, bx  ; swap y1 and y2 and save y1
    xchg    ax, bx              ; on stack for future use

@fb_noswap1:
    sub     bx, ax              ; get y width
    inc     bx                  ; add 1 to avoid 0 value
    mov     [ebp].fb_ypos2, bx  ; save in ypos2

    mul     screen_width        ; mul y1 by bytes per line
    add     edi, eax            ; di = start of line y1

    mov     ax, [ebp].fb_xpos1  ; check x1 <= x2
    mov     bx, [ebp].fb_xpos2  ;
    cmp     ax, bx
    jle     @fb_noswap2         ; skip ahead if ok

    mov     [ebp].fb_xpos2, ax  ; swap x1 and x2 and save x2
    xchg    ax, bx              ; on stack for future use

; all our input values are in  order,  now  determine
; how many full "bands" 4 pixels wide (aligned) there
; are, and if there are partial bands (<4 pixels)  on
; the left and right edges.

@fb_noswap2:
    movzx   edx, ax             ; dx = x1 (pixel position)
    shr     edx, 2              ; dx/4 = bytes into line
    add     edi, edx            ; di = addr of upper-left corner

    movzx   ecx, bx             ; cx = x2 (pixel position)
    shr     cx, 2               ; cx/4 = bytes into line

    cmp     dx, cx              ; start and end in same band?
    jne     @fb_normal          ; if not, check for l & r edges
    jmp     @fb_one_band_only   ; if so, then special processing

@fb_normal:
    sub     cx, dx              ; cx = # bands -1
    mov     si, ax              ; si = plane#(x1)
    and     si, plane_bits      ; if left edge is aligned then
    jz      @fb_l_plane_flush   ; no special processing..

; draw "left edge" vertical strip of 1-3 pixels...

    out_8   sc_data, left_clip_mask[si] ; set left edge plane mask

    mov     esi, edi            ; si = copy of start addr (ul)

    mov     dx, [ebp].fb_ypos2  ; get # of lines to draw
    mov     al, [ebp].fb_color  ; get fill color
    movzx   ebx, screen_width   ; get vertical increment value

@fb_left_loop:
    mov     [esi], al           ; fill in left edge pixels
    add     esi, ebx            ; point to next line (below)
    loopjz  dx, @fb_left_cont   ; exit loop if all lines drawn

    mov     [esi], al           ; fill in left edge pixels
    add     esi, ebx            ; point to next line (below)
    loopx   dx, @fb_left_loop   ; loop until left strip is drawn

@fb_left_cont:

    inc     edi                 ; point to middle (or right) block
    dec     cx                  ; reset cx instead of jmp @fb_right

@fb_l_plane_flush:
    inc     cx                  ; add in left band to middle block

; di = addr of 1st middle pixel (band) to fill
; cx = # of bands to fill -1

@fb_right:
    mov     si, [ebp].fb_xpos2  ; get xpos2
    and     si, plane_bits      ; get plane values
    cmp     si, 0003            ; plane = 3?
    je      @fb_r_edge_flush    ; hey, add to middle

; draw "right edge" vertical strip of 1-3 pixels...

    out_8   sc_data, right_clip_mask[si]    ; right edge plane mask

    mov     esi, edi            ; get addr of left edge
    add     esi, ecx            ; add width-1 (bands)
    dec     esi                 ; to point to top of right edge

    mov     dx, [ebp].fb_ypos2  ; get # of lines to draw
    mov     al, [ebp].fb_color  ; get fill color
    mov     bx, screen_width    ; get vertical increment value

@fb_right_loop:
    mov     [esi], al           ; fill in right edge pixels
    add     esi, ebx            ; point to next line (below)
    loopjz  dx, @fb_right_cont  ; exit loop if all lines drawn

    mov     [esi], al            ; fill in right edge pixels
    add     esi, ebx            ; point to next line (below)
    loopx   dx, @fb_right_loop  ; loop until left strip is drawn

@fb_right_cont:

    dec     cx                  ; minus 1 for middle bands
    jz      @fb_exit            ; uh.. no middle bands...

@fb_r_edge_flush:

; di = addr of upper left block to fill
; cx = # of bands to fill in (width)

    out_8   sc_data, all_planes ; write to all planes

    mov     dx, screen_width    ; dx = di increment
    sub     dx, cx              ; = screen_width-# planes filled

    mov     ebx, ecx            ; bx = quick refill for cx
    mov     si, [ebp].fb_ypos2  ; si = # of line to fill
    mov     al, [ebp].fb_color  ; get fill color

@fb_middle_loop:
    rep     stosb               ; fill in entire line

    mov     ecx, ebx            ; recharge cx (line width)
    add     edi, edx            ; point to start of next line
    loopx   si, @fb_middle_loop ; loop until all lines drawn

    jmp     s @fb_exit          ; outa here

@fb_one_band_only:
    mov     si, ax                  ; get left clip mask, save x1
    and     si, plane_bits          ; mask out row #
    mov     al, left_clip_mask[si]  ; get left edge mask
    mov     si, bx                  ; get right clip mask, save x2
    and     si, plane_bits          ; mask out row #
    and     al, right_clip_mask[si] ; get right edge mask byte

    out_8   sc_data, al         ; clip for left & right masks

    mov     cx, [ebp].fb_ypos2  ; get # of lines to draw
    mov     al, [ebp].fb_color  ; get fill color
    clr     ebx                 ; wipe high word
    mov     bx, screen_width    ; get vertical increment value

@fb_one_loop:
    mov     [edi], al           ; fill in pixels
    add     edi, ebx            ; point to next line (below)
    loopjz  cx, @fb_exit        ; exit loop if all lines drawn

    mov     [edi], al           ; fill in pixels
    add     edi, ebx            ; point to next line (below)
    loopx   cx, @fb_one_loop    ; loop until left strip is drawn

@fb_exit:
    pop     edi esi ebp         ; restore saved registers
    ret     10                  ; exit and clean up stack

    endif
    if x_draw_line eq 1

;=====================================================
;draw_line (xpos1%, ypos1%, xpos2%, ypos2%, colornum%)
;=====================================================
;
; draws a line on the active display page
;
; entry: xpos1    = x position of first point on line
;        ypos1    = y position of first point on line
;        xpos2    = x position of last point on line
;        ypos2    = y position of last point on line
;        colornum = color to draw line with
;
; exit:  no meaningful values returned
;

dl_stack    struc
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    dl_colorf   db  ?,? ; line draw color
    dl_ypos2    dw  ?   ; y pos of last point
    dl_xpos2    dw  ?   ; x pos of last point
    dl_ypos1    dw  ?   ; y pos of first point
    dl_xpos1    dw  ?   ; x pos of first point
dl_stack    ends

        public draw_line

draw_line:

    push    ebp esi edi         ; preserve important registers
    mov     ebp, esp            ; set up stack frame
    cld                         ; direction flag = forward

    out_8   sc_index, map_mask  ; set up for plane select
    mov     ch, [ebp].dl_colorf ; save line color in ch

; check line type

    mov     si, [ebp].dl_xpos1  ; ax = x1   is x1< x2?
    mov     di, [ebp].dl_xpos2  ; dx = x2
    cmp     si, di              ; is x1 < x2
    je      @dl_vline           ; if x1=x2, draw vertical line
    jl      @dl_noswap1         ; if x1 < x2, don't swap

    xchg    si, di              ; x2 is > x1, so swap them

@dl_noswap1:

; si = x1, di = x2

    mov     ax, [ebp].dl_ypos1  ; ax = y1   is y1 <> y2?
    cmp     ax, [ebp].dl_ypos2  ; y1 = y2?
    je      @dl_horz            ; if so, draw a horizontal line

    jmp     @dl_brezham         ; diagonal line... go do it...

; this code draws a horizontal line in mode x where:
; si = x1, di = x2, and ax = y1/y2

@dl_horz:

    mul     screen_width        ; offset = ypos * screen_width
    mov     dx, ax              ; cx = line offset into page

    mov     ax, si                  ; get left edge, save x1
    and     si, plane_bits          ; mask out row #
    mov     bl, left_clip_mask[si]  ; get left edge mask
    mov     cx, di                  ; get right edge, save x2
    and     di, plane_bits          ; mask out row #
    mov     bh, right_clip_mask[di] ; get right edge mask byte

    shr     ax, 2               ; get x1 byte # (=x1/4)
    shr     cx, 2               ; get x2 byte # (=x2/4)

    movzx   eax, ax             ; zero high words for add
    movzx   edx, dx
    movzx   ecx, cx

    mov     edi, current_page   ; point to active vga page
    add     edi, edx            ; point to start of line
    add     edi, eax            ; point to pixel x1

    sub     cx, ax              ; cx = # of bands (-1) to set
    jnz     @dl_longln          ; jump if longer than one segment

    and     bl, bh              ; otherwise, merge clip masks

@dl_longln:

    out_8   sc_data, bl         ; set the left clip mask

    mov     al, [ebp].dl_colorf ; get line color
    mov     bl, al              ; bl = copy of line color
    stosb                       ; set left (1-4) pixels

    jcxz    @dl_exit3           ; done if only one line segment

    dec     cx                  ; cx = # of middle segments
    jz      @dl_xrseg           ; if no middle segments....

; draw middle segments

    out_8   dx, all_planes      ; write to all planes

    mov     al, bl              ; get color from bl
    rep     stosb               ; draw middle (4 pixel) segments

@dl_xrseg:
    out_8   dx, bh              ; select planes for right clip mask
    mov     al, bl              ; get color value
    stosb                       ; draw right (1-4) pixels
@dl_exit3:
    jmp     s @dl_exit          ; we are done...

; this code draws a vertical line.  on entry:
; ch = line color, si & di = x1

@dl_vline:

    mov     ax, [ebp].dl_ypos1  ; ax = y1
    mov     si, [ebp].dl_ypos2  ; si = y2
    cmp     ax, si              ; is y1 < y2?
    jle     @dl_noswap2         ; if so, don't swap them

    xchg    ax, si              ; ok, now y1 < y2

@dl_noswap2:

    sub     si, ax              ; si = line height (y2-y1+1)
    inc     si

; ax = y1, di = x1, get offset into page into ax

    mul     screen_width        ; offset = y1 (ax) * screen width
    mov     dx, di              ; copy xpos into dx
    shr     di, 2               ; di = xpos/4
    add     ax, di              ; di = xpos/4 + screenwidth * y1

    movzx   eax, ax
    mov     edi, current_page   ; point to active vga page
    add     edi, eax            ; point to pixel x1, y1

;select plane

    mov     cl, dl              ; cl = save x1
    and     cl, plane_bits      ; get x1 mod 4 (plane #)
    mov     ax, map_mask_plane1 ; code to set plane #1
    shl     ah, cl              ; change to correct plane #
    out_16  sc_index, ax        ; select plane

    mov     al, ch              ; get saved color
    mov     bx, screen_width    ; get offset to advance line by
    movzx   ebx, bx

@dl_vloop:
    mov     [edi], al           ; draw single pixel
    add     edi, ebx            ; point to next line
    loopjz  si, @dl_exit        ; lines--, exit if done

    mov     [edi], al           ; draw single pixel
    add     edi, ebx            ; point to next line
    loopx   si, @dl_vloop       ; lines--, loop until done

@dl_exit:

    jmp     @dl_exit2           ; done!

; this code draws a diagonal line in mode x

@dl_brezham:
    mov     edi, current_page   ; point to active vga page

    mov     ax, [ebp].dl_ypos1  ; get y1 value
    mov     bx, [ebp].dl_ypos2  ; get y2 value
    mov     cx, [ebp].dl_xpos1  ; get starting xpos

    cmp     bx, ax              ; y2-y1 is?
    jnc     @dl_deltayok        ; if y2>=y1 then goto...

    xchg    bx, ax              ; swap em...
    mov     cx, [ebp].dl_xpos2  ; get new starting xpos

@dl_deltayok:
    mul     screen_width        ; offset = screen_width * y1
    movzx   eax, ax

    add     edi, eax            ; di -> start of line y1 on page
    mov     ax, cx              ; ax = xpos (x1)
    shr     ax, 2               ; /4 = byte offset into line
    add     edi, eax            ; di = starting pos (x1,y1)

    mov     al, 11h             ; staring mask
    and     cl, plane_bits      ; get plane #
    shl     al, cl              ; and shift into place
    mov     ah, [ebp].dl_colorf ; color in hi bytes

    push    ax                  ; save mask,color...

    mov     ah, al              ; plane # in ah
    mov     al, map_mask        ; select plane register
    out_16  sc_index, ax        ; select initial plane

    mov     ax, [ebp].dl_xpos1  ; get x1 value
    mov     bx, [ebp].dl_ypos1  ; get y1 value
    mov     cx, [ebp].dl_xpos2  ; get x2 value
    mov     dx, [ebp].dl_ypos2  ; get y2 value

    movzx   ebp, screen_width   ; use bp for line width to
                                ; to avoid extra memory access

    sub     dx, bx              ; figure delta_y
    jnc     @dl_deltayok2       ; jump if y2 >= y1

    add     bx, dx              ; put y2 into y1
    neg     dx                  ; abs(delta_y)
    xchg    ax, cx              ; and exchange x1 and x2

@dl_deltayok2:
    mov     bx, 08000h          ; seed for fraction accumulator

    sub     cx, ax              ; figure delta_x
    jc      @dl_drawleft        ; if negative, go left

    jmp     @dl_drawright       ; draw line that slopes right

@dl_drawleft:

    neg     cx                  ; abs(delta_x)

    cmp     cx, dx              ; is delta_x < delta_y?
    jb      @dl_steepleft       ; yes, so go do steep line
                                ; (delta_y iterations)

; draw a shallow line to the left in mode x

@dl_shallowleft:
    clr     ax                  ; zero low word of delta_y * 10000h
    sub     ax, dx              ; dx:ax <- dx * 0ffffh
    sbb     dx, 0               ; include carry
    div     cx                  ; divide by delta_x

    mov     si, bx              ; si = accumulator
    mov     bx, ax              ; bx = add fraction
    pop     ax                  ; get color, bit mask
    mov     dx, sc_data         ; sequence controller data register
    inc     cx                  ; inc delta_x so we can unroll loop

; loop (x2) to draw pixels, move left, and maybe down...

@dl_sllloop:
    mov     [edi], ah           ; set first pixel, plane data set up
    loopjz  cx, @dl_sllexit     ; delta_x--, exit if done

    add     si, bx              ; add numerator to accumulator
    jnc     @dl_slll2nc         ; move down on carry

    add     edi, ebp            ; move down one line...

@dl_slll2nc:
    dec     edi                 ; left one addr
    ror     al, 1               ; move left one plane, back on 0 1 2
    cmp     al, 87h             ; wrap?, if al <88 then carry set
    adc     edi, 0              ; adjust address: di = di + carry
    out     dx, al              ; set up new bit plane mask

    mov     [edi], ah           ; set pixel
    loopjz  cx, @dl_sllexit     ; delta_x--, exit if done

    add     si, bx              ; add numerator to accumulator,
    jnc     @dl_slll3nc         ; move down on carry

    add     edi, ebp            ; move down one line...

@dl_slll3nc:                    ; now move left a pixel...
    dec     edi                 ; left one addr
    ror     al, 1               ; move left one plane, back on 0 1 2
    cmp     al, 87h             ; wrap?, if al <88 then carry set
    adc     edi, 0              ; adjust address: di = di + carry
    out     dx, al              ; set up new bit plane mask
    jmp     s @dl_sllloop       ; loop until done

@dl_sllexit:
    jmp     @dl_exit2           ; and exit

; draw a steep line to the left in mode x

@dl_steepleft:
    clr     ax                  ; zero low word of delta_y * 10000h
    xchg    dx, cx              ; delta_y switched with delta_x
    div     cx                  ; divide by delta_y

    mov     si, bx              ; si = accumulator
    mov     bx, ax              ; bx = add fraction
    pop     ax                  ; get color, bit mask
    mov     dx, sc_data         ; sequence controller data register
    inc     cx                  ; inc delta_y so we can unroll loop

; loop (x2) to draw pixels, move down, and maybe left

@dl_stlloop:

    mov     [edi], ah           ; set first pixel
    loopjz  cx, @dl_stlexit     ; delta_y--, exit if done

    add     si, bx              ; add numerator to accumulator
    jnc     @dl_stlnc2          ; no carry, just move down!

    dec     edi                 ; move left one addr
    ror     al, 1               ; move left one plane, back on 0 1 2
    cmp     al, 87h             ; wrap?, if al <88 then carry set
    adc     edi, 0              ; adjust address: di = di + carry
    out     dx, al              ; set up new bit plane mask

@dl_stlnc2:
    add     edi, ebp            ; advance to next line.

    mov     [edi], ah           ; set pixel
    loopjz  cx, @dl_stlexit     ; delta_y--, exit if done

    add     si, bx              ; add numerator to accumulator
    jnc     @dl_stlnc3          ; no carry, just move down!

    dec     edi                 ; move left one addr
    ror     al, 1               ; move left one plane, back on 0 1 2
    cmp     al, 87h             ; wrap?, if al <88 then carry set
    adc     edi, 0              ; adjust address: di = di + carry
    out     dx, al              ; set up new bit plane mask

@dl_stlnc3:
    add     edi, ebp            ; advance to next line.
    jmp     s @dl_stlloop       ; loop until done

@dl_stlexit:
    jmp     @dl_exit2           ; and exit

; draw a line that goes to the right...

@dl_drawright:
    cmp     cx, dx              ; is delta_x < delta_y?
    jb      @dl_steepright      ; yes, so go do steep line
                                ; (delta_y iterations)

; draw a shallow line to the right in mode x

@dl_shallowright:
    clr     ax                  ; zero low word of delta_y * 10000h
    sub     ax, dx              ; dx:ax <- dx * 0ffffh
    sbb     dx, 0               ; include carry
    div     cx                  ; divide by delta_x

    mov     si, bx              ; si = accumulator
    mov     bx, ax              ; bx = add fraction
    pop     ax                  ; get color, bit mask
    mov     dx, sc_data         ; sequence controller data register
    inc     cx                  ; inc delta_x so we can unroll loop

; loop (x2) to draw pixels, move right, and maybe down...

@dl_slrloop:
    mov     [edi], ah           ; set first pixel, mask is set up
    loopjz  cx, @dl_slrexit     ; delta_x--, exit if done..

    add     si, bx              ; add numerator to accumulator
    jnc     @dl_slr2nc          ; don't move down if carry not set

    add     edi, ebp            ; move down one line...

@dl_slr2nc:                     ; now move right a pixel...
    rol     al, 1               ; move right one addr if plane = 0
    cmp     al, 12h             ; wrap? if al >12 then carry not set
    adc     edi, 0              ; adjust address: di = di + carry
    out     dx, al              ; set up new bit plane mask

    mov     [edi], ah           ; set pixel
    loopjz  cx, @dl_slrexit     ; delta_x--, exit if done..

    add     si, bx              ; add numerator to accumulator
    jnc     @dl_slr3nc          ; don't move down if carry not set

    add     edi, ebp            ; move down one line...

@dl_slr3nc:
    rol     al, 1               ; move right one addr if plane = 0
    cmp     al, 12h             ; wrap? if al >12 then carry not set
    adc     edi, 0              ; adjust address: di = di + carry
    out     dx, al              ; set up new bit plane mask
    jmp     s @dl_slrloop       ; loop till done

@dl_slrexit:
    jmp     @dl_exit2           ; and exit

; draw a steep line to the right in mode x

@dl_steepright:
    clr     ax                  ; zero low word of delta_y * 10000h
    xchg    dx, cx              ; delta_y switched with delta_x
    div     cx                  ; divide by delta_y

    mov     si, bx              ; si = accumulator
    mov     bx, ax              ; bx = add fraction
    pop     ax                  ; get color, bit mask
    mov     dx, sc_data         ; sequence controller data register
    inc     cx                  ; inc delta_y so we can unroll loop

; loop (x2) to draw pixels, move down, and maybe right

@strloop:
    mov     [edi], ah           ; set first pixel, mask is set up
    loopjz  cx, @dl_exit2       ; delta_y--, exit if done

    add     si, bx              ; add numerator to accumulator
    jnc     @strnc2             ; if no carry then just go down...

    rol     al, 1               ; move right one addr if plane = 0
    cmp     al, 12h             ; wrap? if al >12 then carry not set
    adc     edi, 0              ; adjust address: di = di + carry
    out     dx, al              ; set up new bit plane mask

@strnc2:
    add     edi, ebp            ; advance to next line.

    mov     [edi], ah           ; set pixel
    loopjz  cx, @dl_exit2       ; delta_y--, exit if done

    add     si, bx              ; add numerator to accumulator
    jnc     @strnc3             ; if no carry then just go down...

    rol     al, 1               ; move right one addr if plane = 0
    cmp     al, 12h             ; wrap? if al >12 then carry not set
    adc     edi, 0              ; adjust address: di = di + carry
    out     dx, al              ; set up new bit plane mask

@strnc3:
    add     edi, ebp            ; advance to next line.
    jmp     s @strloop          ; loop till done

@dl_exit2:
    pop     edi esi ebp         ; restore saved registers
    ret     10                  ; exit and clean up stack

    endif

; ===== dac color register routines =====

;=================================================
;set_dac_register (register%, red%, green%, blue%)
;=================================================
;
; sets a single (rgb) vga palette register
;
; entry: register = the dac # to modify (0-255)
;        red      = the new red intensity (0-63)
;        green    = the new green intensity (0-63)
;        blue     = the new blue intensity (0-63)
;
; exit:  no meaningful values returned
;

sdr_stack   struc
                    dd  ?   ; ebp
                    dd  ?   ; caller
    sdr_blue        db  ?,? ; blue data value
    sdr_green       db  ?,? ; green data value
    sdr_red         db  ?,? ; red data value
    sdr_register    db  ?,? ; palette register #
sdr_stack   ends

    public  set_dac_register

set_dac_register:

    push    ebp                 ; save bp
    mov     ebp, esp            ; set up stack frame

; select which dac register to modify

    out_8   dac_write_addr, [ebp].sdr_register

    mov     dx, pel_data_reg    ; dac data register
    out_8   dx, [ebp].sdr_red   ; set red intensity
    out_8   dx, [ebp].sdr_green ; set green intensity
    out_8   dx, [ebp].sdr_blue  ; set blue intensity

    pop     ebp                 ; restore registers
    ret     8                   ; exit & clean up stack

;====================================================
;get_dac_register (register%, &red%, &green%, &blue%)
;====================================================
;
; reads the rgb values of a single vga palette register
;
; entry: register = the dac # to read (0-255)
;        red      = offset to red variable in ds
;        green    = offset to green variable in ds
;        blue     = offset to blue variable in ds
;
; exit:  the values of the integer variables red,
;        green, and blue are set to the values
;        taken from the specified dac register.
;

gdr_stack   struc
                    dd  ?   ; ebp
                    dd  ?   ; caller
    gdr_blue        dd  ?   ; addr of blue data value (where to put)
    gdr_green       dd  ?   ; addr of green data value
    gdr_red         dd  ?   ; addr of red data value
    gdr_register    db  ?,? ; palette register #
gdr_stack   ends

    public  get_dac_register

get_dac_register:

    push    ebp                 ; save bp
    mov     ebp, esp            ; set up stack frame

; select which dac register to read in

    out_8   dac_read_addr, [ebp].gdr_register

    mov     dx, pel_data_reg    ; dac data register
    clr     ax                  ; clear ax

    in      al, dx              ; read red value
    mov     ebx, [ebp].gdr_red  ; get address of red%
    mov     [ebx], ax           ; *red% = ax

    in      al, dx              ; read green value
    mov     ebx, [ebp].gdr_green; get address of green%
    mov     [ebx], ax           ; *green% = ax

    in      al, dx              ; read blue value
    mov     ebx, [ebp].gdr_blue ; get address of blue%
    mov     [ebx], ax           ; *blue% = ax

    pop     ebp                 ; restore registers
    ret     14                  ; exit & clean up stack

;===========================================================
;load_dac_registers (seg paldata, startreg%, endreg%, sync%)
;===========================================================
;
; sets a block of vga palette registers
;
; entry: paldata  = far pointer to block of palette data
;        startreg = first register # in range to set (0-255)
;        endreg   = last register # in range to set (0-255)
;        sync     = wait for vertical retrace flag (boolean)
;
; exit:  no meaningful values returned
;
; notes: paldata is a lifar array of 3 byte palette values
;        in the order: red  (0-63), green (0-63), blue (0-63)
;

ldr_stack   struc
                    dd  ?,? ; ebp, esi
                    dd  ?   ; caller
    ldr_sync        dw  ?   ; vertical sync flag
    ldr_endreg      db  ?,? ; last register #
    ldr_startreg    db  ?,? ; first register #
    ldr_paldata     dd  ?   ; far ptr to palette data
ldr_stack   ends

    public  load_dac_registers

load_dac_registers:

    push    ebp esi             ; save registers
    mov     ebp, esp            ; set up stack frame

    mov     ax, [ebp].ldr_sync  ; get vertical sync flag
    or      ax, ax              ; is sync flag = 0?
    jz      @ldr_load           ; if so, skip call

    call    sync_display        ; wait for vsync

; determine register #'s, size to copy, etc

@ldr_load:

    mov     esi, [ebp].ldr_paldata  ; esi -> palette data
    mov     dx, dac_write_addr      ; dac register # selector

    clr     ax, bx                  ; clear for byte loads
    mov     al, [ebp].ldr_startreg  ; get start register
    mov     bl, [ebp].ldr_endreg    ; get end register

    sub     bx, ax              ; bx = # of dac registers -1
    inc     bx                  ; bx = # of dac registers
    mov     cx, bx              ; cx = # of dac registers
    add     cx, bx              ; cx =  "   " * 2
    add     cx, bx              ; cx =  "   " * 3
    cld                         ; block outs forward
    out     dx, al              ; set up correct register #

; load a block of dac registers

    mov     dx, pel_data_reg    ; dac data register
    movzx   ecx,cx

    rep     outsb               ; block set dac registers

    pop     esi ebp             ; restore registers
    ret     10                  ; exit & clean up stack

;====================================================
;read_dac_registers (seg paldata, startreg%, endreg%)
;====================================================
;
; reads a block of vga palette registers
;
; entry: paldata  = far pointer to block to store palette data
;        startreg = first register # in range to read (0-255)
;        endreg   = last register # in range to read (0-255)
;
; exit:  no meaningful values returned
;
; notes: paldata is a lifar array of 3 byte palette values
;        in the order: red  (0-63), green (0-63), blue (0-63)
;

rdr_stack   struc
                    dd  ?,? ; ebp, edi
                    dd  ?   ; caller
    rdr_endreg      db  ?,? ; last register #
    rdr_startreg    db  ?,? ; first register #
    rdr_paldata     dd  ?   ; far ptr to palette data
rdr_stack   ends

    public  read_dac_registers

read_dac_registers:

    push    ebp edi             ; save registers
    mov     ebp, esp            ; set up stack frame

; determine register #'s, size to copy, etc

    mov     edi, [ebp].rdr_paldata  ; edi -> palette buffer
    mov     dx, dac_read_addr       ; dac register # selector

    clr     ax, bx                  ; clear for byte loads
    mov     al, [ebp].rdr_startreg  ; get start register
    mov     bl, [ebp].rdr_endreg    ; get end register

    sub     bx, ax              ; bx = # of dac registers -1
    inc     bx                  ; bx = # of dac registers
    mov     cx, bx              ; cx = # of dac registers
    add     cx, bx              ; cx =  "   " * 2
    add     cx, bx              ; cx =  "   " * 3
    cld                         ; block ins forward

; read a block of dac registers

    out     dx, al              ; set up correct register #
    mov     dx, pel_data_reg    ; dac data register
    movzx   ecx,cx

    rep     insb                ; block read dac registers

    pop     edi ebp             ; restore registers
    ret     8                   ; exit & clean up stack

; ===== page flipping and scrolling routines =====

;=========================
;set_active_page (pageno%)
;=========================
;
; sets the active display page to be used for future drawing
;
; entry: pageno = display page to make active
;        (values: 0 to number of pages - 1)
;
; exit:  no meaningful values returned
;

sap_stack   struc
                dd  ?   ; ebp
                dd  ?   ; caller
    sap_page    dw  ?   ; page # for drawing
sap_stack   ends

    public  set_active_page

set_active_page:

    push    ebp                 ; preserve registers
    mov     ebp, esp            ; set up stack frame

    mov     bx, [ebp].sap_page  ; get desired page #
    cmp     bx, last_page       ; is page # valid?
    jae     @sap_exit           ; if not, do nothing

    mov     active_page, bx     ; set active page #

    shl     bx, 2               ; scale page # to dword
    mov     eax, page_addr[bx]  ; get offset to page

    mov     current_page, eax   ; and set for future mov's

@sap_exit:
    pop     ebp                 ; restore registers
    ret     2                   ; exit and clean up stack

;================
;get_active_page%
;================
;
; returns the video page # currently used for drawing
;
; entry: no parameters are passed
;
; exit:  ax = current video page used for drawing
;

    public  get_active_page

get_active_page:

    mov     ax, active_page     ; get active page #
    ret                         ; exit and clean up stack

;===============================
;set_display_page (displaypage%)
;===============================
;
; sets the currently visible display page.
; when called this routine syncronizes the display
; to the vertical blank.
;
; entry: pageno = display page to show on the screen
;        (values: 0 to number of pages - 1)
;
; exit:  no meaningful values returned
;

sdp_stack   struc
                dd  ?       ; ebp
                dd  ?       ; caller
    sdp_page    dw  ?       ; page # to display...
sdp_stack   ends

    public  set_display_page

set_display_page:

    push    ebp                 ; preserve registers
    mov     ebp, esp            ; set up stack frame

    mov     bx, [ebp].sdp_page  ; get desired page #
    cmp     bx, last_page       ; is page # valid?
    jae     @sdp_exit           ; if not, do nothing

    mov     display_page, bx    ; set display page #

    shl     bx, 2               ; scale page # to dword
    mov     ecx, page_addr[bx]   ; get offset in memory to page
    add     ecx, current_moffset ; adjust for any scrolling
    add     ecx,_code32a        ; adjust for protected mode

; wait if we are currently in a vertical retrace

    mov     dx, input_1         ; input status #1 register

@dp_wait0:
    in      al, dx              ; get vga status
    and     al, vert_retrace    ; in display mode yet?
    jnz     @dp_wait0           ; if not, wait for it

; set the start display address to the new page

    mov     dx, crtc_index      ; we change the vga sequencer

    mov     al, start_disp_lo   ; display start low register
    mov     ah, cl              ; low 8 bits of start addr
    out     dx, ax              ; set display addr low

    mov     al, start_disp_hi   ; display start high register
    mov     ah, ch              ; high 8 bits of start addr
    out     dx, ax              ; set display addr high

; wait for a vertical retrace to smooth out things

    mov     dx, input_1         ; input status #1 register

@dp_wait1:
    in      al, dx              ; get vga status
    and     al, vert_retrace    ; vertical retrace start?
    jz      @dp_wait1           ; if not, wait for it

@sdp_exit:
    pop     ebp                 ; restore registers
    ret     2                   ; exit and clean up stack

;=================
;get_display_page%
;=================
;
; returns the video page # currently displayed
;
; entry: no parameters are passed
;
; exit:  ax = current video page being displayed
;

    public  get_display_page

get_display_page:

    mov     ax, display_page    ; get display page #
    ret                         ; exit & clean up stack

    if x_set_window eq 1

;=======================================
;set_window (displaypage%, xpos%, ypos%)
;=======================================
;
; since a logical screen can be larger than the physical
; screen, scrolling is possible.  this routine sets the
; upper left corner of the screen to the specified pixel.
; also sets the display page to simplify combined page
; flipping and scrolling.  when called this routine
; syncronizes the display to the vertical blank.
;
; entry: displaypage = display page to show on the screen
;        xpos        = # of pixels to shift screen right
;        ypos        = # of lines to shift screen down
;
; exit:  no meaningful values returned
;

sw_stack    struc
                dd  ?   ; ebp
                dd  ?   ; caller
    sw_ypos     dw  ?   ; y pos of ul screen corner
    sw_xpos     dw  ?   ; x pos of ul screen corner
    sw_page     dw  ?   ; (new) display page
sw_stack    ends

        public set_window

set_window:

    push    ebp                 ; preserve registers
    mov     ebp, esp            ; set up stack frame

; check if our scroll offsets are valid

    mov     bx, [ebp].sw_page   ; get desired page #
    cmp     bx, last_page       ; is page # valid?
    jae     @sw_exit            ; if not, do nothing

    mov     ax, [ebp].sw_ypos   ; get desired y offset
    cmp     ax, max_yoffset     ; is it within limits?
    ja      @sw_exit            ; if not, exit

    mov     cx, [ebp].sw_xpos   ; get desired x offset
    cmp     cx, max_xoffset     ; is it within limits?
    ja      @sw_exit            ; if not, exit

; compute proper display start address to use

    mul     screen_width        ; ax = yoffset * line width
    shr     cx, 2               ; cx / 4 = bytes into line
    add     ax, cx              ; ax = offset of upper left pixel
    movzx   eax, ax

    mov     current_moffset, eax ; save offset info

    mov     display_page, bx    ; set current page #
    shl     bx, 2               ; scale page # to dword
    add     eax, page_addr[bx]  ; get offset in vga to page
    add     eax,_code32a        ; adjust for protected mode segment
    mov     bx, ax              ; bx = desired display start

    mov     dx, input_1         ; input status #1 register

; wait if we are currently in a vertical retrace

@sw_wait0:
    in      al, dx              ; get vga status
    and     al, vert_retrace    ; in display mode yet?
    jnz     @sw_wait0           ; if not, wait for it

; set the start display address to the new window

    mov     dx, crtc_index      ; we change the vga sequencer
    mov     al, start_disp_lo   ; display start low register
    mov     ah, bl              ; low 8 bits of start addr
    out     dx, ax              ; set display addr low

    mov     al, start_disp_hi   ; display start high register
    mov     ah, bh              ; high 8 bits of start addr
    out     dx, ax              ; set display addr high

; wait for a vertical retrace to smooth out things

    mov     dx, input_1         ; input status #1 register

@sw_wait1:
    in      al, dx              ; get vga status
    and     al, vert_retrace    ; vertical retrace start?
    jz      @sw_wait1           ; if not, wait for it

; now set the horizontal pixel pan values

    out_8   attrib_ctrl, pixel_pan_reg  ; select pixel pan register

    mov     ax, [ebp].sw_xpos   ; get desired x offset
    and     al, 03              ; get # of pixels to pan (0-3)
    shl     al, 1               ; shift for 256 color mode
    out     dx, al              ; fine tune the display!

@sw_exit:
    pop     ebp                 ; restore saved registers
    ret     6                   ; exit and clean up stack

;=============
;get_x_offset%
;=============
;
; returns the x coordinate of the pixel currently display
; in the upper left corner of the display
;
; entry: no parameters are passed
;
; exit:  ax = current horizontal scroll offset
;

    public  get_x_offset

get_x_offset:

    mov     ax, current_xoffset ; get current horz offset
    ret                         ; exit & clean up stack

;=============
;get_y_offset%
;=============
;
; returns the y coordinate of the pixel currently display
; in the upper left corner of the display
;
; entry: no parameters are passed
;
; exit:  ax = current vertical scroll offset
;

    public  get_y_offset

get_y_offset:

    mov     ax, current_yoffset ; get current vertical offset
    ret                         ; exit & clean up stack

    endif

;============
;sync_display
;============
;
; pauses the computer until the next vertical retrace starts
;
; entry: no parameters are passed
;
; exit:  no meaningful values returned
;

    public  sync_display

sync_display:

    mov     dx, input_1         ; input status #1 register

; wait for any current retrace to end

@sd_wait0:
    in      al, dx              ; get vga status
    and     al, vert_retrace    ; in display mode yet?
    jnz     @sd_wait0           ; if not, wait for it

; wait for the start of the next vertical retrace

@sd_wait1:
    in      al, dx              ; get vga status
    and     al, vert_retrace    ; vertical retrace start?
    jz      @sd_wait1           ; if not, wait for it

    ret

; ===== text display routines =====

    if x_gprintc eq 1

;==================================================
;gprintc (charnum%, xpos%, ypos%, colorf%, colorb%)
;==================================================
;
; draws an ascii text character using the currently selected
; 8x8 font on the active display page.  it would be a simple
; exercise to make this routine process variable height fonts.
;
; entry: charnum = ascii character # to draw
;        xpos    = x position to draw character at
;        ypos    = y position of to draw character at
;        colorf  = color to draw text character in
;        colorb  = color to set background to
;
; exit:  no meaningful values returned
;

gpc_stack   struc
    gpc_width   dd  ?   ; screen width-1
    gpc_lines   db  ?,? ; scan lines to decode
    gpc_t_sets  dd  ?   ; saved charset segment
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    gpc_colorb  db  ?,? ; background color
    gpc_colorf  db  ?,? ; text color
    gpc_ypos    dw  ?   ; y position to print at
    gpc_xpos    dw  ?   ; x position to print at
    gpc_char    db  ?,? ; character to print
gpc_stack   ends

        public gprintc

gprintc:

    push    ebp esi edi         ; preserve important registers
    sub     esp, 10             ; allocate workspace on stack
    mov     ebp, esp            ; set up stack frame

    mov     edi, current_page   ; point to active vga page

    movzx   eax, screen_width   ; get logical line width
    mov     ebx, eax            ; bx = screen width
    dec     bx                  ;    = screen width-1
    mov     [ebp].gpc_width,ebx ; save for later use

    mul     [ebp].gpc_ypos      ; start of line = ypos * width
    add     edi, eax            ; di -> start of line ypos

    movzx   eax, [ebp].gpc_xpos ; get xpos of character
    mov     cx, ax              ; save copy of xpos
    shr     ax, 2               ; bytes into line = xpos/4
    add     edi, eax            ; di -> (xpos, ypos)

;get source addr of character bit map  & save

    mov     al, [ebp].gpc_char  ; get character #
    test    al, 080h            ; is hi bit set?
    jz      @gpc_lowchar        ; nope, use low char set ptr

    mov     ebx, charset_hi     ; bx = char set ptr:offset
    jmp     s @gpc_set_char     ; go setup character ptr

@gpc_lowchar:

    mov     ebx, charset_low    ; bx = char set ptr:offset

@gpc_set_char:
    and     eax, 07fh           ; mask out hi bits
    shl     ax, 3               ; * 8 bytes per bitmap
    add     ebx, eax            ; bx = offset of selected char
    mov     [ebp].gpc_t_sets, ebx ; save segment on stack

    and     cx, plane_bits      ; get plane #
    mov     ch, all_planes      ; get initial plane mask
    shl     ch, cl              ; and shift into position
    and     ch, all_planes      ; and mask to lower nibble

    mov     al, 04              ; 4-plane # = # of initial
    sub     al, cl              ; shifts to align bit mask
    mov     cl, al              ; shift count for shl

;get segment of character map

    out_8   sc_index, map_mask  ; setup plane selections
    inc     dx                  ; dx -> sc_data

    mov     al, 08              ; 8 lines to process
    mov     [ebp].gpc_lines, al ; save on stack

@gpc_decode_char_byte:

    mov     esi, [ebp].gpc_t_sets ; get esi = string

    mov     bh, [esi]           ; get bit map
    inc     esi                 ; point to next line
    mov     [ebp].gpc_t_sets, esi ; and save new pointer...

    clr     eax                 ; clear ax

    clr     bl                      ; clear bl
    rol     bx, cl                  ; bl holds left edge bits
    mov     si, bx                  ; use as table index
    and     si, char_bits           ; get low bits
    mov     al, char_plane_data[si] ; get mask in al
    jz      @gpc_no_left1bits       ; skip if no pixels to set

    mov     ah, [ebp].gpc_colorf ; get foreground color
    out     dx, al               ; set up screen mask
    mov     [edi], ah            ; write foreground color

@gpc_no_left1bits:
    xor     al, ch               ; invert mask for background
    jz      @gpc_no_left0bits    ; hey, no need for this

    mov     ah, [ebp].gpc_colorb ; get background color
    out     dx, al               ; set up screen mask
    mov     [edi], ah            ; write foreground color

;now do middle/last band

@gpc_no_left0bits:
    inc     edi                 ; point to next byte
    rol     bx, 4               ; shift 4 bits

    mov     si, bx                  ; make lookup pointer
    and     si, char_bits           ; get low bits
    mov     al, char_plane_data[si] ; get mask in al
    jz      @gpc_no_middle1bits     ; skip if no pixels to set

    mov     ah, [ebp].gpc_colorf ; get foreground color
    out     dx, al               ; set up screen mask
    mov     [edi], ah            ; write foreground color

@gpc_no_middle1bits:
    xor     al, all_planes       ; invert mask for background
    jz      @gpc_no_middle0bits  ; hey, no need for this

    mov     ah, [ebp].gpc_colorb ; get background color
    out     dx, al               ; set up screen mask
    mov     [edi], ah            ; write foreground color

@gpc_no_middle0bits:
    xor     ch, all_planes      ; invert clip mask
    cmp     cl, 4               ; aligned by 4?
    jz      @gpc_next_line      ; if so, exit now..

    inc     edi                 ; point to next byte
    rol     bx, 4               ; shift 4 bits

    mov     si, bx                  ; make lookup pointer
    and     si, char_bits           ; get low bits
    mov     al, char_plane_data[si] ; get mask in al
    jz      @gpc_no_right1bits      ; skip if no pixels to set

    mov     ah, [ebp].gpc_colorf ; get foreground color
    out     dx, al               ; set up screen mask
    mov     [edi], ah            ; write foreground color

@gpc_no_right1bits:

    xor     al, ch               ; invert mask for background
    jz      @gpc_no_right0bits   ; hey, no need for this

    mov     ah, [ebp].gpc_colorb ; get background color
    out     dx, al               ; set up screen mask
    mov     [edi], ah            ; write foreground color

@gpc_no_right0bits:
    dec     edi                  ; adjust for next line advance

@gpc_next_line:
    add     edi, [ebp].gpc_width  ; point to next line
    xor     ch, char_bits       ; flip the clip mask back

    dec     [ebp].gpc_lines     ; count down lines
    jz      @gpc_exit           ; ok... done!

    jmp     @gpc_decode_char_byte   ; again! hey!

@gpc_exit:
    add     esp, 10             ; deallocate stack workspace
    pop     edi esi ebp         ; restore saved registers
    ret     10                  ; exit and clean up stack

    endif
    if x_tgprintc eq 1

;==========================================
;tgprintc (charnum%, xpos%, ypos%, colorf%)
;==========================================
;
; transparently draws an ascii text character using the
; currently selected 8x8 font on the active display page.
;
; entry: charnum = ascii character # to draw
;        xpos    = x position to draw character at
;        ypos    = y position of to draw character at
;        colorf  = color to draw text character in
;
; exit:  no meaningful values returned
;

tpc_stack   struc
    tpc_width   dd  ?   ; screen width-1
    tpc_lines   db  ?,? ; scan lines to decode
    tpc_t_sets  dd  ?   ; saved charset segment
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    tpc_colorf  db  ?,? ; text color
    tpc_ypos    dw  ?   ; y position to print at
    tpc_xpos    dw  ?   ; x position to print at
    tpc_char    db  ?,? ; character to print
tpc_stack   ends

        public tgprintc

tgprintc:

    push    ebp esi edi         ; preserve important registers
    sub     esp, 10             ; allocate workspace on stack
    mov     ebp, esp            ; set up stack frame

    mov     edi, current_page   ; point to active vga page

    movzx   eax, screen_width   ; get logical line width
    mov     ebx, eax            ; bx = screen width
    dec     bx                  ;    = screen width-1
    mov     [ebp].tpc_width,ebx ; save for later use

    mul     [ebp].tpc_ypos      ; start of line = ypos * width
    add     edi, eax            ; di -> start of line ypos

    movzx   eax, [ebp].tpc_xpos ; get xpos of character
    mov     cx, ax              ; save copy of xpos
    shr     ax, 2               ; bytes into line = xpos/4
    add     edi, eax            ; di -> (xpos, ypos)

;get source addr of character bit map  & save

    mov     al, [ebp].tpc_char  ; get character #
    test    al, 080h            ; is hi bit set?
    jz      @tpc_lowchar        ; nope, use low char set ptr

    mov     ebx, charset_hi     ; bx = char set ptr:offset
    jmp     s @tpc_set_char     ; go setup character ptr

@tpc_lowchar:

    mov     ebx, charset_low    ; bx = char set ptr:offset

@tpc_set_char:
    and     eax, 07fh           ; mask out hi bits
    shl     ax, 3               ; * 8 bytes per bitmap
    add     ebx, eax            ; bx = offset of selected char
    mov     [ebp].tpc_t_sets, ebx ; save segment on stack

    and     cx, plane_bits      ; get plane #
    mov     ch, all_planes      ; get initial plane mask
    shl     ch, cl              ; and shift into position
    and     ch, all_planes      ; and mask to lower nibble

    mov     al, 04              ; 4-plane # = # of initial
    sub     al, cl              ; shifts to align bit mask
    mov     cl, al              ; shift count for shl

;get segment of character map

    out_8   sc_index, map_mask  ; setup plane selections
    inc     dx                  ; dx -> sc_data

    mov     al, 08              ; 8 lines to process
    mov     [ebp].tpc_lines, al ; save on stack

@tpc_decode_char_byte:

    mov     esi, [ebp].tpc_t_sets ; get esi = string

    mov     bh, [esi]           ; get bit map
    inc     esi                 ; point to next line
    mov     [ebp].tpc_t_sets, esi ; and save new pointer...

    clr     eax                 ; clear ax

    clr     bl                      ; clear bl
    rol     bx, cl                  ; bl holds left edge bits
    mov     si, bx                  ; use as table index
    and     si, char_bits           ; get low bits
    mov     al, char_plane_data[si] ; get mask in al
    jz      @tpc_no_left1bits       ; skip if no pixels to set

    mov     ah, [ebp].tpc_colorf ; get foreground color
    out     dx, al               ; set up screen mask
    mov     [edi], ah            ; write foreground color

;now do middle/last band

@tpc_no_left1bits:
    inc     edi                 ; point to next byte
    rol     bx, 4               ; shift 4 bits

    mov     si, bx                  ; make lookup pointer
    and     si, char_bits           ; get low bits
    mov     al, char_plane_data[si] ; get mask in al
    jz      @tpc_no_middle1bits     ; skip if no pixels to set

    mov     ah, [ebp].tpc_colorf ; get foreground color
    out     dx, al               ; set up screen mask
    mov     [edi], ah            ; write foreground color

@tpc_no_middle1bits:
    xor     ch, all_planes      ; invert clip mask
    cmp     cl, 4               ; aligned by 4?
    jz      @tpc_next_line      ; if so, exit now..

    inc     edi                 ; point to next byte
    rol     bx, 4               ; shift 4 bits

    mov     si, bx                  ; make lookup pointer
    and     si, char_bits           ; get low bits
    mov     al, char_plane_data[si] ; get mask in al
    jz      @tpc_no_right1bits      ; skip if no pixels to set

    mov     ah, [ebp].tpc_colorf ; get foreground color
    out     dx, al               ; set up screen mask
    mov     [edi], ah            ; write foreground color

@tpc_no_right1bits:
    dec     edi                  ; adjust for next line advance

@tpc_next_line:
    add     edi, [ebp].tpc_width  ; point to next line
    xor     ch, char_bits       ; flip the clip mask back

    dec     [ebp].tpc_lines     ; count down lines
    jz      @tpc_exit           ; ok... done!

    jmp     @tpc_decode_char_byte   ; again! hey!

@tpc_exit:
    add     esp, 10             ; deallocate stack workspace
    pop     edi esi ebp         ; restore saved registers
    ret     8                   ; exit and clean up stack

    endif
    if x_gprintc eq 1

;===============================================================
;print_str (seg string, maxlen%, xpos%, ypos%, colorf%, colorb%)
;===============================================================
;
; routine to quickly print a null terminated ascii string on the
; active display page up to a maximum length.
;
; entry: string  = far pointer to ascii string to print
;        maxlen  = # of characters to print if no null found
;        xpos    = x position to draw text at
;        ypos    = y position of to draw text at
;        colorf  = color to draw text in
;        colorb  = color to set background to
;
; exit:  no meaningful values returned
;

ps_stack    struc
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    ps_colorb   dw  ?   ; background color
    ps_colorf   dw  ?   ; text color
    ps_ypos     dw  ?   ; y position to print at
    ps_xpos     dw  ?   ; x position to print at
    ps_len      dw  ?   ; maximum length of string to print
    ps_text     dd  ?   ; far ptr to text string
ps_stack    ends

        public  print_str

print_str:

    push    ebp esi edi         ; preserve important registers
    mov     ebp, esp            ; set up stack frame

@ps_print_it:

    mov     cx, [ebp].ps_len    ; get remaining text length
    jcxz    @ps_exit            ; exit when out of text

    mov     edi, [ebp].ps_text  ; edi -> current char in text
    mov     al, [edi]           ; al = text character
    and     ax, 00ffh           ; clear high word
    jz      @ps_exit            ; exit if null character

    dec     [ebp].ps_len        ; remaining text length--
    inc     [ebp].ps_text       ; point to next text char

; set up call to gprintc

    push    ax                  ; set character parameter
    mov     bx, [ebp].ps_xpos   ; get xpos
    push    bx                  ; set xpos parameter
    add     bx, 8               ; advance 1 char to right
    mov     [ebp].ps_xpos, bx   ; save for next time through

    mov     bx, [ebp].ps_ypos   ; get ypos
    push    bx                  ; set ypos parameter

    mov     bx, [ebp].ps_colorf ; get text color
    push    bx                  ; set colorf parameter

    mov     bx, [ebp].ps_colorb ; get background color
    push    bx                  ; set colorb parameter

    call    gprintc             ; print character!
    jmp     s @ps_print_it      ; process next character

@ps_exit:
    pop     edi esi ebp         ; restore saved registers
    ret     14                  ; exit and clean up stack

    endif
    if x_tgprintc eq 1

;================================================================
;tprint_str (seg string, maxlen%, xpos%, ypos%, colorf%, colorb%)
;================================================================
;
; routine to quickly transparently print a null terminated ascii
; string on the active display page up to a maximum length.
;
; entry: string  = far pointer to ascii string to print
;        maxlen  = # of characters to print if no null found
;        xpos    = x position to draw text at
;        ypos    = y position of to draw text at
;        colorf  = color to draw text in
;
; exit:  no meaningful values returned
;

tps_stack   struc
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    tps_colorf  dw  ?   ; text color
    tps_ypos    dw  ?   ; y position to print at
    tps_xpos    dw  ?   ; x position to print at
    tps_len     dw  ?   ; maximum length of string to print
    tps_text    dd  ?   ; far ptr to text string
tps_stack   ends

        public  tprint_str

tprint_str:

    push    ebp esi edi         ; preserve important registers
    mov     ebp, esp            ; set up stack frame

@ts_print_it:

    mov     cx, [ebp].tps_len   ; get remaining text length
    jcxz    @ts_exit            ; exit when out of text

    mov     edi, [ebp].tps_text ; edi -> current char in text
    mov     al, [edi]           ; al = text character
    and     ax, 00ffh           ; clear high word
    jz      @ts_exit            ; exit if null character

    dec     [ebp].tps_len       ; remaining text length--
    inc     [ebp].tps_text      ; point to next text char

; set up call to tgprintc

    push    ax                  ; set character parameter
    mov     bx, [ebp].tps_xpos  ; get xpos
    push    bx                  ; set xpos parameter
    add     bx, 8               ; advance 1 char to right
    mov     [ebp].tps_xpos, bx  ; save for next time through

    mov     bx, [ebp].tps_ypos  ; get ypos
    push    bx                  ; set ypos parameter

    mov     bx, [ebp].tps_colorf ; get text color
    push    bx                  ; set colorf parameter

    call    tgprintc            ; print character!
    jmp     s @ts_print_it      ; process next character

@ts_exit:
    pop     edi esi ebp         ; restore saved registers
    ret     12                  ; exit and clean up stack

    endif

;===========================================
;set_display_font(seg fontdata, fontnumber%)
;===========================================
;
; allows the user to specify their own font data for
; wither the lower or upper 128 characters.
;
; entry: fontdata   = far pointer to font bitmaps
;        fontnumber = which half of set this is
;                   = 0, lower 128 characters
;                   = 1, upper 128 characters
;
; exit:  no meaningful values returned
;

sdf_stack   struc
                dd  ?   ; ebp
                dd  ?   ; caller
    sdf_which   dw  ?   ; hi table/low table flag
    sdf_font    dd  ?   ; far ptr to font table
sdf_stack   ends

    public  set_display_font

set_display_font:

    push    ebp                 ; preserve registers
    mov     ebp, esp            ; set up stack frame

    mov     edi, [ebp].sdf_font ; get far ptr to font

    mov     esi, o charset_low  ; assume lower 128 chars
    test    [ebp].sdf_which, 1  ; font #1 selected?
    jz      @sdf_set_font       ; if not, skip ahead

    mov     esi, o charset_hi   ; ah, really it's 128-255

@sdf_set_font:
    mov     [esi], edi          ; set font pointer offset

    pop     ebp                 ; restore registers
    ret     6                   ; we are done.. outa here

; ===== bitmap (sprite) display routines =====

;======================================================
;draw_bitmap (seg image, xpos%, ypos% )
;======================================================
;
; draws a variable sized graphics bitmap such as a
; picture or an icon on the current display page in
; mode x.  the bitmap is stored in a lifar byte array
; corresponding to (0,0) (1,0), (2,0) .. (width, height)
; this is the same lifar manner as mode 13h graphics.
;
; entry: image  = far pointer to bitmap data
;        xpos   = x position to place upper left pixel at
;        ypos   = y position to place upper left pixel at
;        width  = width of the bitmap in pixels  - ommitted
;        height = height of the bitmap in pixels - ommitted
;
; exit:  no meaningful values returned
;
; routine has been modified so that first two words of bitmap define
; bitmap x and y size
;

db_stack    struc
    db_lineo    dw  ?   ; offset to next line
    db_pixcount dw  ?   ; (minimum) # of pixels/line
    db_start    dd  ?   ; addr of upper left pixel
    db_pixskew  dw  ?   ; # of bytes to adjust eol
    db_skewflag dw  ?   ; extra pix on plane flag
    db_height   dw  ?   ; height of bitmap in pixels
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    db_ypos     dw  ?   ; y position to draw bitmap at
    db_xpos     dw  ?   ; x position to draw bitmap at
    db_image    dd  ?   ; far pointer to graphics bitmap
db_stack    ends

        public    draw_bitmap

draw_bitmap:

    push    ebp esi edi         ; preserve important registers
    sub     esp, 14             ; allocate workspace
    mov     ebp, esp            ; set up stack frame

    mov     edi, current_page   ; point to active vga page
    cld                         ; direction flag = forward

    movzx   eax, [ebp].db_ypos  ; get ul corner ypos
    mul     screen_width        ; ax = offset to line ypos

    movzx   ebx, [ebp].db_xpos  ; get ul corner xpos
    mov     cl, bl              ; save plane # in cl
    shr     bx, 2               ; xpos/4 = offset into line

    add     edi, eax            ; edi -> start of line
    add     edi, ebx            ; edi -> upper left pixel
    mov     [ebp].db_start, edi ; save starting addr

; compute line to line offset

    mov     esi, [ebp].db_image ; esi-> source image
    lodsw                       ; get x width
    mov     bx,ax
    lodsw
    mov     [ebp].db_height,ax
    add     [ebp].db_image,4

    mov     dx, bx              ; save copy in dx
    shr     bx, 2               ; /4 = width in bands
    mov     ax, screen_width    ; get screen width
    sub     ax, bx              ; - (bitmap width/4)

    mov     [ebp].db_lineo, ax      ; save line width offset
    mov     [ebp].db_pixcount, bx   ; minimum # pix to copy

    and     dx, plane_bits          ; get "partial band" size (0-3)
    mov     [ebp].db_pixskew, dx    ; also end of line skew
    mov     [ebp].db_skewflag, dx   ; save as flag/count

    and     cx, plane_bits      ; cl = starting plane #
    mov     ax, map_mask_plane2 ; plane mask & plane select
    shl     ah, cl              ; select correct plane
    out_16  sc_index, ax        ; select plane...
    mov     bh, ah              ; bh = saved plane mask
    mov     bl, 4               ; bl = planes to copy

@db_copy_plane:

    mov     esi, [ebp].db_image ; esi-> source image
    mov     dx, [ebp].db_height ; # of lines to copy
    mov     edi, [ebp].db_start ; edi-> dest pos

@db_copy_line:
    mov     cx, [ebp].db_pixcount   ; min # to copy

    test    cl, 0fch            ; 16+pixwide?
    jz      @db_copy_remainder  ; nope...

; pixel copy loop has been unrolled to x4

@db_copy_loop:
    movsb                       ; copy bitmap pixel
    add     esi, 3              ; skip to next byte in same plane
    movsb                       ; copy bitmap pixel
    add     esi, 3              ; skip to next byte in same plane
    movsb                       ; copy bitmap pixel
    add     esi, 3              ; skip to next byte in same plane
    movsb                       ; copy bitmap pixel
    add     esi, 3              ; skip to next byte in same plane

    sub     cl, 4               ; pixels to copy=-4
    test    cl, 0fch            ; 4+ pixels left?
    jnz     @db_copy_loop       ; if so, do another block

@db_copy_remainder:
    jcxz    @db_next_line       ; any pixels left on line

@db_copy2:
    movsb                       ; copy bitmap pixel
    add     esi,3               ; skip to next byte in same plane
    loopx   cx, @db_copy2       ; pixels to copy--, loop until done

@db_next_line:

; any partial pixels? (some planes only)

    or      cx, [ebp].db_skewflag   ; get skew count
    jz      @db_next2               ; if no partial pixels

    movsb                       ; copy bitmap pixel
    dec     edi                 ; back up to align
    dec     esi                 ; back up to align

@db_next2:
    movzx   eax, [ebp].db_pixskew ; adjust skew
    add     esi, eax
    movzx   eax, [ebp].db_lineo   ; set to next display line
    add     edi, eax
    loopx   dx, @db_copy_line   ; lines to copy--, loop if more

; copy next plane....

    dec     bl                  ; planes to go--
    jz      @db_exit            ; hey! we are done

    rol     bh, 1               ; next plane in line...
    out_8   sc_data, bh         ; select plane

    cmp     al, 12h             ; carry set if al=11h
    adc     [ebp].db_start, 0   ; screen addr =+carry
    inc     w [ebp].db_image    ; start @ next byte

    sub     [ebp].db_skewflag, 1 ; reduce planes to skew
    adc     [ebp].db_skewflag, 0 ; back to 0 if it was -1

    jmp     f @db_copy_plane    ; go copy the next plane

@db_exit:
    add     esp, 14             ; deallocate workspace
    pop     edi esi ebp         ; restore saved registers
    ret     8                   ; exit and clean up stack

;=======================================================
;tdraw_bitmap (seg image, xpos%, ypos%)
;=======================================================
;
; transparently draws a variable sized graphics bitmap
; such as a picture or an icon on the current display page
; in mode x.  pixels with a value of 0 are not drawn,
; leaving the previous "background" contents intact.
;
; the bitmap format is the same as for the draw_bitmap function.
;
; entry: image  = far pointer to bitmap data
;        xpos   = x position to place upper left pixel at
;        ypos   = y position to place upper left pixel at
;        width  = width of the bitmap in pixels   - ommitted
;        height = height of the bitmap in pixels  - ommitted
;
; exit:  no meaningful values returned
;
; routine has been modified so that first two words of bitmap define
; bitmap x and y size
;

tb_stack    struc
    tb_lineo    dw  ?   ; offset to next line
    tb_pixcount dw  ?   ; (minimum) # of pixels/line
    tb_start    dd  ?   ; addr of upper left pixel
    tb_pixskew  dw  ?   ; # of bytes to adjust eol
    tb_skewflag dw  ?   ; extra pix on plane flag
    tb_height   dw  ?   ; height of bitmap in pixels
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    tb_ypos     dw  ?   ; y position to draw bitmap at
    tb_xpos     dw  ?   ; x position to draw bitmap at
    tb_image    dd  ?   ; far pointer to graphics bitmap
tb_stack    ends

        public    tdraw_bitmap

tdraw_bitmap:

    push    ebp esi edi         ; preserve important registers
    sub     esp, 14             ; allocate workspace
    mov     ebp, esp            ; set up stack frame

    mov     edi, current_page   ; point to active vga page
    cld                         ; direction flag = forward

    movzx   eax, [ebp].tb_ypos  ; get ul corner ypos
    mul     screen_width        ; ax = offset to line ypos

    movzx   ebx, [ebp].tb_xpos  ; get ul corner xpos
    mov     cl, bl              ; save plane # in cl
    shr     bx, 2               ; xpos/4 = offset into line

    add     edi, eax            ; edi -> start of line
    add     edi, ebx            ; edi -> upper left pixel
    mov     [ebp].tb_start, edi ; save starting addr

; compute line to line offset

    mov     esi, [ebp].tb_image ; esi-> source image
    lodsw                       ; get x width
    mov     bx,ax
    lodsw
    mov     [ebp].tb_height,ax
    add     [ebp].tb_image,4

    mov     dx, bx              ; save copy in dx
    shr     bx, 2               ; /4 = width in bands
    mov     ax, screen_width    ; get screen width
    sub     ax, bx              ; - (bitmap width/4)

    mov     [ebp].tb_lineo, ax      ; save line width offset
    mov     [ebp].tb_pixcount, bx   ; minimum # pix to copy

    and     dx, plane_bits          ; get "partial band" size (0-3)
    mov     [ebp].tb_pixskew, dx    ; also end of line skew
    mov     [ebp].tb_skewflag, dx   ; save as flag/count

    and     cx, plane_bits      ; cl = starting plane #
    mov     ax, map_mask_plane2 ; plane mask & plane select
    shl     ah, cl              ; select correct plane
    out_16  sc_index, ax        ; select plane...
    mov     bh, ah              ; bh = saved plane mask
    mov     bl, 4               ; bl = planes to copy

@tb_copy_plane:

    mov     esi, [ebp].tb_image  ; esi-> source image
    mov     dx, [ebp].tb_height  ; # of lines to copy
    mov     edi, [ebp].tb_start  ; edi-> dest pos

; here ah is set with the value to be considered
; "transparent".  it can be changed!

@tb_copy_line:
    mov     ah, 0               ; value to detect 0
    mov     cx, [ebp].tb_pixcount    ; min # to copy

    test    cl, 0fch            ; 16+pixwide?
    jz      @tb_copy_remainder  ; nope...

; pixel copy loop has been unrolled to x4

@tb_copy_loop:
    lodsb                       ; get pixel value in al
    add     esi, 3              ; skip to next byte in same plane
    cmp     al, ah              ; it is "transparent"?
    je      @tb_skip_01         ; skip ahead if so
    mov     [edi], al           ; copy pixel to vga screen

@tb_skip_01:
    lodsb                       ; get pixel value in al
    add     esi, 3              ; skip to next byte in same plane
    cmp     al, ah              ; it is "transparent"?
    je      @tb_skip_02         ; skip ahead if so
    mov     [edi+1], al         ; copy pixel to vga screen

@tb_skip_02:
    lodsb                       ; get pixel value in al
    add     esi, 3              ; skip to next byte in same plane
    cmp     al, ah              ; it is "transparent"?
    je      @tb_skip_03         ; skip ahead if so
    mov     [edi+2], al         ; copy pixel to vga screen

@tb_skip_03:
    lodsb                       ; get pixel value in al
    add     esi, 3              ; skip to next byte in same plane
    cmp     al, ah              ; it is "transparent"?
    je      @tb_skip_04         ; skip ahead if so
    mov     [edi+3], al         ; copy pixel to vga screen

@tb_skip_04:
    add     edi, 4              ; adjust pixel write location
    sub     cl, 4               ; pixels to copy=-4
    test    cl, 0fch            ; 4+ pixels left?
    jnz     @tb_copy_loop       ; if so, do another block

@tb_copy_remainder:
    jcxz    @tb_next_line       ; any pixels left on line

@tb_copy2:
    lodsb                       ; get pixel value in al
    add     esi, 3              ; skip to next byte in same plane
    cmp     al, ah              ; it is "transparent"?
    je      @tb_skip_05         ; skip ahead if so
    mov     [edi], al           ; copy pixel to vga screen

@tb_skip_05:
    inc     edi                 ; advance dest addr
    loopx   cx, @tb_copy2       ; pixels to copy--, loop until done

@tb_next_line:

; any partial pixels? (some planes only)

    or      cx, [ebp].tb_skewflag   ; get skew count
    jz      @tb_next2               ; if no partial pixels

    lodsb                       ; get pixel value in al
    dec     esi                 ; backup to align
    cmp     al, ah              ; it is "transparent"?
    je      @tb_next2           ; skip ahead if so
    mov     [edi], al           ; copy pixel to vga screen

@tb_next2:
    movzx   eax, [ebp].tb_pixskew ; adjust skew
    add     esi, eax
    movzx   eax, [ebp].tb_lineo   ; set to next display line
    add     edi, eax
    loopx   dx, @tb_copy_line   ; lines to copy--, loop if more

    ;copy next plane....

    dec     bl                  ; planes to go--
    jz      @tb_exit            ; hey! we are done

    rol     bh, 1               ; next plane in line...
    out_8   sc_data, bh         ; select plane

    cmp     al, 12h             ; carry set if al=11h
    adc     [ebp].tb_start, 0   ; screen addr =+carry
    inc     w [ebp].tb_image    ; start @ next byte

    sub     [ebp].tb_skewflag, 1 ; reduce planes to skew
    adc     [ebp].tb_skewflag, 0 ; back to 0 if it was -1

    jmp     @tb_copy_plane      ; go copy the next plane

@tb_exit:
    add     esp, 14             ; deallocate workspace
    pop     edi esi ebp         ; restore saved registers
    ret     8                   ; exit and clean up stack

; ==== video memory to video memory copy routines =====

;==================================
;copy_page (sourcepage%, destpage%)
;==================================
;
; duplicate on display page onto another
;
; entry: sourcepage = display page # to duplicate
;        destpage   = display page # to hold copy
;
; exit:  no meaningful values returned
;

cp_stack    struc
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    cp_destp    dw  ?   ; page to hold copied image
    cp_sourcep  dw  ?   ; page to make copy from
cp_stack    ends

        public    copy_page

copy_page:

    push    ebp esi edi         ; preserve important registers
    mov     ebp, esp            ; set up stack frame
    cld                         ; block xfer forwards

; make sure page #'s are valid

    mov     ax, [ebp].cp_sourcep ; get source page #
    cmp     ax, last_page       ; is it > max page #?
    jae     @cp_exit            ; if so, abort

    mov     bx, [ebp].cp_destp  ; get destination page #
    cmp     bx, last_page       ; is it > max page #?
    jae     @cp_exit            ; if so, abort

    cmp     ax, bx              ; pages #'s the same?
    je      @cp_exit            ; if so, abort

; setup esi and edi to video pages

    shl     bx, 2               ; scale index to dword
    mov     edi, page_addr[ebx] ; offset to dest page

    mov     bx, ax              ; index to source page
    shl     bx, 2               ; scale index to dword
    mov     esi, page_addr[ebx] ; offset to source page

    movzx   ecx, page_size      ; get size of page

; setup vga registers for mem to mem copy

    out_16  gc_index, latches_on    ; data from latches = on
    out_16  sc_index, all_planes_on ; copy all planes

; note.. do *not* use movsw or movsd - they will
; screw with the latches which are 8 bits x 4

    rep     movsb               ; copy entire page!

; reset vga for normal memory access

    out_16  gc_index, latches_off   ; data from latches = off

@cp_exit:
    pop     edi esi ebp         ; restore saved registers
    ret     4                   ; exit and clean up stack

;==========================================================================
;copy_bitmap (sourcepage%, x1%, y1%, x2%, y2%, destpage%, destx1%, desty1%)
;==========================================================================
;
; copies a bitmap image from one display page to another
; this routine is limited to copying images with the same
; plane alignment.  to work: (x1 mod 4) must = (destx1 mod 4)
; copying an image to the same page is supported, but results
; may be defined when the when the rectangular areas
; (x1, y1) - (x2, y2) and (destx1, desty1) -
; (destx1+(x2-x1), desty1+(y2-y1)) overlap...
; no paramter checking to done to insure that
; x2 >= x1 and y2 >= y1.  be careful...
;
; entry: sourcepage = display page # with source image
;        x1         = upper left xpos of source image
;        y1         = upper left ypos of source image
;        x2         = lower right xpos of source image
;        y2         = lower right ypos of source image
;        destpage   = display page # to copy image to
;        destx1     = xpos to copy ul corner of image to
;        desty1     = ypos to copy ul corner of image to
;
; exit:  ax = success flag:   0 = failure / -1= success
;

cb_stack    struc
    cb_height   dw  ?   ; height of image in lines
    cb_width    dw  ?   ; width of image in "bands"
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    cb_desty1   dw  ?   ; destination ypos
    cb_destx1   dw  ?   ; destination xpos
    cb_destp    dw  ?   ; page to copy bitmap to
    cb_y2       dw  ?   ; lr ypos of image
    cb_x2       dw  ?   ; lr xpos of image
    cb_y1       dw  ?   ; ul ypos of image
    cb_x1       dw  ?   ; ul xpos of image
    cb_sourcep  dw  ?   ; page containing source bitmap
cb_stack    ends

        public    copy_bitmap

copy_bitmap:

    push    ebp esi edi         ; preserve important registers
    sub     esp, 4              ; allocate workspace on stack
    mov     ebp, esp            ; set up stack frame

; prep registers (and keep jumps short!)

    cld                         ; block xfer forwards

; make sure parameters are valid

    mov     bx, [ebp].cb_sourcep ; get source page #
    cmp     bx, last_page       ; is it > max page #?
    jae     @cb_abort           ; if so, abort

    mov     cx, [ebp].cb_destp  ; get destination page #
    cmp     cx, last_page       ; is it > max page #?
    jae     @cb_abort           ; if so, abort

    mov     ax, [ebp].cb_x1     ; get source x1
    xor     ax, [ebp].cb_destx1 ; compare bits 0-1
    and     ax, plane_bits      ; check plane bits
    jnz     @cb_abort           ; they should cancel out

; setup for copy processing

    out_8   sc_index, map_mask      ; set up for plane select
    out_16  gc_index, latches_on    ; data from latches = on

; compute info about images, setup esi & edi

    mov     ax, [ebp].cb_y2     ; height of bitmap in lines
    sub     ax, [ebp].cb_y1     ; is y2 - y1 + 1
    inc     ax                  ; (add 1 since were not 0 based)
    mov     [ebp].cb_height, ax ; save on stack for later use

    mov     ax, [ebp].cb_x2     ; get # of "bands" of 4 pixels
    mov     dx, [ebp].cb_x1     ; the bitmap occupies as x2-x1
    shr     ax, 2               ; get x2 band (x2 / 4)
    shr     dx, 2               ; get x1 band (x1 / 4)
    sub     ax, dx              ; ax = # of bands - 1
    inc     ax                  ; ax = # of bands
    mov     [ebp].cb_width, ax  ; save on stack for later use

    shl     bx, 2               ; scale source page to dword
    mov     esi, page_addr[bx]  ; si = offset of source page
    mov     ax, [ebp].cb_y1     ; get source y1 line
    mul     screen_width        ; ax = offset to line y1
    movzx   eax, ax
    add     esi, eax            ; si = offset to line y1
    mov     ax, [ebp].cb_x1     ; get source x1
    shr     ax, 2               ; x1 / 4 = byte offset
    add     esi, eax            ; si = byte offset to (x1,y1)

    mov     bx, cx              ; dest page index to bx
    shl     bx, 2               ; scale source page to dword
    mov     edi, page_addr[bx]  ; di = offset of dest page
    mov     ax, [ebp].cb_desty1 ; get dest y1 line
    mul     screen_width        ; ax = offset to line y1
    movzx   eax, ax
    add     edi, eax            ; di = offset to line y1
    mov     ax, [ebp].cb_destx1 ; get dest x1
    shr     ax, 2               ; x1 / 4 = byte offset
    add     edi, eax            ; di = byte offset to (d-x1,d-y1)

    mov     cx, [ebp].cb_width  ; cx = width of image (bands)
    dec     cx                  ; cx = 1?
    je      @cb_only_one_band   ; 0 means image width of 1 band

    mov     bx, [ebp].cb_x1     ; get source x1
    and     bx, plane_bits      ; aligned? (bits 0-1 = 00?)
    jz      @cb_check_right     ; if so, check right alignment
    jnz     @cb_left_band       ; not aligned? well..

@cb_abort:
    clr     ax                  ; return false (failure)
    jmp     @cb_exit            ; and finish up

; copy when left & right clip masks overlap...

@cb_only_one_band:
    mov     bx, [ebp].cb_x1         ; get left clip mask
    and     bx, plane_bits          ; mask out row #
    mov     al, left_clip_mask[bx]  ; get left edge mask
    mov     bx, [ebp].cb_x2         ; get right clip mask
    and     bx, plane_bits          ; mask out row #
    and     al, right_clip_mask[bx] ; get right edge mask byte

    out_8   sc_data, al         ; clip for left & right masks

    mov     cx, [ebp].cb_height ; cx = # of lines to copy
    movzx   edx, screen_width   ; dx = width of screen
    clr     ebx                 ; bx = offset into image

@cb_one_loop:
    mov     al, [esi+ebx]       ; load latches
    mov     [edi+ebx], al       ; unload latches
    add     bx, dx              ; advance offset to next line
    loopjz  cx, @cb_one_done    ; exit loop if finished

    mov     al, [esi+ebx]       ; load latches
    mov     [edi+ebx], al       ; unload latches
    add     bx, dx              ; advance offset to next line
    loopx   cx, @cb_one_loop    ; loop until finished

@cb_one_done:
    jmp     @cb_finish          ; outa here!

; copy left edge of bitmap

@cb_left_band:

    out_8   sc_data, left_clip_mask[bx] ; set left edge plane mask

    mov     cx, [ebp].cb_height ; cx = # of lines to copy
    mov     dx, screen_width    ; dx = width of screen
    clr     ebx                 ; bx = offset into image

@cb_left_loop:
    mov     al, [esi+ebx]       ; load latches
    mov     [edi+ebx], al       ; unload latches
    add     bx, dx              ; advance offset to next line
    loopjz  cx, @cb_left_done   ; exit loop if finished

    mov     al, [esi+ebx]       ; load latches
    mov     [edi+ebx], al       ; unload latches
    add     bx, dx              ; advance offset to next line
    loopx   cx, @cb_left_loop   ; loop until finished

@cb_left_done:
    inc     edi                 ; move dest over 1 band
    inc     esi                 ; move source over 1 band
    dec     [ebp].cb_width      ; band width--

; determine if right edge of bitmap needs special copy

@cb_check_right:
    mov     bx, [ebp].cb_x2     ; get source x2
    and     bx, plane_bits      ; aligned? (bits 0-1 = 11?)
    cmp     bl, 03h             ; plane = 3?
    je      @cb_copy_middle     ; copy the middle then!

; copy right edge of bitmap

@cb_right_band:

    out_8   sc_data, right_clip_mask[bx]    ; set right edge plane mask

    dec     [ebp].cb_width      ; band width--
    mov     cx, [ebp].cb_height ; cx = # of lines to copy
    mov     dx, screen_width    ; dx = width of screen
    movzx   ebx, [ebp].cb_width ; bx = offset to right edge

@cb_right_loop:
    mov     al, [esi+ebx]       ; load latches
    mov     [edi+ebx], al       ; unload latches
    add     bx, dx              ; advance offset to next line
    loopjz  cx, @cb_right_done  ; exit loop if finished

    mov     al, [esi+ebx]       ; load latches
    mov     [edi+ebx], al       ; unload latches
    add     bx, dx              ; advance offset to next line
    loopx   cx, @cb_right_loop  ; loop until finished

@cb_right_done:

; copy the main block of the bitmap

@cb_copy_middle:

    mov     cx, [ebp].cb_width  ; get width remaining
    jcxz    @cb_finish          ; exit if done

    out_8   sc_data, all_planes ; copy all planes

    mov     dx, screen_width    ; get width of screen minus
    sub     dx, cx              ; image width (for adjustment)
    movzx   edx, dx
    mov     ax, [ebp].cb_height ; ax = # of lines to copy
    movzx   ecx,cx
    mov     ebx, ecx            ; bx = quick rep reload count

; actual copy loop.  rep movsb does the work

@cb_middle_copy:
    mov     ecx, ebx            ; recharge rep count
    rep     movsb               ; move bands
    loopjz  ax, @cb_finish      ; exit loop if finished

    add     esi, edx            ; adjust esi to next line
    add     edi, edx            ; adjust edi to next line

    mov     ecx, ebx            ; recharge rep count
    rep     movsb               ; move bands

    add     esi, edx            ; adjust esi to next line
    add     edi, edx            ; adjust edi to next line
    loopx   ax, @cb_middle_copy ; copy lines until done

@cb_finish:
    out_16  gc_index, latches_off   ; data from latches = on

@cb_exit:
    add     esp, 4              ; deallocate stack workspace
    pop     edi esi ebp         ; restore saved registers
    ret     16                  ; exit and clean up stack

; return to mode 03 before exiting to dos

        public mode03

mode03:
        mov v86r_ax,3h
        mov al,10h
        int 33h
        ret

fb_stack    struc
    fb_add      dw  ?
    fb_count    dd  ?
                dd  ?x3 ; edi, esi, ebp
                dd  ?   ; caller
    fb_pal      dd  ?   ; source palette
fb_stack    ends

        public wipeoffpalette
        public fadeoffpalette
        public fadeonpalette

; load esi to palette

tmppal  db 768 dup (0)

wipeoffpalette:

        xor     al,al
        mov     dx,3c8h
        out     dx,al
        inc     dx
        mov     cx,768
        xor     al,al

wipeit: out     dx,al
        loop    wipeit

        ret

fadeoffpalette:
        mov     bh, 2
        mov     ah,0
        jmp     fadepalette

fadeonpalette:
        mov     bh,-2
        mov     ah,64

fadepalette:
        push    ebp esi edi         ; preserve important registers
        sub     esp, 6
        mov     ebp, esp            ; set up stack frame
        mov     ecx,32
        cld                         ; block xfer forwards
fonp2:
        mov     esi,[ebp].fb_pal
        mov     [ebp].fb_add,ax
        mov     [ebp].fb_count,ecx

        mov     edi,offset tmppal
        mov     ecx,768

fonp1:
        lodsb
        sub     al,ah
        jnc     fonp3
        xor     al,al
fonp3:
        stosb
        loop    fonp1

        call    sync_display
        mov     dx,3c8h
        mov     esi,offset tmppal
        mov     ecx,768/6/2
        xor     al,al
        out     dx,al
        inc     dx

fonp4:
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        loop    fonp4

        call    sync_display
        mov     dx,3c8h
        mov     ecx,768/6/2

fonp5:
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        loop    fonp5

        mov     ecx,[ebp].fb_count
        mov     ax,[ebp].fb_add
        add     ah,bh
        loop    fonp2

        add     esp,6
        pop     edi esi ebp

        ret     4

        public turn_screen_off
        public turn_screen_on

turn_screen_off:           ; guess what these do!
        mov dx,03dah
        in al,dx
        mov dx,03c0h
        mov al,0
        out dx,al
        ret

turn_screen_on:
        mov dx,03dah
        in al,dx
        mov dx,03c0h
        mov al,20h
        out dx,al
        ret

code32  ends
        end
