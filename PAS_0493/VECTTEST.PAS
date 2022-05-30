{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 533 of 658
From : Trevor Robinson                     1:3808/10.0          25 Apr 93  19:41
To   : Sean Palmer
Subj : DownScaling Bitmaps 1/2
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 -=> Quoting Sean Palmer to Trevor Robinson <=-

 TR> It is called DDA texture mapping, and is used to add texture to 3D
 TR> vector objects.  It is basically polygon drawing code that keeps track
 TR> of transformed coordinates in a source bitmap.  There is C source for
 TR> it in the Sep. '92 issue of DDJ.  I have rewritten it for Turbo Pascal,
 TR> but need to rewrite it again in ASM to make it fast enough to use.

 SP> Post! Post!! If not here then in the PASCAL echo, I can translate to
 SP> asm... I NEED those algorithms! I may have to just subscribe to DDJ...

Okay, here it is, hope you can figure them out...  When you finish your
assembly translation, please post it in the 80XXX echo.  I'd like to see it,
because it is quite complicated.  It uses 386 fixed-point arithmetic, which
is in assembly, but I'll post that in the Pascal echo anyway.  (I think you'll
be able to figure out the routines in XGraph.)

*** DDA texture mapping routines for Turbo Pascal }

{$R-,X+}
Program VectTest;
Uses
  Dos, Crt, XGraph;
Const
  ClipMinY = 0;
  ClipMaxY = 199;
  ClipMinX = 0;
  ClipMaxX = 319;
  VertMax = 4;
Type
  TextureMap = Record
    TexMapWidth : Word;
    TexMapBits : Pointer;
  End;
  VertRec = Record
    X, Y : Integer;
  End;
  VertArr = Array [0..VertMax] Of VertRec;
  Face = Record
    VertNums : ^VertArr;
    NumVerts : Word;
    ColorIdx : Byte;
    ShadeTyp : Byte;
    TexMap : TextureMap;
    Point : ^VertArr;
  End;
  EdgeScan = Record
    Direction : Integer;
    RemainingScans : Integer;
    CurrentEnd : Integer;
    SourceX : Longint;
    SourceY : Longint;
    SourceStepX : Longint;
    SourceStepY : Longint;
    DestX : Integer;
    DestXIntStep : Integer;
    DestXDirection : Integer;
    DestXErrTerm : Integer;
    DestXAdjUp : Integer;
    DestXAdjDown : Integer;
  End;
Var
  GD, GM, MapX, MapY : Integer;
  Poly : Face;

PROCEDURE LoadPal (N : STRING);
VAR
  F : FILE;
  Pal : PalType;
BEGIN
  ASSIGN (F, N);
  {$I-} RESET (F, 1); {$I+}
  IF IORESULT <> 0 THEN BEGIN
    SetTextMode;
    HALT;
  END;
  BLOCKREAD (F, Pal, SIZEOF (Pal) );
  SetAllPal (Pal);
  CLOSE (F);
END;

{$F+}
{$L FIXEDM}
Function FixedDiv(L1, L2 : Longint) : Longint; External;
{$F-}

