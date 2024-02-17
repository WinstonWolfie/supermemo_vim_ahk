#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
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
Return

+i::
  Send {Home}
  Vim.State.SetMode("Insert")
Return

a::
  if (Vim.IsNavigating()) {
    Send {tab}
  } else if (!Vim.CheckChr("`n")) {
    Send {Right}
  }
  Vim.State.SetMode("Insert")
Return

+a::
  Send {End}
  Vim.State.SetMode("Insert")
Return

o::
  if (Vim.SM.IsNavigatingPlan()) {
    Send {Down}{Ins}
  } else {
    Send {End}{Enter}
  }
  Vim.State.SetMode("Insert")
Return

+o::
  if (Vim.SM.IsNavigatingPlan()) {
    Send {Ins}
  } else {
    Send {Home}{Enter}{Left}
  }
  Vim.State.SetMode("Insert")
Return

; +s::  ; remapped in vim-sneak
;   Send {end}+{home}{BS}
;   Vim.State.SetMode("Insert")
; Return

; Keys that need insert mode
~f2::
  Sleep 70
  if (A_CaretX)
    Vim.State.SetMode("Insert")
Return

alt::  ; for access keys
  ; Can't use KeyWait Alt, any hotkeys that use modifier alt would trigger this script
  Send {alt}  ; cannot use tilde, because you wouldn't want other keys like alt+d to go to insert
  Vim.State.SetMode("Insert")
return

~RButton::  ; this button is evil and sacrilegious to the purity of Vim. Adding it anyway since someone might need it in the adjusting period
~AppsKey::Vim.State.SetMode("Insert")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class Notepad"))
~^h::
  if (ControlFocusWait("Windows.UI.Input.InputSite.WindowClass1", "A",,,, 500))  ; search window
    Vim.State.SetMode("Insert")
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TCommanderDlg"))
~Enter::
  WinWaitActive, ahk_class TInputDlg,, 0.3
  if (!ErrorLevel)
    Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1
return

#if
