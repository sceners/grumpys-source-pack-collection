{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 342 of 352
From : Sean Palmer                         1:104/123.0          13 Apr 93  13:52
To   : David Jirku
Subj : Fast math
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 DJ> I was just wondering how to speed up some math-intensive
 DJ> routines I've got here. For example, I've got a function
 DJ> that returns the distance between two objects:

 DJ> This is way to slow. I know assembly can speed it up, but
 DJ> I know nothing about asm. so theres the problem. Please
 DJ> help me out, any and all source/suggestions welcome!

I can whip up this integer square-root algorithm in assembly to use
386 registers... will be REAL fast! Else I could post the 16-bit version
I guess...

This is tested code. Works on my 386sx fine... Auto-rounds the result. }

function iSqrt(x:longint):word;assembler;asm  {requires a 386, and TP 6.0}
 db $66; xor ax,ax;            {xor eax,eax}
 db $66; xor dx,dx;            {xor edx,edx}
 db $66; mov di,word ptr x;    {mov edi,x}
 mov cx,32;
@L:
 db $66; shl di,1;             {shl edi,1}
 db $66; rcl dx,1;             {rcl edx,1}
 db $66; shl di,1;             {shl edi,1}
 db $66; rcl dx,1;             {rcl edx,1}
 db $66; shl ax,1;             {shl eax,1}
 db $66; mov bx,ax;            {mov ebx,eax}
 db $66; shl bx,1;             {shl ebx,1}
 db $66; inc bx;               {inc ebx}
 db $66; cmp dx,bx;            {cmp edx,ebx}
 jl @S;
 db $66; sub dx,bx;            {sub edx,ebx}
 db $66; inc ax;               {inc eax}
@S: loop @L;
 db $66; add ax,$8000; dw 0;   {add eax,$00008000}  {round result in hi word}
 db $66; shr ax,16;            {shr eax,16}  {to ax}
 end;