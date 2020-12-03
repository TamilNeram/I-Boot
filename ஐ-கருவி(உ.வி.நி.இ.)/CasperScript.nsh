﻿; ------------ Casper Script --------------
Function CasperScript
${If} $Casper != "0"
${AndIf} $DistroName != "Windows to Go (Virtual Hard Disk)"
 Call GetCaspTools
  ${If} $DistroName == "Debian Live"
  StrCpy $CasperName "persistence"
  ${ElseIf} $DistroName == "Raspberry Pi Desktop"
  StrCpy $CasperName "persistence"
  ${Else}
  StrCpy $CasperName "writable"
  ${EndIf} 
 SetShellVarContext all
 InitPluginsDir
 ExpandEnvStrings $COMSPEC "%COMSPEC%"
 ExecShell "" '"$COMSPEC"' '/C if 1==1 "$PLUGINSDIR\dd.exe" if=/dev/zero of=$BootDir\multiboot\$JustISOName\$CasperName bs=1M count=$Casper --progress 2>$PLUGINSDIR\ddlog.txt' SW_HIDE
 Banner::show /set 76 "Creating a Persistent File."
 Banner::getWindow
 Pop $1  
 DetailPrint "நிலைத்தன்மை கோப்பை உருவாக்குதல்: முடிவடையும் வரை முன்னேற்றப் பட்டி நகராது..."
 Call ddProgress
 Banner::destroy
  ${If} $DistroName == "Raspberry Pi Desktop"
   nsExec::ExecToLog '"$PLUGINSDIR\mke2fs.exe" -L persistence $BootDir\multiboot\$JustISOName\$CasperName'
  ${Else}
   nsExec::ExecToLog '"$PLUGINSDIR\mke2fs.exe" -L $CasperName $BootDir\multiboot\$JustISOName\$CasperName'
  ${EndIf} 
 ;CopyFiles $PLUGINSDIR\$CasperName "$BootDir\multiboot\$JustISOName\$CasperName" ; Copy casper-rw to USB
 ;Delete "$PLUGINSDIR\$CasperName"
${EndIf}
FunctionEnd

Function CasperSize
 IntOp $SizeOfCasper $SizeOfCasper + $Casper
FunctionEnd

Function GetCaspTools
SetShellVarContext all
InitPluginsDir
File /oname=$PLUGINSDIR\dd.exe "இருமங்கள்\dd.exe"
File /oname=$PLUGINSDIR\mke2fs.exe "இருமங்கள்\mke2fs.exe"
DetailPrint "இப்போது ஒரு நிலைத்தன்மை அல்லது எழுதக்கூடிய கோப்பை உருவாக்குதல்" 
DetailPrint "நிலைத்தன்மை கோப்பை உருவாக்குதல்: முடிவடையும் வரை முன்னேற்றப் பட்டி நகராது. தயவுசெய்து பொருமையாயிறு..." 
FunctionEnd