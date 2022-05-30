	DOSSEG
	.MODEL SMALL
	.CODE
	ASSUME  cs:@code, ds:@code
	ideal

	P386N

	INCLUDE "PROMOD.INC"  ;all the globals and stuff

	;GLOBAL AddNum:WORD
	;ADDNUM dw 0
	
;=======-   Grunge Work -====

	MAXBuffSize     equ 30000
	BUFFSIZE        equ 9000

	CRLF        db  13,10,10    ;carriage return & line feed & line feed
	OnChar      db " ÛÛ"
	OffChar     db " °°"

	; count    = 933,120,000/HZ (stored as DD)
	;       116640 for 8000 hz 016C80h for 10000hz chart is below
	; Buffsize = HZ/10000*SPEED_CONST (stored as DW)

;*****************
;***=- DATA -=****
;*****************
	DoWowII     db  0
	IsDirect    db  1   ;1= using direct mode

	BaseModSeg  dw  ?   ;the segment at which the mod starts to store
						; everything... patterns & samples
	CurSegPtr   dw  ?   ;Used to point to the next base address
						; after load is done, has the segment of the highest
						; used area for MOD info..

	PatternSeg      dw  0           ;segment of 1st pattern
	SampleSegment   dw  31 dup (0)  ;segment to Samples
	SampleOffset    dw  31 dup (0)  ;offset to Samples

	BytesPer50th dw 0
	BytesPerTick dw 0   ;base time unit (1/50th of a second)
						;buffer size = BPS * Speed (1-1fh)
	BPTCounter  dw  0
	TickCounter dw  0
	CurTick     db  0
	SongSpeed   dw  6
	BPMSpeed    dw  125
	CurrentTrak dw  0
	TmpCurBuffSize dw 0
	CurStrucOff dw  0
	PatternDelay db 0

	UpdateRoutine dw 4 dup (offset UpdateTrakMONO)
				
	ComputerSpeed db    3

	MAXSPEED = 6    ;the number of entries below - 1

	Hz      dw      10000
	SampleRate db   0

	COUNT   DD      16c8000h ;this value is divided by the NOTE FREQUENCY
											; to yield the step value...
	CountConst dd   16b8000h

	FunkTable     dw  0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	FunkTableSize equ 16

INCLUDE "NoteTabl.INC"  ;has all the notes here from low(big number) to high
						;label is -NoteTable- dw

INCLUDE "Stereo.DW"     ;256*sin(x*pi/512) for (0-255)

	SineWaveTable dw  0, 24, 49, 74, 97,120,141,161
								dw  180,197,212,224,235,244,250,253
								dw  255,253,250,244,235,224,212,197
								dw  180,161,141,120, 97, 74, 49, 24
								dw    0,- 24,- 49,- 74,- 97,-120,-141,-161
								dw -180,-197,-212,-224,-235,-244,-250,-253
								dw -255,-253,-250,-244,-235,-224,-212,-197
								dw -180,-161,-141,-120,- 97,- 74,- 49,- 24
	SineWaveSize  equ 64     ;number of entries

	SquareWaveTable dw  0,128,196,27 dup (255),196,128
								dw  0,-128,-196,27 dup (-255),-196,-128
	SquareWaveSize equ 64     ;number of entries

	RampDnWaveTable dw  0,128,196,27 dup (255),196,128
								dw  0,-128,-196,27 dup (-255),-196,-128
	RampDnWaveSize equ 64     ;number of entries

	VibratoTable  dw  offset SineWaveTable  
	VibratoSize   dw  SineWaveSize
	TremoloTable  dw  offset SineWaveTable
	TremoloSize   dw  SineWaveSize
 
 Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä 

;STRUC DataStruc
;    Headerptr   dd  0           ;pointer to header
;    CurBuff     dd  0           ;pointer to currently playing buffer
;    BuffSize    dw  0           ;size of currently playing buffer
;    TrakOn      db  8 dup (0)   ;what inst is playing (0=none)
;    VolBars     db  8 dup (0)   ;User decreased volume bars
;    CNote       db  0           ;current note 0-63
;    CPattern    db  0           ;current pattern
;    CSequence   db  0           ;surrent sequence
;    BPMspeed    db  0           ;beat per minute speed
;    HZ          dw  0           ;sampling rate
;ENDS  DataStruc

	QTDS DataStruc   ?

 Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä 

	struc SampleRec
		SName       db  22 dup (?)
		Length      dw  ?
		FineTune    db  ?
		Volume      db  ?
		Repeat      dw  ?
		RepLen      dw  ?
	ends  SampleRec

HEADER:
	SongName    db      20 dup (0)
	Samples   SampleRec 31 dup(<>)
	SongLen     db      0
	Restart     db      0
	Sequences   db      128 dup (0)
	mk          dd      0           ;the M.K. signature
	HeaderSize  =   $-Header

	struc   Trak
		senabled    db  0     ;0= trak is not valid: other= play it
		sdelayed    db  0     ;0= not delayed, 1= sample is delayed
		SpecialOn   db  0     ;0= no special, other yes

		sseg        dw  ?     ;sample segment
		soff        dw  ?     ;sample offset
		sloops      dw  ?     ;sample loop start
		slooplen    dw  ?     ;lenght of loop
		send        dw  ?     ;ending offset of sample
		sfreq       dd  ?     ;sample frequency (step)
		stfreq      dw  ?     ;temporary step value
		svol        db  ?     ;volume
		sinst       db  ?     ;the inst currently playing

		PLeftVol    dw  100h
		PRightVol   dw  100h
		Lvol        db  0
		Rvol        db  0

		Note            dw  ?   ;the frequency, not the step value
		LastNote        dw  ?   ;the last real note played..
		cmd             db  ?   ;command (0-15)
		cmdX            db  ?   ;upper 4 bits of the XY
		cmdY            db  ?   ;lower 4 bits..
		cmdXY           db  ?   ;all 8 put together (XY)
		Period          dw  ?   ; ?
		FineTune        db  ?   ;amount shifted up or down..
		Start           dw  ?   ;offset of beginning of sample (for retrigger)
		
		ArpeggStep      db  ?   ;either 0,1, or 2
		WantedNote      dw  ?
		VibratoCmd      db  ?   ;speed for Vibrato
		VibratoPos      db  ?   ;position in chart
		VibNote         dw  ?   ;base note for vib
		TremoloCmd      db  ?   
		TremoloPos      db  ?   
		TremVol         db  ?
		WaveControl     db  ?
		GlissFunk       db  ?
		SampleOffset    db  ?
		LoopPos         db  ?
		LoopCount       db  ?
		FunkOffset      db  ?
		WaveStart       dd  ?
		RealLength      dw  ?
		
	ends    TRAK

	TheTraks    Trak   6 dup (<>)
	
	NumPatterns     dw      0

	CurOff          dw      0
	
	CurPattern      dw      0       ;curent pattern
	CurNote         dw      0       ;current note in pattern
	CurSequence     dw      0       ;current sequence

	MASTERVOLUME    dw      100h    ;100h = 100% volume

;====- DMA DAC PLAYER DATA -====

	CurBuffsize     dw      0
	NewBufferFlag   dw      0
	NewBufferSize   dw      0
	
	;speed 7=1484 6=1320 @ 10000hz
	; count    = 933,120,000/HZ (stored as DD) 
	;       116640 for 8000 hz 016C80h for 10000hz chart is below
	; Buffsize = HZ/10000*SPEED_CONST (stored as DW)

;=====SUBROUTINES=====

PROC SelectHz
	pushad
	push    ds es

	mov     ax,cs
	mov     ds,ax
	mov     es,ax

	movzx   ecx,[HZ]
	
	cmp     [StereoOn],0
	je      @@NoStereo
	mov     [UpdateRoutine+0],offset UpdateTrakSTEREO
	mov     [UpdateRoutine+2],offset UpdateTrakSTEREO
	mov     [UpdateRoutine+4],offset UpdateTrakSTEREO
	mov     [UpdateRoutine+6],offset UpdateTrakSTEREO
	mov     [TheTraks.PLeftVol],0F0h
	mov     [TheTraks.PrightVol],40h
	mov     bx,size Trak
	mov     [BX + TheTraks.PLeftVol], 0D0h
	mov     [BX + TheTraks.PrightVol],0A0h
	add     bx,size Trak
	mov     [BX + TheTraks.PLeftVol], 0A0h
	mov     [BX + TheTraks.PrightVol],0D0h
	add     bx,size Trak
	mov     [BX + TheTraks.PLeftVol],40h
	mov     [BX + TheTraks.PrightVol],0F0h

	add     ecx,ecx
	cmp     [DoWowii],0
	je      @@NoWOWii

