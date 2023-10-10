#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
/*
  Title: Command Functions
    A wrapper set of functions for commands which have an output variable.

  License:
    - Version 1.41 <http://www.autohotkey.net/~polyethene/#functions>
    - Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
*/
; https://github.com/Paris/AutoHotkey-Scripts/blob/master/Functions.ahk

IfBetween(ByRef var, LowerBound, UpperBound, StrCaseSense:=false) {
  PrevStringCaseSense := A_StringCaseSense
  StringCaseSense % StrCaseSense ? "on" : "off"
  If var between %LowerBound% and %UpperBound%
    ret := true
  StringCaseSense % PrevStringCaseSense
  return ret
}
IfNotBetween(ByRef var, LowerBound, UpperBound, StrCaseSense:=false) {
  PrevStringCaseSense := A_StringCaseSense
  StringCaseSense % StrCaseSense ? "on" : "off"
  If var not between %LowerBound% and %UpperBound%
    ret := true
  StringCaseSense % PrevStringCaseSense
  return ret
}
IfIn(ByRef var, MatchList, StrCaseSense:=false) {
  PrevStringCaseSense := A_StringCaseSense
  StringCaseSense % StrCaseSense ? "on" : "off"
  If var in %MatchList%
    ret := true
  StringCaseSense % PrevStringCaseSense
  return ret
}
IfNotIn(ByRef var, MatchList, StrCaseSense:=false) {
  PrevStringCaseSense := A_StringCaseSense
  StringCaseSense % StrCaseSense ? "on" : "off"
  If var not in %MatchList%
    ret := true
  StringCaseSense % PrevStringCaseSense
  return ret
}
IfContains(ByRef var, MatchList, StrCaseSense:=false) {
  PrevStringCaseSense := A_StringCaseSense
  StringCaseSense % StrCaseSense ? "on" : "off"
  If var contains %MatchList%
    ret := true
  StringCaseSense % PrevStringCaseSense
  return ret
}
IfNotContains(ByRef var, MatchList, StrCaseSense:=false) {
  PrevStringCaseSense := A_StringCaseSense
  StringCaseSense % StrCaseSense ? "on" : "off"
  If var not contains %MatchList%
    ret := true
  StringCaseSense % PrevStringCaseSense
  return ret
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

ControlGet(Cmd:="Hwnd", Value:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
  Control := Control ? Control : ControlGetFocus(WinTitle)
  ControlGet, v, % Cmd, % Value, % Control, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
  Return, v
}
ControlGetFocus(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
  ControlGetFocus, v, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
  Return, v
}
ControlGetText(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
  Control := Control ? Control : ControlGetFocus(WinTitle)
  ControlGetText, v, % Control, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
  Return, v
}
DriveGet(Cmd, Value:="") {
  DriveGet, v, % Cmd, % Value
  Return, v
}
DriveSpaceFree(Path) {
  DriveSpaceFree, v, % Path
  Return, v
}
EnvGet(EnvVarName) {
  EnvGet, v, % EnvVarName
  Return, v
}
FileGetAttrib(Filename:="") {
  FileGetAttrib, v, % Filename
  Return, v
}
FileGetShortcut(LinkFile, ByRef OutTarget:="", ByRef OutDir:="", ByRef OutArgs:="", ByRef OutDescription:="", ByRef OutIcon:="", ByRef OutIconNum:="", ByRef OutRunState:="") {
  FileGetShortcut, % LinkFile, OutTarget, OutDir, OutArgs, OutDescription, OutIcon, OutIconNum, OutRunState
}
FileGetSize(Filename:="", Units:="") {
  FileGetSize, v, % Filename, % Units
  Return, v
}
FileGetTime(Filename:="", WhichTime:="") {
  FileGetTime, v, % Filename, % WhichTime
  Return, v
}
FileGetVersion(Filename:="") {
  FileGetVersion, v, % Filename
  Return, v
}
FileRead(Filename) {
  FileRead, v, % Filename
  Return, v
}
FileReadAndDelete(Filename) {
  FileRead, v, % Filename
  FileDelete, % Filename
  Return, v
}
FileReadLine(Filename, LineNum) {
  FileReadLine, v, % Filename, % LineNum
  Return, v
}
FileSelectFile(Options:="", RootDir:="", Prompt:="", Filter:="") {
  FileSelectFile, v, % Options, % RootDir, % Prompt, % Filter
  Return, v
}
FileSelectFolder(StartingFolder:="", Options:="", Prompt:="") {
  FileSelectFolder, v, % StartingFolder, % Options, % Prompt
  Return, v
}
FormatTime(YYYYMMDDHH24MISS:="", Format:="") {
  FormatTime, v, % YYYYMMDDHH24MISS, % Format
  Return, v
}
GuiControlGet(Subcommand:="", ControlID:="", Param4:="") {
  GuiControlGet, v, % Subcommand, % ControlID, % Param4
  Return, v
}
ImageSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ImageFile) {
  ImageSearch, OutputVarX, OutputVarY, % X1, % Y1, % X2, % Y2, % ImageFile
}
IniRead(Filename, Section, Key, Default:="") {
  IniRead, v, % Filename, % Section, % Key, % Default
  Return, v
}
Input(Options:="", EndKeys:="", MatchList:="") {
  Input, v, % Options, % EndKeys, % MatchList
  Return, v
}
InputBox(Title:="", Prompt:="", HIDE:="", Width:="192", Height:="128", X:="", Y:="", Font:="", Timeout:="", Default:="") {
  InputBox, v, % Title, % Prompt, % HIDE, % Width, % Height, % X, % Y, , % Timeout, % Default
  Return, v
}
MouseGetPos(ByRef OutputVarX:="", ByRef OutputVarY:="", ByRef OutputVarWin:="", ByRef OutputVarControl:="", Mode:="") {
  MouseGetPos, OutputVarX, OutputVarY, OutputVarWin, OutputVarControl, % Mode
}
PixelGetColor(X, Y, RGB:="") {
  PixelGetColor, v, % X, % Y, % RGB
  Return, v
}
PixelSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ColorID, Variation:="", Mode:="") {
  PixelSearch, OutputVarX, OutputVarY, % X1, % Y1, % X2, % Y2, % ColorID, % Variation, % Mode
}
Random(Min:="", Max:="") {
  Random, v, % Min, % Max
  Return, v
}
RegRead(RootKey, SubKey, ValueName:="") {
  RegRead, v, % RootKey, % SubKey, % ValueName
  Return, v
}
Run(Target, WorkingDir:="", Mode:="") {
  Run, % Target, % WorkingDir, % Mode, v
  Return, v 
}
SoundGet(ComponentType:="", ControlType:="", DeviceNumber:="") {
  SoundGet, v, % ComponentType, % ControlType, % DeviceNumber
  Return, v
}
SoundGetWaveVolume(DeviceNumber:="") {
  SoundGetWaveVolume, v, % DeviceNumber
  Return, v
}
StatusBarGetText(Part:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
  StatusBarGetText, v, % Part, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
  Return, v
}
SplitPath(ByRef InputVar, ByRef OutFileName:="", ByRef OutDir:="", ByRef OutExtension:="", ByRef OutNameNoExt:="", ByRef OutDrive:="") {
  SplitPath, InputVar, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
}
StrLower(ByRef InputVar, T:="") {
  StringLower, v, InputVar, % T
  Return, v
}
StrUpper(ByRef InputVar, T:="") {
  StringUpper, v, InputVar, % T
  Return, v
}
SysGet(Subcommand, Param3:="") {
  SysGet, v, % Subcommand, % Param3
  Return, v
}
WinGet(Cmd:="ID", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
  WinGet, v, % Cmd, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
  Return, v
}
WinGetActiveTitle() {
  WinGetActiveTitle, v
  Return, v
}
WinGetClass(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
  WinGetClass, v, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
  Return, v
}
WinGetText(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
  WinGetText, v, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
  Return, v
}
WinGetTitle(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
  WinGetTitle, v, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
  Return, v
}
UrlDownloadToFile(URL, Filename) {
  UrlDownloadToFile, % URL, % Filename
}
MsgBox(Options:="", Title:="", Text:="", Timeout:="") {
  MsgBox, % Options, % Title, % Text, % Timeout
}

