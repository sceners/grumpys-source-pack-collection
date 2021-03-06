      DOSSEG
      .MODEL SMALL
      .STACK 200h
      .CODE
      .386
      ASSUME CS:@CODE, DS:@CODE
      Ideal

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

OldInt  dd  0       ;for the old DMA interrupt

BaseAddress dw  220h
IrqNumber   db  7
DMANumber   db  1

SampleSeg dw  0
SampleOff dw  0

FileName  db  "jamhot.sam",0
SamLength dw  ?

STRUC DMAInfo
    Page    dw  ?,?
    Length  dw  ?,?
    Offset  dw  ?,?
    Next    dw  0,0     ;changes 2nd one to a "2" if 2 buffers are needed
    Current dw  0       ;0 or 1
ENDS DMAInfo

DMA DMAInfo <>

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

;==================
;==- Interrupts -==
;==================

PROC DMAINT FAR
    pusha
    cli

    mov     dx,[cs:BaseAddress]
    add     dx,0eh   
    in      al,dx               ;acknowledge interrupt

    xor     [cs:DMA.Current],1
    mov     bx,[cs:DMA.Current]
    add     bx,bx
    mov     bx,[cs:bx + DMA.NEXT]
    
    mov     ax,[cs:bx + DMA.Page]
    mov     ah,al
    mov     cx,[cs:bx + DMA.Length]
    mov     dx,[cs:bx + DMA.Offset]
    call    TransferDma

    mov     al,20h
    out     20h,al              ;end of hardware interrupt

    popa
    sti
    iret
ENDP DMAINT

;======================
;==- Start Transfer -==
;======================

PROC StartTransferDma NEAR
    pusha

    mov     al,[cs:IrqNumber]
    add     al,8
    cbw
    shl     al,2
    mov     bx,ax
    push    es
    sub     ax,ax
    mov     es,ax
    mov     ax,[es:bx]
    mov     [WORD LOW  cs:OldInt],ax           ; Grab the current interrupt
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

    mov     al,14h          ;function 14h DMAmode 8-bit DAC
    call    Sendcommand
    mov     al,cl           ;send LSB of DATALENGTH
    call    SendCommand
    mov     al,ch           ;send MSB of DATALENGTH
    call    SendCommand
    
    popa
    ret
ENDP StartTransferDma

    ;ah= page number
    ;dx= BASE_ADDRESS
    ;cx= DATA_LENGTH (-1)
PROC TransferDma NEAR
    pusha
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

    mov     al,14h          ;function 14h DMAmode 8-bit DAC
    call    Sendcommand
    mov     al,cl           ;send LSB of DATALENGTH
    call    SendCommand
    mov     al,ch           ;send MSB of DATALENGTH
    call    SendCommand
    popa
    ret
ENDP TransferDMA

    ;ah= TC (Time Constant = 256 - 1,000,000/HZ)
PROC SetTimeConstant NEAR
    mov     al,40h
    call    SendCommand
    mov     al,ah
    call    SendCommand
    ret
ENDP SetTimeConstant

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
@@Sendcommandloop:
    in      al,dx
    or      al,al
    js      @@Sendcommandloop
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
    rep     lodsb   ;wait for at least 3�S
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
    cli                             ; Disable interrupts
    mov     dx,ax
    mov     al,[cs:IrqNumber]
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
    mov     cl,[cs:IrqNumber]
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
    sti
    ret
ENDP DoRealint
  
PROC UnDoREALint NEAR
    pushf
    pusha
    cli
    mov     al,[cs:IrqNumber]
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
    mov     cl,[cs:IrqNumber]               ; (=7)
    mov     ah,1
    shl     ah,cl                   ; Shift w/zeros fill
    in      al,21h                  ; port 21h, 8259-1 int IMR
    or      al,ah
    out     21h,al                  ; port 21h, 8259-1 int comands
    popa
    popf                            ; Pop flags
    sti
    ret
ENDP UnDoREALint

    ;Figgures the DMA buffer info
PROC CalcForDMA NEAR
    pushad
    push    ds

    mov     ax,cs
    mov     ds,ax
    mov     es,ax

    mov     [2 + DMA.Next],0          ;assume we do only 1 buffer
    
    movzx   eax,[SampleSeg]
    movzx   edx,[SampleOff]
    call    MakePage
    
    cmp     cx,[SamLength]          ;is max less than needed?
    jb      Skiplengthset           ;yes, must do 2 buffers

    mov     cx,[SamLength]
    mov     [2 + DMA.NEXT],2
    jmp     NoMore

Skiplengthset:
    mov     bx,[SamLength]
    sub     bx,cx
    dec     bx
    mov     [2 + DMA.Length],bx
    mov     [2 + DMA.Offset],0
    mov     [2 + DMA.Page],ax
    inc     [2 + DMA.Page]

NoMore:
    mov     [DMA.Page],ax
    mov     [DMA.Offset],dx
    dec     cx
    mov     [DMA.Length],cx

    pop     ds
    popad
    ret
ENDP CalcForDMA

    ;input: eax=segment
    ;       edx=offset
    ;output: ax=page
    ;        dx=offset
    ;        cx=MAX_LENGTH
PROC MakePage NEAR 
    shl     eax,4
    add     edx,eax         ;edx = 32bit absolute address
    
    ror     edx,16
    mov     al,dl           ;ax= page
    xor     ah,ah
    ror     edx,16

    mov     cx,dx
    neg     cx
    ret
ENDP MakePage

  ; returns -1 if load not successful
PROC  LoadSample NEAR
    pusha
    push    ds

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

    ;now fix the sam so it's playable on a SB
    push    es
    push    ds
    pop     es

    mov     si,0
    mov     di,0
    mov     cx,[cs:SamLength]
    cld
FixItLoop:
    lodsb
    add     al,128
    stosb
    loop    FixItLoop

    pop     es
    pop     ds
    popa
    xor     ax,ax
    ret

@@Error:
    pop     ds
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
    call  CalcForDMA
    call  DspReset

    mov   ah, 256- 1000000/8000  ; 256- 1000000/ HZ
    call  SetTimeConstant

    call  TurnOnSpeaker
    call  StartTransferDMA
    
    mov   ah,0
    int   16h               ;wait for a keypress
    
    call  HaltDMA
    call  UnDoRealInt
    call  TurnOffSpeaker
    call  DSPReset
    
    mov   ax,4c00h
    int   21h

END START
