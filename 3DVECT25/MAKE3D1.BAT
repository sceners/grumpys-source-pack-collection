echo only uncomment the files you wish to assemble/change
echo uncomment them all if this is the first assembley

rem tasm xmouse
rem tasm xmode
    tasm 3d1 3d
rem tasm /ml /m2 pmode.asm
    tasm main1 main
rem tasm irq

tlink /x /3 pmode xmode irq xmouse main 3d, main
