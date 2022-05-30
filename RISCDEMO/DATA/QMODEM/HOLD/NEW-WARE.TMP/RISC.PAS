Program RiSC_Demo;
uses
  crt,graph;

{$M 4000, 9800, 9800}
{$L MOD-obj.OBJ} 	        { Link in Object file }

{$F+} 				{ force calls to be 'far'}
procedure modvolume(v1,v2,v3,v4:integer); external ; {Can do while playing}
procedure moddevice(var device:integer); external ;
procedure modsetup(var status:integer;device,mixspeed,pro,loop:integer;var str:string); external ;
procedure modstop; external ;
procedure modinit; external;
{$F-}

const
  MaxNumVerts=100;
  MaxNumEdges=100;

label
  ns;
type
  CorrectInput=set of char;
  point=record
          x,y:real;
        end;
  point3D=record
            x,y,z:real;
          end;
  vector=record
           dx,dy:real;
         end;
  vector3D=record
             dx,dy,dz:real;
           end;
  matrix3=array[1..3,1..3] of real;
  affine=record
           mat:array[1..2,1..2] of real;
           tr:vector
         end;
  affine3D=record
             mat:array[1..3,1..3] of real;
             tr:vector3D
           end;
  wireframe=record
              numverts:0..MaxNumVerts;
              vert:array[1..MaxNumVerts] of point3D;
              numedge:0..MaxNumEdges;
              edge:array[1..MaxNumEdges, 1..2] of 1..MaxNumVerts
            end;

var
  screen:text;

procedure Line_co(p1,p2:Point);
const
  maxx=640;
  maxy=350;
var
  dx1,dy1,dx2,dy2:integer;
  offset:real;
begin
  offset:=(maxx-maxy)/4.0;
  dx1:=round(maxy*p1.x+offset+250);
  dy1:=round(maxy*p1.y+225);
  dx2:=round(maxy*p2.x+offset+250);
  dy2:=round(maxy*p2.y+225);
  Line(dx1,dy1,dx2,dy2);
end;

procedure Rotate3Dx(theta:real ; var Tran:affine3D);
var
  s,c:real;
begin
  c:=cos(theta);
  s:=sin(theta);
  with Tran do
    begin
      mat[1,1]:=1;mat[1,2]:=0;mat[1,3]:=0;
      mat[2,1]:=0;mat[2,2]:=c;mat[2,3]:=s;
      mat[3,1]:=0;mat[3,2]:=-s;mat[3,3]:=c;
      tr.dx:=0.0;
      tr.dy:=0.0;
      tr.dz:=0.0;
    end;
end;

procedure Rotate3Dy(theta:real ; var Tran:affine3D);
var
  s,c:real;
begin
  c:=cos(theta);
  s:=sin(theta);
  with Tran do
    begin
      mat[1,1]:=c;mat[1,2]:=0;mat[1,3]:=-s;
      mat[2,1]:=0;mat[2,2]:=1;mat[2,3]:=0;
      mat[3,1]:=s;mat[3,2]:=0;mat[3,3]:=c;
      tr.dx:=0.0;
      tr.dy:=0.0;
      tr.dz:=0.0;
    end;
end;

procedure Rotate3Dz(theta:real ; var Tran:affine3D);
var
  s,c:real;
begin
  c:=cos(theta);
  s:=sin(theta);
  with Tran do
    begin
      mat[1,1]:=c;mat[1,2]:=s;mat[1,3]:=0;
      mat[2,1]:=-s;mat[2,2]:=c;mat[2,3]:=0;
      mat[3,1]:=0;mat[3,2]:=0;mat[3,3]:=1;
      tr.dx:=0.0;
      tr.dy:=0.0;
      tr.dz:=0.0;
    end;
end;

procedure Set_Translate(x,y,z:real ; var Tran:affine3D);
begin
  with Tran do
    begin
      mat[1,1]:=1;mat[1,2]:=0;mat[1,3]:=0;
      mat[2,1]:=0;mat[2,2]:=1;mat[2,3]:=0;
      mat[3,1]:=0;mat[3,2]:=0;mat[3,3]:=1;
      tr.dx:=x;
      tr.dy:=y;
      tr.dz:=z;
    end;
end;

