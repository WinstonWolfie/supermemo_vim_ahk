; Accessible Info Viewer by jethrow
; https://autohotkey.com/board/topic/77888-accessible-info-viewer-alpha-release-2012-09-20/
; Modified by tmplinshi - https://gist.github.com/tmplinshi/0fcb8655c1402a3662ac048d0d974915/

#NoEnv
#SingleInstance, force
SetBatchLines, -1

{
	WM_ACTIVATE := 0x06
	WM_KILLFOCUS := 0x08
	WM_LBUTTONDOWN := 0x201
	WM_LBUTTONUP := 0x202
	global Border := new Outline, Stored:={}, Acc, ChildId, TVobj, Win:={}
	global g_isWindowDpiAware
	global g_lastPos := {x:"", y:""}
	global g_lastPath, g_skipTvEvent
}
{
	DetectHiddenWindows, On
	OnExit, OnExitCleanup
	OnMessage(0x200,"WM_MOUSEMOVE")
	ComObjError(false)
	Hotkey, ~LButton Up, Off
}
{
	Gui Main: New, HWNDhwnd LabelGui AlwaysOnTop, Accessible Info Viewer
	Gui Main: Default
	Win.Main := hwnd
	; Gui, Color, White
	Gui, Add, Checkbox, x70 y8 h20 gHotTracker_OnCheck vHotTrackerEnabled Checked0, HotTracking
	Gui, Add, Text, x+0 hp 0x201 Disabled, (F1)
	Gui, Add, Button, x+70 ggotoParentAcc vBtnParent, Parent
	Gui, Add, Button, x+10 ggotoRootAcc vBtnRoot, Root
	Gui, Add, Button, x+10 vShowStructure gShowStructure, Show Acc Structure
	{
		Gui, Add, Text, x10 y3 w25 h26 Border gCrossHair ReadOnly Border 0x6 ; SS_WHITERECT=0x6
		Gui, Add, Text, x10 y3 w25 h4 Border HWNDh9 +0x4E
		CreatePixel(h9, 0x0046D5)

		Gui, Add, Text, x13 y17 w19 h1 Border vHBar
		Gui, Add, Text, x22 y8 w1 h19 Border vVBar
	}
	{
		Gui, Font, bold
		Gui, Add, GroupBox, x2 y32 w465 h130 vWinCtrl, Window/Control Info
		Gui, Font
		Gui, Add, Text, x7 y49 h20, % "WinTitle:"
		Gui, Add, Edit, ReadOnly x+0 y47 w401 h20 vWinTitle ,
		Gui, Add, Text, x7 y71 h20, % "    Text:"
		Gui, Add, Edit, ReadOnly x+0 y69 w401 h20 vText ,
		Gui, Add, Text, x7 y93 h20, % "    Hwnd:"
		Gui, Add, Edit, ReadOnly x+0 y91 w112 h20 vHwnd,
		Gui, Add, Text, x+30 y93 h20 vClassText, % "Class(NN):"
		Gui, Add, Edit, ReadOnly x+0 y91 w198 h20 vClass,
		Gui, Add, Text, x7 y115 h20, % "Position:"
		Gui, Add, Edit, ReadOnly x+0 y113 w112 h20 vPosition,
		Gui, Add, Text, x+30 y115 h20, % "  Process:"
		Gui, Add, Edit, ReadOnly x+0 y113 w198 h20 vProcess,
		Gui, Add, Text, x7 y137 h20, % "    Size:"
		Gui, Add, Edit, ReadOnly x+0 y135 w112 h20 vSize,
		Gui, Add, Text, x+30 y137 h20, % "  Proc ID:"
		Gui, Add, Edit, ReadOnly x+0 y135 w198 h20 vProcID,
	}
	{
		Gui, Font, bold
		Gui, Add, GroupBox, x2 y165 w465 h290 vAcc, Accessible Info
		Gui, Font
		Gui, Add, Text, x7 y182 w42 h20 Right, Name:
		Gui, Add, Edit, ReadOnly x51 y180 w411 h20 vAccName ,
		Gui, Add, Text, x7 y204 w42 h20 Right, Value:
		Gui, Add, Edit, ReadOnly x51 y202 w225 h20 vAccValue ,
		Gui, Add, Button, x+0 hp gModifyAccValue vModifyAccValue Default Disabled, Modify
		Gui, Add, Text, x+20 y204 h20, % "ChildCount:"
		Gui, Add, Edit, ReadOnly x+0 y202 w55 h20 vAccChildCount,
		Gui, Add, Text, x7 y226 w42 h20 Right, Role:
		Gui, Add, Edit, ReadOnly x51 y224 w411 h20 vAccRole,
		Gui, Add, Text, x7 y248 w42 h20 Right, State:
		Gui, Add, Edit, ReadOnly x51 y246 w411 h50 -Wrap vAccState,
		Gui, Add, Button, xp y+0 h22 w100 vStateSelect gSelectAcc Disabled, Select
		Gui, Add, Text, x7 y320 w42 h20 Right, Action:
		Gui, Add, Edit, ReadOnly x51 y318 w142 h20 vAccAction,
		Gui, Add, Button, x+0 gDoDefaultAction hp vExecute Disabled, Execute
		Gui, Add, Text, x+30 y320 h20, % "     Focus:"
		Gui, Add, Edit, ReadOnly x+0 y318 w120 h20 vAccFocus,
		{
			Gui, Add, Text, x7 y342 w75 h20 Right vAccLocationText, Location:
			Gui, Add, Edit, ReadOnly x+0 y340 w380 h20 vAccLocation ,
			Gui, Add, Text, x7 y364 w75 h20 Right, Description:
			Gui, Add, Edit, ReadOnly x+0 y362 w380 h20 vAccDescription ,
			Gui, Add, Text, x7 y386 w75 h20 Right, Keyboard:
			Gui, Add, Edit, ReadOnly x+0 y384 w380 h20 vAccKeyboard ,
			Gui, Add, Text, x7 y408 w75 h20 Right, Help:
			Gui, Add, Edit, ReadOnly x+0 y406 w380 h20 vAccHelp ,
			Gui, Add, Text, x7 y430 w75 h20 Right, HelpTopic:
			Gui, Add, Edit, ReadOnly x+0 y428 w380 h20 vAccHelpTopic ,
			Gui, Add, Text, x7 y+8 w75 Right, Selection:
			Gui, Add, Edit, ReadOnly x+0 yp-3 w380 h20 vAccSelection,
		}
	}
	{
		Gui, Add, StatusBar, gShowMainGui
		SB_SetParts(110, 180, 100)
		; SB_SetText("get full path", 3)
		SB_SetText("`tshow more", 4)
	}
	{
		Gui Acc: New, ToolWindow Resize LabelAcc HWNDhwnd, Acc Structure
		Gui, Margin, 0, 0
		Gui, Font,, Microsoft YaHei
		Gui, Add, TreeView, w300 h357 vTView gTreeView R17 AltSubmit HWNDhTV 0x200 ;BackgroundF0F0F0
		Gui, Show, Hide
		Win.Acc := hwnd
		DllCall("UxTheme.dll\SetWindowTheme", "ptr", hTV, "str", "Explorer", "ptr", 0)
	}
	GoSub, ShowMainGui
	WinSet, Redraw, , % "ahk_id" Win.Main
	return
}

TempMenu_CopyCode:
TempMenu_CopyCodeSingle:
TempMenu_CopyCodeParameters:
	defaultGui := A_DefaultGui
	Gui, % Win.Main ":Default"

	SB_SetText("", 2)
	SB_SetText("Searching..", 3)

	codeType := (A_ThisLabel = "TempMenu_CopyCodeSingle")     ? "single"
	          : (A_ThisLabel = "TempMenu_CopyCodeParameters") ? "parameters"
	          : "full"
	fullPath := GetAccFullPath(outCode, codeType)
	g_lastPath := fullpath
	Clipboard := outCode

	SB_SetText("Path: " fullPath, 2)
	SB_SetText("get full path", 3)
	
	Gui, % defaultGui ":Default"

	ToolTip("Copied",,,, 2000)