;if for some reason, this guy wants to do wowii style...

	mov     [UpdateRoutine+0],offset UpdateTrakLeft
	mov     [UpdateRoutine+2],offset UpdateTrakRight
	mov     [UpdateRoutine+4],offset UpdateTrakRight
	mov     [UpdateRoutine+6],offset UpdateTrakLeft
@@NoWOWII:
	mov     eax,1000000     ;samplerate = 256 - 1,000,000/Hz
	xor     edx,edx
	div     ecx
	neg     al
	mov     [SampleRate],al

	neg     al
	movzx   ecx,al
	mov     eax,1000000     ;samplerate = 256 - 1,000,000/Hz
	xor     edx,edx
	div     ecx
	mov     [HZ],ax
	movzx   ecx,ax
	shr     ecx,1
	mov     eax,[CountConst]
	mov     edx,10000
	mul     edx
	div     ecx
	mov     [Count],eax         ;save COUNT value
	jmp     @@NoStereo2
	
@@NoStereo:
	mov     eax,1000000     ;samplerate = 256 - 1,000,000/Hz
	xor     edx,edx
	div     ecx
	neg     al
	mov     [SampleRate],al

	neg     al
	movzx   ecx,al
	mov     eax,1000000     ;samplerate = 256 - 1,000,000/Hz
	xor     edx,edx
	div     ecx
	mov     [HZ],ax
	movzx   ecx,ax

	mov     eax,[CountConst]
	mov     edx,10000
	mul     edx
	div     ecx
	mov     [Count],eax         ;save COUNT value
	
	cmp     [StereoOn],0
	je      @@NoStereo2
	mov     ax,[HZ]
	add     [HZ],ax
@@NoStereo2:
	mov     ax,[HZ]
	xor     dx,dx
	mov     cx,50
	div     cx
	and     ax,0FFFEh           ;make sure its even
	mov     [BytesPerTick],ax
	mov     [BytesPer50th],ax

	mov     ax,6
	mov     [SongSpeed],ax
	mov     dx,[BytesPerTick]
	mul     dx
	mov     [NEWBuffersize],ax
	mov     [NewBufferFlag],0
	mov     [Buffer1Size],ax
	mov     [Buffer2Size],ax

	mov     [word low  QTDS.HeaderPtr],offset Header
	mov     [word high QTDS.HeaderPtr],cs

	pop     es ds
	popad
	ret
endp SelectHz

PROC GetAndProcessNotes
	cmp     [cs:PatternDelay],0
	je      DoPattern
	dec     [cs:PatternDelay]
	ret

DoPattern:
	pushad
	push    fs
	push    ds

	mov     ax,cs
	mov     ds,ax
	mov     fs,[PatternSeg]

	cmp     [NewBufferFlag],2
	jne     DontResetBufferSize
	mov     [NewBufferSize],0
	mov     [NewBufferFlag],0
DontResetBufferSize:
	mov     si,[CurPattern]
	shl     si,10           ;multiply by 1024
	jnc     @@NoOverFlow
	xor     si,si           ;if there's over flow, do pattern #0

@@NoOverFlow:
	mov     ax,[CurNote]
	shl     ax,4            ;multiply by 16
	add     si,ax           ;fs:si now points to the correct note

	mov     di,0            ;points to TRAK structure
	mov     bp,0            ;counts which trak we are on
DoNoteLoop:
	push    bp
	mov     ax,[fs:si]         ;grab first 2 bytes
	mov     cx,[fs:si+2]       ;grab second 2
	
	mov     dh,al
	mov     dl,ah
	and     dh,0fh          ;dx has "NOTE"
	or      dx,dx
	je      @@NullNote
	xchg    [di + TheTraks.Note],dx
	mov     [di + TheTraks.LastNote],dx
@@NullNote:
	mov     dh,al
	mov     dl,cl
	shr     dl,4            ;get lower 4 bits of inst.
	and     dh,00010000b    ;grab 5th bit for inst.
	or      dl,dh           ;dl has instrument

	pop     bp
	push    dx
	xchg    [cs:bp + QTDS.TrakInstNext],dl
	or      dl,dl
	je      @@NoNewFlag
	mov     [cs:bp + QTDS.TrakInstNew],16
@@NoNewFlag:
	mov     dl,[di + TheTraks.sInst]
	inc     dl
	mov     [cs:bp + QTDS.TrakInst],dl
;   cmp     [di + TheTraks.sEnabled],0
;   jne     @@StillHAveInst
;   mov     [cs:bp + QTDS.TrakInst],0
@@StillHAveInst:
	pop     dx
	push    bp

	or      dl,dl
	je      NoNewInstrument     ;if its zero, its a blank
	
	mov     [di + TheTraks.SpecialOn],0   ;new sample- reset specials
	dec     dl                              ;inst is (1-31) need (0-30)
	mov     [di + TheTraks.sInst],dl

	movzx   bx,dl  
	add     bx,bx
	mov     bp,[SampleSegment + bx]
	mov     [di + TheTraks.sseg],bp  ;load in the segment
	mov     bp,[SampleOffset + bx]
	mov     [di + TheTraks.soff],bp  ;load in the offset
	mov     [di + TheTraks.Start],bp

	movzx   bx,dl
	imul    bx,size SampleRec       ;set up to grab repeat info

	mov     bp,[bx + Samples.Length]  ;have length
	add     bp,[di + TheTraks.soff]   ; add start to get end
	;sub     bp,2
	mov     [di + TheTraks.sEnd],bp

	mov     bp,[bx + Samples.Repeat]    ;grab repeat start
	mov     [di + TheTraks.sloops],bp

	mov     bp,[bx + Samples.Replen]    ;get repeat length
	mov     [di + TheTraks.slooplen],bp

	mov     dl,[bx + Samples.Volume]    ;grab vloume
	mov     [di + TheTraks.Svol],dl
	pop     bp
	xchg    dl,[cs:bp + QTDS.OldVolBars]
	mov     [cs:bp + QTDS.VolBars],dl
	push    bp

	push    ax
	mov     dl,[bx + Samples.FineTune]
	mov     [di + TheTraks.FineTune],dl    ;do finetune... yeah right...
	shl     dl,4
	movsx   dx,dl
	sar     dx,3                        ;the *2
	mov     ax,[di + TheTraks.Note]
	imul    dx                          ;finetune*note*2
	mov     al,ah
	mov     ah,dl       ;divide by 256
	sub     [di + TheTraks.Note],ax         ;add in -finetune*note*2/256
	pop     ax

NoNewInstrument:

	mov     dx,cx                       ;grab effect field
	and     dl,0fh                      ;dl = command, dh = XY
;    cmp     [di + TheTraks.SpecialOn],0 ;are specials off?
;    je      @@IsACommand
;    or      dl,dl
;    jne     @@IsACommand
;    or      dh,dh
;    je      @@NullCommand
@@IsACommand:
	mov     [di + TheTraks.cmd],dl         ;store command
	mov     [di + TheTraks.cmdXY],dh       ;store XY
	mov     dl,dh
	and     dl,0fh
	shr     dh,4
	mov     [di + TheTraks.cmdY],dl        ;store Y part (lower 4bits)
	mov     [di + TheTraks.cmdX],dh        ;store X part (upper 4bits)
	mov     [di + TheTraks.SpecialOn],1    ;turn specials on
@@NullCommand:

	;now set the step value => STEP = COUNT / NOTE
	; STEP is 16bits integer, 16bits precision

	mov     eax,[Count]
	xor     edx,edx
	movzx   ebp,[di + TheTraks.Note]
	cmp     ebp,83
	jbe     SkipDivide

	mov     [di + TheTraks.sEnabled],1  ;enable the track
	div     ebp
	mov     [di + TheTraks.sfreq],eax
	mov     [di + TheTraks.stfreq],0

SkipDivide:
	cmp     [di + TheTraks.SpecialOn],0
	je      @@SkipProcessInit
	call    ProcessInitCommands
@@SkipProcessInit:

;all done processing this trak, lets do the rest
	pop     bp
	
	inc     bp
	add     di,size TRAK
	add     si,4
	cmp     di,(size TRAK) * 4
	jb      DoNoteLoop

