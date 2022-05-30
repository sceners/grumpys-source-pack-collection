#include<stdio.h>
#include<conio.h>
#include<stdlib.h>
#include<dos.h>
#include"pic1.c"
#include"pic2.c"

#define         DELAY           0

char far *p;

//this is the picture being "wormed" in rgb components
//It's also upside down.  I never quite got around to fixing that.

int red[225]={
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,
};

int green[225]={
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,63,0,63,0,0,0,63,0,63,63,63,0,0,0,
0,63,0,63,0,0,0,63,0,63,0,0,63,0,0,
0,63,0,63,0,0,63,63,0,63,0,0,0,63,0,
0,63,0,63,0,0,63,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,63,0,0,63,0,63,0,0,0,63,0,
0,63,0,63,63,0,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,0,0,63,0,63,0,0,63,0,0,
0,63,0,63,0,0,0,63,0,63,63,63,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
};

int blue[225]={
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,63,0,63,0,0,0,63,0,63,63,63,0,0,0,
0,63,0,63,0,0,0,63,0,63,0,0,63,0,0,
0,63,0,63,0,0,63,63,0,63,0,0,0,63,0,
0,63,0,63,0,0,63,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,63,0,63,0,63,0,0,0,63,0,
0,63,0,63,63,0,0,63,0,63,0,0,0,63,0,
0,63,0,63,63,0,0,63,0,63,0,0,0,63,0,
0,63,0,63,0,0,0,63,0,63,0,0,63,0,0,
0,63,0,63,0,0,0,63,0,63,63,63,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
};

//below: storage for transformation

int reg[15];

//grfx routines

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
	int k;
	waitfor();
	for(k=0;k<225;k++)
		setpalcol(k+1,red[k],green[k],blue[k]);
	}

//puts wormhol6.c's pic on screen

void initscrn(void)
	{
	int i,j;
	for(i=0;i<319;i++)
		for(j=0;j<100;j++)
			{
			plot(i,j+100,pic2[(319*j+i)]);
			plot(i,j,pic1[(319*j+i)]);
			}
	}

//Up down left and right shifting routines.
//One has a bug that I haven't fixed yet.

void shiftup(void)
	{
	int k;
	for(k=0;k<15;k++)
		reg[k]=red[k];
	for(k=15;k<225;k++)
		red[k-15]=red[k];
	for(k=0;k<15;k++)
		red[k+210]=reg[k];
	for(k=0;k<15;k++)
		reg[k]=green[k];
	for(k=15;k<225;k++)
		green[k-15]=green[k];
	for(k=0;k<15;k++)
		green[k+210]=reg[k];
	for(k=0;k<15;k++)
		reg[k]=blue[k];
	for(k=15;k<225;k++)
		blue[k-15]=blue[k];
	for(k=0;k<15;k++)
		blue[k+210]=reg[k];
	delay(DELAY);
	}

void shiftdown(void)
	{
	int k;
	for(k=0;k<15;k++)
		reg[k]=red[k+210];
	for(k=209;k>=0;k--)
		red[k+15]=red[k];
	for(k=0;k<15;k++)
		red[k]=reg[k];
	for(k=0;k<15;k++)
		reg[k]=green[k+210];
	for(k=209;k>=0;k--)
		green[k+15]=green[k];
	for(k=0;k<15;k++)
		green[k]=reg[k];
	for(k=0;k<15;k++)
		reg[k]=blue[k+210];
	for(k=209;k>=0;k--)
		blue[k+15]=blue[k];
	for(k=0;k<15;k++)
		blue[k]=reg[k];
	delay(DELAY);
	}