Return

; ToolTip("Test",,,, 3000)
ToolTip(Text := "", X := "", Y := "", WhichToolTip := 1, Timeout := "") {
	ToolTip, % Text, X, Y, WhichToolTip

	If (Timeout) {
		RemoveToolTip := Func("ToolTip").Bind(,,, WhichToolTip)
		SetTimer, % RemoveToolTip, % -Timeout
	}
}

ShowMainGui:
{
	if (A_GuiEvent = "RightClick" && A_EventInfo = 3) {
		preTDpi := DllCall("SetThreadDpiAwarenessContext", "int", -4)
		Menu, TempMenu, Add, Copy Code, TempMenu_CopyCode
		Menu, TempMenu, Add, Copy Code (Single line), TempMenu_CopyCodeSingle
		Menu, TempMenu, Add, Copy Code (Parameters), TempMenu_CopyCodeParameters
		Menu, TempMenu, Show
		Menu, TempMenu, DeleteAll
		DllCall("SetThreadDpiAwarenessContext", "int", preTDpi)
		return
	}

	if A_EventInfo in 1,2
	{
		WM_MOUSEMOVE()
		StatusBarGetText, SB_Text, %A_EventInfo%, % "ahk_id" Win.Main
		if SB_Text
			if (A_EventInfo=2 and SB_Text:=SubStr(SB_Text,7))
			or if RegExMatch(SB_Text, "Id: \K\d+", SB_Text) {
				SB_Text := StrReplace(SB_Text, ",", ".")
				if (A_EventInfo = 2 && childId)
					Clipboard := """" SB_Text """, " childId
				else
					Clipboard := SB_Text

				preTDpi := DllCall("SetThreadDpiAwarenessContext", "int", -4)
				ToolTip % "clipboard = " clipboard
				DllCall("SetThreadDpiAwarenessContext", "int", preTDpi)

				SetTimer, RemoveToolTip, -2000
			}
	}
	else if (A_EventInfo = 3)
	{
		SB_SetText("", 2)
		SB_SetText("Searching..", 3)
		fullPath := GetAccFullPath()
		g_lastPath := fullPath
		SB_SetText("Path: " fullPath, 2)
		SB_SetText("get full path", 3)
	}
	else {
		preTDpi := DllCall("SetThreadDpiAwarenessContext", "int", -4)

		Gui Main: Default
		if ShowingLess {
			SB_SetText("`tshow less", 4)
			GuiControl, Move, Acc, x2 y165 w465 h315
			GuiControl, Show, AccDescription
			GuiControl, Show, AccLocation
			GuiControl, Show, AccLocationText
			{
				height := 369
				while height<503 {
					height += 10
					Gui, Show, w470 h%height%
					Sleep, 20
				}
			}
			Gui, Show, w470 h503
			ShowingLess := false
		}
		else {
			if (ShowingLess != "") {
				height := 503
				while height>369 {
					height -= 10
					Gui, Show, w470 h%height%
					Sleep, 20
				}
			}
			Gui, Show, w470 h369
			GuiControl, Hide, AccDescription
			GuiControl, Hide, AccLocation
			GuiControl, Hide, AccLocationText
			GuiControl, Move, Acc, x2 y165 w465 h180
			SB_SetText("`tshow more", 4)
			ShowingLess := true
		}
		WinSet, Redraw, , % "ahk_id" Win.Main
		DllCall("SetThreadDpiAwarenessContext", "int", preTDpi)
	}
return
}

HotTracker_OnCheck:
	GuiControlGet, HotTrackerEnabled
	if HotTrackerEnabled
		SetTimer, Enable_HotTracker, -1
	else
		SetTimer, Disable_HotTracker, -1
return

#if Not Lbutton_Pressed
Enable_HotTracker:
f1::
{
	Lbutton_Pressed := true
	GuiControl, Main:, HotTrackerEnabled, 1
	Stored.Chwnd := ""
	SB_SetText("", 3)
	Gui Acc: Default
	GuiControl, Disable, TView
	while, Lbutton_Pressed
	{
		GetAccInfo()
		Sleep, 30 ;5
	}
	DllCall("SetThreadDpiAwarenessContext", "int", -4)
	SB_SetText("get full path", 3)
	RestoreCursors()
	ToolTip
	g_lastPos := ""
	return
}

#if Lbutton_Pressed
Disable_HotTracker:
f1::
{
	Lbutton_Pressed := false
	GuiControl, Main:, HotTrackerEnabled, 0
	Gui Main: Default
	Sleep, -1
	GuiControl, , WinCtrl, % (DllCall("GetParent", "ptr",Acc_WindowFromObject(Acc))? "Control":"Window") " Info"
	if Not DllCall("IsWindowVisible", "Ptr",Win.Acc) {
		Border.Hide()
		SB_SetText("Path: " GetAccPath(Acc).path, 2)
		SB_SetText("get full path", 3)
	}
	else {
		Gui Acc: Default
		BuildTreeView()
		GuiControl, Enable, TView
		; WinActivate, % "ahk_id" Win.Acc
		PostMessage, %WM_LBUTTONDOWN%, , , SysTreeView321, % "ahk_id" Win.Acc
	}
	return
}

