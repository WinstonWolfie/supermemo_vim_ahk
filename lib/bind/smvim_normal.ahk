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
q::Vim.State.SetMode("SMVim_Extract", 0, -1, 0)
z::Vim.State.SetMode("SMVim_Cloze", 0, -1, 0)
+z::
^+z::
	Vim.State.SetMode("SMVim_ClozeHinter", 0, -1, 0)
	cloze_hinter_ctrl_state := GetKeyState("Ctrl")
Return

m::
	send ^{f7} ; set read point
	VimToolTipFunc("Read point set")
Return

`::
	send !{f7} ; go to read point
	VimToolTipFunc("Go to read point")
Return

!m::
	send ^+{f7} ; clear read point
	VimToolTipFunc("Read point cleared")
Return

+h:: ; move to top of screen
	if SMMouseMoveTop(true)
		send {left}{home}
	else
		send ^{home}
Return

+m:: ; move to middle of screen
	SMMouseMoveMiddle(true)
	send {home}
Return

+l:: ; move to bottom of screen
	if !SMMouseMoveBottom(true)
		send ^{end}
	send {home}
Return

^/:: ; visual
?:: ; caret on the right
!/:: ; followed by a cloze
+!/:: ; followed by a cloze hinter
^+!/:: ; also cloze hinter but stays in clozed item
/:: ; better search
	ctrl_state := GetKeyState("Ctrl") ; visual
	shift_state := GetKeyState("Shift") ; caret on the right
	alt_state := GetKeyState("alt") ; followed by a cloze
	if !IsSMEditingText() {
		send ^t{esc}q ; focus to question field if no field is focused
		sleep 100 ; make sure current_focus is updated		
		if !IsSMEditingText() { ; still found no text
			MsgBox, Text not found.
			Return
		}
	}
	ControlGetFocus, current_focus, ahk_class TElWind
	if alt_state
		InputBox, user_input, Search, Find text in current field. Enter nothing to repeat the last search (highlights will be automatically removed). Your search result will be clozed,, 256, 180
	else if ctrl_state
		InputBox, user_input, Search, Find text in current field. Enter nothing to repeat the last search (highlights will be automatically removed). Vim will go to visual mode after the search,, 256, 180
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
	if InStr(current_focus, "TMemo") {
		send ^a
		pos := InStr(clip(), user_input)
		if pos {
			pos -= 1
			SendInput {left}{right %pos%}
			input_len := StrLen(user_input)
			if shift_state
				SendInput {right %input_len%}
			else if ctrl_state || alt_state {
				SendInput +{right %input_len%}
				if ctrl_state
					Vim.State.SetMode("Vim_VisualChar")
				else if alt_state
					send !z
			}
		} else {
			MsgBox, Not found.
			Return
		}
	} else {
		send {esc}{f3} ; esc to exit field, so it can return to the same field later
		WinWaitActive, ahk_class TMyFindDlg,, 0
		if ErrorLevel
			Return
		clip(user_input)
		send {enter}
		WinWaitNotActive, ahk_class TMyFindDlg,, 0 ; faster than wait for element window to be active
		if ErrorLevel
			Return
		if !alt_state {
			if shift_state
				send {right} ; put caret on right of searched text
			else if ctrl_state
				Vim.State.SetMode("Vim_VisualChar")
			else ; all modifier keys are not pressed
				send {left} ; put caret on left of searched text
		}
		send ^{enter} ; to open commander; convienently, if a "not found" window pops up, this would close it
		WinWaitActive, ahk_class TCommanderDlg,, 0
		if ErrorLevel {
			send {esc}
			MsgBox, Not found.
			Return
		}
		send h{enter}
		if WinExist("ahk_class TMyFindDlg") ; clears search box window
			WinClose
		if alt_state {
			if !ctrl_state && !shift_state
				send !z
			else if shift_state {
				if ctrl_state
					cloze_hinter_ctrl_state := 1
				WinWaitActive, ahk_class TElWind
				gosub cloze_hinter
			}
		} else if !ctrl_state ; alt is up and ctrl is up; shift can be up or down
			send {esc}^t ; to return to the same field
		else if ctrl_state { ; sometimes SM doesn't focus to anything after the search
			WinWaitActive, ahk_class TElWind,, 0
			ControlGetFocus, current_focus_after, ahk_class TElWind
			if !current_focus_after
				ControlFocus, %current_focus%, ahk_class TElWind
		}
	}
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && IsSMEditingHTML()
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