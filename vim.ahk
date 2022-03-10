; Auto-execute section
VimScriptPath := A_LineFile
Vim := new VimAhk()
Return

^!r::Reload

#Include %A_LineFile%\..\lib\vim_ahk.ahk
