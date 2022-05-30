; ------------------------------ GLOBE.ASM ------------------------------
; Bye Jare of VangeliSTeam. Want more comments? Write'em. O:-)
; -----------------------------------------------------------------------
;   Slightly inspired (that is, absolutely copied) from the Globe ST demo
; by Axel of XXX International (coded back in September 16th in 1989).
; -----------------------------------------------------------------------
;   Do anything you want with this source, but NEVER say it's yours. That
; would be a lie, so there you are. If you use it please DO credit me. If
; you write another version DO credit Axel. If  you like it, write to us;
; it would be nice to know.
; -----------------------------------------------------------------------

; ----- Configuration of the execution. ---------
TRACE   = 0
FILECFG = 0

 ; ------- Values that control the appearance of the intro. -------

MAXDIAM = 198
ANGLEDIVISOR = 6
ANGLEINC = 1 SHL (ANGLEDIVISOR - 3)

MULTPTS = 8
NUMPTS  = MULTPTS*32

FRAMESPERCFG = 70*5

 ; --- This is the best profiler ever written, if you know what I mean. ---

SetBorder MACRO r,g,b
  IF TRACE
        MOV     DX,3C8h
        XOR     AL,AL
        OUT     DX,AL
        INC     DX
      IFDIF <&r>,<0>
        MOV     AL,&r
      ENDIF
        OUT     DX,AL
      IFDIF <&g>,<&r>
        MOV     AL,&g
      ENDIF
        OUT     DX,AL
      IFDIF <&b>,<&g>
        MOV     AL,&b
      ENDIF
        OUT     DX,AL
  ENDIF
ENDM

        .MODEL SMALL
        .STACK 400
        DOSSEG
        LOCALS

        .DATA

; ------------ Cosinus table, and Sin() and Cos() neat macros. ----------

CosTbl LABEL WORD
        INCLUDE COSTBL.INC

Cos MACRO dest
        SHR     BX,ANGLEDIVISOR
        AND     BH,3
        ADD     BX,BX
        MOV     &dest,[CosTbl+BX]
ENDM

Sin MACRO dest
        ADD     BH,(1 SHL ANGLEDIVISOR)
        Cos     &dest
ENDM

 ; ---------------- These values define completely a configuration. ----
        UDATASEG

ActualConfiguration LABEL BYTE
Phi     DW ?
Alp     DW ?
Rho     DW ?

IncPhi  DW ?
IncAlp  DW ?
IncRho  DW ?

GapPhi  DW ?
GapAlp  DW ?

SizeH   DW ?
SizeV   DW ?
CONFIGSIZE = $-OFFSET ActualConfiguration


Preset  DW ?            ; Actual Preset configuration.

; --------------- Predefined configurations. --------------

        .DATA

PresetConfigs LABEL BYTE            
        INCLUDE GLOBECFG.INC
SIZEPRESETS = $-OFFSET PresetConfigs

 ; ----------------- These other have to be this way at the beginning. ----

thisColor DB 15
oldColor  DB 14

drawn     DB 0

State     DW 0                  ; 0-> Abriendo, ... hasta FRAMESPERCFG
ChngDiameter DW 0               ; Diametro de apertura o cierre.

 ; ---------- Nifty nonVGA msg. Perhaps nobody I will ever see it. ----

VgaMsg  DB '   Ooohhhhh.... I''m sorry, you need at least a VGA card to run GLOBE.', 13, 10
        DB 'Go buy one, GLOBE is worth the ca$h. ;-)', 13, 10, 10

 ; ------------------  And the greetings!!! -------------------

ByeMsg LABEL BYTE
        INCLUDE GLOBEGRT.INC
ByeMsgLng = $-OFFSET ByeMsg

IF FILECFG               ; ----------- Data file related vars.
CfgFN   DB 'globe.dat', 0
FileError DB 'File error.', 13, 10, '$'
        UDATASEG
CfgHandle DW ?
ENDIF
        UDATASEG

  ; ---- The moving point. ---------------
_phi      DW ?
_alp      DW ?

  ; ---- Buffers for screen offsets. We have to erase the points, eh?
BufPos1   DW NUMPTS DUP (?)
BufPos2   DW NUMPTS DUP (?)

  ; ---- Diameters for performing the opening or closing.
ChngDH    DW ?
ChngDV    DW ?

        .DATA

OldPos    DW OFFSET BufPos1
NewPos    DW OFFSET BufPos2

