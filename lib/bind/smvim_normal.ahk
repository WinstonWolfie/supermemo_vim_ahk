#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") and (Vim.State.g)
f:: ; gf: go to next component
	send ^t
	Vim.State.SetMode()
Return

+f:: ; gF: go to previous component
	send !{f12}fl
	Vim.State.SetMode()
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind")
+h:: ; move to top of screen
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 9
		y_coord -= 22
		click, %x_coord% %y_coord%
		send {left}{home}
	}
Return

+m:: ; move to middle of screen
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_up, y_up)
	FindClick(A_ScriptDir . "\lib\bind\util\down_arrow.png", "n", x_down, y_down)
	if x_up {
		CoordMode, Mouse, Screen
		x_coord := x_up - 9
		y_coord := (y_up + y_down) / 2
		Click, %x_coord% %y_coord%
		send {home}
	}
Return

+l:: ; move to bottom of screen
	FindClick(A_ScriptDir . "\lib\bind\util\down_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 9
		y_coord += 21
		click, %x_coord% %y_coord%
		send {home}
	}
Return

*/:: ; better search
	ctrl_state := GetKeyState("Ctrl") ; visual
	shift_state := GetKeyState("RShift") ; caret on the right
	alt_state := GetKeyState("RAlt") ; followed by a cloze
	if (ctrl_state = 1 && shift_state = 1 && alt_state = 1) || (ctrl_state = 1 && alt_state = 1) { ; more than 1 modifier keys
		MsgBox, Which one do you want??
		Return
	}
	if SMEditingPlainText() {
		MsgBox, Sorry, SuperMemo doesn't support f3 search on text components.
		Return
	}
	if !SMEditingHTML() { ; also not editing html; so no text component is focused
		send ^t{esc}q ; focus to question field if no field is focused
		sleep 100 ; make sure current_focus is updated
	}
	if SMEditingPlainText() { ; question field is plain text
		MsgBox, Sorry, SuperMemo doesn't support f3 search on text components.
		Return
	}
	if (ctrl_state = 1)
		InputBox, user_input, Search, Find text in current field. Enter nothing to repeat the last search (highlights will be automatically removed). Vim will go to visual mode after the search,, 256, 180
	else if (alt_state = 1)
		InputBox, user_input, Search, Find text in current field. Enter nothing to repeat the last search (highlights will be automatically removed). Your search result will be clozed,, 256, 180
	else
		InputBox, user_input, Search, Find text in current field. Enter nothing to repeat the last search (highlights will be automatically removed),, 256, 160
	if ErrorLevel
		Return
	if !user_input ; entered nothing
		user_input := last_search ; repeat last search
	else ; entered something
		last_search := user_input ; register user_input into last_search
	if !user_input ; still empty
		Return
	send {esc}{f3} ; esc to exit field, so it can return to the same field later
	WinWaitActive, ahk_class TMyFindDlg,, 0
	if ErrorLevel
		Return
	clip(user_input)
	send {enter}
	WinWaitNotActive, ahk_class TMyFindDlg,, 0 ; faster than wait for element window to be active
	if ErrorLevel
		Return
	if (shift_state = 1)
		send {right} ; put caret on right of searched text
	else if (ctrl_state = 1)
		Vim.State.SetMode("Vim_VisualChar")
	else if (alt_state = "U") ; all modifier keys are not pressed
		send {left} ; put caret on left of searched text
	send ^{enter} ; to open commander; convienently, if a "not found" window pops up, this would close it
	WinWaitActive, ahk_class TCommanderDlg,, 0
	if ErrorLevel {
		send {esc}
		MsgBox, Not found.
		Return
	}
	send h{enter}
	if (alt_state = 1)
		send !z ; cloze
	else if (ctrl_state = 0) ; alt is up and ctrl is up; shift can be up or down
		send {esc}^t ; to return to the same field
	else if (ctrl_state = 1) { ; sometimes SM doesn't focus to anything after the search
		WinWaitActive, ahk_class TElWind,, 0
		ControlGetFocus, current_focus_after, ahk_class TElWind
		if !current_focus_after
			ControlFocus, %current_focus%, ahk_class TElWind
	}
	if WinExist("ahk_class TMyFindDlg") ; clears search box window
		WinClose
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && SMEditingHTML()
n::  ; open hyperlink in current caret position (Open in *n*ew window)
	clipSave := Clipboardall
	Clipboard =
	send +{right}^c{left}
	ClipWait 1
	sleep 100
	If ClipboardGet_HTML( Data ){
		RegExMatch(data, "(<A((.|\r\n)*)href="")\K[^""]+", current_link)
		if !current_link
			VimToolTipFunc("No link found.")
		else if InStr(current_link, "SuperMemoElementNo=(") { ; goes to a supermemo element
			click, %A_CaretX% %A_CaretY%, right
			send n
		} else
			run % current_link
	}
	Clipboard := clipSave
return