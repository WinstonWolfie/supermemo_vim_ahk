; Q-dir
#If Vim.IsVimGroup() and WinActive("ahk_group VimQdir") and (Vim.State.Mode == "Vim_Normal")
; Enter insert mode to quickly locate the file/folder by using the first letter
/::Vim.State.SetMode("Insert")
; Enter insert mode at rename
~F2::Vim.State.SetMode("Insert")

#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal"))
i::
  if (Vim.State.g)
    Vim.Move.Move("g")
  Vim.State.SetMode("Insert")
Return

+i::
  Send, {Home}
  Vim.State.SetMode("Insert")
Return

a::
  if (! Vim.CheckChr("`n")) {
    Send, {Right}
  }
  Vim.State.SetMode("Insert")
Return

+a::
  Send, {End}
  Vim.State.SetMode("Insert")
Return

o::
  Send,{End}{Enter}
  Vim.State.SetMode("Insert")
Return

+o::
  Send, {Home}{Enter}{Left}
  Vim.State.SetMode("Insert")
Return

+s::
  send {end}+{home}{bs}
    Vim.State.SetMode("Insert")
Return

; Keys that need insert mode
~f2::
  sleep 50
  if A_CaretX
    Vim.State.SetMode("Insert")
Return

alt::  ; for access keys
  ; can't use KeyWait alt, any hotkeys that use modifier alt would trigger this script
  send {alt}  ; cannot use tilde, because you wouldn't want other keys like alt+d to go to insert
  Vim.State.SetMode("Insert")
return

~AppsKey::
  Vim.State.SetMode("Insert")
Return

#If
