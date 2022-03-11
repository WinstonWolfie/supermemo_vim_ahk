#If Vim.IsVimGroup()
Esc::Vim.State.HandleEsc()
^[::Vim.State.HandleCtrlBracket()

enter::
	; in Plan window pressing enter simply goes to the next field; no need to go back to normal
	if !WinActive("ahk_class TPlanDlg") && WinActive("ahk_class TElWind") && !IsSMEditingText() ; in element window pressing enter to learn goes to normal
		Vim.State.SetNormal()
	send {enter}
Return

space:: ; space: for Learn button
if WinActive("ahk_class TElWind") && !IsSMEditingText()
	Vim.State.SetNormal()
send {space}
return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Insert")) and (Vim.Conf["VimJJ"]["val"] == 1)
~j up:: ; jj: go to Normal mode.
  Input, jout, I T0.1 V L1, j
  if(ErrorLevel == "EndKey:J"){
    SendInput, {BackSpace 2}
    Vim.State.SetNormal()
  }
Return

#If Vim.IsVimGroup() and WinActive("ahk_class TElWind") ; SuperMemo element window
~^p:: ; open Plan window
~f4:: ; open tasklist
	Vim.State.SetNormal()
return

#If Vim.IsVimGroup() and WinActive("ahk_class TPlanDlg") ; SuperMemo Plan window
~^s:: ; save
~^+a:: ; archive current plan
	Vim.State.SetNormal()
return