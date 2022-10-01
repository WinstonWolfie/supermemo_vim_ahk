; Auto-execute section
#SingleInstance force
If (!A_IsAdmin)
  Run *RunAs "%A_ScriptFullPath%"
VimScriptPath := A_LineFile
Vim := new VimAhk()

#Include %A_LineFile%\..\lib\vim_ahk.ahk