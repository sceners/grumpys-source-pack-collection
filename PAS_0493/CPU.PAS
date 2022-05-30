{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 411 of 473
From : Salim Samaha                        1:167/110.0          08 Apr 93  15:55
To   : Giovanni Palmiotto                  1:167/110.0
Subj : Pasal Programming Problems
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
I got this routine here a while ago, it works well in detecting the CPU. }

{$D-} {$L-}
Program Cpuu;
 
Const
   Cpu :  Array[1..4] of String[5] = ('8086','80286','80386','80486');
   Cpu8086  = 1;
   Cpu80286 =2;
   Cpu80386 = 3;
   Cpu80486 = 4;
 
Function GetCPU_Type: Byte; Assembler;
Asm
 MOV   DX,Cpu8086
 PUSH  SP
 POP   AX
 CMP   SP,AX
 JNE   @OUT
 MOV   DX, Cpu80286
 PUSHF
 
 POP   AX
 OR   AX,4000h
 PUSH  AX
 POPF
 PUSHF
 POP   AX
 TEST  AX,4000h
 JE   @OUT
 MOV DX, Cpu80386
 {"DB 66h" indicates '386 extended instruction}
 DB 66h; MOV   BX, SP      {MOV EBX, ESP}
 DB 66h, 83h, 0E4h, 0FCh   {AND ESP, FFFC}
 DB 66h; PUSHF             {PUSHFD}
 DB 66h; POP AX            {POP EAX}
 DB 66h; MOV   CX, AX      {MOV ECX, EAX}
 DB 66h, 35h, 00h
 DB 00h, 04h, 00           {XOR EAX, 00040000}
 DB 66h; PUSH   AX     {PUSH EAX}
 
 DB 66h; POPF              {POPFD}
 DB 66h; PUSHF             {PUSHFD}
 DB 66h; POP   AX     {POP EAX}
 DB 66h, 25h, 00h
 DB 00h, 04h, 00h          {AND EAX, 00040000}
 DB 66h, 81h, 0E1h, 00h
 DB 00h, 04h, 00h          {AND ECX, 00040000}
 DB 66h; CMP   AX, CX      {CMP EAX, ECX}
 JE @Not486
 MOV DX, Cpu80486
@Not486:
 DB 66h; PUSH   CX         {PUSH EXC}
 DB 66h; POPF              {POPFD}
 DB 66h; MOV   SP, BX      {MOV ESP, EBX}
@Out:
 MOV AX, DX
end;
 
begin
   Writeln; Writeln('I detected an ',Cpu[GetCpu_Type],' chip.');
end.

Good luck in finishing your program.

                                SAL

--- Maximus/2 2.01wb
 * Origin: Programmer's Quest BBS (1:167/110)

