#If Vim.IsVimGroup()
Esc::Vim.State.HandleEsc()
^[::Vim.State.HandleCtrlBracket()

enter::
	; in Plan window pressing enter simply goes to the next field; no need to go back to normal
	if !WinActive("ahk_class TPlanDlg") && WinActive("ahk_class TElWind") { ; in element window pressing enter (learn) sets the mode normal
		ControlGetFocus, current_focus, ahk_class TElWind
		if !InStr(current_focus, "Internet Explorer_Server") && !InStr(current_focus, "TMemo") ; not editing text
			Vim.State.SetNormal()
	}
	send {enter}
Return

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