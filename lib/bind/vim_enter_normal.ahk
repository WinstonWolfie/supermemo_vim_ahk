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
    send {BackSpace 2}
    Vim.State.SetNormal()
  }
Return

#if (Vim.State.Vim.Enabled && Vim.State.BackToNormal)
~enter::
  if (Vim.State.BackToNormal == 1) {
    if (WinActive("ahk_class TCommanderDlg")) {
      WinWaitActive, ahk_class TInputDlg,, 0.25
      if (!ErrorLevel)  ; commands like Compress images
        return
    }
    Vim.State.SetMode("Vim_Normal")
  }
  Vim.State.BackToNormal--
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert"))
~j::LastJPressed := A_TickCount

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert") && (A_PriorKey == "j") && (A_TickCount - LastJPressed < 1000))
:*:jk::
  Vim.State.SetNormal()
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && GetKeyState("j", "P"))
k::
  send +{up}{right}
  Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && GetKeyState("k", "P"))
j::
  send +{down}{left}
  Vim.State.SetMode("Vim_Normal")
return