; https://www.autohotkey.com/boards/viewtopic.php?t=5484
; This function wraps a loop that continuously uses ControlGetFocus to test if a particular 
; control is active. For more info see ControlGetFocus in the docs.
; An optional timeout can be included.
ControlFocusWait(Control, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=0) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetFocus(WinTitle, WinText, ExcludeTitle, ExcludeText) == Control) {
      Return True
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      Return False
    }
  }
}

ControlWait(Control, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=0) {
  StartTime := A_TickCount
  Loop {
    if (ControlGet(,, Control, WinTitle, WinText, ExcludeTitle, ExcludeText)) {
      Return ControlGet(,, Control, WinTitle, WinText, ExcludeTitle, ExcludeText)
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      Return False
    }
  }
}

ControlWaitNotFocus(Control, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=0) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetFocus(WinTitle, WinText, ExcludeTitle, ExcludeText) != Control) {
      Return ControlGetFocus(WinTitle, WinText, ExcludeTitle, ExcludeText)
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      Return False
    }
  }
}

WinTextWaitExist(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=0) {
  StartTime := A_TickCount
  Loop {
    if (WinGetText(WinTitle, WinText, ExcludeTitle, ExcludeText)) {
      Return WinGetText(WinTitle, WinText, ExcludeTitle, ExcludeText)
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      Return False
    }
  }
}

ControlTextWaitExist(Control, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=0) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetText(Control, WinTitle, WinText, ExcludeTitle, ExcludeText)) {
      Return ControlGetText(Control, WinTitle, WinText, ExcludeTitle, ExcludeText)
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      Return False
    }
  }
}

ControlTextWait(Control, text, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=0) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetText(Control, WinTitle, WinText, ExcludeTitle, ExcludeText) == text) {
      Return True
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      Return False
    }
  }
}

ControlTextWaitChange(Control, text:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=0) {
  StartTime := A_TickCount
  Loop {
    if (ControlGetText(Control, WinTitle, WinText, ExcludeTitle, ExcludeText) != text) {
      Return ControlGetText(Control, WinTitle, WinText, ExcludeTitle, ExcludeText)
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      Return False
    }
  }
}

ControlWaitHwndChange(Control, hWnd:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=0) {
  hWnd := hWnd ? hWnd : ControlGet(,, Control, WinTitle, WinText, ExcludeTitle, ExcludeText)
  StartTime := A_TickCount
  Loop {
    NewHwnd := ControlGet(,, Control, WinTitle, WinText, ExcludeTitle, ExcludeText)
    if (NewHwnd && (NewHwnd != hWnd)) {
      Return NewHwnd
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      Return False
    }
  }
}

