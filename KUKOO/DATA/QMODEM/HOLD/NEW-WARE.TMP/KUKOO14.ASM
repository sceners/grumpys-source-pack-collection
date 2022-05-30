
STACK  SEGMENT WORD STACK  'STACK'
        db 256 dup(?)
STACK  ENDS

DATA   SEGMENT PARA PUBLIC 'DATA'

;---- !! Ne pas bouger !! -----
        INCLUDE c:\masm\dompub\demo\inc\2\alibi.txt
;------------------------------

Kukoo   LABEL BYTE
        include c:\masm\data\kron5.pak
Kuklen  EQU $ - OFFSET Kukoo

Fonte   LABEL BYTE
        include c:\masm\data\fonte.asc

        EVEN
Rasters BYTE 0,2,4,6,8,10,12,13,14,15,16,17,18,19,20,21,22,23
        BYTE 24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44
        BYTE 45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
        BYTE 62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42
        BYTE 41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22
        BYTE 21,20,19,18,17,16,15,14,13,12,10,8,6,4,2
Rastlen EQU  ($ - OFFSET Rasters)

        EVEN
Gradian LABEL BYTE
        i = 0
        REPT 64/2
        BYTE i,0,63   ; bleu fonc‚ --> violet
        i = i+2
        ENDM
        i=63
        REPT 63/2
        i = i-2
        BYTE 63,0,i   ; violet --> rouge
        ENDM
        i = 1
        REPT 63/2
        BYTE 63,i,0   ; rouge --> jaune
        i = i+2
        ENDM
        i = 63
        REPT 63/2
        i = i-2
        BYTE i,63,0   ; jaune --> vert
        ENDM
        i = 1
        REPT 63/2
        BYTE 0,63,i   ; vert --> bleu clair
        i = i+2
        ENDM
        i=63
        REPT 63/2
        i = i-2
        BYTE 0,i,63   ; bleu clair --> bleu fonc‚
        ENDM
        i = 1
        REPT 63/2
        BYTE i,0,63   ; bleu fonc‚ --> violet
        i = i+2
        ENDM

        i=63
        REPT 63/2
        i = i-2
        BYTE 63,0,i   ; violet --> rouge
        ENDM
        i = 1
        REPT 63/2
        BYTE 63,i,0   ; rouge --> jaune
        i = i+2
        ENDM
        i = 63
        REPT 5
        i = i-2
        BYTE i,63,0   ; jaune --> vert
        ENDM

Gradlen EQU ($-OFFSET Gradian)/3


Sorry   BYTE 10,13,'Sorry Dude, You must have VGA card to see dis ANSI Screen..',10,13

Bye     BYTE 'Don''t Forget to contact us : +32-2-3461778 Pleasure Access BBS',10,13
        BYTE '- Last Demos - 80 Mo MODs files - Sexy GIFs - Best Freeware -',10,13
        BYTE 10,13
        BYTE 'You can send Email to : llardin@is1.vub.ac.be',10,13
        BYTE '          or Fido  to : 2:291/725.2 (Kawasaki)',10,13,10,13
        BYTE 'CU l8r... ',10,13,'$'

Autor   BYTE 10,13,'Dis ANSI Screen was coded by -= Type One =-',10,13
        BYTE 'Zake & AdLib player by JCH from Vibrants...',10,13,10,13,'$'

OldMode BYTE ?

Bing    LABEL BYTE
        INCLUDE c:\masm\data\bingbon3.pan ; Rebondissement
LBing   EQU ($-OFFSET Bing)/3

Fwit    LABEL BYTE
        INCLUDE c:\masm\data\fwit3.pan    ; Fuite
LFwit   EQU ($-OFFSET Fwit)/3

Logo    LABEL BYTE
        INCLUDE c:\masm\data\logo.xy      ; d‚placement du logo...
LEnd    EQU $-1
LStart  EQU OFFSET Logo + 128*4           ; adr. d‚but tourni...

        EVEN
SRol    LABEL WORD
        INCLUDE c:\masm\data\sinus.rol    ; Sinus pour rasters
LSRol   EQU ($-OFFSET SRol)/2

Indice  WORD 0                            ; indice Sinus


