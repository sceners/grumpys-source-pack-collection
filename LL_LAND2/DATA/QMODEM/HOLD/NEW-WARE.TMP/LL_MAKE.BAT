@echo off
qcl -AH -c ll_land.c
ml -c -VM ll_1.asm
link ll_land ll_1;

