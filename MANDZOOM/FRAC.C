
/* Fractal zoom prog by David Hedley...
    Compile with GCC !!!

*/


#include <stdio.h>
#include <pc.h>
#include <dos.h>
#include <math.h>
#include <stdlib.h>

typedef unsigned char byte;

#define MAXX 256
#define MAXY 160

#define XPOS ((320-MAXX)/2)
#define YPOS 4

#define xSAVE

#define plot(x,y,c) (screen_data[(x)+(y)*MAXX] = (byte)(c))
#define peek(x,y) (screen_data[(x)+(y)*MAXX])

#define F_BITS 22

typedef long fixed;

#define Float2Fixed(a) (fixed)((a) * (float)(1 << F_BITS))
#define Int2Fixed(a) (fixed)((a) << F_BITS)
#define Fixed2Int(a) (int)((a) >> F_BITS)
#define Fixed2Float(a) (float)((a) / (float)(1 << F_BITS))


#define S_BITS 16

#define Float2SF(a) (fixed)((a) * (float)(1 << S_BITS))
#define Int2SF(a) (fixed)((a) << S_BITS)
#define SF2Int(a) (int)((a) >> S_BITS)


#ifdef SAVE
    byte array1[MAXX*MAXY*4];
#else
    extern byte array1[MAXX*MAXY*4];
#endif

byte array2[MAXX*MAXY*4];

byte screen_data[MAXX*MAXY];

byte *mand_data = array1;
byte *other_data = array2;


fixed m_x1 = Float2Fixed(-3.17559521);
fixed m_y1 = Float2Fixed(2.53588476);
fixed m_x2 = Float2Fixed(1.97954465);
fixed m_y2 = Float2Fixed(-1.21328414);


extern byte bits_graphic[];
extern byte lefttext[];
extern byte righttext[];

int ysrc,xsrc;
fixed ysz,xsz;
int frame = 0;


extern byte palette[];


