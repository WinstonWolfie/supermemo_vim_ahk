#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!.::  ; find [...] and insert
  BlockInput, On
  if !(SM.HasTwoComp() && (ControlGetFocus() == "Internet Explorer_Server2")) {
    SM.ExitText()
    SM.EditFirstQuestion(), SM.WaitTextFocus()
  }
  if (SM.IsEditingPlainText()) {
    Send ^a
    if (pos := InStr(Copy(), "[...]")) {
      Send % "{Left}{Right " . pos + 4 . "}"
    } else {
      SetToolTip("Not found.")
      Goto SetModeNormalReturn
    }
  } else if (SM.IsEditingHTML()) {
    if (!SM.HandleF3(1))
      Goto SetModeNormalReturn
    ControlSetText, TEdit1, [...], ahk_class TMyFindDlg
    Send {Enter}
    WinWaitNotActive, ahk_class TMyFindDlg  ; faster than wait for element window to be active
    Send {Right}  ; put caret on the right
    if (!SM.HandleF3(2))
      Goto SetModeNormalReturn
  }
  BlockInput, Off
  Vim.State.SetMode("Insert")
return

^!c::  ; change default *c*oncept group
  SetDefaultKeyboard(0x0409)  ; English-US
  SM.SetDefaultConcept(), Vim.State.SetMode("Vim_Normal")
Return

~^+f12::  ; bomb format with no confirmation
  Send {Enter}
  Vim.State.SetNormal()
return

