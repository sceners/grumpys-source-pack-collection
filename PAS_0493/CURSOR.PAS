{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 427 of 473
From : Jon Jasiunas                        1:273/216.0          08 Apr 93  21:56
To   : Daniel Shapiro
Subj : Hiding cursor
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DS>      I have another one- How do I "hide" the cursor?  So when it is waiting
  >for input, I won't see that stupid little blinking cursor there...

    cut here --- }
unit Cursor;

interface

uses
  Crt, Dos;

type
  CursorType = (cmOn, cmOff, cmUnderline, cmHalf, cmBlock);

procedure GetCursorMode(var Regs : Registers);

implementation

  procedure GetCursorMode(var Regs : Registers);
  begin
    Regs.Ah := $03;
    Intr($10, Regs);
  end;  { GetCursorMode }

procedure SetCursor(Mode : CursorType);
var
  Regs : Registers;

begin   { SetCursor }
  GetCursorMode(Regs);
  With Regs do
    begin
      Case Mode of
        cmOn : Ch := Ch and $1F;
        cmOff: Ch := Ch or $20;
        Else
          Case Lastmode of
            $07 : begin
                    Case Mode of
                      cmUnderline : Ch := $0B;
                      cmHalf      : Ch := $07;
                      cmBlock     : Ch := $00;
                    end;  { Case Mode }
                    Cl := $0C;
                  end { $07 }
          Else
            begin
              Case Mode of
                cmUnderline : Ch := $06;
                cmHalf      : Ch := $04;
                cmBlock     : Ch := $00;
              end;  { Case Mode }
              Cl := $07;
            end;  { Else Case }
          end;  { Case Lastmode }
      end;  { Case Mode }
      Ah := $01;
    end;  { With Regs }
  Intr($10, Regs);
end;  { SetCursor }

end.