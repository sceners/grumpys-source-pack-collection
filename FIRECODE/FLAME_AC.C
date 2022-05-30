//**************************************************************************
//*                                                                        *
//*    CFLAMES1 by Kirk A. Baum                                            *
//*       This C program was addapted from a pascal program by M.D.Mackey. *
//*       It has been modified to half the resolution used by Mark and the *
//*       routines are entirely in C.  The original code was written in    *
//*       Pascal with Inline assemby.  As with Marks code, I release this  *
//*       code into the public domain.  It may be freely distributed and   *
//*       modified, but please give credit where it is due if used.        *
//*       If you have any suggestions or comments please contact me at:    *
//*       kbaum@Novell.com.                                                *
//*       Mark can be reached at: mackey@aqueous.ml.csiro.au               *
//*                                                                        *
//**************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <dos.h>


#define VIDEO_INT       0x10
#define VGA_MODE        0x13
#define TEXT_MODE       0x03
#define V_WIDTH         80
#define V_HEIGHT        50
#define BUF_WIDTH       80
#define BUF_HEIGHT      56
#define PALETTE_SIZE    256*3
#define INT_SIZE        2
#define ESC_KEY         27
#define VGA_SCREEN      0xa000
#define DAC_WRITE_INDEX 0x03c8
#define DAC_DATA_REG    0x03c9

void SetVGAMode13(void);
void RestoreTextMode(void);
void SetPalette(void);


unsigned char far *screen;    // pointer to the VGA graphics screen 320x200
int p1[BUF_HEIGHT][BUF_WIDTH];// VGA buffer, quarter resolution w/extra lines
unsigned int i,j,k,l,delta;   // looping variables, counters, and data
char ch;                      // input character

// VGA color palette for flames
unsigned char pal[PALETTE_SIZE]={  0,  0,  0,  0,  0, 24,  0,  0, 24,  0,  0, 28,
				   0,  0, 32,  0,  0, 32,  0,  0, 36,  0,  0, 40,
				   8,  0, 40, 16,  0, 36, 24,  0, 36, 32,  0, 32,
				  40,  0, 28, 48,  0, 28, 56,  0, 24, 64,  0, 20,
				  72,  0, 20, 80,  0, 16, 88,  0, 16, 96,  0, 12,
				 104,  0,  8,112,  0,  8,120,  0,  4,128,  0,  0,
				 128,  0,  0,132,  0,  0,136,  0,  0,140,  0,  0,
				 144,  0,  0,144,  0,  0,148,  0,  0,152,  0,  0,
				 156,  0,  0,160,  0,  0,160,  0,  0,164,  0,  0,
				 168,  0,  0,172,  0,  0,176,  0,  0,180,  0,  0,
				 184,  4,  0,188,  4,  0,192,  8,  0,196,  8,  0,
				 200, 12,  0,204, 12,  0,208, 16,  0,212, 16,  0,
				 216, 20,  0,220, 20,  0,224, 24,  0,228, 24,  0,
				 232, 28,  0,236, 28,  0,240, 32,  0,244, 32,  0,
				 252, 36,  0,252, 36,  0,252, 40,  0,252, 40,  0,
				 252, 44,  0,252, 44,  0,252, 48,  0,252, 48,  0,
				 252, 52,  0,252, 52,  0,252, 56,  0,252, 56,  0,
				 252, 60,  0,252, 60,  0,252, 64,  0,252, 64,  0,
				 252, 68,  0,252, 68,  0,252, 72,  0,252, 72,  0,
				 252, 76,  0,252, 76,  0,252, 80,  0,252, 80,  0,
				 252, 84,  0,252, 84,  0,252, 88,  0,252, 88,  0,
				 252, 92,  0,252, 96,  0,252, 96,  0,252,100,  0,
				 252,100,  0,252,104,  0,252,104,  0,252,108,  0,
				 252,108,  0,252,112,  0,252,112,  0,252,116,  0,
				 252,116,  0,252,120,  0,252,120,  0,252,124,  0,
				 252,124,  0,252,128,  0,252,128,  0,252,132,  0,
				 252,132,  0,252,136,  0,252, 136,   0,252, 140,   0,
				 252, 140,   0,252, 144,   0,252, 144,   0,252, 148,   0,
				 252, 152,   0,252, 152,   0,252, 156,   0,252, 156,   0,
				 252, 160,   0,252, 160,   0,252, 164,   0,252, 164,   0,
				 252, 168,   0,252, 168,   0,252, 172,   0,252, 172,   0,
				 252, 176,   0,252, 176,   0,252, 180,   0,252, 180,   0,
				 252, 184,   0,252, 184,   0,252, 188,   0,252, 188,   0,
				 252, 192,   0,252, 192,   0,252, 196,   0,252, 196,   0,
				 252, 200,   0,252, 200,   0,252, 204,   0,252, 208,   0,
				 252, 208,   0,252, 208,   0,252, 208,   0,252, 208,   0,
				 252, 212,   0,252, 212,   0,252, 212,   0,252, 212,   0,
				 252, 216,   0,252, 216,   0,252, 216,   0,252, 216,   0,
				 252, 216,   0,252, 220,   0,252, 220,   0,252, 220,   0,
				 252, 220,   0,252, 224,   0,252, 224,   0,252, 224,   0,
				 252, 224,   0,252, 228,   0,252, 228,   0,252, 228,   0,
				 252, 228,   0,252, 228,   0,252, 232,   0,252, 232,   0,
				 252, 232,   0,252, 232,   0,252, 236,   0,252, 236,   0,
				 252, 236,   0,252, 236,   0,252, 240,   0,252, 240,   0,
				 252, 240,   0,252, 240,   0,252, 240,   0,252, 244,   0,
				 252, 244,   0,252, 244,   0,252, 244,   0,252, 248,   0,
				 252, 248,   0,252, 248,   0,252, 248,   0,252, 252,   0,
				 252, 252,   4,252, 252,   8,252, 252,  12,252, 252,  16,
				 252, 252,  20,252, 252,  24,252, 252,  28,252, 252,  32,
				 252, 252,  36,252, 252,  40,252, 252,  40,252, 252,  44,
				 252, 252,  48,252, 252,  52,252, 252,  56,252, 252,  60,
				 252, 252,  64,252, 252,  68,252, 252,  72,252, 252,  76,
				 252, 252,  80,252, 252,  84,252, 252,  84,252, 252,  88,
				 252, 252,  92,252, 252,  96,252, 252, 100,252, 252, 104,
				 252, 252, 108,252, 252, 112,252, 252, 116,252, 252, 120,
				 252, 252, 124,252, 252, 124,252, 252, 128,252, 252, 132,
				 252, 252, 136,252, 252, 140,252, 252, 144,252, 252, 148,
				 252, 252, 152,252, 252, 156,252, 252, 160,252, 252, 164,
				 252, 252, 168,252, 252, 168,252, 252, 172,252, 252, 176,
				 252, 252, 180,252, 252, 184,252, 252, 188,252, 252, 192,
				 252, 252, 196,252, 252, 200,252, 252, 204,252, 252, 208,
				 252, 252, 208,252, 252, 212,252, 252, 216,252, 252, 220,
				 252, 252, 224,252, 252, 228,252, 252, 232,252, 252, 236,
				 252, 252, 240,252, 252, 244,252, 252, 248,252, 252, 252};



