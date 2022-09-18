; Q-dir
#if Vim.IsVimGroup() and WinActive("ahk_group VimQdir") and (Vim.State.Mode == "Vim_Normal")
; Enter insert mode to quickly locate the file/folder by using the first letter
/::Vim.State.SetMode("Insert")
; Enter insert mode at rename
~F2::Vim.State.SetMode("Insert")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal"))
i::
  if (Vim.State.g)
    Vim.Move.Move("g")
  Vim.State.SetMode("Insert")
  if (Vim.SM.IsNavigatingPlan())
    send {f2}^a
Return

+i::
  send {Home}
  Vim.State.SetMode("Insert")
Return

a::
  if (Vim.SM.IsNavigatingPlan()) {
    send {tab}{f2}^a
  } else if (!Vim.CheckChr("`n")) {
    send {Right}
  }
  Vim.State.SetMode("Insert")
Return

+a::
  send {End}
  Vim.State.SetMode("Insert")
Return

o::
  send {End}{Enter}
  Vim.State.SetMode("Insert")
Return

+o::
  send {Home}{Enter}{Left}
  Vim.State.SetMode("Insert")
Return

+s::
  send {end}+{home}{bs}
    Vim.State.SetMode("Insert")
Return

; Keys that need insert mode
~f2::
  sleep 50
  if (A_CaretX)
    Vim.State.SetMode("Insert")
Return

alt::  ; for access keys
  ; Can't use KeyWait alt, any hotkeys that use modifier alt would trigger this script
  send {alt}  ; cannot use tilde, because you wouldn't want other keys like alt+d to go to insert
  Vim.State.SetMode("Insert")
return

~AppsKey::Vim.State.SetMode("Insert")

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual"))
~#a::Vim.State.SetMode("Insert")  ; text editor everywhere shortcut

#if