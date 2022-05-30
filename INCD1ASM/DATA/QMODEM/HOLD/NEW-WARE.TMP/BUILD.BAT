@echo off
cls
echo Please wait...
tasm loader
tlink loader /x
cutsize
copy /b loader2.exe+datafile.inc fedtmule.exe > nul
del loader.exe > nul
del loader2.exe > nul
del *.obj > nul
ren fedtmule.exe loader.*
echo - All done!
echo - 
echo - ONLY spread loader.exe!    That's the final loader!
echo -
echo -                             Later, Xerox & Red scorpion of *INC*