;=======================================================================
;=======================================================================

        .CODE
        .STARTUP
                                                   ; VGA card detection
        XOR     BX,BX
        MOV     AX,01A00h
        INT     10h
        CMP     BL,7
        JC      @@novga
        CMP     BL,0Dh
        JC      SetupFile
    @@novga:
        MOV     DX,OFFSET VgaMsg
ErrorExit:
        MOV     AH,9
        INT     21h
        MOV     AX,4C01h
        INT     21h

SetupFile:
IF FILECFG
        MOV     DX,OFFSET CfgFN
        MOV     AX,3d01h                ; Open file for writing.
        INT     21h
        JC      @@creat
        MOV     [CfgHandle],AX
        MOV     BX,AX
        XOR     DX,DX
        XOR     CX,CX
        MOV     AX,4202h                ; Go EOF.
        INT     21h
        JMP     SetupVideo
    @@creat:
        MOV     AH,5Bh
        XOR     CX,CX
        MOV     DX,OFFSET CfgFN
        INT     21h
        JNC     @@ok
        MOV     DX,OFFSET FileError
        JMP     ErrorExit
    @@ok:
        MOV     [CfgHandle],AX
ENDIF
SetupVideo:
        CLD
        MOV     AX,13h
        INT     10h

        MOV     DX,3C8h
        MOV     AL,14
        OUT     DX,AL
        MOV     AL,0FFh
        INC     DX
        OUT     DX,AL                   ; Palette DAC 14 & 15 == White.
        OUT     DX,AL
        OUT     DX,AL
        OUT     DX,AL
        OUT     DX,AL
        OUT     DX,AL

   IF TRACE
        MOV     AX,0A000h
        MOV     ES,AX
        MOV     DI,0
        MOV     AL,8
        MOV     CX,200/8
     @@lp:
         STOSB
         ADD    DI,320*8-1
         LOOP   @@lp
   ENDIF
        XOR     SI,SI                   ; Initialize config.
        CALL    SetPreset
        MOV     AX,[SizeH]
        MOV     [ChngDH],AX
        MOV     AX,[SizeV]
        MOV     [ChngDV],AX
        JMP     MainLoopEntry
MainLoop:                    
        SetBorder 0,0,0      
        MOV     DX,3DAh                 ; Retrace sync.
@@vs1:
        IN      AL,DX
        TEST    AL,8
        JNZ      @@vs1
@@vs2:
        IN      AL,DX
        TEST    AL,8
        JZ     @@vs2

        SetBorder 63,0,63

        MOV     AL,[drawn]
        OR      AL,AL
        JZ      @@nodrawn
         CALL   DumpGlobe
         JMP    @@c2
    @@nodrawn:
         CALL    DumpGlobeNoErase
    @@c2:
        MOV     [drawn],1
        MOV     AX,[WORD PTR thisColor]
        XCHG    AL,AH
        MOV     [WORD PTR thisColor],AX
        MOV     AX,[OldPos]
        MOV     DX,[NewPos]
        MOV     [OldPos],DX
        MOV     [NewPos],AX

        SetBorder 0,0,63
MainLoopEntry:
        MOV     AX,[State]
        CMP     AX,0FFFFh
        JZ      ReadyToCalculate
         CALL   DoSequence

ReadyToCalculate:
        CALL    CalculateGlobe
        MOV     AX,[IncAlp]
        ADD     [Alp],AX
        MOV     AX,[IncPhi]
        ADD     [Phi],AX
        MOV     AX,[IncRho]
        ADD     [Rho],AX

        MOV     AH,1
        INT     16h
        JZ      @@cont
        MOV     AX,0FFFFh               
        CMP     [State],AX
        JZ      @@dokb
         MOV     [State],AX             ; Switch to interactive mode.
         MOV     AX,[ChngDH]            ; Restore full diameters.
         MOV     [SizeH],AX
         MOV     AX,[ChngDV]
         MOV     [SizeV],AX
    @@dokb:
        CALL    ControlKeyboard
        JZ      Exit
    @@cont:
        JMP     MainLoop
Exit:
        MOV     AX,3
        INT     10h
        XOR     BH,BH
        MOV     DX,1700h
        MOV     AH,2
        INT     10h
        MOV     AX,0B800h
        MOV     ES,AX
        MOV     SI,OFFSET ByeMsg
        XOR     DI,DI
        MOV     CX,ByeMsgLng/2
        REP     MOVSW

        MOV     AX,4C00h
        INT     21h

