    IDEAL
    DOSSEG
    MODEL SMALL
    STACK 200h
    CODESEG
    p386n
    ASSUME  CS:@CODE, DS:@CODE
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�    
    INCLUDE "PRINTSUB.inc"
    INCLUDE "MCLSUB.INC"
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STRUC VCH_Header
    Id      db  "VLACH"
    From    db  ?
    X       db  ?
    Y       db  ?
    NumChr  db  ?
ENDS

STRUC FNT_Header
    Id          db  "VLAFNT"
    X           db  1           ;widths in BYTES (8 pixels)
    Y           db  8
    NumChr      db  ?
    StartChr    db  " "         ;char to start with
ENDS
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FileName_VCH    db  130 dup (0)
Extension_VCH   db  ".VCH",0
Handle_VCH      dw  ?

FileName_FNT    db  130 dup (0)
Extension_Fnt   db  ".FNT",0
Handle_FNT      dw  ?

Dsp_Seg         dw  ?
VCH_Seg         dw  ?
FNT_Seg         dw  ?

Credits         db  "VCH to FNT converter written by Draeden of VLA!"
                db  13,10,10,0

MSG_OpenError   db  "Error loading VCH file.",13,10,0
MSG_OverWrite   db  "FNT file already exists, replace? (Y/N)",13,10,0
MSG_CreateError db  "Failed to create FNT file.",13,10,0
MSG_WriteError  db  "Failed to write the FNT file!?",13,10,0
MSG_Written     db  " was successfully written.",0

VCHHead         VCH_Header <>
FNTHead         FNT_Header <>
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ;This routine opens the VCH file
    ;Returns    CF = 0 = Success! VCH file opened
    ;           CF = 1 = Failed to open file
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC Open_VCH NEAR
    pusha
    push    ds

    mov     ax,cs
    mov     ds,ax
    mov     dx,offset FileName_VCH
    mov     ax,3d00h                ;open file
    int     21h
    jc      @@END
    mov     [Handle_VCH],ax
    clc

@@END:
    pop     ds
    popa
    ret
ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ;This routine creates (safely) the FNT file
    ;Returns    CF = 0 = Success! was able to create file
    ;           CF = 1 = Failed!  could not create FNT file
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC Create_FNT NEAR
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax

    mov     dx,offset FileName_FNT
    mov     ax,5b00h                ;create file (safe)
    xor     cx,cx
    int     21h
    jc      @@FileError1
    mov     [Handle_FNT],ax
    clc                         ;No error occured
    jmp     @@End

@@FileError1:
    mov     si,offset MSG_Overwrite
    call    PrintZ
    call    YesNo
    jnc     @@Abort

    mov     dx,offset FileName_FNT
    mov     ax,3c00h                ;create file (unsafe)
    xor     cx,cx
    int     21h
    jc      @@Abort
    mov     [Handle_FNT],ax
    clc                         ;No error occured
    jmp     @@End

@@Abort:
    stc
@@END:
    pop     ds
    popa
    ret
ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ;Closes VCH file... nothing can go wrong that we care about...
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC Close_VCH NEAR
    push    ax bx

    mov     bx,[cs:HANDLE_VCH]
    mov     ah,3eh
    int     21h

    pop     bx ax     
    ret
ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ;Closes FNT file... nothing can go wrong that we care about...
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC Close_FNT NEAR
    push    ax bx

    mov     bx,[cs:HANDLE_FNT]
    mov     ah,3eh
    int     21h

    pop     bx ax     
    ret
ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ; Converts the VCH to FNT
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC Convert_VCH2FNT NEAR
    pusha
    push    ds es
    mov     ax,cs
    mov     ds,ax

    mov     al,[VCHhead.NumChr]
    mov     [FNThead.NumChr],al
    mov     al,[VCHhead.From]
    mov     [FNThead.StartChr],al
    mov     [FNThead.X],1           ;that's 8 pixels wide
    mov     al,[VCHhead.Y]
    mov     [FNThead.Y],al

    xor     si,si
    mov     di,si
    mov     es,[FNT_Seg]
    mov     ds,[VCH_Seg]

    mov     ch,[cs:FNThead.NumChr]
    mov     cl,[cs:FNThead.Y]
    xor     ah,ah
    mov     dl,8