#if
~Lbutton Up::
{
	Hotkey, ~LButton Up, Off
	Lbutton_Pressed := False
	Gui Main: Default
	if Not CH {
		GuiControl, Show, HBar
		GuiControl, Show, VBar
		CrossHair(CH:=true)
	}
	Sleep, -1
	GuiControl, , WinCtrl, % (DllCall("GetParent", "ptr",Acc_WindowFromObject(Acc))? "Control":"Window") " Info"
	if Not DllCall("IsWindowVisible", "Ptr",Win.Acc) {
		Border.Hide()
		SB_SetText("Path: " (g_lastPath:=GetAccPath(Acc).path), 2)
		SB_SetText("get full path", 3)
	}
	else {
		Gui Acc: Default
		BuildTreeView()
		GuiControl, Enable, TView
		WinActivate, % "ahk_id" Win.Acc
		PostMessage, %WM_LBUTTONDOWN%, , , SysTreeView321, % "ahk_id" Win.Acc
	}
	return
}
CrossHair:
{
	if (A_GuiEvent = "Normal") {
		Hotkey, ~LButton Up, On
		{
			GuiControl, Hide, HBar
			GuiControl, Hide, VBar
			CrossHair(CH:=false)
		}
		Lbutton_Pressed := True
		Stored.Chwnd := ""
		SB_SetText("", 3)
		Gui Acc: Default
		GuiControl, Disable, TView
		while, Lbutton_Pressed
		{
			GetAccInfo()
			Sleep, 30 ;5
		}
		DllCall("SetThreadDpiAwarenessContext", "int", -4)
		RestoreCursors()
		SB_SetText("get full path", 3)
		ToolTip
		g_lastPos := ""
	}
	return
}
OnExitCleanup:
{
	; CrossHair(true) ;???
	RestoreCursors()
	GuiClose:
	ExitApp
}
ShowStructure:
{
	ControlFocus, Static1, % "ahk_id" Win.Main
	if DllCall("IsWindowVisible", "Ptr",Win.Acc) {
		PostMessage, %WM_LBUTTONDOWN%, , , SysTreeView321, % "ahk_id" Win.Acc
		return
	}
	WinGetPos, x, y, w, , % "ahk_id" Win.Main
	WinGetPos, , , AccW, AccH, % "ahk_id" Win.Acc
	WinMove, % "ahk_id" Win.Acc,
		, (x+w+AccW > A_ScreenWidth? x-AccW-10:x+w+10)
		, % y+5, %AccW%, %AccH%
	WinShow, % "ahk_id" Win.Acc
	if ComObjType(Acc, "Name") = "IAccessible"
		BuildTreeView()
	if Lbutton_Pressed
		GuiControl, Disable, TView
	else
		GuiControl, Enable, TView
	PostMessage, %WM_LBUTTONDOWN%, , , SysTreeView321, % "ahk_id" Win.Acc

	TV_Modify(TV_GetSelection(), "VisFirst")
	return
}
BuildTreeView()
{
	r := GetAccPath(Acc)
	AccObj:=r.AccObj, Child_Path:=r.Path, r:=""
	Gui Acc: Default
	TV_Delete()
	GuiControl, -Redraw, TView
	; parent := TV_Add(Acc_Role(AccObj), "", "Bold Expand")
	parent := TV_Add(Acc_Role(AccObj), "", "Expand")
	TVobj := {(parent): {is_obj:true, obj:AccObj, need_children:false, childid:0, Children:[]}}
	Loop Parse, Child_Path, .
	{
		if A_LoopField is not Digit
			TVobj[parent].Obj_Path := Trim(TVobj[parent].Obj_Path "," A_LoopField, ",")
		else {
			StoreParent := parent
			parent := TV_BuildAccChildren(AccObj, parent, "", A_LoopField)
			TVobj[parent].need_children := false
			TV_Expanded(StoreParent)
			TV_Modify(parent,"Expand")
			AccObj := TVobj[parent].obj
		}
	}
	if Not ChildId {
		TV_BuildAccChildren(AccObj, parent)
		TV_Modify(parent, "Select")
	}
	else
		TV_BuildAccChildren(AccObj, parent, ChildId)
	TV_Expanded(parent)
	GuiControl, +Redraw, TView
}
AccClose:
{
	Border.Hide()
	Gui Acc: Hide
	TV_Delete()
	Gui Main: Default
	GuiControl, Enable, ShowStructure
	return
}
AccSize:
{
	if (A_EventInfo != 1)
		GuiControl, Move, TView, w%A_GuiWidth% h%A_GuiHeight%
	return
}
TreeView:
{
	if g_skipTvEvent
		return

	Gui, Submit, NoHide
	if (A_GuiEvent = "S") {
		ToggleThreadDpiAwareness( AccWindowFromObject(TVobj[A_EventInfo].obj) )
		UpdateAccInfo(TVobj[A_EventInfo].obj, TVobj[A_EventInfo].childid, TVobj[A_EventInfo].obj_path)

		acc := TVobj[A_EventInfo].obj
		childid := TVobj[A_EventInfo].childid
		EnableButtons()
		SB_SetText("get full path", 3)
	}
	if (A_GuiEvent = "+") {
		GuiControl, -Redraw, TView
		TV_Expanded(A_EventInfo)
		GuiControl, +Redraw, TView
	}
	return
}
RemoveToolTip:
{
	ToolTip
	return
}

GetClassName(hwnd) {
	static init, className
	if !init {
		init := true
		VarSetCapacity(className, 256, 0)
	}
	DllCall("GetClassName", "ptr", hwnd, "str", className, "int", 256)
	return className
}

