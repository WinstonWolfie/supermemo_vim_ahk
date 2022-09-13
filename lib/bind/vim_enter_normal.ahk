#if Vim.IsVimGroup() || (Vim.State.Vim.Enabled && BackToNormal)
CapsLock::
Esc::
  Vim.State.HandleEsc()
  BackToNormal := 0
Return

#if Vim.IsVimGroup()
^[::Vim.State.HandleCtrlBracket()

#if Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Insert")) and (Vim.Conf["VimJJ"]["val"] == 1)
~j up::  ; jj: go to Normal mode.
  Input, jout, I T0.1 V L1, j
  if (ErrorLevel == "EndKey:J") {
    SendInput, {BackSpace 2}
    Vim.State.SetNormal()
  }
Return

#if (Vim.State.Vim.Enabled && BackToNormal)
~enter::
  if (BackToNormal == 1)
    Vim.State.SetMode("Vim_Normal")
  BackToNormal -= 1
Return