; ‚cran de travail pour les rasters
Rolo1   BYTE 8*3*Rastlen DUP(0)
Rolo2   BYTE 8*3*Rastlen DUP(0)
RolPt   DW OFFSET Rolo1,OFFSET Rolo2      ; pointeur sur ‚cran de travail

; datas rouleaux

Glon    BYTE 1*2,2*2, 3*2, 4*2, 5*2, 6*2, 7*2, 6*2, 5*2, 4*2, 3*2, 2*2, 1*2,0
LGlon   EQU ($-OFFSET Glon)
        BYTE 1*2,2*2, 3*2, 5*2, 6*2, 7*2, 8*2, 7*2, 6*2, 5*2, 3*2, 2*2, 1*2,0
        BYTE 1*2,3*2, 4*2, 5*2, 7*2, 8*2, 9*2, 8*2, 7*2, 5*2, 4*2, 3*2, 1*2,0
        BYTE 2*2,3*2, 5*2, 6*2, 8*2, 10*2,11*2,10*2,8*2, 6*2, 5*2, 3*2, 2*2,0
        BYTE 2*2,4*2, 6*2, 8*2, 10*2,12*2,14*2,12*2,10*2,8*2, 6*2, 4*2, 2*2,0
        BYTE 3*2,5*2, 8*2, 11*2,13*2,16*2,19*2,16*2,13*2,11*2,8*2, 5*2, 3*2,0
        BYTE 4*2,8*2, 12*2,16*2,20*2,24*2,28*2,24*2,20*2,16*2,12*2,8*2, 4*2,0
        BYTE 8,16,24,32,40,48,56,48,40,32,24,16,8,0

; Palette de L'ANSI

Palette BYTE 0,0,0, 0,0,43, 10,53,10, 10,53,53, 49,0,0, 43,0,43, 0,0,43
        BYTE 43,43,43, 22,22,22, 22,22,63, 22,63,22, 22,63,63, 63,00,00
        BYTE 63,22,63, 63,35,00, 63,63,63

DecLog  BYTE 0,0,1,0

DATA    ENDS


.286
CODE  SEGMENT WORD PUBLIC 'CODE'
      ASSUME  CS:CODE, DS:DATA, SS:STACK

;---- MACROs ----

HSYNC MACRO          ; !! Sp‚cifique au Rasters !!
      mov  ah,dl

      mov  dl,0dah
@@:   in   al,dx
      jmp  $+2
      test al,01
      jnz  @B
@@:   in   al,dx
      jmp  $+2
      test al,01
      jz   @B

      mov  dl,ah
      ENDM

VSYNC MACRO
      call WaitVbl
      ENDM

STARTUP MACRO
        mov ax,DATA
        mov ds,ax
        ENDM

EXIT    MACRO
        mov ax,4c00h
        int 21h
        ENDM

;----------------

;---------------------- INIT ------------------------------------------

GO:      STARTUP

         mov     ah,0fh
         int     10h
         mov     OldMode,al          ; Sauve Mode courant

         mov     ax,0013h            ; VGA Detect
         int     10h
         mov     ah,0fh
         int     10h
         cmp     al,13h
         je      VGA_Ok
         lea     dx,Sorry            ; Sorry You've not...
         mov     ah,9
         int     21h
         EXIT