GetAccInfo(oInput := "") {
	global Whwnd
	static ShowButtonEnabled

	if oInput
		Whwnd := oInput.hwnd
	else
	{
		MouseGetPos, x, y, Whwnd, Chwnd, 2
		if (x = g_lastPos.x && y = g_lastPos.y) {
			; _log("///////////return")
			return
		}

		g_lastPos := {x: x, y: y}
	}

	if (Whwnd = Win.Main || Whwnd = Win.Acc)
		return

	GuiControlGet, SectionLabel, , WinCtrl
	if (SectionLabel != "Window/Control Info")
		GuiControl, , WinCtrl, Window/Control Info

	if oInput
		Acc := oInput.Acc, ChildId := 0
	else
		Acc := __Acc_ObjectFromPoint(ChildId), switchToVisibleParent()


	static lastAcc, lastChildId
	if Border.isVisible && isSameAcc(Acc, ChildId, lastAcc, lastChildId) {
		return
	}
	lastAcc := Acc, lastChildId := ChildId


	; enable acc in chrome
	static WM_GETOBJECT := 0x003D
	if (GetClassName(whwnd) = "Chrome_WidgetWin_1") {
		SendMessage, WM_GETOBJECT, 0, 1, , % "ahk_id" (Chwnd ? Chwnd : Whwnd)
	}
		

	;ToolTip, % SubStr(acc.accName(ChildId), 1, 100) . (StrLen(acc.accName(ChildId))>100 ? " ..." : "")
	Location := GetAccLocation(Acc, ChildId)
	; if Stored.Location != Location {
	; if 1 {
		Hwnd := Acc_WindowFromObject(Acc)
		if Stored.Hwnd != Hwnd {
			if DllCall("GetParent", ptr,hwnd) {
				WinGetTitle, title, ahk_id %parent%
				ControlGetText, text, , ahk_id %Hwnd%
				class := GetClassNN(Hwnd,Whwnd)
				ControlGetPos, posX, posY, posW, posH, , ahk_id %Hwnd%
				WinGet, proc, ProcessName, ahk_id %parent%
				WinGet, procid, PID, ahk_id %parent%
			}
			else {
				WinGetTitle, title, ahk_id %Hwnd%
				WinGetText, text, ahk_id %Hwnd%
				WinGetClass, class, ahk_id %Hwnd%
				WinGetPos, posX, posY, posW, posH, ahk_id %Hwnd%
				WinGet, proc, ProcessName, ahk_id %Hwnd%
				WinGet, procid, PID, ahk_id %Hwnd%
			}
			{
				GuiControl, , WinTitle, %title%
				GuiControl, , Text, %text%
				SetFormat, IntegerFast, H
				GuiControl, , Hwnd, % Hwnd+0
				SetFormat, IntegerFast, D
				GuiControl, , Class, %class%
				GuiControl, , Position, x%posX%  y%posY%
				GuiControl, , Size, w%posW%  h%posH%
				GuiControl, , Process, %proc%
				GuiControl, , ProcId, %procid%
			}
			Stored.Hwnd := Hwnd
		}
		UpdateAccInfo(Acc, ChildId)
	; }
}

isSameAcc(acc1, chidId1, acc2, childId2) {
	if (chidId1 = childId2)
	&& (acc1.accRole(chidId1)             = acc2.accRole(childId2))
	&& (acc1.accName(chidId1)             = acc2.accName(childId2))
	&& (acc1.accState(chidId1)            = acc2.accState(childId2))
	&& (acc1.accValue(chidId1)            = acc2.accValue(childId2))
	&& (acc1.accChildCount                = acc2.accChildCount)
	&& (acc1.accDefaultAction(chidId1)    = acc2.accDefaultAction(childId2))
	&& (acc1.accDescription(chidId1)      = acc2.accDescription(childId2))
	&& (acc1.accHelp(chidId1)             = acc2.accHelp(childId2))
	&& (acc1.accKeyboardShortcut(chidId1) = acc2.accKeyboardShortcut(childId2))
	&& (Acc_LocationStr(acc1)             = Acc_LocationStr(acc2))
		return true
}

isAccInvisible() {
	static STATE_SYSTEM_INVISIBLE := 0x8000
	return acc.accState(childId) & STATE_SYSTEM_INVISIBLE
}

switchToVisibleParent() {
	while isAccInvisible()
		acc := Acc_Parent(acc)
}

DoDefaultAction() {
	acc.accDoDefaultAction(ChildId)
	GuiControl,, AccAction, % Acc.accDefaultAction(ChildId)
	GuiControl,, AccState,  % Acc_GetStateTextEx2(Acc.accState(ChildId))
}

ModifyAccValue() {
	GuiControlGet, AccValue
	Acc.accValue(ChildId) := AccValue
	GuiControl, +cRed +Redraw, AccValue
}

EnableModifyAccValue() {
	b := (Acc.accRole(ChildId) = 42) ;ROLE_SYSTEM_TEXT
	GuiControl, % (b ? "-" : "+" ) . "ReadOnly", AccValue
	GuiControl, % "Enable" b, ModifyAccValue
	GuiControl, +cDefault, AccValue
}

EnableButtons() {
	EnableModifyAccValue()
	EnableBtnSelect()
	GuiControl, % "Enable" (Acc.accDefaultAction(ChildId) != ""), Execute
}

UpdateAccInfo(Acc, ChildId, Obj_Path="") {
	global Whwnd
	Gui Main: Default
	Location := GetAccLocation(Acc, ChildId, x, y, w, h)
	{
		GuiControl,, AccName,        % Acc.accName(ChildId)
		GuiControl,, AccValue,       % Acc.accValue(ChildId)
		GuiControl,, AccRole,        % Acc_GetRoleInfo(Acc, ChildId)
		GuiControl,, AccState,       % Acc_GetStateTextEx2(Acc.accState(ChildId))
		GuiControl,, AccAction,      % Acc.accDefaultAction(ChildId)
		GuiControl,, AccChildCount,  % ChildId ? "N/A" : Acc.accChildCount
		GuiControl,, AccSelection,   % ChildId ? "N/A" : Acc.accSelection
		GuiControl,, AccFocus,       % ChildId ? "N/A" : Acc.accFocus
		GuiControl,, AccLocation,    % Location
		GuiControl,, AccDescription, % Acc.accDescription(ChildId)
		GuiControl,, AccKeyboard,    % Acc.accKeyboardShortCut(ChildId)
		Guicontrol,, AccHelp,        % Acc.accHelp(ChildId)
		GuiControl,, AccHelpTopic,   % Acc.accHelpTopic(ChildId)
		SB_SetText(ChildId? "Child Id: " ChildId:"Object")
		SB_SetText(DllCall("IsWindowVisible", "Ptr",Win.Acc)? "Path: " Obj_Path:"", 2)
		g_lastPath := Obj_Path

		EnableButtons()
	}

	; Border.Transparent(true)
	Border.show(x, y, x+w, y+h)
	Border.setabove(Whwnd)
	; Border.Transparent(false)

	Stored.Location := Location
}
GetClassNN(Chwnd, Whwnd) {
	global _GetClassNN := {}
	_GetClassNN.Hwnd := Chwnd
	Detect := A_DetectHiddenWindows
	WinGetClass, Class, ahk_id %Chwnd%
	_GetClassNN.Class := Class
	DetectHiddenWindows, On
	EnumAddress := RegisterCallback("GetClassNN_EnumChildProc")
	DllCall("EnumChildWindows", "uint",Whwnd, "uint",EnumAddress)
	DetectHiddenWindows, %Detect%
	return, _GetClassNN.ClassNN, _GetClassNN:=""
}
GetClassNN_EnumChildProc(hwnd, lparam) {
	static Occurrence
	global _GetClassNN
	WinGetClass, Class, ahk_id %hwnd%
	if _GetClassNN.Class == Class
		Occurrence++
	if Not _GetClassNN.Hwnd == hwnd
		return true
	else {
		_GetClassNN.ClassNN := _GetClassNN.Class Occurrence
		Occurrence := 0
		return false
	}
}
TV_Expanded(TVid) {
	For Each, TV_Child_ID in TVobj[TVid].Children
		if TVobj[TV_Child_ID].need_children
			TV_BuildAccChildren(TVobj[TV_Child_ID].obj, TV_Child_ID)
}
TV_BuildAccChildren(AccObj, Parent, Selected_Child="", Flag="") {
	TVobj[Parent].need_children := false
	Parent_Obj_Path := Trim(TVobj[Parent].Obj_Path, ",")
	for wach, child in Acc_Children(AccObj) {
		if Not IsObject(child) {
			added := TV_Add("[" A_Index "] " Acc_GetRoleText(AccObj.accRole(child)) " " AccObj.accName(child), Parent)
			TVobj[added] := {is_obj:false, obj:Acc, childid:child, Obj_Path:Parent_Obj_Path}
			if (child = Selected_Child)
				TV_Modify(added, "Select")
		}
		else {
			; added := TV_Add("[" A_Index "] " Acc_Role(child) " " child.accName(0), Parent, "bold")
			added := TV_Add("[" A_Index "] " Acc_Role(child) " " child.accName(0), Parent, "")
			TVobj[added] := {is_obj:true, need_children:true, obj:child, childid:0, Children:[], Obj_Path:Trim(Parent_Obj_Path "," A_Index, ",")}
		}
		TVobj[Parent].Children.Insert(added)
		if (A_Index = Flag)
			Flagged_Child := added
	}
	return Flagged_Child
}
GetAccPath(Acc, byref hwnd="") {
	hwnd := Acc_WindowFromObject(Acc)
	WinObj := Acc_ObjectFromWindow(hwnd)
	WinObjPos := Acc_Location(WinObj).pos
	while Acc_WindowFromObject(Parent:=Acc_Parent(Acc)) = hwnd {
		t2 := GetEnumIndex(Acc) "." t2
		if Acc_Location(Parent).pos = WinObjPos
			return {AccObj:Parent, Path:SubStr(t2,1,-1)}
		Acc := Parent
	}
	while Acc_WindowFromObject(Parent:=Acc_Parent(WinObj)) = hwnd
		t1.="P.", WinObj:=Parent
	return {AccObj:Acc, Path:t1 SubStr(t2,1,-1)}
}
GetEnumIndex(Acc, ChildId=0) {
	if Not ChildId {
		ChildPos := Acc_Location(Acc).pos
		For Each, child in Acc_Children(Acc_Parent(Acc))
			if IsObject(child) and Acc_Location(child).pos=ChildPos
				return A_Index
	} 
	else {
		ChildPos := Acc_Location(Acc,ChildId).pos
		For Each, child in Acc_Children(Acc)
			if Not IsObject(child) and Acc_Location(Acc,child).pos=ChildPos
				return A_Index
	}
}
GetAccLocation(AccObj, Child=0, byref x="", byref y="", byref w="", byref h="") {
	AccObj.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), Child)
	return "x" (x:=NumGet(x,0,"int")) "  "
	.	"y" (y:=NumGet(y,0,"int")) "  "
	.	"w" (w:=NumGet(w,0,"int")) "  "
	.	"h" (h:=NumGet(h,0,"int"))
}
WM_MOUSEMOVE() {
	static hCurs := new Cursor(32649)
	MouseGetPos,,,,ctrl
	if (ctrl = "msctls_statusbar321")
		DllCall("SetCursor","ptr",hCurs.ptr)
}
class Cursor {
	__New(id) {
		this.ptr := DllCall("LoadCursor", "ptr", 0, "Int", id, "ptr")
	}
	__delete() {
		DllCall("DestroyCursor", "ptr", this.ptr)
	}
}
class Outline {
	__New(color="red") {
		static WS_EX_TRANSPARENT := 0x20, WS_EX_LAYERED := 0x00080000

		preDefaultGui := A_DefaultGui

		this.hwnds := {}
		Loop, 4 {
			Gui, New, -Caption +ToolWindow HWNDhwnd -DPIScale +E%WS_EX_TRANSPARENT% +E%WS_EX_LAYERED%
			Gui, Color, %color%
			this[A_Index] := hwnd
			DllCall("SetLayeredWindowAttributes", "ptr", hwnd, uint, 0, "uchar", 255, "int", 2)
		}
		this.isVisible := false
		this.color := color
		this.top := this[1]
		this.right := this[2]
		this.bottom := this[3]
		this.left := this[4]
		Gui, %preDefaultGui%: Default
	}

