Program Binary2Asm;

  Var
    BinFileStr,
    TxtFileStr  : String;
    BinFile     : File of Byte;
    TextFile    : Text;
    InByte      : Byte;
    Count,
    CharCount   : Integer;

  Begin { Binary2Asm }
    Write('Enter binary filename and extension to convert: ');
    Readln(BinFileStr);
    Write('Enter output text filename and extension: ');
    Readln(TxtFileStr);

    Assign(BinFile,BinFileStr);
    Reset(BinFile);
    Assign(TextFile,TxtFileStr);
    ReWrite(TextFile);

    CharCount := 13;
    For Count := 1 To 3072 Do
      Begin
        If CharCount > 12
          Then Begin
            Write(TextFile,'        DB      ');
            CharCount := 0;
          End;
        Read(BinFile,InByte);
        Write(TextFile,InByte:4);
        Inc(CharCount);
        If (CharCount <= 12) And (Count <> 2048)
          Then Write(TextFile,',')
          Else Writeln(TextFile);
      End;

    Close(TextFile);
    Close(BinFile);
  End.  { Binary2Asm }