;=======================================================================
;=======================================================================

DoSequence:
        OR      AX,AX
        JZ      @@open
        CMP     AX,FRAMESPERCFG
        JZ      @@close
        INC     AX                      ; Showing the current figure.
        MOV     [State],AX
        RET
  @@open:
        MOV     AX,[ChngDiameter]
        INC     AX
        CMP     AX,MAXDIAM
        JNZ     @@sequence
         INC    [State]
         JMP    @@doneseq
  @@close:
        MOV     AX,[ChngDiameter]
        DEC     AX
        JNZ     @@sequence
         MOV    [State],AX
         CALL   IncreasePreset
         CALL    @@doneseq
         XOR    AX,AX
  @@sequence:
        MOV     [ChngDiameter],AX
        MOV     DX,[ChngDH]
        MUL     DX
        MOV     CX,MAXDIAM
        DIV     CX
        MOV     [SizeH],AX
        MOV     AX,[ChngDiameter]
        MOV     DX,[ChngDV]
        MUL     DX
        MOV     CX,MAXDIAM
        DIV     CX
        MOV     [SizeV],AX
        RET
  @@doneseq:
        MOV     AX,[SizeH]
        MOV     [ChngDH],AX
        MOV     AX,[SizeV]
        MOV     [ChngDV],AX
        RET

; -----------------------------------

CalculateGlobe:
        MOV     AX,DS
        MOV     ES,AX
        MOV     AX,[Alp]
        MOV     [_alp],AX
        MOV     AX,[Phi]
        MOV     [_phi],AX
        MOV     BP,NUMPTS
        MOV     DI,[NewPos]
    @@lp:
        MOV     BX,[_alp]
        Cos DX
        MOV     BX,[_phi]
        Cos AX
        IMUL    DX
        ADD     DX,DX
        MOV     AX,[SizeH]
        IMUL    DX
        ADD     DX,160
        PUSH    DX                      ; Graba el valor del ancho.

        MOV     BX,[_phi]
        Sin DX
        MOV     BX,[Rho]
        Cos AX
        IMUL    DX
        ADD     DX,DX
        MOV     AX,[SizeV]
        IMUL    DX
        PUSH    DX                      ; Valor1 del alto.

        MOV     BX,[_alp]               ; Now for the 'Rhotated' Y value.
        Sin DX
        MOV     BX,[_phi]
        Cos AX
        IMUL    DX
        ADD     DX,DX
        MOV     BX,[Rho]
        Sin AX
        IMUL    DX
        ADD     DX,DX
        MOV     AX,[SizeH]
        IMUL    DX
        POP     AX
        ADD     DX,101
        ADD     DX,AX                   ; DX == Ypos
        MOV     AX,320
        MUL     DX
        POP     CX                      ; Retrieve saved X.
        ADD     AX,CX                   ; AX = dest. offset.
        STOSW
        MOV     AX,[GapAlp]
        ADD     [_alp],AX
        MOV     AX,[GapPhi]
        ADD     [_phi],AX
        DEC     BP
        JZ      @@ret
        JMP     @@lp
    @@ret:
        RET

; -----------------------------------

DumpGlobe:
        MOV     BP,NUMPTS/MULTPTS
        MOV     SI,[NewPos]
        MOV     BX,[OldPos]
        MOV     AX,0A000h
        MOV     ES,AX
        XOR     CL,CL
        MOV     DX,2
        MOV     AX,[WORD PTR thisColor]
    @@lp:
        REPT MULTPTS
            LOCAL @@c1
            MOV     DI,[BX]
            CMP     AH,ES:[DI]
            JNZ     @@c1
             MOV    ES:[DI],CL
        @@c1:
            MOV     DI,[SI]
            MOV     ES:[DI],AL
            ADD     SI,DX
            ADD     BX,DX
        ENDM
        DEC     BP
        JZ      @@ret
        JMP     @@lp
    @@ret:
        RET

; -----------------------------------

DumpGlobeNoErase:
        MOV     BP,NUMPTS/MULTPTS
        MOV     SI,[NewPos]
        MOV     AX,0A000h
        MOV     ES,AX
        MOV     DX,2
        MOV     AL,[thisColor]
    @@lp:
        REPT MULTPTS
            MOV     DI,[SI]
            MOV     ES:[DI],AL
            ADD     SI,DX
        ENDM
        DEC     BP
        JNZ     @@lp
        RET

; -----------------------------------

