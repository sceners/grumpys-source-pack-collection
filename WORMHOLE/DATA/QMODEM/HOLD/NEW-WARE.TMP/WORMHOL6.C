#include<stdio.h>
#include<stdlib.h>
#include<dos.h>
#include<conio.h>
#include<math.h>

#define STRETCH 25
#define SIZE    40
#define FAC             1
#define PI              3.14159265358979323846
#define XCENTER 160
#define YCENTER 50
#define DIVS    1200
#define SPOKES  2400
#define NUMSQT  20

//grfx routines

char far *p;

void initgr256(void)     //Tested
{
asm{
	mov ah,00h
	mov al,13h
	int 10h
   }
   p=(char *)MK_FP(0xa000,0);
}
void deinit(void)       //Tested
{
asm{
	mov ah,00h
	mov al,03h
	int 10h
   }
}

void setpalcol(short int color, short int red, short int green, short int blue)
{
asm {
	mov dx,03c8h
	mov ax,color
	out dx,al
	inc dx
	mov ax,red
	out dx,al
	mov ax,green
	out dx,al
	mov ax,blue
	out dx,al
	};
}
void plot(int x,int y,int color)
{
p[x+320*y]=color;
}

void waitfor(void)
{
asm MOV     DX,3DAh;
Wait: asm   IN      AL,DX
asm TEST    AL,08h
asm JZ      Wait
Retr: asm   IN      AL,DX
asm         TEST    AL,08h
asm         JNZ     Retr
}

void setpal(void)
	{
	int k,l;
	for (k=0;k<15;k++)
		for(l=0;l<15;l++)
			{
			setpalcol(k+15*l+1,4*(k%15),4*(l%15),63);
			setpalcol(0,0,0,0);
			}
	}

//Do all the work!
//convert r,theta,z to x,y,x to screen x,y
//plot the point
//z=-1.0+(log(2.0*j/DIVS) is the line that sets the math eqn for plot
//Feel free to try other functions!
//Cylindrical coordinates, i.e. z=f(r,theta)

void transarray(void)
	{
	float x,y,z;
	int i,j,color;
	for(j=1;j<DIVS+1;j++)
		for(i=0;i<SPOKES;i++)
			{
			z=-1.0+(log(2.0*j/DIVS));
			x=(320.0*j/DIVS*cos(2*PI*i/SPOKES));
			y=(240.0*j/DIVS*sin(2*PI*i/SPOKES));
			y=y-STRETCH*z;
			x+=XCENTER;
			y+=YCENTER;
			color=((i/8)%15)+15*((j/6)%15)+1;
			if ((x>=0)&&(x<=320)&&(y>=0)&&(y<=200))
				plot((int) x,(int) y,color);
			}
	}

void main(void)
	{
	initgr256();
	setpal();
	transarray();
	getch();
	deinit();
	}
