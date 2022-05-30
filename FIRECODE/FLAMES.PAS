program flames;
{**************************************************************************}
{*                                                                        *}
{*    FLAMES by M.D.Mackey  (C) 1993                                      *}
{*        This code released into the public domain. It may be freely     *}
{*        used, distributed and modified. I would appreciate it if        *}
{*        credit were given, however. If you have any improvements,       *}
{*        find any bugs etc. mail me at mackey@aqueous.ml.csiro.au        *}
{*        with MARK: in the subject header.                               *}
{*                                                                        *}
{**************************************************************************}


uses crt;
type bigarr=array[0..102,0..159] of integer;
var f:bigarr;
    i,j,k,l:word;
    delta:integer;
    pal:array[0..255,1..3] of byte;
    ch:char;

procedure setmode13;
assembler;
asm
  mov ax,13h
  int 10h
end;

procedure setpalette;
var mapfile:text;
    i,j:integer;

begin
  assign(mapfile,'flames5.map');  {kludgy, but it works!}
  reset(mapfile);
  for i:=0 to 255 do
  for j:=1 to 3 do
  begin
    read(mapfile,pal[i,j]);
    pal[i,j]:=pal[i,j] shr 2;
  end;
  asm
    mov si,offset pal
    mov cx,768      {no of colour registers}
    mov dx,03c8h
    xor al,al	  {First colour to change pal for = 0}
    out dx,al
    inc dx
@1: outsb
    dec cx        {safer than rep outsb}
    jnz @1
  end;
end;

begin
  setmode13;
  setpalette;
  randomize;
  ch:=' ';
  for i:=0 to 102 do
  for j:=0 to 159 do
    f[i,j]:=0;        {initialise array}

  repeat
    asm                {move lines up, averaging}
      mov cx,16159;    {no. elements to change}
      mov di,offset f
      add di,320   {di points to 1st element of f in upper row (320 bytes/row)}
@1:
      mov ax,ds:[di-2]
      add ax,ds:[di]
      add ax,ds:[di+2]
      add ax,ds:[di+320]
      shr ax,2     {divide by 4: average 4 elements of f}
      jz @2
      sub ax,1
@2:   mov word ptr ds:[di-320],ax
      add di,2
      dec cx
      jnz @1    {faster than _loop_ on 486}
    end;


    for j:=0 to 159 do  {set new bottom line}
    begin
      if random<0.4 then
        delta:=random(2)*255;
      f[101,j]:=delta;
      f[102,j]:=delta;
    end;


    asm                 {output to screen}
      mov si,offset f
      mov ax,0a000h
      mov es,ax
      mov di,0
      mov dx,100
@3:
      mov bx,2
@2:
      mov cx,160
@1:
      mov al,[si]
      mov ah,al
      mov es:[di],ax     {word aligned write to display mem}
      add di,2
      add si,2
      dec cx
      jnz @1

      sub si,320
      dec bx
      jnz @2

      add si,320
      dec dx
      jnz @3
    end;
    if keypressed then ch:=readkey;
  until ch=#27;
  asm   {restore text mode}
    mov ax,03h
    int 10h
  end;
end.