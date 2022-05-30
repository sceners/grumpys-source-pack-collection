;|----------------------------------------------------------------------------|
;|      written 1993 by Alexander Lenhardt (Centauri of Legend Design)        |
;|      All rights reserved                                                   |
;|      Inspired by VTIRIS from VangeliSTeam                                  |
;|      USE (c) is a Trademark of AWL - Trade and Development                 |
;|                                                                            |
;|----------------------------------------------------------------------------|
;******************************************************************************
;ASSEMBLER COMMANDS
;******************************************************************************
;------------------------------------------------------------------------------
                MODEL SMALL
                .STACK 300H
                .386
;------------------------------------------------------------------------------
;******************************************************************************
;STRUCTURES
;******************************************************************************
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;******************************************************************************
;EQUALS
;******************************************************************************
;------------------------------------------------------------------------------
 IMAGE_DELAY    EQU 200           ;cyclces until face appears or disappears
 LIFT_DELAY     EQU 3             ;delay cycles between every "face lift"
 LOGO_X         EQU 0             ;start x position for legend logo plasma
 LOGO_Y         EQU 65            ;start y position for legend logo plasma
 LOGO_LENGTH    EQU 80            ;logo length in pixel
 LOGO_HEIGTH    EQU 15            ;logo height in pixel
 P_WIDTH        EQU 60            ;plasma width after pop up
 P_HEIGTH       EQU 50            ;plasma height after pop up
;------------------------------------------------------------------------------
;==============================================================================
 .DATA
;==============================================================================
;******************************************************************************
;PREDEFINED LOCAL VARIABLES AND AREAS
;******************************************************************************
;------------------------------------------------------------------------------
 COSTABLE       DB 64,64,64,64,64,64,64,64,63,63,63,63
                DB 63,62,62,62,62,61,61,61,60,60,59,59
                DB 59,58,58,57,57,56,56,55,55,54,53,53
                DB 52,52,51,50,50,49,48,48,47,46,46,45
                DB 44,44,43,42,41,41,40,39,38,37,37,36
                DB 35,34,34,33,32,31,30,30,29,28,27,27
                DB 26,25,24,23,23,22,21,20,20,19,18,18
                DB 17,16,16,15,14,14,13,12,12,11,11,10
                DB  9, 9, 8, 8, 7, 7, 6, 6, 5, 5, 5, 4
                DB  4, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1
                DB  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                DB  0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2
                DB  2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 7
                DB  7, 8, 8, 9, 9,10,11,11,12,12,13,14
                DB 14,15,16,16,17,18,18,19,20,20,21,22
                DB 23,23,24,25,26,27,27,28,29,30,30,31
                DB 32,33,34,34,35,36,37,37,38,39,40,41
                DB 41,42,43,44,44,45,46,46,47,48,48,49
                DB 50,50,51,52,52,53,53,54,55,55,56,56
                DB 57,57,58,58,59,59,59,60,60,61,61,61
                DB 62,62,62,62,63,63,63,63,63,64,64,64
                DB 64,64,64,64
                                  ;cosinus table for creating plasma
                                  ;movings
;------------------------------------------------------------------------------
 COSTABLE_COLOR DB 03FH,03FH,03FH,03FH,03FH,03FH,03FH,03FH
                DB 03EH,03EH,03EH,03EH,03EH,03DH,03DH,03DH
                DB 03DH,03CH,03CH,03CH,03BH,03BH,03BH,03AH
                DB 03AH,039H,039H,038H,038H,037H,037H,036H
                DB 036H,035H,035H,034H,033H,033H,032H,032H
                DB 031H,030H,030H,02FH,02EH,02EH,02DH,02CH
                DB 02CH,02BH,02AH,029H,029H,028H,027H,026H
                DB 026H,025H,024H,023H,023H,022H,021H,020H
                DB 020H,01FH,01EH,01DH,01CH,01CH,01BH,01AH
                DB 019H,019H,018H,017H,016H,016H,015H,014H
                DB 013H,013H,012H,011H,011H,010H,00FH,00FH
                DB 00EH,00DH,00DH,00CH,00CH,00BH,00AH,00AH
                DB 009H,009H,008H,008H,007H,007H,006H,006H
                DB 005H,005H,004H,004H,004H,003H,003H,003H
                DB 002H,002H,002H,002H,001H,001H,001H,001H
                DB 001H,000H,000H,000H,000H,000H,000H,000H
                DB 000H,000H,000H,000H,000H,000H,000H,000H
                DB 001H,001H,001H,001H,001H,002H,002H,002H
                DB 002H,003H,003H,003H,004H,004H,004H,005H
                DB 005H,006H,006H,007H,007H,008H,008H,009H
                DB 009H,00AH,00AH,00BH,00CH,00CH,00DH,00DH
                DB 00EH,00FH,00FH,010H,011H,011H,012H,013H
                DB 013H,014H,015H,016H,016H,017H,018H,019H
                DB 019H,01AH,01BH,01CH,01CH,01DH,01EH,01FH
                DB 020H,020H,021H,022H,023H,023H,024H,025H
                DB 026H,026H,027H,028H,029H,029H,02AH,02BH
                DB 02CH,02CH,02DH,02EH,02EH,02FH,030H,030H
                DB 031H,032H,032H,033H,033H,034H,035H,035H
                DB 036H,036H,037H,037H,038H,038H,039H,039H
                DB 03AH,03AH,03BH,03BH,03BH,03CH,03CH,03CH
                DB 03DH,03DH,03DH,03DH,03EH,03EH,03EH,03EH
                DB 03EH,03FH,03FH,03FH,03FH,03FH,03FH,03FH
                                  ;cosinus table for creating plasma
                                  ;color cyclings
