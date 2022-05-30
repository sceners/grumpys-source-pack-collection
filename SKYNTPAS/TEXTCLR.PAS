Program UpperWinColor;

  Uses Crt;

  Const
    TotalWanted = 5*3.14159263/2;
    Start = -3.14159263/3.5;

  Procedure SetColor ( Val: integer; red, green, blue : byte );

    Begin
      Port[$3c8] := val;
      Port[$3c9] := red;
      Port[$3c9] := green;
      Port[$3c9] := blue;
    End;


  Var
    Count : Integer;
    Color : Byte;
    OutFile : Text;

  Begin
    Assign(OutFile,'UpperWin.DAT');
    ReWrite(OutFile);
    Asm
      mov ax,0013h
      int 10h
    End;
    For Count := 1 To 100 Do
      Begin
        Color := Round(31+(32*Sin(-Start+Count*TotalWanted/80)));
        If Color > 63 Then Color := 0;
        SetColor(Count,0,0,Color);
        Writeln(OutFile,'        DB        0,  0,',Color:3);
        FillChar(Mem[$A000:Count*320],320,Chr(Count));
      End;
    Close(OutFile);
    Repeat Until Keypressed;
    Asm
      mov ax,0003h
      int 10h
    End;
  End.
