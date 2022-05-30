{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 444 of 473
From : Grady Werner                        1:114/224.0          13 Apr 93  17:44
To   : All
Subj : Assembly Grafix Routines
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
I'm looking for any inline assembly routines for graphis handling.  I need
faster routines for line drawing, pixel plotting, animation, and any other
nifty stuff...  I have palette changing routines down... Put these in your
code for GREAT, FAST RGB Palette Changing... }

     Procedure ASetRGBPalette (Color,Red,Green,Blue: byte);
          Begin
               Port[$3C8]:=Color;
               Port[$3C9]:=Red;
               Port[$3C9]:=Green;
               Port[$3C9]:=Blue;
          end;

{     This procedure Changes palette colors about 400% faster than the
built-in routines.  Also, a problem with flicker may have been encountered
with Turbo's Putimage functions.  Call this procedure RIGHT BEFORE the
putimage is called... Viola... NO Flicker! }

     Procedure WaitScreen;
          Begin
               Repeat Until (Port[$3DA] and $08) = 0;
               Repeat Until (Port[$3DA] and $08) <> 0;
          end;