;now that we've processed this note, lets point to the next one

	inc     [CurNote]           ;increase to next note
	cmp     [CurNote],64
	jb      StillInSamePattern

	mov     [CurNote],0
	inc     [CurSequence]
	mov     ax,[CurSequence]
	cmp     al,[SongLen]
	jb      NotPastEndOfSong

	mov     [CurSequence],0     ;repeat it and go

NotPastEndOfSong:
	mov     bx,[CurSequence]
	movzx   ax,[Sequences + bx]
	mov     [CurPattern],ax

StillInSamePattern:

	pop     ds
	pop     fs
	popad
	ret
ENDP GetAndProcessNotes

UpdateCommand dw offset UpArpegg,  offset UpSlideUp, offset UpSlideDown
	dw     offset UpSlideTo, offset UpVibrato, offset UpSlide2Vol
	dw     offset UpVibVol,  offset UpTremolo, offset AllDoneUpdate
	dw    offset AllDoneUpdate
	dw    offset UpVolSlide, offset AllDoneUpdate,offset AllDoneUpdate
	dw    offset AllDoneUpdate, offset UpExtended,offset AllDoneUpdate

EUpdateCommand dw offset AllDoneUpdate
	dw    offset EUpFineUp,  offset EUpFineDown, offset EUpGlissando
	dw    offset EUpVibWave, offset EUpSetFine,  offset EUpPlayLoop
	dw    offset EUpTremWave,offset AllDoneUpdate, offset EUpRetrig
	dw    offset EUpFVolUp,  offset EUpFVolDown, offset EUpCutShort
	dw    offset EUpDelayNote, offset EUpDelayPattern 
	dw    offset EUpFunkIt

MACRO @FiggureStep     ;in: ebp = Note   out: ebp = step
	push    edx
	mov     eax,[Count]
	xor     edx,edx
	cmp     ebp,83
	jbe     $+5
	div     ebp
	mov     ebp,eax
	pop     edx
ENDM  @FiggureStep
	
	; this is put in a procedure because it is called from many different
	; places
PROC UpdateVolSlide NEAR
	mov     al,[bx + TheTraks.cmdXY]
	mov     dl,[bx + TheTraks.sVol]
	add     dl,al
	cmp     dl,0
	jg      @@VolNotTooLow
	mov     [bx + TheTraks.sVol],0
	xor     dl,dl
	mov     [bx + TheTraks.SpecialOn],0
	ret
@@VolNotTooLow:
	cmp     dl,64
	jle     @@VolNotTooHigh
	mov     dl,64
	mov     [bx + TheTraks.SpecialOn],0
@@VolNotTooHigh:
	mov     [bx + TheTraks.sVol],dl
	ret
ENDP UpdateVolSlide

PROC  InitVolumeSlide NEAR
	mov     al,[di + TheTraks.cmdXY]
	test    al,00001111b
	jz      @@NoVolDown
	neg     al
	mov     [di + TheTraks.cmdXY],al
	add     [di + TheTraks.sVol],al
	ret
@@NoVolDown:
	test    al,11110000b
	jz      @@NoVolUp
	shr     al,4
	mov     [di + TheTraks.cmdXY],al
	add     [di + TheTraks.sVol],al
	ret
@@NoVolUp:
	ret
ENDP InitVolumeSlide

PROC DoGlissando NEAR
	cmp     [bx + TheTraks.GlissFunk],0
	je      @@NoGlissando
	cmp     bp,300
	jbe     @@NoGlissando       ;if its less than 300 then its on a note
	push    si
	mov     si,offset NoteTable
@@DaLoop:
	lodsw
	cmp     ax,bp
	ja      @@DaLoop
	mov     bp,ax
	pop     si
@@NoGlissando:
	ret
ENDP DoGlissando
					
	;Upon return: 
	;       FS:DI must point to the next byte of sample data
	;       CX must be the ending offset for the sample    
	;       DL must be the volume
	;      EBP must be the STEP VALUE
	;
	;    ES:SI must be left unchanged (points into the buffer)
	;   BX cannot be changed: BX = (Trak to update) * (size TRAK)
PROC ProTrackerUpdate
	push BX ES SI
	cmp     [bx + TheTraks.SpecialOn],0   ;see if we are s'posed to do stuff
	je      AllDoneUpdate

	movzx   si,[bx + TheTraks.cmd]   ;range 0-Fh
	and     si,0Fh                ;make sure it's in range
	add     si,si                 ;si = si + si
	jmp     [UpdateCommand + si]

AllDoneUpDate:
	pop SI ES BX
	ret

UpArpegg:
	movzx   ebp,[bx + TheTraks.Note]
	inc     [bx + TheTraks.ArpeggStep]
	mov     al,[bx + TheTraks.ArpeggStep]
	cmp     al,3
	jb      @@ArOk
	xor     al,al
	mov     [bx + TheTraks.ArpeggStep],0
@@ArOk:
	cmp     al,0
	je      @@ArNotex
	cmp     al,1
	je      @@ArNoteY
	@FiggureStep  
	jmp     AllDoneUpdate
@@ArNotex:
	movzx   eax,[bx + TheTraks.cmdX]
	add     ebp,eax
	@FiggureStep
	Jmp     AllDoneUpdate
@@ArNoteY:
	movzx   eax,[bx + TheTraks.cmdY]
	add     ebp,eax
	@FiggureStep
	Jmp     AllDoneUpdate

UpSlideUp:
	xor     ax,ax
	mov     al,[bx + TheTraks.cmdXY]
	sub     [bx + TheTraks.Note],ax
	movzx   ebp,[bx + TheTraks.Note]
	cmp     bp,83
	ja      @@ContSLideUp
	mov     bp,83
@@ContSLideUp:
	mov     [bx + TheTraks.Note],bp

	@FiggureStep

	Jmp     AllDoneUpdate

UpSlideDown:
	xor     ax,ax
	mov     al,[bx + TheTraks.cmdXY]
	add     [bx + TheTraks.Note],ax
	movzx   ebp,[bx + TheTraks.Note]
	and     bp,0FFFh
	cmp     bp,856
	jb      @@ContSlideDown
	mov     bp,856
@@ContSlideDown:
	mov     [bx + TheTraks.Note],bp

	@FiggureStep

	Jmp     AllDoneUpdate

UpSlideTo:
	movzx   ax,[bx + TheTraks.cmdXY]
	and     ax,0ffh
	movzx   ebp,[bx + TheTraks.Note]
	cmp     bp,[bx + TheTraks.WantedNote]
	jb      @@S2Up
	ja      @@S2DN
	mov     [bx + TheTraks.SpecialOn],0
	jmp     AllDoneUpdate
@@S2DN:
	sub     bp,ax
	cmp     bp,[bx + TheTraks.WantedNote]
	ja      @@StillDown
	mov     bp,[bx + TheTraks.WantedNote]
	mov     [bx + TheTraks.SpecialOn],0
@@StillDown:
	cmp     bp,83
	jae     @@NotTooLow
	mov     bp,83
@@NotTooLow:
	cmp     bp,856
	jbe     @@NotTooHi
	mov     bp,856
@@NotTooHi:
	mov     [bx + TheTraks.Note],bp
	call    DoGlissando
	@FiggureStep
	Jmp     AllDoneUpdate
@@S2Up:
	add     bp,ax
	cmp     bp,[bx + TheTraks.WantedNote]
	jb      @@StillUp
	mov     bp,[bx + TheTraks.WantedNote]
	mov     [bx + TheTraks.SpecialOn],0
@@StillUp:
	jmp     @@StillDown

UpVibrato:
	push    dx

	mov     al,[bx + TheTraks.VibratoCMD]
	shr     al,4    ;grab speed
	add     [bx + TheTraks.VibratoPOS],al
	mov     dx,[VibratoSize]
	cmp     [bx + TheTraks.VibratoPOS],dl
	jb      @@NotVibOver
	sub     [bx + TheTraks.VibratoPOS],dl
@@NotVibOver:
	movzx   si,[bx + TheTraks.VibratoPOS]
	add     si,si
	add     si,[VibratoTable]
	mov     dx,[si]
	mov     al,[bx + TheTraks.VibratoCMD]
	and     al,0Fh        ;grab depth
	xor     ah,ah
	imul    dx
	sar     ax,8          ;divide by 128
	movzx   ebp,[bx + TheTraks.VibNote]
	add     bp,ax
	call    DoGlissando
	@FiggureStep

	pop     dx
	Jmp     AllDoneUpdate

UpSlide2Vol:
	call    UpdateVolSlide    
	Jmp     UpSlideTo
UpVibVol:
	call    UpdateVolSlide
	Jmp     UpVibrato
