#ifndef LL_GFX_H
#define LL_GFX_H
// LL_FONT.ASM
extern void ll_font(unsigned char, unsigned int, unsigned int);

// LL_PAL.ASM
extern char ll_palcycle(char far *, unsigned char, unsigned int, char);
extern char ll_palcol(char far *, unsigned char, unsigned int, char, char, char);
extern char ll_palput(char far *);
extern char ll_palget(char far *);
extern char ll_palfade(char far *);
extern char ll_palramp(char far *, unsigned char, unsigned int, char, char, char, char, char, char);
extern char ll_palupdate();

// LL_GFX.ASM
extern unsigned char ll_lgiload(char far *);
extern unsigned int ll_mapsize(int, int, int, int);
extern char ll_mappix(char far *, int, int, int);
extern char ll_mapset(char far *, int, int);    // 0 is NOT see thru
extern char ll_mapput(char far *, int, int);    // 0 IS see thru
extern char ll_mapget(char far *, int, int, int, int);
extern char ll_mapclr(char far *, int, int, unsigned char);
extern unsigned char ll_dotget(int, int);
extern unsigned char ll_dotput(int, int, unsigned char);
extern unsigned char ll_dotscr(unsigned char);

// LL_SYS.ASM
extern char far *ll_getsys();
extern char ll_putsys();

// LL_TIME.ASM
extern long LL_TIME;
extern long ll_timeget();       // Returns current clock count
extern char ll_timeclr();       // Clears the time clock
extern char ll_timedel(int);    // Timed delay - clocks since last ll_timeset
extern long ll_timeset();       // Sets new time clock and returns cpu clock

// LL_SIN.ASM
extern char ll_sin(int);
extern char ll_cos(int);


// Global Define Statements
#define LL_PALSIZE 775
#define LL_PALFORWARD   1
#define LL_PALBACKWARD  -1
#endif
