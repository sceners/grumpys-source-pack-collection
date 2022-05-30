echo only uncomment the files you wish to assemble/change
echo uncomment them all if this is the first assembley

rem tasm xmouse
rem tasm xmode
    tasm /m2 /kh10000 3d2 3d
rem tasm /ml /m2 pmode.asm
    tasm main2 main
rem tasm irq

tlink /x /3 pmode xmode irq xmouse 3d main,main
