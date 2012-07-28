!include "x64.nsh"
!include MUI2.nsh
!include WinVer.nsh
; The name of the installer
Name "BASSMIDI System Synth"

; The file to write
OutFile "bassmididrv.exe"
; Request application privileges for Windows Vista
RequestExecutionLevel admin
SetCompressor /solid lzma 
;--------------------------------
; Pages
!insertmacro MUI_PAGE_WELCOME
Page Custom LockedListShow
!insertmacro MUI_PAGE_INSTFILES
UninstPage Custom un.LockedListShow
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

!macro DeleteOnReboot Path
  IfFileExists `${Path}` 0 +3
    SetFileAttributes `${Path}` NORMAL
    Delete /rebootok `${Path}`
!macroend
!define DeleteOnReboot `!insertmacro DeleteOnReboot`

Function LockedListShow
 ${If} ${AtLeastWinVista}
  !insertmacro MUI_HEADER_TEXT `File in use check` `Drive use check`
  LockedList::AddModule \bassmididrv.dll
  LockedList::Dialog  /autonext   
  Pop $R0
  ${EndIf}
FunctionEnd
Function un.LockedListShow
 ${If} ${AtLeastWinVista}
  !insertmacro MUI_HEADER_TEXT `File in use check` `Drive use check`
  LockedList::AddModule \bassmididrv.dll
  LockedList::Dialog  /autonext   
  Pop $R0
 ${EndIf}
FunctionEnd
;--------------------------------
Function .onInit
ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth" "UninstallString"
  StrCmp $R0 "" done
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "The MIDI driver is already installed. $\n$\nClick `OK` to remove the \
  previous version or `Cancel` to cancel this upgrade." \
  IDOK uninst
  Abort
;Run the uninstaller
uninst:
  ClearErrors
  Exec $R0
  Abort
done:
   MessageBox MB_YESNO "This will install the BASSMIDI System Synth. Continue?" IDYES NoAbort
     Abort ; causes installer to quit.
   NoAbort:
 FunctionEnd
; The stuff to install
Section "Needed (required)"
  SectionIn RO
  ; Copy files according to whether its x64 or not.
   DetailPrint "Copying driver and synth..."
   ${If} ${RunningX64}
   SetOutPath "$WINDIR\SysWow64\bassmididrv"
   File bass.dll 
   File bassmidi.dll 
   File bassmididrv.dll 
   File bassmididrvcfg.exe
   RegDLL "$WINDIR\SysWow64\bassmididrv\bassmididrv.dll"
   ;check if already installed
   StrCpy  $1 "0"
LOOP1:
  ;k not installed, do checks
  IntOp $1 $1 + 1
  ClearErrors
  ReadRegStr $0  HKLM "Software\Microsoft\Windows NT\CurrentVersion\Drivers32" "midi$1"
  StrCmp $0 "" INSTALLDRIVER NEXTCHECK
  NEXTCHECK:
  StrCmp $0 "wdmaud.drv" 0  NEXT1
INSTALLDRIVER:
  WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\Drivers32" "midi$1" "bassmididrv\bassmididrv.dll"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth\Backup" \
      "MIDI" "midi$1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth\Backup" \
      "MIDIDRV" "$0"
  Goto REGDONE
NEXT1:
  StrCmp $1 "9" 0 LOOP1
   ${Else}
   SetOutPath "$WINDIR\System32\bassmididrv"
   File bass.dll 
   File bassmidi.dll 
   File bassmididrv.dll 
   File bassmididrvcfg.exe
   RegDLL "$WINDIR\System32\bassmididrv\bassmididrv.dll"
   ;check if already installed
   StrCpy  $1 "0"
LOOP2:
  ;k not installed, do checks
  IntOp $1 $1 + 1
  ClearErrors
  ReadRegStr $0  HKLM "Software\Microsoft\Windows NT\CurrentVersion\Drivers32" "midi$1"
  StrCmp $0 "" INSTALLDRIVER2 NEXTCHECK2
  NEXTCHECK2:
  StrCmp $0 "wdmaud.drv" 0  NEXT2
INSTALLDRIVER2:
  WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\Drivers32" "midi$1" "bassmididrv\bassmididrv.dll"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth\Backup" \
      "MIDI" "midi$1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth\Backup" \
      "MIDIDRV" "$0"
  Goto REGDONE
NEXT2:
  StrCmp $1 "9" 0 LOOP2
   ${EndIf}
