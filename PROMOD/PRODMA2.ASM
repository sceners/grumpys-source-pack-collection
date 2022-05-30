    DOSSEG
    LOCALS 
    .MODEL SMALL
    .CODE
    .386

    ASSUME  cs:@code, ds:@code

    IDEAL

    INCLUDE "PROMOD.INC"
    
    ;To Initialize:
    ;   DspReset
    ;   TurnOnSpeaker
    ;   SetSampleRate
    ;   CalcForDMA => call whenever song speed changes
    ;
    ;To Start:
    ;   StartTransferDma
    ;
    ;To End:
    ;   mov [QuitDMA],1
    ;   TurnOffSpeaker

    BufferSeg       dw  0
    BufferOffset1   dw  0
    BufferOffset2   dw  0
    Buffer1Size     dw  1000
    Buffer2Size     dw  1000

    StereoOn        db  0       ;0= stereo is OFF.

    LptAddress1     dw  3bch
    LptAddress2     dw  3bch
    BaseAddress     dw  220h
    IntNumber       db  7
    DMANumber       db  1
    DMAPage         dw  83h
    DMAStart        dw  2

    DmaChartPage    dw  87h,83h,82h
    DMAStartChart   db  0,2,6

    WhichBuffer     dw  4

    QuitDma         dw  0

    ;MoreB           db  0,0
    ;IPage           db  0,0,0,0
    ;ILength         dw  1,1,1,1
    ;IOffset         dw  0,0,0,0

STRUC DMAInfo
    Page    dw  ?,?,?,?
    Length  dw  ?,?,?,?
    Offset  dw  ?,?,?,?
    Next    dw  4,4,0,0 ;change 1st to '2' for 2 buffers also 3rd to '6'
    WBuff   dw  3,0,4,0
    Current dw  0       ;0 to 3
ENDS DMAInfo

DMA DMAInfo <>
    
    DmaRoutine      dw  offset TransferDmaMONO
    OldInt          dd  0
    DacBuffOff      dw  0
    DacBuffLen      dw  0

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;==-  DMA Interrupt  -==

PROC DMAINT FAR
    pusha
    cli

    mov     dx,[cs:BaseAddress]
    add     dx,0eh   
    in      al,dx                       ;acknowledge interrupt

    cmp     [cs:QuitDma],1
    je      @@TerminateDMA

    mov     bx,[cs:DMA.Current]         ;grab offset

    mov     ax,[cs:bx + DMA.NEXT]       ;set up for next buffer
    mov     [cs:DMA.Current],ax
    
    mov     ah,[BYTE LOW cs:bx + DMA.Page]
    mov     cx,[cs:bx + DMA.Length]
    mov     dx,[cs:bx + DMA.Offset]
    call    [cs:DmaRoutine]

    mov     bx,[cs:DMA.Current]         ;grab offset
    mov     ax,[cs:bx + DMA.WBuff]
    or      ax,ax
    je      @@DontSetBuffer
    mov     [cs:WhichBuffer],ax
@@DontSetBuffer:
    mov     al,20h
    out     20h,al              ;end of hardware interrupt

    popa
    sti
    iret
@@TerminateDMA:
    mov     [cs:QuitDma],0
    call    UnDoRealInt
    call    HaltDMA
    jmp     @@DontSetBuffer
ENDP DMAINT

;======================
;==- Start Transfer -==
;======================

PROC StartTransferDma NEAR
    pusha

    cmp     [cs:StereoOn],0
    je      NoStereo

    mov     ax,130eh        ;turn stereo on
    call    SetMixer
    mov     ax,0ff22h        ;set master volume = FF
    call    SetMixer
    mov     ax,0ff04h        ;set VOC volume = FF
    call    SetMixer

    mov     [cs:DmaRoutine],offset TransferDMASTEREO

NoStereo:
    mov     al,[cs:IntNumber]
    add     al,8
    cbw
    shl     al,2
    mov     bx,ax

    push    es
    sub     ax,ax
    mov     es,ax
    mov     ax,[es:bx]
    mov     [WORD LOW cs:OldInt],ax              ; Grab the current interrupt
    mov     ax,[es:bx+2]
    mov     [WORD HIGH cs:OldInt],ax              ; so we can restore it later
    pop     es
    
    mov     ax,[cs:DMA.Page]
    mov     ah,al
    mov     cx,[cs:DMA.Length]
    mov     dx,[cs:DMA.Offset]
    
    mov     al,5
    out     0ah,al          ;Mask off channel 1
    xor     al,al
    out     0ch,al          ;Clear byte pointer F/F to lowerbyte
    mov     al,49h  
    out     0bh,al          ;Set transfer mode to DAC (ADC = 45h)
    mov     al,dl           ;LSB of BASE_ADDRESS
    out     2,al
    mov     al,dh           ;MSB of BASE_ADDRESS
    out     2,al
    mov     al,ah
    out     83h,al          ;Page Number
    mov     al,cl
    out     3,al            ;LSB of DATA_Length
    mov     al,ch
    out     3,al            ;MSB of DATA_Length
    mov     al,1
    out     0ah,al          ;Enable Channel 1

    mov     ax,offset DMAInt
    call    DoRealInt

    cmp     [cs:StereoOn],0
    jne     @@StartStereo

    mov     al,14h          ;function 14h DMAmode 8-bit DAC
    call    Sendcommand
    mov     al,cl           ;send LSB of DATALENGTH
    call    SendCommand
    mov     al,ch           ;send MSB of DATALENGTH
    call    SendCommand
    popa
    ret

