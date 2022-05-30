
#include <stdio.h>
#include <malloc.h>
#include "stmik.h"

int	isfilestx(char *fname);
int	endprg(char *txt);
char far *loadfile(char *fname);

int	autostop=1;
int	extendedhelp=0;
int	io=0x220,irq=0x7,mixspd=16000;
int	quietmode=0;
char	filename[16][65]={"?"};
int	files=0;

main(int argc,char *argv[])
{
	char far *p;
	int	a,b,f;
	for(a=1;a<argc;a++) if(*argv[a]=='/' || *argv[a]=='-') switch(argv[a][1])
	{
		case 'a' :
		case 'A' :
			io=0x200+0x10*(argv[a][3]-'0');
			if((io&15)!=0 || io>0x260 || io<0x210)
			{
				printf("Allowed IO addresses are 210,220,230,240,250 and 260.");
			} break;
		case 'i' :
		case 'I' :
			irq=(argv[a][2]-'0');
			if(irq!=1 && irq!=3 && irq!=5 && irq!=7)
			{
				printf("Allowed IRQ numbers are 1,3,5 and 7.\n");
				exit(1);
			} break;
		case 's' :
		case 'S' :
			mixspd=atoi(argv[a]+2);
			if(mixspd>20000) 
			{
				printf("Maximum mixing speed is 20000.\n");
				exit(1);
			} break;
		case 'q' :
		case 'Q' :
			quietmode=1; break;
		case 'h' :
		case 'H' :
		case '?' :
			extendedhelp=1;
			break;
		case 'c' :
		case 'C' :
			autostop=0;
			break;
	}
	else { strcpy(filename[files],argv[a]); files++; }
	if(*filename[0]=='?' || extendedhelp)
	{
		printf("\nSTMIK module player V1.0   Copyright (C) 1991 Sami Tammilehto\n"
			"usage: PLAY <filename(s)> [switch(es)]    switches:\n"
			"-a###  Address of the SoundBlaster (###=210,220,230...)\n"
			"-i#    IRQ number of the SoundBlaster (#=1,3,5,7)\n"
			"-s#### Mixing speed (10000,16000,20000)\n"
			"-q     Quiet mode; no screen output (except errors)\n"
			"-c     Continuous play; don't stop after one loop\n"
			"-h     Extended help\n");
		if(extendedhelp) printf("\n"
			"The STMIK module player can play both .STX and .STM modules.\n"
			"It will autodetect the module format. The STX modules are meant\n"
			"to be used only in programs using STMIK and are not to be used\n"
			"as storage files. (this is because the format will change!)\n\n"
			"The player defaults to SoundBlaster at 220h with IRQ 7 and mixing\n"
			"speed of 16000. The mixing speed determines the quality of the\n"
			"sound. The higher sounds better (but also takes more processor time.)\n"
			"The speed 16000 is roughly equal to Scream Trackers 12Mhz mode.\n\n"
			"The source code of this player is included in the STMIK\n"
			"(Scream Tracker Music Interface Kit V0.2). Call the Silicon\n"
			"Dragon (+358-21-500318) for STMIK and other great stuff!\n");
		exit(0);
	}
	if(stmik_init(1,io,irq,mixspd)) endprg("Error initializing SoundBlaster.\n");
	for(f=0;f<files;f++)
	{
		strupr(filename[f]);
		if(!quietmode) printf("Loading %s as ",filename[f]);
		if(isfilestx(filename[f]))	
		{
			if(!quietmode) printf("STX... ");
			p=loadfile(filename[f]);
			b=1;
		}
		else 
		{
			if(!quietmode) printf("STM... ");
			p=stmik_loadstm(filename[f]);
			b=0;
		}
		if(p==NULL) endprg("File not found or out of memory.");
		if(!quietmode) printf("Playing... ");
		if(stmik_playsong(p)) endprg("Error while starting song.");
		for(a=-1;!kbhit() && (stmik_songpos()<256 || !autostop);) if(a!=stmik_songpos())
		{
			if(!quietmode) printf("(order:%2i)\b\b\b\b\b\b\b\b\b\b",stmik_songpos()&255);
			a=stmik_songpos();
		}
		while(kbhit()) getch();
		if(!quietmode) printf("Done!                 \n");
		if(stmik_stopsong()) endprg("Error while ending song.");
		/* free memory */
		if(b) hfree(p);
		else stmik_freestm();
	}
}

int	endprg(char *txt)
{
	printf("%s\nExiting to dos.\n",txt);
	exit(3);
}

char far *loadfile(char *fname)
{ /* this routine is not 'standard' C, it uses some DOS/segment stuff
     to make loading easier and works at least under MSC. */
	FILE	*f1;
	char far *p,*p2;
	f1=fopen(fname,"rb");
	if(f1==NULL) return(NULL);
	fseek(f1,0L,SEEK_END);
	p2=p=halloc((long)ftell(f1),1); /* returns a pointer to PURE segment at least under MSC */
	if(p==NULL) return(NULL);
	fseek(f1,0L,SEEK_SET);
	while(fread(p2,1,16384,f1)==16384) p2=(char far *)((long)p2+1024L*65536L);
	fclose(f1);
	return(p);
}

int	isfilestx(char *fname)
{ /* remark that the .STX format is a temporary one, so this routine may
     not work with future versions of the format! */
	int	a=1;
	FILE	*f1;
	f1=fopen(fname,"rb");
	if(f1==NULL) return(1);
	fseek(f1,0x3cL,SEEK_SET);
	if(getc(f1)!='S') a=0;
	if(getc(f1)!='C') a=0;
	if(getc(f1)!='R') a=0;
	if(getc(f1)!='M') a=0;
	fclose(f1);
	return(a);
}