;------------------------------------------------------------------------------
 PALETTE        DB 0,0,0          ;first color black
                I=0               ;create
                REPT 64           ;a black faded
                DB I/2,I/2,I/2    ;white
                I=I+1             ;palette
                ENDM              ;using asm macros
                DB 26,32,32       ;middle color a little bit cyan
                I=1               ;than create a palette part
                REPT 63           ;white faded
                DB 32-I/2,32-I/2,32-I/2
                                  ;to black
                I=I+1             ;using
                ENDM              ;asm macros too
;------------------------------------------------------------------------------
 PLASMA_POS     DW 68+57*80       ;the plasma position at the beginning
 PLASMA_WIDTH   DB 1              ;the start plasma width
 PLASMA_HEIGTH  DB 1              ;the start plasma height
 COSPOSC1       DB ?              ;phase offset for red cosinus wave
 COSPOSC2       DB ?              ;phase offset for green cosinus wave
 COSPOSC3       DB ?              ;phase offset for blue cosinus wave
 COSPOSX1       DB ?              ;phase offset for first horizontal wave
 COSPOSX2       DB ?              ;phase offset for second horizontal wave
 COSPOSY1       DB ?              ;phase offset for first vertical wave
 COSPOSY2       DB ?              ;phase offset for second vertical wave
 RUN_X1_POS     DW ?              ;current position in 1. hor. cos. wave
 RUN_X2_POS     DW ?              ;current position in 2. hor. cos. wave
 RUN_Y1_POS     DW ?              ;current position in 1. vert. cos. wave
 RUN_Y2_POS     DW ?              ;current position in 2. vert. cos. wave
 IMAGE_LIFT     DB 0              ;current image value multiplier
 COUNTER        DW LIFT_DELAY     ;counter for delay between two lifts
 COUNTER2       DW IMAGE_DELAY    ;counter for delay between up and down lifts
 LINE_DOUBLE    DB 4              ;adding value for maximum raster line reg.
 PLASMA_PICTURE DW OFFSET PLASMA_IMAGE
                                  ;offset for the plasma face
 HORIZ_ADD_1    DW 300H           ;speed to go thru 1. hor. cos. wave (real)
 HORIZ_ADD_2    DW 200H           ;speed to go thru 2. hor. cos. wave (real)
 VERTI_ADD_1    DW 300H           ;speed to go thru 1. vert. cos. wave (real)
 VERTI_ADD_2    DW 100H           ;speed to go thru 2. vert. cos. wave (real)
 COS_RUNXADD1   DB 0              ;current pos. in 1. hor. speed cos. wave
 COS_RUNXADD2   DB 0              ;current pos. in 2. hor. speed cos. wave
 COS_RUNYADD1   DB 0              ;current pos. in 1. vert. speed cos. wave
 COS_RUNYADD2   DB 0              ;current pos. in 2. vert. speed cos. wave
 RCOS_POS       DW 0              ;current pos. in red cosinus wave
 GCOS_POS       DW 0              ;current pos. in green cosinus wave
 BCOS_POS       DW 0              ;current pos. in blue cosuins wave
 UPDOWN_FLAG    DB 255            ;flag if plasma face has to faded up or down
 GOTO_BW_FLAG   DB 0              ;flag if color have to be faded to black&w
 R_FASTNES      DW 400H           ;speed to go thru red cosinus wave (real)
 G_FASTNES      DW 200H           ;speed to go thru green cosinus wave (real)
 B_FASTNES      DW 300H           ;speed to go thru blue cosinus wave (real)
 HOME_FLAG      DB 0              ;flag if this part has to be finished
 BW_DONE_FLG    DB 0              ;flag if the bw-move was successful
 FADE_DONE_FLG  DB 0              ;flag if the rgb speed set was successful
 LOUDNES        DW 04040H         ;the start master volume for left and right
 SONG_NAME      DB "FANTA.MOD",0  ;the name of the mod to play
;------------------------------------------------------------------------------
 PLASMA_IMAGE   DB "{MARKER}PLASFACE.BIN"
                                  ;free space to
                DB 2980 DUP (0)   ;link in the plasma picture
;------------------------------------------------------------------------------
 LOGO_PICTURE   DB "{MARKER}80X15   .BIN"
                                  ;free space to link in
                DB 1180 DUP (0)   ;the legend design logo
;------------------------------------------------------------------------------
 COLOR_CONVERT  LABEL BYTE        ;create
                I=0               ;a table
                REPT 128          ;to supress
                DB 128+I          ;bad lookin'
                I=I+1             ;wrap around
                ENDM              ;effects
                I=0               ;'coz the plasma routine
                REPT 128          ;creates values from 0 to 255
                DB 255-I          ;while only 128 colors are
                I=I+1             ;hold free for the plasma
                ENDM
;------------------------------------------------------------------------------
;==============================================================================
 .CODE
;==============================================================================
;******************************************************************************
;HELPMACROS
;******************************************************************************
;------------------------------------------------------------------------------
;Explanation:waits for the vertical display retrace
;Inputs :none
;Outputs:none
;Registers destroyed:AX,DX
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 WAIT_VSYNC     MACRO
                LOCAL @@VS1,@@VS2
                MOV DX,3DAH       ;load DX with vga status port
 @@VS1:
                IN AL,DX          ;load AL with value from this port
                TEST AL,8         ;is there still a retrace ?
                JZ @@VS1          ;yes,then loop until this retrace ends
 @@VS2:
                IN AL,DX          ;load AL with vga status
                TEST AL,8         ;is there a display phase ?
                JNZ @@VS2         ;yes,then wait until a new retrace starts
                ENDM