REGDONE:
  ; Write the uninstall keys
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth" "DisplayName" "BASSMIDI System Synth"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth" "NoRepair" 1
  WriteRegDWORD HKLM "Software\BASSMIDI Driver" "volume" "10000"
  CreateDirectory "$SMPROGRAMS\BASSMIDI System Synth"
 ${If} ${RunningX64}
   WriteUninstaller "$WINDIR\SysWow64\bassmididrv\bassmididrvuninstall.exe"
   WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth" "UninstallString" '"$WINDIR\SysWow64\bassmididrv\bassmididrvuninstall.exe"'
   WriteRegStr HKLM "Software\BASSMIDI Driver" "path" "$WINDIR\SysWow64\bassmididrv"
   CreateShortCut "$SMPROGRAMS\BASSMIDI System Synth\Uninstall.lnk" "$WINDIR\SysWow64\bassmididrv\bassmididrvuninstall.exe" "" "$WINDIR\SysWow64\bassmididrvuninstall.exe" 0
   CreateShortCut "$SMPROGRAMS\BASSMIDI System Synth\Configure BASSMIDI Driver.lnk" "$WINDIR\SysWow64\bassmididrv\bassmididrvcfg.exe" "" "$WINDIR\SysWow64\bassmididrv\bassmididrvcfg.exe" 0
   ${Else}
   WriteUninstaller "$WINDIR\System32\bassmididrvuninstall.exe"
   WriteRegStr HKLM "Software\BASSMIDI Driver" "path" "$WINDIR\System32\bassmididrv"
   WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth" "UninstallString" '"$WINDIR\System32\bassmididrv\bassmididrvuninstall.exe"'
   CreateShortCut "$SMPROGRAMS\BASSMIDI System Synth\Uninstall.lnk" "$WINDIR\System32\bassmididrv\bassmididrvuninstall.exe" "" "$WINDIR\System32\bassmididrv\bassmididrvuninstall.exe" 0
   CreateShortCut "$SMPROGRAMS\BASSMIDI System Synth\Configure BASSMIDI Driver.lnk" "$WINDIR\System32\bassmididrv\bassmididrvcfg.exe" "" "$WINDIR\System32\bassmididrv\bassmididrvcfg.exe" 0
   ${EndIf}
   MessageBox MB_OK "Installation complete! Use the driver configuration tool which is in the 'BASSMIDI System Synth' program shortcut directory to configure the driver."

SectionEnd
;--------------------------------

; Uninstaller

Section "Uninstall"
   ; Remove registry keys
    ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth\Backup" \
       "MIDI"
  ReadRegStr $1 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth\Backup" \
      "MIDIDRV"
  WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\Drivers32" "$0" "$1"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BASSMIDI System Synth"
  DeleteRegKey HKLM "Software\BASSMIDI Driver"
  RMDir /r "$SMPROGRAMS\BASSMIDI System Synth"
 ${If} ${RunningX64}
 ${If} ${AtLeastWinVista}
  UnRegDLL "$WINDIR\SysWow64\bassmididrv\bassmididrv.dll"
  Delete $WINDIR\SysWow64\bassmididrv\bass.dll
  Delete $WINDIR\SysWow64\bassmididrv\bassmidi.dll
  Delete $WINDIR\SysWow64\bassmididrv\bassmididrv.dll
  Delete $WINDIR\SysWow64\bassmididrv\bassmididrvuninstall.exe
  Delete $WINDIR\SysWow64\bassmididrv\bassmididrvcfg.exe
${Else}
  UnRegDLL "$WINDIR\SysWow64\bassmididrv\bassmididrv.dll"
  MessageBox MB_OK "Note: The uninstaller will reboot your system to remove drivers."
  ${DeleteOnReboot} $WINDIR\SysWow64\bassmididrv\bass.dll
  ${DeleteOnReboot} $WINDIR\SysWow64\bassmididrv\bassmidi.dll
  ${DeleteOnReboot} $WINDIR\SysWow64\bassmididrv\bassmididrv.dll
  ${DeleteOnReboot} $WINDIR\SysWow64\bassmididrv\bassmididrvuninstall.exe
  ${DeleteOnReboot} $WINDIR\SysWow64\bassmididrv\bassmididrvcfg.exe
  Reboot
${Endif}
${Else}
${If} ${AtLeastWinVista}
  UnRegDLL "$WINDIR\System32\bassmididrv\bassmididrv.dll"
  Delete $WINDIR\System32\bassmididrv\bass.dll
  Delete $WINDIR\System32\bassmididrv\bassmidi.dll
  Delete $WINDIR\System32\bassmididrv\bassmididrv.dll
  Delete $WINDIR\System32\bassmididrv\bassmididrvuninstall.exe
  Delete $WINDIR\System32\bassmididrv\bassmididrvcfg.exe
${Else}
  UnRegDLL "$WINDIR\System32\bassmididrv.dll"
  MessageBox MB_OK "Note: The uninstaller will reboot your system to remove drivers."
  ${DeleteOnReboot} $WINDIR\System32\bassmididrv\bass.dll
  ${DeleteOnReboot} $WINDIR\System32\bassmididrv\bassmidi.dll
  ${DeleteOnReboot} $WINDIR\System32\bassmididrv\bassmididrv.dll
  ${DeleteOnReboot} $WINDIR\System32\bassmididrv\bassmididrvuninstall.exe
  ${DeleteOnReboot} $WINDIR\System32\bassmididrv\bassmididrvcfg.exe
  Reboot
${Endif}
${EndIf}
SectionEnd