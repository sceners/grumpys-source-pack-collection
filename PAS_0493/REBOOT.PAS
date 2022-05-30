{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 595 of 708
From : Reynir Stefansson                   2:391/20.0           14 Apr 93  17:33
To   : All
Subj : Reboots, warm or cold.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
     For anyone wondering how to reboot a PClone from within Turbo Pascal: }

UNIT Reboot;

INTERFACE

PROCEDURE ColdStart;
PROCEDURE WarmStart;

IMPLEMENTATION

PROCEDURE ColdStart;
BEGIN
   MemW[$40:$72] := 0;
   Inline($EA/0/0/$FF/$FF);
END;

PROCEDURE WarmStart;
BEGIN
   MemW[$40:$72] := $1234;
   Inline($EA/0/0/$FF/$FF);
END;

END.