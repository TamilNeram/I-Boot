﻿; -- Configuration and Text File Manipulation Stuff! --

Function FindFiles ; <- FindFiles function written by KiCHik http://nsis.sourceforge.net/Search_For_a_File
  Exch $R5 # callback function
  Exch 
  Exch $R4 # file name
  Exch 2
  Exch $R0 # directory
  Push $R1
  Push $R2
  Push $R3
  Push $R6
  Push $R0 # first dir to search
  StrCpy $R3 1
  nextDir:
    Pop $R0
    IntOp $R3 $R3 - 1
    ClearErrors
    FindFirst $R1 $R2 "$R0\*.*"
    nextFile:
      StrCmp $R2 "." gotoNextFile
      StrCmp $R2 ".." gotoNextFile
 
      StrCmp $R2 $R4 0 isDir
        Push "$R0\$R2"
        Call $R5
        Pop $R6
        StrCmp $R6 "stop" 0 isDir
          loop:
            StrCmp $R3 0 done
            Pop $R0
            IntOp $R3 $R3 - 1
            Goto loop
      isDir:
        IfFileExists "$R0\$R2\*.*" 0 gotoNextFile
          IntOp $R3 $R3 + 1
          Push "$R0\$R2"
  gotoNextFile:
    FindNext $R1 $R2
    IfErrors 0 nextFile
  done:
    FindClose $R1
    StrCmp $R3 0 0 nextDir
  Pop $R6
  Pop $R3
  Pop $R2
  Pop $R1
  Pop $R0
  Pop $R5
  Pop $R4
FunctionEnd
!macro CallFindFiles DIR FILE CBFUNC
Push "${DIR}"
 StrCpy $SearchDir "${DIR}"
Push "${FILE}"
 StrCpy $SearchFile "${FILE}"
Push $0
GetFunctionAddress $0 "${CBFUNC}"
Exch $0
Call FindFiles
!macroend
Function CBFUNC
  Exch $0
  DetailPrint "Found $SearchFile at $0"  
  CopyFiles "$PLUGINSDIR\$SearchFile" "$0" 
  Pop $0
  Push "stop"
FunctionEnd

Function WriteToFile ; modified to populate *.cfg file with the distro user installed!
 Exch $R0 ;file to write to
 Exch
 Exch $1 ;text to write
 FileOpen $R0 '$BootDir\!\menu\$DistroPath' a 
 FileSeek $R0 0 END
 FileWrite $R0 '$\r$\n$1' ; புதிய வரி மற்றும் தரவைச் சேர்க்கவும்
 FileClose $R0
 Pop $1
 Pop $R0
FunctionEnd

!macro WriteToFile String File
 Push "${String}"
 Push "${File}"
 Call WriteToFile
 ${LineFind} "$BootDir\!\menu\$DistroPath" "$BootDir\!\menu\$DistroPath" "1:-1" "DeleteEmptyLine" ; Remove any left over empty lines
!macroend  
!define WriteToFile "!insertmacro WriteToFile"

Function WriteToSysFile ; Write entry to syslinux.cfg
 Exch $R0 ;file to write to
 Exch
 Exch $1 ;text to write
 FileOpen $R0 '$BootDir\!\syslinux.cfg' a 
 FileSeek $R0 0 END
 FileWrite $R0 '$\r$\n$1$\r$\n'
 FileClose $R0
 Pop $1
 Pop $R0
FunctionEnd
!macro WriteToSysFile String File
  Push "${String}"
  Push "${File}"
  Call WriteToSysFile
!macroend  
!define WriteToSysFile "!insertmacro WriteToSysFile"

Function InstalledList ; Creates a list of installed distros in the ! folder on the USB drive (So we can uninstall the distros later)
 ${IfNot} ${FileExists} "$BootDir\!\$JustISOName\*.*" ; If the installation directory exists user must be reinstalling the same distro, so we won't add a removal entry. 
   Exch $R0 ;file to write to
   Exch
   Exch $1 ;text to write
   ${If} ${FileExists} "$BootDir\!\நிறுவப்பட்டது.உரை" 
    FileOpen $R0 '$BootDir\!\நிறுவப்பட்டது.உரை' a 
    FileSeek $R0 0 END
	FileWrite $R0 '$\r$\n$1' ; add subsequent entry on a new line
   ${Else}
    FileOpen $R0 '$BootDir\!\நிறுவப்பட்டது.உரை' a 
    FileSeek $R0 0 END
    FileWrite $R0 '$1'  ; add first entry without a new line
   ${EndIf}
    FileClose $R0
    Pop $1
    Pop $R0
 ${EndIf}
FunctionEnd
!macro InstalledList String File
  Push "${String}"
  Push "${File}"
  Call InstalledList
!macroend  
!define InstalledList "!insertmacro InstalledList"


Function RemovalList ; Lists the distros installed on the select drive.
 ${NSD_SetText} $LinuxDistroSelection "படி 2: $DestDiskஇலிருந்து அகற்ற தேர்வு"  
 ${If} ${FileExists} "$BootDir\!\நிறுவப்பட்டது.உரை" ; Are there distributions on the select drive? 
 ClearErrors
 FileOpen $0 $BootDir\!\நிறுவப்பட்டது.உரை r
  loop:
   FileRead $0 $1
    IfErrors done
    StrCpy $DistroName $1
	${ஒழுங்கமை} "$DistroName" "$DistroName" ; Remove spaces, newlines, and carriage return
    ${NSD_CB_AddString} $Distro "$DistroName" ; Add DistroName to the listbox of removable distros ; was ${NSD_LB_AddString} $Distro "$DistroName" ; Enable for DropBox
   Goto loop
  done:  
 FileClose $0
 ${Else}
     ;Call SetISOFileName
 ${EndIf}
FunctionEnd

!include "TextFunc.nsh" ; TextFunc.nsh required for the following DeleteInstall function
Function DeleteInstall  ; நிறுவப்பட்டது.உரைஇலிருந்து உள்ளீட்டைத் தேர்ந்தெடு நீக்குகிறது          
	StrLen $0 "$DistroName"
	StrCpy $1 "$R9" $0
	StrCmp $1 "$DistroName" 0 End
	StrCpy $R9 ""
	End:
	Push $0
FunctionEnd

Function DeleteEmptyLine ;நிறுவப்பட்டது.உரையிலிருந்து வெற்று வரியை நீக்குகிறது
	StrLen $0 "$\r$\n"
	StrCpy $1 "$R9" $0
	StrCmp $1 "$\r$\n" 0 End
	StrCpy $R9 ""
	End:
	Push $0
FunctionEnd
