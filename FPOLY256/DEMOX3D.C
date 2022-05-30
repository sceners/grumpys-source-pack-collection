#include <bios.h>
#include <dos.h>
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <graphics.h>
#include <math.h>

#include "fx3dkit.h"



/****************** TEST/DEMO SOFTWARE ******************/


	 /* defined keystrokes for the program */
enum key{ null=0,
	  F1,
	  F2,
	  F3,
	  F4,
	  home,
	  end,
	  up_arrow,
	  down_arrow,
	  left_arrow,
	  right_arrow,
	  esc,
	  enter,
	  backspace,
	  plus,
	  minus,
	};


			/* GET KEY COMMAND */
enum key getkey()
{
 int c;

 if (!kbhit()) return(null);	/* null if no key hit */

 c = (int) getch();             /* get key code */
 if (c)                         /* nonzero key code */
   {
    switch(c)                   /* return proper name */
      {
       case 27:  return(esc);
       case 13:  return(enter);
       case 8:   return(backspace);
       case '+': return(plus);
       case '-': return(minus);
       default: return(c);   	/* ASCII if not command */
      }
   }

 c = (int) getch();		/* zero code: get second byte */
 switch(c)			/* return proper name */
   {
    case 59: return(F1);
    case 60: return(F2);
    case 61: return(F3);
    case 62: return(F4);
    case 71: return(home);
    case 79: return(end);
    case 72: return(up_arrow);
    case 80: return(down_arrow);
    case 75: return(left_arrow);
    case 77: return(right_arrow);
    default: return(c);         /* ASCII if not command */
   }
}


void dummy(int a, int b, int c, int d, int e)
{
return;
}



#define INC 4    	/* number degrees per step for THING demo */

main()
{
 long btime;
 float mtime;
 int i,j,k;
 int x[4],y[4];
 char c;
 lpoints l;

 set_gmode();
 set_vidpage(0,0);
 set_drawpage(0);

  goto speedtri; /* test tri/quad/line time */
/*  goto grest;    /* test line drawing and clipping */


demo:
 j=0;
 k=180;
 i = 0;
 set_drawpage(2);
 clr_page(2,2);
 setup_hdwe(PUT);
 poly3(20,20,160,60,160,140,4);
 poly3(300,180,160,60,160,140,3);
 c=0;

doit:
 set_vidpage(i^1,1);
 copy_page(2,i);
/* clr_page(i,0); */
 set_drawpage(i);
 i = i^1;
 setup_hdwe(PUT);
 draw_thing(j,k);
 reset_hdwe();
 if(getkey()==esc)exit(0);
 if(c==1)
  {
   j+=INC;
   k-=INC;
   if(j>=90) c = c^1;
  }
 if(c==0)
  {
   j-=INC;
   k+=INC;
   if(j<=-90)c = c^1;
  }
 goto doit;

grest:
 t_clip = l_clip = 25;
 b_clip = r_clip = 175;

 set_drawpage(2);
 clr_page(2,0);
 setup_hdwe(PUT);
 poly4(l_clip,t_clip,l_clip,b_clip,r_clip,t_clip,r_clip,b_clip,4);

grept:
 set_vidpage(0,1);
 copy_page(2,0);
 set_drawpage(0);
 setup_hdwe(PUT);
 for(i=0;i<2;i++)
  {
   x[i] = random(100);
   y[i] = random(100);
   if(x[i]>50) x[i] +=100;
   if(y[i]>50) y[i] +=100;
   l.x1 = x[i]; l.x2 = x[i]+1;
   l.y1 = y[i]; l.y2 = y[i];
   vgalines(&l,13+i);
  }
   l.x1 = x[0]; l.x2 = x[1];
   l.y1 = y[0]; l.y2 = y[1];
 if(toupper(getch())=='N') goto grept;
 setup_hdwe(PUT);
 if(clipper(&l)!=-1)
   vgalines(&l,15);
 reset_hdwe();
 if(toupper(getch())=='R')
  {
   setup_hdwe(PUT);
   l.x1 = x[0]; l.x2 = x[1];
   l.y1 = y[0]; l.y2 = y[1];
   if(clipper(&l)!=-1)
     vgalines(&l,15);
   reset_hdwe();
  }
 goto grept;

speedtri:
 setup_hdwe(PUT);
				   /* draw 49300 24x24 trapezoids */
 reset_hdwe();

 btime = biostime(0,0L);

 setup_hdwe(PUT);
 for(i=0;i<290;i++)
 for(k=0;k<170;k++)
/*
  poly4(i+10, k, i, k+4, i+3, k+4, i+20, k+30, ((i+k)%15)+1);
*/
/*
 poly3(i+10, k, i, k+4, i+3, k+4, (i+k)&255);
*/

 for(j=0;j<10;j++) vgaline(i,k,i+22,k+20,(i+k)&255);

/*
 {
  load_color((i+k)&255);
  fastri(i+10,k,i,k+4,i+3,k+4);
 }
*/
 reset_hdwe();
 exit_gmode();
 printf("Time for 49300(0) Draws: %f\n", (float)(biostime(0,0L)-btime)/18.2);
 btime = biostime(0,0L);

 getch();
 reset_hdwe();
 exit_gmode();
}


draw_thing(j,k)
{
 int x1,x2,y1,y2;
 float snj=sin(j/57.3);
 float snk=sin(k/57.3);
 float csj=cos(j/57.3);
 float csk=cos(k/57.3);

 x1 = 66*csj+160;
 x2 = 66*csk+160;
 y1 = 66*snj+70;
 y2 = 66*snk+70;

 poly3(10,10,160,100,x2,y2,12);
 poly3(310,10,160,100,x1,y1,13);
 poly3(160,190,x1,y1,x2,y2,14);
 poly3(160,100,x1,y1,x2,y2,15);
}