UpTremolo:
	push    dx

	mov     al,[bx + TheTraks.TremoloCMD]
	shr     al,4    ;grab speed
	add     [bx + TheTraks.TremoloPOS],al
	mov     dx,[TremoloSize]
	cmp     [bx + TheTraks.TremoloPOS],dl
	jb      @@NotTremOver
	sub     [bx + TheTraks.TremoloPOS],dl
@@NotTremOver:
	movzx   si,[bx + TheTraks.TremoloPOS]
	add     si,si
	add     si,[TremoloTable]
	mov     dx,[si]
	mov     al,[bx + TheTraks.TremoloCMD]
	and     al,0Fh        ;grab depth
	xor     ah,ah
	imul    dx
	mov     al,[bx + TheTraks.TremVol]
	add     al,ah
	cmp     al,0
	jge     @@TVolnl
	mov     al,0
@@TVolnl:
	cmp     al,64
	jle     @@TVolnh
	mov     al,64
@@TVolnh:
	mov     [bx + TheTraks.sVol],al
	pop     dx
	mov     dl,al
	Jmp     AllDoneUpdate
UpVolSlide:
	call    UpdateVolSlide
	Jmp     AllDoneUpdate
UpExtended:
	movzx   si,[bx + TheTraks.cmdX]  ;range 0-Fh
	and     si,0Fh                ;make sure it's in range
	add     si,si
	jmp     [EUpdateCommand + si]

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Protracker extended commands - Update
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EUpFineUp:   
	jmp     AllDoneUpdate
EUpFineDown:
	jmp     AllDoneUpdate
EUpGlissando:
	jmp     AllDoneUpdate
EUpVibWave:
	jmp     AllDoneUpdate
EUpSetFine:
	jmp     AllDoneUpdate
EUpPlayLoop:
	jmp     AllDoneUpdate
EUpTremWave:
	jmp     AllDoneUpdate
EUpRetrig:
	mov     al,[bx + TheTraks.cmdY]
	cmp     al,[CurTick]
	je      @@ReTrigSample
	jmp     AllDoneUpdate
@@ReTrigSample:
	mov     di,[bx + TheTraks.Start]    ;reset the sample
	mov     [bx + TheTraks.SpecialOn],0
	jmp     AllDoneUpdate
EUpFVolUp:
	jmp     AllDoneUpdate
EUpFVolDown:
	jmp     AllDoneUpdate
EUpCutShort:
	mov     al,[bx + TheTraks.cmdY]
	cmp     al,[CurTick]
	je      @@CutNoteShort
	jmp     AllDoneUpdate
@@CutNoteShort:
	mov     di,cx                       ;cut the note short
	mov     [bx + TheTraks.SpecialOn],0
	jmp     AllDoneUpdate
EUpDelayNote:
	mov     al,[bx + TheTraks.cmdY]
	cmp     al,[CurTick]
	je      @@ShutOffDelay
	jmp     AllDoneUpdate
@@ShutOffDelay:
	mov     [bx + TheTraks.sDelayed],0    ;turn off the delay
	mov     [bx + TheTraks.SpecialOn],0
	jmp     AllDoneUpdate
EUpDelayPattern:
	jmp     AllDoneUpdate
EUpFunkIt:
	jmp     AllDoneUpdate

ENDP ProTrackerUpdate

InitCommand dw offset InArpegg, offset InSlideUp, offset InSlideDown
		dw    offset InSlideTo, offset InVibrato, offset InSlide2Vol
		dw    offset InVibVol,  offset InTremolo, offset InStereoVol
		dw    offset InSetSampOff
		dw    offset InVolSlide,offset InPosJump, offset InSetVolume
		dw    offset InPattBrk, offset InExtended,offset InSetSpeed

EInitCommand dw offset AllDoneInit
		dw    offset EInFineUp,   offset EInFineDown, offset EInGlissando
		dw    offset EInVibWave,  offset EInSetLoop,  offset EInPlayLoop
		dw    offset EInTremWave, offset AllDoneInit, offset EInRetrig
		dw    offset EInFVolUp,   offset EInFVolDown, offset EInCutShort
		dw    offset EInDelayNote,offset EInDelayPattern 
		dw    offset EInFunkIt

	;DI = index into TheTraks
PROC ProcessInitCommands Near
	pushad
	movzx   si,[di + TheTraks.cmd]   ;range 0-Fh
	and     si,0Fh                ;make sure it's in range
	add     si,si
	jmp     [InitCommand + si]
AllDoneInit:
	popad
	ret

InStereoVol:
	movzx   si,[di + TheTraks.CMDXY]
	add     si,si
	mov     ax,[StereoChart + si]
	mov     [di + TheTraks.PLeftVol],ax

	movzx   ax,[di + TheTraks.CMDXY]
	inc     al
	neg     al
	mov     si,ax
	add     si,si
	mov     ax,[StereoChart + si]
	mov     [di + TheTraks.PRightVol],ax
	jmp     AllDoneInit

InArpegg:
	cmp     [di + TheTraks.cmdXY],0
	jne     @@NotNullCommand
	mov     [di + TheTraks.SpecialOn],0
@@NotNullCommand:
	Jmp     AllDoneInit
InSlideUp:

	Jmp     AllDoneInit
InSlideDown:
	Jmp     AllDoneInit

InSlideTo:
	mov     ax,[di + TheTraks.Note]
	or      ax,ax
	je      @@NOTHING
	mov     [di + TheTraks.WantedNote],ax   ;fill in wanted note
	mov     ax,[di + TheTraks.LastNote]
	mov     [di + TheTraks.Note],ax         ;restore last note
	Jmp     AllDoneInit
@@NOTHING:
	mov     [di + TheTraks.SpecialOn],0
	Jmp     AllDoneInit

InVibrato:
	mov     ax,[di + TheTraks.Note]         ;vib note is the base...
	mov     [di + TheTraks.VibNote],ax
	mov     al,[di + TheTraks.cmdXY]
	mov     [di + TheTraks.VibratoCMD],al
	mov     [di + TheTraks.VibratoPOS],0
	Jmp     AllDoneInit

InSlide2Vol:
	call    InitVolumeSlide
	Jmp     AllDoneInit         ;do NOT reinit the Vib

InVibVol:
	call    InitVolumeSlide
	Jmp     AllDoneInit         ;do NOT reinitialize the slide

InTremolo:
	mov     al,[di + TheTraks.sVol]         ;vib note is the base...
	mov     [di + TheTraks.TremVol],al
	mov     al,[di + TheTraks.cmdXY]
	mov     [di + TheTraks.TremoloCMD],al
	mov     [di + TheTraks.TremoloPOS],0
	Jmp     AllDoneInit

InSetSampOff:
	mov     al,[di + TheTraks.cmdXY]
	shl     ax,8
	add     [di + TheTraks.soff],ax
	mov     [di + TheTraks.SpecialOn],0
	Jmp     AllDoneInit

InVolSlide:
	call    InitVolumeSlide
	Jmp     AllDoneInit

InPosJump:
	mov     [CurNote],64
	movzx   ax,[di + TheTraks.cmdXY]
	dec     ax
	mov     [CurSequence],ax
	mov     [di + TheTraks.SpecialOn],0
	Jmp     AllDoneInit

InSetVolume:
	mov     al,[di + TheTraks.CmdXY]
	cmp     al,64
	jbe     @@VolOk
	mov     al,64
@@VolOk:
	mov     [di + TheTraks.sVol],al
	mov     [di + TheTraks.SpecialOn],0
	Jmp     AllDoneInit
InPattBrk:  
	mov     [CurNote],64    ;reset to note 0
	mov     [di + TheTraks.SpecialOn],0
	jmp     AllDoneInit

InExtended:
	; jmp     AllDoneInit

	movzx   si,[di + TheTraks.cmdX]  ;range 0-Fh
	and     si,0Fh                ;make sure it's in range
	add     si,si
	jmp     [EInitCommand + si]
	
InSetSpeed:
	mov     [di + TheTraks.SpecialOn],0
	xor     ah,ah
	mov     al,[di + TheTraks.cmdXY]       ;range 0-1Fh are legal speeds
	cmp     al,1fh
	ja      @@BPMSpeed
	mov     [SongSpeed],ax
	mov     dx,[BytesPer50th]
	mov     [BytesPerTick],dx
	mul     dx
	mov     [NEWBuffersize],ax
	mov     [NewBufferFlag],0
	mov     ax,750
	mov     dx,[SongSpeed]
	cmp     dx,3
	jbe     @@SkipDiv
	div     dl
