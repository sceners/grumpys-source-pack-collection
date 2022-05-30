{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 505 of 536
From : Bernie Pallek                       1:247/128.0          21 Apr 93  18:26
To   : Stephen Cheok
Subj : STARFIELD
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 SC>         Hmm.. does anyone have an example of a
 SC> starfield routine in Turbo Pascal.. or can be used
 SC> with Turbo Pascal.. using the ASSEMBLER..  I want to
 SC> try to make one.. but I need some help with it.

OK, here's a sample (I don't know what kind of starfield you're looking for):}

{EGA/VGA parallax stars}

USES Crt, Graph;

CONST
     starCol : ARRAY[0..2] OF Byte = (8, 7, 15);

TYPE
    StarRec = RECORD
              x : Integer;
              y : Integer;
              d : Integer;  { depth }
              END;
VAR
   stars : ARRAY[0..31] OF StarRec;
   xinc,
   yinc  : Integer;
   ch    : Char;


PROCEDURE OpenGraph;
VAR
   gd, gm : Integer;
BEGIN
     DetectGraph(gd, gm);
     { this doesn't care if you don't have correct video card or not }
     InitGraph(gd, gm, 'C:\BP\BGI');      { put the path to your BGI }
END;

PROCEDURE InitStars;
VAR
   i : Integer;
BEGIN
     FOR i := 0 TO 31 DO WITH stars[i] DO BEGIN
         x := Random(GetMaxX);
         y := Random(GetMaxY);
         d := Random(3);
     END;
END;

PROCEDURE MoveStars;
VAR
   i : Integer;
BEGIN
     FOR i := 0 TO 31 DO WITH stars[i] DO BEGIN
         PutPixel(x, y, 0);
         x := x + xinc * (d + 1);
         IF (x < 0) THEN x := x + GetMaxX;
         IF (x > GetMaxX) THEN x := x - GetMaxX;
         y := y + yinc * (d + 1);
         IF (y < 0) THEN y := y + GetMaxY;
         IF (y > GetMaxY) THEN y := y - GetMaxY;
         PutPixel(x, y, starCol[d]);
     END;
END;


BEGIN
     OpenGraph;  (* enter graphics mode *)
     InitStars;
     xinc := 1;
     yinc := 0;
     REPEAT
           MoveStars;
           (* delay here for faster computers *)
     UNTIL KeyPressed;
     ch := ReadKey;
     IF (ch = #0) THEN ch := ReadKey;  (* get rid of extended keycodes *)
     CloseGraph;
END.

------------SNIPLINE-----------

Whew!  There you have it!  Untested, of course, so you may have to iron out a
few bugs.

**** BIG HINT: You should probably use REAL numbers instead of INTEGER numbers
for x and y positions AND increments, and Round them when PutPixel-ing!  This
will allow you to make smoother transitions, as well as bouncing effects, and
other neat stuff. ****

You'll notice (if the thing works) that the stars move horizontally only, and
the dimmer ones move slower than the bright ones (parallax/multi-layered).  You
can add extra layers, but remember to change the StarCol constant so you have
the right number of colours for the stars.

Sorry, I was too lazy to comment it thoroughly; I'm expecting that you'll be
able to figure it out without too much trouble.  Sorry if you can't; write me
for an explanation.  TTYL.

Bernie.