	DOSSEG
	.MODEL SMALL
	.STACK  200h
	.CODE
	.386
	Ideal

	ASSUME  cs:@code, ds:@code
	
	INCLUDE "PROMOD.INC"
	INCLUDE "CONFIGIT.INC"
	
;=======- Necessary DATA
;=====- Command line capture
;FILE: MCLSUB.ASM
;upon entry: 
;
;*      ES= PSP SEG 
;*      DS:DX = pointer to filename area
;*      DS:BX = pointer to 5 byte 0 terminating Extension to add
;
;RETURN: AX= length of command line

GLOBAL  GetCommandLine:NEAR

	MNPRi   db  13,10,10    
	ModName db "c:\mods\attack.mod",130 dup (0),"$"   ;filename goes here
	Extension db  ".MOD",0,"$"
	ModSeg  dw  0
	DspSeg  dw  0

	Credits db  10,10,20 dup (" "),"Written by Draeden of VLA ",13,10,10,"$"

	ErrorMsg  db "Error loading file.$"

	PLaying db  13,10,10,"    Playing MOD.... Press any key to exit.$"

;=======- START MAIN

Start:
	mov     ax,es
	mov     [cs:DspSeg],ax
	mov     ax,cs
	mov     ds,ax

	mov     bx,ss
	add     bx,20h
	mov     [BaseModSeg],bx      ;MUST be last one - stacks on top of it

	mov     ax,cs
	mov     ds,ax
	mov     es,[DspSeg]
	mov     dx,offset ModName
	mov     bx,offset Extension
	call    GetCommandLine

	mov     ax,3
	int     10h

	mov     [StereoOn],0
	mov     [DoWowii],0
	mov     [IsDirect],0
	mov     [HZ],15000
	mov     [MasterVolume],256
	mov     [BaseAddress],220h
	mov     [IntNumber],7

	@cursorOff
	call    AskQuestions

	mov     ah,9
	mov     dx,offset MNPri
	int     21h

	mov     dx,offset Playing
	mov     ah,9
	int     21h

SoundIsOn:
	mov     dx,offset ModName
	call    StartPlaying
	cmp     ax,-1
	je      ExitError
MainLoop:
	call    MainUpdate
	mov     ah,1
	int     16h
	jz      MainLoop

WaitForESC:
;    in      al,60h
;    cmp     al,1
;    jne     WaitForESC

	mov     ah,0
	int     16h

ExitAllDone:
	call    StopPlaying

ByeBye:
	mov     ax,0003h
	int     10h
	mov     ax,4c00h
	int     21h

ExitError:
	push    cs
	pop     ds
	mov     ah,9
	mov     dx,offset ErrorMsg
	int     21h
	jmp     ByeBye

END Start
