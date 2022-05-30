;=======-  DMA 286 GLOBALS

  GLOBAL  SetSampleRate:PROC, StartTransferDMA:PROC, TurnOffSpeaker:PROC
  GLOBAL  TurnOnSpeaker:PROC, CalcForDMA :PROC
  GLOBAL  HaltDma      :PROC, DspReset   :PROC  

  GLOBAL  WhichBuffer  :WORD, QuitDma      :WORD
  GLOBAL  Buffer1size  :WORD, Buffer2Size  :WORD
  GLOBAL  BufferOffset1:WORD, BufferOffset2:WORD
  GLOBAL  BufferSeg    :Word

  GLOBAL  IntNumber:BYTE, BaseAddress:WORD

  GLOBAL  StereoOn:BYTE, DoWowII:BYTE
  GLOBAL  SetMixer:NEAR, IsDirect:BYTE
    
  GLOBAL  RemoveInterrupt:NEAR, SetUpInterrupt:NEAR
  GLOBAL  UndoRealInt:NEAR
  
;=======- MOD SUB GLOBALS

  GLOBAL  StartPlaying:NEAR,  StopPlaying :NEAR
  GLOBAL  Mute        :NEAR,  UnMute      :NEAR
  GLOBAL  MainUpDate  :NEAR

  GLOBAL  BaseModSeg  :WORD, ComputerSpeed  :BYTE     ;range 0-6
  GLOBAL  ModName:BYTE, MasterVolume   :WORD, HZ:WORD
  GLOBAL  LptAddress1:WORD, LptAddress2:WORD

;======- print routines

    GLOBAL  PrintByte:PROC, PrintWord:PROC, PrintBig:PROC
    GLOBAL  PrintHexByte:PROC, PrintHexWord:PROC, PrintHexBig:PROC
    GLOBAL  PrintHex:PROC, PrintNum:PROC
    GLOBAL  PrintString:PROC

STRUC DataStruc
    HeaderPtr   dd  0           ;pointer to header
    CurBuffPtr  dd  0           ;pointer to currently playing buffer
    BuffSize    dw  0           ;size of currently playing buffer
    TrakInst    db  8 dup (0)   ;what inst is playing (0=none)
    TrakInstNext db 8 dup (0)   ;next note to be played...
    TrakInstNew db  8 dup (0)   ;a pulse- turn on when a note is played
                                ;yser should read and then reset to 0
    VolBars     db  8 dup (0)   ;User decreased volume bars
    OldVolBars  db  8 dup (0)
    CNote       db  0           ;current note 0-63
    CPattern    db  0           ;current pattern
    CSequence   db  0           ;surrent sequence
    BPMspeed    db  0           ;beat per minute speed
    HZ          dw  0           ;sampling rate
ENDS  DataStruc

GLOBAL QTDS:DataStruc

GLOBAL ModName:Byte