CHKKEY MACRO val,var,inc
        LOCAL @@nothis
        CMP     AH,&val
        JNZ     @@nothis
        ADD     [&var],&inc
        JMP     @@nofunc
    @@nothis:
ENDM

CHKDIAM MACRO val,var,inc
        LOCAL @@nothis
        CMP     AH,&val
        JNZ     @@nothis
        IF &inc LE 0
            CMP     [&var], 0
            JLE     @@nofunc
        ELSE
            CMP     [&var],MAXDIAM
            JGE     @@nofunc
        ENDIF
        ADD     [&var],&inc
        JMP     @@nofunc
    @@nothis:
ENDM

ControlKeyboard:
        XOR     AH,AH
        INT     16h
        OR      AL,AL
        JZ      @@func
        CMP     AL,27                   ; ESC pressed? Return Z.
        JZ      @@ret
        CMP     AL,'-'
        JNZ     @@nomin
        CALL    SaveActual
        CALL    DecreasePreset
        JMP     @@retnoesc
    @@nomin:
        CMP     AL,'+'
        JNZ     @@noadd
        CALL    SaveActual
        CALL    IncreasePreset
        JMP     @@retnoesc
    @@noadd:
        CMP     AL,8
        JNZ     @@nobs
        XOR     AX,AX
        MOV     [Phi],AX
        MOV     [Alp],AX
        MOV     [Rho],AX
        MOV     [IncPhi],AX
        MOV     [IncAlp],AX
        MOV     [IncRho],AX
        MOV     [GapPhi],AX
        MOV     [GapAlp],AX
        MOV     AX,MAXDIAM
        MOV     [SizeH],AX
        MOV     [SizeV],AX
        JMP     @@retnoesc
    @@nobs:
IF FILECFG
        CMP     AL,' '
        JNZ     @@nospc
        CALL    SaveConfiguration
    @@nospc:
ENDIF
    @@retnoesc:
        XOR     AL,AL                   ; Return NZ.
        INC     AL
    @@ret:
        RET
    @@func:
        CHKKEY  59,IncPhi,ANGLEINC
        CHKKEY  60,IncPhi,-ANGLEINC
        CHKKEY  61,IncAlp,ANGLEINC
        CHKKEY  62,IncAlp,-ANGLEINC
        CHKKEY  63,GapPhi,ANGLEINC
        CHKKEY  64,GapPhi,-ANGLEINC
        CHKKEY  65,GapAlp,ANGLEINC
        CHKKEY  66,GapAlp,-ANGLEINC
        CHKKEY  67,IncRho,ANGLEINC
        CHKKEY  68,IncRho,-ANGLEINC

        CHKDIAM 77,SizeH,2
        CHKDIAM 75,SizeH,-2
        CHKDIAM 72,SizeV,2
        CHKDIAM 80,SizeV,-2
   @@nofunc:
        INC     AL                      ; Return NZ
        RET

; ----------------------------
; Various Configuration handling routines interconnected. I love ASM! :_)

SaveActual:
        MOV     DI,[Preset]
        ADD     DI,OFFSET PresetConfigs
        MOV     SI,OFFSET ActualConfiguration
        JMP     DoCfgCopy

DecreasePreset:
        MOV     SI,[Preset]
        SUB     SI,CONFIGSIZE
        JNC     SetPreset
        ADD     SI,SIZEPRESETS
        JMP     SetPreset
IncreasePreset:
        MOV     SI,[Preset]
        ADD     SI,CONFIGSIZE
        CMP     SI,SIZEPRESETS
        JC      SetPreset
        SUB     SI,SIZEPRESETS
SetPreset:
        MOV     [Preset],SI
        ADD     SI,OFFSET PresetConfigs
        MOV     DI,OFFSET ActualConfiguration
DoCfgCopy:
        MOV     CX,CONFIGSIZE
        MOV     AX,DS
        MOV     ES,AX
        REP MOVSB
        RET

; -----------------------------------------
IF FILECFG
SaveConfiguration:
        MOV     DX,OFFSET ActualConfiguration
SaveDXCfg:
        MOV     BX,[CfgHandle]
        MOV     CX,CONFIGSIZE
        MOV     AH,40h
        INT     21h
        JNC     @@ret
        CMP     AX,CONFIGSIZE
        JNZ     @@err
    @@ret:
        RET
    @@err:
        MOV     DX,OFFSET FileError
        JMP     ErrorExit
ENDIF
        END
; ------------------------------ End of GLOBE.ASM ---------------------------