	MoveTogether(arrHwnd, arrPos) {
		hDWP := DllCall("BeginDeferWindowPos", "int", arrHwnd.Length(), "ptr")
		for i, v in arrPos {
			DllCall("DeferWindowPos", "ptr", hDWP, "ptr", arrHwnd[i], "ptr", 0
				, "int", v[1], "int", v[2], "int", v[3], "int", v[4]
				, "uint", 0x54) ; SWP_SHOWWINDOW|SWP_NOACTIVATE|SWP_NOZORDER
		}
		DllCall("EndDeferWindowPos", "ptr", hDWP)
	}
	Show(x1, y1, x2, y2) {
		b := g_isWindowDpiAware ? Round(2*(A_ScreenDPI/96)) : 2

		arrHwnd := [this.1, this.2, this.3, this.4]
		arrPos  := [ [x1-b, y1-b, x2-x1+b*2, b]
		           , [x2,   y1,   b,         y2-y1]
		           , [x1-b, y2,   x2-x1+b*2, b]
		           , [x1-b, y1,   b,         y2-y1] ]
		this.MoveTogether(arrHwnd, arrPos)

		; this.GuiShow("top",    x1-b, y1-b, x2-x1+b*2, b)
		; this.GuiShow("right",  x2,   y1,   b,         y2-y1)
		; this.GuiShow("bottom", x1-b, y2,   x2-x1+b*2, b)
		; this.GuiShow("left",   x1-b, y1,   b,         y2-y1)

		this.isVisible := true
	}
	GuiShow(name, x, y, w, h) {
		Gui, % this[name] ":Show", % "NA x" x " y" y " w" w " h" h
	}
	Hide() {
		Loop, 4
			Gui, % this[A_Index] ": Hide"
		this.isVisible := false
	}
	SetAbove(hwnd) {
		ABOVE := DllCall("GetWindow", "ptr", hwnd, "uint", 3, "ptr")
		Loop, 4
			DllCall(	"SetWindowPos", "ptr", this[A_Index], "ptr", ABOVE
					,	"int", 0, "int", 0, "int", 0, "int", 0
					,	"uint", 0x1|0x2|0x10	)
	}
	Transparent(param) {
		Loop, 4
			WinSet, Transparent, % param=1? 0:255, % "ahk_id" this[A_Index]
		this.isVisible := !param
	}
	Color(color) {
		Gui, +HWNDdefault
		Loop, 4
			Gui, % this[A_Index] ": Color" , %color%
		this.color := color
		Gui, %default%: Default
	}
	Destroy() {
		Loop, 4
			Gui, % this[A_Index] ": Destroy"
	}
}
CreatePixel(hwnd, Color) {
	VarSetCapacity(BMBITS, 4, 0), Numput(Color, &BMBITS, 0, "UInt")
	hBM := DllCall("CreateBitmap", "Int", 1, "Int", 1, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")
	hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "Ptr")
	DllCall("SetBitmapBits", "Ptr", hBM, "UInt", 3, "Ptr", &BMBITS)
	DllCall("SendMessage", "Ptr", hwnd, "UInt", 0x172, "Ptr", 0, "Ptr", hBM)
}
CrossHair(OnOff=1) {
	static AndMask, XorMask, $, h_cursor, IDC_CROSS := 32515
	,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13
	, b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13
	, h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13
	if (OnOff = "Init" or OnOff = "I" or $ = "") {
		$ := "h"
		, VarSetCapacity( h_cursor,4444, 1 )
		, VarSetCapacity( AndMask, 32*4, 0xFF )
		, VarSetCapacity( XorMask, 32*4, 0 )
		, system_cursors := "32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650"
		StringSplit c, system_cursors, `,
		Loop, %c0%
			h_cursor   := DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
			, h%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
			, b%A_Index% := DllCall("LoadCursor", "Uint", "", "Int", IDC_CROSS, "Uint")
	}
	$ := (OnOff = 0 || OnOff = "Off" || $ = "h" && (OnOff < 0 || OnOff = "Toggle" || OnOff = "T")) ? "b" : "h"
	Loop, %c0%
		h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
		, DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
}

ToggleThreadDpiAwareness(hwnd) {
	if !g_isWindowDpiAware := _isWindowDpiAware(hwnd)
		val := -1
	else if (g_isWindowDpiAware=2 && WinGetClass(hwnd)="#32768")
	|| (g_isWindowDpiAware=1 && A_PtrSize=8 && WinGetClass(hwnd)="#32768")
		val := -1, g_isWindowDpiAware := 0, getCursorAgain := true
	else
		val := -4

	if (A_OSVersion >= "10.0.14393")
		DllCall("SetThreadDpiAwarenessContext", "int", val)

	return getCursorAgain
}

WinGetClass(hwnd) {
	WinGetClass, class, ahk_id %hwnd%
	return class
}

{ ; Acc Library
	__Acc_AutoInit() {
		static	_ := DllCall("LoadLibrary", "Str", "oleacc.dll", "Ptr")
	}
	Acc_ObjectFromEvent(ByRef _idChild_, hWnd, idObject, idChild) {
		If DllCall("oleacc\AccessibleObjectFromEvent", "Ptr", hWnd, "UInt", idObject, "UInt", idChild, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
			Return ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
	}
	__Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "") {
		if (x = "" || y = "") {
			DllCall("GetPhysicalCursorPos", "Int64P", pt)
			hwnd :=  DllCall("WindowFromPoint", "int64", pt)
			if ToggleThreadDpiAwareness(hwnd)
				DllCall("GetPhysicalCursorPos", "Int64P", pt)
		} else {
			pt := x & 0xFFFFFFFF | y << 32
		}
		If DllCall("oleacc\AccessibleObjectFromPoint", "Int64", pt, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
			Return ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
	}
	Acc_ObjectFromWindow(hWnd, idObject = 0) {
		If DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF
			, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81
			,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
			Return ComObjEnwrap(9,pacc,1)
	}
	Acc_WindowFromObject(pacc) {
		If DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0
			Return hWnd
	}
	Acc_GetRoleText(nRole) {
		nSize := DllCall("oleacc\GetRoleText", "Uint", nRole, "Ptr", 0, "Uint", 0)
		VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
		DllCall("oleacc\GetRoleText", "Uint", nRole, "str", sRole, "Uint", nSize+1)
		Return sRole
	}
	Acc_GetStateText(nState) {
		nSize := DllCall("oleacc\GetStateText", "Uint", nState, "Ptr", 0, "Uint", 0)
		VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
		DllCall("oleacc\GetStateText", "Uint", nState, "str", sState, "Uint", nSize+1)
		Return sState
	}
	Acc_Role(Acc, ChildId=0) {
		try return ComObjType(Acc,"Name")="IAccessible"?Acc_GetRoleText(Acc.accRole(ChildId)):"invalid object"
	}
	Acc_State(Acc, ChildId=0) {
		try return ComObjType(Acc,"Name")="IAccessible"?Acc_GetStateText(Acc.accState(ChildId)):"invalid object"
	}
	Acc_Children(Acc) { ; from https://github.com/serzh82saratov/AhkSpy
		if ComObjType(Acc, "Name") != "IAccessible"
			return
		else
		{
			cChildren := Acc.accChildCount, Children := [] 
			if DllCall("oleacc\AccessibleChildren"
			, "Ptr", ComObjValue(Acc)
			, "Int", 0, "Int", cChildren
			, "Ptr", VarSetCapacity(varChildren, cChildren * (8 + 2 * A_PtrSize), 0) * 0 + &varChildren
			, "Int*", cChildren) = 0 
			{
				Loop %cChildren%
					i := (A_Index - 1) * (A_PtrSize * 2 + 8) + 8
					, child := NumGet(varChildren, i)
					, Children.Insert(NumGet(varChildren, i - 8) = 9 ? Acc_Query(child) : child)
					, NumGet(varChildren, i - 8) = 9 ? ObjRelease(child) : ""
				return Children.MaxIndex() ? Children : ""
			}
		}
	}
	Acc_Location(Acc, ChildId=0) {
		try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
		catch
			return
		return {x:NumGet(x,0,"int"), y:NumGet(y,0,"int"), w:NumGet(w,0,"int"), h:NumGet(h,0,"int")
		,	pos:"x" NumGet(x,0,"int")" y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")}
	}
	Acc_Parent(Acc) {
		try parent := Acc.accParent
		return parent ? Acc_Query(parent) : ""
	}
	Acc_Child(Acc, ChildId=0) {
		try child := Acc.accChild(ChildId)
		return child ? Acc_Query(child) : ""
	}
	Acc_Query(Acc) {
		try return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
	}

	; https://docs.microsoft.com/zh-cn/windows/desktop/WinAuto/object-state-constants
	Acc_GetStateTextEx(nState) {
		static states := [ 0x0,0x1,0x10,0x100,0x10000,0x100000,0x1000000,0x2,0x20,0x200,0x2000
		                 , 0x20000,0x200000,0x2000000,0x20000000,0x4,0x40,0x400,0x4000,0x40000
		                 , 0x400000,0x40000000,0x8,0x80,0x800,0x8000,0x80000,0x800000 ]
		for i, n in states
		{
			if (nState & n)
				out .= Acc_GetStateText(n) ","
		}
		return RTrim(out, ",")
	}

	Acc_GetStateTextEx2(nState) {
		static oState := { ANIMATED:0x4000, BUSY:0x800, CHECKED:0x10, COLLAPSED:0x400, DEFAULT:0x100, EXPANDED:0x200, EXTSELECTABLE:0x2000000
			             , FOCUSABLE:0x100000, FOCUSED:0x4, HASPOPUP:0x40000000, HOTTRACKED:0x80, INVISIBLE:0x8000, OFFSCREEN:0x10000, LINKED:0x400000
			             , MARQUEED:0x2000, MIXED:0x20, MOVEABLE:0x40000, MULTISELECTABLE:0x1000000, NORMAL:0x0, PRESSED:0x8, PROTECTED:0x20000000
			             , READONLY:0x40, SELECTABLE:0x200000, SELECTED:0x2, SELFVOICING:0x80000, SIZEABLE:0x20000, TRAVERSED:0x800000, UNAVAILABLE:0x1 }
		for k, v in oState
		{
			if (nState & v) {
				v_hex := Format("{:#x}", v)
				out .= Acc_GetStateText(v) " (STATE_SYSTEM_" k " := " v_hex ")`n"
			}
		}
		return RTrim(out, "`n")
	}

	Acc_GetRoleConstName(nRole) {
		static arr := [ "TITLEBAR","MENUBAR","SCROLLBAR","GRIP","SOUND","CURSOR","CARET","ALERT","WINDOW","CLIENT","MENUPOPUP","MENUITEM","TOOLTIP"
		              , "APPLICATION","DOCUMENT","PANE","CHART","DIALOG","BORDER","GROUPING","SEPARATOR","TOOLBAR","STATUSBAR","TABLE","COLUMNHEADER","ROWHEADER"
		              , "COLUMN","ROW","CELL","LINK","HELPBALLOON","CHARACTER","LIST","LISTITEM","OUTLINE","OUTLINEITEM","PAGETAB","PROPERTYPAGE","INDICATOR"
		              , "GRAPHIC","STATICTEXT","TEXT","PUSHBUTTON","CHECKBUTTON","RADIOBUTTON","COMBOBOX","DROPLIST","PROGRESSBAR","DIAL","HOTKEYFIELD","SLIDER"
		              , "SPINBUTTON","DIAGRAM","ANIMATION","EQUATION","BUTTONDROPDOWN","BUTTONMENU","BUTTONDROPDOWNGRID","WHITESPACE"
		              , "PAGETABLIST","CLOCK","SPLITBUTTON","IPADDRESS","OUTLINEBUTTON" ]
		return (s := arr[nRole]) ? "ROLE_SYSTEM_" s : ""
	}

	Acc_GetRoleInfo(Acc, ChildId) {
		nRole := Acc.accRole(ChildId)
		return Acc_GetRoleText(nRole) " (" Acc_GetRoleConstName(nRole) " := " nRole ")"
	}
}

