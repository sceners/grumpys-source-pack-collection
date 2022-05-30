{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 580 of 708
From : David Drzyzga                       1:3612/220.0         25 Apr 93  07:28
To   : Dustin Nulf                         1:124/6304.0
Subj : User defined Character S
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 DN> Is there any way to create or use your own fonts in
 DN> regular text mode with Pascal?

Yep. Here's a demo of a routine originally posted by Bernie P and revised by me:}

program UpsideDown;
{-upsidedown and backwards text aka redefining the text mode font}
var
  newcharset, oldcharset : array[0..255,1..16] of byte;
  
procedure getoldcharset;
var
  b:byte;
  w:word;
begin
  for b := 0 to 255 do begin
    w := b * 32;
    inline($FA);
    PortW[$3C4] := $0402;
    PortW[$3C4] := $0704;
    PortW[$3CE] := $0204;
    PortW[$3CE] := $0005;
    PortW[$3CE] := $0006;
    Move(Ptr($A000, w)^, oldcharset[b,1], 16);
    PortW[$3C4] := $0302;
    PortW[$3C4] := $0304;
    PortW[$3CE] := $0004;
    PortW[$3CE] := $1005;
    PortW[$3CE] := $0E06;
    inline($FB);
  end;
end;

procedure restoreoldcharset;
var
  b:byte;
  w:word;
begin
  for b := 0 to 255 do begin
    w := b * 32;
    inline($FA);
    PortW[$3C4] := $0402;
    PortW[$3C4] := $0704;
    PortW[$3CE] := $0204;
    PortW[$3CE] := $0005;
    PortW[$3CE] := $0006;
    Move(oldcharset[b,1], Ptr($A000, w)^, 16);
    PortW[$3C4] := $0302;
    PortW[$3C4] := $0304;
    PortW[$3CE] := $0004;
    PortW[$3CE] := $1005;
    PortW[$3CE] := $0E06;
    inline($FB);
  end;
end;

procedure setasciichar(charnum : byte; var data);
var
   offset : Word;
begin
  offset := charNum * 32;
  inline($FA);
  PortW[$3C4] := $0402;
  PortW[$3C4] := $0704;
  PortW[$3CE] := $0204;
  PortW[$3CE] := $0005;
  PortW[$3CE] := $0006;
  Move(data, Ptr($A000, offset)^, 16);
  PortW[$3C4] := $0302;
  PortW[$3C4] := $0304;
  PortW[$3CE] := $0004;
  PortW[$3CE] := $1005;
  PortW[$3CE] := $0E06;
  inline($FB);
end;

procedure newwriteln(s:string);
 {- Reverses order of characters written}
var
  b : byte;
begin
  for b := length(s) downto 1 do write(s[b]);writeln;
end;

var
  b,c : byte;

begin
  getoldcharset;
  for b := 0 to 255 do
    for c := 1 to 16 do newcharset[b, c] := oldcharset[b,(17-c)];
  for b := 0 to 255 do setasciichar(b,newcharset[b,1]);
  newwriteln('Hello World!');
  readln;
  restoreoldcharset;
end.