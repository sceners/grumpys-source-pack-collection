    DOSSEG
    .286
    .MODEL SMALL
    .CODE

    ASSUME cs:@code, ds:@code

;====- DATA -=====
;
;upon entry:    Decompressit => loads .CMP image and decompresses it...
;
;*  DS:DX = pointer to filename
;*  AX != 0, image fitted to AX wide window
;*  AX == 0, image decompressed using [Xsize] for width
;*  [FileSeg] and [Destination] must both have valid segmnet values
;
;upon EXIT:
;
;*  AX=0 if no error, 1 means error
;*  Stuff in [FileSeg] is destoryed
;*  Decompressed image is in [Destination] segment
;*  Palette is at CmpPal
;

    GLOBAL  DeCompressIt:NEAR
    GLOBAL  FileSeg:WORD, Destination:WORD, CmpPal:BYTE
    
    FileSeg     dw      0
    Destination dw      0

    CmpPal  db      0,767 dup (0)

    Xsize       dw  0
    Ysize       dw  0
    Repeatcode  db  0
    ScreenWidth dw  320
        
    SegMsg      db  "FATAL! You forgot to load [FileSeg] and/or [Destination]!!$"
    FileMsg     db  "FATAL! File was not openable! (Probably not found.)$"

;========- SubRoutines -========

DeCompressit proc near
        pusha
        push    ds es

        cmp     cs:[FileSeg],0
        je      SegError
        cmp     cs:[Destination],0
        je      SegError

        push    ax

        mov     ax,cs
        mov     es,ax  
        mov     ax,3d00h        ;open file
        int     21h
        jnc     Noabort

        pop     ax

        popa
        mov     ax,1        ;1 means file error
        ret
SegError:
        mov     ax,cs
        mov     ds,ax
        mov     ah,9
        mov     dx,offset SegMsg
        int     21h
        popa
        mov     ax,2        ;2 means segment error
        ret
Noabort:
        mov     bx,ax

        mov     ax,cs:[FileSeg]
        mov     ds,ax
        mov     ax,cs:[Destination]
        mov     es,ax

        mov     cx,0ffffh               ;read whole file ( if < 64k )
        xor     dx,dx    
        mov     ah,3fh               
        int     21h                
        
        mov     ah,3eh                  ;close source file 
        int     21h                     

        mov     al,ds:[3]               ;read 4th byte (offset 3)
        mov     cs:[repeatcode],al
        mov     ax,ds:[4]               ;xsize
        mov     cs:[xsize],ax
        mov     ax,ds:[6]
        mov     cs:[ysize],ax

        pop     ax              ;from push up top
        mov     cs:[ScreenWidth],ax
        or      ax,ax
        jne     WidthAx         ;see if we use AX or Xsize

        mov     ax,cs:[Xsize]   ;use Xsize
        mov     cs:[ScreenWidth],ax
WidthAX:
        xor     di,di
        mov     si,776
                        
        mov     cx,cs:[xsize]
        mov     bx,cs:[ysize]
        mov     dl,cs:[repeatcode]
        push    di
TryAgain:
        lodsb
        cmp     al,dl           ;is byte a repeatcode?
        je      decodeloop      ;yup do decode loop
        stosb                   ;nope, it's a pixel, store it
jumphere:
        dec     cx              ;are we done with this line?
        jne     tryagain        ;no, do another
        mov     cx,cs:[xsize]
        pop     di
        add     di,cs:[ScreenWidth]
        push    di
        dec     bx              ;are we done with height?
        jne     tryagain        ;nope go on
        jmp     alldone         ;Yup, exit out

DECODELOOP:
        lodsw                   ;ah=# of times: al= byte to repeat
        stosb
        jmp     dcskip
Bigloop:
        stosb
        dec     ah              ;are we done with this repeat sequence?
        je      jumphere        ;yup, go back up top
dcskip:
        dec     cx              ;are we done with this line?
        jne     Bigloop
        mov     cx,cs:[xsize]
        pop     di
        add     di,cs:[ScreenWidth]
        push    di
        dec     bx              ;are we done with the picture?
        jne     Bigloop         ;nope, keep going...
        jmp     alldone         ;yup
AllDone:
        pop     di              ;pull garbage di off stack
        
        mov     ax,cs
        mov     es,ax           ;copy palette to CmpPal
        
        mov     si,8
        mov     di,offset CmpPal
        mov     cx,768/2
        rep     movsw
        
        pop     es ds
        popa
        mov     ax,0            ;operation was successful
        ret
DeCompressit endp

    end