>!>+BS::  ; for laptop
>^>+BS::  ; for processing pending queue: delete element and keep learning
>!>+\::  ; for laptop
>^>+\::  ; Done! and keep learning
  Vim.State.SetNormal()
  if (IfContains(A_ThisLabel, "\")) {
    Send ^+{Enter}
    WinWaitNotActive, ahk_class TElWind  ; "Do you want to remove all element contents from the collection?"
    Send {Enter}
  } else {
    Send ^+{Del}
  }
  WinWaitActive, ahk_class TMsgDialog  ; wait for "Delete element?" or confirm registry deletion
  Send {Enter}
  WinWaitClose
  SM.WaitFileLoad()
  WinWaitNotActive, ahk_class TElWind,, 0.3
  if (!ErrorLevel)  ; "Warning! The last child of the displayed element has been moved or deleted"
    return
  SM.GoHome()
  SM.WaitFileLoad()
  if (WinActive("ahk_class TElWind"))
    SM.Learn(false, true, true)
return

^!+g::  ; change current element's concept *g*roup
  KeyWait Ctrl
  KeyWait Shift
  KeyWait Alt
  BlockInput, On
  Send ^+p!g  ; open element parameter window and focus to concept group
  WinWaitActive, ahk_class TElParamDlg
  Vim.State.SetMode("Insert"), SetDefaultKeyboard(0x0409)  ; English-US
  OldConcept := ControlGetText("Edit2"), NewConcept := ""
  BlockInput, Off

  WinWaitClose
  Vim.State.SetMode("Vim_Normal")
  if (NewConcept && (A_PriorKey = "Enter")) {
    SM.OpenBrowser()
    WinWait, % wBrowser := "ahk_class TBrowser ahk_pid " . WinGet("PID", "ahk_class TElWind")
    BrowserTitle := WinWaitTitleRegEx("^Subset elements \(\d+ elements\)")
    if (IfContains(BrowserTitle, "(1 elements)")) {
      WinClose, % wBrowser
      return
    }
    if (MsgBox(3,, "Make children this concept too?") = "Yes") {
      WinWaitActive, ahk_class TElWind
      WinActivate, % wBrowser
      WinWaitActive, % wBrowser
      Send {AppsKey}pg
      WinWaitActive, ahk_class TRegistryForm
      ControlSend, Edit1, % "{text}" . NewConcept
      ControlSend, Edit1, {Enter}
      WinWaitActive, ahk_class TMsgDialog
      Send {Enter}
      WinWaitClose
      WinWaitActive, ahk_class TMsgDialog
      WinClose
      WinActivate, ahk_class TBrowser
      Send {Esc}
    } else {
      WinClose, % wBrowser
    }
  }
return

^!t::
  KeyWait Ctrl
  KeyWait Alt
  if (t := SM.IsEditingText()) {
    Send {Right}
    while (Copy())  ; still selecting text
      Sleep 200
  }
  SM.SetTitle(, 1500)
  if (t)
    SwitchToSameWindow("ahk_class TElWind")
return

^+!t::Goto Tag

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind") && SM.DoesHTMLExist())
^!f::  ; use IE's search; discovered by Harvey from the SuperMemo.wiki Discord server
  if (!SM.IsEditingHTML()) {
    SM.EditFirstQuestion()
    ret := SM.WaitTextFocus(3000)
    if (!ret || (ret = "Text"))
      return
  }
  Send {Right}{Left}{Ctrl Down}cf{Ctrl Up}
  WinWaitActive, ahk_class #32770,, 1.5
  if (ErrorLevel)
    return
  Send !c
  if (VimLastSearch)
    SM.EnterAndUpdate("Edit1", VimLastSearch)
  Send !f
  pidSM := WinGet("PID", "ahk_class TElWind")
  SetTimer, RegisterVimLastSearchForSMCtrlAltF, -1
return

RegisterVimLastSearchForSMCtrlAltF:
  while (WinExist("ahk_class #32770 ahk_pid " . pidSM)) {
    if (v := ControlGetText("Edit1"))
      VimLastSearch := v
    Sleep 100
  }
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
~^Enter::
  SetDefaultKeyboard(0x0409)  ; English-US
return

^!p::  ; convert to a *p*lain-text template
^!i::  ; convert to the "item" template
  ContLearn := SM.IsLearning()
  KeyWait Ctrl
  KeyWait Alt
  BlockInput, On
  if (A_ThisLabel == "^!p") {
    Template := "classic"  ; my plain-text template name is classic
  } else if (A_ThisLabel == "^!i") {
    Template := "item"
  }
  SM.SetElParam(,, Template)
  WinWaitClose, ahk_class TElParamDlg
  if (ContLearn == 1)
    SM.learn()
  BlockInput, Off
  MB := MsgBox(3,, "Permanently remove extra components?")
  WinWaitActive, ahk_class TElWind
  BlockInput, On
  if (MB = "Yes") {
    Send ^+{f2}  ; impose template
    WinWaitActive, ahk_class TMsgDialog
    Send {Enter}
    WinWaitClose
    WinWaitActive, ahk_class TMsgDialog
    Send {Enter}
    WinWaitClose
    SM.SetElParam(,, Template)
    WinWaitClose, ahk_class TElParamDlg
    if (ContLearn == 1)
      SM.learn()
  } else if (MB = "Cancel") {
    SM.DetachTemplate()
  }
  BlockInput, Off
  Vim.State.SetMode("Vim_Normal")
return

SMCtrlN:
^n::
  YT := (RegExMatch(Clipboard, "(?:youtube\.com).*?(?:v=)([a-zA-Z0-9_-]{11})", v) && IsUrl(Clipboard))
  if (A_ThisLabel == "^n") {
    Vim.State.SetMode("Vim_Normal")
    if (YT) {
      ClipSaved := ClipboardAll
      Browser.Url := Clipboard
    }
  }
  ; Register browser time stamp to YT comp time stamp
  if (YT && Browser.TimeStamp) {
    WinClip.Clear()
    Clipboard := "{SuperMemoYouTube:" . v1 . "," . Browser.TimeStamp . ",0:00,0:00,3}"
    ClipWait
  }
  SM.CtrlN()
  if (YT) {
    Text := Browser.Title . SM.MakeReference()
    SM.WaitFileLoad()
    SM.EditFirstQuestion()
    SM.WaitTextFocus()
    Send ^a{BS}{Esc}
    SM.WaitTextExit()
    Clip(Text,, false)
    SM.WaitTextFocus()
    SM.WaitFileLoad()
    if (A_ThisLabel == "^n") {
      SM.SetElParam(Browser.Title,, "YouTube")
      SM.Reload(), Browser.Clear()
      SetToolTip("Processing finished.")
    }
  }
  if (YT && (A_ThisLabel == "^n"))
    Clipboard := ClipSaved
return

~^+m::SetDefaultKeyboard(0x0409)  ; English-US

^!m::
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("ahk_class TElWind"))
  if (btn := el.FindFirstBy("ControlType=Button AND Name='Start' AND AutomationId='start'")) {
    btn.Click()
  } else if (btn := el.FindFirstByName("Start: (\d{1,2}\.)?\d{1,2}\.\d{1,2}",, "regex")) {
    btn.Click("left")
  }
  SwitchToSameWindow()  ; refresh caret