@@SkipDiv:
	xor     ah,ah
	mov     [BPMSpeed],ax
	Jmp     AllDoneInit
@@BPMSpeed:
	push    cx

	mov     dl,al
	mov     [BPMSpeed],ax
	mov     ax,750
	cmp     dl,5
	jbe     @@SskipD
	div     dl
@@SskipD:
	xor     ah,ah
	mov     [SongSpeed],ax  ;=750/BPM

	mov     ax,750
	mov     dx,[BytesPerTick]
	mul     dx
	movzx   cx,[di + TheTraks.cmdXY]
	cmp     cx,5
	jbe     @@SkipDis
	div     cx

	mov     [NewBufferSize],ax
	mov     [NewBufferFlag],0
@@SkipDis:
	pop     cx
	jmp     AllDoneInit

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Protracker extended commands- Init
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

EInFineUp:
	movzx   ax,[di + TheTraks.cmdY]
	sub     [di + TheTraks.NOTE],ax
	mov     eax,[Count]
	xor     edx,edx
	movzx   ebp,[di + TheTraks.Note]
	cmp     ebp,83
	jbe     @@EinOk
	div     ebp
	mov     [di + TheTraks.sfreq],eax
@@EinOk:
	jmp     AllDoneInit
EInFineDown:
	movzx   ax,[di + TheTraks.cmdY]
	add     [di + TheTraks.NOTE],ax
	mov     eax,[Count]
	xor     edx,edx
	movzx   ebp,[di + TheTraks.Note]
	cmp     ebp,83
	jbe     @@EinOk
	div     ebp
	mov     [di + TheTraks.sfreq],eax
	jmp     AllDoneInit
EInGlissando:
	mov     al,[di + TheTraks.cmdY]
	and     al,1
	mov     [di + TheTraks.GlissFunk],al
	jmp     AllDoneInit
EInVibWave:
	mov     [di + TheTraks.SpecialOn],0
	mov     al,[di + TheTraks.cmdY]
	and     al,3
	cmp     al,1
	je      @@SetVRampDn
	cmp     al,2
	je      @@SetVSquare
	mov     [VibratoTable],offset SineWaveTable
	mov     [VibratoSize],SineWaveSize
	jmp     AllDoneInit
@@SetVrampDn:
	mov     [VibratoTable],offset RampDnWaveTable
	mov     [VibratoSize],RampDnWaveSize
	jmp     AllDoneInit
@@SetVSquare:
	mov     [VibratoTable],offset SquareWaveTable
	mov     [VibratoSize],SquareWaveSize
	jmp     AllDoneInit

EInSetLoop:
	mov     [di + TheTraks.SpecialOn],0
;    cmp     [di + TheTraks.LoopCount],0     ;if we are in a loop, dont set..
;    jne     @@SkipSet
	mov     ax,[CurNote]
	mov     [di + TheTraks.LoopPos],al
@@SkipSet:
	jmp     AllDoneInit

EInPlayLoop:
	mov     [di + TheTraks.SpecialOn],0
	cmp     [di + TheTraks.LoopCount],0     ;if we are in a loop, dont set..
	jne     @@SkipSet2
	mov     al,[di + TheTraks.cmdY]
	cmp     al,0
	je      EInSetLoop
	inc     al
	mov     [di + TheTraks.LoopCount],al
@@SkipSet2:
	dec     [di + TheTraks.LoopCount]
	je      @@Skip33
	movzx   ax,[di + TheTraks.LoopPos]
	mov     [CurNote],ax
@@Skip33:
	jmp     AllDoneInit

EInTremWave:
	mov     [di + TheTraks.SpecialOn],0
	mov     al,[di + TheTraks.cmdY]
	and     al,3
	cmp     al,1
	je      @@SetTRampDn
	cmp     al,2
	je      @@SetVSquare
	mov     [TremoloTable],offset SineWaveTable
	mov     [TremoloSize],SineWaveSize
	jmp     AllDoneInit
@@SetTrampDn:
	mov     [TremoloTable],offset RampDnWaveTable
	mov     [TremoloSize],RampDnWaveSize
	jmp     AllDoneInit
@@SetTSquare:
	mov     [TremoloTable],offset SquareWaveTable
	mov     [TremoloSize],SquareWaveSize
	jmp     AllDoneInit

EInRetrig:
	jmp     AllDoneInit
EInFVolUp:
	mov     al,[di + TheTraks.cmdY]
	add     [di + TheTraks.sVol],al
	cmp     [di + TheTraks.sVol],64
	jle     @@FvolUPok
	mov     [di + TheTraks.sVol],64
@@FvolUpOk:
	mov     [di + TheTraks.SpecialOn],0
	jmp     AllDoneInit
EInFVolDown:
	mov     al,[di + TheTraks.cmdY]
	sub     [di + TheTraks.sVol],al
	cmp     [di + TheTraks.sVol],0
	jge     @@Fvoldnok
	mov     [di + TheTraks.sVol],0
@@Fvoldnok:
	mov     [di + TheTraks.SpecialOn],0
	jmp     AllDoneInit
EInCutShort:
	jmp     AllDoneInit
EInDelayNote:
	mov     [di + TheTraks.sDelayed],1
	jmp     AllDoneInit
EInDelayPattern:
	mov     al,[di + TheTraks.cmdY]
	mov     [PatternDelay],al
	mov     [di + TheTraks.SpecialOn],0
	jmp     AllDoneInit
EInFunkIt:
	jmp     AllDoneInit

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ENDP ProcessInitCommands

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   The little update routines...
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	;IN: BX = (Trak to update) * (size TRAK)
PROC    UpdateTrakMONO  ;called to update the traks
	pushad
	push    ds
	push    es
	push    fs
	push    gs

	mov     ax,cs
	mov     ds,ax
	mov     ax,[BufferSeg]
	mov     es,ax

	mov     ax,[BytesPerTick]
	inc     ax
	mov     [BPTCounter],ax
	mov     ax,[SongSpeed]
	mov     [TickCounter],ax
	mov     [CurTick],0

	mov     si,[CurOff]             ;es:si is pointer to buffer
	mov     cx,[CurBuffSize]        ;TmpCurBuffSize is the length
	;inc     cx
	mov     [TmpCurBuffSize],cx

	mov     fs,[bx + TheTraks.sseg] ;fs:di is pointer to Sample data
	xor     edi,edi
	mov     di,[bx + TheTraks.soff]
	mov     cx,[bx + TheTraks.send] ;cx is ending offset of sample
	mov     ebp,[bx+ TheTraks.sfreq]    ;step for note
	mov     dl,[bx + TheTraks.svol] ;dl is volume

@@DelayedLoop:
	cmp     [bx + TheTraks.sdelayed],0
	je      @@TheLoop           ;check if we are delaying this trak...
	mov     ax,[BPTCounter]
	add     si,ax
	sub     [TmpCurBuffSize],ax
	jbe     @@EndOfUpdate

	call    ProTrackerUpdate

	inc     [CurTick]
	jmp     @@DelayedLoop
	
@@TheLoop:
	mov     al,[fs:di]
	imul    dl
	add     [es:si],ah      ;do one note
	
	ror     edi,16          ;increase the pointer
	add     edi,ebp
	rol     edi,16
	cmp     di,cx
	jae     @@HandleEndOfSample

@@BackFromEOS:
	inc     si
	dec     [TmpCurBuffSize]
	je      @@EndOfUpdate
	dec     [BPTCounter]
	jne     @@TheLoop

	call    ProTrackerUpdate

	mov     ax,[BytesPerTick]
	inc     ax
	mov     [BPTCounter],ax
	inc     [CurTick]
	jmp     @@TheLoop

@@EndOfUpdate:
	mov     [bx + TheTraks.soff],di
	mov     [bx + TheTraks.send],cx     ;cx is ending offset of sample
	mov     [bx+ TheTraks.sfreq],ebp    ;step for note
	mov     [bx + TheTraks.svol],dl     ;dl is volume
	
	pop     gs 
	pop     fs
	pop     es
	pop     ds
	popad
	ret
	
@@HandleEndOfSample:
	cmp     [bx + TheTraks.slooplen],0
	jne     @@DoARepeat
	mov     [bx + TheTraks.sEnabled],0  ;disable the track
	mov     [bx + TheTraks.sVol],0      ;disable the track
	;mov     [bx + TheTraks.sInst],0     ;clear out the inst
	jmp     @@EndOfUpdate
