; Auto-execute section
VimScriptPath := A_LineFile
Vim := new VimAhk()
SetCapsLockState AlwaysOff

#Include %A_LineFile%\..\lib\vim_ahk.ahk