return

^!Space::
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("ahk_class TElWind"))
  ; Can't detect pause/play button, sometimes not present on screen
  if (btn := el.FindFirstBy("ControlType=Group AND Name='Video'")) {
    btn.Click()
    btn := el.WaitElementExist("ControlType=Button AND Name='Hide more videos' OR Name='More videos'",,,, 1000)
    if (btn.CurrentName == "Hide more videos")
      btn.Click()
  } else if (btn := el.FindFirstByName("^(\d{1,2}\.)?\d{1,2}\.\d{1,2}$",, "regex")) {
    btn.ControlClick()
  }
  SwitchToSameWindow()  ; refresh caret
return

!+c::
  KeyWait Shift  ; shift always gets stuck
  BlockInput, On
  SM.EditFirstQuestion()
  Send ^t{f9}
  WinWaitActive, ahk_class TScriptEditor,, 1.5
  if (ErrorLevel) {
    BlockInput, Off
    SetToolTip("Script editor not found.")
    return
  }
  Send !c
  WinWaitActive, ahk_class TInputDlg,, 0.3
  if (ErrorLevel) {
    Send {Esc}
    BlockInput, Off
    WinWaitActive, ahk_class TElWind
    SetToolTip("Can't be cloned because this script is the only instance in this collection.")
    return
  }
  Send {Alt Down}oo{Alt Up}{Esc}
  BlockInput, Off
  WinWaitActive, ahk_class TElWind
  SetToolTip("Cloning successful.")
return

; More intuitive inter-element linking, inspired by Obsidian
; 1. Go to the element you want to link to and press Ctrl + Alt + G
; 2. Go to the element you want to have the hyperlink, select text and press Ctrl + Alt + K
^!g::SetToolTip("Copied " . Clipboard := "#" . SM.GetElNumber(, false))

#if (Vim.IsVimGroup() && SM.IsEditingHTML())
^!k::
  KeyWait Ctrl
  KeyWait Alt
  if (Link := IsUrl(Trim(Clipboard))) {
    Link := Clipboard
  } else if (RegExMatch(Clipboard, "^#(\d+)", v)) {
    Link := "SuperMemoElementNo=(" . v1 . ")"
  } else if (Clipboard ~= "^SuperMemoElementNo=\(\d+\)$") {
    Link := Clipboard
  }
  if (!Link || !Copy())  ; no selection or no link
    return
  Send ^k
  UIA := UIA_Interface()
  WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame
  el := UIA.ElementFromHandle(WinActive())
  el.WaitElementExist("ControlType=Edit AND Name='URL: ' AND AutomationId='txtURL'").SetValue(Link)
  Send {Enter}
  WinWaitClose
  Vim.State.SetNormal(), SwitchToSameWindow("ahk_class TElWind")
  Send {Left}
return