@@DoARepeat:
	mov     di,[bx + TheTraks.sloops]   ;start of loop
	add     di,[bx + TheTraks.Start]
	mov     cx,[bx + TheTraks.slooplen]
	add     cx,di                       ;set up ending address
	jmp     @@BackFromEOS

ENDP    UpdateTrakMONO

	;IN: BX = (Trak to update) * (size TRAK)
PROC    UpdateTrakStereo  ;called to update the traks
	pushad
	push    ds
	push    es
	push    fs
	push    gs

	mov     ax,cs
	mov     ds,ax
	mov     ax,[BufferSeg]
	mov     es,ax

	mov     ax,[BytesPerTick]
	inc     ax
	mov     [BPTCounter],ax
	mov     ax,[SongSpeed]
	mov     [TickCounter],ax
	mov     [CurTick],0

	mov     si,[CurOff]             ;es:si is pointer to buffer
	mov     cx,[CurBuffSize]        ;TmpCurBuffSize is the length
	;inc     cx
	;inc     cx
	mov     [TmpCurBuffSize],cx

	mov     fs,[bx + TheTraks.sseg] ;fs:di is pointer to Sample data
	xor     edi,edi
	mov     di,[bx + TheTraks.soff]
	mov     cx,[bx + TheTraks.send]     ;cx is ending offset of sample
	mov     ebp,[bx+ TheTraks.sfreq]    ;step for note

	mov     dl,[bx + TheTraks.svol]     ;dl is main volume for trak
	xor     dh,dh
	mov     ax,[bx + TheTraks.PLeftVol]
	mul     dx
	mov     [bx + TheTraks.LVol],ah
	mov     dl,[bx + TheTraks.svol]     ;dl is main volume for trak
	xor     dh,dh
	mov     ax,[bx + TheTraks.PRightVol]
	mul     dx
	mov     [bx + TheTraks.RVol],ah
	mov     dh,ah                       ;dh = right volume
	mov     dl,[bx + TheTraks.LVol]     ;dl = left volume

@@DelayedLoop:
	cmp     [bx + TheTraks.sdelayed],0
	je      @@TheLoop           ;check if we are delaying this trak...
	mov     ax,[BPTCounter]
	add     si,ax
	sub     [TmpCurBuffSize],ax
	jbe     @@EndOfUpdate

	call    ProTrackerUpdate

	inc     [CurTick]
	jmp     @@DelayedLoop
	
@@TheLoop:
	mov     al,[fs:di]
	imul    dl
	add     [es:si],ah      ;do left trak
	mov     al,[fs:di]
	imul    dh
	add     [es:si+1],ah    ;and the right one
	
	ror     edi,16          ;increase the pointer
	add     edi,ebp
	rol     edi,16
	cmp     di,cx
	jae     @@HandleEndOfSample

@@BackFromEOS:
	inc     si
	inc     si
	sub     [TmpCurBuffSize],2
	jle     @@EndOfUpdate
	dec     [BPTCounter]
	jne     @@TheLoop

	mov     dl,[bx + TheTraks.svol]     ;dl is volume

	call    ProTrackerUpdate
	
	mov     [bx + TheTraks.svol],dl     ;dl is main volume for trak
	xor     dh,dh
	mov     ax,[bx + TheTraks.PLeftVol]
	mul     dx
	mov     [bx + TheTraks.LVol],ah
	mov     dl,[bx + TheTraks.svol]     ;dl is main volume for trak
	xor     dh,dh
	mov     ax,[bx + TheTraks.PRightVol]
	mul     dx
	mov     [bx + TheTraks.RVol],ah
	mov     dh,ah                       ;dh = right volume
	mov     dl,[bx + TheTraks.LVol]     ;dl = left volume

	mov     ax,[BytesPerTick]
	inc     ax
	mov     [BPTCounter],ax
	inc     [CurTick]
	jmp     @@TheLoop

@@EndOfUpdate:
	mov     [bx + TheTraks.soff],di
	mov     [bx + TheTraks.send],cx     ;cx is ending offset of sample
	mov     [bx+ TheTraks.sfreq],ebp    ;step for note
	;mov     [bx + TheTraks.svol],dl     ;dl is volume

	pop     gs 
	pop     fs
	pop     es
	pop     ds
	popad
	ret
	
@@HandleEndOfSample:
	cmp     [bx + TheTraks.slooplen],0
	jne     @@DoARepeat
	mov     [bx + TheTraks.sEnabled],0  ;disable the track
	mov     [bx + TheTraks.sVol],0      ;disable the track
	jmp     @@EndOfUpdate
@@DoARepeat:
	mov     di,[bx + TheTraks.sloops]   ;start of loop
	add     di,[bx + TheTraks.Start]
	mov     cx,[bx + TheTraks.slooplen]
	add     cx,di                       ;set up ending address
	jmp     @@BackFromEOS

ENDP    UpdateTrakStereo

	;IN: BX = (Trak to update) * (size TRAK)
PROC    UpdateTrakLEFT  ;called to update the traks
	pushad
	push    ds
	push    es
	push    fs
	push    gs

	mov     ax,cs
	mov     ds,ax
	mov     ax,[BufferSeg]
	mov     es,ax

	mov     ax,[BytesPerTick]
	inc     ax
	mov     [BPTCounter],ax
	mov     ax,[SongSpeed]
	mov     [TickCounter],ax
	mov     [CurTick],0

	mov     si,[CurOff]             ;es:si is pointer to buffer
	mov     cx,[CurBuffSize]        ;TmpCurBuffSize is the length
	;inc     cx
	;inc     cx
	mov     [TmpCurBuffSize],cx

	mov     fs,[bx + TheTraks.sseg] ;fs:di is pointer to Sample data
	xor     edi,edi
	mov     di,[bx + TheTraks.soff]
	mov     cx,[bx + TheTraks.send] ;cx is ending offset of sample
	mov     ebp,[bx+ TheTraks.sfreq]    ;step for note
	mov     dl,[bx + TheTraks.svol] ;dl is volume

@@DelayedLoop:
	cmp     [bx + TheTraks.sdelayed],0
	je      @@TheLoop           ;check if we are delaying this trak...
	mov     ax,[BPTCounter]
	add     si,ax
	sub     [TmpCurBuffSize],ax
	jbe     @@EndOfUpdate

	call    ProTrackerUpdate

	inc     [CurTick]
	jmp     @@DelayedLoop
	
@@TheLoop:
	mov     al,[fs:di]
	imul    dl
	add     ax,ax
	add     [es:si+1],ah      ;do one note
	
	ror     edi,16          ;increase the pointer
	add     edi,ebp
	rol     edi,16
	cmp     di,cx
	jae     @@HandleEndOfSample

@@BackFromEOS:
	inc     si
	inc     si
	;dec     [TmpCurBuffSize]
	sub     [TmpCurBuffSize],2
	jle     @@EndOfUpdate
	dec     [BPTCounter]
	jne     @@TheLoop

	call    ProTrackerUpdate

	mov     ax,[BytesPerTick]
	inc     ax
	mov     [BPTCounter],ax
	inc     [CurTick]
	jmp     @@TheLoop

@@EndOfUpdate:
	mov     [bx + TheTraks.soff],di
	mov     [bx + TheTraks.send],cx     ;cx is ending offset of sample
	mov     [bx+ TheTraks.sfreq],ebp    ;step for note
	mov     [bx + TheTraks.svol],dl     ;dl is volume

	pop     gs 
	pop     fs
	pop     es
	pop     ds
	popad
	ret
	
@@HandleEndOfSample:
	cmp     [bx + TheTraks.slooplen],0
	jne     @@DoARepeat
	mov     [bx + TheTraks.sEnabled],0  ;disable the track
	mov     [bx + TheTraks.sVol],0      ;disable the track
	jmp     @@EndOfUpdate
@@DoARepeat:
	mov     di,[bx + TheTraks.sloops]   ;start of loop
	add     di,[bx + TheTraks.Start]
	mov     cx,[bx + TheTraks.slooplen]
	add     cx,di                       ;set up ending address
	jmp     @@BackFromEOS

ENDP    UpdateTrakLEFT

	;IN: BX = (Trak to update) * (size TRAK)