VGA_Ok:  cli

         mov     ax,0003h            ; Text Mode
         int     10h

         mov     ax,ds               ; Set our Font...
         mov     es,ax               ; Font Seg...
         mov     bp,OFFSET Fonte     ; Offset...
         mov     bh,16               ; 16 bytes/char
         mov     cx,96               ; 96 symbols...
         mov     dx,32               ; … partir du char. 32
         xor     bl,bl               ; 1er bloc...
         mov     ax,1110h            ; load 8x16 font
         int     10h                 ; geeeeezzzz....

         VSYNC

         mov     dx,3d4h             ; Some parameters to change
         mov     al,0ah              ; in the VGA config.
         out     dx,al
         inc     dl
         in      al,dx
         and     al,11100000y        ; cursor OFF
         out     dx,al
         dec     dl
         mov     al,0bh
         out     dx,al
         inc     dl
         in      al,dx
         and     al,11100000y
         out     dx,al
         dec     dl
         mov     ax,82*256+13h       ; 164 colonnes de large
         out     dx,ax               ; --> Change LineWidth

                                     ; OverScan Haut-Bas (82x29)
         mov     ax,205*256+10h      ; VSync Start
         out     dx,ax
         mov     ax,14*256+11h       ; VSync End + Protect CR0-CR7 OFF
         out     dx,ax
         mov     ax,221*256+06h      ; Vertical Total
         out     dx,ax
         mov     ax,204*256+12h      ; Vertical Displayed
         out     dx,ax
         mov     ax,205*256+15h      ; VBlank Start
         out     dx,ax
         mov     ax,209*256+16h      ; VBlank End
         out     dx,ax
                                     ; I don't want horizontal border !!!!
         mov     ax,82*256+01h       ; Horizontal Display END
         out     dx,ax
         mov     ax,81*256+02h       ; Start Horizontal Blanking
         out     dx,ax
         mov     ax,87*256+04h       ; Start Horizontal Retrace
         out     dx,ax
         mov     ax,(128+2)*256+03h  ; End Horizontal Blanking
         out     dx,ax
         mov     ax,(128+0)*256+05h  ; End Horizontal Retrace
         out     dx,ax

         mov     dx,3c0h             ; Pixel Panning Compatibility...
         mov     al,30h
         out     dx,al
         inc     dl
         in      al,dx
         dec     dl
         or      al,00100000y
         out     dx,al

         mov     dx,3c8h             ; 2,3 couleurs … changer
         xor     al,al
         out     dx,al
         inc     dl
         mov     si,OFFSET Palette
         mov     cx,6
@@:      outsb
         outsb
         outsb
         loop    @B
         dec     dl
         mov     al,20
         out     dx,al
         inc     dl
         mov     cx,10
@@:      outsb
         outsb
         outsb
         loop    @B


         mov     dx,3d4h             ; cache la 1Šre page
         mov     ax,HIGH(82)*256+0ch
         out     dx,ax
         mov     ax,LOW(82)*256+0dh
         out     dx,ax
         VSYNC

         mov     ax,0b800h           ; Clear TEXT Memory...
         mov     es,ax
         xor     di,di
         xor     ax,ax
         mov     cx,32768/2
         rep     stosw

         mov     di,2                ; centrer image
         mov     si,OFFSET IMAGEDATA ; Affiche l'ANSI
         mov     cx,IMAGEDATA_LENGTH
         call    UNCRUNCH

         push    ds
         mov     ax,es
         mov     ds,ax
         xor     si,si               ; duplique la partie Info
         mov     di,164*2*(29*2)
         mov     cx,164*11           ; 11 lignes … copier
         rep     movsw
         pop     ds


;-- init rasterpage 1 --

         mov     ax,ds               ; copy background
         mov     es,ax

         mov     di,OFFSET Rolo1
         xor     ax,ax

         mov     si,OFFSET Rasters
         mov     cx,Rastlen
@@:      stosw
         stosb
         movsb                       ; rouleau bleu
         add     di,4                ; skip la couleur 1
         loop    @B

         mov     si,OFFSET Rasters
         mov     cx,Rastlen
@@:      stosw
         movsb                       ; rouleau vert
         stosb
         add     di,4                ; skip la couleur 1
         loop    @B

         mov     si,OFFSET Rasters
         mov     cx,Rastlen
@@:      stosw
         stosb
         movsb                       ; rouleau bleu
         add     di,4                ; skip la couleur 1
         loop    @B


         mov     si,OFFSET Gradian   ; joli d‚grad‚
         mov     di,OFFSET Rolo1+4
         mov     cx,285
         xor     al,al
@@:      movsw
         movsb
         stosb
         add     di,4
         loop    @B

         mov     ax,43*256
         mov     cx,Rastlen*3-285
@@:      stosb
         stosw
         stosb
         add     di,4
         loop    @B

         mov     si,OFFSET Rolo1
         mov     di,OFFSET Rolo2     ; dupliquer la page
         mov     cx,Rastlen*4*3
         rep     movsw