^!l::
  ContLearn := SM.IsGrading() ? 1 : SM.IsLearning()
  Item := (ContLearn == 1) ? true : false
  CurrTimeDisplay := GetDetailedTime()
  CurrTimeFileName := RegExReplace(CurrTimeDisplay, ",? |:", "-")
  ClipSaved := ClipboardAll
  KeyWait Alt
  KeyWait Ctrl
  if (!data := Copy(false, true)) {
    Clipboard := ClipSaved
    return
  }
  SetToolTip("LaTeX converting...")
  if (!IfContains(data, "<IMG")) {  ; text
    Send {BS}^{f7}  ; set read point
    LatexFormula := Trim(ProcessLatexFormula(Clipboard), "$")
    ; After almost a year since I wrote this script, I finially figured out this f**ker website encodes the formula twice. Well, I suppose I don't use math that often in SM
    LatexFormula := EncodeDecodeURI(EncodeDecodeURI(LatexFormula))
    LatexLink := "https://latex.vimsky.com/test.image.latex.php?fmt=png&val=%255Cdpi%257B150%257D%2520%255Cbg_white%2520%255Chuge%2520" . LatexFormula . "&dl=1"
    LatexFolderPath := SM.GetCollPath(Text := WinGetText("ahk_class TElWind"))
                     . SM.GetCollName(Text) . "\elements\LaTeX"
    LatexPath := LatexFolderPath . "\" . CurrTimeFileName . ".png"
    InsideHTMLPath := "file:///[PrimaryStorage]LaTeX\" . CurrTimeFileName . ".png"
    SetTimer, DownloadLatex, -1
    FileCreateDir % LatexFolderPath
    LatexPlaceHolder := GetDetailedTime()
    Clip("<img alt=""" . LatexFormula . """ src=""" . InsideHTMLPath . """>" . LatexPlaceHolder,, false, true)
    if (ContLearn == 1) {  ; item and "Show answer"
      Send {Esc}
      SM.WaitTextExit()
    }
    SM.SaveHTML()
    SM.WaitHTMLFocus()
    HTML := FileRead(HTMLPath := SM.LoopForFilePath(false))
    HTML := StrReplace(HTML, LatexPlaceHolder)
    
    /*
      Recommended css setting for anti-merge class:
      .anti-merge {
        position: absolute;
        left: -9999px;
        top: -9999px;
      }
    */
    
    AntiMerge := "<SPAN class=anti-merge>Last LaTeX to image conversion at " . CurrTimeDisplay . "</SPAN>"
    HTML := RegExReplace(HTML, "<SPAN class=anti-merge>Last LaTeX to image conversion at .*?(<\/SPAN>|$)", AntiMerge, v)
    if (!v)
      HTML .= "`n" . AntiMerge
    SM.EmptyHTMLComp()
    WinWaitActive, ahk_class TElWind
    Send ^{Home}
    Clip(HTML,, false, "sm")
    if (ContLearn == 1) {  ; item and "Show answer"
      Send {Esc}
      SM.WaitTextExit()
    }
    SM.SaveHTML()
    if (Item) {
      WinWaitActive, ahk_class TElWind
      Send ^+{f7}  ; clear read point
    }
    Vim.State.SetMode("Vim_Normal")
  } else {  ; image
    Send {BS}  ; otherwise might contain unwanted format
    RegExMatch(data, "alt=""(.*?)""", v)
    if (!v)
      RegExMatch(data, "alt=(.*?) ", v)
    LatexFormula := EncodeDecodeURI(EncodeDecodeURI(v1, false), false)
    LatexFormula := ProcessLatexFormula(LatexFormula)
    RegExMatch(data, "src=""(.*?)""", v)
    if (!v)
      RegExMatch(data, "src=(.*?) ", v)
    LatexPath := StrReplace(v1, "file:///")
    LatexFormula := StrReplace(LatexFormula, "&amp;", "&")
    Clip(LatexFormula, true, false)
    FileDelete % LatexPath
    Vim.State.SetMode("Vim_Visual")
  }
  Clipboard := ClipSaved
return

ProcessLatexFormula(LatexFormula) {
  LatexFormula := RegExReplace(LatexFormula, "{\\(display|text)style |\\(display|text)style{ ?",, v)  ; from Wikipedia, Wikibooks, Better Explained, etc
  if (v)
    LatexFormula := RegExReplace(LatexFormula, "}$")
  LatexFormula := RegExReplace(LatexFormula, "\\\(\\(displaystyle)?",, v)  ; from LibreTexts
  if (v)
    LatexFormula := RegExReplace(LatexFormula, "\)$")
  LatexFormula := StrReplace(LatexFormula, "{\ce ",, v)  ; from Wikipedia's chemistry formulae
  if (v)
    LatexFormula := RegExReplace(LatexFormula, "}$")
  LatexFormula := RegExReplace(LatexFormula, "^\\\[|\\\]$")  ; removing start \[ and end ]\ (in Better Explained)
  LatexFormula := RegExReplace(LatexFormula, "^\\\(|\\\)$")  ; removing start \( and end )\ (in LibreTexts)
  return Trim(LatexFormula)
}

DownloadLatex:
  UrlDownloadToFile, % LatexLink, % LatexPath
return

^!+l::  ; numbered list
  UIA := UIA_Interface(), el := UIA.ElementFromHandle(WinActive("A"))
  el.WaitElementExist("ControlType=TabItem AND Name='Edit'").ControlClick()
  el.WaitElementExist("ControlType=ToolBar AND Name='Format'").FindByPath("19").ControlClick()
  el.WaitElementExist("ControlType=TabItem AND Name='Learn'").ControlClick()
  SwitchToSameWindow(), Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))  ; SuperMemo Plan window