//************************************************************************
//*  SetVGAMode13                                                        *
//*     Sets the graphics screen to mode 13h (320x200) at 256 colors.    *
//************************************************************************
void SetVGAMode13()
{
union REGS regs;

regs.x.ax = VGA_MODE;
int86(VIDEO_INT, &regs, &regs);
}


//************************************************************************
//*  RestoreTextMode                                                     *
//*     Sets the video mode back to text mode.                           *
//************************************************************************
void RestoreTextMode()
{
union REGS regs;

regs.x.ax = TEXT_MODE;
int86(VIDEO_INT, &regs, &regs);
}

//************************************************************************
//*  SetPalette                                                          *
//*    Sets the 256 color palette of the VGA to reflect the RGB colos    *
//*    contained in the pal array.  Set the DAC_WRITE_INDEX to the color *
//*    you want to start with, in our case 0 (the first color index).    *
//*    Then send the RGB values for each successive color index to the   *
//*    DAC_DATA_REGister.
//************************************************************************
void SetPalette()
{
int  i;

outportb(DAC_WRITE_INDEX, 0);
for(i=0; i<PALETTE_SIZE; i++)
   {
   pal[i] = pal[i] >> 2;
   outportb(DAC_DATA_REG, pal[i]);
   }
}


//************************************************************************
//*  Main                                                                *
//*    Creates a fire (plasma) effect                                    *
//************************************************************************
void main()
{
  SetVGAMode13();      // Setup the graphics mode
  SetPalette();        // Setup the color palette
  randomize();         // Initialize the random number generator
  ch=' ';              // Initialize the input character


  // Initialize the video buffer to 0's
  for(i=0;i<BUF_HEIGHT;i++)
     {
     for(j=0;j<BUF_WIDTH;j++)
	{
	p1[i][j]=0;
	}
     }

  // Loop until ESC is pressed
  while(ch != ESC_KEY)
    {

    // Transform current buffer
    for(i=1;i<BUF_HEIGHT;i++)
       {
       for(j=0;j<BUF_WIDTH;j++)
	  {
	  if(j==0) p1[i-1][j] = (p1[i][j]+
				 p1[i-1][79]+
				 p1[i][j+1]+
				 p1[i+1][j]) / 4;
	  else if(j==79) p1[i-1][j] = (p1[i][j]+
				       p1[i][j-1]+
				       p1[i+1][0]+
				       p1[i+1][j]) / 4;
	  else p1[i-1][j] = (p1[i][j]+
			     p1[i][j-1]+
			     p1[i][j+1]+
			     p1[i+1][j]) / 4;


	  //if(p1[i][j] > 0) p1[i][j]= p1[i][j] - 1;
	  //if(p1[i][j] > 0) p1[i][j]= p1[i][j] - 1;
	  //if(p1[i][j] > 0) p1[i][j]= p1[i][j] - 1;

	  if(p1[i][j] > 11) p1[i][j]= p1[i][j] - 12;
	  else if(p1[i][j] > 3) p1[i][j] = p1[i][j] - 4;
	  else {
	       if(p1[i][j] > 0) p1[i][j]--;
	       if(p1[i][j] > 0) p1[i][j]--;
	       if(p1[i][j] > 0) p1[i][j]--;
	       }
	  }
       }

    // Set new bottom line with random white or black
    delta = 0;
    for(j=0;j<BUF_WIDTH;j++)
       {
       if(random(10) < 5)
	 {
	 delta=random(2)*255;
	 }
       p1[BUF_HEIGHT - 2][j] = delta;
       p1[BUF_HEIGHT - 1][j] = delta;
       }

    // Write the buffer to the screen
    screen = MK_FP(VGA_SCREEN,0);
    for(i=0; i<V_HEIGHT; i++)
       {
       for(k=0; k<4; k++)
	  {
	  for(j=0; j<V_WIDTH; j++)
	     {
	     for(l=0; l<4; l++)
		{
		*screen = (unsigned char)p1[i][j];
		screen++;
		}
	     }
	  }
       }

    // Check for ESC key pressed
    if(kbhit())
      {
      ch=getch();
      }

    }//End of While

  RestoreTextMode();
}