@@StartStereo:
    mov     al,48h          ;data length command
    call    Sendcommand
    mov     al,cl           ;send LSB of DATALENGTH
    call    SendCommand
    mov     al,ch           ;send MSB of DATALENGTH
    call    SendCommand
    mov     al,91h          ;tell it to GO!
    call    SendCommand

    popa
    ret
ENDP StartTransferDma
    
    ;ah= page number
    ;dx= BASE_ADDRESS
    ;cx= DATA_LENGTH (-1)
    ; This function sets up for write only!
PROC TransferDmaSTEREO NEAR
    mov     al,5
    out     0ah,al          ;Mask off channel 1
    xor     al,al
    out     0ch,al          ;Clear byte pointer F/F to lowerbyte
    mov     al,49h  
    out     0bh,al          ;Set transfer mode to DAC (ADC = 45h)_
    mov     al,dl           ;LSB of BASE_ADDRESS
    out     2,al
    mov     al,dh           ;MSB of BASE_ADDRESS
    out     2,al
    mov     al,ah
    out     83h,al          ;Page Number
    mov     al,cl
    out     3,al            ;LSB of DATA_Length
    mov     al,ch
    out     3,al            ;MSB of DATA_Length
    mov     al,1
    out     0ah,al          ;Enable Channel 1

    mov     al,48h          ;data length command
    call    Sendcommand
    mov     al,cl           ;send LSB of DATALENGTH
    call    SendCommand
    mov     al,ch           ;send MSB of DATALENGTH
    call    SendCommand
    mov     al,91h          ;tell it to GO!
    call    SendCommand

    ret
ENDP TransferDMASTEREO

    ;ah= page number
    ;dx= BASE_ADDRESS
    ;cx= DATA_LENGTH (-1)
    ; This function sets up for write only!
PROC TransferDmaMONO NEAR
    mov     al,5
    out     0ah,al          ;Mask off channel 1
    xor     al,al
    out     0ch,al          ;Clear byte pointer F/F to lowerbyte
    mov     al,49h  
    out     0bh,al          ;Set transfer mode to DAC (ADC = 45h)_
    mov     al,dl           ;LSB of BASE_ADDRESS
    out     2,al
    mov     al,dh           ;MSB of BASE_ADDRESS
    out     2,al
    mov     al,ah
    out     83h,al          ;Page Number
    mov     al,cl
    out     3,al            ;LSB of DATA_Length
    mov     al,ch
    out     3,al            ;MSB of DATA_Length
    mov     al,1
    out     0ah,al          ;Enable Channel 1

    mov     al,14h          ;function 14h DMAmode 8-bit DAC
    call    Sendcommand
    mov     al,cl           ;send LSB of DATALENGTH
    call    SendCommand
    mov     al,ch           ;send MSB of DATALENGTH
    call    SendCommand
    ret
ENDP TransferDMAMONO

    ;ah= SR (Time Constant = 256 - 1,000,000/HZ)
PROC SetSampleRate NEAR
    mov     al,40h
    call    SendCommand
    mov     al,ah
    call    SendCommand
    ret
ENDP SetSampleRate

PROC TurnOffSpeaker NEAR
    mov     al,0d3h         ;turn off speaker
    call    Sendcommand
    ret
ENDP TurnOffSpeaker

PROC HaltDMA NEAR
    mov     al,0d0h         ;Halt DMA
    call    SendCommand
    ret
ENDP HaltDma

    ;al = command
PROC SendCommand NEAR
    push    dx
    push    ax
    mov     dx,[cs:BaseAddress]
    add     dx,0ch
sendcommandloop:
    in      al,dx
    test    al,10000000b
    jnz     sendcommandloop
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
    ;DESTROYED: ax,dx,cx
PROC DspReset NEAR
    mov     dx,[cs:baseaddress]
    add     dx,06h
    mov     al,1
    out     dx,al
    mov     cx,1000
    push    di
    rep     lodsb   ;wait for at least 3æS
    pop     di
    xor     al,al
    out     dx,al

    add     dx,8         ;check WhichBuffer (22eh)
    mov     cx,12000
