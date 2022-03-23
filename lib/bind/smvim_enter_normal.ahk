#If Vim.IsVimGroup() && !WinActive("ahk_class TPlanDlg") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
; in Plan window pressing enter simply goes to the next field; no need to go back to normal
; in element window pressing enter to learn goes to normal
~enter::
#If Vim.IsVimGroup() && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
~space:: ; for Learn button
#If Vim.IsVimGroup() and WinActive("ahk_class TElWind") ; SuperMemo element window
~f4:: ; open tasklist
~!x:: ; extract
~!z:: ; cloze
~^+a:: ; web import
#If Vim.IsVimGroup() and WinActive("ahk_class TPlanDlg") ; SuperMemo Plan window
~^s:: ; save
~^+a:: ; archive current plan
	Vim.State.SetNormal()
return

#If Vim.IsVimGroup() and WinActive("ahk_class TElWind") && !Vim.State.StrIsInCurrentVimMode("Visual") ; SuperMemo element window
^l:: ; learn
	send {blind}{LCtrl up}{RCtrl up}
	Vim.SM.ExitText()
	send !ll
	Vim.State.SetNormal()
Return

#If Vim.IsVimGroup() and WinActive("ahk_class TElWind") ; SuperMemo element window
^p:: ; open Plan window
	send {blind}{LCtrl up}{RCtrl up}
	Vim.SM.ExitText()
	send !kp
	Vim.State.SetNormal()
Return