/*
	Title: Command Functions
		A wrapper set of functions for commands which have an output variable.

	License:
		- Version 1.41 <http://www.autohotkey.net/~polyethene/#functions>
		- Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
*/

Functions() {
	Return, true
}

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

ControlGet(Cmd, Value = "", Control = "", WinTitle:="A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
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
; GetKeyState(WhichKey , Mode = "") {
; 	GetKeyState, v, %WhichKey%, %Mode%
; 	Return, v
; }
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
StringGetPos(ByRef InputVar, SearchText, Mode = "", Offset = "") {
	StringGetPos, v, InputVar, %SearchText%, %Mode%, %Offset%
	Return, v
}
StringLeft(ByRef InputVar, Count) {
	StringLeft, v, InputVar, %Count%
	Return, v
}
StringLen(ByRef InputVar) {
	StringLen, v, InputVar
	Return, v
}
StringLower(ByRef InputVar, T = "") {
	StringLower, v, InputVar, %T%
	Return, v
}
StringMid(ByRef InputVar, StartChar, Count , L = "") {
	StringMid, v, InputVar, %StartChar%, %Count%, %L%
	Return, v
}
StringReplace(ByRef InputVar, SearchText, ReplaceText = "", All = "") {
	StringReplace, v, InputVar, %SearchText%, %ReplaceText%, %All%
	Return, v
}
StringRight(ByRef InputVar, Count) {
	StringRight, v, InputVar, %Count%
	Return, v
}
StringTrimLeft(ByRef InputVar, Count) {
	StringTrimLeft, v, InputVar, %Count%
	Return, v
}
StringTrimRight(ByRef InputVar, Count) {
	StringTrimRight, v, InputVar, %Count%
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
Transform(Cmd, Value1, Value2 = "") {
	Transform, v, %Cmd%, %Value1%, %Value2%
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
    if (ControlGetFocus(%WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%) == Control) {
      Return True
    } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
      Return False
    }
  }
}

ControlWaitNotFocus(Control, WinTitle:="A", WinText:="", ExcludeTitle:="", ExcludeText:="", TimeOut:=500) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetFocus(%WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%) != Control) {
      Return True
    } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
      Return False
    }
  }
}

