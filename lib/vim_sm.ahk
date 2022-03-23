class VimSM{
	__New(vim){
		this.Vim := vim
	}	

	MouseMoveTop(clicking=false) {
		if WinActive("ahk_class TElWind") {
			FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_coord, y_coord)
			if x_coord {
				CoordMode, Mouse, Screen
				x_coord -= 10
				y_coord -= 21
				if clicking
					click, %x_coord% %y_coord%
				else
					MouseMove, %x_coord%, %y_coord%, 1
				Return true
			}
		}
	}

	MouseMoveMiddle(clicking=false) {
		if WinActive("ahk_class TElWind") {
			FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_up, y_up)
			FindClick(A_ScriptDir . "\lib\bind\util\down_arrow.png", "n", x_down, y_down)
			if x_up {
				CoordMode, Mouse, Screen
				x_coord := x_up - 10
				y_coord := (y_up + y_down) / 2
				if clicking
					click, %x_coord% %y_coord%
				else
					MouseMove, %x_coord%, %y_coord%, 1
				Return true
			}
		}
	}

	MouseMoveBottom(clicking=false) {
		if WinActive("ahk_class TElWind") {
		FindClick(A_ScriptDir . "\lib\bind\util\down_arrow.png", "n", x_coord, y_coord)
			if x_coord {
				CoordMode, Mouse, Screen
				x_coord -= 10
				y_coord += 21
				if clicking
					click, %x_coord% %y_coord%
				else
					MouseMove, %x_coord%, %y_coord%, 1
				Return true
			}
		}
	}
	
	IsEditingHTML() {
		ControlGetFocus, current_focus, ahk_class TElWind
		return WinActive("ahk_class TElWind") && InStr(current_focus, "Internet Explorer_Server")
	}

	IsEditingPlainText() {
		ControlGetFocus, current_focus, ahk_class TElWind
		return WinActive("ahk_class TElWind") && InStr(current_focus, "TMemo")
	}

	IsEditingText() {
		ControlGetFocus, current_focus, ahk_class TElWind
		return WinActive("ahk_class TElWind") && (InStr(current_focus, "Internet Explorer_Server") || InStr(current_focus, "TMemo"))
	}

	IsGrading() {
		ControlGetFocus, current_focus, ahk_class TElWind
		; If SM is focusing on either 5 of the grading buttons or the cancel button
		return WinActive("ahk_class TElWind") && (current_focus == "TBitBtn4" || current_focus == "TBitBtn5" || current_focus == "TBitBtn6" || current_focus == "TBitBtn7" || current_focus == "TBitBtn8" || current_focus == "TBitBtn9")
	}
	
	IsPlanWindowEditingText() {
		ControlGetFocus, current_focus, ahk_class TPlanDlg
		Return WinActive("ahk_class TPlanDlg") && (current_focus == "TStringGrid1")
	}
	
	IsTasklistWindowEditingText() {
		ControlGetFocus, current_focus, ahk_class TTaskManager
		Return WinActive("ahk_class TTaskManager") && (current_focus == "TStringGrid1")
	}
	
	SetPriority(min, max) {
		send !p
		Random, OutputVar, %min%, %max%
		SendInput {raw}%OutputVar%
		send {enter}
		this.Vim.State.SetNormal()
	}

	SetTaskValue(min, max) {
		send !v
		Random, OutputVar, %min%, %max%
		SendInput {raw}%OutputVar%
		send {tab}
		this.Vim.State.SetNormal()
	}
	
	MoveAboveRef(NoRestore:=false) {
		Send, ^{End}^+{up} ; if there are references this would select (or deselect in visual mode) them all
		if InStr(clip("",, NoRestore), "#SuperMemo Reference:")
			send {up 2} ; go to start of last line
		else
			send ^{end}
	}
	
	WaitHTMLSave() {
		send {esc} ; try to save html
		loop {
			sleep 20
			if !this.IsEditingHTML() {
				Break
				ErrorLevel := 0
			}
			if (A_Index > 500) { ; takes over 10s to save the file
				this.Vim.ToolTipFunc("Timed out.")
				Break
				ErrorLevel := 1
			}
		}
	}
	
	WaitTextFocus() {
		loop {
			sleep 20
			if this.IsEditingText() {
				Break
				ErrorLevel := 0
			}
			if (A_Index > 250) { ; over 5s
				Break
				ErrorLevel := 1
			}
		}
	}
	
	; Wait until cloze/extract is finished
	WaitProcessing(caret_x, caret_y, timeout:=5000) {
		sleep_calculation := A_TickCount
		loop_timeout := timeout / 20
		loop {
			if (A_Index > loop_timeout) ; over 10s
				Break
			sleep 20
			if (A_CaretX != caret_x || A_CaretY != caret_y)
				Break
			this.Vim.Caret.SwitchToSameWindow() ; refresh caret
		}
		sleep % A_TickCount - sleep_calculation + 300
		loop {
			sleep 20
			selection_len := StrLen(clip())
			if (selection_len == 2 || selection_len == 1 || !selection_len) {
				Break
				ErrorLevel := 0
			}
			if (A_Index > 250) {
				Break
				ErrorLevel := 1
			}
		}
	}
}