;------------------------------------------------------------------------------
         mov     ax,DATA             ; adr. AdLib Player
         mov     cs:Player[2],ax
         mov     ah,6
         call    PlayMusic
         jnc     NO_CARD_PRESENT
         mov     BYTE PTR cs:[PlayM],0C3h ; RET
NO_CARD_PRESENT:
         mov     ah,0                ; init music
         mov     bx,DATA
         mov     cx,2390
         call    PlayMusic
         mov     ah,2
         mov     bx,0
         call    PlayMusic
;------------------------------------------------------------------------------

;----------- Fait Rebondir -----------

         cli
         mov     cx,LBing
         mov     si,OFFSET Bing
         VSYNC
Rebond:  mov     dx,3d4h             ; CRT Port
         mov     al,0ch              ; FAIT REBONDIR
         out     dx,al
         inc     dl
         outsb                       ; HIGH(adr)
         dec     dl
         inc     al
         out     dx,al
         inc     dl
         outsb                       ; LOW(adr)
         dec     dl

         push    cx
         push    si
         mov     ah,3                ; play music
         call    PlayMusic
         pop     si
         pop     cx

         VSYNC
         mov     dx,3d4h
         mov     al,08h
         out     dx,al
         inc     dl
         outsb                       ; Vertical Panning

         push    si
         push    cx
         mov     dx,3C8h             ; Rasters
         mov     si,OFFSET Rolo1
         mov     cx,Rastlen*3
fill2:   HSYNC                       ; !Warning! Destroy AX
         outsw                       ; col 0
         inc     dl
         outsb
         outsb
         outsb                       ; col 1
         outsb
         outsb
         inc     si
         dec     dl
         loop    fill2
         pop     cx
         pop     si

         loop    Rebond

;----- On peut splitter l'‚cran … pr‚sent !!!! ------

         mov     dx,3d4h             ; Line Compare
         mov     al,07h              ; overflow reg.
         out     dx,al
         inc     dl
         in      al,dx
         or      al,00010000y        ; set bit 9 LC
         out     dx,al
         dec     dl
         mov     al,09h              ; max scan line reg.
         out     dx,al
         inc     dl
         in      al,dx
         and     al,10111111y        ; clear bit 10 LC
         out     dx,al
         dec     dl
         mov     ax,32*256+18h       ; set 8 bits LC
         out     dx,ax



;------------------------------------------------------------------------------

;------- Main Part ---------

         mov     si,OFFSET Logo

Main:    mov     dx,3d4h             ; CRT Port
         mov     al,0ch              ; FAIT mover le logo
         out     dx,al
         inc     dl
         outsb                       ; HIGH(adr)
         dec     dl
         inc     al
         out     dx,al
         inc     dl
         outsb                       ; LOW(adr)

         push    si
         mov     ah,3                ; play music
         call    PlayMusic
         pop     si

         VSYNC

         mov     dx,3d4h
         mov     al,08h
         out     dx,al
         inc     dl
         outsb                       ; Vertical Panning
         mov     dx,3c0h
         mov     al,33h
         out     dx,al
         outsb                       ; Horizontal Panning

         cmp     si,LEnd
         jb      @F
         mov     si,OFFSET LStart    ; on recommence le tour....
@@:

         push    si

         mov     dx,3C8h             ; Rasters
         mov     si,WORD PTR[RolPt]
         mov     cx,Rastlen*3
fill:    HSYNC                       ; !Warning! Destroy AX
         outsw                       ; col 0
         inc     dl
         outsb
         outsb
         outsb                       ; col 1
         outsb
         outsb
         inc     si
         dec     dl
         loop    fill

         call    RastIT              ; faire mover les rasters

         pop     si

         in      al,60h              ; EXIT ?
         cmp     al,39h
         jne     Main


;------  on peut enlever le logo maintenant... ------

         mov     cx,75               ; d‚lai +- calcul‚ au pif....
LogOut:  push    cx

         mov     al,DecLog+2         ; faire remonter le logo...
         add     [si+2],al
         cmp     BYTE PTR[si+2],15
         jbe     @F
         and     BYTE PTR[si+2],15
         add     BYTE PTR[si+1],82*2
         adc     BYTE PTR[si],0