!r::
  if (refresh := SM.IsNavigatingPlan()) {
    Send {Home}{Right}
    x := A_CaretX, y := A_CaretY
    Send {f2}
    WaitCaretMove(x, y)
    Sleep 70
  }
	ControlClick, % "x" . 39 * A_ScreenDPI / 96 . " y" . A_CaretY, A,,,, NA
  if (refresh)
    Send {tab}+{tab}
return

!t::Send !mlt  ; Totals
!d::Send !mld  ; Delays

^b::
^!b::
  CancelAlarm := (A_ThisLabel == "^!b")
  BlockInput, On
  Send !b^s
  BlockInput, Off
  WinWaitActive, Question ahk_class TMsgDialog,, 0.3
  if (!ErrorLevel) {
    Send {text}y
    WinWaitClose
    if (CancelAlarm)
      SM.Command("")
  } else {
    if (CancelAlarm) {
      SM.Command("")
      WinWaitClose, % "ahk_class TCommanderDlg ahk_pid " . WinGet("PID", "ahk_class TElWind")
    }
    WinActivate, ahk_class TPlanDlg
    Send ^s
    return
  }
  WinWaitActive, ahk_class TMsgDialog,, 0.3
  if (!ErrorLevel) {
    WinActivate
    Send {text}y
  }
  WinActivate, ahk_class TPlanDlg
  Send ^s
return

!a::  ; insert/append activity
  SetDefaultKeyboard(0x0409)  ; English-US
  if (WinExist("ahk_id " . SMPlanInsertHwnd)) {
    WinActivate
    return
  }
  Gui, SMPlanInsert:Add, Text,, A&ctivity:
  list := "Break||Game|Code|Sports|Social|Family|Listen|Meal|Rest"
        . "|Plan|Invest|SM|Shower|IM|Piano|Mindful|Job|Misc|Out"
        . "|Sing|Write|Draw|Movie|TV|GF|Music|Sun|Lang|SocMed"
        . "|MP|Tidy|Read|Write|Poker|Video|Watch"
  Gui, SMPlanInsert:Add, Combobox, vActivity gAutoComplete w110, % list
  Gui, SMPlanInsert:Add, Text,, &Time:
  Gui, SMPlanInsert:Add, Edit, vTime w110
  Gui, SMPlanInsert:Add, CheckBox, vNoBackup, Do &not backup
  Gui, SMPlanInsert:Add, CheckBox, vCancelAlarm, Canc&el alarm
  Gui, SMPlanInsert:Add, CheckBox, vSave, &Save
  Gui, SMPlanInsert:Add, Button, default x10 w50 h24, &Insert
  Gui, SMPlanInsert:Add, Button, x+10 w50 h24, &Append
  Gui, SMPlanInsert:Show,, Add Activity
  Gui, SMPlanInsert:+HwndSMPlanInsertHwnd
return

SMPlanInsertGuiEscape:
SMPlanInsertGuiClose:
  Gui, Destroy
return

SMPlanInsertButtonInsert:
SMPlanInsertButtonAppend:
  aTime := StrSplit(CurrTime := FormatTime(, "HH:mm:ss"), ":")
  if (aTime[3] >= 30)
    aTime[2]++
  CurrTime := aTime[1] . ":" . aTime[2]
  Gui, Submit
  Gui, Destroy
  KeyWait Alt
  SwitchToSameWindow("ahk_class TPlanDlg")
  BlockInput, On
  if (A_ThisLabel == "SMPlanInsertButtonInsert") {
    Send ^t  ; split
    WinWaitActive, ahk_class TInputDlg
    Send {Enter}
    WinWaitActive, ahk_class TPlanDlg
  }
  Send {Down}{Ins}  ; inserting one activity below the current selected activity and start editing
  Send % "{text}" . Activity
  if (Time) {
    Send {Enter}
    Send % "{text}" . Time
    Send {Enter}{Up}!b
    WinWaitActive, ahk_class TMsgDialog,, 0.3
    if (!ErrorLevel)
      WinClose, ahk_class TMsgDialog
  } else {
    Send +{tab}
    Send % "{text}" . CurrTime
    Send {Enter}
    WinWaitActive, ahk_class TMsgDialog,, 0.3
    if (!ErrorLevel)
      Send {text}y
  }
  if (Save || (A_ThisLabel == "SMPlanInsertButtonAppend"))
    Send ^s
  if (CancelAlarm)
    SM.Command("")
  if (!NoBackup && IfIn(Activity, "Break,Sports,Out,Shower"))
    try ShellRun("b")  ; my personal backup script
  BlockInput, Off
  Vim.State.SetNormal()
  WinActivate, ahk_class TPlanDlg
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg"))
!+d::ControlClickWinCoordDPIAdjusted(250, 66)
!+s::ControlClickWinCoordDPIAdjusted(173, 67)

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TElParamDlg"))
; Task value script, modified from Naess's priority script
!0::
Numpad0::
NumpadIns::SM.SetRandTaskVal(9024.74,9999)

