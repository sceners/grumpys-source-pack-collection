{*****************************************************************************
 example 

 Hardware Scroll in Tweaked Video Mode 320*200*256*4
 Scroll uses * Start Adress Register to perform scroll.
             * Input Status Port for Vertical Retrace.
             * Logical Screen Width to alter the screen width.
             * PCX-pictures for the fonts (thx the GFX Man or make
               some yourself...)
             * Independ width for the fonts, this means that your're able to
               put logo's in the scroll , let's say 200 pixels or more large,
               and max 50 in height.But you propably be able to do better... .

******************************************************************************}

{$G+,S-,L-,R-}
uses Crt;
const   Crtadress:word=$3d4;
        Inputstatus:word=$3DA;
Type    ColorValue = Record R,G,B: Byte; End;
        Palette    = Array [0..255] Of ColorValue;

var as,ao,cs,co,bs,bo:word;
    tp,tp1,tp2:pointer;
    P:palette;

{$I example.hdw}  {include text}

Procedure LoadPcxbuf(Fname:String;var as,ao:word;var q:palette);
Const
  DataBuffer = $2800;                                      { 10K Data Buffer Area}
type
    Pal        = array[0..767] of byte;

Var
  ScrOff,Buf,HowMany : LongInt;                            { Decompress Variables }
  PcxBuffer : Array[1..DataBuffer] Of Byte;                { Declare DataBuffer Size }
  RGBs : Array[0..767] of Byte;                            { Temp Colour Palette Storage }
  DataByte : Byte;                                         { Current Byte Being Processed }
  NumRead : Word;                                          { Temporary Variable }
  F : File;                                                { File Variable }
  p:Pal;

Procedure MoveIt(SSeg,SOfs,TSeg,TOfs,L: Word);
Begin
 Asm
  cld
  push  ds
  mov   si,SOfs
  mov   di,TOfs
  mov   cx,l
  mov   es,[tseg]
  mov   ds,[sseg]
  shr   cx,1
  rep  movsw
  jnb  @even
  movsb
@even:
  pop ds
 End;
End;


procedure Fillarea(as,ao,l,color:word);assembler;
Asm
    push es
    mov  es,[as]               { Point es to screen segment }
    mov  di,ao
    mov  ax,color
    mov  cx,l
    cld
    rep  stosb               { use a fast 8088 instruction to store al }
@even:
    pop  es
end;


Procedure ShiftPcxPalette(var p:pal);
var loop:integer;
Begin
  For Loop:=0 To 767 Do p[Loop]:=RGBs[Loop] SHR 2;      { Helps Set Colours Correctly }
End;

Procedure FillBuffer;
Begin
  If (Buf> DataBuffer) Then                             { Refresh Buffer ? }
  Begin
    Buf:=1;
    BlockRead(F,PcxBuffer,SizeOf(PcxBuffer),NumRead);    { Read Chunk Of Data From .Pcx File }
  End;
  DataByte:=PcxBuffer[Buf];                             { Take A Byte From The Buffer }
  Inc(Buf,1);
End;

