{Converts example.txt into example.hdw ascii# 33-100 are allowed.Due to the gfx.
 all you have to do is count the numbers of bytes and write it at
 the top of the file nl.' maxtxt=....' and ofcourse recompile the hscroll.pas.
 I know you can code that but he I'm to lazy to do it all... .}
uses crt;
var f:file of char;
    p:text;
    x:integer;
    ch:char;
begin
     assign(f,'example.txt');
     reset(f);
     assign(p,'example.hdw');
     rewrite(p);
     x:=1;
     writeln(p,'const maxtxt = .....;');
     writeln(p,' txt:array[0..maxtxt] of byte = (');
     write(p,255,',');
     while not eof(f) do
     begin
          read(f,ch);
          inc(x);
          if (ord(upcase(ch))-33 < 0) or (ord(upcase(ch))-33 >57)
             then write(p,255,',')                           {255 --> blank}
          else write(p,ord(upcase(ch))-33,',');
          if x mod 20 = 0 then writeln(p);                   {use proper files!!}
     end;
     write(p,');');
     write(#7,#7);
     close(f);
     close(p);
end.