@@:      mov     al,DecLog+1
         add     [si+1],al
         mov     al,DecLog
         adc     [si],al

         add     DecLog+2,4
         cmp     DecLog+2,16
         jb      @F
         mov     DecLog+2,0
         add     DecLog+1,82*2
         adc     DecLog,0
@@:

         mov     dx,3d4h             ; CRT Port
         mov     al,0ch              ; FAIT mover le logo
         out     dx,al
         inc     dl
         outsb                       ; HIGH(adr)
         dec     dl
         inc     al
         out     dx,al
         inc     dl
         outsb                       ; LOW(adr)

         push    si
         mov     ah,3                ; play music
         call    PlayMusic
         pop     si

         VSYNC

         mov     dx,3d4h
         mov     al,08h
         out     dx,al
         inc     dl
         outsb                       ; Vertical Panning
         mov     dx,3c0h
         mov     al,33h
         out     dx,al
         outsb                       ; Horizontal Panning

         cmp     si,LEnd
         jb      @F
         mov     si,OFFSET LStart    ; on recommence le tour....
@@:

         push    si

         mov     dx,3C8h             ; Rasters
         mov     si,WORD PTR[RolPt]
         mov     cx,Rastlen*3
fille:   HSYNC                       ; !Warning! Destroy AX
         outsw                       ; col 0
         inc     dl
         outsb
         outsb
         outsb                       ; col 1
         outsb
         outsb
         inc     si
         dec     dl
         loop    fille

         call    RastIT              ; faire mover les rasters

         pop     si

         pop     cx
         dec     cx
         jnz     LogOut

;------ 

;------------------------------------------------------------------------------

         VSYNC
         mov     dx,3C8h             ; Rasters
         mov     si,WORD PTR[RolPt]
         mov     cx,Rastlen*3
fill4:   HSYNC                       ; !Warning! Destroy AX
         outsw                       ; col 0
         inc     dl
         outsb
         outsb
         outsb                       ; col 1
         outsb
         outsb
         inc     si
         dec     dl
         loop    fill4

         call    RastIt

         mov     dx,3d4h             ; D‚Splittage de l'‚cran...
         mov     ax,255*256+18h      ; set 8 bits LC
         out     dx,ax
         mov     ax,15*256+08h       ; un petit d‚calage vers le bas
         out     dx,ax
         mov     dx,3c0h             ; pas de d‚calage horizontal...
         mov     al,33h
         out     dx,al
         xor     al,al
         out     dx,al

;------ Escape ------

         mov     cx,LFWit
         mov     si,OFFSET Fwit
Escape:  mov     dx,3d4h             ; CRT Port
         mov     al,0ch              ; FAIT S'ECHAPPER
         out     dx,al
         inc     dl
         outsb                       ; HIGH(adr)
         dec     dl
         inc     al
         out     dx,al
         inc     dl
         outsb                       ; LOW(adr)

         push    cx
         push    si
         mov     ah,3                ; play music
         call    PlayMusic
         pop     si
         pop     cx

         VSYNC
         mov     dx,3c0h
         mov     al,33h
         out     dx,al
         outsb                       ; Horizontal Panning

         push    si
         push    cx
         mov     dx,3C8h             ; Rasters
         mov     si,WORD PTR[RolPt]
         mov     cx,Rastlen*3
fill3:   HSYNC                       ; !Warning! Destroy AX
         outsw                       ; col 0
         inc     dl
         outsb
         outsb
         outsb                       ; col 1
         outsb
         outsb
         inc     si
         dec     dl
         loop    fill3
         call    RastIt
         pop     cx
         pop     si

         loop    Escape

;------------------------------------------------------------------------------

;----- EXIT -----

         mov     ah,2
         mov     bx,0
         call    PlayMusic              ; Stop Music
         sti

         mov     al,OldMode             ; Ancien Mode
         xor     ah,ah
         int     10h

         lea     dx,Autor               ; Who has coded dis stuff ?
         mov     ah,9
         int     21h
         lea     dx,Bye                 ; Contact us !!!
         mov     ah,9
         int     21h

         EXIT

;------------------------------------------------------------------------------