!1::
Numpad1::
NumpadEnd::SM.SetRandTaskVal(7055.79,9024.74)

!2::
Numpad2::
NumpadDown::SM.SetRandTaskVal(5775.76,7055.78)

!3::
Numpad3::
NumpadPgdn::SM.SetRandTaskVal(4625,5775.75)

!4::
Numpad4::
NumpadLeft::SM.SetRandTaskVal(3721.04,4624)

!5::
Numpad5::
NumpadClear::SM.SetRandTaskVal(2808.86,3721.03)

!6::
Numpad6::
NumpadRight::SM.SetRandTaskVal(1849.18,2808.85)

!7::
Numpad7::
NumpadHome::SM.SetRandTaskVal(841.32,1849.17)

!8::
Numpad8::
NumpadUp::SM.SetRandTaskVal(360.77,841.31)

!9::
Numpad9::
NumpadPgup::SM.SetRandTaskVal(0,360.76)

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TPriorityDlg"))  ; priority window (alt+p)
Enter::
  Prio := ControlGetText("TEdit5", "A")
  if (Prio ~= "^\.")
    ControlSetText, TEdit5, % "0" . Prio
  Send {Enter}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMyFindDlg"))
; So holding ctrl and press f twice could be a shorthand for searching clipboard
^f::
  ControlSetText, TEdit1, % VimLastSearch := Clipboard
  ControlFocus, TEdit1
  ControlClick, TButton3
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsNavigatingPlan())
d::Vim.State.SetMode("Vim_ydc_d", 0, -1, 0,,, -1)
#if (Vim.IsVimGroup() && SM.IsNavigatingPlan() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_d"))
d::
  BlockInput, On
  Vim.State.SetMode("SMPlanDragging")
  MouseGetPos, XCoordSaved, YCoordSaved

  ; Move to the name of current entry
  Send {Home}{Right}

  ; Get current entry coords
  x := A_CaretX, y := A_CaretY
  Send {f2}  ; sometimes A_Caret isn't accurate
  ControlFocusWait("TInplaceEdit1", "A")
  Sleep 70
  Coords := StrSplit(WaitCaretMove(x, y), " ")

  ; Move to the next entry
  Send +{tab}{Down}{Right}
  Coords := StrSplit(WaitCaretMove(Coords[1], IniYCoord := Coords[2]), " ")

  ; Show caret in next entry
  Send {f2}
  ControlFocusWait("TInplaceEdit1", "A")
  Sleep 70
  Coords := StrSplit(WaitCaretMove(Coords[1], Coords[2]), " ")

  ; Calculate entry height
  PlanEntryGap := A_CaretY - IniYCoord
  Send {Up}{Left}  ; go back
  WaitCaretMove(Coords[1], Coords[2])

  ; Move to position
  MouseMove, 20, % IniYCoord + PlanEntryGap / 2, 0
  MouseGetPos, IniXCoord, IniYCoord
  Click Down
  BlockInput, Off
return

#if (Vim.IsVimGroup() && SM.IsNavigatingPlan() && Vim.State.IsCurrentVimMode("SMPlanDragging"))
j::
k::
  if (A_ThisLabel == "j") {
    c := 1
  } else if (A_ThisLabel == "k") {
    c := -1
  }
  MouseMove, 0, % c * Vim.State.GetN() * PlanEntryGap,, R
return

p::
  MouseMove, 0, % PlanEntryGap,, R  ; put after
  Sleep 70  ; wait for SM to update slot position
