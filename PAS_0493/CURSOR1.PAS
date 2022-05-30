{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 439 of 474
From : Sean Palmer                         1:104/123.0          16 Apr 93  14:58
To   : Daniel Shapiro
Subj : Hiding cursor
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 DS>      I have another one- How do I "hide" the cursor?
 DS> So when it is waiting for input, I won't see that stupid little
 DS> blinking cursor there...  }

{ $TESTED+}  {<<< I like that!!}

unit cursor1; {Public domain, by Sean Palmer aka Ghost}

interface
 
var maxSize:byte;
 
 procedure setSize(scans:byte);  {set size from bottom, or 0 for off}
 procedure detect;     {get max scan lines by reading current cursor}

implementation

procedure setSize(scans:byte);var t:byte;begin
 if scans=0 then t:=$20 else t:=maxSize-scans;
 asm mov ah,1; mov bh,0; mov ch,t; mov cl,maxSize; dec cl; int $10; end;
 end;

procedure detect;assembler;asm  {do NOT call while cursor's hidden}
 mov ah,3; mov bh,0; int $10; inc cl; mov maxSize,cl;
 end;

begin
 detect;
 end.