@@CLoop:
    shl     ah,1
    lodsb
    or      al,al
    je      @@Tis0
    or      ah,1
@@Tis0:

    dec     dl
    jne     @@Cloop
    mov     dl,8
    mov     al,ah
    stosb
    xor     ah,ah

    dec     cl
    jne     @@CLoop

    mov     cl,[cs:FNThead.Y]
    dec     ch
    jne     @@Cloop
    
    pop     es ds
    popa
    ret
ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ; Writes the FNT header and all the FNT data
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC Write_FNT NEAR
    pusha
    push    ds

    mov     ax,cs
    mov     ds,ax
    
    mov     bx,[HANDLE_FNT]             ;save FNT header
    mov     cx,(size FNT_HEADER)
    mov     ah,40h
    mov     dx,offset FNThead
    int     21h
    jc      @@FileError

    mov     al,[cs:FNTHead.NumChr]
    mov     ah,[cs:FNTHead.Y]
    mul     ah
    movzx   cx,[cs:FNTHead.X]
    mul     cx
    mov     cx,ax
    mov     ds,[cs:FNT_Seg]
    mov     dx,dx                       ;save off FNT data
    mov     ah,40h
    int     21h
    clc

@@FileError:
    pop     ds
    popa
    ret
ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ; Reads in the VCH header and all the character data
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC Read_VCH NEAR
    pusha
    push    ds
    mov     ax,cs
    mov     ds,ax
    mov     bx,[Handle_VCH]
    mov     cx,(size VCH_Header)
    mov     dx,offset VCHhead
    mov     ah,3fh
    int     21h

    mov     ds,[VCH_seg]
    mov     al,[cs:VCHHead.NumChr]
    mov     ah,[cs:VCHHead.X]
    cmp     ah,8
    jne     @@Fail

    mul     ah
    movzx   cx,[cs:VCHHead.Y]
    mul     cx
    xor     dx,dx
    mov     cx,ax
    mov     ah,3fh
    int     21h             ;read in all of the stuff
    clc
    jmp     short @@Done

@@Fail:
    stc
@@Done:
    pop     ds
    popa
    ret
ENDP
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Start:
    mov     ax,cs
    mov     ds,ax
    mov     [Dsp_Seg],es

    mov     bx,ss
    mov     ax,sp
    add     ax,15
    shr     ax,4
    add     bx,ax
    mov     [VCH_Seg],bx
    add     bx,1000h
    mov     [FNT_Seg],bx

    mov     es,[Dsp_Seg]
    mov     dx,offset FileName_VCH
    mov     bx,offset Extension_VCH
    mov     bp,1                        ;override extension
    call    GetCommandLine
    mov     dx,offset FileName_FNT
    mov     bx,offset Extension_FNT
    call    GetCommandLine

    call    Open_VCH
    jnc     @@NoFileError
    
    mov     si,offset MSG_OpenError
    call    PrintZ
    mov     al,1
    jmp     ExitProg

@@NoFileError:
    call    Create_FNT
    jnc     @@NoCreateError
    call    Close_VCH
    mov     si,offset MSG_CreateError
    call    PrintZ
    mov     al,2
    jmp     ExitProg

@@NoCreateError:
    call    Read_VCH
    call    Convert_VCH2FNT
    call    Write_FNT
    call    Close_FNT
    call    Close_VCH

    mov     si,offset FileName_FNT
    call    PrintZ
    mov     si,offset MSG_Written
    call    PrintZ
    xor     al,al

ExitProg:
    mov     ah,4ch
    int     21h
END START

