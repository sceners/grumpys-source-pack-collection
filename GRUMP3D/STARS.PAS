{ This is a simple 3D Stars Program for Grumpy so he can see some 3D Stars }
{ written by Ken Sallot on 10/8/93 }

Program Stars(Input,Output);  { Standard Pascal Header oooh ahhhh }

Uses Dos, Crt;

Type StarRow = Array[1..80] of char;
     StarField = Array[1..25] of StarRow;

Var SlowStars, MedStars, FastStars : StarField;
    I,B : Integer; { Counter }


Procedure SetupStars;
var randfill : byte;
begin
  fillchar(SlowStars, SizeOf(SlowStars), 0);
  MedStars := SlowStars;
  FastStars := MedStars;
  Randomize;  { Install Random Seed Kernel }
  For I := 1 to 8 do
  begin
    for b := 1 to 5 do
    begin
       randfill := Random(80)+1;
       SlowStars[i*3-2][randfill] := 'ù';
    end;
    for b := 1 to 5 do
    begin
      randfill := Random(80)+1;
      MedStars[i*3-1][randfill] := 'ù';
    end;
    for b := 1 to 5 do
    begin
      RandFill := Random(80)+1;
      FastStars[i*3][randfill] := '.';
    end;
  end;
end;  { SetupStars }

Procedure SetMode13h;
Begin
  Asm
    Mov ah, 13h
    int 10h
  end
end;

Procedure DisplayAllStars;
var tpg : array[1..8000] of char;
    az1 : array[1..4000] of char;
begin
  fillchar(tpg,sizeof(tpg),0);
  Move(slowstars,az1,sizeof(slowstars));  { This aint too kosher but I know
   					    what I'se bee doin' }
  for i := 1 to 4000 do
    if az1[i]<>#0 then
    begin
      tpg[i*2-1] := az1[i];
      tpg[i*2] := #8;
    end;
  Move(Medstars,az1,sizeof(Medstars));  { This aint too kosher but I know
   					    what I'se bee doin' }
  for i := 1 to 4000 do
    if az1[i]<>#0 then
    begin
      tpg[i*2-1] := az1[i];
      tpg[i*2] := #7;  { higher intensity for medium stars }
    end;
  Move(Faststars,az1,sizeof(Faststars));  { This aint too kosher but I know
   					    what I'se bee doin' }
  for i := 1 to 4000 do
    if az1[i]<>#0 then
    begin
      tpg[i*2-1] := az1[i];
      tpg[i*2] := #15;  { higher intensity for medium stars }
    end;

  repeat                     { check for vertical retrace }
  until port[$3da] and 8=0;
  repeat until port[$3da] and 8<>0;

  move(tpg,Mem[$B800:0],sizeof(tpg));   { Dump to video }
End;

Procedure MoveStars;
var temp : starfield;
begin
  fillchar(temp,sizeof(temp),0);
  if b=4 then
  begin
   for i := 1 to 25 do
      move(slowstars[i][2],temp[i][1],79);
   slowstars := temp;
   for i := 1 to 8 do
       if random(20)=1 then slowstars[i*3-2][80] := 'ù';
  end; { if b=3 then begin }

  fillchar(temp,sizeof(temp),0);
  for i := 1 to 25 do
    move(faststars[i][2],temp[i][1],79);
  faststars := temp;
  for i := 1 to 8 do
    if random(20)=1 then faststars[i*3][80] := '.';

  fillchar(temp,sizeof(temp),0);
  if (b/2) = (b div 2) then
  begin
    for i := 1 to 25 do
      move(medstars[i][2],temp[i][1],79);
    medstars := temp;
    for i := 1 to 8 do if random(20)=1 then medstars[i*3-1][80] := 'ù';
  end;

  inc(b);
  if b=5 then b := 1;
end;


Begin
   ClrScr;
   SetupStars;
   b := 1;
   repeat
     DisplayAllStars;
     movestars;
   until keypressed;
   while keypressed do ReadKey;
   clrscr;
   WriteLn('3D Stars written by Ken Sallot ');
End.