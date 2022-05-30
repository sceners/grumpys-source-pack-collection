/* C header file for STMIK V0.2 
** Copyright (C) 1991 Sami Tammilehto
*/

/* routines in STMIK020.OBJ */

extern int stmik_init(int mode,int ioadd,int irq,int mixspd);
/*   mode: 1=SBC
**  ioadd: card I/O address; 0x220=default
**    irq: card IRQ number; 0x7=default
** mixspd: 20000=high,16000=normal,10000=low, higher=more processor time taken
** RETURN: nonzero=error
*/
extern int stmik_playsong(char far *module);
/* module: far pointer to module to be played (STX). The pointer MUST be
**         on a segment boundary; i.e. OFFSET part MUST be zero!
** RETURN: nonzero=error
*/
extern int stmik_stopsong(void);
/* RETURN: nonzero=error
*/
extern int stmik_setpollmix(int flag);
/*   flag: 0=no pollmix, 1=do pollmix
** RETURN: nonzero=error
*/
extern void stmik_poll(void);
/* must be called >10 times per second when pollmix is on.
** RETURN: none
*/
extern int stmik_songpos(void);
/* note the position is NOT exactly in time (about 1/4 secs early)
** RETURN: order+256*loop_count
*/
extern char far *stmik_nequinfo(void);
/* note the note equ is NOT exactly in time (about 1/4 secs early)
** RETURN: far pointer to note equ
*/

/* routines in STMLOAD.OBJ */

extern char far *stmik_loadstm(char *fname);
/*  fname: name of the .STM to load
** RETURN: NULL=error, otherwise segment to module laoded
*/