fixed FixedMul(fixed a, fixed b)
{
    asm ("
        movl 8(%ebp),%eax
        imull 12(%ebp)
        ");
    asm ("shrd %0,%%edx,%%eax" : : "i" (F_BITS));
}


fixed FixedDiv(fixed a, fixed b)
{
    asm ("
        movl 8(%ebp),%eax
        movl %eax,%edx
        ");
    asm ("sar %0,%%edx" : : "i" (32-F_BITS));
    asm ("shl %0,%%eax" : : "i" (F_BITS));
    asm ("idivl 12(%ebp)");
}


/*
byte getch(void)
{
    union REGS regs;

    regs.h.ah = 0x06;
    regs.h.dl = 0xff;
    int86(0x21,&regs,&regs);

    return regs.h.al;
}
*/


void zoom(void *src, void *dest, int n_width, int n_height, int o_width,
                    int o_height, int d_width, int s_width)
{
    if (n_width == 0 || n_height == 0) return;

    asm("
        pushl %esi
        pushl %edi
        pushl %ebx
        pushl %ebp

        movl  8(%ebp),%esi
        movl 12(%ebp),%edi
        movl 16(%ebp),%eax
        movl 20(%ebp),%ebx
        movl 24(%ebp),%ecx
        movl 28(%ebp),%edx
        movl 32(%ebp),%ebp
        shll $16,%ebp
        movw 52(%esp),%ebp

        call do_zoom

        popl %ebp
        popl %ebx
        popl %edi
        popl %esi
        ");
}


byte scrn_buff[320*200];


void Sync(void)
{
    while (inportb(0x3da) & 8);
    while (!(inportb(0x3da) & 8));
}


void ZoomScreen(void)
{
    int height;
    fixed denom,width;

    denom = Int2Fixed(80);
    width = Int2Fixed(0);

    while (width < Int2Fixed(320))
    {
        width = FixedDiv(Int2Fixed(320),denom);
        height = (200*Fixed2Int(width)) / 320;

        Sync();

        zoom(scrn_buff,(void *)(0xd0000000+(320-Fixed2Int(width))/2+
                ((200-height)/2)*320),Fixed2Int(width),height,320,200,320,320);

        denom -= Float2Fixed(0.25);
    }
}



void EndZoom(void)
{
    int height;
    int width;

    bcopy((void *)0xd0000000,scrn_buff,320*200);

    width = 320;

    while (width > 1)
    {
        height = (200*width) / 320;

        Sync();

        zoom(scrn_buff+(320-width)/2+((200-height)/2)*320,
                (void *)0xd0000000,320,200,width,height,320,320);

        width -= 4;
    }
}



#define MAXITER 256


byte Mandel(fixed x, fixed y)
{
    int volatile iter = MAXITER-1;

    asm ("
        pushl %esi
        pushl %edi
        pushl %ebx

        movl 8(%ebp),%esi
        movl 12(%ebp),%edi
LOOP:
        movl %esi,%eax
        imul %eax
        ");
    asm ("shrd %0,%%edx,%%eax" : : "i" (F_BITS) );
    asm ("
        movl %eax,%ebx

        movl %edi,%eax
        imul %eax
        ");
    asm ("shrd %0,%%edx,%%eax" : : "i" (F_BITS) );
    asm ("
        movl %eax,%ecx

        addl %ebx,%eax
        ");

    asm ("cmpl %0,%%eax" : : "i" (4*(1 << F_BITS)) );
    asm ("
        jg EXIT

        movl %edi,%eax
        imul %esi
        ");
    asm ("shrd %0,%%edx,%%eax" : : "i" (F_BITS) );
    asm ("
        movl %ebx,%esi
        subl %ecx,%esi
        addl 8(%ebp),%esi

        leal (%eax,%eax),%edi
        addl 12(%ebp),%edi

        decl -4(%ebp)
        jnz LOOP

EXIT:
        popl %ebx
        popl %edi
        popl %esi
        ");

    return (byte)(MAXITER - iter);

}



void ResetAll(void)
{
    register byte *dest;
    fixed tmp = FixedDiv(m_x2-m_x1,Float2Fixed(4.0));

    m_x1 += tmp;
    m_x2 -= tmp;

    tmp = FixedDiv(m_y2-m_y1,Float2Fixed(4.0));

    m_y1 += tmp;
    m_y2 -= tmp;

    dest = mand_data;
    mand_data = other_data;
    other_data = dest;

    ysz = Int2SF(2*MAXY);
    xsz = Int2SF(2*MAXX);

    ysrc = 0;
    xsrc = 0;
    frame = 0;
}


void UpdateScreen(void *destination)
{
    asm("
        pushl %esi
        pushl %edi
        pushl %ebx
        cld
        ");
    asm("movl %0,%%edx" : : "i" (MAXY-9));
    asm("movl %0,%%esi" : : "i" (screen_data));
    asm("
        movl 8(%ebp),%edi

update_back:
        ");
    asm("movl %0,%%ecx" : : "i" (MAXX/4));
    asm("
        rep
        movsl
        ");
    asm("addl %0,%%edi" : : "i" (320-MAXX));
    asm("
        decl %edx
        jnz update_back
        ");

    asm("movl %0,%%ebx" : : "i" (bits_graphic+XPOS));
    asm("
        movl $9,%edx

update_under:

        ");
    asm("movl %0,%%ecx" : : "i" (MAXX));
    asm("

update_under_next:

        testb $-1,(%ebx)
        jnz update_skip

        movb (%esi),%al
        movb %al,(%edi)

update_skip:

        inc %esi
        inc %edi
        inc %ebx

        dec %ecx
        jnz update_under_next

        ");
    asm("addl %0,%%edi" : : "i" (320-MAXX));
    asm("addl %0,%%ebx" : : "i" (320-MAXX));
    asm("

        decl %edx
        jnz update_under

        popl %ebx
        popl %edi
        popl %esi
        ");
}

/*
#define GetMandel(a,b,xp,yp) Mandel(xp,yp)
*/

#define GetMandel(Mx,My,Mxpos,Mypos) \
    ((Mx) < MAXX-1 \
    ? \
        ((peek((Mx)+1,(My)+1) == peek((Mx)-1,(My)-1) && \
        peek((Mx)+1,(My)+1) == peek((Mx)+1,(My)-1) && \
        peek((Mx)+1,(My)+1) == peek((Mx)-1,(My)+1)) \
            ? \
                peek((Mx)+1,(My)+1) \
            : \
                Mandel(Mxpos,Mypos)) \
    : \
        ((peek((Mx),(My)) == peek((Mx),(My)-1) && \
        peek((Mx),(My)) == peek((Mx),(My)+1)) \
            ? \
                peek((Mx),(My)) \
            : \
                Mandel(Mxpos,Mypos)))


void CalcColumn()
{
    #define YS_BITS 30

    fixed n_x1,n_y1,n_x2,n_y2;
    fixed xdiff,ydiff,s_x1,s_y1;
    register int y;
    register fixed ypos;
    fixed xp,ystep,sstep;
    register byte *m,*mand;
    int sx;
    fixed sy;

    n_x1 = m_x1+FixedDiv(m_x2-m_x1,Int2Fixed(4));
    n_x2 = m_x2-FixedDiv(m_x2-m_x1,Int2Fixed(4));

    n_y1 = m_y1+FixedDiv(m_y2-m_y1,Int2Fixed(4));
    n_y2 = m_y2-FixedDiv(m_y2-m_y1,Int2Fixed(4));

    xdiff = FixedMul(m_x2 - m_x1, Int2Fixed(1)-
                    FixedDiv(Int2Fixed(xsrc),Int2Fixed(MAXX)));

    ydiff = FixedMul(m_y2 - m_y1, Int2Fixed(1)-
                    FixedDiv(Int2Fixed(ysrc),Int2Fixed(MAXY)));

    s_x1 = FixedMul(m_x2-m_x1,FixedDiv(Int2Fixed(xsrc) >> 1,Int2Fixed(MAXX)))
                + m_x1;

    s_y1 = FixedMul(m_y2-m_y1,FixedDiv(Int2Fixed(ysrc) >> 1,Int2Fixed(MAXY)))
                + m_y1;

    ystep = ((n_y2-n_y1) << (YS_BITS-F_BITS)) / (2*MAXY);

    sstep = FixedMul(FixedDiv(ystep >> (YS_BITS-F_BITS), ydiff),Int2Fixed(MAXY));

    m = &other_data[frame << 1];
    mand = &mand_data[(frame + MAXX/2)+(MAXY/2)*2*MAXX];

    for (y = 0; y < MAXY; y++, m += 2*2*MAXX, mand += 2*MAXX)
        *m = *mand;

    xp = FixedMul(FixedDiv(Int2Fixed(frame << 1) >> 1, Int2Fixed(MAXX)),
                n_x2-n_x1) + n_x1;
    sx = Fixed2Int(FixedMul(FixedDiv(xp - s_x1, xdiff),Int2Fixed(MAXX)));
    m = &other_data[(frame << 1)+2*MAXX];
    ypos = (n_y1 << (YS_BITS-F_BITS))+ystep;

    sy = FixedMul(FixedDiv((ypos >> (YS_BITS-F_BITS))-s_y1,ydiff),
                                        Int2Fixed(MAXY));


    for (y = 0; y < MAXY-3; y++,m+=2*2*MAXX,ypos+=ystep << 1,sy+=(sstep<<1))
        *m = GetMandel(sx+1,Fixed2Int(sy)+1,xp, ypos >> (YS_BITS-F_BITS));


    xp = FixedMul(FixedDiv(Int2Fixed((frame << 1)+1) >> 1, Int2Fixed(MAXX)),
                n_x2-n_x1) + n_x1;
    sx = Fixed2Int(FixedMul(FixedDiv(xp - s_x1, xdiff),Int2Fixed(MAXX)));
    m = &other_data[(frame << 1)+1];
    ypos = n_y1 << (YS_BITS - F_BITS);

    sy = FixedMul(FixedDiv((ypos >> (YS_BITS-F_BITS))-s_y1,ydiff),
                                        Int2Fixed(MAXY));


    for (y = 0; y < 2*MAXY-2; y++,m += 2*MAXX, ypos += ystep, sy += sstep)
        *m = GetMandel(sx+1,Fixed2Int(sy)+1,xp, ypos >> (YS_BITS-F_BITS));


	m = &other_data[(frame+128) << 1];
    mand = &mand_data[(frame+MAXX)+(MAXY/2)*2*MAXX];

    for (y = 0; y < MAXY; y++, m += 2*2*MAXX, mand += 2*MAXX)
        *m = *mand;

    xp = FixedMul(FixedDiv(Int2Fixed((frame+128) << 1) >> 1, Int2Fixed(MAXX)),
                n_x2-n_x1) + n_x1;
    sx = Fixed2Int(FixedMul(FixedDiv(xp - s_x1, xdiff),Int2Fixed(MAXX)));
    m = &other_data[((frame+128) << 1)+2*MAXX];
    ypos = (n_y1 << (YS_BITS-F_BITS)) + ystep;

    sy = FixedMul(FixedDiv((ypos >> (YS_BITS-F_BITS))-s_y1,ydiff),
                                        Int2Fixed(MAXY));


    for (y = 0; y < MAXY-3;y++,m+=2*2*MAXX,ypos+=ystep << 1,sy+=(sstep<<1))
        *m = GetMandel(sx+1,Fixed2Int(sy)+1,xp, ypos >> (YS_BITS-F_BITS));


    xp = FixedMul(FixedDiv(Int2Fixed(((frame+128) << 1)+1) >> 1, Int2Fixed(MAXX)),
                n_x2-n_x1) + n_x1;
    sx = Fixed2Int(FixedMul(FixedDiv(xp - s_x1, xdiff),Int2Fixed(MAXX)));
    m = &other_data[((frame+128) << 1)+1];
    ypos = n_y1 << (YS_BITS-F_BITS);

    sy = FixedMul(FixedDiv((ypos >> (YS_BITS-F_BITS))-s_y1,ydiff),
                                                        Int2Fixed(MAXY));


    for (y = 0; y < 2*MAXY-2; y++,m += 2*MAXX,ypos+=ystep, sy += sstep)
        *m = GetMandel(sx+1,Fixed2Int(sy)+1,xp, ypos >> (YS_BITS-F_BITS));

}


void SetCols(void)
{
    int c;

    outportb(0x3c8,0);

    for (c = 0; c < 256*3; c++)
        outportb(0x3c9,palette[c]);

}


void PutText(byte *text, int height, void *dest)
{
    asm("
        pushl %esi
        pushl %edi
        cld

        movl 12(%ebp),%edx
        movl 8(%ebp),%esi
        movl 16(%ebp),%edi

next_row_left:

        movl $8,%ecx
        rep
        movsl

        addl $288,%edi
        decl %edx
        jnz next_row_left

        popl %edi
        popl %esi
        ");
}


void PutGraphic(void)
{
    asm("
        pushl %esi
        pushl %edi
        ");
    asm("movl %0,%%esi" : : "i" (bits_graphic));
    asm("movl %0,%%edi" : : "i" (scrn_buff+155*320));
    asm("movl %0,%%ecx" : : "i" (45*320));
    asm("

put_graphic_next:

        testb $-1,(%esi)
        jz put_graphic_skip

        movb (%esi),%al
        movb %al,(%edi)

put_graphic_skip:

        incl %esi
        incl %edi
        decl %ecx
        jnz put_graphic_next

        popl %edi
        popl %esi
        ");
}


 
int main(void)
{
    union REGS regs;
    int count;

    byte pic;


#ifdef SAVE
    int j;
    byte *m;
    FILE *f1;
#endif

    regs.x.ax = 0x13;
    int86(0x10,&regs,&regs);

    pic = inportb(0x21);
    outportb(0x21,0xfe);

    SetCols();

    PutText(lefttext,161,scrn_buff);
    PutText(righttext,161,scrn_buff+288);
    PutGraphic();

	ysrc = 0;
    ysz = Int2SF(MAXY*2);
    xsz = Int2SF(MAXX*2);

#ifdef SAVE
    f1 = fopen("data.tbl","wb");

    for (j = 0,m = mand_data; j < 2*MAXY; j++)
        for (i = 0; i < 2*MAXX; i++,m++)
        {
           *m = Mandel(FixedMul(FixedDiv(Int2Fixed(i) >> 1,
                           Int2Fixed(MAXX)),m_x2-m_x1)+m_x1,
                           FixedMul(FixedDiv(Int2Fixed(j) >> 1,
                           Int2Fixed(MAXY)), m_y2-m_y1) + m_y1);
           plot(i >> 1, j >> 1, *m);
        }

    fwrite(mand_data,1,sizeof array1,f1);
    fclose(f1);
    return 0;
#endif

    zoom(mand_data,screen_data,MAXX,MAXY,2*MAXX,2*MAXY,MAXX,2*MAXX);

    UpdateScreen((void *)(scrn_buff+XPOS+(YPOS)*320));
    ZoomScreen();

    for(count = 1450; count > 0; count--)
	{
        if (inportb(0x60) == 1)
            break;

        xsz -= Float2SF(2.0);
        ysz -= Float2SF(1.25);

        xsrc = SF2Int((Int2SF(2*MAXX)-xsz)/2);
        ysrc = SF2Int((Int2SF(2*MAXY)-ysz)/2);

        zoom(mand_data+xsrc+ysrc*2*MAXX,screen_data,MAXX,MAXY,SF2Int(xsz),
                    SF2Int(ysz),MAXX,2*MAXX);

        CalcColumn();

        UpdateScreen((void *)(0xd0000000+XPOS+(YPOS)*320));

        frame++;

        if (xsz == Int2SF(MAXX))
            ResetAll();
	}

    EndZoom();

    regs.x.ax = 0x3;
    int86(0x10,&regs,&regs);

    outportb(0x21,pic);

    return 0;
}