ControlTextWait(Control, text, WinTitle:="A", WinText:="", ExcludeTitle:="", ExcludeText:="", TimeOut:=500) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetText(%Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%) == text) {
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

html_decode(html) {  
   ; original name: ComUnHTML() by 'Guest' from
   ; https://autohotkey.com/board/topic/47356-unhtm-remove-html-formatting-from-a-string-updated/page-2 
   html := RegExReplace(html, "\r?\n|\r", "<br>")  ; added this because original strips line breaks
   oHTML := ComObjCreate("HtmlFile") 
   oHTML.write(html)
   return % oHTML.documentElement.innerText 
}

StrReverse(String) {  ; https://www.autohotkey.com/boards/viewtopic.php?t=27215
  String .= "", DllCall("msvcrt.dll\_wcsrev", "Ptr", &String, "CDecl")
	return String
}

GetBrowserInfo(ByRef BrowserTitle, ByRef BrowserUrl, ByRef BrowserSource, ByRef BrowserDate) {
	BrowserTitle := BrowserUrl := BrowserSource := BrowserDate := ""
	global WinClip
  WinClip.Snap(ClipData)
	Clipboard := ""
	CurrentTick := A_TickCount
	send {f6}^l  ; for moronic websites that use ctrl+L as a shortcut (I'm looking at you, paratranz)
	while (!Clipboard) {
		send ^l^c
		if (A_TickCount := CurrentTick + 500)
			Break
	}
	If (Clipboard) {
    BrowserUrl := ParseUrl(Clipboard)
    GetBrowserTitleSourceDate(BrowserUrl, BrowserTitle, BrowserSource, BrowserDate)
	}
	if (WinActive("ahk_exe msedge.exe")) {
		send ^l{f6}
	} else {
		send ^l+{f6}
	}
  WinClip.Restore(ClipData)
}

ParseUrl(url) {
	url := RegExReplace(url, "#(.*)$")
	if (InStr(url, "youtube.com") && InStr(url, "v=")) {
		RegExMatch(url, "v=\K[\w\-]+", YTLink)
		url := "https://www.youtube.com/watch?v=" . YTLink
	} else if (InStr(url, "bilibili.com/video")) {
		url := RegExReplace(url, "(\/\?|&)vd_source=.*")
	} else if (InStr(url, "netflix.com/watch")) {
		url := RegExReplace(url, "\?trackId=.*")
	}
	return url
}

GetBrowserTitleSourceDate(BrowserUrl, ByRef BrowserTitle, ByRef BrowserSource, ByRef BrowserDate) {
	WinGetActiveTitle BrowserTitle
	BrowserTitle := RegExReplace(BrowserTitle, "( - Google Chrome| — Mozilla Firefox|( and [0-9]+ more pages?)? - [^-]+ - Microsoft​ Edge)$")
	; Sites that need special attention
	if (InStr(BrowserTitle, "很帅的日报")) {
		BrowserDate := StrReplace(BrowserTitle, "很帅的日报 ")
		BrowserTitle := "很帅的日报"
	} else if (InStr(BrowserTitle, "_百度百科")) {
		BrowserSource := "百度百科"
		BrowserTitle := StrReplace(BrowserTitle, "_百度百科")
	} else if (InStr(BrowserTitle, "_百度知道")) {
		BrowserSource := "百度知道"
		BrowserTitle := StrReplace(BrowserTitle, "_百度知道")
	} else if (InStr(BrowserUrl, "reddit.com")) {
		RegExMatch(BrowserUrl, "reddit\.com\/\Kr\/[^\/]+", BrowserSource)
		BrowserTitle := StrReplace(BrowserTitle, " : " . StrReplace(BrowserSource, "r/"))
	; Sites that don't include source in the title
	} else if (InStr(BrowserUrl, "dailystoic.com")) {
		BrowserSource := "Daily Stoic"
	} else if (InStr(BrowserUrl, "healthline.com")) {
		BrowserSource := "Healthline"
	} else if (InStr(BrowserUrl, "medicalnewstoday.com")) {
		BrowserSource := "Medical News Today"
	} else if (InStr(BrowserUrl, "investopedia.com")) {
		BrowserSource := "Investopedia"
	; Sites that should be skipped
	} else if (InStr(BrowserUrl, "mp.weixin.qq.com")) {
		return
	} else if (InStr(BrowserUrl, "universityhealthnews.com")) {
		return
	; Try to use - or | to find source
	} else {
		ReversedTitle := StrReverse(BrowserTitle)
		if (InStr(ReversedTitle, " | ") && (!InStr(ReversedTitle, " - ") || InStr(ReversedTitle, " | ") < InStr(ReversedTitle, " - "))) {  ; used to find source
			separator := " | "
		} else if (InStr(ReversedTitle, " - ")) {
			separator := " - "
		} else if (InStr(ReversedTitle, " – ")) {
			separator := " – "  ; websites like BetterExplained
		} else {
			separator := ""
		}
		pos := separator ? InStr(StrReverse(BrowserTitle), separator) : 0
		if (pos) {
			BrowserSource := SubStr(BrowserTitle, StrLen(BrowserTitle) - pos - 1, StrLen(BrowserTitle))
			if (InStr(BrowserSource, separator))
				BrowserSource := StrReplace(BrowserSource, separator,,, 1)
			BrowserTitle := SubStr(BrowserTitle, 1, StrLen(BrowserTitle) - pos - 2)
		}
	}
}

WinWaitTitleChange(OriginalTitle:="", TimeOut:=5000) {
	if (!OriginalTitle)
		WinGetTitle, OriginalTitle, A
	StartTime := A_TickCount
	Loop {
		if (WinGetTitle() != OriginalTitle) {
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

ControlClickWinCoord(XCoord, YCoord) {
  WinGet, hwnd, ID, A
  ControlClick, % "x" . XCoord * A_ScreenDPI / 96 . " y" . YCoord * A_ScreenDPI / 96, % "ahk_id " hwnd,,,, NA
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

ReleaseKey(Key) {
	if (GetKeyState(Key)) {
		if (key = "ctrl" || key = "shift") {
			send {blind}{l%Key% up}{r%Key% up}
		} else {
			send {blind}{%key% up}
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