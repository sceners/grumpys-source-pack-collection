//
// Lord Logics Landscape
//
// Use it, read it, learn from it, do whatever you want with it . . .
// If it screws up ur system, its not my fault.  If it doesn't work for you,
// its not my fault.
//
// To compile   : qcl -AH -c ll_land.c
// To assemble  : ml -c ll_1.asm
// To link      : link land ll_1;
// To run       : ll_land
//

#include <math.h>
#include "ll_gfx.h"
#include "ll_key.h"

extern void ll_xinit();
extern void ll_page();
extern char ll_sin(int);
extern char ll_cos(int);
extern void land_clr();
extern void land_put(int, int, int, int);
extern  int     far     *ll_table;

#define LL_PALSIZE 775
char far NEW_PAL[LL_PALSIZE];

/*
   void ll_delta();
   This routine determines the radius and theta angles for the cubical
   landscape region.  Call this routine passing the buffer (size: int
   40*40*2) as well as the DX and DZ values.  These values are the change
   in X and Z between each pixel plot in the landscape.
*/
void    ll_delta(int far *table, int dx, int dz)
{
int     c,x,z,r,theta;

	c=0;
	for (z=23; z>-23; z--)
	for (x=-23; x<23; x++)
	{
		r=(int)sqrt((double)((long)((long)dz*(long)dz*(long)z*(long)z)+(long)((long)dx*(long)dx*(long)x*(long)x)));
		if ((z==0) && (x<0))
			theta=270;
		else
		if ((z==0) && (x>0))
			theta=90;
		else
		if (z==0)
			theta=0;
		else
		if (z<0)
			theta=(int)((double)(atan( (double)((long)dx*(long)x)/(double)((long)dz*(long)z) )*180/3.1415926))+180;
		else
			theta=(int)((double)(atan( (double)((long)dx*(long)x)/(double)((long)dz*(long)z) )*180/3.1415926));

		if (theta<0) theta+=360;

		/*
		printf("%d,%d: %d %d\n",x+23,z+23,r,theta);
		if (kbhit()) { while (kbhit()) getch(); getch(); }
		*/

		table[c]=r;
		table[c+1]=theta;

		c+=2;
	}
}

main()
{
int     x;
int     y;
int     z;
long    c=0;
long    d=0;
long    w=0;
int     water=0;
int     wdelta=2;
int     adelta=2;
int     xydelta=0;
int     alpha=0;


	printf("-=[    Initializing Land Mesh    ]=-\n");
	ll_delta(ll_table,35,35);


	/* Routines not provided for this section.  These are a part of
	   my graphics routines which I am no releasing.  Code is given
	   to do the necessary stuff.  This code initializes a 13h video
	   mode and saves the text screen for restoration.

	if ((pal=ll_getsys())==0)
	{
		printf("VGA not found or insufficient memory.\n");
		exit(1);
	}
	*/

	// Substitute code
	_asm
	{
		mov     ax,0013h
		int     10h
	}

	ll_palramp(NEW_PAL,1,64,0,63,0,0,32,0);
	ll_palramp(NEW_PAL,64,32,0,32,0,63,63,63);
	ll_palramp(NEW_PAL,96,159,63,63,63,63,63,63);
	NEW_PAL[0]=0;
	NEW_PAL[1]=0;
	NEW_PAL[2]=0;
	NEW_PAL[3]=3;
	NEW_PAL[4]=0;
	NEW_PAL[5]=46;

	ll_xinit();             // Initialize a 320x200 unchained mode

	ll_palput(NEW_PAL);

	x=0;
	y=0;
	adelta=0;
	xydelta=0;

	ll_keyswap();

	while (!ll_keypressed(_ESC))
	{
		ll_page();
		land_clr();
		land_put(x,y,water,alpha);

		if (ll_keypress(_UP))
			{if (xydelta<5) xydelta++;}
		else
			{if (xydelta>0) xydelta--;}

		if (ll_keypress(_DOWN))
			{if (xydelta>-5) xydelta--;}
		else
			{if (xydelta<0) xydelta++;}

		if (ll_keypress(_RIGHT))
			{if (adelta>-10) adelta--;}
		else
			{if (adelta<0) adelta++;}

		if (ll_keypress(_LEFT))
			{if (adelta<10) adelta++;}
		else
			{if (adelta>0) adelta--;}

		if (ll_keypress(_MIDDLE))
			adelta=0;
		if (ll_keypress(_SPACE))
			water+=wdelta;

		if (water<0) {wdelta=2; water=0;}
		if (water>160) wdelta=-2;

		alpha+=adelta;
		while (alpha<0) alpha+=360;
		while (alpha>=360) alpha-=360;

		x-=ll_sin(alpha)*xydelta/128;
		y-=ll_cos(alpha)*xydelta/128;

		if (x>206) x=206;
		if (y>206) y=206;
		if (y<0) y=0;
		if (x<0) x=0;
	}

	ll_keyswap();

	/* Another routine not given.
	ll_putsys();
	*/

	// Substitute code
	_asm
	{
		mov     ax,0003h
		int     10h
	}
}