PROC    UpdateTrakRIGHT  ;called to update the traks
	pushad
	push    ds
	push    es
	push    fs
	push    gs

	mov     ax,cs
	mov     ds,ax
	mov     ax,[BufferSeg]
	mov     es,ax

	mov     ax,[BytesPerTick]
	inc     ax
	mov     [BPTCounter],ax
	mov     ax,[SongSpeed]
	mov     [TickCounter],ax
	mov     [CurTick],0

	mov     si,[CurOff]             ;es:si is pointer to buffer
	mov     cx,[CurBuffSize]        ;TmpCurBuffSize is the length
	;inc     cx
	;inc     cx
	mov     [TmpCurBuffSize],cx

	mov     fs,[bx + TheTraks.sseg] ;fs:di is pointer to Sample data
	xor     edi,edi
	mov     di,[bx + TheTraks.soff]
	mov     cx,[bx + TheTraks.send] ;cx is ending offset of sample
	mov     ebp,[bx+ TheTraks.sfreq]    ;step for note
	mov     dl,[bx + TheTraks.svol] ;dl is volume

@@DelayedLoop:
	cmp     [bx + TheTraks.sdelayed],0
	je      @@TheLoop           ;check if we are delaying this trak...
	mov     ax,[BPTCounter]
	add     si,ax
	sub     [TmpCurBuffSize],ax
	jbe     @@EndOfUpdate

	call    ProTrackerUpdate

	inc     [CurTick]
	jmp     @@DelayedLoop
	
@@TheLoop:
	mov     al,[fs:di]
	imul    dl
	add     ax,ax
	add     [es:si],ah      ;do one note
	
	ror     edi,16          ;increase the pointer
	add     edi,ebp
	rol     edi,16
	cmp     di,cx
	jae     @@HandleEndOfSample

@@BackFromEOS:
	inc     si
	inc     si
	;dec     [TmpCurBuffSize]
	sub     [TmpCurBuffSize],2
	jle     @@EndOfUpdate
	dec     [BPTCounter]
	jne     @@TheLoop

	call    ProTrackerUpdate

	mov     ax,[BytesPerTick]
	inc     ax
	mov     [BPTCounter],ax
	inc     [CurTick]
	jmp     @@TheLoop

@@EndOfUpdate:
	mov     [bx + TheTraks.soff],di
	mov     [bx + TheTraks.send],cx     ;cx is ending offset of sample
	mov     [bx+ TheTraks.sfreq],ebp    ;step for note
	mov     [bx + TheTraks.svol],dl     ;dl is volume

	pop     gs 
	pop     fs
	pop     es
	pop     ds
	popad
	ret
	
@@HandleEndOfSample:
	cmp     [bx + TheTraks.slooplen],0
	jne     @@DoARepeat
	mov     [bx + TheTraks.sEnabled],0  ;disable the track
	mov     [bx + TheTraks.sVol],0      ;disable the track
	jmp     @@EndOfUpdate
@@DoARepeat:
	mov     di,[bx + TheTraks.sloops]   ;start of loop
	add     di,[bx + TheTraks.Start]
	mov     cx,[bx + TheTraks.slooplen]
	add     cx,di                       ;set up ending address
	jmp     @@BackFromEOS

ENDP    UpdateTrakRIGHT

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; call this routine constantly to keep the mod playing correctly
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

PROC  MainUpdate NEAR     ;the routine that gets called all the time
	pushf
	cmp     [cs:WhichBuffer],3
	je      LetsDoit3
	CMP     [cs:WhichBuffer],4
	je      LetsDoit4
	popf
	ret

LetsDoit3:
	pushad
	push    es ds fs gs

	mov     ax,cs
	mov     ds,ax
	mov     es,ax

	mov     ax,[cs:BufferOffset1]
	mov     [cs:CurOff],ax
	
	cmp     [cs:NewBufferSize],0
	je      SkipNewSize
	mov     ax,[cs:NewBuffersize]
	mov     [cs:Buffer1Size],ax
	call    CalcForDma
	inc     [cs:NewBufferFlag]
Skipnewsize:
	mov     ax,[cs:Buffer1Size]
	mov     [cs:CurBuffSize],ax
	jmp     UpdateItNow

Letsdoit4:
	pushad
	push    es ds fs gs
	mov     ax,cs
	mov     ds,ax
	mov     es,ax

	mov     ax,[cs:BufferOffset2]
	mov     [cs:CurOff],ax
	
	cmp     [cs:NewBufferSize],0
	je      SkipNewSize2
	mov     ax,[cs:NewBuffersize]
	mov     [cs:Buffer2Size],ax
	call    CalcForDma
	inc     [cs:NewBufferFlag]
SkipNewSize2:
	mov     ax,[cs:Buffer2Size]
	mov     [cs:CurBuffSize],ax

Updateitnow:
	mov     ax,cs
	mov     ds,ax
	mov     es,ax
	add     [WhichBuffer],2
	cld

	mov     es,[BufferSeg]      ;clear out buffer
	mov     di,[CurOff]
	mov     cx,[CurBuffSize]
	mov     ax,8080h
	add     cx,4
	shr     cx,1
	rep     stosw
	
	mov     bp,0                ;start on trak 0
	mov     bx,0
MainUpdateLoop:
	cmp     [bx + TheTraks.senabled],0
	je      @@SkipThisTrak

	call    [cs:UpdateRoutine + bp]

@@SkipThisTrak:
	add     bx,size TRAK
	add     bp,2
	cmp     bp,8
	jb      MainUpdateLoop
	
;SoundFXLoop:
;  cmp     [bx + TheTraks.senabled],0
;  je      @@SkipThisTrak2
;  call    UpdateFXTrak

;@@SkipThisTrak2:
;  add     bx,size TRAK
;  inc     bp
;  cmp     bp,6
;  jb      SoundFXLoop

	;Do mainvolume now...
	cmp     [cs:MasterVolume],256
	je      SkipMasterVolume

	pusha
	mov     ds,[cs:BufferSeg]
	mov     di,[cs:CurOff]
	mov     cx,[cs:CurBuffSize]
	mov     bx,[cs:MasterVolume]   ;bx = 0 - 255
MasterVolumeLoop:
	mov     al,[byte di]
	sub     al,128
	cbw
	imul    bx
	add     ah,128
	mov     [di],ah
	inc     di
	dec     cx
	jne     MasterVolumeLoop
	popa

SkipMasterVolume:

	call    GetAndProcessNotes

	pop    gs fs ds es
	popad
	popf
	ret
ENDP MainUpdate

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 
; Routines that load in the MOD starting at [BaseModSeg]  
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; LoadModule - Load in the module pointed to by DS:DX.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Handle  dw  0

MadeITtoHere db "made it past the load...$"
MadeITtoHere2 db "failed to open the file...$"

proc    LoadModule NEAR
		pusha
		
		mov     ax,3D00h        ;open the file
		int     21h
		jc      @@Error

		mov     [cs:Handle],ax
		mov     ax,cs
		mov     ds,ax
		mov     es,ax

		call    ReadMod

		mov     ax,3E00h        ;close the file
		mov     bx,[cs:Handle]
		int     21h

;    push    cs
;    pop     ds
;    mov     ah,9
;    mov     dx,offset MadeItToHere
;    int     21h
		
		popa
		xor     ax,ax
		ret

@@Error:
;    push    cs
;    pop     ds
;    mov     ah,9
;    mov     dx,offset MadeItToHere2
;    int     21h

		popa
		mov     ax,-1
		ret
endp    LoadModule

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; LoadInSample - Loads in a sample and does whatever with it
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;in: CX - Sample Size in bytes
;out: CX - segment it was put in

proc    LoadInSample NEAR
		pusha

		mov     bx,[cs:Handle]
		xor     dx,dx           ;load at offset 0
		mov     ds,[cs:CurSegPtr]
		mov     ax,3F00h        ; Load in the sample
		int     21h

		popa

		mov     ax,cx
		shr     ax,4    ;change size into a segmnet
		inc     ax      ;just in case
		mov     cx,[cs:CurSegPtr]
		add     [cs:CurSegPtr],ax

		ret
endp    LoadInSample

;²ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ²
; s_ReadMod - Read the header, all patterns, and all samples from module.
;²ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ²

pastloadpatt db "made it past load patterns$"
pastloadsamp db "made it past load samples$"

PROC    ReadMod NEAR
		pusha

		mov     ax,cs
		mov     ds,ax

		mov     ax,3F00h        ; Read the header
		mov     bx,[cs:Handle]
		mov     dx,offset Header
		mov     cx,HeaderSize
		int     21h

		call    LoadPatterns

;    push    cs
;    pop     ds
;    mov     ah,9
;    mov     dx,offset pastloadpatt
;    int     21h

		mov     cx,31           ;FIX all the samples
		mov     bx,offset samples+(offset (SampleRec).Length)