void shiftright(void)
	{
	int k;
	for(k=0;k<15;k++)
		{
		reg[k]=red[15*k+14];
		red[15*k+14]=red[15*k+13];
		red[15*k+13]=red[15*k+12];
		red[15*k+12]=red[15*k+11];
		red[15*k+11]=red[15*k+10];
		red[15*k+10]=red[15*k+9];
		red[15*k+9]=red[15*k+8];
		red[15*k+8]=red[15*k+7];
		red[15*k+7]=red[15*k+6];
		red[15*k+6]=red[15*k+5];
		red[15*k+5]=red[15*k+4];
		red[15*k+4]=red[15*k+3];
		red[15*k+3]=red[15*k+2];
		red[15*k+2]=red[15*k+1];
		red[15*k+1]=red[15*k];
		red[15*k]=reg[k];
		reg[k]=green[15*k+14];
		green[15*k+14]=green[15*k+13];
		green[15*k+13]=green[15*k+12];
		green[15*k+12]=green[15*k+11];
		green[15*k+11]=green[15*k+10];
		green[15*k+10]=green[15*k+9];
		green[15*k+9]=green[15*k+8];
		green[15*k+8]=green[15*k+7];
		green[15*k+7]=green[15*k+6];
		green[15*k+6]=green[15*k+5];
		green[15*k+5]=green[15*k+4];
		green[15*k+4]=green[15*k+3];
		green[15*k+3]=green[15*k+2];
		green[15*k+2]=green[15*k+1];
		green[15*k+1]=green[15*k];
		green[15*k]=reg[k];
		reg[k]=blue[15*k+14];
		blue[15*k+14]=blue[15*k+13];
		blue[15*k+13]=blue[15*k+12];
		blue[15*k+12]=blue[15*k+11];
		blue[15*k+11]=blue[15*k+10];
		blue[15*k+10]=blue[15*k+9];
		blue[15*k+9]=blue[15*k+8];
		blue[15*k+8]=blue[15*k+7];
		blue[15*k+7]=blue[15*k+6];
		blue[15*k+6]=blue[15*k+5];
		blue[15*k+5]=blue[15*k+4];
		blue[15*k+4]=blue[15*k+3];
		blue[15*k+3]=blue[15*k+2];
		blue[15*k+2]=blue[15*k+1];
		blue[15*k+1]=blue[15*k];
		blue[15*k]=reg[k];
		}
	delay(DELAY);
	}

void shiftleft(void)
	{
	int k;
	for(k=0;k<15;k++)
		{
		reg[k]=red[15*k];
		red[15*k]=red[15*k+1];
		red[15*k+1]=red[15*k+2];
		red[15*k+2]=red[15*k+3];
		red[15*k+3]=red[15*k+4];
		red[15*k+4]=red[15*k+5];
		red[15*k+5]=red[15*k+6];
		red[15*k+6]=red[15*k+7];
		red[15*k+7]=red[15*k+8];
		red[15*k+8]=red[15*k+9];
		red[15*k+9]=red[15*k+10];
		red[15*k+10]=red[15*k+11];
		red[15*k+11]=red[15*k+12];
		red[15*k+12]=red[15*k+13];
		red[15*k+13]=red[15*k+14];
		red[15*k+14]=reg[k];
		reg[k]=green[15*k];
		green[15*k]=green[15*k+1];
		green[15*k+1]=green[15*k+2];
		green[15*k+2]=green[15*k+3];
		green[15*k+3]=green[15*k+4];
		green[15*k+4]=green[15*k+5];
		green[15*k+5]=green[15*k+6];
		green[15*k+6]=green[15*k+7];
		green[15*k+7]=green[15*k+8];
		green[15*k+8]=green[15*k+9];
		green[15*k+9]=green[15*k+10];
		green[15*k+10]=green[15*k+11];
		green[15*k+11]=green[15*k+12];
		green[15*k+12]=green[15*k+13];
		green[15*k+13]=green[15*k+14];
		green[15*k+14]=reg[k];
		reg[k]=blue[15*k];
		blue[15*k]=blue[15*k+1];
		blue[15*k+1]=blue[15*k+2];
		blue[15*k+2]=blue[15*k+3];
		blue[15*k+3]=blue[15*k+4];
		blue[15*k+4]=blue[15*k+5];
		blue[15*k+5]=blue[15*k+6];
		blue[15*k+6]=blue[15*k+7];
		blue[15*k+7]=blue[15*k+8];
		blue[15*k+8]=blue[15*k+9];
		blue[15*k+9]=blue[15*k+10];
		blue[15*k+10]=blue[15*k+11];
		blue[15*k+11]=blue[15*k+12];
		blue[15*k+12]=blue[15*k+13];
		blue[15*k+13]=blue[15*k+14];
		blue[15*k+14]=reg[k];
		}
	delay(DELAY);
	}

void main(void)
	{
	int k;
	initgr256();
	setpal();
	initscrn();
	while(kbhit()==0)
		{
		shiftup();               //You could change these
		shiftright();            //to any combo you want
		setpal();                //Just setpal() each time
		}                        //you want to reset the pattern
	deinit();
	}
