#If Vim.IsVimGroup() || (Vim.State.Vim.Enabled && back_to_normal)
Esc::
	Vim.State.HandleEsc()
	back_to_normal =
Return

#If Vim.IsVimGroup()
^[::Vim.State.HandleCtrlBracket()

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Insert")) and (Vim.Conf["VimJJ"]["val"] == 1)
~j up:: ; jj: go to Normal mode.
  Input, jout, I T0.1 V L1, j
  if(ErrorLevel == "EndKey:J"){
    SendInput, {BackSpace 2}
    Vim.State.SetNormal()
  }
Return

#If Vim.State.Vim.Enabled && back_to_normal
~enter::
	if (back_to_normal == 1)
		Vim.State.SetMode("Vim_Normal")
	back_to_normal -= 1
Return