@@FlipLoop:
		mov     ax,[cs:bx]      ; Flip length
		xchg    ah,al
		shl     ax,1
		mov     [cs:bx],ax
		mov     ax,[cs:bx+4]    ; Flip repeat
		xchg    ah,al
		shl     ax,1
		mov     [cs:bx+4],ax
		mov     ax,[cs:bx+6]    ; Flip repeat length
		xchg    ah,al
		shl     ax,1
		cmp     ax,2
		jne     @@Not2
		xor     ax,ax
@@Not2:
		mov     [cs:bx+6],ax
		add     bx,size SampleRec
		loop    @@FlipLoop

		mov     cx,31
		mov     bx,offset samples+(offset (SampleRec).Length)

		mov     si,0            ;used to store segments for samples
@@DoSamples:    
		push    cx
		mov     ax,[cs:bx]      ;grab the lenght.. is it zero?
		or      ax,ax
		jz      @@Bottom
		mov     cx,ax           ; Save for read from disk. cx= length

		call    LoadInSample
		mov     [cs:SampleSegment+si],cx
		mov     gs,cx
		mov     [cs:SampleOffset+si],0
		mov     di,0
		cmp     [byte gs:di],0
		je      @@NoFrontClick
		cmp     [byte gs:di],0FFh
		je      @@NoFrontClick
		sar     [byte gs:di+0],3    ;gets rid of beginning click
		sar     [byte gs:di+1],2
		sar     [byte gs:di+2],1
@@NoFrontClick:
		add     di,[cs:bx]      ;the length
		cmp     [byte gs:di],0
		je      @@Bottom
		cmp     [byte gs:di],0FFh
		je      @@Bottom
		sar     [byte gs:di-2],1    ;gets rid of ending click
		sar     [byte gs:di-1],2
		sar     [byte gs:di-0],3
@@Bottom:
		add     bx,size SampleRec
		add     si,2
		pop     cx
		loop    @@DoSamples

;    push    cs
;    pop     ds
;    mov     ah,9
;    mov     dx,offset pastloadsamp
;    int     21h

		popa
		ret
endp    ReadMod

proc    GetHighestBlock NEAR
		pusha
		push    cs
		pop     ds
		mov     si,offset sequences
		mov     cx,128
		xor     ax,ax
@@SetBlock: 
		mov     ah,al
		jmp     @@BotLoop
@@SearchLoop:   
		lodsb
		cmp     al,ah
		jg      @@SetBlock
@@BotLoop:  
		loop    @@SearchLoop
		mov     al,ah
		inc     al
		xor     ah,ah                   ; Clear ah.
		mov     [cs:NumPatterns],ax
		popa
		ret
endp    GetHighestBlock

PROC    LoadPatterns NEAR
		pusha

		mov     ax,[cs:CurSegPtr]
		mov     [cs:PatternSeg],ax

		call    GetHighestBlock

		mov     cx,[cs:NumPatterns]
		shl     cx,10       ;cx = ax*1024 -# bytes to read in for patterns
		mov     ax,cx
		shr     ax,4        ;ax = num paragraphs patterns will take
		inc     ax          ;just in case
		add     [cs:CurSegPtr],ax   ;'reserve' the memory

		mov     bx,[cs:Handle]
		xor     dx,dx           ;load at offset 0
		mov     ds,[cs:PatternSeg]
		mov     ax,3F00h        ; Load in all the patterns...
		int     21h

		popa
		ret
endp    LoadPatterns

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   Keyboard routines
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

PROC CheckKey NEAR
	mov  ah,1
	int  16h
	jz   NoCheckKey
	mov  ah,0
	int  16h
	ret
NoCheckKey:
	xor  ax,ax
	ret
ENDP CheckKey

	oldintoff       dw      0
	oldintseg       dw      0
	keypress        db      0

PROC DoInt   NEAR
	pusha
	mov     ah,35h
	mov     al,15h
	int     21h
	mov     [cs:oldintoff],bx
	mov     [cs:oldintseg],es
	mov     al,15h
	mov     ah,25h
	mov     dx,offset keybdint
	mov     bx,@code
	mov     ds,bx
	int     21h
	popa
	ret
ENDP DoInt

PROC UndoInt NEAR
	pusha
	mov     dx,[cs:oldintoff]
	mov     ax,[cs:oldintseg]
	mov     ds,ax
	mov     al,15h
	mov     ah,25h
	int     21h
	popa
	ret
ENDP UndoInt

keybdint:
	cmp     ah,4fh
	jne     noint
	PUSHA
	mov     bx,@code
	mov     ds,bx
	mov     [ds:keypress],al
	mov     al,7
isesc:
	stc
	popa
	iret
noint:
	jmp    [dword cs:oldintoff]

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Delay - wait for BX verticle retraces
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	;bx= number of screen updates to wait
PROC Delay
	pusha

	mov     dx,03dah
vr12:   
	in      al,dx
	test    al,08
	jz      vr12
Nvr12:   
	in      al,dx
	test    al,08
	jz      Nvr12

	dec     bx
	jne     vr12
	popa
	ret
ENDP delay

;  struc SampleRec
;    SName       db  22 dup (?)
;    Length      dw  ?
;    FineTune    db  ?
;    Volume      db  ?
;    Repeat      dw  ?
;    RepLen      dw  ?
;  ends  SampleRec

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   Misc subroutines for initializing
; and terminating play...
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

PROC Mute NEAR
	call    TurnOffSpeaker
	ret
ENDP Mute

PROC UnMute NEAR 
	call    TurnOnSpeaker
	ret
ENDP UnMute 

ReallyFailed db "Yup there's really a load error..$"

PROC StartPlaying NEAR
	pusha
	push    ds es
	push    dx

	mov     ax,cs
	mov     ds,ax
	mov     es,ax
	
	mov     bx,[BaseModSeg]
	mov     [BufferSeg],bx
	mov     [word high cs:QTDS.CurBuffPtr],bx

	add     bx,(MaxBuffSize * 2) / 16 + 2   ;size of both buffers combined
	mov     [CurSegPtr],bx
	
	mov     [Buffer1Size],BUFFSIZE
	mov     [Buffer2Size],BUFFSIZE

	mov     [BufferOffset1],0
	mov     [BufferOffset2],MaxBuffSize

	push    es
	mov     es,[BufferSeg]
	mov     di,0
	mov     cx,MaxBuffSize
	mov     ax,8080h
	cld
	rep     stosw
	pop     es

	pop     dx
	call    LoadModule
	
	or      ax,ax           ;if ax=0 then load was successful
	je      TestSound

ERROR:
	
	push    cs
	pop     ds
	mov     dx,offset ReallyFailed
	mov     ah,9
	int     21h

	pop     es ds
	popa
	mov     ax,-1           ;says Hey, I failed. (-1 = file error)
	ret

TESTSOUND:
	mov     ax,cs
	mov     es,ax
	mov     ds,ax
	call    SelectHz

	cmp     [IsDirect],0
	je      DoDMAStuff

	call    SetUpInterrupt
	mov     [CurNote],0
	mov     [CurSequence],0
	movzx   ax,[Sequences]
	mov     [CurPattern],ax
	call    GetAndProcessNotes
	jmp     @@ContinueHere

DoDmaStuff:
	call    DspReset 
	cmp     al,0
	je      NoDMAError
	jmp     ERROR
NoDMAError:
	call    TurnOnSpeaker
	mov     ah,[cs:SampleRate]
	call    SetSampleRate
	
	mov     [CurNote],0
	mov     [CurSequence],0
	movzx   ax,[Sequences]
	mov     [CurPattern],ax

	;call    GetAndProcessNotes
	call    CalcForDma
	call    StartTransferDma     ;start output

@@ContinueHere:
	pop     es ds
	popa
	xor     ax,ax
	ret
ENDP  StartPlaying

PROC  StopPlaying NEAR
	cmp     [IsDirect],0
	je      @@DoDmaStop

	call    RemoveInterrupt
	ret

@@DoDmaStop:
	mov     [cs:QuitDma],1
	call    TurnOffSpeaker
@@WAitForStop:
	cmp     [cs:QuitDma],0
	jne     @@WaitForStop
	
	cmp     [cs:StereoOn],0
	je      NoStereo
	mov     ax,110eh        ;turn stereo off
	call    SetMixer
NoStereo:
	
	call    DspReset
	mov     bx,10
	call    Delay
	ret
ENDP  StopPlaying

	END
