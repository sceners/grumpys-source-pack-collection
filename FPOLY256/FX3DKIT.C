#include <bios.h>
#include <dos.h>
#include <stdio.h>
#include <stdlib.h>

unsigned int dpaddr = 0;        /* video write base */

unsigned long l_hold, r_hold;	      /* used to hold old x data for edge */

int l_clip = 0;     	/* clipping rectangle for polys and lines */
int r_clip = 319;       /* max. 0,319,0,199			  */
int t_clip = 0;
int b_clip = 199;

typedef struct lp {           /* set of points for clipping or line dwg */
		    int x1, y1, x2, y2;
		  } lpoints;




extern void far vsync();                /* pause till vert. retrace */
extern void far vga_reg(int reg); 	/* load VGA register:  */
					/* reg = reg# + 256*value */

extern void far load_color(int color);  /* load VGA color register */
extern void far set_vmode(int mode);    /* set video mode thru BIOS */
extern void far set_vpage(int page);    /* set video page thru BIOS */


#define PUT 0		/* defines of VGA write modes */
#define AND 1           /* for use with setup_hdwe()  */
#define OR  2
#define XOR 3

extern void far setup_hdwe(int mode);  /* setup VGA for bunch of line */
				       /* or poly draws: once per set */

extern void far reset_hdwe();  /* reset VGA to BIOS state after drawing */

			 /* clear video page to solid color: 10 mS */
			 /* returns -1 if bad page #		 */
extern int far clr_page(int page, int color);

			/* copy one page to another for use as */
			/* background: 21 mS per call          */
			/* returns -1 if bad page #            */
extern int far copy_page(int source, int dest);

			/* fast VGA line draw: about 15600 24-pixel */
			/* vectors/sec (horizontal much faster)     */
extern void far vgaline(int x1, int y1, int x2, int y2, int color);

			/* line draw using lpoint structure   */
void vgalines(lpoints *points, int color);

			/* Fast Cohen-Sutherland line clipper */
			/* modifies data in points, returns   */
			/* 0 if not clipped, 1 if clipped,    */
			/* -1 if undrawable                   */
			/* 2 - 10 uS per call                 */
int clipper (lpoints far *points);

			/* does C-S clipping and draws line   */
			/* returns same codes as C-S clipper  */
int clipline (lpoints *points, int color);

#define NO_HOLD  0      /* values for hold in tpoly() */
#define L_HOLD   1
#define R_HOLD   2
#define HOLD_ALL 3
#define HOLD 0x8000     /* use in x1 or x2 to continue poly side */

			/* draws trapeziodal poly slice FAST   */
			/* x1 is top left, x2 is top right,    */
			/* y1 is top, y3 is bottom.  Clipping  */
			/* is performed.  l_incr and r_incr    */
			/* set slope of sides.		       */
			/* if x1 or x2 = HOLD, continues that  */
			/* side from last tpoly call.  Use     */
			/* bits in hold to ensure that needed  */
			/* side data is good in previous tpoly */
extern int far tpoly(int x1,int x2, long l_incr, long r_incr,
					 int y1, int y3, int hold);

			       /* compute (x1-x2)/(y1-y2) << 16 */
			       /* used for tpoly...             */
			       /* returns x1-x2 if y1==y2       */
extern long far compute_slope(int x1, int x2, int y1, int y2);

void set_gmode();              /* enters 320x200x16 mode, clears screen */
void restore_gmode();          /* enters 320x200x16 mode w/o  clearing screen */
void exit_gmode();             /* exits to text mode */

int set_drawpage(int page);		/* set page for drawing on (0-7)   */

			 /* set displayed page: uses BIOS   */
			 /* call, so DON'T use in interrupt */
			 /* routines! If WAIT is 1, will    */
			 /* sync with vert. retrace (pause) */
int set_vidpage(int page, int wait);


			       /* draw and fill 3-sided polygon    */
			       /* automatically clipped to bounds  */
			       /* not a "pretty poly" fill, so     */
			       /* sliver polys break up.           */
			       /* 5800 polys/sec for 24x24         */
poly3(int x1, int y1, int x2, int y2, int x3, int y3, int color);

			/* fastest triangle poly blitter */
			/* points must be in CCW order   */
			/* (clockwise before Y mirror)   */
			/* and color must have been set  */
			/* with load_color() before call */
			/* NO CLIPPING AT ALL            */
void fastri(int x1, int y1, int x2, int y2, int x3, int y3);

			/* N_SIDED POLY DRAW DONE WITH TRIANGLES */
			/* pass pointers to X, Y coord arrays    */
			/* and count.  No clipping, preset color */
			/* with load_color()                     */
