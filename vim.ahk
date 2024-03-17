#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Auto-execute section
#SingleInstance force
If (!A_IsAdmin) {
  Run *RunAs "%A_ScriptFullPath%"
  ExitApp
}
VimScriptPath := A_LineFile
Vim := new VimAhk()
SM := new SM()
Browser := new Browser()

#Include %A_LineFile%\..\lib\vim_ahk.ahk