;------------------------------------------------------------------------------
;******************************************************************************
;HELPPROCEDURES
;******************************************************************************
;------------------------------------------------------------------------------
;Explanation:draws a plasma on screen
;Inputs :ES contains vga page segment,DS data segment
;Outputs:none
;Registers destroyed:AX,BX,CX,DX,SI,DI
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 DO_PLASMA      PROC NEAR
                MOV DX,3C4H       ;load DX with sequencer address
                MOV AX,0F02H      ;and enable writing to all planes
                OUT DX,AX         ;by sending above value to sequencer
                MOV DI,WORD PTR [PLASMA_POS]
                                  ;load DI with current plasma position
                MOV SI,WORD PTR [PLASMA_PICTURE]
                                  ;load SI with current facepicture offset
                MOV AH,BYTE PTR [PLASMA_HEIGTH]
                                  ;load AH with current plasma heigth
                MOV AL,BYTE PTR [COSPOSY1]
                                  ;load AL with 1. hor. wave phase
                                  ;offset
                MOV BYTE PTR [OFFSET RUN_Y1_POS+1],AL
                                  ;and load integer part of current
                                  ;1. hor. wave position with AL
                MOV AL,BYTE PTR [COSPOSY2]
                                  ;do so with
                MOV BYTE PTR [OFFSET RUN_Y2_POS+1],AL
                                  ;2. horizontal cosinus wave
 @@LV:
                PUSH AX           ;save AX and DI
                PUSH DI           ;on stack
                MOV AH,BYTE PTR [PLASMA_WIDTH]
                                  ;load AH with current plasma width
                MOV AL,BYTE PTR [COSPOSX1]
                                  ;load AL with 1. vert. wave phase offset
                MOV BYTE PTR [OFFSET RUN_X1_POS+1],AL
                                  ;and load integer part of current wave
                                  ;position with this value
                MOV AL,BYTE PTR [COSPOSX2]
                                  ;do so with
                MOV BYTE PTR [OFFSET RUN_X2_POS+1],AL
                                  ;2. vertical cosinus wave
                MOV DL,BYTE PTR [OFFSET RUN_Y1_POS+1]
                                  ;load DL and DH with current vertical
                MOV DH,BYTE PTR [OFFSET RUN_Y2_POS+1]
                                  ;cosinus wave positions
 @@LH:
                MOV BX,BP         ;load BX with BP (BP is a runvariable)
                MOV AL,BL         ;load AL with lower part of BP
                ADD AL,AH         ;add AH to AL (AH is random)
                XOR BH,BH         ;clear BH
                MOV BL,DL         ;load BL with current 1. vertical wave pos.
                ADD AL,BYTE PTR [BX]
                                  ;so we get a pointer on the cosinus table
                                  ;and add value from this table to AL
                MOV BL,DH         ;do so with second vertical
                ADD AL,BYTE PTR [BX]
                                  ;wave position
                MOV BL,BYTE PTR [OFFSET RUN_X1_POS+1]
                                  ;load BL with current 1. horizontal cosinus
                                  ;wave position
                ADD AL,BYTE PTR [BX]
                                  ;use BX as pointer to the cosinus table and
                                  ;add table entry to AL
                MOV BL,BYTE PTR [OFFSET RUN_X2_POS+1]
                                  ;do so with second horizontal cosinus
                ADD AL,BYTE PTR [BX]
                                  ;wave position
                MOV BL,BYTE PTR [IMAGE_LIFT]
                                  ;load BL with current picture value
                                  ;multiplier
                PUSH AX           ;save AX on stack
                MOV AL,BYTE PTR [SI]
                                  ;load AL with entry from plasma face buffer
                MUL BL            ;multiply entry by image lift value
                SHL AH,2          ;shift result in AH
                MOV BL,AH         ;load BL with result
                POP AX            ;restore AX from stack
                ADD AL,BL         ;and add result to AL
                MOV BX,OFFSET COLOR_CONVERT
                                  ;load BX with offset of color convert table
                XLAT              ;and load AL with table entry
                STOSB             ;store result in screen memory
                MOV BX,WORD PTR [HORIZ_ADD_1]
                                  ;load BX with 1. horizontal wave speed
                ADD WORD PTR [RUN_X1_POS],BX
                                  ;and add it to current wave position
                                  ;(we're simulating a real addition here)
                MOV BX,WORD PTR [HORIZ_ADD_2]
                                  ;do so with second horizontal wave
                ADD WORD PTR [RUN_X2_POS],BX
                                  ;and it's speed
                INC SI            ;go forward in plasma face buffer
                DEC AH            ;decrement loop counter
                JNZ @@LH          ;all horizontal dots done in this line ?
                                  ;no,then jump
                POP DI            ;else restore plasma position offset
                ADD DI,80         ;and add 80 for a line jump
                MOV BX,WORD PTR [VERTI_ADD_1]
                                  ;add wave speed of 1. vertical wave
                ADD WORD PTR [RUN_Y1_POS],BX
                                  ;to it's current offset
                MOV BX,WORD PTR [VERTI_ADD_2]
                                  ;and do so with
                ADD WORD PTR [RUN_Y2_POS],BX
                                  ;second vertical cosinus wave
                POP AX            ;restore line counter in AH
                DEC AH            ;and decrement it
                JNZ @@LV          ;all lines done yet ? no,then jump
                RET               ;else return
 DO_PLASMA      ENDP
;------------------------------------------------------------------------------
;Explanation:simulates a random set of the plasma and color variable
;Inputs :none
;Outputs:none
;Registers destroyed:AX,BX,CX,DX
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 CALC_PLASM_RND PROC NEAR
                MOV CL,FS:[4]     ;load CL,CH,DL,DH
                MOV CH,FS:[9]     ;with current
                MOV DL,FS:[12]    ;values
                MOV DH,FS:[17]    ;from use dma buffer
                SHR CL,5          ;divide CL by 32
                SHR CH,6          ;divide CH by 64
                SHR DL,5          ;divide DL by 32
                SHR DH,4          ;and divide DH by 16
                ADD BYTE PTR [COSPOSX1],CL
                                  ;add CL to 1.hwave phase offset
                SUB BYTE PTR [COSPOSX2],CH
                                  ;decrement CH from 2.hwave phase offset
                ADD BYTE PTR [COSPOSY1],DL
                                  ;add DL to 1.vwave phase offset
                SUB BYTE PTR [COSPOSY2],DH
                                  ;decrement DH from 2.vwave phase offset
                XOR BH,BH         ;clear BH
                MOV BL,BYTE PTR [COS_RUNXADD1]
                                  ;load BL with 1.hwave speed cosinus pos.
                MOV AL,BYTE PTR [BX]
                                  ;load AL with speed from cosinus table
                XOR AH,AH         ;clear AH
                SHL AX,3;2        ;multiply AX by 8
                ADD AX,100H       ;add 100H (minimal speed)
                MOV WORD PTR [HORIZ_ADD_1],AX
                                  ;and save result as new 1.hwave speed
                MOV BL,BYTE PTR [COS_RUNXADD2]
                                  ;do so with
                MOV AL,BYTE PTR [BX]
                                  ;all other waves
                XOR AH,AH
                SHL AX,3;2
                ADD AX,100H
                MOV WORD PTR [HORIZ_ADD_2],AX
                MOV BL,BYTE PTR [COS_RUNYADD1]
                MOV AL,BYTE PTR [BX]
                XOR AH,AH
                SHL AX,3;2
                ADD AX,100H
                MOV WORD PTR [VERTI_ADD_1],AX
                MOV BL,BYTE PTR [COS_RUNYADD2]
                MOV AL,BYTE PTR [BX]
                XOR AH,AH
                SHL AX,3;2
                ADD AX,100H
                MOV WORD PTR [VERTI_ADD_2],AX
                MOV CL,FS:[0]     ;load CL
                MOV CH,FS:[7]     ;CH,DL and
                MOV DL,FS:[11]    ;DH with values from
                MOV DH,FS:[13]    ;use dma buffer
                SHR CL,5;4        ;divide CL by 32
                SHR CH,4;3        ;divide CH by 16
                SHR DL,4;3        ;divide DL by 16
                SHR DH,5;4        ;divide DH by 32
                ADD BYTE PTR [COS_RUNXADD1],CL
                                  ;and add CL,CH,DL,CH
                SUB BYTE PTR [COS_RUNXADD2],CH
                                  ;to waves
                ADD BYTE PTR [COS_RUNYADD1],DL
                                  ;speed cosinus positions
                SUB BYTE PTR [COS_RUNYADD2],DH
                MOV CL,FS:[32]    ;load CL,CH,DL with
                MOV CH,FS:[67]    ;values from
                MOV DL,FS:[21]    ;use dma buffer
                SHR CL,6          ;divide CL by 64
                SHR CH,7          ;divide CH by 128
                SHR DL,6          ;and divide DL by 64
                CMP BYTE PTR [GOTO_BW_FLAG],255
                                  ;move colors to black&white
                JZ MOVE_TO_BW     ;yes,then jump
                ADD BYTE PTR [COSPOSC1],CL
                                  ;else add CL to red cosinus phase offset
                SUB BYTE PTR [COSPOSC2],CH
                                  ;add CH to green cosinus phase offset
                SUB BYTE PTR [COSPOSC3],DL
                                  ;and add DL to blue cosinus phase offset
                RET               ;then leave this damned procedure
 MOVE_TO_BW:
                CMP BYTE PTR [BW_DONE_FLG],63
                                  ;move to bw done ?
                JZ FADE_OUT       ;yes,then start fading out
                CMP BYTE PTR [COSPOSC1],128
                                  ;else check if red cosinus phase offset is
                                  ;in then dead point of the cosinus
                JZ SKIP_R_CORRECT ;yes,then skip moving phase offset
                INC BYTE PTR [COSPOSC1]
                                  ;else move it forward
                JMP R_CORREC_DONE ;and jump
 SKIP_R_CORRECT:
                OR BYTE PTR [BW_DONE_FLG],1
                                  ;set bit 0 in bw_done flag
 R_CORREC_DONE:
                CMP BYTE PTR [COSPOSC2],128
                                  ;do so with green
                JZ SKIP_G_CORRECT
                INC BYTE PTR [COSPOSC2]
                JMP G_CORREC_DONE
 SKIP_G_CORRECT:
                OR BYTE PTR [BW_DONE_FLG],2
 G_CORREC_DONE:
                CMP BYTE PTR [COSPOSC3],128
                                  ;do so with blue
                JZ SKIP_B_CORRECT
                INC BYTE PTR [COSPOSC3]
                JMP B_CORREC_DONE
 SKIP_B_CORRECT:
                OR BYTE PTR [BW_DONE_FLG],4
 B_CORREC_DONE:
                CMP WORD PTR [R_FASTNES],100H
                                  ;is red cosinus wave speed = 1 ?
                JBE SKIP_RSPEED_COR
                                  ;yes,then skip correcting it
                SUB WORD PTR [R_FASTNES],10H
                                  ;else correct it a little bit
                JMP R_SPEEDSET_DONE
                                  ;and jump
 SKIP_RSPEED_COR:
                OR BYTE PTR [BW_DONE_FLG],8
                                  ;set bit 4 of bw_done flag
 R_SPEEDSET_DONE:
                CMP WORD PTR [G_FASTNES],100H
                                  ;do so with green
                JBE SKIP_GSPEED_COR
                SUB WORD PTR [G_FASTNES],10H
                JMP G_SPEEDSET_DONE
 SKIP_GSPEED_COR:
                OR BYTE PTR [BW_DONE_FLG],16
 G_SPEEDSET_DONE:
                CMP WORD PTR [B_FASTNES],100H
                                  ;do so with blue
                JBE SKIP_BSPEED_COR
                SUB WORD PTR [B_FASTNES],10H
                JMP B_SPEEDSET_DONE
 SKIP_BSPEED_COR:
                OR BYTE PTR [BW_DONE_FLG],32
 B_SPEEDSET_DONE:
                RET               ;leave procedure
 FADE_OUT:
                CMP WORD PTR [R_FASTNES],0
                                  ;is red cosinus wave speed 0 ?
                JBE SKIP_RSPEED_COR2
                                  ;yes,then skip calculating it to 0
                SUB WORD PTR [R_FASTNES],1
                                  ;else calculate new speed
                JMP R_SPEEDSET_DONE2
                                  ;and jump
 SKIP_RSPEED_COR2:
                OR BYTE PTR [FADE_DONE_FLG],1
                                  ;set bit 0 in fade done flag
 R_SPEEDSET_DONE2:
                CMP WORD PTR [G_FASTNES],0
                                  ;do so for green
                JBE SKIP_GSPEED_COR2
                SUB WORD PTR [G_FASTNES],1
                JMP G_SPEEDSET_DONE2
 SKIP_GSPEED_COR2:
                OR BYTE PTR [FADE_DONE_FLG],2
 G_SPEEDSET_DONE2:
                CMP WORD PTR [B_FASTNES],0
                                  ;do so for blue
                JBE SKIP_BSPEED_COR2
                SUB WORD PTR [B_FASTNES],1
                JMP B_SPEEDSET_DONE2
 SKIP_BSPEED_COR2:
                OR BYTE PTR [FADE_DONE_FLG],4
 B_SPEEDSET_DONE2:
                CMP BYTE PTR [FADE_DONE_FLG],7
                                  ;are all speeds zero ?
                JNZ MORE_BW_MOVES ;no,then correct'em until they are
                MOV BYTE PTR [HOME_FLAG],255
                                  ;else set exit flag
 MORE_BW_MOVES:
                RET               ;and return
 CALC_PLASM_RND ENDP
;------------------------------------------------------------------------------
;Explanation:set maximum scan line register
;Inputs :none
;Outputs:none
;Registers destroyed:AX,DX,DS
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 SET_MSL_REG    PROC
                MOV AX,@DATA      ;load DS with data segment
                MOV DS,AX         ;using AX register
                MOV DX,03D4H      ;load DX with crtc port
                MOV AL,9          ;and send msl index in AL
                MOV AH,BYTE PTR [LINE_DOUBLE]
                                  ;and new msl value in AH
                OUT DX,AX         ;to crtc
                RET               ;return
 SET_MSL_REG    ENDP
;------------------------------------------------------------------------------
;Explanation:cycle plasma colors (cycling means randomly creating)
;Inputs :DS contains data segment
;Outputs:none
;Registers destroyed:AX,BX,CX,DX,SI
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 CYCLE_COLORS   PROC NEAR
                MOV SI,OFFSET COSTABLE_COLOR
                                  ;load SI with offset of color cosinus tab.
                XOR BH,BH         ;clear BH and
                XOR AL,AL         ;AL
                MOV AH,BYTE PTR [COSPOSC1]
                                  ;load AL with red cosinus phase offset
                MOV WORD PTR [RCOS_POS],AX
                                  ;and store AX in current red offset
                MOV AH,BYTE PTR [COSPOSC2]
                                  ;do so with green
                MOV WORD PTR [GCOS_POS],AX
                MOV AH,BYTE PTR [COSPOSC3]
                                  ;and blue
                MOV WORD PTR [BCOS_POS],AX
                MOV DX,03C8H      ;load DX with pel index port
                MOV AL,128        ;and send start color
                OUT DX,AL         ;to pel
                INC DX            ;load DX with pel data port
                MOV CX,128        ;load CX with number of colors to do
 CYCLE_COL_LOOP:
                PUSH CX           ;save loop counter on stack
                MOV BL,BYTE PTR [RCOS_POS+1]
                                  ;load BL with current red cosinus pos.
                MOV AL,[SI+BX]    ;and load AL with entry from color costab.
                OUT DX,AL         ;send AL to pel
                MOV BL,BYTE PTR [GCOS_POS+1]
                                  ;do so with green
                MOV AL,[SI+BX]
                OUT DX,AL
                MOV BL,BYTE PTR [BCOS_POS+1]
                                  ;and blue
                MOV AL,[SI+BX]
                OUT DX,AL
                POP CX            ;restore loop counter
                MOV AX,WORD PTR [R_FASTNES]
                                  ;load AX with red cosinus speed (real)
                ADD WORD PTR [RCOS_POS],AX
                                  ;and add it to current red cosinus wave
                                  ;position
                MOV AX,WORD PTR [G_FASTNES]
                                  ;do so with green
                ADD WORD PTR [GCOS_POS],AX
                MOV AX,WORD PTR [B_FASTNES]
                                  ;do so with blue
                ADD WORD PTR [BCOS_POS],AX
                LOOP CYCLE_COL_LOOP
                                  ;redo until 128 colors are set
                RET               ;and then leave
 CYCLE_COLORS   ENDP
;------------------------------------------------------------------------------
;Explanation:controls the plasma face mix in timing
;Inputs :DS contains data register
;Outputs:none
;Registers destroyed:none
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 MIX_IMAGE      PROC NEAR
                CMP WORD PTR [COUNTER2],0
                                  ;is it time to start a new picture
                                  ;mix in or out phase ?
                JZ DO_IMAGE       ;yes,then jump
                DEC WORD PTR [COUNTER2]
                                  ;else decrement counter
                RET               ;and return
 DO_IMAGE:
                DEC WORD PTR [COUNTER]
                                  ;decrement lift up delay counter
                JNZ END_IMAGE_MIX ;is it time to lift picture a little bit ?
                                  ;no,then jump
                MOV WORD PTR [COUNTER],LIFT_DELAY
                                  ;else reload lift delay counter
                CMP BYTE PTR [UPDOWN_FLAG],0
                                  ;lift picture up or down ?
                JNZ IMAGE_UP      ;up,then jump
                DEC BYTE PTR [IMAGE_LIFT]
                                  ;else lift it down a little bit
                CMP BYTE PTR [IMAGE_LIFT],0
                                  ;is it lifted down fully ?
                JNZ END_IMAGE_MIX ;no,then jump
                MOV BYTE PTR [UPDOWN_FLAG],255
                                  ;else set up down flag
                MOV WORD PTR [COUNTER2],IMAGE_DELAY
                                  ;reload second counter
                RET               ;and return
 IMAGE_UP:
                INC BYTE PTR [IMAGE_LIFT]
                                  ;lift picture up a little bit
                CMP BYTE PTR [IMAGE_LIFT],45
                                  ;is it lifted up enough ?
                JNZ END_IMAGE_MIX ;no,then jump
                MOV WORD PTR [COUNTER2],IMAGE_DELAY
                                  ;else reload second counter
                MOV BYTE PTR [UPDOWN_FLAG],0
                                  ;set up down flag
                RET               ;and return
 END_IMAGE_MIX:
                RET               ;return (a second time)
 MIX_IMAGE      ENDP
;------------------------------------------------------------------------------
;Explanation:initializes the black&white phase coupling
;Inputs :DS contains data segment
;Outputs:none
;Registers destroyed:none
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 INIT_BW_MOVE   PROC NEAR
                MOV BYTE PTR [GOTO_BW_FLAG],255
                                  ;set do_bw_flag
                RET               ;and return
 INIT_BW_MOVE   ENDP
;------------------------------------------------------------------------------
;Explanation:draws the legend desing logo on the screen
;Inputs :DS contains data segment
;Outputs:none
;Registers destroyed:AX,BX,CX,DX,DI,SI
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 DO_LOGOPLAS    PROC NEAR
                MOV DX,3C4H       ;enable writing to all planes
                MOV AX,0F02H      ;at one time
                OUT DX,AX         ;by setting vga sequencer
                MOV DI,LOGO_X+LOGO_Y*80
                                  ;load DI with logo position on screen
                MOV SI,OFFSET LOGO_PICTURE
                                  ;load SI with offset of logo buffer
                MOV AH,LOGO_HEIGTH;load AH with logo height
                MOV DL,BYTE PTR [OFFSET RUN_Y1_POS+1]
                                  ;load DL with 1.vwave phase offset
                MOV DH,BYTE PTR [OFFSET RUN_Y2_POS+1]
                                  ;load DH with 2.vwave phase offset
 @@LV2:
                PUSH AX           ;save AX and DI
                PUSH DI           ;on stack
                MOV AH,LOGO_LENGTH;load AH with logo width
                MOV CL,BYTE PTR [OFFSET RUN_X1_POS+1]
                                  ;load CL with 1.hwave phase offset
                MOV CH,BYTE PTR [OFFSET RUN_X2_POS+1]
                                  ;load CH with 2.hwave phase offset
 @@LH2:
                MOV BX,BP         ;load BX with BP
                MOV AL,BL         ;load AL with lower part of BP
                ADD AL,AH         ;add AH (AH is random)
                XOR BH,BH         ;clear BH
                MOV BL,DL         ;and add
                ADD AL,BYTE PTR [BX]
                MOV BL,DH         ;values
                ADD AL,BYTE PTR [BX]
                MOV BL,CL         ;of the four
                ADD AL,BYTE PTR [BX]
                MOV BL,CH         ;cosinus waves
                ADD AL,BYTE PTR [BX]
                                  ;together
                MOV BL,BYTE PTR [SI]
                                  ;load BL with value from logo picture
                SHL BL,1          ;multiply it by 2
                ADD AL,BL         ;add it to cosinus calculation result in
                                  ;AL
                CMP BL,0          ;is logo pixel black ?
                JNZ LOGO_SET      ;no,then set it
                MOV AL,0          ;else load AL with zero
 LOGO_SET:
                AND AL,127        ;mask out highest bit
                STOSB             ;and set value in AL onto screen
                ADD CL,1          ;move forward in 1. and 2. hwave
                ADD CH,2          ;cosinus wave table
                INC SI            ;get next logo picture position
                DEC AH            ;decrement pixel counter
                JNZ @@LH2         ;all pixels done in this line ? no,then
                                  ;redo until all are done
                POP DI            ;get old DI from stack
                ADD DL,2          ;move forward in 1. and 2. vwave
                ADD DH,3          ;cosinus wave table
                POP AX            ;pop AX from stack
                ADD DI,80         ;count DI forward one line
                DEC AH            ;decrement line counter
                JNZ @@LV2         ;all lines done ? no,then do until
                RET               ;return
 DO_LOGOPLAS    ENDP
;------------------------------------------------------------------------------
;Explanation:fades up logo colors while redrawing logo,cycling colors and so on
;Inputs :DS contains data segment
;Outputs:none
;Registers destroyed:AX,BX,CX,DX,SI,DI
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 FADE_IN_LOGO   PROC NEAR
                MOV AH,64         ;load AH with number of steps to do
 DO_MORE_COLFADE:
                PUSH AX           ;save loop counter on stack
                WAIT_VSYNC        ;wait for vertical retrace
                WAIT_VSYNC        ;twice
                POP AX            ;restore loop counter
                MOV DX,3C8H       ;load DX with pel index port
                MOV AL,0          ;load AL with start color
                OUT DX,AL         ;and send it to pel
                INC DX            ;load DX with pel data port
                MOV CX,384        ;load CX with loops to do
                MOV SI,OFFSET PALETTE
                                  ;load SI with offset of palette datas
 @@PL1:
                LODSB             ;load AL with palette table entry
                SUB AL,AH         ;decrement loop counter
                JNB NO_COLOR_UNDERFLW
                                  ;jump,if it didn't crossed zero
                MOV AL,0          ;else set it to zero
 NO_COLOR_UNDERFLW:
                OUT DX,AL         ;and send result to pel
                LOOP @@PL1        ;redo until 128 colors are set
                PUSH AX           ;save loop counter on satck again
                CALL DO_PLASMA    ;draw plasma
                CALL DO_LOGOPLAS  ;draw logo plasma
                CALL CALC_PLASM_RND
                                  ;randomize plasma variables
                DEC BP            ;decrement plasma intern variable
                POP AX            ;restore AX
                DEC AH            ;decrement loop counter
                JNZ DO_MORE_COLFADE
                                  ;all loops done ? no,then do until it is
                RET               ;return to calling procedure
 FADE_IN_LOGO   ENDP
;------------------------------------------------------------------------------
;Explanation:resizes plasma on screen
;Inputs :DS contains data segment
;Outputs:none
;Registers destroyed:AX,BX,CX,DX,SI,DI,BP
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 BIGGER_PLASMA  PROC NEAR
                WAIT_VSYNC        ;wait for vertical retrace
                CMP BYTE PTR [PLASMA_WIDTH],P_WIDTH
                                  ;has plasma width reached his end value ?
                JNZ MORE_SCALE    ;no,then do more width scale
                RET               ;else return
 MORE_SCALE:
                INC BYTE PTR [PLASMA_WIDTH]
                                  ;increment plasma width
                DEC WORD PTR [PLASMA_POS]
                                  ;and decrement plasma x position
                CMP BYTE PTR [PLASMA_HEIGTH],P_HEIGTH
                                  ;has plasma heigth reached his maximum ?
                JZ NO_MORE_HSCALE ;yes,then end plasma scaling
                INC BYTE PTR [PLASMA_HEIGTH]
                                  ;else increment plasma height
                SUB WORD PTR [PLASMA_POS],80
                                  ;and move plasma up one line
 NO_MORE_HSCALE:
                CALL CYCLE_COLORS ;randomize plasma colors
                CALL DO_PLASMA    ;redraw plasma
                CALL DO_LOGOPLAS  ;redraw logo plasma
                CALL CALC_PLASM_RND
                                  ;randomize plasma variables
                DEC BP            ;decrement plasm intern variables
                JMP BIGGER_PLASMA ;and jump to scale more times
 BIGGER_PLASMA  ENDP
;------------------------------------------------------------------------------
;Explanation:sets the second 128 colors to zero
;Inputs :DS contains data segment
;Outputs:none
;Registers destroyed:AX,CX,DX
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 PLASMA_BLACK   PROC NEAR
                MOV DX,3C8H       ;load DX with pel index port
                MOV AL,128        ;load AL with start color
                OUT DX,AL         ;and send it to pel
                INC DX            ;load DX with pel data port
                MOV CX,384        ;load CX with number of r,g and b cycles
                                  ;to do
                MOV AL,0          ;load AL with 0
 PAL_BLACK:
                OUT DX,AL         ;send it to pel
                LOOP PAL_BLACK    ;and redo until all colors are done
                RET               ;leave procedure
 PLASMA_BLACK   ENDP
;------------------------------------------------------------------------------
;Explanation:initializes the vga card for our requierments
;Inputs :none
;Outputs:none
;Registers destroyed:AX,CX,DX
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 INIT_VGACARD   PROC NEAR
                MOV AX,13H        ;set video mode 13H
                INT 10H           ;via video interrupt
                MOV DX,3C4H       ;initialize sequencer
                MOV AX,604H       ;to allow
                OUT DX,AX         ;chain 4 mode
                MOV DX,3D4H       ;initialize CRT controller
                MOV AX,14H        ;to support
                OUT DX,AX         ;chain 4 mode
                MOV AX,0E317H     ;allowed
                OUT DX,AX         ;by sequencer
                CALL PLASMA_BLACK ;set second 128 colors to zero
                CALL SET_MSL_REG  ;initialize line doubling
                RET               ;return
 INIT_VGACARD   ENDP
;------------------------------------------------------------------------------
;Explanation:fades out logo colors and background sound
;Inputs :DS contains data segment
;Outputs:none
;Registers destroyed:AX,BX,CX,DX
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 FADE_OUT_LOGO  PROC NEAR
                MOV AH,64         ;load AH with number of fade out steps to do
 DO_MORE_COLFADE2:
                PUSH AX           ;save counter on stack
                WAIT_VSYNC        ;wait for vertical retrace
                POP AX            ;restore counter
                MOV DX,3C8H       ;load DX with pel index port
                MOV AL,0          ;load AL with start color
                OUT DX,AL         ;and send it to pel
                INC DX            ;load DX with pel data port
                MOV CX,384        ;load CX with number of rgb triple parts to
                                  ;do
                MOV SI,OFFSET PALETTE
                                  ;load SI with palette table offset
 @@PL2:
                LODSB             ;load AL with palette table entry
                MOV BL,AH         ;load BL with counter
                XOR BL,63         ;negate it
                SUB AL,BL         ;and decrement it from table entry
                JNB NO_COLOR_UNDERFLW2
                                  ;crossed result zero ? no,then jump
                MOV AL,0          ;else load AL with zero
 NO_COLOR_UNDERFLW2:
                OUT DX,AL         ;and send AL to pel
                LOOP @@PL2        ;redo until all 128 colors are done
                PUSH AX           ;push counter on stack
                CALL DO_PLASMA    ;redraw plasma
                CALL DO_LOGOPLAS  ;redraw logo plasma
                CALL CALC_PLASM_RND
                                  ;randomize plasma variables
                DEC BP            ;decrement plasma intern variable
                SUB WORD PTR [LOUDNES],0101H
                                  ;decrement loudness for left and right
                                  ;channel
                MOV CX,WORD PTR [LOUDNES]
                                  ;load CX with new loudness
                MOV AH,10H        ;and set it
                PUSH ES           ;using really cool
                INT 80H           ;use driver interrupt
                POP ES            ;restore ES
                POP AX            ;pop counter from stack
                DEC AH            ;decrement counter
                JNZ DO_MORE_COLFADE2
                                  ;and redo until all is faded out
                RET               ;return
 FADE_OUT_LOGO  ENDP
;------------------------------------------------------------------------------
;Explanation:
;Inputs :
;Outputs:
;Registers destroyed:
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 INIT_SOUND     PROC NEAR
                MOV AH,0FH
                INT 80H
                MOV AH,01H
                INT 80H
                MOV AX,@DATA
                MOV DS,AX
                MOV DX,OFFSET SONG_NAME
                MOV AH,21H
                INT 80H
                MOV AH,10H
                MOV CX,4040H
                INT 80H
                MOV AH,30H
                MOV CL,1
                INT 80H
                RET
 INIT_SOUND     ENDP
;------------------------------------------------------------------------------
;Explanation:
;Inputs :
;Outputs:
;Registers destroyed:
;Possible errors:none
;Cycles used on 386:
;------------------------------------------------------------------------------
 STOP_SOUND     PROC NEAR
                MOV AH,32H
                INT 80H
                MOV AH,40H
                INT 80H
                MOV AH,0FFH
                INT 80H
                RET
 STOP_SOUND     ENDP
;------------------------------------------------------------------------------
;******************************************************************************
;RUNTIMECODE
;******************************************************************************
;------------------------------------------------------------------------------
 START:
                MOV BX,500        ;free conventional dos memory
                MOV AH,4AH        ;using the good
                INT 21H           ;old dos
                CALL INIT_VGACARD ;init vga card for our requierment
                CALL INIT_SOUND   ;init use-driver for playing nice music
                CLD               ;clear direction flag
                MOV AH,0D1H       ;get use-driver dma buffer segment
                INT 80H           ;by calling use_int
                PUSH ES           ;load FS with dma segment in ES
                POP FS            ;using stack
                MOV AX,@DATA      ;load DS with data segment
                MOV DS,AX         ;using AX
                MOV AX,0A000H     ;and load ES with vga screen segment
                MOV ES,AX         ;using AX register
                CALL FADE_IN_LOGO ;fade in legend design logo
                CALL BIGGER_PLASMA;and scale plasma
 MAINLOOP:
;                WAIT_VSYNC        ;wait for fuckin' vsync
                CALL CYCLE_COLORS ;cycle the plasma colors
                CALL DO_PLASMA    ;redraw plasma with new colors and form
                CALL DO_LOGOPLAS  ;redraw plasma woth new colors and form
                CALL CALC_PLASM_RND
                                  ;randomize plasma values (randomize :-))
                CALL MIX_IMAGE    ;and mix plasma face into plasma
                DEC BP            ;decrement BP (plasma intern variable)
                CMP BYTE PTR [HOME_FLAG],0
                                  ;is the home flag set ?
                JNZ REALLY_BYE    ;yeap,then start exit procedure
                MOV AH,1          ;else check if a key was pressed
                INT 16H           ;using keyboard interrupt
                JNZ BYE           ;yeap,then init exit part
                JMP MAINLOOP      ;else redo plasma scum
 BYE:
                CALL INIT_BW_MOVE ;initialize black&white fade
                JMP MAINLOOP      ;and redo plasma scum
 REALLY_BYE:
                CALL FADE_OUT_LOGO;fade down logo (and music volume)
                CALL STOP_SOUND   ;stop music playing
 SKIP_DEMOPART:
                XOR AH,AH         ;clear keyboard buffer
                INT 16H           ;by calling keyboard interrupt
                MOV AX,3          ;set video mode 3
                INT 10H           ;using video interrupt
                MOV AX,4C00H      ;return
                INT 21H           ;via dos
;------------------------------------------------------------------------------
 END START