procedure Set_Scale3D(sx,sy,sz:real;var Tran:affine3D);
begin
  with Tran do
    begin
      mat[1,1]:=(1/sx);mat[1,2]:=0;mat[1,3]:=0;
      mat[2,1]:=0;mat[2,2]:=(1/sy);mat[2,3]:=0;
      mat[3,1]:=0;mat[3,2]:=0;mat[3,3]:=(1/sz);
      tr.dx:=0;
      tr.dy:=0;
      tr.dz:=0;
    end;
end;


procedure Transform3D(Tran:affine3D ; var P:point3D; var Q:point3D);
begin
  with Tran do
    begin
      Q.x:=mat[1,1]*P.x+mat[2,1]*P.y+mat[3,1]*P.z+tr.dx;
      Q.y:=mat[1,2]*P.x+mat[2,2]*P.y+mat[3,2]*P.z+tr.dy;
      Q.z:=mat[1,3]*P.x+mat[2,3]*P.y+mat[3,3]*P.z+tr.dz;
      P:=Q;
    end;
end;

procedure Persp_x(p_in:point3D; E:real; var p_out:point);
var
  t_hit:real;
begin
  begin
    t_hit:=1.0/(1.0-p_in.x/E);
    p_out.x:=p_in.y*t_hit;
    p_out.y:=p_in.z*t_hit;
  end
end;

procedure Persp_y(p_in:point3D; E:real; var p_out:point);
var
  t_hit:real;
begin
  begin
    t_hit:=1.0/(1.0-p_in.y/E);
    p_out.x:=p_in.z*t_hit;
    p_out.y:=p_in.x*t_hit;
  end
end;

procedure Persp_z(p_in:point3D; E:real; var p_out:point);
var
  t_hit:real;
begin
  begin
    t_hit:=1.0/(1.0-p_in.z/E);
    p_out.x:=p_in.y*t_hit;
    p_out.y:=p_in.x*t_hit;
  end
end;


procedure ViewObject(var obj:wireframe ; Tran:affine3D ; E:real ; Col:integer );
var
  i:integer;
  Q:point3D;
  pt:array[1..MaxNumVerts] of point;
begin
  with obj do
    begin
      for i:=1 to numverts do
      begin
        Transform3D(Tran,vert[i],Q);
        Persp_x(Q,E,pt[i]);
        vert[i]:=Q;
      end;
      setcolor(Col);
      for i:=1 to numedge do
        Line_co(pt[edge[i,1]],pt[edge[i,2]]);
      setcolor(0);
      for i:=1 to numedge do
        Line_co(pt[edge[i,1]],pt[edge[i,2]]);
    end;
end;

procedure menu;
begin
  setcolor(10);
  outtextxy(3,3,'    Left, Up, & Right    ');
  outtextxy(3,13,'    Arrow Keys change    ');
  outtextxy(3,23,'  x, y, and z Rotation.  ');
  outtextxy(3,43,'   [INS] and [DEL] to    ');
  outtextxy(3,53,' Increase/Decrease Size  ');
  outtextxy(3,73,'     [,] and [.] to      ');
  outtextxy(3,83,' Increase/Decrease Speed ');
  outtextxy(3,103,'[space] to Refresh Screen');
  outtextxy(3,123,'    [ESC] to Quit!!!     ');
  setcolor(blue);
 outtextxy(3,400,'      by The Hacker     ');
 outtextxy(3,420,' MOD routines via MOD-OBJ');
 outtextxy(3,430,'  (c) 1992 by Mark J Cox');
  setcolor(green);
 outtextxy(225,460,'RiSC - We Fuckin'' ROCK!');
end;

var
  objfile:text;
  d,dd,lp,ctr,vnum,enum,ev1,ev2,l1,l2,l3,dev,mix,stat,pro,loop:integer;
  fx,fy,fz,tpp:real;
  obj:wireframe;
  graphdriver,graphmode,errorcode:integer;
  tramat:affine3D;
  ch,ch2:char;
  modname:string;
  good:CorrectInput;
  small:integer;

