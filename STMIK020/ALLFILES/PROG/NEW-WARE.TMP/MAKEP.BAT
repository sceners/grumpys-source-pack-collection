qcl /AL /c play.c
if ERRORLEVEL 1 goto end
link /E play.obj+stmik020.obj+stmload.obj,play.exe;
:end
