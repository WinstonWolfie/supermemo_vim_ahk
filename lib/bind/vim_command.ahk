#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
; `;::Vim.State.SetMode("Command") ;(;)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command"))
w::Vim.State.SetMode("Command_w")
q::Vim.State.SetMode("Command_q")
h::
  Send, {F1}
  Vim.State.SetMode("Vim_Normal")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_w"))
Return::
  Send, ^s
  Vim.State.SetMode("Vim_Normal")
Return

q::
  Send, ^s
  Send, !{F4}
  Vim.State.SetMode("Insert")
Return

Space::
  Send, !fa
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_q"))
Return::
  Send, !{F4}
  Vim.State.SetMode("Insert")
Return

; Commander, can be launched anywhere as long as vim_ahk is enabled
#If Vim.State.Vim.Enabled
^`;::
	Vim.State.SetMode("Vim_Normal")
	Gui, VimCommander:Add, Text,, &Command:
	list = Open SM Plan||Window spy
	Gui, VimCommander:Add, Combobox, vCommand gAutoComplete, %list%
	Gui, VimCommander:Add, Button, default, &Execute
	Gui, VimCommander:Show,, Vim Commander
Return

VimCommanderGuiEscape:
VimCommanderGuiClose:
	Gui, Destroy
return

VimCommanderButtonExecute:
	Gui, Submit
	Gui, Destroy
	StringLower, command, command
	command := RegExReplace(command, " \(.*") ; removing parentheses
	command := StrReplace(command, " ", "_")
	Gosub % command
Return

open_sm_plan:
	if WinExist("ahk_class TPlanDlg") {
		WinActivate
		Return
	}
	if WinExist("ahk_group SuperMemo") {
		WinActivate, ahk_class TElWind
		WinWaitActive, ahk_class TElWind,, 0
	} else {
		run C:\SuperMemo\sm18.exe
		WinWaitActive, ahk_class TElWind,, 5
		if ErrorLevel
			Return
	}
	send {alt}kp ; open Plan window
Return

window_spy:
	run C:\Program Files\AutoHotkey\WindowSpy.ahk
Return