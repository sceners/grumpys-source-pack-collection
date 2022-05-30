tasm /iE:\TASM201\OUTPUT\USE2 /m8 /z /mu plasma.asm
tlink plasma.obj
bin2exe plasma.exe
del plasma.map
del plasma.obj
