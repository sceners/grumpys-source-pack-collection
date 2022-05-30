echo off
tasm main.asm,demo.obj;
if ERRORLEVEL 1 goto end
link /E demo.obj+stmik020.obj,mental.exe;
:end