Procedure DrawTexPoly(Var Polygon : Face);
Var
  MinY, MaxY, MinVert, MaxVert, I, DestY : Integer;
  LeftEdge, RightEdge : EdgeScan;

  Function SetUpEdge(Var Edge : EdgeScan; StartVert : Integer) : Boolean;
  Var
    NextVert, DestXWidth : Integer;
    DestYHeight, T : Longint;
  Begin
    SetUpEdge := True;
    While (StartVert <> MaxVert) Do Begin
      NextVert := StartVert + Edge.Direction;
      If (NextVert >= Polygon.NumVerts) Then
        NextVert := 0
      Else If (NextVert < 0) Then
        NextVert := Polygon.NumVerts - 1;
      With Edge Do Begin
        RemainingScans := Polygon.VertNums^[NextVert].Y -
          Polygon.VertNums^[StartVert].Y;
        If (RemainingScans <> 0) Then Begin
          T := RemainingScans;        DestYHeight := T Shl 16;
          CurrentEnd := NextVert;
          T := Polygon.Point^[StartVert].X;   SourceX := T Shl 16;
          T := Polygon.Point^[StartVert].Y;   SourceY := T Shl 16;
          T := Polygon.Point^[NextVert].X;    T := T Shl 16;
{ Pascal equivalent of assembler fixed division:
          SourceStepX := Trunc((T - SourceX) / DestYHeight * $10000);
}
          SourceStepX := FixedDiv(T - SourceX, DestYHeight);
          T := Polygon.Point^[NextVert].Y;    T := T Shl 16;
{ Pascal equivalent of assembler fixed division:
          SourceStepY := Trunc((T - SourceY) / DestYHeight * $10000);
}
          SourceStepY := FixedDiv(T - SourceY, DestYHeight);
          DestX := Polygon.VertNums^[StartVert].X;
          DestXWidth := Polygon.VertNums^[NextVert].X -
            Polygon.VertNums^[StartVert].X;
          If (DestXWidth < 0) Then Begin
            DestXDirection := -1;
            DestXWidth := -DestXWidth;
            DestXErrTerm := 1 - RemainingScans;
            DestXIntStep := -(DestXWidth Div RemainingScans);
          End Else Begin
            DestXDirection := 1;
            DestXErrTerm := 0;
            DestXIntStep := DestXWidth Div RemainingScans;
          End;
          DestXAdjUp := DestXWidth Mod RemainingScans;
          DestXAdjDown := RemainingScans;
          Exit;
        End;
        StartVert := NextVert;
      End;
    End;
    SetUpEdge := False;
  End;

  Function StepEdge(Var Edge : EdgeScan) : Boolean;
  Begin
    Dec(Edge.RemainingScans);
    If (Edge.RemainingScans = 0) Then Begin
      StepEdge := SetUpEdge(Edge, Edge.CurrentEnd);
      Exit;
    End;
    With Edge Do Begin
      Inc(SourceX,SourceStepX);
      Inc(SourceY,SourceStepY);
      Inc(DestX,DestXIntStep);
      Inc(DestXErrTerm,DestXAdjUp);
      If (DestXErrTerm > 0) Then Begin
        Inc(DestX,DestXDirection);
        Dec(DestXErrTerm,DestXAdjDown);
      End;
    End;
    StepEdge := True;
  End;

  Procedure ScanOutLine;
  Var
    T, SourceX, SourceY : Longint;
    DestX, DestXMax : Integer;
    DestWidth, SourceXStep, SourceYStep : Longint;
    C : Byte;
    A : Word;
  Begin
    SourceX := LeftEdge.SourceX;
    SourceY := LeftEdge.SourceY;
    DestX := LeftEdge.DestX;
    DestXMax := RightEdge.DestX;
    If (DestXMax <= ClipMinX) Or (DestX >= ClipMaxX) Then Exit;
    T := DestXMax - DestX;
    If (T <= 0) Then Exit;
    DestWidth := T Shl 16;
{ Pascal equivalent of assembler fixed division:
    SourceXStep := Trunc((RightEdge.SourceX - SourceX) / DestWidth * $10000);
    SourceYStep := Trunc((RightEdge.SourceY - SourceY) / DestWidth * $10000);
}
    SourceXStep := FixedDiv(RightEdge.SourceX - SourceX, DestWidth);
    SourceYStep := FixedDiv(RightEdge.SourceY - SourceY, DestWidth);
    If (DestXMax > ClipMaxX) Then
      DestXMax := ClipMaxX;
    If (DestX < ClipMinX) Then Begin
      Inc(SourceX, SourceXStep * (ClipMinX - DestX));
      Inc(SourceY, SourceYStep * (ClipMinX - DestX));
      DestX := ClipMinX;
    End;
    A := DestY * BytesPerLine + DestX;
    While (DestX <= DestXMax) Do Begin
      With Polygon.TexMap Do
        C := Mem[Seg(TexMapBits^):Ofs(TexMapBits^) +
          (SourceY Shr 16) * TexMapWidth + (SourceX Shr 16)];
      If C = 0 Then Inc(C);
      Mem[VideoSeg:A] := C;
      Inc(SourceX, SourceXStep);
      Inc(SourceY, SourceYStep);
      Inc(DestX);
      Inc(A);
    End;
  End;

