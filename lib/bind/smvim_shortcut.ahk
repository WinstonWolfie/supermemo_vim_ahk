#If Vim.IsVimGroup() && WinActive("ahk_class TElWind")
^!.:: ; find [...] and insert
	send ^t{esc}q{f3}
	WinWaitNotActive, ahk_class TELWind,, 0 ; double insurance to make sure the enter below does not trigger learn (which sometimes happens in slow computers)
	WinWaitActive, ahk_class TMyFindDlg,, 0
	SendInput {raw}[...]
	send {enter}
	WinWaitNotActive, ahk_class TMyFindDlg,, 0 ; faster than wait for element window to be active
	send {right}^{enter}
	WinWaitActive, ahk_class TCommanderDlg,, 0
	if ErrorLevel
		return
	send h{enter}q
	if WinExist("ahk_class TMyFindDlg") ; clears search box window
		WinClose
	Vim.State.SetMode("Insert")
return

^!c::FindClick(A_ScriptDir . "\lib\bind\util\concept_lightbulb.png") ; change default *c*oncept group

>!>+bs:: ; for laptop
>^>+bs:: ; for processing pending queue Advanced English 2018: delete element and keep learning
	send ^+{del}
	WinWaitActive, ahk_class TMsgDialog,, 0 ; wait for "Delete element?"
	send {enter}
	WinWaitActive, ahk_class TElWind,, 0 ; wait for element window to become focused again
	send {enter}
	Vim.State.SetNormal()
return

>!>+/:: ; for laptop
>^>+/:: ; done! and keep learning
	send ^+{enter}
	WinWaitActive, ahk_class TMsgDialog,, 0 ; "Do you want to remove all element contents from the collection?"
	send {enter}
	WinWaitActive, ahk_class TMsgDialog,, 0 ; wait for "Delete element?"
	send {enter}
	WinWaitActive, ahk_class TElWind,, 0 ; wait for element window to become focused again
	sleep 150
	ControlGetText, currentText, TBitBtn3
	if (currentText = "Learn")
		send {enter}
	Vim.State.SetNormal()
return

>!.:: ; for laptop
>!,:: ; play video in default system player / edit script component
send ^{t 2}{f9}
Vim.State.SetNormal()
return

; more intuitive inter-element linking, inspired by obsidian
; 1. go to the element you want to link to and press ctrl+alt+g
; 2. go to the element you want to have the hyperlink, select text and press ctrl+alt+k
^!g::
	send ^g
	WinWaitActive, ahk_class TInputDlg,, 0
	send ^c{esc}
	Vim.State.SetNormal()
return

#If Vim.IsVimGroup() && WinActive("ahk_class TElWind") and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual"))
\::send ^{f3}

#If Vim.IsVimGroup() && WinActive("ahk_class TElWind") && IsSMEditingHTML()
^!k::
	send ^k
	WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame,, 2 ; a bit more delay since everybody knows how slow IE can be
	clip("SuperMemoElementNo=(" . RegExReplace(Clipboard, "^#") . ")")
	send {enter}
	Vim.State.SetNormal()
return

#If Vim.IsVimGroup() and WinActive("ahk_class TPlanDlg") ; SuperMemo Plan window
!a:: ; insert the accident activity
	Vim.State.SetNormal()
	InputBox, user_input, Accident activity, Please enter the name of the activity. Add ! at the beginning if you don't want to split the current activity.,, 256, 164
	if ErrorLevel
		return
	replacement := RegExReplace(user_input, "^!") ; remove the "!"
	if (replacement != user_input) { ; you entered an "!"
		split = 0
		user_input := replacement
	} else
		split = 1
	if (user_input = "b") ; shortcuts
		user_input = Break
	else if (user_input = "g")
		user_input = Gaming
	else if (user_input = "c")
		user_input = Coding
	else if (user_input = "s")
		user_input = Sports
	else if (user_input = "o")
		user_input = Social
	else if (user_input = "w")
		user_input = Writing
	else if (user_input = "f")
		user_input = Family
	else if (user_input = "p")
		user_input = Passive
	else if (user_input = "m")
		user_input = Meal
	else if (user_input = "r")
		user_input = Rest
	else if (user_input = "h")
		user_input = School
	else if (user_input = "l")
		user_input = Planning
	if (split = 1) {
		send ^t ; split
		WinWaitActive, ahk_class TInputDlg,, 0
		send {enter}
		WinWaitActive, ahk_class TPlanDlg,, 0
	}
	send {down}{Insert} ; inserting one activity below the current selected activity and start editing
	SendInput {raw}%user_input% ; SendInput is faster than clip() here
	send !b ; begin
	sleep 400 ; wait for "Mark the slot with the drop to efficiency?"
	if WinActive("ahk_class TMsgDialog")
		send y
	WinWaitActive, ahk_class TPlanDlg,, 0
	send ^s{esc} ; save and exits
	WinWaitActive, ahk_class TElWind,, 0
	send ^{enter} ; commander
	WinWaitActive, ahk_class TCommanderDlg,, 0
	send {enter} ; cancel alarm
	WinWaitActive, ahk_class TElWind,, 0
	send ^p ; open plan again
return