#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Auto-execute section
#SingleInstance force
VimScriptPath := A_LineFile
Vim := new VimAhk()

#Include %A_LineFile%\..\lib\vim_ahk.ahk