_isWindowDpiAware(hwnd) {
	static last := {}

	if (hwnd = last.hwnd)
		return last.val

	DllCall("GetWindowThreadProcessId", "ptr", hwnd, "int*", pid)
	if (pid = last.pid)
		return last.val, last.hwnd := hwnd

	return val := GetProcessDpiAwareness(pid)
	     , last := {pid: pid, hwnd: hwnd, val: val}
}

GetProcessDpiAwareness(pid) {
	static h := DllCall("LoadLibrary", "str", "Shcore.dll", "ptr")
	static GetProcessDpiAwareness := DllCall("GetProcAddress", "ptr", h, "astr", "GetProcessDpiAwareness", "ptr")
	if hProcess := DllCall("OpenProcess", "uint", 0x0400, "int", false, "uint", pid, "ptr")
	{
		DllCall(GetProcessDpiAwareness, "ptr", hProcess, "int*", PROCESS_DPI_AWARENESS)
		DllCall("CloseHandle", "ptr", hProcess)
		return PROCESS_DPI_AWARENESS
	}
}

SelectAcc() {
	; https://docs.microsoft.com/en-us/windows/win32/winauto/selflag
	; SELFLAG_TAKESELECTION = 0x2
	Acc.accSelect(0x2, ChildId)
	GuiControl, Disable, % A_GuiControl
	GuiControl,, AccState, % Acc_GetStateTextEx2(Acc.accState(ChildId))
}

EnableBtnSelect() {
	static STATE_SYSTEM_SELECTABLE := 0x200000
	static STATE_SYSTEM_SELECTED := 0x2
	b :=  (Acc.accState(ChildId) & STATE_SYSTEM_SELECTABLE)
	  && !(Acc.accState(ChildId) & STATE_SYSTEM_SELECTED)

	static last := 0
	if (b != last) {
		GuiControl, % "Enable" b, StateSelect
		last := b
	}
}

