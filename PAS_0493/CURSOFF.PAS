{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 246 of 286                                                               
From : Michael Fortson                     1:141/495.0          08 Apr 93  21:41 
To   : Daniel Shapiro                                                            
Subj : cursor?                                                                
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 -=> Quoting Daniel Shapiro to All <=-
 
 DS> I have another one- How do I "hide" the cursor?  So when it is
 DS> waiting for input, I won't see that stupid little blinking cursor
 DS> there... 


Here's some code that should do it. }

procedure CursOff; assembler;    
asm
  mov ah,3       { get cursor }
  xor BX,BX
  int 10h
  or ch,20h    { Make OFF}
  mov ah,1  { set new cursor }
  int 10h
end;

procedure CursOn; assembler;
asm
  mov ah,3     { get  cursor }
  xor BX,BX  
  int 10h
  and ch,1fh    { make ON }
  mov ah,1     { set new cursor }
  int 10h
end;


begin
  Writeln('The cursor will now be turned off');
  CursOff;
  readln;
  Writeln('Turning the cursor back on');
  CursOn;
  readln;
end.