waitforstat:
    in      al,dx
    dec     cx
    je      errorstat
    test    al,10000000b
    jz      waitforstat

    mov     cx,10000
    sub     dx,4         ;(22ah)      
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

;========================
;==- Start Interrupts -==
;========================

    ;cs:ax=location of interrupt
PROC DoRealint NEAR
    pushf                           ; Push flags
    push    bx
    push    cx
    push    dx
    
    mov     dx,ax
    mov     al,[cs:IntNumber]
    add     al,8
    cbw                             ; Convrt byte to word
    shl     ax,2                    ; Shift w/zeros fill
    mov     bx,ax

    push    es
    sub     ax,ax
    mov     es,ax
    mov     [es:bx],dx
    mov     [es:bx+2],cs
    pop     es

    mov     cl,[cs:IntNumber]
    mov     ah,1
    shl     ah,cl                   ; Shift w/zeros fill
    not     ah
    in      al,21h                  ; port 21h, 8259-1 int IMR
    and     al,ah
    out     21h,al                  ; port 21h, 8259-1 int comands

    pop     dx
    pop     cx
    pop     bx
    popf                            ; Pop flags
    ret
ENDP DoRealint
  
PROC UnDoREALint NEAR
    pushf
    pusha
    
    mov     al,[cs:IntNumber]
    add     al,8
    cbw
    shl     ax,2
    mov     di,ax

    push    es
    sub     ax,ax
    mov     es,ax
    mov     ax,[WORD LOW  cs:OldInt]  
    mov     [es:di],ax
    mov     ax,[WORD HIGH cs:OldInt]              
    mov     [es:di+2],ax
    pop     es

    mov     cl,[cs:IntNumber]               ; (=7)
    mov     ah,1
    shl     ah,cl                   ; Shift w/zeros fill
    in      al,21h                  ; port 21h, 8259-1 int IMR
    or      al,ah
    out     21h,al                  ; port 21h, 8259-1 int comands
    popa
    popf                            ; Pop flags
    ret
ENDP UnDoREALint

;STRUC DMAInfo
;    Page    dw  ?,?,?,?
;    Length  dw  ?,?,?,?
;    Offset  dw  ?,?,?,?
;    Next    dw  4,4,0,0 ;change 1st to '2' for 2 buffers also 3rd to '6'
;    Current dw  0       ;0 to 3
;ENDS DMAInfo

PROC CalcForDMA NEAR
    pushad
    push    ds
    mov     ax,cs
    mov     ds,ax
    
    mov     [DMA.Next],4
    movzx   eax,[BufferSeg]
    movzx   edx,[BufferOffset1]      ;offset for part1
    call    MakePage
    
    cmp     cx,[buffer1size]        ;is max less than needed?
    jb      skiplengthset
    mov     cx,[buffer1size]
    jmp     nomoreb1
skiplengthset:
    mov     bx,[buffer1size]
    sub     bx,cx
    mov     [DMA.Next],2
    dec     bx
    mov     [2 + DMA.Length],bx
    mov     [2 + DMA.Offset],0
    mov     [BYTE LOW 2 + DMA.Page],ah
    inc     [BYTE LOW 2 + DMA.Page]
NoMoreb1:
    mov     [BYTE LOW DMA.Page],ah
    mov     [DMA.Offset],dx
    dec     cx
    mov     [DMA.Length],cx

    mov     [4 + DMA.Next],0
    movzx   eax,[BufferSeg]
    movzx   edx,[BufferOffset2]   ;offset for part1
    call    MakePage
    
    cmp     cx,[buffer2size]        ;is max less than needed?
    jb      skiplengthset2
    mov     cx,[buffer2size]
    jmp     nomoreb2
skiplengthset2:
    mov     bx,[buffer2size]
    sub     bx,cx
    mov     [4 + DMA.Next],6
    dec     bx

    mov     [6 + DMA.Length],bx
    mov     [6 + DMA.Offset],0
    mov     [BYTE LOW 6 + DMA.Page],ah
    inc     [BYTE LOW 6 + DMA.Page]
NoMoreb2:
    mov     [BYTE LOW 4 + DMA.Page],ah
    mov     [4 + DMA.Offset],dx
    dec     cx
    mov     [4 + DMA.Length],cx
    
    pop     ds
    popad
    sti
    ret
ENDP CalcForDMA

    ;input: eax=segment
    ;       edx=offset
    ;output: ah=page
    ;        dx=offset
    ;        cx=MAX_LENGTH
PROC MakePage NEAR 
    shl     eax,4
    add     edx,eax         ;dx = 32bit absolute address
    
    ror     edx,16
    mov     ah,dl           ;ah= page
    ror     edx,16

    mov     cx,dx
    neg     cx
    ret
ENDP MakePage
    
    ;al = selection#, ah= value
