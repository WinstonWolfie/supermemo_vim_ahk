/*
	Title: Command Functions
		A wrapper set of functions for commands which have an output variable.

	License:
		- Version 1.41 <http://www.autohotkey.net/~polyethene/#functions>
		- Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
*/
; https://github.com/Paris/AutoHotkey-Scripts/blob/master/Functions.ahk

IfBetween(ByRef var, LowerBound, UpperBound) {
	If var between %LowerBound% and %UpperBound%
		Return, true
}
IfNotBetween(ByRef var, LowerBound, UpperBound) {
	If var not between %LowerBound% and %UpperBound%
		Return, true
}
IfIn(ByRef var, MatchList) {
	If var in %MatchList%
		Return, true
}
IfNotIn(ByRef var, MatchList) {
	If var not in %MatchList%
		Return, true
}
IfContains(ByRef var, MatchList) {
	If var contains %MatchList%
		Return, true
}
IfNotContains(ByRef var, MatchList) {
	If var not contains %MatchList%
		Return, true
}
IfIs(ByRef var, type) {
	If var is %type%
		Return, true
}
IfIsNot(ByRef var, type) {
	If var is not %type%
		Return, true
}
IfMsgBox(ByRef ButtonName) {
	IfMsgBox, % ButtonName
		return true
}

ControlGet(Cmd, Value = "", Control = "", WinTitle:="A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	if (!control)
		control := ControlGetFocus()
	ControlGet, v, %Cmd%, %Value%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
ControlGetFocus(WinTitle:="A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	ControlGetFocus, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
ControlGetText(Control = "", WinTitle:="A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	ControlGetText, v, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
DriveGet(Cmd, Value = "") {
	DriveGet, v, %Cmd%, %Value%
	Return, v
}
DriveSpaceFree(Path) {
	DriveSpaceFree, v, %Path%
	Return, v
}
EnvGet(EnvVarName) {
	EnvGet, v, %EnvVarName%
	Return, v
}
FileGetAttrib(Filename = "") {
	FileGetAttrib, v, %Filename%
	Return, v
}
FileGetShortcut(LinkFile, ByRef OutTarget = "", ByRef OutDir = "", ByRef OutArgs = "", ByRef OutDescription = "", ByRef OutIcon = "", ByRef OutIconNum = "", ByRef OutRunState = "") {
	FileGetShortcut, %LinkFile%, OutTarget, OutDir, OutArgs, OutDescription, OutIcon, OutIconNum, OutRunState
}
FileGetSize(Filename = "", Units = "") {
	FileGetSize, v, %Filename%, %Units%
	Return, v
}
FileGetTime(Filename = "", WhichTime = "") {
	FileGetTime, v, %Filename%, %WhichTime%
	Return, v
}
FileGetVersion(Filename = "") {
	FileGetVersion, v, %Filename%
	Return, v
}
FileRead(Filename) {
	FileRead, v, %Filename%
	Return, v
}
FileReadLine(Filename, LineNum) {
	FileReadLine, v, %Filename%, %LineNum%
	Return, v
}
FileSelectFile(Options = "", RootDir = "", Prompt = "", Filter = "") {
	FileSelectFile, v, %Options%, %RootDir%, %Prompt%, %Filter%
	Return, v
}
FileSelectFolder(StartingFolder = "", Options = "", Prompt = "") {
	FileSelectFolder, v, %StartingFolder%, %Options%, %Prompt%
	Return, v
}
FormatTime(YYYYMMDDHH24MISS = "", Format = "") {
	FormatTime, v, %YYYYMMDDHH24MISS%, %Format%
	Return, v
}
GuiControlGet(Subcommand = "", ControlID = "", Param4 = "") {
	GuiControlGet, v, %Subcommand%, %ControlID%, %Param4%
	Return, v
}
ImageSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ImageFile) {
	ImageSearch, OutputVarX, OutputVarY, %X1%, %Y1%, %X2%, %Y2%, %ImageFile%
}
IniRead(Filename, Section, Key, Default = "") {
	IniRead, v, %Filename%, %Section%, %Key%, %Default%
	Return, v
}
Input(Options = "", EndKeys = "", MatchList = "") {
	Input, v, %Options%, %EndKeys%, %MatchList%
	Return, v
}
InputBox(Title = "", Prompt = "", HIDE = "", Width = "", Height = "", X = "", Y = "", Font = "", Timeout = "", Default = "") {
	InputBox, v, %Title%, %Prompt%, %HIDE%, %Width%, %Height%, %X%, %Y%, , %Timeout%, %Default%
	Return, v
}
MouseGetPos(ByRef OutputVarX = "", ByRef OutputVarY = "", ByRef OutputVarWin = "", ByRef OutputVarControl = "", Mode = "") {
	MouseGetPos, OutputVarX, OutputVarY, OutputVarWin, OutputVarControl, %Mode%
}
PixelGetColor(X, Y, RGB = "") {
	PixelGetColor, v, %X%, %Y%, %RGB%
	Return, v
}
PixelSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ColorID, Variation = "", Mode = "") {
	PixelSearch, OutputVarX, OutputVarY, %X1%, %Y1%, %X2%, %Y2%, %ColorID%, %Variation%, %Mode%
}
Random(Min = "", Max = "") {
	Random, v, %Min%, %Max%
	Return, v
}
RegRead(RootKey, SubKey, ValueName = "") {
	RegRead, v, %RootKey%, %SubKey%, %ValueName%
	Return, v
}
Run(Target, WorkingDir = "", Mode = "") {
	Run, %Target%, %WorkingDir%, %Mode%, v
	Return, v	
}
SoundGet(ComponentType = "", ControlType = "", DeviceNumber = "") {
	SoundGet, v, %ComponentType%, %ControlType%, %DeviceNumber%
	Return, v
}
SoundGetWaveVolume(DeviceNumber = "") {
	SoundGetWaveVolume, v, %DeviceNumber%
	Return, v
}
StatusBarGetText(Part = "", WinTitle:="A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	StatusBarGetText, v, %Part%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
SplitPath(ByRef InputVar, ByRef OutFileName = "", ByRef OutDir = "", ByRef OutExtension = "", ByRef OutNameNoExt = "", ByRef OutDrive = "") {
	SplitPath, InputVar, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
}
StringLower(ByRef InputVar, T = "") {
	StringLower, v, InputVar, %T%
	Return, v
}
StringUpper(ByRef InputVar, T = "") {
	StringUpper, v, InputVar, %T%
	Return, v
}
SysGet(Subcommand, Param3 = "") {
	SysGet, v, %Subcommand%, %Param3%
	Return, v
}
WinGet(Cmd = "", WinTitle:="A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	WinGet, v, %Cmd%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
WinGetActiveTitle() {
	WinGetActiveTitle, v
	Return, v
}
WinGetClass(WinTitle:="A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	WinGetClass, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
WinGetText(WinTitle:="A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	WinGetText, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
WinGetTitle(WinTitle:="A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	WinGetTitle, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}

; https://www.autohotkey.com/boards/viewtopic.php?t=5484
; This function wraps a loop that continuously uses ControlGetFocus to test if a particular 
; control is active. For more info see ControlGetFocus in the docs.
; An optional timeout can be included.
ControlFocusWait(Control, WinTitle:="A", WinText:="", ExcludeTitle:="", ExcludeText:="", TimeOut:=500) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetFocus(WinTitle, WinText, ExcludeTitle, ExcludeText) == Control) {
      Return True
    } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
      Return False
    }
  }
}

ControlWait(Control, WinTitle:="A", WinText:="", ExcludeTitle:="", ExcludeText:="", TimeOut:=500) {
  StartTime := A_TickCount
  Loop {
    if (ControlGet("hwnd",, Control, WinTitle, WinText, ExcludeTitle, ExcludeText)) {
      Return True
    } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
      Return False
    }
  }
}

ControlWaitNotFocus(Control, WinTitle:="A", WinText:="", ExcludeTitle:="", ExcludeText:="", TimeOut:=500) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetFocus(WinTitle, WinText, ExcludeTitle, ExcludeText) != Control) {
      Return True
    } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
      Return False
    }
  }
}

