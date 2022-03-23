#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && Vim.SM.IsEditingHTML()
~^+i::Vim.State.SetMode("Vim_Normal") ; ignore

.:: ; selected text becomes [...]
	Clip("<span class=""Cloze"">[...]</span>", true)
	send ^+1
	Vim.State.SetMode("Vim_Normal")
return

a:: ; p*a*rse html
^+1::
	send ^+1
	Vim.State.SetMode("Vim_Normal")
return

+a::
	Vim.State.SetMode("Vim_Normal")
	Gui, HTMLTag:Add, Text,, &HTML tag:
	list = H1||H2|H3|H4|H5|H6|B|I|U|STRONG|CODE|PRE|EM|cloze|clozed|extract
	Gui, HTMLTag:Add, Combobox, vTag gAutoComplete, %list%
	Gui, HTMLTag:Add, Button, default, &Add
	Gui, HTMLTag:Show,, Add HTML Tag
Return

HTMLTagGuiEscape:
HTMLTagGuiClose:
	Gui, Destroy
return

HTMLTagButtonAdd:
	Gui, Submit
	Gui, Destroy
	if (tag == "cloze" || tag == "extract" || tag == "clozed")
		clip("<SPAN class=" . tag . ">" . clip() . "</SPAN>", true)
	else
		clip("<" . tag . ">" . clip() . "</" . tag . ">", true)
	send ^+1
Return

m::  ; highlight: *m*ark
	send !{f12}rh
	Vim.State.SetMode("Vim_Normal")
return

q:: ; extract (*q*uote)
	send !x
	Vim.State.SetMode("Vim_Normal")
return

extract_stay:
#If Vim.IsVimGroup() and WinActive("ahk_class TElWind")
^!x::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
^q:: ; extract (*q*uote)
	caret_x := A_CaretX
	caret_y := A_CaretY
	send !x
	Vim.State.SetMode("Vim_Normal")
	Vim.SM.WaitProcessing(caret_x, caret_y)
	send !{left}
return

+q:: ; extract with priority
	send !+x
	Vim.State.SetMode("Vim_Normal")
return

z:: ; clo*z*e
	send !z
	Vim.State.SetMode("Vim_Normal")
return

cloze_stay:
#If Vim.IsVimGroup() and WinActive("ahk_class TElWind")
^!z::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
^z::
	caret_x := A_CaretX
	caret_y := A_CaretY
	send !z
	Vim.State.SetMode("Vim_Normal")
	WinWaitActive, ahk_class TMsgDialog,, 0 ; warning on trying to cloze on items
	if !ErrorLevel
		return
	Vim.SM.WaitProcessing(caret_x, caret_y)
	send !{left}
Return

~!t::
~!q::
	Vim.State.SetMode("Vim_Normal")
Return

cloze_hinter:
#If Vim.IsVimGroup() && WinActive("ahk_class TElWind")
^!+z::
!+z::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
^+z:: ; cloze hinter
+z:: ; cloze hinter
	if cloze_hinter_ctrl_state && (A_ThisLabel == "cloze_hinter") { ; from cloze hinter label and ctrl is down
		ctrl_state := 1
		cloze_hinter_ctrl_state := 0
	} else
		ctrl_state := GetKeyState("Ctrl")
	caret_x := A_CaretX
	caret_y := A_CaretY
	InputBox, user_input, Cloze Hinter, Please enter your cloze hint.`nIf you enter "hint1/hint2"`, your cloze will be [hint1/hint2]`nIf you enter "hint1/hint2/"`, your cloze will be [...](hint1/hint2),, 256, 196
	if ErrorLevel ; pressed esc
		return
	send !z
	Vim.State.SetMode("Vim_Normal")
	if !user_input ; entered nothing
		return
	WinWaitActive, ahk_class TMsgDialog,, 0 ; warning on trying to cloze on items
	if !ErrorLevel
		return
	Vim.ToolTipFunc("Cloze hinting...", true)
	sleep_calculation := A_TickCount
	Vim.SM.WaitProcessing(caret_x, caret_y)
	send !{left}
	sleep % A_TickCount - sleep_calculation
	loop {
		send {esc}q
		Vim.SM.WaitTextFocus()
		if !ErrorLevel
			Break
		if (A_Index > 50) ; over 5s
			Return
	}
	if InStr(user_input, "/") {
		cloze := RegExReplace(user_input, "/$") ; removing the last /
		if (cloze = user_input) ; no replacement
			cloze .= "]"
		else
			cloze = ...](%cloze%)
	} else
		cloze = ...](%user_input%)
	if Vim.SM.IsEditingPlainText() { ; editing plain text
		send ^a
		clip(StrReplace(clip(), "[...]", "[" . cloze))
	} else if Vim.SM.IsEditingHTML() {
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
		clip_bak := Clipboardall
		Clipboard =
		send !{f12}fc ; copy file path
		ClipWait 0.2
		sleep 20
		FileRead, html, %Clipboard%
		Vim.SM.MoveAboveRef(true)
		send !\\
		WinWaitNotActive, ahk_class TElWind,, 0
		if !ErrorLevel
			send {enter}
		clip(StrReplace(html, "<SPAN class=cloze>[...]</SPAN>", "<SPAN class=cloze>[" . cloze . "</SPAN>"),, true)
		send ^+{home}^+1
		Vim.SM.WaitHTMLSave()
		if ErrorLevel
			Return
		Clipboard := clip_bak
	}
	if !ctrl_state ; only goes back to topic if ctrl is up
		send !{right} ; add a ctrl to keep editing the clozed item
	else ; refresh if staying in the cloze item
		send !{home}!{left}
	Gosub RemoveToolTip
return