begin
  assign(screen,'con');
  rewrite(screen);
  writeln(screen,#27,'[2J');
  writeln;
  writeln(screen,#27,'[10B');
  writeln(screen,#27,'[1;5;31m          NOTE:  The demo runs quite a bit slower with music playing!!!');
  writeln(screen,#27,'[0;1;35m');
  writeln(screen,#27,'[15A');
  modinit;
  moddevice (dev); { Returns device number in DEV or 255 if 'no sound' }
  if dev=255 then
    goto ns;
  if paramcount=0 then
    modname:='risc.mod'
  else
    modname:=paramstr(1);
  mix:=10000;
  pro:=0;          {Leave at 0}
  loop:=4;        {4 means mod will play forever}
  modvolume (255,255,255,255);    { Full volume }
  modsetup (stat,dev,mix,pro,loop,modname);
  case stat of
    1: begin
         writeln(screen,#27,'[2J');
         for ctr:=1 to 10 do
           writeln;
         writeln(screen,#27,'[1;5;35m   ERROR! ',#27,'[0m Input file not found or not a MOD file!');
         writeln;
         write(screen,'   Hit RETURN to end.');
         readln;
       end;
    2: begin
         writeln(screen,#27,'[2J');
         for ctr:=1 to 10 do
           writeln;
         writeln(screen,#27,'[1;5;35m   ERROR! ',#27,'[0m MOD already playing!');
         writeln;
         write(screen,'   Hit RETURN to end.');
         readln;
       end;
    4: begin
         writeln(screen,#27,'[2J');
         for ctr:=1 to 10 do
           writeln;
         writeln(screen,#27,'[1;5;35m   ERROR! ',#27,'[0m Out of Memory!');
         writeln;
         write(screen,'   Hit RETURN to end.');
         readln;
       end;
  else
ns: begin
      graphdriver := detect;
      graphmode :=1;
      initgraph(graphdriver,graphmode,'');
      cleardevice;
      menu;
      setcolor(10);
      good:=[#27,'.',',',#83,#82,' ',#72,#75,#77];
      assign (objfile,'risc.dat');
      reset(objfile);
      readln(objfile,obj.numverts);
      for ctr:=1 to obj.numverts do
        begin
          read(objfile,obj.vert[ctr].x);
          read(objfile,obj.vert[ctr].y);
          readln(objfile,obj.vert[ctr].z);
        end;
      readln(objfile,obj.numedge);
      for ctr:=1 to obj.numedge do
        begin
          read(objfile,obj.edge[ctr,1]);
          readln(objfile,obj.edge[ctr,2]);
        end;
      close(objfile);
      tpp:=0.12;
      ch:=#72;
      small:=1;
      Set_Scale3D(20,20,20,tramat);
      ViewObject(obj,tramat,8,4);
      while ch<> #27 do
        begin
          if KeyPressed then
            ch:=ReadKey;
          if ch in good then
            ch:=ch
          else
            ch:=#72;
          case ch of
            '.' : begin                                { speed }
                    tpp:=tpp+0.020;
                    ch:=ch2;
                  end;
            ',' : begin                                { speed }
                    tpp:=tpp-0.020;
                    ch:=ch2;
                  end;
            #83 : begin                                { size + }
                    Set_Scale3D(1.1,1.1,1.1,tramat);
                    ViewObject(obj,tramat,4,4);
                    ch:=ch2;
                  end;
            #82 : begin                                { size - }
                    Set_Scale3D(0.9,0.9,0.9,tramat);
                    ViewObject(obj,tramat,4,4);
                    ch:=ch2;
                  end;
            ' ' : begin                                { refresh screen }
                    ch:=ch2;
                    menu;
                  end;
            #72 : begin                                { rotate on X }
                    Rotate3Dx(tpp,tramat);
                    ViewObject(obj,tramat,4,4);
                    ch2:=#72;
                  end;
            #75  : begin                               { rotate on Y }
                     Rotate3Dy(tpp,tramat);
                     ViewObject(obj,tramat,4,4);
                     ch2:=#75;
                   end;
            #77  : begin                               { rotate on Z }
                     Rotate3Dz(tpp,tramat);
                     ViewObject(obj,tramat,8,4);
                     ch2:=#77;
                   end;
          end;{case}
        end;{while}
      cleardevice;
      closegraph;
    end;
  end; {case}
  modstop;
  writeln(screen,#27,'[2J');
  writeln;
  writeln(screen,#27,'[1;5;31m   RiSC - We Fuckin'' ROCK!  ');
  writeln(screen,#27,'[0;1;35m');
end.
