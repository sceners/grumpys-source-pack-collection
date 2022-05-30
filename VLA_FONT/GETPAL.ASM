        dosseg
stacks  segment byte stack 'stack'
        thestak         db      256 dup(0h)
stacks  ends

code    segment byte public 'code'
        assume  cs:code, es:code, ds:code, ss:stacks
start:  

        mov     ax,es
        mov     ds,ax
        mov     si,128
        lodsb
        xor     cx,cx
        mov     cl,al
        mov     [inputlength],cx
        mov     ax,cs
        mov     es,ax
        mov     di,offset inputstring
        rep     movsb
        
        jmp main

;===- data -===

        credits db      13,10,"TGA Palette Grabber",13,10
                db      "  By Ben Gardner",13,10,"$"

        properuse db    "TGA Palette Grabber:",13,10
                db      " Use: GETPAL Filename ",13,10
                db      "Directory paths not supported.$",13,10,'$'

        inputstring  db 255 dup ('~')
        inputlength  dw 0

        filename db     "12345678.tga",0,0,0,0 

        ErrorLook dw    offset properuse,offset properuse,offset Nofile
                dw      offset Nopath,offset Nohandle,OFFSET Noaccess
                
        
        nofile          db      10,13,"File not found error.$"
        nopath          db      10,13,"Path not found error.$"
        nohandle        db      10,13,"No handles available.$"
        noaccess        db      10,13,"Access to file denied.$"
        errormes        db      10,13,"Program aborted.$"
        diskfull        db      10,13,"Disk full.$"

        result          db      10,13,"Program was successful. Cut palette stored in "
        PalName  db     "12345678.pal",0,0,0,'$' 
                       
        
        fileshand       dw      0000h
        filedhand       dw      0000h

        bufferit        dw      768 dup (0)

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

GetCommand proc near
        mov     ax,es
        mov     ds,ax
        mov     si,128
        lodsb
        xor     cx,cx
        mov     cl,al
        mov     [inputlength],cx
        mov     ax,cs
        mov     es,ax
        mov     di,offset inputstring
        mov     al,cl
        rep     movsb
        ret
GetCommand endp        

CaptureFilename proc near
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     si,offset inputstring
        mov     di,offset filename
        xor     bl,bl
Nospace:
        lodsb
        cmp     al,'~'
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
        mov     al,'t'
        stosb
        mov     al,'g'
        stosb
        mov     al,'a'
        stosb
        mov     al,0
        stosb
        mov     al,'$'
        stosb
        mov     di,offset palname
        mov     si,offset filename
        mov     cx,14
        rep     movsb
        mov     di,offset palname+1     ;+1 to get past dot
        xor     bh,bh
        add     di,bx                   ;bx = 0 thru 7
        mov     al,'p'
        stosb
        mov     al,'a'
        stosb
        mov     al,'l'
        stosb
        ret
CaptureFileName endp

;THIS STUFF SETS UP THE PALETTE FOR USE OF TGA TYPE PALETTES        

palettesetup proc near
        mov     dx,offset bufferit
        mov     di,dx
        mov     si,dx
        mov     cx,768
        cld
DIVIDE: 
        lodsb                           ; this routine divides by four
        shr     al,1
        shr     al,1
        stosb
        dec     cx
        jne     divide

        mov     cx,256                  ; no of registers to xchange
        mov     di,dx   
        mov     si,dx                   ; point di to red
        inc     si                      ; and si to blue
        inc     si                      
switchrb:                               ; switches red and blue registers
        mov     al,[di]
        mov     ah,[si]
        mov     [si],al
        mov     [di],ah
        add     di,3
        add     si,3
        dec     cx
        jne     switchrb
        ret

palettesetup endp


;============================
Main:
        ;call    getcommand
        cmp     [inputlength],0
        jne     gotsome
        jmp     noinput
Gotsome:
        mov     ax,cs
        mov     es,ax
        mov     ds,ax
        call    capturefilename

openfiles:
        mov     dx,offset filename      ;load in palette
        sub     al,al                   
        mov     ah,3dh                  
        int     21h                     
        jc      abort                   
        mov     bx,ax                   

        sub     cx,cx                   ;18 past beginning
        mov     dx,18                
        mov     ax,4200h             
        int     21h                  

        mov     cx,768                  ;read 768 bytes
        mov     dx,offset bufferit    
        mov     ah,3fh               
        int     21h                  
        
        mov     ah,3eh                  ;close source file 
        int     21h                     

        call palettesetup
        
        mov     dx,offset palname 
        sub     cx,cx             
        mov     ah,3ch                  
        int     21h                     
        jc      abort                   
        mov     bx,ax          
        
        mov     cx,768                  ; the dest file
        mov     ah,40h                  ; load function write
        mov     dx,offset bufferit      ;
        int     21h                     ; write it

        cmp     ax,cx
        je      success
        mov     ah,9                    ; disk full error
        mov     dx,offset diskfull      ;
        int     21h                     ; 
success:
        mov     ah,3eh                  ;close source file 
        int     21h                     
        mov     ah,9
        mov     dx,offset result
        int     21h
        jmp     endit
abort:
        push    ax
        mov     ah,3eh
        int     21h
        pop     ax
        cmp     ax,6
        jb      displayerror
        jmp     noinput
Displayerror:
        mov     bx,ax
        shl     bx,1
        mov     dx,errorlook[bx]
        mov     ah,9                    ; Print string
        int     21h                     ; 
        mov     ah,9
        mov     dx,offset errormes
        int     21h
        
endit:
        mov     ax,4c00h                ; return control to 
        int     21h                     ; DOS and exit

Noinput:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     ah,9
        mov     dx,offset properuse
        int     21h
        mov     ax,4c00h
        int     21h

code    ends
        end     start
