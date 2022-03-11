#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind") && IsSMEditingHTML()
~^+i::Vim.State.SetMode("Vim_Normal") ; ignore

.:: ; selected text becomes [...]
	Clip("<span class=""Cloze"">[...]</span>", true)
	send ^+1
	Vim.State.SetMode("Vim_Normal")
return

f:: ; parse html (*f*ormat)
^+1::
	send ^+1
	Vim.State.SetMode("Vim_Normal")
return

m::  ; highlight: *m*ark
	send !{f12}rh
	Vim.State.SetMode("Vim_Normal")
return

#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
q:: ; extract (*q*uote)
	send !x
	Vim.State.SetMode("Vim_Normal")
return

+q:: ; extract with priority
	send !+x
	Vim.State.SetMode("Vim_Normal")
return

z::  ; clo*z*e
	send !z
	Vim.State.SetMode("Vim_Normal")
return

#If Vim.IsVimGroup() && WinActive("ahk_class TElWind")
*!+z::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
*!+z::
*+c:: ; cloze hinter
	ctrl_state := GetKeyState("Ctrl")
	InputBox, user_input, Cloze hinter, Please enter your cloze hint.`nIf you enter "hint1/hint2"`, your cloze will be [hint1/hint2]`nIf you enter "hint1/hint2/"`, your cloze will be [...](hint1/hint2),, 256, 196
	if ErrorLevel
		return
	send !z
	Vim.State.SetMode("Vim_Normal")
	if !user_input
		return
	WinWaitActive, ahk_class TMsgDialog,, 0
	if !ErrorLevel
		return
	VimToolTipFunc("Cloze hinting...", true)
	sleep 1700 ; tried several detection method here, like detecting when the focus control changes or when title changes
	send !{left} ; none of them seems to be stable enough
	sleep 300 ; so I had to resort to good old sleep
	send q
	sleep 100
	if InStr(user_input, "/") {
		cloze := RegExReplace(user_input, "/$") ; removing the last /
		if (cloze = user_input) ; no replacement
			cloze = %cloze%]
		else
			cloze = ...](%cloze%)
	} else
		cloze = ...](%user_input%)
	ControlGetFocus, current_focus, ahk_class TElWind
	if (current_focus = "TMemo2" || current_focus = "TMemo1") { ; editing plain text
		send ^a
		clip(StrReplace(clip(), "[...]", "["cloze))
	} else {
		/* old method: using supermemo's f3
		send {f3}
		WinWaitNotActive, ahk_class TELWind,, 0 ; double insurance to make sure the enter below does not trigger learn (which sometimes happens in slow computers)
		WinWaitActive, ahk_class TMyFindDlg,, 0
		SendInput {raw}[...]
		send {enter}
		WinWaitNotActive, ahk_class TMyFindDlg,, 0 ; faster than wait for element window to be active
		send ^{enter}
		WinWaitActive, ahk_class TCommanderDlg,, 0
		if ErrorLevel
			return
		send h{enter}q{left}{right} ; put the caret after the [ of [...]
		clip(cloze)
		SendInput {del 4} ; delete ...] ; somehow, here send wouldn't be working well in slow computers
		if WinExist("ahk_class TMyFindDlg") ; clears search box window
			WinClose
		*/
		; new method: directly replace the [...] in text
		send {esc}^+{f6}
		WinWaitActive, ahk_class Notepad,, 2
		if ErrorLevel
			return
		send ^a
		html := clip()
		send ^w
		WinWaitActive, ahk_class TELWind,, 0
		send q
		sleep 100
		Vim.Move.Move("+g")
		send {down}!\\
		WinWaitActive ahk_class TMsgDialog,, 0
		if !ErrorLevel
			send {enter}
		clip(StrReplace(html, "<SPAN class=cloze>[...]</SPAN>", "<SPAN class=cloze>[" . cloze . "</SPAN>"))
		send ^+{home}^+1
	}
	if (ctrl_state = 0) ; only goes back to topic if ctrl is up
		send !{right} ; add a ctrl to keep editing the clozed item
	else ; refresh if staying in the cloze item
		send !{home}!{left}
	ToolTip
return