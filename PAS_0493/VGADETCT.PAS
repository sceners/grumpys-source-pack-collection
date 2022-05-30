{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 259 of 534
From : Sean Palmer                         1:104/123.0          19 Apr 93  16:29
To   : Aaron Marasco
Subj : VGA Detection
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 AM> I know how to determine the current mode of a card, but how
 AM> do a lot of  programs determine if a VGA is present in the
 AM> first place? I'd really  appreciate some code if possible.
 AM> Oh, and does anyone know about custom  character fonts for
 AM> EGA? Is it possible? If so, could someone also pass  along
 AM> the code for EGA detection? Thanks!

Font-changing is possible, but you seem to have just missed a lot of
font-changing routines on here...

Well, here are routines to detect a VGA and an EGA adapter...}

function EGAInstalled:boolean;assembler;asm
 mov ax,$1200; mov bx,$10; mov cx,$FFFF; int $10;
 inc cx; mov al,cl; or al,ch;
 end;
                                              
function vgaPresent:boolean;assembler;asm
 mov ah,$F; int $10; mov oldMode,al;  {save old Gr mode}
 mov ax,$1A00; int $10;    {check for VGA/MCGA}
 cmp al,$1A; jne @ERR;     {no VGA Bios}
 cmp bl,7; jb @ERR;        {is VGA or better?}
 cmp bl,$FF; jnz @OK;
@ERR: xor al,al; jmp @EXIT;
@OK: mov al,1;
@EXIT:
 end;
 _
/ _
\_/host