PROC SetMixer NEAR
    push    ax dx
    mov     dx,224h
    out     dx,al
    inc     dx

    jmp     $+2
    jmp     $+2

    mov     al,ah
    out     dx,al
    pop     dx ax
    ret
ENDP SetMixer

;====
;==== DAC Stuff...
;====

PROC SetUpInterrupt NEAR
    pushad
    push  ds

    mov   ax,0
    mov   ds,ax
    mov   bx,8*4                  ;interrupt 8
    mov   ax,[ds:bx]
    mov   [Word LOW  cs:OldInt],ax
    mov   ax,[ds:bx+2]
    mov   [Word HIGH cs:OldInt],ax

    mov   ax,offset TimerInt
    cmp   [cs:StereoOn],0
    je    @@NoStereo
    mov   ax,offset TimerIntStereo
    shr   [cs:HZ],1
@@NoStereo:    
    cli
    mov   [Word ds:bx],ax
    mov   [ds:bx+2],cs

    mov   al,36h
    out   43h,al                  ; timer program

    mov   eax,1193180
    movzx ebx,[cs:HZ]             ; # of ticks between interrupts
    xor   edx,edx
    div   ebx
                                  ; Clock Freq / HZ
    out   40h,al
    mov   al,ah
    out   40h,al

;    mov   al,5ch
;    out   21h,al
    sti

    pop   ds  
    popad
    ret
ENDP SetUpInterrupt
  
PROC RemoveInterrupt NEAR
    pusha
    push    ds
    
    cli
    mov ax,0
    mov ds,ax
    mov bx,8*4
    mov ax,[Word LOW  cs:OldInt]
    mov [ds:bx],ax
    mov ax,[Word HIGH cs:OldInt]
    mov [ds:bx+2],ax
    mov al,36h
    out 43h,al
    xor al,al
    out 40h,al
    out 40h,al

;    mov   al,0
;    out   21h,al
    sti
    
    pop     ds
    popa
    ret
ENDP  RemoveInterrupt

PROC TimerInt FAR
    pusha
    push    fs
    
    mov     fs,[cs:BufferSeg]
    mov     di,[cs:DacBuffOff]
    
    mov     al,[fs:di]
    mov     dx,[cs:LptAddress1]
    out     dx,al
    
    inc     [cs:DacBuffOff]
    mov     ax,[cs:DacBuffLen]
    cmp     [cs:DacBuffOff],ax
    jb      @@NotOver

;set up for next buffer
    cmp     [cs:WhichBuffer],3
    je      SetDac3
    cmp     [cs:WhichBuffer],5
    je      SetDac3

    mov     [cs:WhichBuffer],3
    mov     ax,[cs:BufferOffset2]
    mov     [cs:DacBuffOff],ax
    add     ax,[cs:Buffer2Size]
    sub     ax,2
    mov     [cs:DacBuffLen],ax
    jmp     @@NotOver

SetDac3:
    mov     [cs:WhichBuffer],4
    mov     ax,[cs:BufferOffset1]
    mov     [cs:DacBuffOff],ax
    add     ax,[cs:Buffer1Size]
    sub     ax,2
    mov     [cs:DacBuffLen],ax

@@NotOver:
    mov     al,20h      ;acknowledge hardware interrupt
    out     20h,al

    pop     fs
    popa
    iret
ENDP TimerInt

PROC TimerIntStereo FAR
    pusha
    push    fs
    
    mov     fs,[cs:BufferSeg]
    mov     di,[cs:DacBuffOff]
    
    mov     al,[fs:di]
    mov     dx,[cs:LptAddress1]
    out     dx,al
    mov     al,[fs:di + 1]
    mov     dx,[cs:LptAddress2]
    out     dx,al
    
    add     [cs:DacBuffOff],2
    mov     ax,[cs:DacBuffLen]
    cmp     [cs:DacBuffOff],ax
    jb      @@NotOver

;set up for next buffer
    cmp     [cs:WhichBuffer],3
    je      @@SetDac3
    cmp     [cs:WhichBuffer],5
    je      @@SetDac3

    mov     [cs:WhichBuffer],3
    mov     ax,[cs:BufferOffset2]
    mov     [cs:DacBuffOff],ax
    add     ax,[cs:Buffer2Size]
    sub     ax,2
    mov     [cs:DacBuffLen],ax
    jmp     @@NotOver

@@SetDac3:
    mov     [cs:WhichBuffer],4
    mov     ax,[cs:BufferOffset1]
    mov     [cs:DacBuffOff],ax
    add     ax,[cs:Buffer1Size]
    sub     ax,2
    mov     [cs:DacBuffLen],ax

@@NotOver:
    mov     al,20h      ;acknowledge hardware interrupt
    out     20h,al

    pop     fs
    popa
    iret
ENDP TimerIntStereo

    END

