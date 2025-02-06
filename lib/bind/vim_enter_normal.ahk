#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() || (Vim.State.Vim.Enabled && Vim.State.BackToNormal))
CapsLock::
Esc::
  Vim.State.HandleEsc()
  if (Vim.State.BackToNormal == 1)
    Vim.State.SetMode("Vim_Normal")
  Vim.State.BackToNormal := 0
Return

#if (Vim.IsVimGroup())
^[::Vim.State.HandleCtrlBracket()

#if (Vim.IsVimGroup() && (Vim.State.StrIsInCurrentVimMode("Insert")) && (Vim.Conf["VimJJ"]["val"] == 1))
~j up::  ; jj: go to Normal mode.
  Input, jout, I T0.1 V L1, j
  if (ErrorLevel == "EndKey:J") {
    Send {BackSpace 2}
    Vim.State.SetNormal()
  }
Return

#if (Vim.State.Vim.Enabled && Vim.State.BackToNormal)
~Enter::
  if (Vim.State.BackToNormal == 1)
    Vim.State.SetMode("Vim_Normal")
  Vim.State.BackToNormal--
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert") && GetKeyState("j", "P"))
k::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert") && GetKeyState("k", "P"))
j::
  Send {BS}
  Vim.State.SetNormal()
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert"))
~j::VimLastJPressed := A_TickCount

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert") && (A_PriorKey = "j") && (A_TickCount - VimLastJPressed < 1000))
:*:jk::
  Vim.State.SetNormal()
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && GetKeyState("j", "P"))
k::
  Send +{Up}{Right}
  Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && GetKeyState("k", "P"))
j::
  Send +{Down}{Left}
  Vim.State.SetMode("Vim_Normal")
return
