      DOSSEG
      .MODEL SMALL
      .STACK 200h
      .CODE
      .386
      ASSUME CS:@CODE, DS:@CODE
      Ideal

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

OldInt  dd  ?

BaseAddress dw 220h

SampleSeg dw  ?
SampleOff dw  0

FileName  db  "jamhot.sam",0   ;you need to put your filename here...
SamLength dw  ?

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
      
PROC TurnOffSpeaker NEAR
    mov     al,0d3h         ;turn off speaker
    call    Sendcommand
    ret
ENDP TurnOffSpeaker

    ;al = command
PROC SendCommand NEAR
    push    dx
    push    ax
    mov     dx,[cs:BaseAddress]
    add     dx,0ch
sendcommandloop:
    in      al,dx
    or      al,al
    js      sendcommandloop
    pop     ax
    out     dx,al
    pop     dx
    ret
ENDP SendCommand

PROC TurnOnSpeaker NEAR
    mov     al,0d1h
    call    SendCommand
    ret
ENDP TurnOnSpeaker

    ;input- none 
    ;output al=0 successful
    ;       al=1 unsuccessful
    ;Destroys AX,DX,CX
    ;
PROC DspReset NEAR
    mov     dx,[cs:baseaddress]
    add     dx,06h
    mov     al,1
    out     dx,al
    mov     cx,1000
    push    di
    rep     lodsb         ;wait for at least 3�S
    pop     di
    xor     al,al
    out     dx,al

    add     dx,8          ;check status (22eh)
    mov     cx,12000
waitforstat:
    in      al,dx
    dec     cx
    je      errorstat
    or      al,al
    js      WaitForStat

    mov     cx,10000
    sub     dx,4          ;(22ah)      
waitforstat2:
    in      al,dx
    dec     cx
    je      errorstat
    cmp     al,0aah
    jne     waitforstat2
    mov     al,0
    ret
errorstat:
    mov     al,1
    ret
ENDP DspReset

PROC SetUpInterrupt NEAR
    pusha
    push    ds

    mov   ax,0
    mov   ds,ax
    mov   bx,8*4                  ;interrupt 8
    mov   ax,[ds:bx]
    mov   [Word LOW  cs:OldInt],ax
    mov   ax,[ds:bx+2]
    mov   [Word HIGH cs:OldInt],ax

    cli
    mov   [Word ds:bx],offset TimerInt
    mov   [ds:bx+2],cs

    mov   al,36h
    out   43h,al                  ; timer program

    mov   ax,1193180/8000         ; # of ticks between interrupts
                                  ; Clock Freq / HZ
    out   40h,al
    mov   al,ah
    out   40h,al
    sti

    pop     ds
    popa
    ret
ENDP SetUpInterrupt
  
PROC RemoveInterrupt NEAR
    pusha
    push    ds
    
    cli
    mov ax,0
    mov ds,ax
    mov bx,8*4
    mov ax,[Word cs:OldInt]
    mov [ds:bx],ax
    mov ax,[Word cs:OldInt+2]
    mov [ds:bx+2],ax
    mov al,36h
    out 43h,al
    xor al,al
    out 40h,al
    out 40h,al
    sti
    
    pop     ds
    popa
    ret
ENDP  RemoveInterrupt

PROC TimerInt FAR
    pusha
    push    fs
    
    mov     fs,[cs:SampleSeg]
    mov     di,[cs:SampleOff]
    
    mov     al,10h + 0b            ;Direct 8-bit DAC command
    call    SendCommand

    mov     al,[fs:di]
    add     al,128            ;change SAM data (-128 to 127) to SB data 0-255
    call    SendCommand
    
    inc     [cs:SampleOff]
    mov     ax,[CS:SamLength]
    cmp     [cs:SampleOff],ax
    jb      @@NotOver
    mov     [cs:SampleOff],0

@@NotOver:
    mov     al,20h      ;acknowledge hardware interrupt
    out     20h,al

    pop     fs
    popa
    iret
ENDP TimerInt

  ; returns -1 if load not successful
PROC  LoadSample NEAR
    pusha

    mov     ax,cs
    mov     ds,ax
    mov     dx,offset FileName
    mov     ax,3D00h        ;open the file
    int     21h
    jc      @@Error

    mov     bx,ax
    xor     dx,dx             ;load at offset 0
    mov     cx,0ffffh         ;read in a whole segments worth
    mov     ds,[cs:SampleSeg]
    mov     ax,3F00h          ; Load in the sample
    int     21h

    mov     [cs:SamLength],ax

    mov     ax,3E00h          ;close the file
    int     21h
    
    popa
    xor     ax,ax
    ret

@@Error:
    popa
    mov     ax,-1
    ret
ENDP  LoadSample

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

START:
    mov   bx,ss
    add   bx,20h            ;put sample right after stack
    mov   [cs:SampleSeg],bx

    call  LoadSample
    or    al,al
    jne   ByeBye

    call  DspReset
    call  TurnOnSpeaker
    call  SetUpInterrupt    ;starts going after this line

    mov   ah,0
    int   16h               ;wait for a keypress
    
    call  RemoveInterrupt
    call  TurnOffSpeaker

ByeBye:    
    mov   ax,4c00h
    int   21h

END START
