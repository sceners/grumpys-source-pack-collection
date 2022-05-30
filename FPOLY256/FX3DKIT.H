extern unsigned int dpaddr;        /* video write base */

extern unsigned long l_hold, r_hold;	      /* used to hold old x data for edge */

extern int l_clip;     	/* clipping rectangle for polys and lines */
extern int r_clip;      /* max. 0,319,0,199			  */
extern int t_clip;
extern int b_clip;

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
extern void vgalines(lpoints *points, int color);

			/* Fast Cohen-Sutherland line clipper */
			/* modifies data in points, returns   */
			/* 0 if not clipped, 1 if clipped,    */
			/* -1 if undrawable                   */
			/* 2 - 10 uS per call                 */
extern int clipper (lpoints far *points);

			/* does C-S clipping and draws line   */
			/* returns same codes as C-S clipper  */
extern int clipline (lpoints *points, int color);

#define NO_HOLD  0      /* values for hold in tpoly() */
#define L_HOLD   1
#define R_HOLD   2
#define HOLD_ALL 3
#define HOLD 0x8000     /* use in x1 or x2 to continue poly side */


/* NOTE: for all polys, height is 1 less than expected.  This is
   because of the coordinate system used, and aliasing.  So a
   poly with (0,0) (10,0) (0,10) will fill vertical lines 0-9 only.
   This is OK, since real 3D figures consist of overlapping polys.
*/

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

int set_drawpage(int page);	/* set page for drawing on (0-7)   */

			 /* set displayed page: uses BIOS   */
			 /* call, so DON'T use in interrupt */
			 /* routines! If WAIT is 1, will    */
			 /* sync with vert. retrace (pause) */
int set_vidpage(int page, int wait);

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
			       /* 5800 polys/sec for 24x24         */
poly3(int x1, int y1, int x2, int y2, int x3, int y3, int color);

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


