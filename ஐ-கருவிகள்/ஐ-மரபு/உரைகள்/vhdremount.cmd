﻿rem http://tamilneram.github.io
@echo off
cls
Set Distroname=ISONAMESLUG
REM echo %~d0
Set DRIVE=%~d0
echo > vdisk.txt Select vdisk file="%DRIVE%\!\%Distroname%\%Distroname%.vhd"
echo >> vdisk.txt attach vdisk
echo >> vdisk.txt exit
diskpart /s vdisk.txt
REM assign letter z
REM subst Z: "%~d0\windows.vhd"
exit