RastIT    PROC NEAR   ; !! ES=DS !!


          mov  di,WORD PTR[RolPt]       ; take working buffer
          xchg di,WORD PTR[RolPt+2]     ; & swap
          mov  WORD PTR[RolPt],di
          inc  di
          mov  bp,di

          xor  al,al
          mov  cx,Rastlen*3             ; clear moving rasters
@@:       stosb
          add  di,7
          loop @B

          mov  si,OFFSET Glon           ; motif
          mov  bx,Indice                ; Indice courant
          add  bx,OFFSET SRol
          add  Indice,2                 ; Incr‚menter
          and  Indice,511               ; modulo...

          mov  dx,16
          REPT 8
          mov  di,bp                    ; Copier les rouleaux
          add  di,WORD PTR[bx]          ; position
          mov  cx,LGlon/2
@@:       lodsw
          mov  BYTE PTR[di],al
          mov  BYTE PTR[di+8],ah
          add  di,dx
          loop @B
          add  bx,12                    ; index+6 position
          ENDM


          ret

RastIT    ENDP

PlayMusic PROC NEAR

PlayM     LABEL  NEAR
          nop
          call   DWORD PTR cs:[Player]
          cli
          ret

Player    DW     0,0

PlayMusic ENDP


WaitVbl  PROC NEAR

         push ax
         push dx

         mov  dx,3dah
@@:      in   al,dx
         jmp  $+2
         test al,08
         jnz  @B
@@:      in   al,dx
         jmp  $+2
         test al,08
         jz   @B

         pop  dx
         pop  ax

         ret

WaitVbl  ENDP

;THEDRAW IMAGE UNCRUNCHING ROUTINE
;-----------------------------------------------------------------------------
;Compatible with MASM (Microsoft) and TASM v1.0 (Borland).  Minor format
;changes may be required for other assemblers.
;-----------------------------------------------------------------------------
;
;This is the routine for displaying crunched TheDraw image files.  The
;crunched data format is a simple custom protocol for reproducing any image.
;The control codes below decimal 32 are reserved for this function.
;Characters 32 and above are written directly to the destination address.
;
;The following shows the format of a control code sequence.  Please note that
;not all functions use the optional bytes <x> or <y>.
;
;Data Structure:  <current byte>[<x>[<y>]]
;
;   0..15 = New Foreground Color
;  16..23 = New Background Color
;      24 = Go down to next line, return to same horizontal position as when
;           routine was started (akin to a c/r).
;      25 = Displays <x> number of spaces.
;      26 = Displays <x> number of <y>.  Also used to display ANY characters
;           below #32.  This function is the only way to do this although it
;           uses three bytes.  Otherwise the code would be interpreted as
;           another command.
;      27 = Toggles on/off the foreground attribute blink flag.
;  28..31 = reserved
;
;----------------------------------------------------------------------------
;
;To use the routine, call the uncrunch procedure with the DS:SI register pair
;pointing to the TheDraw output listing, the ES:DI register pair pointing to
;the destination display address, and the length of the crunched image data
;in the CX register.  All modified registers are restored upon exiting.
;
;Assume an output file of a 40 character by 10 line block.  The label
;'IMAGEDATA' has been added for referencing purposes. ie:
;
;
;     ;TheDraw Assembler Crunched Screen Image
;     IMAGEDATA_WIDTH EQU 40
;     IMAGEDATA_DEPTH EQU 10
;     IMAGEDATA_LENGTH EQU 467
;     IMAGEDATA LABEL BYTE
;                DB      ...list of image bytes here...
;
;
;The following assembly language code could then be used to display the
;40x10 block on the screen with:
;
;                MOV     SI,offset IMAGEDATA
;                MOV     AX,0B800h
;                MOV     ES,AX
;                MOV     DI,34*2 + 5*160-162
;                MOV     CX,IMAGEDATA_LENGTH
;                CALL    UNCRUNCH
;
;The data segment (DS register) is assumed to point at the segment ImageData
;resides in.   The ES:DI register pair points at position (34,5) on the color
;graphics adapter screen, calculated as an offset from the start of the screen.
;Monochrome card users, replace the 0B800h with 0B000h.
;
;The original horizontal starting offset is remembered by the uncrunch routine.
;The offset is restored upon moving down to the next line.  This permits a
;block to be displayed correctly anywhere on the screen.  ie:
;
;              ÚÄ horizontal starting offset
;              V
;  +-------------------------------------------------+
;  |                                                 |
;  |                                                 | <- Assume this
;  |                                                 |    is the video
;  |           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿               |    display.
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛ ImageData block ÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ               |
;  |                                                 |
;  |                                                 |
;  |                                                 |
;  +-------------------------------------------------+
;
;
;To display the block in the lower-right corner, change the DI assignment to:
;
;                MOV     DI,40*2 + 15*160-162
;
;The block is 40 characters wide by 10 lines deep.  To display on a 80 by 25
;screen, we must display the block at coordinates (40,15).  To display in
;the upper-left screen corner use:
;
;                MOV     SI,offset IMAGEDATA
;                MOV     AX,0B800H
;                MOV     ES,AX
;                MOV     DI,1*2 + 1*160-162       ;coordinates 1,1
;                MOV     CX,IMAGEDATA_LENGTH
;                CALL    UNCRUNCH
;
;Notice in both cases only the offset address changed.  Note the latter case
;is also used for displaying a full screen image (which in general are
;always displayed at coordinate 1,1).
;
;----------------------------------------------------------------------------
;
;That's it!  The routine was designed for easy use and understanding; however,
;for some people the best way is to experiment.  Create a program using the
;above examples, perhaps with a 40x10 block (or any size).  Good luck!
;