+p::  ; put before
  Click Up
  MouseGetPos, XCoord, YCoord
  ; If the slot remains in the same place as before, it will be fixed
  if ((XCoord == IniXCoord) && (YCoord == IniYCoord))  ; no change
    Click  ; to unfix
  MouseMove, XCoordSaved, YCoordSaved, 0
  SMPlanDraggingPut := true, Vim.State.SetMode("Vim_Normal")
return

; Incremental video
#if (Vim.State.Vim.Enabled && (((WinActive("ahk_group Browser") || WinActive("ahk_class mpv")) && WinExist("ahk_class TElWind")) || WinActive("ahk_class TElWind")))
^!s::  ; sync time
!+s::  ; sync time but browser tab stays open
^+!s::  ; sync time and keep learning
^!`::  ; clear time
!+`::  ; clear time but browser tab stays open
^+!`::  ; clear time and keep learning
BrowserSyncTime:
  if (A_ThisLabel != "BrowserSyncTime")
    ClipSaved := ClipboardAll
  ResetTime := IfContains(A_ThisLabel, "``")
  CloseWnd := IfContains(A_ThisLabel, "^")  ; hotkeys with ctrl will close the browser tab / mpv
  wPrev := "ahk_id " . WinActive("A")
  hMPV := WinActive("ahk_class mpv"), wMPV := "ahk_id " . hMPV
  hBrowser := WinActive("ahk_group Browser"), wBrowser := "ahk_id " . hBrowser
  wSMElWind := "ahk_class TElWind", SMTemplCode := ""
  KeyWait Ctrl
  KeyWait Alt
  KeyWait Shift

  if (hBrowser) {
    Browser.Clear()
    Browser.FullTitle := Browser.GetFullTitle(wBrowser)

    if (Browser.FullTitle != "Netflix")
      ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Esc}, % wBrowser

    if (!ResetTime)
      Browser.TimeStamp := Browser.GetTimeStamp(Browser.FullTitle,, false)
    Browser.GetInfo(false, false,,, false, false)  ; need url and title here
    
    if (w := SM.FindMatchTitleColl(Browser.Title))
      wSMElWind := w

    while (!SMTemplCode) {
      SMTemplCode := SM.GetTemplCode(false, wSMElWind, 1.5)
      sleep 700
    }
    CurrSMUrl := SM.GetLink(SMTemplCode)
    ret := SM.AskToSearchLink(Browser.Url, CurrSMUrl, wSMElWind)
    if (ret == 0) {
      Goto SMSyncTimeReturn
    } else if (ret == -1) {
      SMTemplCode := ""
    }
  }

  if (hMPV && !ResetTime) {
    if (Browser.TimeStamp := Copy(,,, 1.5)) {
      Browser.TimeStamp := RegExReplace(Browser.TimeStamp, "^00:")
      Browser.TimeStamp := RegExReplace(Browser.TimeStamp, "^0(?=\d)")
      Browser.TimeStamp := RegExReplace(Browser.TimeStamp, "\..*")
    } else {
      SetToolTip("mpv-copyTime script not installed or timed out.")
    }
  }

  if (!Browser.TimeStamp && !ResetTime) {
    SetDefaultKeyboard(0x0409)  ; English-US
    if ((!Browser.TimeStamp := InputBox(, "Enter time stamp:")) || ErrorLevel)
      Goto SMSyncTimeReturn
  }

  if (hBrowser && CloseWnd) {
    WinActivate % wBrowser
    ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Ctrl Down}w{Ctrl Up}, % wBrowser
  }

  if (hMPV && CloseWnd && !ResetTime) {
    ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Shift Down}q{Shift Up}, % wMPV
  } else if (hMPV && CloseWnd && ResetTime) {
    ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}q, % wMPV
  }

  SM.CloseMsgDialog()
  if (ResetTime)
    Browser.TimeStamp := "0:00"

  EditHTML := EditScript := false
  if (hMPV) {
    EditHTML := true
  } else {
    if (!SMTemplCode)
      SMTemplCode := SM.GetTemplCode(false, wSMElWind)
    RegExMatch(SMTemplCode, "ScriptFile=\K.*", ScriptPath) 
    UrlInScript := RegExReplace(FileRead(ScriptPath), "^url ")
    if (NewUrl := Browser.TimeStampToUrl(UrlInScript, Browser.TimeStamp)) {
      EditScript := true
    } else {
      EditHTML := true
    }
  }

  if (EditHTML) {
    WinActivate, % wSMElWind
    SM.EditFirstQuestion()
    auiaText := SM.GetTextArray()
    Marker := SM.GetMarkerFromTextArray(auiaText)
    NewTimeStamp := "<SPAN class=Highlight>SMVim time stamp</SPAN>: " . Browser.TimeStamp
    if (Marker != RegExReplace(NewTimeStamp, "<.*?>")) {
      SM.WaitTextFocus()
      Send ^{Home}
      if (Marker ~= "^SMVim time stamp: ") {
        Send ^{Right 4}
        Send % "+{Right " . StrLen(RegExReplace(Marker, "^SMVim time stamp: ")) . "}"
        Send % "{text}" . Browser.TimeStamp
      } else {
        if (!SM.IsHTMLEmpty(auiaText))
          Send {Enter}{Up}
        Clip(NewTimeStamp,, false, "sm")
      }
    }
    SM.ExitText()
  }

SMSyncTimeReturn:
  if (A_ThisLabel ~= "^(!\+(s|`)|SMSyncTimeReturn)$") {
    WinActivate % wPrev
  } else if (IfContains(A_ThisLabel, "^!,^+!")) {
    WinActivate % wSMElWind
  }

  if (EditScript && (A_ThisLabel != "SMSyncTimeReturn")) {
    if (NewUrl == UrlInScript) {
      SetToolTip("No change.")
    } else {
      FileDelete, % ScriptPath
      FileAppend, % "url " . NewUrl, % ScriptPath
      SetToolTip("Time stamp in script component set as " . Browser.TimeStamp)
    }
  }

  if (IfContains(A_ThisLabel, "^+!"))
    SM.Learn(false, true, true, wSMElWind)
  Browser.Clear(), Clipboard := ClipSaved
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
!s::
  if ((p := SM.GetMarkerFromTextArray()) && (p ~= "^SMVim (read point|page mark|time stamp): ")) {
    SetToolTip("Copied " . Clipboard := RegExReplace(p, "^SMVim (read point|page mark|time stamp): "))
  } else {
    KeyWait Alt
    Send !s
    Vim.State.SetMode("Insert")
  }
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle() ~= "^Concept Registry \(\d+ members\)"))
!p::ControlFocus, TEdit1  ; set priority for current selected concept in registry window
!i::Acc_Get("Object", "4.6.4.3.4.9.4").accDoDefaultAction()  ; default item template
!t::Acc_Get("Object", "4.6.4.3.4.10.4").accDoDefaultAction()  ; default topic template