RestoreCursors() {
	static SPI_SETCURSORS := 0x57
	DllCall("SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0)
}


; ====================================================================
#If WinActive("ahk_id " Win.Acc) || WinActive("ahk_id " Win.Main)
	^g::gotoPath()
; 	^BackSpace::gotoParentAcc()
; 	^Home::gotoRootAcc()
#If

_InputBox(Title:="", oParam := "")
{
	preTDPI := DllCall("SetThreadDpiAwarenessContext", "int", -4)

	Gui, % Win.Main ":+OwnDialogs -AlwaysOnTop"

	InputBox, v, %Title%,,,, % oParam.Height,,,,, % oParam.Default
	CancelPressed := ErrorLevel

	Gui, % Win.Main ":+AlwaysOnTop"

	DllCall("SetThreadDpiAwarenessContext", "int", preTDPI)
	return CancelPressed ? "" : v
}

_error(title, text) {
	preTDPI := DllCall("SetThreadDpiAwarenessContext", "int", -4)
	Gui, % Win.Main ":+OwnDialogs -AlwaysOnTop"
	MsgBox, 48, %title%, %text%
	Gui, % Win.Main ":+AlwaysOnTop"
	DllCall("SetThreadDpiAwarenessContext", "int", preTDPI)
}

gotoPath() {
	if !inputPath := _InputBox( "Go to path", {height:110, default:g_lastPath} )
		Return

	inputPath := StrReplace(inputPath, ",", ".")
	inputPath := Trim(inputPath, ".")
	if !(inputPath ~= "^\d+(\.\d+)*$")
		return _error("Go to path", "path invalid")

	parentElement := GetRootAcc(acc)
	try {
		Loop, Parse, inputPath, .
		{
			parentElement := AccChildren(parentElement)[A_LoopField]
			if !parentElement.accRole(0)
				return
		}
		Acc := parentElement, childId := 0
		UpdateAccInfo(Acc, childId)
		BuildTreeView()
	}
}

gotoParentAcc() {
	if !isRootAcc(Acc)
		__updateAcc( Acc_Parent(Acc) )
}

gotoRootAcc() {
	__updateAcc( GetRootAcc(Acc) )
}

__updateAcc(newAcc, childId := 0) {
	if !AccChildren(newAcc)
		return

	acc := newAcc
	ToggleThreadDpiAwareness( AccWindowFromObject(acc) )
	GetAccInfo( {hwnd: Acc_WindowFromObject(acc), acc:acc} )
	; UpdateAccInfo(Acc, childId)
	; SB_SetText("Path: " (g_lastPath:=GetAccPath(Acc).path), 2)
	g_skipTvEvent := true
	BuildTreeView()
	g_skipTvEvent := false
}

; isRootAcc(acc) {
; 	static GA_ROOT := 2
; 	hWnd     := Acc_WindowFromObject(acc)
; 	hWndRoot := DllCall("GetAncestor", "ptr", hwnd, "uint", GA_ROOT, "ptr")
; 	return (hWnd = hWndRoot)
; }

isRootAcc(acc) {
	static DesktopHwnd := DllCall("GetDesktopWindow", "ptr")
	try {
		return (Acc_WindowFromObject(Acc_Parent(acc)) = DesktopHwnd)
	}
}

GetRootAcc(acc) {
	static GA_ROOT := 2
	hwnd := Acc_WindowFromObject(acc)
	hRoot := DllCall("GetAncestor", "ptr", hwnd, "uint", GA_ROOT, "ptr")
	return AccObjectFromWindow(hRoot)
}

GetAccFullPath2(ByRef outCode := "", codeType := "full") {
	params := { Value: acc.AccValue(childId)
	          , Name:  acc.AccName(childId)
	          , Role:  acc.accRole(childId)
	          , State: acc.accState(childId)
	          , ChildCount: acc.accChildCount
	          , hWnd: AccWindowFromObject(Acc) }
	if SearchElement(accRoot:=GetRootAcc(acc), params, childId, inOutPath, inOutRole)
	{
		if IsByRef(outCode)
			createSearchCode(outCode, codeType, accRoot, params, childId, inOutPath, inOutRole)
		return inOutPath
	}
}

GetAccPath_Full(Acc) {
	static DesktopHwnd := DllCall("GetDesktopWindow", "ptr")

	while idx := GetEnumIndex2(Acc) {
		ParentAcc := Acc_Parent(Acc)
		if !(hwnd := Acc_WindowFromObject(ParentAcc)) || (hwnd = DesktopHwnd)
			break

		path := idx "." path
		role .= Acc.accRole(0) "."
		Acc := ParentAcc
	}
	return {AccObj:Acc, Path: RTrim(path, ".")}
}

GetAccFullPath(ByRef outCode := "", codeType := "full") {
	local path, role

	static DesktopHwnd := DllCall("GetDesktopWindow", "ptr")
	rootHwnd := DllCall("GetAncestor", "ptr", Acc_WindowFromObject(Acc), "uint", GA_ROOT:=2, "ptr")

	thisAcc := Acc

	while idx := GetEnumIndex2(thisAcc) {
		parentAcc := Acc_Parent(thisAcc)
		if !(hwnd := Acc_WindowFromObject(parentAcc)) || (hwnd = DesktopHwnd)
			break

		path := idx "." path
		role .= thisAcc.accRole(0) "."
		thisAcc := parentAcc
	}
	path := Trim(path, ".")

	if (Acc_WindowFromObject(thisAcc) != rootHwnd) {
		return GetAccFullPath2(outCode, codeType)
	}

	if IsByRef(outCode) {
		Sort, role, U D.
		role := Trim(role, ".")

		params := { Name: Acc.AccName(childId), Role: Acc.accRole(childId) }

		createSearchCode(outCode, codeType, thisAcc, params, childId, path, role)
	}
	return path
}

GetEnumIndex2(Acc) {
	For Each, child in Acc_Children(p:=Acc_Parent(Acc))
	{ 
		if IsObject(child)
		&& (child.accRole(0) = Acc.accRole(0))
		&& (child.accName(0) = Acc.accName(0))
		&& (child.accState(0) = Acc.accState(0))
		&& (child.accValue(0) = Acc.accValue(0))
		&& (child.accChildCount = Acc.accChildCount)

		&& (Acc_LocationStr(child) = Acc_LocationStr(Acc))
		&& (child.accDefaultAction(0) = Acc.accDefaultAction(0))
		&& (child.accDescription(0) = Acc.accDescription(0))
		&& (child.accHelp(0) = Acc.accHelp(0))
		&& (child.accKeyboardShortcut(0) = Acc.accKeyboardShortcut(0))
			return A_Index
	}
}

Acc_LocationStr(Acc, ChildId=0) {
	Static x := 0, y := 0, w := 0, h := 0
	try Acc.accLocation(ComObj(0x4003,&x), ComObj(0x4003,&y), ComObj(0x4003,&w), ComObj(0x4003,&h), ChildId)
	return "x" NumGet(x, 0, "int") " y" NumGet(y, 0, "int") " w" NumGet(w, 0, "int") " h" NumGet(h, 0, "int")
}

; teadrinker
SearchElement(parentElement, params, childId:=0, ByRef inOutPath:="", ByRef inOutRole:="", _allowRole:="")
{
	if inOutPath {
		_accBackup := parentElement
		Loop, Parse, inOutPath, `,., %A_Space%%A_Tab%
			parentElement := AccChildren(parentElement)[A_LoopField]
	}

	found := true
	for k, v in params {
		try {
			switch k {
				case "ChildCount": (parentElement.accChildCount != v  && found := false)
				case "State": (!(parentElement.accState(childId) & v) && found := false)
				case "hWnd": (AccWindowFromObject(parentElement) != v && found := false)
				default:      (parentElement["acc" . k](childId) != v && found := false)
			}
		}
		catch
			found := false
	} until !found
	if found
		Return parentElement

	if _accBackup {
		parentElement := _accBackup
	}
	if inOutRole {
		_allowRole := {}
		Loop, Parse, inOutRole, `,., %A_Space%%A_Tab%
			_allowRole[A_LoopField] := 1
	}
	inOutPath := inOutRole := ""

	for k, v in AccChildren(parentElement)
	{
		b := !_allowRole || _allowRole.HasKey(v.accRole(0))
		if b && (obj := SearchElement(v, params, childId, inOutPath, inOutRole, _allowRole))
		{
			if IsByRef(inOutPath)
				inOutPath := k . (inOutPath ? "." : "") . inOutPath
			if IsByRef(inOutRole) && !(inOutRole ~= "\b" v.accRole(0) "\b")
				inOutRole := v.accRole(0) . (inOutRole ? "." : "") . inOutRole
			Return obj
		}
	}
}

AccObjectFromWindow(hWnd, idObject = 0) {
	static IID_IDispatch	:= "{00020400-0000-0000-C000-000000000046}"
		  , IID_IAccessible := "{618736E0-3C3D-11CF-810C-00AA00389B71}"
		  , OBJID_NATIVEOM  := 0xFFFFFFF0, VT_DISPATCH := 9, F_OWNVALUE := 1
		  , h := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")

	VarSetCapacity(IID, 16), idObject &= 0xFFFFFFFF
	DllCall("ole32\CLSIDFromString", "Str", idObject = OBJID_NATIVEOM ? IID_IDispatch : IID_IAccessible, "Ptr", &IID)
	if DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject, "Ptr", &IID, "PtrP", pAcc) = 0
		Return ComObject(VT_DISPATCH, pAcc, F_OWNVALUE)
}

AccWindowFromObject(Acc) {
	DllCall("oleacc\WindowFromAccessibleObject", "Ptr", ComObjValue(Acc), "Ptr*", hWnd)
	return hWnd
}

