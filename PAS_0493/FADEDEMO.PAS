{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 592 of 708
From : Reynir Stefansson                   2:391/20.0           14 Apr 93  17:32
To   : All
Subj : Yafir...
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
     Here is yet another fade-in routine. This one does a proportional fade
of all colours. }

PROGRAM FadeDemo;

USES Crt;

CONST PelAddrRgR  = $3C7;
      PelAddrRgW  = $3C8;
      PelDataReg  = $3C9;

TYPE rgb = RECORD r, g, b : BYTE; END;

VAR i : INTEGER; ch : CHAR; col : ARRAY[0..63] OF rgb;

PROCEDURE GetCol(C : BYTE; VAR R, G, B : BYTE);
BEGIN
   Port[PelAddrRgR] := C;
   R := Port[PelDataReg];
   G := Port[PelDataReg];
   B := Port[PelDataReg];
END;

PROCEDURE SetCol(C, R, G, B : BYTE);
BEGIN
   Port[PelAddrRgW] := C;
   Port[PelDataReg] := R;
   Port[PelDataReg] := G;
   Port[PelDataReg] := B;
END;

PROCEDURE SetInten(b : BYTE);
VAR i : INTEGER; fr, fg, fb : BYTE;
BEGIN
   FOR i := 0 TO 63 DO
   BEGIN
      fr := col[i].r*b DIV 63;
      fg := col[i].g*b DIV 63;
      fb := col[i].b*b DIV 63;
      SetCol(i, fr, fg, fb);
   END;
END;

BEGIN
   TextMode(LastMode);
   FOR i := 0 TO 63 DO GetCol(i, col[i].r, col[i].g, col[i].b);
   FOR i := 1 TO 15 DO
   BEGIN
      TextAttr := i;
      WriteLn('Foreground colour = ', i:2);
   END;
   ch := ReadKey;
   FOR i := 63 DOWNTO 0 DO BEGIN SetInten(i); Delay(20); END;
   GotoXY(1, 1);
   FOR i := 15 DOWNTO 1 DO
   BEGIN
      TextAttr := i;
      WriteLn('Foreground colour = ', i:2);
   END;
   FOR i := 0 TO 63 DO BEGIN SetInten(i); Delay(20); END;
   ch := ReadKey;
   TextMode(LastMode);
END.