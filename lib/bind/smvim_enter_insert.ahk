#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Keys that need insert mode
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_group SuperMemo"))
~!f10::
~+f10::
~!f12::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TPlanDlg"))
~Insert::
~NumpadIns::
~!m::  ; menu
#if (Vim.State.IsCurrentVimMode("Vim_Normal") && ((WinActive("ahk_class TElWind") && !Vim.State.g) || WinActive("ahk_class TRegistryForm")))
~!a::  ; new item and new registry entry
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TTaskManager"))
~!f1::  ; new task
~!a::  ; new task
  Vim.State.SetMode("Insert")
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind"))
!n::  ; new topic
  Vim.SM.AltN()
  Vim.State.SetMode("Insert")
return

~^g::  ; element number
  Vim.State.SetMode("Insert")
  Vim.State.BackToNormal := 1
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.State.g)
!t::
  Vim.SM.AltT()
  Vim.State.SetMode("Insert")
  Vim.State.BackToNormal := 2
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
