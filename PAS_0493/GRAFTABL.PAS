� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 685 of 702                                                               
From : Emmanuel Roussin                    2:320/200.21         21 Apr 93  22:32 
To   : All                                                                       
Subj : redefined characters in CGA                                            
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
After several tricks to redefine characters in EGA and VGA in this echo,
here is one you can use in CGA mode 4,5,6. You will find an unit, and a
test program.

UNIT graftabl;

{
released into the public domain
author : Emmanuel ROUSSIN
FIDO   : 2:320/200.21
Email  : roussin@frmug.fr.mugnet.org

for using redefined characters (128 to 255)
in CGA mode 4,5 and 6 without using GRAFTABL.EXE
}

INTERFACE

TYPE Tcaractere8 = array [1..8] of byte;
       Tgraftabl = array [128..255] of Tcaractere8;

{
 if you want to use only one font, define it in this unit,
 for example :

 CONST
  the_only_font : Tgraftabl = (
                              (x,x,x,x,x,x,x,x),
                              .
                              .
                              (x,x,x,x,x,x,x,x),
                              (x,x,x,x,x,x,x,x)
                              );

 Or you can in your main program :

 VAR my_font : Tgraftabl;

 and define it after
}

VAR seg_graftabl,
    ofs_graftabl : word;

{internal procedures}

procedure get_graftabl(VAR segment, offset : word);
procedure put_graftabl(segment, offset : word);

{procedures to use in your programs}

procedure init_graftabl;
procedure use_graftabl(VAR aray : Tgraftabl);
procedure end_graftabl;

IMPLEMENTATION

procedure get_graftabl(VAR segment, offset : word);
BEGIN
  segment:=memw[0:$1F*4+2];
  offset:=memw[0:$1f*4];
END;

procedure put_graftabl(segment, offset : word);
BEGIN
  memw[0:$1f*4+2]:=segment;
  memw[0:$1f*4]:=offset
END;

procedure init_graftabl;
{
 interrupt 1F is a pointer to bitmaps
 for high 128 chars (8 bytes per character)
 defined by GRAFTABL.EXE
 we save this initial pointer
}
BEGIN
  get_graftabl(seg_graftabl,ofs_graftabl);
END;

procedure use_graftabl(VAR aray : Tgraftabl);
{
 we define a new pointer : the address of an array
}
BEGIN
  put_graftabl(seg(aray),ofs(aray));
END;

procedure end_graftabl;
{
 we restore the original pointer
}
BEGIN
  put_graftabl(seg_graftabl,ofs_graftabl);
END;

END.

program test;

uses graph3,crt,graftabl;


var font    : Tgraftabl;
    i,j,tmp : byte;
    rid     : char;

BEGIN
  hires;
  init_graftabl;
  fillchar(font,sizeof(font),0);
  use_graftabl(font);

  {
   $F000:$FA6E is the ROM address where
   the characters 0 to 127 are defined
  }

  for i:=1 to 26 do
   for j:=0 to 7 do
   BEGIN
     tmp:=mem[$F000:$FA6E+97*8+(i-1)*8+j] xor $FF;
     tmp:=tmp xor $FF;
     tmp:=tmp or (tmp div 2);
     font[i+127,j+1]:=tmp;
     {
      char 128 to 153 are redefined
     }
   END;

  for i:=1 to 26 do
   for j:=0 to 7 do
   BEGIN
     tmp:=mem[$F000:$FA6E+97*8+(i-1)*8+j] or $55;
     font[i+153,j+1]:=tmp;
     {
      char 154 to 181 are redefined
     }
   END;
  writeln('the normal characters ($61 to $7A) :');
  writeln;
  for i:=$61 to $7A do write(chr(i));
  writeln; writeln;
  writeln('now, these same characters, but thick :');
  writeln;
  for i:=128 to 153 do write(chr(i));
  writeln; writeln;
  writeln('the same characters, but greyed :');
  writeln;
  for i:=154 to 181 do write(chr(i));
  rid:=readkey;
  end_graftabl;
  textmode(co80);
END.

--- GEcho 1.00
 * Origin:  echanger un bubulle contre deux li'll, jamais !  (2:320/200.21)