void polynt(int *xcoords, int *ycoords, int count);

			/* draw and fill 3-sided polygon    */
			/* automatically clipped to bounds  */
			/* not a "pretty poly" fill, so     */
			/* sliver polys break up.           */
			/* will draw some concave polys OK  */
			/* but can't be depended on esp.    */
			/* if concavity is at top or bot.   */
			/* 3800 30x30 polys/sec             */
poly4(int x1, int y1, int x2, int y2, int x3, int y3,
					int x4, int y4, int color);



/************* GRAPHICS MODE CONTROL SUPPORT **************/

void set_gmode()		/* enters 320x200x256 mode, clears screen */
{
 set_vmode(0x14);
}


void restore_gmode()		/* enters 320x200x256 mode w/o  clearing screen */
{
 set_vmode(0x94);
}


void exit_gmode()		/* exits to text mode */
{
 set_vmode(0x02);
}


int set_drawpage(int page)      /* set page for drawing */
{
 if(page>3) return(-1);
 dpaddr = 16000*page;
 return(0);
}


int set_vidpage(int page, int wait)  /* set visible page, wait for vsync */
{
 if(page>3) return(-1);
 set_vpage(page);
 if(wait) vsync();
}


/******************* LINE DRAWING SUPPORT ***************/

void vgalines(lpoints *l, int color)
{
 vgaline(l->x1, l->y1, l->x2, l->y2, color);
}


int clipline(lpoints *l, int color)
{
 register int i;

 if ((i=clipper(l))==-1) return(i);
 vgaline(l->x1, l->y1, l->x2, l->y2, color);
 return(i);
}



/*************** 3-SIDED POLYGON DRAW AND FILL ***************/

poly3(int x1, int y1, int x2, int y2, int x3, int y3, int color)
{
 register int i;
 long s12, s23, s13;
			  /* find if all outside of window      */
			  /* sort of braindead partial clipping */
			  /* but it's fast and optimal for      */
			  /* small polys */

 i = r_clip;
 if(!( x1<=i || x2<=i || x3<=i )) return(0);

 i = l_clip;
 if(!( x1>=i || x2>=i || x3>=i )) return(0);

 i = b_clip;
 if(!( y1<=i || y2<=i || y3<=i )) return(0);

 i = t_clip;
 if(!( y1>=i || y2>=i || y3>=i )) return(0);

 if(y2<y1)   	/* sort by vert pos'n */
  {
   i = y1;
   y1 = y2;
   y2 = i;
   i = x1;
   x1 = x2;
   x2 = i;
  }

 if(y3<y1)
  {
   i = y1;
   y1 = y3;
   y3 = i;
   i = x1;
   x1 = x3;
   x3 = i;
  }

 if(y3<y2)
  {
   i = y2;
   y2 = y3;
   y3 = i;
   i = x2;
   x2 = x3;
   x3 = i;
  }

 if(y3<t_clip || y1>b_clip)return(0);	/* all above or below clip area */

 if(y1==y2&&y2==y3) return;

 load_color(color);

 if(y1==y2)		/* case = 2 (flat top) */
  {
   if(x2<x1)
    {
     i = x1;
     x1 = x2;
     x2 = i;
    }
   s23 = compute_slope(x2,y2,x3,y3);
   s13 = compute_slope(x1,y1,x3,y3);
   tpoly(x1,x2,s13,s23,y1,y3,NO_HOLD);
  }
 else if(y2==y3) 	/* case = 1 (flat bottom)*/
  {
   if(x3<x2)
    {
     i = x2;            /* sort bottom sides */
     x2 = x3;
     x3 = i;
    }
   s12 = compute_slope(x1,y1,x2,y2);
   s13 = compute_slope(x1,y1,x3,y3);
   tpoly(x1,x1,s12,s13,y1,y3,NO_HOLD);
  }
 else
  {
   s12 = compute_slope(x1,y1,x2,y2);
   s23 = compute_slope(x2,y2,x3,y3);
   s13 = compute_slope(x1,y1,x3,y3);

   if(s12>s13) 	/* case = 4 (3rd point on right) */
    {
     tpoly(x1,x1,s13,s12,y1,y2,L_HOLD);
     tpoly(0x8000,x2,s13,s23,y2,y3,NO_HOLD);
    }
   else         /* case = 3 (3rd point on left)  */
    {
     tpoly(x1,x1,s12,s13,y1,y2,R_HOLD);
     tpoly(x2,0x8000,s23,s13,y2,y3,NO_HOLD);
    }
  }
}



