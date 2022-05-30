#ifndef LL_KEY_H
#define LL_KEY_H
#include "ll_keylist.h"

extern void ll_keyswap();
extern char LL_KEYFLAG[256];
extern char LL_KEYCHANGE;
extern char LL_KEYBUF;
extern char ll_keyget();
extern char ll_keyhit();

#define ll_keypressed( key )  ((LL_KEYFLAG[key]))
#define ll_keyset( key )   {(LL_KEYFLAG[key]) = (char)1;}
#define ll_keyclr( key ) {(LL_KEYFLAG[key]) = (char)0;}
#define ll_keyreset( key ) {(LL_KEYFLAG[key]) = (LL_KEYFLAG[key+1]);}
#define ll_keypress( key ) ((LL_KEYFLAG[key+1]))

#ifndef ON
#define ON 1
#endif

#ifndef OFF
#define OFF 0
#endif

#endif