Begin
  If (Polygon.NumVerts < 3) Then Exit;
  MinY := 32767;
  MaxY := -32768;
  For I := 0 To Polygon.NumVerts-1 Do
    With Polygon Do Begin
      If (VertNums^[I].Y < MinY) Then Begin
        MinY := VertNums^[I].Y;
        MinVert := I;
      End;
      If (VertNums^[I].Y > MaxY) Then Begin
        MaxY := VertNums^[I].Y;
        MaxVert := I;
      End;
    End;
  If (MinY >= MaxY) Then Exit;
  DestY := MinY;
  LeftEdge.Direction := -1;
  SetUpEdge(LeftEdge, MinVert);
  RightEdge.Direction := 1;
  SetUpEdge(RightEdge, MinVert);
  While (DestY < ClipMaxY) Do Begin
    If (DestY >= ClipMinY) Then
      ScanOutLine;
    If Not StepEdge(LeftEdge) Then Exit;
    If Not StepEdge(RightEdge) Then Exit;
    Inc(DestY);
  End;
End;

Function LoadBitMap(Fname : String; Var Polygon : Face) : Boolean;
Var
  F : File;
  W : Word;
Begin
  LoadBitMap := False;
  Assign(F, Fname);
  {$I-} Reset(F, 1); {$I+}
  If IOResult <> 0 Then Exit;
  BlockRead(F, W, 2);
  Dec(W, 6);
  If MaxAvail < W Then Begin
    Close(F);
    Exit;
  End;
  With Polygon.TexMap Do Begin
    BlockRead(F, TexMapWidth, 2);
    MapX := TexMapWidth;
    BlockRead(F, MapY, 2);
    GetMem(TexMapBits, W);
    BlockRead(F, TexMapBits^, W);
  End;
  Close(F);
  LoadBitMap := True;
End;

Begin
  SetGraphMode;
  DirectVideo := False;
  LoadPal('C:\XGRAPH\PICT.PAL');
  { PAL format: raw 768-byte palette information file }
  If Not LoadBitMap('C:\XGRAPH\PICT.CUT', Poly) Then Begin
    SetTextMode;
    WriteLn('Error loading bitmap');
    Halt;
  End;
  { CUT format: image size + 6 (word), width (word), height (word), image }
  With Poly Do Begin
    NumVerts := 4;
    ColorIdx := 16;
    ShadeTyp := 4;
    GetMem(VertNums,(NumVerts + 1) * SizeOf(VertRec));
    With VertNums^[0] Do Begin
      X := 50;  Y := 40;
    End;
    With VertNums^[1] Do Begin
      X := 240;  Y := 20;
    End;
    With VertNums^[2] Do Begin
      X := 270;  Y := 160;
    End;
    With VertNums^[3] Do Begin
      X := 70;  Y := 180;
    End;
    With VertNums^[3] Do Begin
      X := 100;  Y := 140;
    End;
    GetMem(Point,NumVerts * SizeOf(VertRec));
    With Point^[0] Do Begin
      X := 0;  Y := 0;
    End;
    With Point^[1] Do Begin
      X := MapX-1;  Y := 0;
    End;
    With Point^[2] Do Begin
      X := MapX-1;  Y := MapY-1;
    End;
    With Point^[3] Do Begin
      X := 0;  Y := MapY-1;
    End;
  End;
  DrawTexPoly(Poly);
  ReadKey;
  SetTextMode;
End.