WinTextWaitChange(text, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=0) {
  StartTime := A_TickCount
  Loop {
    if (WinGetText(WinTitle, WinText, ExcludeTitle, ExcludeText) != text) {
      Return WinGetText(WinTitle, WinText, ExcludeTitle, ExcludeText)
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
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
      StringReplace, str, str, % char, %  "" . SubStr(Asc(char),3), All
    Else Break
  SetFormat, Integer, % f
  Return, pr . str
}

;#########################################################################################
;XML encode/decode by infogulch  -  this might be handy for use with xpath by titan
;About: http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references

Dec_XML(str)
{ ;Decode xml required characters, as well as numeric character references
   Loop
      If RegexMatch(str, "S)(&#(\d+);)", dec)           ; matches:   &#[dec];
         StringReplace, str, str, % dec1, % Chr(dec2), All
      Else If   RegexMatch(str, "Si)(&#x([\da-f]+);)", hex)     ; matches:   &#x[hex];
         StringReplace, str, str, % hex1, % Chr("0x" . hex2), All
      Else
         Break
   StringReplace, str, str, % " ", % A_Space, All
   StringReplace, str, str, ", ", All     ;required predefined character entities &"<'>
   StringReplace, str, str, ', ', All
   StringReplace, str, str, <,   <, All
   StringReplace, str, str, >,   >, All
   StringReplace, str, str, &,  &, All      ;do this last so str doesn't resolve to other entities
   return, str
}

Enc_XML(str, chars="") 
{ ;encode required xml characters. and characters listed in Param2 as numeric character references
   StringReplace, str, str, &, &,  All      ;do first so it doesn't re-encode already encoded characters
   StringReplace, str, str, ", ", All     ;required predefined character entities &"<'>
   StringReplace, str, str, ', ', All
   StringReplace, str, str, <, <,   All
   StringReplace, str, str, >, >,   All
   Loop, Parse, chars         
      StringReplace, str, str, % A_LoopField, % "&#" . Asc(A_LoopField) . "`;", All
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

WinWaitTitleChange(OriginalTitle:="", WinTitle:="", Timeout:=0) {
  OriginalTitle := OriginalTitle ? OriginalTitle : WinGetTitle(WinTitle)
  StartTime := A_TickCount
  loop {
    if (WinGetTitle(WinTitle) != OriginalTitle) {
      return WinGetTitle(WinTitle)
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      return false
    }
  }
}

WinWaitTitle(title, Timeout:=0, WinTitle:="") {
  StartTime := A_TickCount
  loop {
    if (WinGetTitle(WinTitle) == title) {
      return true
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
      return false
    }
  }
}

WinWaitTitleRegEx(title, Timeout:=0, WinTitle:="") {
  StartTime := A_TickCount
  loop {
    if (WinGetTitle(WinTitle) ~= title) {
      return WinGetTitle(WinTitle)
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
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
  WinTitle := WinTitle ? WinTitle : "ahk_id " . WinActive("A")
  ControlClick, % "x" . XCoord . " y" . YCoord, % WinTitle,,,, NA
}

ControlClickWinCoordDPIAdjusted(XCoord, YCoord, WinTitle:="") {
  WinTitle := WinTitle ? WinTitle : "ahk_id " . WinActive("A")
  ControlClick, % "x" . XCoord * A_ScreenDPI / 96 . " y" . YCoord * A_ScreenDPI / 96, % WinTitle,,,, NA
}

ControlClickDPIAdjusted(XCoord, YCoord, Control:="", WinTitle:="") {
  Control := Control ? Control : ControlGetFocus(WinTitle)
  WinTitle := WinTitle ? WinTitle : "ahk_id " . WinActive("A")
  ControlClick, % Control, % WinTitle,,,, % "NA x" . XCoord * A_ScreenDPI / 96 . " y" . YCoord * A_ScreenDPI / 96
}

ControlClickScreen(x, y, WinTitle:="") {
  WinTitle := WinTitle ? WinTitle : "ahk_id " . WinActive("A")
  WinGetPos, wX, wY,,, % WinTitle
  ControlClick, % "x" . x - wX . " y" . y - wY, % WinTitle,,,, NA
}

WaitCaretMove(OriginalX:=0, OriginalY:=0, Timeout:=0) {
  if (!OriginalX)
    MouseGetPos, OriginalX
  if (!OriginalY)
    MouseGetPos,, OriginalY
  StartTime := A_TickCount
  loop {
    x := A_CaretX, y := A_CaretY
    if ((x != OriginalX) || (y != OriginalY)) {
      return x . " " . y
    } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
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
    PostMessage 0x50, 0, % Lan, , %  "ahk_id " windows%A_Index%
  }
}

ToolTip(text, perma:=false, period:=-2000, command:="", n:=20) {
  PrevCoordModeTT := A_CoordModeToolTip
  CoordMode, ToolTip, Screen
  if (command = "center") {
    x := A_ScreenWidth / 3, y := A_ScreenHeight / 2
  } else {
    x := A_ScreenWidth / 3, y := A_ScreenHeight / 5 * 4
  }
  ToolTip, % text, % x, % y, % n
  RemoveTTFunc := Func("RemoveToolTip").Bind(n)
  SetTimer, % RemoveTTFunc, off
  if (!perma)
    SetTimer, % RemoveTTFunc, % period
  CoordMode, ToolTip, % PrevCoordModeTT
}

RemoveToolTip(n:=20) {
  Tooltip,,,, % n
}

RevArr(arr) {  ; https://github.com/jNizM/AHK_Scripts/blob/master/src/arrays/RevArr.ahk
  newarr := []
  for index, value in arr
    newarr.InsertAt(1, value)
  return newarr
}

ObjCount(obj) {  ; https://www.autohotkey.com/boards/viewtopic.php?f=37&t=3950&p=21579#p21578
  return NumGet(&obj+4*A_PtrSize)  ; obj->mFieldCount -- OK for v1.1.15.01 and v2.0-a48
}

HasVal(haystack, needle) {  ; https://github.com/jNizM/AHK_Scripts/blob/master/src/arrays/HasVal.ahk
  for index, value in haystack
    if (value = needle)
      return index
  if !(IsObject(haystack))
    throw Exception("Bad haystack!", -1, haystack)
  return 0
}

; ======================================================================================================================
; ToolTipEx()     Display ToolTips with custom fonts and colors.
;                 Code based on the original AHK ToolTip implementation in Script2.cpp.
; Tested with:    AHK 1.1.15.04 (A32/U32/U64)
; Tested on:      Win 8.1 Pro (x64)
; Change history:
;     1.1.01.00/2014-08-30/just me     -  fixed  bug preventing multiline tooltips.
;     1.1.00.00/2014-08-25/just me     -  added icon support, added named function parameters.
;     1.0.00.00/2014-08-16/just me     -  initial release.
; Parameters:
;     Text           -  the text to display in the ToolTip.
;                       If omitted or empty, the ToolTip will be destroyed.
;     X              -  the X position of the ToolTip.
;                       Default: "" (mouse cursor)
;     Y              -  the Y position of the ToolTip.
;                       Default: "" (mouse cursor)
;     WhichToolTip   -  the number of the ToolTip.
;                       Values:  1 - 20
;                       Default: 1
;     HFONT          -  a HFONT handle of the font to be used.
;                       Default: 0 (default font)
;     BgColor        -  the background color of the ToolTip.
;                       Values:  RGB integer value or HTML color name.
;                       Default: "" (default color)
;     TxColor        -  the text color of the TooöTip.
;                       Values:  RGB integer value or HTML color name.
;                       Default: "" (default color)
;     HICON          -  the icon to display in the upper-left corner of the TooöTip.
;                       This can be the number of a predefined icon (1 = info, 2 = warning, 3 = error - add 3 to
;                       display large icons on Vista+) or a HICON handle. Specify 0 to remove an icon from the ToolTip.
;                       Default: "" (no icon)
;     CoordMode      -  the coordinate mode for the X and Y parameters, if specified.
;                       Values:  "C" (Client), "S" (Screen), "W" (Window)
;                       Default: "W" (CoordMode, ToolTip, Window)
; Return values:
;     On success: The HWND of the ToolTip window.
;     On failure: False (ErrorLevel contains additional informations)
; ======================================================================================================================
ToolTipEx(Text:="", X:="", Y:="", WhichToolTip:=1, HFONT:="", BgColor:="", TxColor:="", HICON:="", CoordMode:="W") {
   ; ToolTip messages
   Static ADDTOOL  := A_IsUnicode ? 0x0432 : 0x0404 ; TTM_ADDTOOLW : TTM_ADDTOOLA
   Static BKGCOLOR := 0x0413 ; TTM_SETTIPBKCOLOR
   Static MAXTIPW  := 0x0418 ; TTM_SETMAXTIPWIDTH
   Static SETMARGN := 0x041A ; TTM_SETMARGIN
   Static SETTHEME := 0x200B ; TTM_SETWINDOWTHEME
   Static SETTITLE := A_IsUnicode ? 0x0421 : 0x0420 ; TTM_SETTITLEW : TTM_SETTITLEA
   Static TRACKACT := 0x0411 ; TTM_TRACKACTIVATE
   Static TRACKPOS := 0x0412 ; TTM_TRACKPOSITION
   Static TXTCOLOR := 0x0414 ; TTM_SETTIPTEXTCOLOR
   Static UPDTIPTX := A_IsUnicode ? 0x0439 : 0x040C ; TTM_UPDATETIPTEXTW : TTM_UPDATETIPTEXTA
   ; Other constants
   Static MAX_TOOLTIPS := 20 ; maximum number of ToolTips to appear simultaneously
   Static SizeTI   := (4 * 6) + (A_PtrSize * 6) ; size of the TOOLINFO structure
   Static OffTxt   := (4 * 6) + (A_PtrSize * 3) ; offset of the lpszText field
   Static TT := [] ; ToolTip array
   ; HTML Colors (BGR)
   Static HTML := {AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
                 , LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
                 , SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF}
   ; -------------------------------------------------------------------------------------------------------------------
   ; Init TT on first call
   If (TT.MaxIndex() = "")
      Loop, 20
         TT[A_Index] := {HW: 0, IC: 0, TX: ""}
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check params
   TTTX := Text
   TTXP := X
   TTYP := Y
   TTIX := WhichToolTip = "" ? 1 : WhichToolTip
   TTHF := HFONT = "" ? 0 : HFONT
   TTBC := BgColor
   TTTC := TxColor
   TTIC := HICON
   TTCM := CoordMode = "" ? "W" : SubStr(CoordMode, 1, 1)
   If TTXP Is Not Digit
      Return False, ErrorLevel := "Invalid parameter X-position!", False
   If TTYP Is Not Digit
      Return  False, ErrorLevel := "Invalid parameter Y-Position!", False
   If (TTIX < 1) || (TTIX > MAX_TOOLTIPS)
      Return False, ErrorLevel := "Max ToolTip number is " . MAX_TOOLTIPS . ".", False
   If (TTHF) && !(DllCall("Gdi32.dll\GetObjectType", "Ptr", TTHF, "UInt") = 6) ; OBJ_FONT
      Return False, ErrorLevel := "Invalid font handle!", False
   If TTBC Is Integer
      TTBC := ((TTBC >> 16) & 0xFF) | (TTBC & 0x00FF00) | ((TTBC & 0xFF) << 16)
   Else
      TTBC := HTML.HasKey(TTBC) ? HTML[TTBC] : ""
   If TTTC Is Integer
      TTTC := ((TTTC >> 16) & 0xFF) | (TTTC & 0x00FF00) | ((TTTC & 0xFF) << 16)
   Else
      TTTC := HTML.HasKey(TTTC) ? HTML[TTTC] : ""
   If !InStr("CSW", TTCM)
      Return False, ErrorLevel := "Invalid parameter CoordMode!", False
   ; -------------------------------------------------------------------------------------------------------------------
   ; Destroy the ToolTip window, if Text is empty
   TTHW := TT[TTIX].HW
   If (TTTX = "") && (TTHW) {
      If DllCall("User32.dll\IsWindow", "Ptr", TTHW, "UInt")
         DllCall("User32.dll\DestroyWindow", "Ptr", TTHW)
      TT[TTIX] := {HW: 0, TX: ""}
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Get the virtual desktop rectangle
   SysGet, X, 76
   SysGet, Y, 77
   SysGet, W, 78
   SysGet, H, 79
   DTW := {L: X, T: Y, R: X + W, B: Y + H}
   ; -------------------------------------------------------------------------------------------------------------------
   ; Initialise the ToolTip coordinates. If either X or Y is empty, use the cursor position for the present.
   PT := {X: 0, Y: 0}
  If (TTXP = "") || (TTYP = "") {
      VarSetCapacity(Cursor, 8, 0)
      DllCall("User32.dll\GetCursorPos", "Ptr", &Cursor)
      Cursor := {X: NumGet(Cursor, 0, "Int"), Y: NumGet(Cursor, 4, "Int")}
      PT := {X: Cursor.X + 16, Y: Cursor.Y + 16}
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; If either X or Y  is specified, get the position of the active window considering CoordMode.
   Origin := {X: 0, Y: 0}
   If ((TTXP <> "") || (TTYP <> "")) && ((TTCM = "W") || (TTCM = "C")) { ; if (*aX || *aY) // Need the offsets.
      HWND := DllCall("User32.dll\GetForegroundWindow", "UPtr")
      If (TTCM = "W") {
         WinGetPos, X, Y, , , ahk_id %HWND%
         Origin := {X: X, Y: Y}
      }
      Else {
         VarSetCapacity(OriginPT, 8, 0)
         DllCall("User32.dll\ClientToScreen", "Ptr", HWND, "Ptr", &OriginPT)
         Origin := {X: NumGet(OriginPT, 0, "Int"), Y: NumGet(OriginPT, 0, "Int")}
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; If either X or Y is specified, use the window related position for this parameter.
   If (TTXP <> "")
      PT.X := TTXP + Origin.X
   If (TTYP <> "")
      PT.Y := TTYP + Origin.Y
   ; -------------------------------------------------------------------------------------------------------------------
   ; Create and fill a TOOLINFO structure.
   TT[TTIX].TX := "T" . TTTX ; prefix with T to ensure it will be stored as a string in either case
   VarSetCapacity(TI, SizeTI, 0) ; TOOLINFO structure
   NumPut(SizeTI, TI, 0, "UInt")
   NumPut(0x0020, TI, 4, "UInt") ; TTF_TRACK
   NumPut(TT[TTIX].GetAddress("TX") + (1 << !!A_IsUnicode), TI, OffTxt, "Ptr")
   ; -------------------------------------------------------------------------------------------------------------------
   ; If the ToolTip window doesn't exist, create it.
   If !(TTHW) || !DllCall("User32.dll\IsWindow", "Ptr", TTHW, "UInt") {
      ; ExStyle = WS_TOPMOST, Style = TTS_NOPREFIX | TTS_ALWAYSTIP
      TTHW := DllCall("User32.dll\CreateWindowEx", "UInt", 8, "Str", "tooltips_class32", "Ptr", 0, "UInt", 3
                        , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", A_ScriptHwnd, "Ptr", 0, "Ptr", 0, "Ptr", 0)
      DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", ADDTOOL, "Ptr", 0, "Ptr", &TI)
      DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", MAXTIPW, "Ptr", 0, "Ptr", A_ScreenWidth)
      DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", TRACKPOS, "Ptr", 0, "Ptr", PT.X | (PT.Y << 16))
      DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", TRACKACT, "Ptr", 1, "Ptr", &TI)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Update the text and the font and colors, if specified.
   If (TTBC <> "") || (TTTC <> "") { ; colors
      DllCall("UxTheme.dll\SetWindowTheme", "Ptr", TTHW, "Ptr", 0, "Str", "")
      VarSetCapacity(RC, 16, 0)
      NumPut(4, RC, 0, "Int"), NumPut(4, RC, 4, "Int"), NumPut(4, RC, 8, "Int"), NumPut(1, RC, 12, "Int")
      DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", SETMARGN, "Ptr", 0, "Ptr", &RC)
      If (TTBC <> "")
         DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", BKGCOLOR, "Ptr", TTBC, "Ptr", 0)
      If (TTTC <> "")
         DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", TXTCOLOR, "Ptr", TTTC, "Ptr", 0)
   }
   If (TTIC <> "")
      DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", SETTITLE, "Ptr", TTIC, "Str", " ")
   If (TTHF) ; font
      DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", 0x0030, "Ptr", TTHF, "Ptr", 1) ; WM_SETFONT
   DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", UPDTIPTX, "Ptr", 0, "Ptr", &TI)
   ; -------------------------------------------------------------------------------------------------------------------
   ; Get the ToolTip window dimensions.
  VarSetCapacity(RC, 16, 0)
  DllCall("User32.dll\GetWindowRect", "Ptr", TTHW, "Ptr", &RC)
  TTRC := {L: NumGet(RC, 0, "Int"), T: NumGet(RC, 4, "Int"), R: NumGet(RC, 8, "Int"), B: NumGet(RC, 12, "Int")}
  TTW := TTRC.R - TTRC.L
  TTH := TTRC.B - TTRC.T
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check if the Tooltip will be partially outside the virtual desktop and adjust the position, if necessary.
  If (PT.X + TTW >= DTW.R)
    PT.X := DTW.R - TTW - 1
  If (PT.Y + TTH >= DTW.B)
    PT.Y := DTW.B - TTH - 1
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check if the cursor is inside the ToolTip window and adjust the position, if necessary.
  If (TTXP = "") || (TTYP = "") {
    TTRC.L := PT.X, TTRC.T := PT.Y, TTRC.R := TTRC.L + TTW, TTRC.B := TTRC.T + TTH
    If (Cursor.X >= TTRC.L) && (Cursor.X <= TTRC.R) && (Cursor.Y >= TTRC.T) && (Cursor.Y <= TTRC.B)
      PT.X := Cursor.X - TTW - 3, PT.Y := Cursor.Y - TTH - 3
  }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Show the Tooltip using the final coordinates.
   DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", TRACKPOS, "Ptr", 0, "Ptr", PT.X | (PT.Y << 16))
   DllCall("User32.dll\SendMessage", "Ptr", TTHW, "UInt", TRACKACT, "Ptr", 1, "Ptr", &TI)
   TT[TTIX].HW := TTHW
  Return TTHW
}

; ======================================================================================================================
; ToolTipG()      Display ToolTips with custom fonts and colors using a GUI.
;                 Code based on just me's ToolTipEx.
; Requires format.ahk, which is distributed with AutoHotkey v2-alpha.
; Tested with:    AHK 1.1.16.05 (U32/U64)
; Tested on:      Win 7 Pro (x64)
; Parameters:
;     Text           -  the text to display in the ToolTip.
;                       If omitted or empty, the ToolTip will be destroyed.
;     X              -  the X position of the ToolTip.
;                       Default: "" (mouse cursor)
;     Y              -  the Y position of the ToolTip.
;                       Default: "" (mouse cursor)
;     WhichToolTip   -  the number of the ToolTip.
;                       Values:  1 - 20
;                       Default: 1
;     Font           -  Font options and name separated by a comma.
;                       Default: none (default GUI font)
;     BgColor        -  the background color of the ToolTip.
;                       Values:  RGB integer value or HTML color name.
;                       Default: "" (default color)
;     TxColor        -  the text color of the ToolTip.
;                       Values:  RGB integer value or HTML color name.
;                       Default: "" (default color)
;     Image          -  not implemented.
;                       Default: "" (no image)
;     CoordMode      -  the coordinate mode for the X and Y parameters, if specified.
;                       Values:  "C" (Client), "S" (Screen), "W" (Window)
;                       Default: "W" (CoordMode, ToolTip, Window)
; Return values:
;     On success: The HWND of the ToolTip window.
;     On failure: False (ErrorLevel contains additional informations)
; ======================================================================================================================
ToolTipG(Text:="", X:="", Y:="", WhichToolTip:=1, Font:="", BgColor:="", TxColor:="", Image:="", CoordMode:="W") {
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check params
   TTTX := Text
   TTXP := X
   TTYP := Y
   TTIX := "ToolTip" (WhichToolTip = "" ? 1 : WhichToolTip)
   TTHF := Font = "" ? "" : StrSplit(Font, ",", " `t")
   TTBC := BgColor
   TTTC := TxColor
   TTIC := Image
   TTCM := CoordMode = "" ? "W" : SubStr(CoordMode, 1, 1)
   If TTXP Is Not Digit
      Return False, ErrorLevel := "Invalid parameter X-position!", False
   If TTYP Is Not Digit
      Return  False, ErrorLevel := "Invalid parameter Y-Position!", False
   If !InStr("CSW", CoordMode)
      Return False, ErrorLevel := "Invalid parameter CoordMode!", False
   ; -------------------------------------------------------------------------------------------------------------------
   ; Destroy the ToolTip window, if Text is empty
   If (TTTX = "") {
      Gui %TTIX%: Destroy
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Save thread settings.
   DHW := A_DetectHiddenWindows
   DetectHiddenWindows On
   LFW := WinExist()
   ; -------------------------------------------------------------------------------------------------------------------
   ; Get the virtual desktop rectangle
   SysGet, X, 76
   SysGet, Y, 77
   SysGet, W, 78
   SysGet, H, 79
   DTW := {L: X, T: Y, R: X + W, B: Y + H}
   ; -------------------------------------------------------------------------------------------------------------------
   ; Initialise the ToolTip coordinates. If either X or Y is empty, use the cursor position for the present.
   PT := {X: 0, Y: 0}
   If (TTXP = "") || (TTYP = "") {
      VarSetCapacity(Cursor, 8, 0)
      DllCall("User32.dll\GetCursorPos", "Ptr", &Cursor)
      Cursor := {X: NumGet(Cursor, 0, "Int"), Y: NumGet(Cursor, 4, "Int")}
      PT := {X: Cursor.X + 16, Y: Cursor.Y + 16}
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; If either X or Y  is specified, get the position of the active window considering CoordMode.
   Origin := {X: 0, Y: 0}
   If ((TTXP <> "") || (TTYP <> "")) && ((TTCM = "W") || (TTCM = "C")) { ; if (*aX || *aY) // Need the offsets.
      HWND := DllCall("User32.dll\GetForegroundWindow", "UPtr")
      If (TTCM = "W") {
         WinGetPos, X, Y, , , ahk_id %HWND%
         Origin := {X: X, Y: Y}
      }
      Else {
         VarSetCapacity(OriginPT, 8, 0)
         DllCall("User32.dll\ClientToScreen", "Ptr", HWND, "Ptr", &OriginPT)
         Origin := {X: NumGet(OriginPT, 0, "Int"), Y: NumGet(OriginPT, 0, "Int")}
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; If either X or Y is specified, use the window related position for this parameter.
   If (TTXP <> "")
      PT.X := TTXP + Origin.X
   If (TTYP <> "")
      PT.Y := TTYP + Origin.Y
   ; -------------------------------------------------------------------------------------------------------------------
   ; If the ToolTip window doesn't exist, create it.
   Gui %TTIX%: +LastFoundExist
   If !TTHW := WinExist() {
      Gui %TTIX%: +AlwaysOnTop +HwndTTHW +ToolWindow -Caption -DPIScale
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Update the text and the font and colors, if specified.
   If (TTBC = "")
      TTBC := format("{1:08x}", DllCall("GetSysColor", "int", 24))
   if (TTTC = "")
      TTTC := format("{1:08x}", DllCall("GetSysColor", "int", 23))
   Gui %TTIX%: Color, %TTTC% ; border
   If (TTIC <> "") {
      ; TODO: Add image
   }
   If (TTHF) ; font
      Gui %TTIX%: Font, % TTHF[1], % TTHF[2]
   ; -------------------------------------------------------------------------------------------------------------------
   ; (Re)create a sub-GUI to simplify text control sizing.
   Gui %TTIX%T: Destroy
   if TTHF
      Gui %TTIX%T: Font, % TTHF[1], % TTHF[2]
   Gui %TTIX%T: +Parent%TTIX% +HwndTTHWT -Caption 
   Gui %TTIX%T: Margin, 3, 2
   Gui %TTIX%T: Color, %TTBC%
   Gui %TTIX%T: Add, Text, c%TTTC%, %TTTX%
   Gui %TTIX%T: Show, NA x1 y1
   ; -------------------------------------------------------------------------------------------------------------------
   ; Get the ToolTip window dimensions.
   VarSetCapacity(RC, 16, 0)
   DllCall("User32.dll\GetWindowRect", "Ptr", TTHWT, "Ptr", &RC)
   TTRC := {L: NumGet(RC, 0, "Int"), T: NumGet(RC, 4, "Int"), R: NumGet(RC, 8, "Int"), B: NumGet(RC, 12, "Int")}
   TTW := TTRC.R - TTRC.L + 2
   TTH := TTRC.B - TTRC.T + 2
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check if the Tooltip will be partially outside the virtual desktop and adjust the position, if necessary.
   If (PT.X + TTW >= DTW.R)
      PT.X := DTW.R - TTW - 1
   If (PT.Y + TTH >= DTW.B)
      PT.Y := DTW.B - TTH - 1
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check if the cursor is inside the ToolTip window and adjust the position, if necessary.
   If (TTXP = "") || (TTYP = "") {
      TTRC.L := PT.X, TTRC.T := PT.Y, TTRC.R := TTRC.L + TTW, TTRC.B := TTRC.T + TTH
      If (Cursor.X >= TTRC.L) && (Cursor.X <= TTRC.R) && (Cursor.Y >= TTRC.T) && (Cursor.Y <= TTRC.B)
         PT.X := Cursor.X - TTW - 3, PT.Y := Cursor.Y - TTH - 3
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Show the Tooltip using the final coordinates.
   Gui %TTIX%: Show, % "NA x" PT.X " y" PT.Y " w" TTW " h" TTH
   ; -------------------------------------------------------------------------------------------------------------------
   ; Restore thread settings.
   WinExist("ahk_id " LFW)
   DetectHiddenWindows %DHW%
   Return TTHW
}

slice(arr, start, end = ""){  ; https://www.autohotkey.com/boards/viewtopic.php?t=76049
  len := arr.Length()
  if(end == "" || end > len)
    end := len
  if(start<arr.MinIndex())
    start := arr.MinIndex()
  if(len<=0 || len < start || start > end)
    return []
    
  ret := []
  start -= 1
  c := end - start
  loop %c%
    ret.push(arr[A_Index + start])
  return ret
}

sortArray( a, o := "A")  ; https://www.autohotkey.com/boards/viewtopic.php?t=60181
{ 
  ; AHK References
  ; https://sites.google.com/site/ahkref/custom-functions/sortarray
    MaxIndex := ObjMaxIndex(a)
    If (o = "R") 
  {
        count := 0
        Loop, % MaxIndex
            ObjInsert( a, ObjRemove( a, MaxIndex - count++))
        Return
    }
    Partitions := "|" ObjMinIndex( a) "," MaxIndex
    Loop 
  {
        comma := InStr( this_partition := SubStr( Partitions, InStr( Partitions, "|", False, 0)+1), ",")
        spos := pivot := SubStr( this_partition, 1, comma-1) 
    epos := SubStr( this_partition, comma+1)
        if (o = "A") 
    {    
            Loop, % epos - spos 
                if (a[pivot] > a[A_Index+spos])
                    ObjInsert(a, pivot++, ObjRemove( a, A_Index+spos))    
        } 
    else 
            Loop, % epos - spos 
                if (a[pivot] < a[A_Index+spos])
                    ObjInsert(a, pivot++, ObjRemove( a, A_Index+spos))    
        Partitions := SubStr( Partitions, 1, InStr( Partitions, "|", False, 0)-1)
        if (pivot - spos) > 1               ;if more than one elements
            Partitions .= "|" spos "," pivot-1        ;the left partition
        if (epos - pivot) > 1               ;if more than one elements
            Partitions .= "|" pivot+1 "," epos        ;the right partition
    } Until !Partitions
}

RestoreClipReturn:
  Clipboard := ClipSaved
return

; https://www.autohotkey.com/docs/v1/scripts/index.htm#HTML_Entities_Encoding
; HTML Entities Encoding
; https://www.autohotkey.com
; Similar to the Transform's HTML sub-command, this function converts a
; string into its HTML equivalent by translating characters whose ASCII
; values are above 127 to their HTML names (e.g. £ becomes &pound;). In
; addition, the four characters "&<> are translated to &quot;&amp;&lt;&gt;.
; Finally, each linefeed (`n) is translated to <br>`n (i.e. <br> followed
; by a linefeed).

; For Unicode executables: In addition of the functionality above, Flags
; can be zero or a combination (sum) of the following values. If omitted,
; it defaults to 1.

; - 1: Converts certain characters to named expressions. e.g. € is
;      converted to &euro;
; - 2: Converts certain characters to numbered expressions. e.g. € is
;      converted to &#8364;

; Only non-ASCII characters are affected. If Flags is the number 3,
; numbered expressions are used only where a named expression is not
; available. The following characters are always converted: <>"& and `n
; (line feed).

EncodeHTML(String, Flags := 1)
{
    SetBatchLines, -1
    static TRANS_HTML_NAMED := 1
    static TRANS_HTML_NUMBERED := 2
    static ansi := ["euro", "#129", "sbquo", "fnof", "bdquo", "hellip", "dagger", "Dagger", "circ", "permil", "Scaron", "lsaquo", "OElig", "#141", "#381", "#143", "#144", "lsquo", "rsquo", "ldquo", "rdquo", "bull", "ndash", "mdash", "tilde", "trade", "scaron", "rsaquo", "oelig", "#157", "#382", "Yuml", "nbsp", "iexcl", "cent", "pound", "curren", "yen", "brvbar", "sect", "uml", "copy", "ordf", "laquo", "not", "shy", "reg", "macr", "deg", "plusmn", "sup2", "sup3", "acute", "micro", "para", "middot", "cedil", "sup1", "ordm", "raquo", "frac14", "frac12", "frac34", "iquest", "Agrave", "Aacute", "Acirc", "Atilde", "Auml", "Aring", "AElig", "Ccedil", "Egrave", "Eacute", "Ecirc", "Euml", "Igrave", "Iacute", "Icirc", "Iuml", "ETH", "Ntilde", "Ograve", "Oacute", "Ocirc", "Otilde", "Ouml", "times", "Oslash", "Ugrave", "Uacute", "Ucirc", "Uuml", "Yacute", "THORN", "szlig", "agrave", "aacute", "acirc", "atilde", "auml", "aring", "aelig", "ccedil", "egrave", "eacute", "ecirc", "euml", "igrave", "iacute", "icirc", "iuml", "eth", "ntilde", "ograve", "oacute", "ocirc", "otilde", "ouml", "divide", "oslash", "ugrave", "uacute", "ucirc", "uuml", "yacute", "thorn", "yuml"]
    static unicode := {0x20AC:1, 0x201A:3, 0x0192:4, 0x201E:5, 0x2026:6, 0x2020:7, 0x2021:8, 0x02C6:9, 0x2030:10, 0x0160:11, 0x2039:12, 0x0152:13, 0x2018:18, 0x2019:19, 0x201C:20, 0x201D:21, 0x2022:22, 0x2013:23, 0x2014:24, 0x02DC:25, 0x2122:26, 0x0161:27, 0x203A:28, 0x0153:29, 0x0178:32}

    if !A_IsUnicode && !(Flags & TRANS_HTML_NAMED)
        throw Exception("Parameter #2 must be omitted or 1 in the ANSI version.", -1)
    
    out  := ""
    for i, char in StrSplit(String)
    {
        code := Asc(char)
        switch code
        {
            case 10: out .= "<br>`n"
            case 34: out .= "&quot;"
            case 38: out .= "&amp;"
            case 60: out .= "&lt;"
            case 62: out .= "&gt;"
            default:
            if (code >= 160 && code <= 255)
            {
                if (Flags & TRANS_HTML_NAMED)
                    out .= "&" ansi[code-127] ";"
                else if (Flags & TRANS_HTML_NUMBERED)
                    out .= "&#" code ";"
                else
                    out .= char
            }
            else if (A_IsUnicode && code > 255)
            {
                if (Flags & TRANS_HTML_NAMED && unicode[code])
                    out .= "&" ansi[unicode[code]] ";"
                else if (Flags & TRANS_HTML_NUMBERED)
                    out .= "&#" code ";"
                else
                    out .= char
            }
            else
            {
                if (code >= 128 && code <= 159)
                    out .= "&" ansi[code-127] ";"
                else
                    out .= char
            }
        }
    }
    return out
}

CopyAll(Timeout:=2500) {
  Timeout := Timeout ? Timeout / 1000 : ""
  global WinClip
  WinClip.Clear()
  send {CtrlDown}a{Ins}{CtrlUp}{Esc}
  ClipWait % Timeout
  return !ErrorLevel
}

IsUrl(text) {
  return ((DoesTextContainUrl(text, v) == 1) && (text == v))
}

DoesTextContainUrl(text, byref v) {
  return RegExMatch(text, "((https?|file):\/\/|www\.)[^ ]+", v)
}

SetModeNormalReturn:
  Vim.State.SetMode("Vim_Normal")
return

DefaultBrowser() {  ; https://www.autohotkey.com/board/topic/84785-default-browser-path-and-executable/
  ; Find the Registry key name for the default browser
  RegRead, BrowserKeyName, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice, Progid

  ; Find the executable command associated with the above Registry key
  RegRead, BrowserFullCommand, HKEY_CLASSES_ROOT, %BrowserKeyName%\shell\open\command

  ; The above RegRead will return the path and executable name of the brower contained within quotes and optional parameters
  ; We only want the text contained inside the first set of quotes which is the path and executable
  ; Find the ending quote position (we know the beginning quote is in position 0 so start searching at position 1)
  StringGetPos, pos, BrowserFullCommand, ",,1

  ; Decrement the found position by one to work correctly with the StringMid function
  pos := --pos

  ; Extract and return the path and executable of the browser
  StringMid, BrowserPathandEXE, BrowserFullCommand, 2, %pos%
  Return BrowserPathandEXE
}

IsWhitespaceOnly(str) {
  return !(str ~= "[\S]")
}

GetAcrobatPageBtn() {
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("ahk_class AcrobatSDIWindow"))
  if (!uiaAcrobatPage := el.FindFirstBy("ControlType=Edit AND Name='Page Number'"))
    uiaAcrobatPage := el.FindFirstByName("AVQuickToolsTopBarCluster").FindByPath("+2")
  return uiaAcrobatPage
}

IsRegExChar(char) {
  return (IfIn(char, ".,+,*,?,^,$,(,),[,],{,},|,\"))
}

GetTimeMSec() {
  return FormatTime(, "yyyy-MM-dd HH:mm:ss:" . A_MSec)
}

GetTimeZone() {
  RegRead, TimeZone, HKEY_LOCAL_MACHINE, SYSTEM\ControlSet001\Control\TimeZoneInformation, TimeZoneKeyName  ; https://www.autohotkey.com/board/topic/43828-finding-correct-time-zone/
  return TimeZone
}

GetDetailedTime() {
  return GetTimeMSec() . ", " . GetTimeZone()
}

/*
  ShellRun by Lexikos
    requires: AutoHotkey v1.1
    license: http://creativecommons.org/publicdomain/zero/1.0/

  Credit for explaining this method goes to BrandonLive:
  http://brandonlive.com/2008/04/27/getting-the-shell-to-run-an-application-for-you-part-2-how/

  Shell.ShellExecute(File [, Arguments, Directory, Operation, Show])
  http://msdn.microsoft.com/en-us/library/windows/desktop/gg537745
*/
ShellRun(prms*)  ; execute without admin privileges
{
    shellWindows := ComObjCreate("Shell.Application").Windows
    VarSetCapacity(_hwnd, 4, 0)
    desktop := shellWindows.FindWindowSW(0, "", 8, ComObj(0x4003, &_hwnd), 1)

    ; Retrieve top-level browser object.
    if ptlb := ComObjQuery(desktop
        , "{4C96BE40-915C-11CF-99D3-00AA004AE837}"  ; SID_STopLevelBrowser
        , "{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser
    {
        ; IShellBrowser.QueryActiveShellView -> IShellView
        if DllCall(NumGet(NumGet(ptlb+0)+15*A_PtrSize), "ptr", ptlb, "ptr*", psv:=0) = 0
        {
            ; Define IID_IDispatch.
            VarSetCapacity(IID_IDispatch, 16)
            NumPut(0x46000000000000C0, NumPut(0x20400, IID_IDispatch, "int64"), "int64")

            ; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
            DllCall(NumGet(NumGet(psv+0)+15*A_PtrSize), "ptr", psv
                , "uint", 0, "ptr", &IID_IDispatch, "ptr*", pdisp:=0)

            ; Get Shell object.
            shell := ComObj(9,pdisp,1).Application

            ; IShellDispatch2.ShellExecute
            shell.ShellExecute(prms*)

            ObjRelease(psv)
        }
        ObjRelease(ptlb)
    }
}

GetCurrTimeForFileName() {
  return RegExReplace(GetTimeMSec(), "[^a-zA-Z0-9\\.\\-]", "_")
}

RunDefaultBrowser() {
  RegExMatch(DefaultBrowser := DefaultBrowser(), ".*\\\K.*$", v)
  if (WinExist("ahk_exe " . v)) {
    WinActivate
    return 1
  } else {
    ShellRun(DefaultBrowser)
    return 2
  }
}

PrepareLatin(word) {
  Word := StrReplace(Word, "ā", "a")
  Word := StrReplace(Word, "ē", "e")
  Word := StrReplace(Word, "ī", "i")
  Word := StrReplace(Word, "ū", "u")
  Word := StrReplace(Word, "ō", "o")
  return word
}