UNCRUNCH PROC NEAR
;
;Parameters Required:
;  DS:SI  Crunched image source pointer.
;  ES:DI  Display address pointer.
;  CX     Length of crunched image source data.
;
       PUSH    SI                      ;Save registers.
       PUSH    DI
       PUSH    AX
       PUSH    BX
       PUSH    CX
       PUSH    DX
       JCXZ    Done

       MOV     DX,DI                   ;Save X coordinate for later.
       XOR     AX,AX                   ;Set Current attributes.
       CLD

LOOPA: LODSB                           ;Get next character.
       CMP     AL,32                   ;If a control character, jump.
       JC      ForeGround
       STOSW                           ;Save letter on screen.
Next:  LOOP    LOOPA
       JMP     Short Done

ForeGround:
       CMP     AL,16                   ;If less than 16, then change the
       JNC     BackGround              ;foreground color.  Otherwise jump.
       AND     AH,0F0H                 ;Strip off old foreground.
       OR      AH,AL
       JMP     Next

BackGround:
       CMP     AL,24                   ;If less than 24, then change the
       JZ      NextLine                ;background color.  If exactly 24,
       JNC     FlashBitToggle          ;then jump down to next line.
       SUB     AL,16                   ;Otherwise jump to multiple output
       ADD     AL,AL                   ;routines.
       ADD     AL,AL
       ADD     AL,AL
       ADD     AL,AL
       AND     AH,8FH                  ;Strip off old background.
       OR      AH,AL
       JMP     Next

NextLine:
       ADD     DX,328 ;160             ;If equal to 24,
       MOV     DI,DX                   ;then jump down to
       JMP     Next                    ;the next line.

FlashBitToggle:
       CMP     AL,27                   ;Does user want to toggle the blink
       JC      MultiOutput             ;attribute?
       JNZ     Next
       XOR     AH,128                  ;Done.
       JMP     Next

MultiOutput:
       CMP     AL,25                   ;Set Z flag if multi-space output.
       MOV     BX,CX                   ;Save main counter.
       LODSB                           ;Get count of number of times
       MOV     CL,AL                   ;to display character.
       MOV     AL,32
       JZ      StartOutput             ;Jump here if displaying spaces.
       LODSB                           ;Otherwise get character to use.
       DEC     BX                      ;Adjust main counter.

StartOutput:
       XOR     CH,CH
       INC     CX
       REP STOSW
       MOV     CX,BX
       DEC     CX                      ;Adjust main counter.
       LOOPNZ  LOOPA                   ;Loop if anything else to do...

Done:  POP     DX                      ;Restore registers.
       POP     CX
       POP     BX
       POP     AX
       POP     DI
       POP     SI
       RET

UNCRUNCH ENDP



CODE     ENDS

 END GO
