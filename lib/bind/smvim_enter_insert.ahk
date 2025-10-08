﻿#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Keys that need insert mode
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_group SM"))
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

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_group SM") && !SM.IsEditingHTML())
~^+p::Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind"))
~^+y::  ; search YT
~^g::  ; element number
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1
return

~!n::  ; new topic
; Context menus
~!e::
~!l::
~!v::
~!w::Vim.State.SetMode("Insert")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.State.g)
!t::SM.AltT(), Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 2

#if (Vim.State.Vim.Enabled && (SM.IsBrowsing() || WinActive("ahk_class TRegistryForm")))
~!r::
  WinWaitActive, ahk_class TInputDlg,, 0
  if (!ErrorLevel)
    Vim.State.SetMode("Insert")
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))
!h::  ; change hours
  ControlFocus, TEdit1
  Vim.State.SetMode("Insert")
Return

~^t::  ; split
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1
return
