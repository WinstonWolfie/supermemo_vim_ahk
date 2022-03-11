ClipboardGet_HTML( byref Data ) { ; https://www.autohotkey.com/boards/viewtopic.php?t=13063
 If CBID := DllCall( "RegisterClipboardFormat", Str,"HTML Format", UInt )
  If DllCall( "IsClipboardFormatAvailable", UInt,CBID ) <> 0
   If DllCall( "OpenClipboard", UInt,0 ) <> 0
    If hData := DllCall( "GetClipboardData", UInt,CBID, UInt )
       DataL := DllCall( "GlobalSize", UInt,hData, UInt )
     , pData := DllCall( "GlobalLock", UInt,hData, UInt )
     , Data := StrGet( pData, dataL, "UTF-8" )
     , DllCall( "GlobalUnlock", UInt,hData )
 DllCall( "CloseClipboard" )
Return dataL ? dataL : 0
}

SMMouseMoveTop(clicking="") {
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 10
		y_coord -= 21
		if clicking
			click, %x_coord% %y_coord%
		else
			MouseMove, %x_coord%, %y_coord%
		Return true
	}
}

SMMouseMoveMiddle(clicking="") {
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_up, y_up)
	FindClick(A_ScriptDir . "\lib\bind\util\down_arrow.png", "n", x_down, y_down)
	if x_up {
		CoordMode, Mouse, Screen
		x_coord := x_up - 10
		y_coord := (y_up + y_down) / 2
		if clicking
			click, %x_coord% %y_coord%
		else
			MouseMove, %x_coord%, %y_coord%
		Return true
	}
}

SMMouseMoveBottom(clicking="") {
	FindClick(A_ScriptDir . "\lib\bind\util\down_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 10
		y_coord += 21
		if clicking
			click, %x_coord% %y_coord%
		else
			MouseMove, %x_coord%, %y_coord%
		Return true
	}
}

ClickDPIAdjusted(coord_x="", coord_y="") {
	if coord_x && coord_y {
		coord_x := coord_x * A_ScreenDPI / 96
		coord_y := coord_y * A_ScreenDPI / 96
		click, %coord_x% %coord_y%
	}
}

VimToolTipFunc(text="", permanent="", period:=-2000) {
	CoordMode, ToolTip, Screen
	coord_x := A_ScreenWidth / 2
	coord_y := A_ScreenHeight / 3 * 2
	ToolTip, %text%, %coord_x%, %coord_y%
	if permanent
		SetTimer, RemoveToolTip, off
	else
		SetTimer, RemoveToolTip, %period%
}

RemoveToolTip:
	ToolTip
return

IsSMEditingHTML() {
	ControlGetFocus, current_focus, ahk_class TElWind
	return WinActive("ahk_class TElWind") && InStr(current_focus, "Internet Explorer_Server")
}

IsSMEditingPlainText() {
	ControlGetFocus, current_focus, ahk_class TElWind
	return WinActive("ahk_class TElWind") && InStr(current_focus, "TMemo")
}

IsSMEditingText() {
	ControlGetFocus, current_focus, ahk_class TElWind
	return WinActive("ahk_class TElWind") && (InStr(current_focus, "Internet Explorer_Server") || InStr(current_focus, "TMemo"))
}

IsSMGrading() {
	ControlGetFocus, current_focus, ahk_class TElWind
	; if focused on either 5 of the grading buttons or the cancel button
	return WinActive("ahk_class TElWind") && (current_focus = "TBitBtn4" || current_focus = "TBitBtn5" || current_focus = "TBitBtn6" || current_focus = "TBitBtn7" || current_focus = "TBitBtn8" || current_focus = "TBitBtn9")
}