AccChildren(Acc) {
	static VT_DISPATCH := 9
	Loop 1  {
		if ComObjType(Acc, "Name") != "IAccessible"  {
			error := "Invalid IAccessible Object"
			break
		}
		try cChildren := Acc.accChildCount
		catch
			Return ""
		Children := []
		VarSetCapacity(varChildren, cChildren*(8 + A_PtrSize*2), 0)
		res := DllCall("oleacc\AccessibleChildren", "Ptr", ComObjValue(Acc), "Int", 0
		                                        , "Int", cChildren, "Ptr", &varChildren, "IntP", cChildren)
		if (res != 0) {
			error := "AccessibleChildren DllCall Failed"
			break
		}
		Loop % cChildren  {
			i := (A_Index - 1)*(A_PtrSize*2 + 8)
			child := NumGet(varChildren, i + 8)
			Children.Push( (b := NumGet(varChildren, i) = VT_DISPATCH) ? AccQuery(child) : child )
			( b && ObjRelease(child) )
		}
	}
	if error
		ErrorLevel := error
	else
		Return Children.MaxIndex() ? Children : ""
}

AccQuery(Acc) {
	static IAccessible := "{618736e0-3c3d-11cf-810c-00aa00389b71}", VT_DISPATCH := 9, F_OWNVALUE := 1
	try Return ComObject(VT_DISPATCH, ComObjQuery(Acc, IAccessible), F_OWNVALUE)
}

; =================================================================
createSearchCode(ByRef outCode, codeType, parentElement, params, childId, inOutPath, inOutRole) {
	if !(codeType ~= "i)full|single|parameters")
		throw

	WinGetTitle, title, % "ahk_id " (hWnd := Acc_WindowFromObject(parentElement))
	WinGet, exeName, ProcessName, ahk_id %hWnd%
	WinGetClass, class, ahk_id %hWnd%

	for k, v in params {
		if !(k ~= "i)State|ChildCount|hWnd|Value") {
			q := (k ~= "i)Name|Value") ? """" : ""
			v := (k = "Role") ? "(" Acc_GetRoleConstName(v) ":=" v ")" : v
			strParams .= k ":" q StrReplace(v, "`n", "``n") q ", "
		}
	}
	strParams := "{" RTrim(strParams, ", ") "}"

	if (codeType = "single") {
		outCode = accFound := SearchElement(accParent, %strParams%, %childId%, "%inOutPath%", "%inOutRole%")
		return
	}
	if (codeType = "parameters") {
		outCode = %strParams%, %childId%, "%inOutPath%", "%inOutRole%"
		return
	}

	if (a := acc.accDefaultAction(childId))
		code_DoDefaultAction = accFound.accDoDefaultAction(%childId%) `;%a%

	if (class = "Chrome_WidgetWin_1")
		code_WM_GETOBJECT := "SendMessage, 0x003D, 0, 1 `;WM_GETOBJECT"

	code_part1 =
	(LTrim Join`r`n
		#NoEnv
		SetBatchLines, -1

		if !hwnd := WinExist("%title% ahk_exe %exeName% ahk_class %class%")
		%A_Tab%throw "window not found"

		%code_WM_GETOBJECT%

		accRoot := AccObjectFromWindow(hwnd)
		if !accFound := SearchElement(accRoot, %strParams%, %childId%, "%inOutPath%", "%inOutRole%")
		%A_Tab%throw "element not found"

		MsgBox, `% accFound.accName(%childId%)
		%code_DoDefaultAction%
		Return


	)

code_part2 =
(% Join`r`n
SearchElement(parentElement, params, childId:=0, ByRef inOutPath:="", ByRef inOutRole:="")
{
	_inOutRole := inOutRole
	if accFound := _SearchElement(parentElement, params, childId, inOutPath, inOutRole)
		return accFound
	if _inOutRole 
		return _SearchElement(parentElement, params, childId, inOutPath, inOutRole := "")
}

_SearchElement(parentElement, params, childId:=0, ByRef inOutPath:="", ByRef inOutRole:="", _allowRole:="")
{
	if inOutPath {
		_accBackup := parentElement
		Loop, Parse, inOutPath, `,., %A_Space%%A_Tab%
			parentElement := AccChildren(parentElement)[A_LoopField]
	}

	found := true
	for k, v in params {
		try {
			switch k {
				case "ChildCount":     (parentElement.accChildCount != v  && found := false)
				case "State":     (!(parentElement.accState(childId) & v) && found := false)
				case "NameRegEx": (!(parentElement.accName(childId) ~= v) && found := false)
				default:          (parentElement["acc" . k](childId) != v && found := false)
			}
		}
		catch
			found := false
	} until !found
	if found
		Return parentElement

	if _accBackup {
		parentElement := _accBackup
	}
	if inOutRole {
		_allowRole := {}
		Loop, Parse, inOutRole, `,., %A_Space%%A_Tab%
			_allowRole[A_LoopField] := 1
	}
	inOutPath := inOutRole := ""

	for k, v in AccChildren(parentElement)
	{
		b := !_allowRole || _allowRole.HasKey(v.accRole(0))
		if b && (obj := _SearchElement(v, params, childId, inOutPath, inOutRole, _allowRole))
		{
			if IsByRef(inOutPath)
				inOutPath := k . (inOutPath ? "." : "") . inOutPath
			if IsByRef(inOutRole) && !(inOutRole ~= "\b" v.accRole(0) "\b")
				inOutRole := v.accRole(0) . (inOutRole ? "." : "") . inOutRole
			Return obj
		}
	}
}

AccObjectFromWindow(hWnd, idObject = 0) {
	static IID_IDispatch	:= "{00020400-0000-0000-C000-000000000046}"
		  , IID_IAccessible := "{618736E0-3C3D-11CF-810C-00AA00389B71}"
		  , OBJID_NATIVEOM  := 0xFFFFFFF0, VT_DISPATCH := 9, F_OWNVALUE := 1
		  , h := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")

	VarSetCapacity(IID, 16), idObject &= 0xFFFFFFFF
	DllCall("ole32\CLSIDFromString", "Str", idObject = OBJID_NATIVEOM ? IID_IDispatch : IID_IAccessible, "Ptr", &IID)
	if DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject, "Ptr", &IID, "PtrP", pAcc) = 0
		Return ComObject(VT_DISPATCH, pAcc, F_OWNVALUE)
}

AccChildren(Acc) {
	static VT_DISPATCH := 9
	Loop 1  {
		if ComObjType(Acc, "Name") != "IAccessible"  {
			error := "Invalid IAccessible Object"
			break
		}
		try cChildren := Acc.accChildCount
		catch
			Return ""
		Children := []
		VarSetCapacity(varChildren, cChildren*(8 + A_PtrSize*2), 0)
		res := DllCall("oleacc\AccessibleChildren", "Ptr", ComObjValue(Acc), "Int", 0
		                                        , "Int", cChildren, "Ptr", &varChildren, "IntP", cChildren)
		if (res != 0) {
			error := "AccessibleChildren DllCall Failed"
			break
		}
		Loop % cChildren  {
			i := (A_Index - 1)*(A_PtrSize*2 + 8)
			child := NumGet(varChildren, i + 8)
			Children.Push( (b := NumGet(varChildren, i) = VT_DISPATCH) ? AccQuery(child) : child )
			( b && ObjRelease(child) )
		}
	}
	if error
		ErrorLevel := error
	else
		Return Children.MaxIndex() ? Children : ""
}

AccQuery(Acc) {
	static IAccessible := "{618736e0-3c3d-11cf-810c-00aa00389b71}", VT_DISPATCH := 9, F_OWNVALUE := 1
	try Return ComObject(VT_DISPATCH, ComObjQuery(Acc, IAccessible), F_OWNVALUE)
}
)

	outCode := code_part1 . code_part2
	outCode := StrReplace(outCode, "`r`n`r`n`r`n", "`r`n",, 1)
}