ControlTextWait(Control, text, WinTitle:="A", WinText:="", ExcludeTitle:="", ExcludeText:="", TimeOut:=500) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetText(Control, WinTitle, WinText, ExcludeTitle, ExcludeText) == text) {
      Return True
    } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
      Return False
    }
  }
}

;#########################################################################################
;uri encode/decode by Titan
;Thread: http://www.autohotkey.com/forum/topic18876.html
;About: http://en.wikipedia.org/wiki/Percent_encoding
;two functions by titan: (slightly modified by infogulch)
; https://www.autohotkey.com/board/topic/29866-encoding-and-decoding-functions-v11/

Dec_Uri(str) 
{
   Loop
      If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
      Else Break
   Return, str
}

Enc_Uri(str) 
{
  f = %A_FormatInteger%
  SetFormat, Integer, Hex
  If RegExMatch(str, "^\w+:/{0,2}", pr)
    StringTrimLeft, str, str, StrLen(pr)
  StringReplace, str, str, `%, `%25, All
  Loop
    If RegExMatch(str, "i)[^\w\.~%/:]", char)
      StringReplace, str, str, %char%, % "%" . SubStr(Asc(char),3), All
    Else Break
  SetFormat, Integer, %f%
  Return, pr . str
}

;#########################################################################################
;XML encode/decode by infogulch  -  this might be handy for use with xpath by titan
;About: http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references

Dec_XML(str)
{ ;Decode xml required characters, as well as numeric character references
   Loop
      If RegexMatch(str, "S)(&#(\d+);)", dec)						; matches:   &#[dec];
         StringReplace, str, str, %dec1%, % Chr(dec2), All
      Else If   RegexMatch(str, "Si)(&#x([\da-f]+);)", hex)			; matches:   &#x[hex];
         StringReplace, str, str, %hex1%, % Chr("0x" . hex2), All
      Else
         Break
   StringReplace, str, str, % " ", %A_Space%, All
   StringReplace, str, str, ", ", All			;required predefined character entities &"<'>
   StringReplace, str, str, ', ', All
   StringReplace, str, str, <,   <, All
   StringReplace, str, str, >,   >, All
   StringReplace, str, str, &,  &, All			;do this last so str doesn't resolve to other entities
   return, str
}

