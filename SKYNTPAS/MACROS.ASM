; ** Integers are in the 2's complement format - what is used by ASM **


Multiply        MACRO

; This macro will multiply two integers (signed) and shift the result
; right 15 times
;
; Input:   AX = integer
;          DX = integer
; Output:  AX = AX x BX SHR 15
;
; Modifies AX,DX,CF

        IMUL    DX                      ; Call integer multiply
        RCL     AX,1                    ; Transfer MSB of AX ...
        RCL     DX,1                    ;                ... to LSB of DX
        MOV     AX,DX                   ; Move it back to AX as output

                ENDM



Sine            MACRO

; This macro will give the sine of a number * 32768 found in the SinTable
;
; Input:   AX = AX/360
; Output:  AX = Sin(AX) * 32768
;
; Modifies AX,BX

        SHL     AX,1
        MOV     SI,AX
        MOV     AX,WORD PTR SineTable[SI]

                ENDM



Cosine          MACRO

; This macro will give the cosine of a number * 32768 found in the SinTable
;
; Input:   AX = AX/360
; Output:  AX = Cos(AX) * 32768
;
; Modifies AX

        SHL     AX,1
        MOV     SI,AX
        MOV     AX,WORD PTR SineTable[SI+180]   ; Accounts for 90 deg shift

                ENDM


SetColor        MACRO   Color,Red,Green,Blue

        MOV     AL,Color
        MOV     DX,03C8h
        OUT     DX,AL
        INC     DX
        MOV     AL,Red
        OUT     DX,AL
        MOV     AL,Green
        OUT     DX,AL
        MOV     AL,Blue
        OUT     DX,AL

                ENDM

SetWriteMode    MACRO   Mode

        MOV     DX,03CEh
        MOV     AX,((40h OR Mode) SHL 8) OR 5
        OUT     DX,AX

                ENDM


SetDataRotate   MACRO   Func

        MOV     DX,03CEh
        MOV     AX,((Func SHL 3) SHL 8) OR 3
        OUT     DX,AX

                ENDM

