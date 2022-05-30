Program MakeGrid;

  Uses Crt;

  Var
    Done : Boolean;
    Key : Char;
    XPos,YPos,GridCount : Integer;
    Grid : Array[1..16,1..8] of Boolean;
    OutFile : File of Byte;


  Procedure ClearGrid;

    Var XCnt,YCnt : Integer;

    Begin
      For YCnt := 1 To 8 Do
        For XCnt := 1 To 16 Do
          Grid[XCnt,YCnt] := False;
    End;


  Procedure DrawGrid;

    Var XCnt,YCnt : Integer;

    Begin
      For YCnt := 1 To 8 Do
        For XCnt := 1 To 16 Do
          Begin
            GotoXY(31+XCnt,8+YCnt);
            If Grid[XCnt,YCnt] = True
              Then Write('Û')
              Else Write('.');
          End;
    End;


  Procedure StoreGrid;

    Var XCnt,YCnt : Integer;
        Valu : Byte;

    Begin
      For YCnt := 1 To 8 Do
        For XCnt := 1 To 16 Do
          If Grid[XCnt,YCnt]
            Then Begin
              Valu := 0;
              Write(OutFile,Valu);
              Valu := 63;
              Write(OutFile,Valu);
              Valu := 0;
              Write(OutFile,Valu);
            End Else Begin
              Valu := 0;
              Write(OutFile,Valu);
              Write(OutFile,Valu);
              Write(OutFile,Valu);
            End;
    End;
    

  Begin
    Assign(OutFile,'GridClr.BIN');
    ReWrite(OutFile);
    For GridCount := 1 To 8 Do
      Begin
        ClrScr;
        ClearGrid;
        Done := False;
        XPos := 1;
        YPos := 1;
        Repeat
          GotoXY(1,1);
          Write('GridCount = ',GridCount);
          DrawGrid;
          GotoXY(31+XPos,8+YPos);
          Repeat Until Keypressed;
          Key := ReadKey;
          If Ord(Key) = 0
            Then Case Ord(ReadKey) Of
              72 : YPos := YPos - 1;
              75 : XPos := XPos - 1;
              77 : XPos := XPos + 1;
              80 : YPos := YPos + 1;
            End
            Else Case Upcase(Key) Of
              ' ' : Grid[XPos,YPos] := True;
              'R' : ClearGrid;
              'D' : Done := True;
            End;
        Until Done;
        StoreGrid;
      End;
    Close(OutFile);
  End.