^l::
  SM.RegAltG()
  WinWaitActive, ahk_class TElWind
  Goto SMLearnChildren
return

^n::
  SM.RegAltG()
  WinWaitActive, ahk_class TElWind
  Goto SMNeuralReviewChildren
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle() ~= "^Reference Registry \(\d+ members\)"))
!i::SM.RegInsert()

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle() ~= "^.*? Registry \(\d+ members\)"))
!g::SM.RegAltG(), Vim.State.SetNormal()

^l::
  Send !b
  WinWaitActive, ahk_class TBrowser
  Goto SMLearnChildrenActiveBrowser
return

~!n::
  WinWaitActive, ahk_class TElWind,, 1
  SM.PlayIfOnlineColl()
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg"))
; Use English input method for choosing concept when import
~!g::SetDefaultKeyboard(0x0409)  ; English-US

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMsgDialog"))
y::Send {text}y
n::Send {text}n

#if (Vim.IsVimGroup() && SM.IsEditingText())
^/::Send {Home}//{Space}
+!a::Send /*  */{Left 3}
^+!a::Send /*{Enter 2}*/{Up}
^!+h::Send {text}==================================================
^+k::SM.RegMember()

!+d::
  SM.CtrlF3()
  WinWaitActive, ahk_class TInputDlg
  Send {Enter}
  WinWaitActive, ahk_class TChoicesDlg
  Send {Enter}
  WinWaitActive, ahk_class TBrowser
  SM.ClearHighlight()
  WinActivate, ahk_class TBrowser
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TElParamDlg") && OldConcept)
Enter::
  NewConcept := ControlGetText("Edit2")
  Send {Enter}
return