Enc_XML(str, chars="") 
{ ;encode required xml characters. and characters listed in Param2 as numeric character references
   StringReplace, str, str, &, &,  All			;do first so it doesn't re-encode already encoded characters
   StringReplace, str, str, ", ", All			;required predefined character entities &"<'>
   StringReplace, str, str, ', ', All
   StringReplace, str, str, <, <,   All
   StringReplace, str, str, >, >,   All
   Loop, Parse, chars         
      StringReplace, str, str, %A_LoopField%, % "&#" . Asc(A_LoopField) . "`;", All
   return, str
}

;#########################################################################################

html_decode(html) {  
   ; original name: ComUnHTML() by 'Guest' from
   ; https://autohotkey.com/board/topic/47356-unhtm-remove-html-formatting-from-a-string-updated/page-2 
   html := RegExReplace(html, "\r?\n|\r", "<br>")  ; added this because original strips line breaks
   oHTML := ComObjCreate("HtmlFile") 
   oHTML.write(html)
   return % oHTML.documentElement.innerText 
}

EncodeDecodeURI(str, encode := true, component := true) {  ; https://www.autohotkey.com/boards/viewtopic.php?t=84825
   static Doc, JS
   if !Doc {
      Doc := ComObjCreate("htmlfile")
      Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
      JS := Doc.parentWindow
      ( Doc.documentMode < 9 && JS.execScript() )
   }
   Return JS[ (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "") ](str)
}

StrReverse(String) {  ; https://www.autohotkey.com/boards/viewtopic.php?t=27215
  String .= "", DllCall("msvcrt.dll\_wcsrev", "Ptr", &String, "CDecl")
	return String
}

WinWaitTitleChange(OriginalTitle:="", TimeOut:=5000, WinTitle:="A") {
	if (!OriginalTitle)
		WinGetTitle, OriginalTitle, % WinTitle
	StartTime := A_TickCount
	loop {
		if (WinGetTitle(WinTitle) != OriginalTitle) {
			return true
		} else if (TimeOut && A_TickCount - StartTime > TimeOut) {
			return false
		}
	}
}

Click(XCoord, YCoord, WhichButton:="") {
	MouseDelay := A_MouseDelay
	MouseGetPos, XSaved, YSaved
	SetMouseDelay -1
	Click % XCoord . " " . YCoord . " " . WhichButton
	MouseMove, XSaved, YSaved, 0
	SetMouseDelay % MouseDelay
}

ClickDPIAdjusted(XCoord, YCoord) {
	MouseDelay := A_MouseDelay
	MouseGetPos, XSaved, YSaved
	SetMouseDelay -1
	Click % XCoord * A_ScreenDPI / 96 . " " . YCoord * A_ScreenDPI / 96
	MouseMove, XSaved, YSaved, 0
	SetMouseDelay % MouseDelay
}

ControlClickWinCoord(XCoord, YCoord, WinTitle:="") {
	if (!Wintitle)
		WinTitle := "ahk_id " . WinGet("ID")
	ControlClick, % "x" . XCoord * A_ScreenDPI / 96 . " y" . YCoord * A_ScreenDPI / 96, % WinTitle,,,, NA
}

WaitCaretMove(OriginalX:=0, OriginalY:=0, TimeOut:=5000) {
	if (!OriginalX)
		MouseGetPos, OriginalX
	if (!OriginalY)
		MouseGetPos,, OriginalY
	StartTime := A_TickCount
	loop {
		if (A_CaretX != OriginalX || A_CaretY != OriginalY) {
			return true
		} else if (TimeOut && A_TickCount - StartTime > TimeOut) {
			return false
		}
	}
}

SetDefaultKeyboard(LocaleID) {  ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=18519
	Global
	SPI_SETDEFAULTINPUTLANG := 0x005A
	SPIF_SENDWININICHANGE := 2
	Lan := DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", LocaleID), "Int", 0)
	VarSetCapacity(Lan%LocaleID%, 4, 0)
	NumPut(LocaleID, Lan%LocaleID%)
	DllCall("SystemParametersInfo", "UInt", SPI_SETDEFAULTINPUTLANG, "UInt", 0, "UPtr", &Lan%LocaleID%, "UInt", SPIF_SENDWININICHANGE)
	WinGet, windows, List
	Loop %windows% {
		PostMessage 0x50, 0, %Lan%, , % "ahk_id " windows%A_Index%
	}
}
return

ToolTip(text:="", perma:=false, period:=-2000) {
	CoordMode, ToolTip, Screen
	ToolTip, % text, % A_ScreenWidth / 3, % A_ScreenHeight / 4 * 3, 20
	if (!perma)
		SetTimer, RemoveToolTip, % period
}

RemoveToolTip:
  ToolTip,,,, 20
return

RevArr(arr) {
	newarr := []
	for index, value in arr
			newarr.InsertAt(1, value)
	return newarr
}