Program Clip_Picture;

  Uses
    Crt;

  Const
    VideoSeg = $0A000;

  Type
    PicType = Array[1..16192] Of Byte;

  Var
    PicPal : Array[1..768] Of Byte;
    QuarterPic    : PicType;
    PictureFN     : String;
    PictureFile   : File of PicType;
    PointerValue,
    Red,
    Green,
    Blue          : Byte;
    ClipXLen,
    ClipYLen      : Integer;
    ByteFile      : File of Byte;


  Procedure VideoMode ( Mode : Byte );

    Begin { VideoMode }
      Asm
        Mov  AH,00
        Mov  AL,Mode
        Int  10h
      End;
    End;  { VideoMode }


  Procedure GetPointerAttrib;

    Begin { GetPointerAttrib }
      Write('Enter pointer value: ');
      Readln(PointerValue);
      Write('Enter pointer attrib RED   intensity: ');
      Readln(Red);
      Write('Enter pointer attrib GREEN intensity: ');
      Readln(Green);
      Write('Enter pointer attrib BLUE  intensity: ');
      Readln(Blue);
    End;  { GetPointerAttrib }


  Procedure LoadPalette;

    Var
      Count : Integer;

    Begin { LoadPalette }
      Port[$3C8] := 0;
      For Count := 1 To 768 Do
        Port[$3C9] := PicPal[Count];
      Port[$3C8] := PointerValue;             {* Set pointer value last *}
      Port[$3C9] := Red;                      {* to overwrite any color *}
      Port[$3C9] := Green;
      Port[$3C9] := Blue;
    End;  { LoadPalette }


  Procedure LoadPicture;

    Begin { LoadPicture }
      Read(PictureFile,QuarterPic);
      Move(QuarterPic,PicPal,768);       {* Get/store the palette *}
      LoadPalette;
      Move(QuarterPic[769],Mem[VideoSeg:0],15424);
      Read(PictureFile,QuarterPic);
      Move(QuarterPic,Mem[VideoSeg:15424],16192);
      Read(PictureFile,QuarterPic);
      Move(QuarterPic,Mem[VideoSeg:31616],16192);
      Read(PictureFile,QuarterPic);
      Move(QuarterPic,Mem[VideoSeg:47808],16192);
      Close(PictureFile);
    End;  { LoadPicture }


  Procedure LowToHigh ( Var First, Second : Integer );

    Var
      Temp : Integer;

    Begin { LowToHigh }
      If First > Second
        Then Begin
          Temp := First;
          First := Second;
          Second := Temp;
        End;
    End;  { LowToHigh }


  Procedure SaveClip ( StartX, StartY, EndX, EndY : Integer );

    Var CountX,CountY : Integer;

    Begin { SaveClip }
      LowToHigh(StartX,EndX);
      LowToHigh(StartY,EndY);
      Assign(ByteFile,'CLIPPIC.DAT');
      ReWrite(ByteFile);
      For CountY := StartY To EndY Do
        For CountX := StartX To EndX Do
          Write(ByteFile,Mem[VideoSeg:CountY*320+CountX]);
      Close(ByteFile);
      ClipXLen := EndX-StartX+1;
      ClipYLen := EndY-StartY+1;
    End;  { SaveClip }


  Procedure ClipPicture;

    Var
      BoxHidden : Array[1..320*2+198*2] Of Byte;


    Procedure DrawBox ( StartX, StartY, EndX, EndY : Integer );

      Var BoxCnt,Count : Integer;

      Begin { DrawBox }
        LowToHigh(StartX,EndX);
        LowToHigh(StartY,EndY);

        {* Store what box touches *}

        Move(Mem[VideoSeg:StartY*320+StartX],BoxHidden,EndX-StartX+1);
        BoxCnt := EndX-StartX+2;
        For Count := StartY+1 To EndY-1 Do
          Begin
            BoxHidden[BoxCnt] := Mem[VideoSeg:Count*320+StartX];
            BoxHidden[BoxCnt+1] := Mem[VideoSeg:Count*320+EndX];
            BoxCnt := BoxCnt + 2;
          End;
        Move(Mem[VideoSeg:EndY*320+StartX],BoxHidden[BoxCnt],EndX-StartX+1);

        {* Draw Box *}

        FillChar(Mem[VideoSeg:StartY*320+StartX],EndX-StartX+1,Chr(PointerValue));
        For Count := StartY+1 To EndY-1 Do
          Begin
            Mem[VideoSeg:Count*320+StartX] := PointerValue;
            Mem[VideoSeg:Count*320+EndX] := PointerValue;
          End;
        FillChar(Mem[VideoSeg:EndY*320+StartX],EndX-StartX+1,Chr(PointerValue));

      End;  { DrawBox }


    Procedure RestoreBoxHidden ( StartX, StartY, EndX, EndY : Integer );

      Var Count,BoxCnt : Integer;

      Begin { RemoveBoxHidden }
        LowToHigh(StartX,EndX);
        LowToHigh(StartY,EndY);

        {* Restore what was in the box *}

        Move(BoxHidden,Mem[VideoSeg:StartY*320+StartX],EndX-StartX+1);
        BoxCnt := EndX-StartX+2;
        For Count := StartY+1 To EndY-1 Do
          Begin
            Mem[VideoSeg:Count*320+StartX] := BoxHidden[BoxCnt];
            Mem[VideoSeg:Count*320+EndX] := BoxHidden[BoxCnt+1];
            BoxCnt := BoxCnt + 2;
          End;
        Move(BoxHidden[BoxCnt],Mem[VideoSeg:EndY*320+StartX],EndX-StartX+1);
      End;  { RemoveBoxHidden }


    Var
      Key : Char;
      TopActive,
      ClipDone : Boolean;
      TopXPos,
      TopYPos,
      CursorXPos,
      CursorYPos  : Integer;
      CursorHidden : Byte;

    Begin { ClipPicture }
      TopActive := False;
      CursorXPos := 0;
      CursorYPos := 0;
      ClipDone := False;
      Repeat
        CursorHidden := Mem[VideoSeg:CursorXPos+CursorYPos*320];
        Mem[VideoSeg:CursorXPos+CursorYPos*320] := PointerValue;
        Repeat Until Keypressed;
        Key := ReadKey;
        Mem[VideoSeg:CursorXPos+CursorYPos*320] := CursorHidden;
        If TopActive
          Then RestoreBoxHidden(TopXPos,TopYPos,CursorXPos,CursorYPos);
        If Ord(Key) = 0
          Then Begin
            Case Ord(ReadKey) Of
{Left}        75  : If CursorXPos > 0 Then Dec(CursorXPos);
{Right}       77  : If CursorXPos < 319 Then Inc(CursorXPos);
{Up}          72  : If CursorYPos > 0 Then Dec(CursorYPos);
{Down}        80  : If CursorYPos < 199 Then Inc(CursorYPos);
            End;
            If TopActive Then DrawBox(TopXPos,TopYPos,CursorXPos,CursorYPos);
          End
          Else Case Upcase(Key) Of
            'T' : If TopActive
                    Then TopActive := False
                    Else Begin
                      TopActive := True;
                      TopXPos := CursorXPos;
                      TopYPos := CursorYPos;
                      DrawBox(TopXPos,TopYPos,CursorXPos,CursorYPos);
                    End;
            'B' : If TopActive
                    Then Begin
                      SaveClip(TopXPos,TopYPos,CursorXPos,CursorYPos);
                      ClipDone := True;
                    End;
            ' ' : If TopActive Then TopActive := False;
            'Q' : Begin
                    VideoMode(3);
                    Halt(1);
                  End;
          End;
      Until ClipDone;
    End;  { ClipPicture }


  Function LeftJustify ( AnyStr : String;  MaxSpaces : Integer ) : String;

    Var
      Count : Integer;
      TempStr : String;

    Begin { LeftJustify }
      TempStr := AnyStr;
      If Length(AnyStr) < MaxSpaces
        Then For Count := 1 To MaxSpaces-Length(AnyStr) Do
          TempStr := TempStr + ' ';
      LeftJustify := TempStr;
    End;  { LeftJustify }


  Procedure FixColorValues;

    Type

      ModifyRec = Record
        ColorFrom,
        ColorTo,
        Red,
        Green,
        Blue    : Byte;
      End;


    Var

      ColorModify : Array[1..256] Of ModifyRec;
      NumColors : Integer;
      Assembly : Boolean;
      StartColor : Byte;
      DoStartColor : Boolean;
      PicFN : String;
      PicFile : Text;
      StoredCnt : Integer;
      PicName : String;


    Procedure PascalOrAssembly;

      Var
        Response : Char;

      Begin { PascalOrAssembly }
        Writeln;
        Response := ' ';
        Repeat
          Write('Write into [A]ssembly or [P]ascal format? ');
          Readln(Response);
        Until Upcase(Response) In ['A','P'];
        Assembly := Upcase(Response) = 'A';
        Writeln;
        Writeln;
      End;  { PascalOrAssembly }


    Procedure GetStartingColor;

      Var
        Response : Char;

      Begin { GetStartingColor }
        Writeln;
        Writeln;
        Writeln('Automatically incrementing the color values will compact the');
        Writeln('palette table.  You may also choose to manually enter in the');
        Writeln('color value.');
        Writeln;
        Repeat
          Writeln('Do you want to [A]utomatically modify the table or [M]anually');
          Write('enter in your own values? ');
          Readln(Response);
        Until Upcase(Response) In ['A','M'];
        DoStartColor := Upcase(Response) = 'A';
        If DoStartColor
          Then Begin
            Write('Enter in the starting value to increment from: ');
            Readln(StartColor);
          End;
      End;  { GetStartingColor }


    Function AlreadyModified ( InB : Byte ) : Boolean;

      Var
        Count : Integer;

      Begin { AlreadyModified }
        AlreadyModified := False;
        For Count := 1 To NumColors Do
          If InB = ColorModify[Count].ColorFrom
            Then AlreadyModified := True;
      End;  { AlreadyModified }


    Function Modified ( InB : Byte ) : Byte;

      Var
        Count : Integer;

      Begin { Modified }
        For Count := 1 To NumColors Do
          If InB = ColorModify[Count].ColorFrom
            Then Modified := ColorModify[Count].ColorTo;
      End;  { Modified }


    Procedure Modify ( InB : Byte );

      Begin { Modify }
        NumColors := NumColors + 1;
        ColorModify[NumColors].ColorFrom := InB;
        ColorModify[NumColors].Red := PicPal[InB*3+1];
        ColorModify[NumColors].Green := PicPal[InB*3+2];
        ColorModify[NumColors].Blue := PicPal[InB*3+3];
        If DoStartColor
          Then ColorModify[NumColors].ColorTo := NumColors+StartColor-1
          Else With ColorModify[NumColors] Do
            Begin
              Write(ColorFrom:4,' [',Red:2,',',Green:2,',',Blue:2,']  -->  ');
              Readln(ColorTo);
            End;
      End;  { Modify }


    Procedure InitTextFile;

      Begin { InitTextFile }
        Write('Enter filename and extension to store text: ');
        ReadLn(PicFN);
        Assign(PicFile,PicFN);
        ReWrite(PicFile);
        If Assembly
          Then Begin
            Writeln(PicFile,'; Picture dimensions');
            Writeln(PicFile,LeftJustify(PicName+'_XLen',16),'EQU     ',ClipXLen,'d');
            Writeln(PicFile,LeftJustify(PicName+'_YLen',16),'EQU     ',ClipYLen,'d');
            Writeln(PicFile);
            Writeln(PicFile,LeftJustify(PicName+'_Pic',16),'LABEL   BYTE');
          End
          Else Begin
            Writeln(PicFile,'{* Picture dimensions *}');
            Writeln(PicFile,LeftJustify(PicName+'_XLen',14),'=       ',ClipXLen,';');
            Writeln(PicFile,LeftJustify(PicName+'_YLen',14),'=       ',ClipYLen,';');
            Writeln(PicFile);
            Writeln(PicFile,PicName+'_Pic : Array[1..',ClipXLen,'*',ClipYLen,'] Of Byte = (');
          End;
      End;  { InitTextFile }


    Procedure StoreByteToPicFile (InB : Byte; EndOfFile: Boolean);

      Begin { StorePicToFile }
        If StoredCnt = 0
          Then If Assembly
            Then Write(PicFile,'                DB      ',InB:3)
            Else Write(PicFile,'        ',InB:3)
          Else Write(PicFile,',',InB:3);
        Inc(StoredCnt);
        If StoredCnt > 12
          Then Begin
            If Assembly
              Then Writeln(PicFile)
              Else If Not EndOfFile Then Writeln(PicFile,',');
            StoredCnt := 0;
          End;
      End;  { StorePicToFile }


    Procedure FinishPicFile;

      Begin { FinishPicFile }
        If Assembly
          Then Writeln(PicFile)
          Else Writeln(PicFile,');');
        Writeln(PicFile);
        Writeln(PicFile);
      End;  { FinishPicFile }


    Procedure StorePicToFile;

      Var
        InByte : Byte;
        CountX,CountY : Integer;

      Begin { StorePicToFile }
        If DoStartColor
          Then Write('Storing picture');
        NumColors := 0;
        Assign(ByteFile,'CLIPPIC.DAT');
        Reset(ByteFile);
        For CountY := 1 To ClipYLen Do
          Begin
            For CountX := 1 To ClipXLen Do
              Begin
                Read(ByteFile,InByte);
                If Not AlreadyModified(InByte)
                  Then Modify(InByte);
                StoreByteToPicFile(Modified(InByte),(CountY = ClipYLen) And (CountX = ClipXLen));
              End;
            If DoStartColor Then Write('.');
          End;
        Close(ByteFile);
        FinishPicFile;
      End;  { StorePicToFile }



    Procedure StorePalToFile;

      Var
        Count : Integer;

      Begin { StorePalToFile }
        Writeln;
        Write('Storing palette');
        If Assembly
          Then Begin
            Writeln(PicFile,LeftJustify(PicName+'_NumColors',16),'EQU     ',NumColors,'d');
            Writeln(PicFile);
            Writeln(PicFile,LeftJustify(PicName+'_Pal',16),'LABEL   BYTE')
          End
          Else Begin
            Writeln(PicFile,LeftJustify(PicName+'_NumColors',14),'= ',NumColors,';');
            Writeln(PicFile);
            Writeln(PicFile,PicName+'_Pal : Array[1..',NumColors,'*4] Of Byte = (');
          End;
        For Count := 1 To NumColors Do
          With ColorModify[Count] Do
            Begin
              If Assembly
                Then Writeln(PicFile,'                DB      ',ColorTo:3,',',Red:3,',',Green:3,',',Blue:3)
                Else Write(PicFile,'        ',ColorTo:3,',',Red:3,',',Green:3,',',Blue:3);
              If (Not Assembly) And (Count <> NumColors)
                Then Writeln(PicFile,',');
              Write('.');
            End;
        If Not Assembly Then Writeln(PicFile,');');
      End;  { StorePalToFile }



    Begin { FixColorValues }
      StoredCnt := 0;
      VideoMode($03);
      Writeln('Clipped picture X length = ',ClipXLen);
      Writeln('Clipped picture Y length = ',ClipYLen);
      PascalOrAssembly;
      GetStartingColor;
      Write('Enter the picture label: ');
      Readln(PicName);
      InitTextFile;
      StorePicToFile;
      StorePalToFile;
      Close(PicFile);
    End;  { FixColorValues }


  Begin { Clip_Picture }
    Write('Enter picture filename and extension: ');
    Readln(PictureFN);
    Assign(PictureFile,PictureFN);
    Reset(PictureFile);
    GetPointerAttrib;
    VideoMode($13);
    LoadPicture;
    ClipPicture;
    FixColorValues;
    Writeln;
    Writeln('Done!');
  End.  { Clip_Picture }
