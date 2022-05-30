Data    segment para public 'Data'

include Small.FNT

MessageNumLines equ     48
Message         db      '                                    ',0
                db      '        BBS ADVERTISEMENT BY        ',0
                db      '           FRED NIETZCHE            ',0
                db      '                                    ',0
                db      '         FONTS SNAGGED FROM         ',0
                db      '        THG''S INTROMAKER 3.0        ',0
                db      '                                    ',0
                db      '                                    ',1
                db      '                                    ',0
                db      '                                    ',0
                db      '           - SKYNET BBS -           ',0
                db      '           (301) 890-2972           ',0
                db      '                                    ',0
                db      '   SYSOPS: VIPER * THE ROCKETEER    ',0
                db      '                                    ',0
                db      '                                    ',1
                db      '                                    ',0
                db      '                                    ',0
                db      '    FEATURING...                    ',0
                db      '      * 1.7 GIGS ONLINE!            ',0
                db      '      * SEARCHLIGHT V3.0 BBS        ',0
                db      '      * 14400 V.32/BIS,V.42/BIS     ',0
                db      '                                    ',0
                db      '                                    ',1
                db      '                                    ',0
                db      '                                    ',0
                db      '    SPECIALIZING IN...              ',0
                db      '      * SB/VGA DEMOS/FILES          ',0
                db      '      * .MOD/.MID MUSIC FILES       ',0
                db      '      * LIVELY DISCUSSIONS (HA!)    ',0
                db      '                                    ',0
                db      '                                    ',1
                db      '                                    ',0
                db      '                                    ',0
                db      '   ...AND OF COURSE, THE LATEST     ',0
                db      '   AND GREATEST IN 0-7 DAY WAREZ    ',0
                db      '                                    ',0
                db      '           CALL TODAY!              ',0
                db      '                                    ',0
                db      '                                    ',1
                db      '                                    ',0
                db      '                                    ',0
                db      '                                    ',0
                db      '              OH.....               ',0
                db      '     DID I MENTION 9600+ ONLY?      ',0
                db      '                                    ',0
                db      '                                    ',0
                db      '                                    ',1



MessagePtr      dw      offset Message
MessageLine     dw      0

Data    ends


DisplayNextLine proc    near
; This procedure displays the next message line 'slice' onto the bottom of the
; split screen window.  Assumes ES = 0a000h, and write mode is 0

        mov     dx,03c4h
        mov     ax,0f02h
        out     dx,ax
        mov     al,CurrentLine
        add     al,129
        mov     di,StartAddr
        add     di,SplitHeight*80 + 4
        mov     cx,72
        rep     stosb

        mov     si,MessagePtr
        mov     di,StartAddr
        add     di,SplitHeight*80 + 4   ; (Xstart,Ystart) = (32,SplitHeight)
        mov     cl,3
DNL1:
        lodsb
        cmp     al,1
        jbe     Finished
        sub     al,32
        xor     bx,bx
        mov     bl,al
        shl     bx,6
        xor     ah,ah
        shl     ax,4
        add     bx,ax
        add     bx,MessageLine
        mov     ah,8
DNL2:
        mov     al,[offset Font + bx]
        cmp     al,0
        jz      DNL3

        mov     bp,ax
        mov     ax,0802h
        shr     ah,cl
        mov     dx,03c4h
        out     dx,ax
        mov     ax,bp

        mov     byte ptr es:[di],al

DNL3:
        dec     cl
        jns     DNL4
        inc     di
        mov     cl,3
DNL4:
        inc     bx
        dec     ah
        jnz     DNL2

        jmp     DNL1

Finished:
        add     MessageLine,8
        cmp     MessageLine,80
        jne     DontResetML

        cmp     al,1
        jne     Finished2
        mov     Delay,200
Finished2:

        mov     MessageLine,0
        add     MessagePtr,37
        cmp     MessagePtr,offset Message + MessageNumLines*37
        jne     DontResetML
        mov     MessagePtr,offset Message

DontResetML:
        ret

DisplayNextLine endp


CopyLineToTop   proc    near
; Copies displayed line from the bottom of the split screen window to the
; top portion.  Assumes in write mode 1, data rotate is none, and ES points to
; 0a000h

        mov     bx,ds

        mov     si,StartAddr
        add     si,4
        mov     di,si
        add     si,SplitHeight*80

        mov     dx,03c4h
        mov     ax,0f02h
        out     dx,ax

        mov     ax,0a000h
        mov     ds,ax

        mov     cx,72
        rep     movsb

        mov     ds,bx

        ret

CopyLineToTop   endp
