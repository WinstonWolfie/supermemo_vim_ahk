; Keys that need insert mode
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_group SuperMemo"))
~!f10::
~+f10::
~!f12::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TPlanDlg"))
~Insert::
~NumpadIns::
~!m::  ; menu
#if (Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TRegistryForm")))
~!a::  ; new item and new registry entry
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind"))
~!n::  ; new topic
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TTaskManager"))
~!f1::  ; new task
  Vim.State.SetMode("Insert")
return

~^g::  ; element number
  Vim.State.SetMode("Insert")
  Vim.State.BackToNormal := 1
return

#if (Vim.State.Vim.Enabled && Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TRegistryForm")) && !Vim.SM.IsEditingText())
~!r::
  WinWaitActive, ahk_class TInputDlg,, 0
  if (!ErrorLevel)
    Vim.State.SetMode("Insert")
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))
!h::  ; change hours
  ControlFocus, TEdit1, A
  Vim.State.SetMode("Insert")
Return

~^t::  ; split
  Vim.State.SetMode("Insert")
  Vim.State.BackToNormal := 1
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_group SuperMemo"))
~RButton::  ; this button is evil and sacrilegious to the purity of Vim. Adding it anyway since someone might need it in the adjusting period
  Vim.State.SetMode("Insert")
Return