/******************* 4-SIDED CONVEX POLY DRAW AND FILL **************/

/* draw quad poly-- MUST BE CONVEX */
/* will draw some concave polys OK */
/* but can't be depended on esp.   */
/* if concavity is at top or bot.  */

poly4(int x1, int y1, int x2, int y2, int x3, int y3,
				 int x4, int y4, int color)
{
 register int i;
 long s12, s13, s24, s14, s23 ,s34;

			  /* find if all outside of window      */
			  /* sort of braindead partial clipping */
			  /* but it's fast and optimal for      */
			  /* small polys */
 i = r_clip;
 if(!( x1<=i || x2<=i || x3<=i || x4<=i )) return(0);

 i = l_clip;
 if(!( x1>=i || x2>=i || x3>=i || x4>=i )) return(0);

 i = b_clip;
 if(!( y1<=i || y2<=i || y3<=i || y4<=i )) return(0);

 i = t_clip;
 if(!( y1>=i || y2>=i || y3>=i || y4>=i )) return(0);

 if(y2<y1)   	/* sort by vert pos'n             */
  {             /* an unrolled bubble sort        */
   i = y1;      /* early termination not worth it */
   y1 = y2;
   y2 = i;
   i = x1;
   x1 = x2;
   x2 = i;
  }

 if(y3<y1)
  {
   i = y1;
   y1 = y3;
   y3 = i;
   i = x1;
   x1 = x3;
   x3 = i;
  }

 if(y4<y1)
  {
   i = y1;
   y1 = y4;
   y4 = i;
   i = x1;
   x1 = x4;
   x4 = i;
  }

 if(y3<y2)
  {
   i = y2;
   y2 = y3;
   y3 = i;
   i = x2;
   x2 = x3;
   x3 = i;
  }

 if(y4<y2)
  {
   i = y2;
   y2 = y4;
   y4 = i;
   i = x2;
   x2 = x4;
   x4 = i;
  }

 if(y4<y3)
  {
   i = y3;
   y3 = y4;
   y4 = i;
   i = x3;
   x3 = x4;
   x4 = i;
  }

 load_color(color);             /* set VGA color register */

 if(y1==y2) goto case_a;
 if(y2==y3) goto case_b;
 if(y3==y4) goto case_c;
 if(y4==y1) return(0);		/* invisible h. line poly: exit */
 goto case_d;

case_a:                         /* flat top */
 if(y2!=y3) goto case_e;
 if(y3==y4) return(0);		/* invisible line */

 if(x2<x1)			/* sort x1 lowest, x3 highest */
  {
   i = x1;
   x1 = x2;
   x2 = i;
   i = y1;
   y1 = y2;
   y2 = i;
  }
 if(x3<x2)
  {
   x3 = x2;
   y3 = x2;
  }

 s14 = compute_slope(x1,y1,x4,y4);    /* combine into flat-top tri */
 s34 = compute_slope(x3,y3,x4,y4);
 tpoly(x1,x3,s14,s34,y1,y4,NO_HOLD);
 return(0);

case_e:                         /* flat top and bottom */
 if(y3!=y4) goto case_f;

 if(x2<x1)			/* sort x1 lowest, x2 highest */
  {
   i = x1;
   x1 = x2;
   x2 = i;
   i = y1;
   y1 = y2;
   y2 = i;
  }

 if(x4<x3)			/* sort x3 lowest, x4 highest */
  {
   i = x3;
   x3 = x4;
   x4 = i;
   i = y3;
   y3 = y4;
   y4 = i;
  }

 s13 = compute_slope(x1,y1,x3,y3);    /* combine into parallelogram */
 s24 = compute_slope(x2,y2,x4,y4);
 tpoly(x1,x2,s13,s24,y1,y4,NO_HOLD);
 return(0);

case_f:		 /* flat-top only */

 if(x2<x1)			/* sort x1 lowest, x2 highest */
  {
   i = x1;
   x1 = x2;
   x2 = i;
   i = y1;
   y1 = y2;
   y2 = i;
  }

 if(x4<x3)                      /* left below right bottom */
  {
   s14 = compute_slope(x1,y1,x4,y4);
   s23 = compute_slope(x2,y2,x3,y3);
   tpoly(x1,x2,s14,s23,y1,y3,L_HOLD);
   s34 = compute_slope(x3,y3,x4,y4);
   tpoly(HOLD,x3,s14,s34,y3,y4,NO_HOLD);
  }
 else                          /* right below left bottom */
  {
   s13 = compute_slope(x1,y1,x3,y3);
   s24 = compute_slope(x2,y2,x4,y4);
   tpoly(x1,x2,s13,s24,y1,y3,R_HOLD);
   s34 = compute_slope(x3,y3,x4,y4);
   tpoly(x3,HOLD,s34,s24,y3,y4,NO_HOLD);
  }
 return(0);

case_b:                         /* sides equal height */
 if(y3!=y4) goto case_g;        /* not triangular? */

 if(x3<x2)			/* sort x2 lowest, x4 highest */
  {
   i = x1;
   x2 = x3;
   x3 = i;
   i = y2;
   y2 = y3;
   y3 = i;
  }
 if(x4<x3)
  {
   x4 = x3;
   y4 = x3;
  }

 s12 = compute_slope(x1,y1,x2,y2);    /* combine into flat-bottom tri */
 s14 = compute_slope(x1,y1,x4,y4);
 tpoly(x1,x1,s12,s14,y1,y4,NO_HOLD);
 return(0);

case_g:		/* diamond */

 if(x3<x2)			/* sort x2 lowest, x3 highest */
  {
   i = x1;
   x2 = x3;
   x3 = i;
   i = y2;
   y2 = y3;
   y3 = i;
  }
 s12 = compute_slope(x1,y1,x2,y2);    /* draw upper, lower diamond */
 s13 = compute_slope(x1,y1,x3,y3);
 tpoly(x1,x1,s12,s13,y1,y2,NO_HOLD);
 s24 = compute_slope(x2,y2,x4,y4);
 s34 = compute_slope(x3,y3,x4,y4);
 tpoly(x2,x3,s24,s34,y2,y4,NO_HOLD);
 return(0);

case_c:
 /* flat-bottom only */

 if(x4<x3)			/* sort x3 lowest, x4 highest */
  {
   i = x3;
   x3 = x4;
   x4 = i;
   i = y3;
   y3 = y4;
   y4 = i;
  }

 if(x1<x2)                     /* left above right top */
  {
   s12 = compute_slope(x1,y1,x2,y2);
   s13 = compute_slope(x1,y1,x3,y3);
   tpoly(x1,x1,s13,s12,y1,y2,L_HOLD);
   s24 = compute_slope(x2,y2,x4,y4);
   tpoly(HOLD,x2,s13,s24,y2,y4,NO_HOLD);
  }
 else                          /* right above left top */
  {
   s12 = compute_slope(x1,y1,x2,y2);
   s14 = compute_slope(x1,y1,x4,y4);
   tpoly(x1,x1,s12,s14,y1,y2,R_HOLD);
   s23 = compute_slope(x2,y2,x3,y3);
   tpoly(x2,HOLD,s23,s14,y2,y3,NO_HOLD);
  }
 return(0);

case_d:		/* no regularities */

 s12 = compute_slope(x1,y1,x2,y2);
 s13 = compute_slope(x1,y1,x3,y3);
 s34 = compute_slope(x3,y3,x4,y4);
 s14 = compute_slope(x1,y1,x4,y4);

 if(s12<s13)    	/* p2 at left */
  {
   if(s14>s34)          /* p2,p3 on opposite sides */
    {
     s24 = compute_slope(x2,y2,x4,y4);
     tpoly(x1,x1,s12,s13,y1,y2,R_HOLD);
     tpoly(x2,HOLD,s24,s13,y2,y3,L_HOLD);
     tpoly(HOLD,x3,s24,s34,y3,y4,NO_HOLD);
    }
   else
    {
     s23 = compute_slope(x2,y2,x3,y3);
     tpoly(x1,x1,s12,s14,y1,y2,R_HOLD);
     tpoly(x2,HOLD,s23,s14,y2,y3,R_HOLD);
     tpoly(x3,HOLD,s34,s14,y3,y4,NO_HOLD);
    }
  }
 else
  {
   if(s14<s34)          /* p2,p3 on opposite sides */
    {
     tpoly(x1,x1,s13,s12,y1,y2,L_HOLD);
     s24 = compute_slope(x2,y2,x4,y4);
     tpoly(HOLD,x2,s13,s24,y2,y3,R_HOLD);
     tpoly(x3,HOLD,s34,s24,y3,y4,NO_HOLD);
    }
   else
    {
     s23 = compute_slope(x2,y2,x3,y3);
     tpoly(x1,x1,s14,s12,y1,y2,L_HOLD);
     tpoly(HOLD,x2,s14,s23,y2,y3,L_HOLD);
     tpoly(HOLD,x3,s14,s34,y3,y4,NO_HOLD);
    }
  }
 return(0);
}