Begin
  Assign(F,FName+'.pcx');
  Reset(F,1);                                              { Use records with length 1}
  Seek(F,128);                                             { Ignore .Pcx Header }
  HowMany:=0;  ScrOff:=0;
  Buf:=DataBuffer + 1;
  While (ScrOff < $fa00) Do
  Begin
    FillBuffer;
    HowMany:=1;                                            { Contiguous Bytes Set To 1 }
    If (DataByte AND $C0) = $C0 Then                       { If DataByte's Top 2 Bits Are 1 }
    Begin
      HowMany:=DataByte AND $3F;                           { It's An RLE (Run Length Encoded) Byte }
      FillBuffer;                                          { Refresh Buffer If Need Be }
    End;
    Fillarea(AS,AO+ScrOff,HowMany,DataByte);          { Write DataByte(s) Directly To Video Memory }
    Inc(ScrOff,HowMany);                                   { Increase Video Memory OffSet }
  End;
  Seek(F,FileSize(F) - 768);
  BlockRead(F,RGBs,SizeOf(RGBs),NumRead);
  ShiftPcxPalette(p);
  Close(F);
  Moveit(seg(p),ofs(p),seg(q),ofs(q),768)
End;


procedure Fntoffs;assembler;
Asm     {Font height is 50, offset the first word, the width is the second word }
        {offset 48260 = not defined (black pix)!! }
        DW 18092,0018; {! : 33}
        DW 48260,0010; {" : 34}
        DW 48260,0010; {# : 35}
        DW 48260,0010; {  : 36}
        DW 48260,0010; {% : 37}
        DW 18050,0035; {& : 38}
        DW 35690,0020; {' : 39}
        DW 48260,0010; {( : 40}
        DW 48260,0010; {) : 41}
        DW 18020,0020; {* : 42}
        DW 18115,0020; {+ : 43}
        DW 17920,0021; {, : 44}
        DW 18141,0030; {- : 45}
        DW 17941,0020; {. : 46}
        DW 35560,0035; {/ : 47}

        DW 19235,0030; {0 : 48}
        DW 00640,0030; {1 : 49}
        DW 00673,0030; {2 : 50}
        DW 00713,0030; {3 : 51}
        DW 00752,0030; {4 : 52}
        DW 00788,0030; {5 : 53}
        DW 00825,0030; {6 : 54}
        DW 00861,0030; {7 : 55}
        DW 00897,0030; {8 : 56}
        DW 19200,0030; {9 : 57}


        DW 17960,0018; {: : 58}
        DW 17983,0018; {; : 59}
        DW 35607,0030; {< : 60}
        DW 18177,0030; {= : 61}
        DW 35653,0030; {> : 62}
        DW 35520,0030; {? : 63}
        DW 48260,0010; {@ : 64}


        DW 03850,0025; {A : 65}
        DW 03879,0025; {B}
        DW 03908,0025; {C}
        DW 03937,0025; {D}
        DW 03966,0025; {E}
        DW 03995,0022; {F}
        DW 04022,0024; {G}
        DW 04052,0021; {H}
        DW 04082,0020; {I}
        DW 04102,0022; {J}
        DW 04128,0025; {K}
        DW 22410,0024; {L}
        DW 22439,0026; {M}
        DW 22475,0022; {N}
        DW 22504,0024; {O}
        DW 22535,0024; {P}
        DW 22562,0028; {Q}
        DW 22595,0026; {R}
        DW 22627,0022; {S}
        DW 22655,0021; {T}
        DW 22687,0026; {U}

        DW 00001,0028; {V}
        DW 00033,0040; {W}
        DW 00080,0025; {X}
        DW 00113,0024; {Y}
        DW 00145,0025; {Z}
end;

PROCEDURE SetGraph;
BEGIN

 ASM            {Let us see if we have a color or a monochorme display?}
   MOV DX,3CCh
   IN AL,DX
   TEST AL,1    {Is it a color display?    }
   MOV CX,3DAh
   MOV DX,3D4h
   JNZ @L1      {Yes  }
   MOV DX,3B4h  {No  }
   MOV CX,3BAh
  @L1:
   MOV CRTAdress,DX
   MOV Inputstatus,CX
    MOV AX,0013h   {Use BIOS to set graphic mode 13H (320x200x256)   }
    INT 10h
    MOV DX,03C4h   {Select memory-mode-register at sequencer port    }
    MOV AL,04
    OUT DX,AL
    INC DX         {Read in data via the according data register     }
    IN  AL,DX
    AND AL,0F7h    { $F7=11110111B bit 3:=0 -> don't chain planes }
    OR  AL,04      { $04=00000100B bit 2:=1 -> no odd/even-scheme }
    OUT DX,AL      {Activate new settings... .}
    MOV DX,03C4h   {Enable the map-mask for planing}
    MOV AL,02
    OUT DX,AL
    INC DX
    MOV AL,0Fh     { $0F=00001111B ...and allow access to all 4 bit maps            }
    OUT DX,AL
    MOV AX,0A000h  {Starting in segment A000h, set 8000h logical     }
    MOV ES,AX      {Words = 4*8000h physical words (because of 4     }
    SUB DI,DI      {Bitplanes) to 0                                  }
    MOV AX,DI
    MOV CX,8000h
    CLD
    REP STOSW

    MOV DX,CRTAdress  {Address the underline-location-register at   }
    MOV AL,14h        {The CRT-controller port, read out the according  }
    OUT DX,AL         {Data register:                                   }
    INC DX
    IN  AL,DX
    AND AL,0BFh    { $BF=10111111B bit 6:=0 -> disable double word addressing}
    OUT DX,AL      {Video ram                                        }
    DEC DX
    MOV AL,17h     {Select mode control register                     }
    OUT DX,AL
    INC DX
    IN  AL,DX
    OR  AL,40h     { $40=01000000B bit 6:=1 -> address memory as a linear bit array  }
    OUT DX,AL
 END;
END;

Procedure SetHPages(P: Byte);assembler;
asm
   mov   ax,40
   mov   bl,p           {p*40 ex. 160 words or 4 pages from 80 bytes hor.}
   mul   bl
   mov   dx,Crtadress
   mov   ah,al
   mov   al,$13
   out   dx,ax
end;

Procedure Pan(X,Y: Word);assembler;
asm
    mov    bx,320
    mov    ax,y
    mul    bx
    add    ax,x
    push   ax
    pop    bx
    mov    dx,INPUTSTATUS
@WaitDE:
    in     al,dx
    test   al,01h
    jnz    @WaitDE       {display enable is active?}
    mov    dx,Crtadress
    mov    al,$0C
    mov    ah,bh

    out    dx,ax
    mov    al,$0D
    mov    ah,bl
    out    dx,ax
    MOV    dx,inputstatus
@wait:
    in      al,dx
    test    al,8                    {?End Vertical Retrace?}
    jz     @wait

End;


Procedure Movescrtopage(SSeg,SOfs,TOFS: Word);assembler;
Asm           {Put the scroll on in vram (out of screen) plane 0 1 2 3 }
  push   ds
  cld
  mov   si,SOfs
  add   Tofs,150*320+80
  mov   di,TOfs
  mov   ax,$0A000
  mov   es,ax
  mov   ds,[sseg]
  mov   dx,$3c4
  mov   al,02
  out   dx,al
  inc   dx

  mov   cx,50
  in    al,dx
  and   al,11110000B           {Do not affect the other bit settings}
  or    al,1                   {This not really necesary! ex. mov  al,01}
  out   dx,al                  {                              out  dx,al}
@plane0:
  lodsb
  or   al,al
  jnz   @j0
  mov   ax,cx
@j0:
  stosb
  add   di,319
  add   si,319
  loop  @plane0

  inc   sofs
  mov   si,SOfs
  mov   di,TOfs

  mov   cx,50
  in    al,dx
  and   al,11110000B
  or    al,2
  out   dx,al
@plane1:
  lodsb
  or   al,al
  jnz   @j1
  mov   ax,cx
@j1:
  stosb
  add   di,319
  add   si,319
  loop  @plane1

  inc   sofs
  mov   si,SOfs
  mov   di,TOfs

  mov   cx,50
  in    al,dx
  and   al,11110000B
  or    al,4
  out   dx,al
@plane2:
  lodsb
  or    al,al
  jnz   @j2
  mov   ax,cx
@j2:
  stosb
  add   di,319
  add   si,319
  loop  @plane2

  inc   sofs
  mov   si,SOfs
  mov   di,TOfs

  mov   cx,50
  in    al,dx
  and   al,11110000B
  or    al,8
  out   dx,al
@plane3:
  lodsb
  or    al,al
  jnz   @j3
  mov   ax,cx
@j3:
  stosb
  add   di,319
  add   si,319
  loop  @plane3

  pop  ds
End;

function Keypressed:boolean;assembler;
Asm
   mov   ah,01
   int   $16            {Read keyboard buffer status}
   jz    @false         {No keystroke}
   mov   al,1
   jmp   @true
@false:
   mov  al,0
@true:
end;


procedure Dohscroll;
const Blankpos :word=8;
      Page0    :word=0;
      Page1    :word=80;
      Page2    :word=160;
      Page3    :word=240;

var y:integer;
    zs,tmp:word;
    Winxpos,Winypos,Font,let,Hblank:word;
    Yhlp:integer;

begin
 Yhlp:=-1;
 Winypos:=50;
 let:=0;
 repeat
     Asm
        mov  ax,maxtxt
        cmp  let,ax
        jle  @nope
        mov  let,0
     @nope:                                   {Avoid the overflow of the text buffer.}
        cmp  winxpos,240
        jl   @exit                            {Scroll on page 0 - 1 - 2 and 3 }
        mov  winxpos,0
     @exit:
     end;

     y:=txt[let];

     if y<15 then                          {Thx the GFX-man for this}
     begin                                   {greate confusion!!}
          as:=cs;                            {First fonts he ever made, see the}
          ao:=co;                            {result the coder has to do all the shit!}
     end
     else if y<25 then
          begin
               as:=bs;
               ao:=bo;
          end
          else if y>52 then
               begin
                    as:=cs;
                    ao:=co;
               end
               else if y<32 then
                    begin
                         as:=cs;
                         ao:=co;
                    end
                    else
                        begin
                           as:=seg(tp^);
                           ao:=ofs(tp^);
                        end;

     Asm
        push  ds
        mov   cx,font
        mov   ax,seg fntoffs
        mov   ds,ax
        mov   si,offset fntoffs
        mov   ax,y
        shl   ax,2     {*4}
        add   si,ax
        inc   si
        inc   si       {-2b = 1W get the length of the current font.}
        lodsw
        cmp   ax,cx
        jg    @nonext
        mov   tmp,0
        jmp   @exit
@nonext:
        mov  tmp,1
@exit:
        sub   si,4
        lodsw
        sub   ax,4
        mov   zs,ax              {zs:=offset fntoffs[txt[let]]}
        pop   ds
          cmp   y,250
          jle   @exit2
          mov   zs,48250         {A Black font on the pic... .}
          mov   font,0
          mov   ax,hblank
          or    ax,ax
          jnz   @selse
          add   ax,blankpos
          mov   hblank,ax
          inc   let
          jmp   @exit3
       @selse:
          dec   hblank
          jmp   @exit3
       @exit2:
          mov  ax,tmp
          or   ax,ax
          jnz  @selse2
          mov  font,0
          inc  let
          jmp  @exit3
       @selse2:
          add  font,4
       @exit3:
     end;
     if Winxpos>Page2 then Movescrtopage(as,ao+zs+Font,Winxpos-Page3);
     Movescrtopage(as,ao+zs+Font,Winxpos);
     Pan(Winxpos,Winypos);
     inc(Winxpos);
     inc(Winypos,Yhlp);
     if (Winypos>=150)  or (Winypos<=1)then Yhlp:=-Yhlp;
 until Keypressed;
end;


Procedure SetVGApalette(Var tp: Palette);
var Sofs:word;
begin
     Sofs:=ofs(tp);
Asm
  mov si,Sofs
  xor ax,ax
  mov cx,3*256
  mov dx,$03c8
  out dx,al
  inc dx
  rep outsb
  end;
End;


procedure arrangepal;
var tel:byte;
begin
    p[128]:=p[128];                        {Bizarr neh??}
    for tel:=1 to 50 do With p[tel] do     {Make background}
    begin
         r:=tel;
         b:=tel;
         g:=tel;
    end;
end;


begin
    Getmem(tp,$fa00);
    Getmem(tp1,$fa00);
    Getmem(tp2,$fa00);                    {Reserve memory for fonts..}

    as:=seg(tp^);ao:=ofs(tp^);
    bs:=seg(tp1^);bo:=ofs(tp1^);
    cs:=seg(tp2^);co:=ofs(tp2^);          {Get adresses for fast access}

    Fillchar(p,Sizeof(p),0);              {Clear palette to reduce flicker while}
    SetVGApalette(p);                     {Setting up GFX mode}
    Setgraph;                             {Set unchained VGA mode}
    Fillchar(p,Sizeof(p),0);
    Setvgapalette(p);

    Sethpages(4);                         {Set logical screen with at 160 words, }
                                          {Or Set 4 Horz. pages}

    Loadpcxbuf('multv-',cs,co,p);
    Loadpcxbuf('cijf',bs,bo,p);
    Loadpcxbuf('multa-u',as,ao,p);        {Load the pix in mem}

    Arrangepal;                           {Fix the color palette... .}

    Setvgapalette(p);                     {Set the color palette}

    Dohscroll;                            {Run the Hardware scrolly... .}

    textmode (lastmode);                  {Warping back to DOS.}
end.

