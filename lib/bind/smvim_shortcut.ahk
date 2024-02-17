#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!.::  ; find [...] and insert
  BlockInput, On
  if !(Vim.SM.HasTwoComp() && (ControlGetFocus() == "Internet Explorer_Server2")) {
    Vim.SM.ExitText()
    Vim.SM.EditFirstQuestion(), Vim.SM.WaitTextFocus()
  }
  if (Vim.SM.IsEditingPlainText()) {
    Send ^a
    if (pos := InStr(Copy(), "[...]")) {
      Send % "{left}{right " . pos + 4 . "}"
    } else {
      Vim.State.SetToolTip("Not found.")
      Goto SetModeNormalReturn
    }
  } else if (Vim.SM.IsEditingHTML()) {
    if (!Vim.SM.HandleF3(1))
      Goto SetModeNormalReturn
    ControlSetText, TEdit1, [...], ahk_class TMyFindDlg
    Send {enter}
    WinWaitNotActive, ahk_class TMyFindDlg  ; faster than wait for element window to be active
    Send {right}  ; put caret on the right
    if (!Vim.SM.HandleF3(2))
      Goto SetModeNormalReturn
  }
  BlockInput, Off
  Vim.State.SetMode("Insert")
return

^!c::  ; change default *c*oncept group
  SetDefaultKeyboard(0x0409)  ; English-US
  Vim.SM.SetCurrConcept(), Vim.State.SetMode("Vim_Normal")
Return

~^+f12::  ; bomb format with no confirmation
  Send {enter}
  Vim.State.SetNormal()
return

>!>+BS::  ; for laptop
>^>+BS::  ; for processing pending queue Advanced English 2018: delete element and keep learning
>!>+\::  ; for laptop
>^>+\::  ; Done! and keep learning
  Vim.State.SetNormal()
  if (IfContains(A_ThisLabel, "\")) {
    Send ^+{enter}
    WinWaitNotActive, ahk_class TElWind  ; "Do you want to remove all element contents from the collection?"
    Send {enter}
  } else {
    Send ^+{del}
  }
  WinWaitActive, ahk_class TMsgDialog  ; wait for "Delete element?" or confirm registry deletion
  Send {enter}
  WinWaitClose
  Vim.SM.WaitFileLoad()
  WinWaitNotActive, ahk_class TElWind,, 0.3
  if (!ErrorLevel)  ; "Warning! The last child of the displayed element has been moved or deleted"
    return
  Vim.SM.GoHome()
  Vim.SM.WaitFileLoad()
  if (WinActive("ahk_class TElWind"))
    Vim.SM.Learn(false, true)
return

^!+g::  ; change element's concept *g*roup
  Vim.State.SetMode("Insert")
  SetDefaultKeyboard(0x0409)  ; English-US
  KeyWait Ctrl
  KeyWait Shift
  KeyWait Alt
  Send ^+p!g  ; focus to concept group
  WinWaitActive, ahk_class TElParamDlg
  OldConcept := ControlGetText("Edit2"), NewConcept := ""
  WinWaitNotActive
  if (NewConcept && (OldConcept != NewConcept)) {
    if (MsgBox(3,, "Make children this concept too?") = "yes") {
      WinWaitActive, ahk_class TElWind
      Send !c
      WinWaitActive, ahk_class TContents
      Vim.SM.OpenBrowser()
      WinWaitActive, ahk_class TBrowser
      Send {AppsKey}pg
      WinWaitActive, ahk_class TRegistryForm
      ControlSend, Edit1, % "{text}" . NewConcept
      ControlSend, Edit1, {enter}
      WinWaitActive, ahk_class TMsgDialog
      Send {enter}
      WinWaitClose
      WinWaitActive, ahk_class TMsgDialog
      WinClose
      WinActivate, ahk_class TBrowser
      Send {Esc}
    }
  }
  OldConcept := NewConcept := ""
  Vim.State.SetMode("Vim_Normal")
return

^!t::
  KeyWait Ctrl
  KeyWait Alt
  if (t := Vim.SM.IsEditingText()) {
    Send {right}
    while (Copy())  ; still selecting text
      Sleep 200
  }
  Vim.SM.SetTitle(, 1500)
  if (t)
    Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
return

^+!t::Goto Tag

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind") && Vim.SM.DoesHTMLExist())
^!f::  ; use IE's search
  pidSM := WinGet("PID", "A")
  Send ^t
  Vim.SM.WaitHTMLFocus()
  if (Vim.SM.IsEditingHTML())
    Send {right}{left}{Ctrl Down}cf{Ctrl Up}  ; discovered by Harvey from the SuperMemo.wiki Discord server
  WinWaitActive, ahk_class #32770,, 1.5
  if (ErrorLevel)
    return
  Send !c
  if (VimLastSearch) {
    ControlSetText, Edit1, % SubStr(VimLastSearch, 2)
    ControlSend, Edit1, % "{text}" . SubStr(VimLastSearch, 1, 1)
  }
  Send !f
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
  ContLearn := Vim.SM.IsLearning()
  KeyWait Ctrl
  KeyWait Alt
  BlockInput, On
  if (A_ThisLabel == "^!p") {
    Template := "classic"  ; my plain-text template name is classic
  } else if (A_ThisLabel == "^!i") {
    Template := "item"
  }
  Vim.SM.SetElParam(,, Template)
  WinWaitClose, ahk_class TElParamDlg
  if (ContLearn == 1)
    Vim.SM.learn()
  BlockInput, Off
  MB := MsgBox(3,, "Permanently remove extra components?")
  WinWaitActive, ahk_class TElWind
  BlockInput, On
  if (MB = "yes") {
    Send ^+{f2}  ; impose template
    WinWaitActive, ahk_class TMsgDialog
    Send {enter}
    WinWaitClose
    WinWaitActive, ahk_class TMsgDialog
    Send {enter}
    WinWaitClose
    Vim.SM.SetElParam(,, Template)
    WinWaitClose, ahk_class TElParamDlg
    if (ContLearn == 1)
      Vim.SM.learn()
  } else if (MB = "cancel") {
    Vim.SM.DetachTemplate()
  }
  BlockInput, Off
  Vim.State.SetMode("Vim_Normal")
return

SMCtrlN:
^n::
  Vim.SM.CtrlN(), Vim.State.SetMode("Vim_Normal")
  if (RegExMatch(Clipboard, "(?:youtube\.com).*?(?:v=)([a-zA-Z0-9_-]{11})", v) && IsUrl(Clipboard)) {
    if (A_ThisLabel == "^n")
      ClipSaved := ClipboardAll
    Vim.Browser.Url := Clipboard
    ; Register browser time stamp to YT comp time stamp
    if (Vim.Browser.TimeStamp)
      Clipboard := "{SuperMemoYouTube:" . v1 . "," . Vim.Browser.TimeStamp . ",0:00,0:00,3}"
    text := Vim.Browser.Title . Vim.SM.MakeReference()
    Vim.SM.WaitFileLoad()
    Vim.SM.EditFirstQuestion()
    Vim.SM.WaitTextFocus()
    Send ^a{BS}{Esc}
    Vim.SM.WaitTextExit()
    Clip(text,, false)
    Vim.SM.WaitTextFocus()
    if (A_ThisLabel == "^n") {
      Vim.SM.SetElParam(Vim.Browser.Title,, "YouTube")
      Vim.Browser.Clear(), Clipboard := ClipSaved
    }
  }
return

~^+m::SetDefaultKeyboard(0x0409)  ; English-US

^!m::
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("ahk_class TElWind"))
  if (btn := el.FindFirstBy("ControlType=Button AND Name='Start' AND AutomationId='start'")) {
    btn.Click()
    Vim.Caret.SwitchToSameWindow()  ; refresh caret
  } else if (btn := el.FindFirstByName("Start: (\d{1,2}\.)?\d{1,2}\.\d{1,2}",, "regex")) {
    btn.Click("left")
  }
return

^!space::
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("ahk_class TElWind"))
  ; Can't detect pause/play button, sometimes not present on screen
  if (btn := el.FindFirstBy("ControlType=Group AND Name='Video'")) {
    btn.Click()
    btn := el.WaitElementExist("ControlType=Button AND Name='Hide more videos' OR Name='More videos'",,,, 1000)
    if (btn.CurrentName == "Hide more videos")
      btn.Click()
    Vim.Caret.SwitchToSameWindow()  ; refresh caret
  } else if (btn := el.FindFirstByName("^(\d{1,2}\.)?\d{1,2}\.\d{1,2}$",, "regex")) {
    btn.ControlClick()
  }
return

!+c::
  KeyWait Shift  ; shift always gets stuck
  BlockInput, On
  Vim.SM.EditFirstQuestion()
  Send ^t{f9}
  WinWaitActive, ahk_class TScriptEditor,, 1.5
  if (ErrorLevel) {
    BlockInput, Off
    Vim.State.SetToolTip("Script editor not found.")
    return
  }
  Send !c
  WinWaitActive, ahk_class TInputDlg,, 0.3
  if (ErrorLevel) {
    Send {Esc}
    BlockInput, Off
    WinWaitActive, ahk_class TElWind
    Vim.State.SetToolTip("Can't be cloned because this script is the only instance in this collection.")
    return
  }
  Send {Alt Down}oo{Alt Up}{Esc}
  BlockInput, Off
  WinWaitActive, ahk_class TElWind
  Vim.State.SetToolTip("Cloning successful.")
return

; More intuitive inter-element linking, inspired by Obsidian
; 1. Go to the element you want to link to and press Ctrl + Alt + G
; 2. Go to the element you want to have the hyperlink, select text and press Ctrl + Alt + K
^!g::Vim.State.SetToolTip("Copied " . Clipboard := "#" . Vim.SM.GetElNumber(, false))

#if (Vim.IsVimGroup() && Vim.SM.IsEditingHTML())
^!k::
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
  WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("ahk_class Internet Explorer_TridentDlgFrame"))
  el.WaitElementExist("ControlType=Edit AND Name='URL: ' AND AutomationId='txtURL'").SetValue(Link)
  Send {enter}
  WinWaitClose
  Vim.State.SetNormal(), Vim.Caret.SwitchToSameWindow()
  Send {left}
return

^!l::
  ContLearn := Vim.SM.IsGrading() ? 1 : Vim.SM.IsLearning()
  Item := (ContLearn == 1) ? true : false
  CurrTimeDisplay := GetDetailedTime()
  CurrTimeFileName := RegExReplace(CurrTimeDisplay, ",? |:", "-")
  ClipSaved := ClipboardAll
  KeyWait Alt
  KeyWait Ctrl
  if (!data := Copy(false, true))
    Goto RestoreClipReturn
  Vim.State.SetToolTip("LaTeX converting...")
  if (!IfContains(data, "<IMG")) {  ; text
    Send {BS}^{f7}  ; set read point
    LatexFormula := Trim(ProcessLatexFormula(Clipboard), "$")
    ; After almost a year since I wrote this script, I finially figured out this f**ker website encodes the formula twice. Well, I suppose I don't use math that often in SM
    LatexFormula := EncodeDecodeURI(EncodeDecodeURI(LatexFormula))
    LatexLink := "https://latex.vimsky.com/test.image.latex.php?fmt=png&val=%255Cdpi%257B150%257D%2520%255Cbg_white%2520%255Chuge%2520" . LatexFormula . "&dl=1"
    LatexFolderPath := Vim.SM.GetCollPath(text := WinGetText("ahk_class TElWind"))
                     . Vim.SM.GetCollName(text) . "\elements\LaTeX"
    LatexPath := LatexFolderPath . "\" . CurrTimeFileName . ".png"
    InsideHTMLPath := "file:///[PrimaryStorage]LaTeX\" . CurrTimeFileName . ".png"
    SetTimer, DownloadLatex, -1
    FileCreateDir % LatexFolderPath
    LatexPlaceHolder := GetDetailedTime()
    Clip("<img alt=""" . LatexFormula . """ src=""" . InsideHTMLPath . """>" . LatexPlaceHolder,, false, true)
    if (ContLearn == 1) {  ; item and "Show answer"
      Send {Esc}
      Vim.SM.WaitTextExit()
    }
    Vim.SM.SaveHTML()
    Vim.SM.WaitHTMLFocus()
    HTML := FileRead(HTMLPath := Vim.SM.LoopForFilePath(false))
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
    Vim.SM.EmptyHTMLComp()
    WinWaitActive, ahk_class TElWind
    Send ^{home}
    Clip(HTML,, false, "sm")
    if (ContLearn == 1) {  ; item and "Show answer"
      Send {Esc}
      Vim.SM.WaitTextExit()
    }
    Vim.SM.SaveHTML()
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
  Vim.Caret.SwitchToSameWindow(), Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))  ; SuperMemo Plan window
!r::
  if (refresh := Vim.SM.IsNavigatingPlan()) {
    Send {home}{right}
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
      Vim.SM.Command("")
  } else {
    if (CancelAlarm) {
      Vim.SM.Command("")
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
        . "|Plan|Invest|SM|Shower|IM|Piano|Medit|Job|Misc|Out"
        . "|Sing|Write|Draw|Movie|TV|GF|Music|Sun|Lang|SocMed"
        . "|MP|Tidy|Read|Write|Poker|Video"
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
  Vim.Caret.SwitchToSameWindow("ahk_class TPlanDlg")
  BlockInput, On
  if (A_ThisLabel == "SMPlanInsertButtonInsert") {
    Send ^t  ; split
    WinWaitActive, ahk_class TInputDlg
    Send {enter}
    WinWaitActive, ahk_class TPlanDlg
  }
  Send {down}{ins}  ; inserting one activity below the current selected activity and start editing
  Send % "{text}" . Activity
  if (Time) {
    Send {enter}
    Send % "{text}" . Time
    Send {enter}{up}!b
    WinWaitActive, ahk_class TMsgDialog,, 0.3
    if (!ErrorLevel)
      WinClose, ahk_class TMsgDialog
  } else {
    Send +{tab}
    Send % "{text}" . CurrTime
    Send {enter}
    WinWaitActive, ahk_class TMsgDialog,, 0.3
    if (!ErrorLevel)
      Send {text}y
  }
  if (Save || (A_ThisLabel == "SMPlanInsertButtonAppend"))
    Send ^s
  if (CancelAlarm)
    Vim.SM.Command("")
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
NumpadIns::Vim.SM.SetRandTaskVal(9024.74,9999)

!1::
Numpad1::
NumpadEnd::Vim.SM.SetRandTaskVal(7055.79,9024.74)

!2::
Numpad2::
NumpadDown::Vim.SM.SetRandTaskVal(5775.76,7055.78)

!3::
Numpad3::
NumpadPgdn::Vim.SM.SetRandTaskVal(4625,5775.75)

!4::
Numpad4::
NumpadLeft::Vim.SM.SetRandTaskVal(3721.04,4624)

!5::
Numpad5::
NumpadClear::Vim.SM.SetRandTaskVal(2808.86,3721.03)

!6::
Numpad6::
NumpadRight::Vim.SM.SetRandTaskVal(1849.18,2808.85)

!7::
Numpad7::
NumpadHome::Vim.SM.SetRandTaskVal(841.32,1849.17)

!8::
Numpad8::
NumpadUp::Vim.SM.SetRandTaskVal(360.77,841.31)

!9::
Numpad9::
NumpadPgup::Vim.SM.SetRandTaskVal(0,360.76)

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TPriorityDlg"))  ; priority window (alt+p)
Enter::
  Prio := ControlGetText("TEdit5", "A")
  if (Prio ~= "^\.")
    ControlSetText, TEdit5, % "0" . Prio
  Send {enter}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMyFindDlg"))
; So holding ctrl and press f twice could be a shorthand for searching clipboard
^f::
  ControlSetText, TEdit1, % VimLastSearch := Clipboard
  ControlFocus, TEdit1
  ControlClick, TButton3
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingPlan())
d::Vim.State.SetMode("Vim_ydc_d", 0, -1, 0,,, -1)
#if (Vim.IsVimGroup() && Vim.SM.IsNavigatingPlan() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_d"))
d::
  BlockInput, On
  Vim.State.SetMode("SMPlanDragging")
  MouseGetPos, XCoordSaved, YCoordSaved

  ; Move to the name of current entry
  Send {home}{right}

  ; Get current entry coords
  x := A_CaretX, y := A_CaretY
  Send {f2}  ; sometimes A_Caret isn't accurate
  ControlFocusWait("TInplaceEdit1", "A")
  Sleep 70
  Coords := StrSplit(WaitCaretMove(x, y), " ")

  ; Move to the next entry
  Send +{tab}{down}{right}
  Coords := StrSplit(WaitCaretMove(Coords[1], IniYCoord := Coords[2]), " ")

  ; Show caret in next entry
  Send {f2}
  ControlFocusWait("TInplaceEdit1", "A")
  Sleep 70
  Coords := StrSplit(WaitCaretMove(Coords[1], Coords[2]), " ")

  ; Calculate entry height
  PlanEntryGap := A_CaretY - IniYCoord
  Send {up}{left}  ; go back
  WaitCaretMove(Coords[1], Coords[2])

  ; Move to position
  MouseMove, 20, % IniYCoord + PlanEntryGap / 2, 0
  MouseGetPos, IniXCoord, IniYCoord
  Click Down
  BlockInput, Off
return

#if (Vim.IsVimGroup() && Vim.SM.IsNavigatingPlan() && Vim.State.IsCurrentVimMode("SMPlanDragging"))
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
  Sync := (A_ThisLabel == "BrowserSyncTime")
  ResetTime := IfContains(A_ThisLabel, "``")
  CloseWnd := IfContains(A_ThisLabel, "^")  ; hotkeys with ctrl will close the browser tab / mpv
  hMPV := WinActive("ahk_class mpv"), wMPV := "ahk_id " . hMPV
  hSMElWind := SMTemplCode := wBrowser := ""

  if (hBrowser := WinActive("ahk_group Browser")) {
    Vim.Browser.Clear(), wBrowser := "ahk_id " . hBrowser
    Vim.Browser.FullTitle := Vim.Browser.GetFullTitle(wBrowser)
    if (Vim.Browser.FullTitle != "Netflix")
      ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Esc}, % wBrowser
    Vim.Browser.GetTitleSourceDate(!Sync, false,,, false, false)  ; need url and title here
    WinGet, pahSMElWind, List, ahk_class TElWind
    loop % pahSMElWind {
      SMTitle := WinGetTitle("ahk_id " . hWnd := pahSMElWind%A_Index%)
      ; SM uses "." instead of "..." in titles
      if (SMTitle == RegExReplace(Vim.Browser.Title, "\.\.\.?", ".")) {
        hSMElWind := hWnd
        Break
      }
    }
  }

  wSMElWind := hSMElWind ? "ahk_id " . hSMElWind : "ahk_class TElWind"

  if (hBrowser) {
    if (Vim.Browser.FullTitle == "Netflix")
      Vim.Browser.TimeStamp := Vim.Browser.GetTimeStamp(Vim.Browser.FullTitle,, !Sync)
    SMUrl := Vim.SM.GetLink(SMTemplCode := Vim.SM.GetTemplCode(!Sync, wSMElWind))
    Vim.Browser.Url := Vim.SM.HTMLUrl2SMRefUrl(Vim.Browser.Url)
    if (Vim.Browser.Url != SMUrl) {
      SMTemplCode := ""
      if (!Vim.SM.AskToSearchLink(Vim.Browser.Url, SMUrl, wSMElWind))
        Goto SMSyncTimeReturn
    }
    if (!ResetTime && !Vim.Browser.TimeStamp)
      Vim.Browser.TimeStamp := Vim.Browser.GetTimeStamp(Vim.Browser.FullTitle,, !Sync)
  }

  if (hMPV && !ResetTime) {
    if (Vim.Browser.TimeStamp := Copy(,,, 1)) {
      Vim.Browser.TimeStamp := RegExReplace(Vim.Browser.TimeStamp, "^00:")
      Vim.Browser.TimeStamp := RegExReplace(Vim.Browser.TimeStamp, "^0(?=\d)")
      Vim.Browser.TimeStamp := RegExReplace(Vim.Browser.TimeStamp, "\..*")
    } else {
      Vim.State.SetToolTip("mpv-copyTime script not installed or timed out.")
    }
  }

  if (!Vim.Browser.TimeStamp && !ResetTime) {
    SetDefaultKeyboard(0x0409)  ; English-US
    if ((!Vim.Browser.TimeStamp := InputBox("Time Stamp", "Enter time stamp.")) || ErrorLevel)
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

  Vim.SM.CloseMsgDialog()
  if (ResetTime)
    Vim.Browser.TimeStamp := "0:00"

  if (!hMPV) {
    if (!SMTemplCode)
      SMTemplCode := Vim.SM.GetTemplCode(!Sync, wSMElWind)
    RegExMatch(SMTemplCode, "ScriptFile=\K.*", ScriptPath) 
    Script := FileRead(ScriptPath)
    Sec := Vim.Browser.GetSecFromTime(Vim.Browser.TimeStamp)
  } else {
    Script := ""
  }

  EditScript := True
  if (IfContains(Script, "bilibili.com")) {
    if (Script ~= "\?p=\d+") {
      Match := "&t=.*", Replacement := "&t=" . Sec
    } else {
      Match := "\?t=.*", Replacement := "?t=" . Sec
    }
  } else if (IfContains(Script, "youtube.com")) {
    Match := "&t=.*s", Replacement := "&t=" . Sec . "s"
  } else {
    EditScript := False
    WinActivate, % wSMElWind
    Vim.SM.EditFirstQuestion()
    OldText := Vim.SM.GetMarkerFromTextArray()
    NewText := "<SPAN class=Highlight>SMVim time stamp</SPAN>: " . Vim.Browser.TimeStamp
    if (OldText != RegExReplace(NewText, "<.*?>")) {
      Vim.SM.WaitTextFocus()
      Send ^{home}
      if (OldText ~= "^SMVim time stamp: ") {
        Send ^{right 4}
        Send % "+{right " . StrLen(RegExReplace(OldText, "^SMVim time stamp: ")) . "}"
        Send % "{text}" . Vim.Browser.TimeStamp
      } else if (OldText) {
        Send {enter}{up}
        Clip(NewText,, !Sync, "sm")
      }
    }
    Send {Esc}
  }

SMSyncTimeReturn:
  if (IfContains(A_ThisLabel, "^+!")) {
    Vim.SM.Learn(false,, true)
  } else if (wBrowser && ((A_ThisLabel == "SMSyncTimeReturn") || (A_ThisLabel ~= "\!\+(s|`)"))) {  ; keep browser tab open
    WinActivate % wBrowser
  } else if (wMPV && (A_ThisLabel ~= "\!\+(s|`)")) {
    WinActivate % wMPV
  } else if (IfContains(A_ThisLabel, "^!")) {
    WinActivate % wSMElWind
  }

  if (EditScript) {
    FileDelete, % ScriptPath
    FileAppend, % RegExReplace(Script, Match . "|$", Replacement,, 1), % ScriptPath
    if (A_ThisLabel != "SMSyncTimeReturn")
      Vim.State.SetToolTip("Time stamp in script component set as " . Sec . "s")
  }

  Vim.Browser.Clear()
  if (Sync)
    Clipboard := ClipSaved
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
!s::
  if ((p := Vim.SM.GetMarkerFromTextArray()) && (p ~= "SMVim (read point|page mark|time stamp): ")) {
    Vim.State.SetToolTip("Copied " . Clipboard := RegExReplace(p, "SMVim (read point|page mark|time stamp): "))
  } else {
    KeyWait Alt
    Send !s
    Vim.State.SetMode("Insert")
  }
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle("A") ~= "^Concept Registry \(\d+ members\)"))
!p::ControlFocus, TEdit1  ; set priority for current selected concept in registry window
!i::Acc_Get("Object", "4.6.4.3.4.9.4",, "A").accDoDefaultAction()  ; default item template
!t::Acc_Get("Object", "4.6.4.3.4.10.4",, "A").accDoDefaultAction()  ; default topic template

^l::
  Gosub SMRegAltG
  WinWaitActive, ahk_class TElWind
  Goto SMLearnChild
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle("A") ~= "^Reference Registry \(\d+ members\)"))
!i::Acc_Get("Object", "4.5.4.8.4",, "A").accDoDefaultAction()

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle("A") ~= "^.*? Registry \(\d+ members\)"))
SMRegAltG:
!g::
  Acc_Get("Object", "4.5.4.2.4",, "A").accDoDefaultAction()
  WinWaitActive, ahk_class TElWind,, 1.5
  if (!ErrorLevel)
    Vim.State.SetMode("Vim_Normal")
return

^l::
  Send !b
  WinWaitActive, ahk_class TBrowser
  Goto SMLearnChildActiveBrowser
return

~!n::
  WinWaitActive, ahk_class TElWind,, 1
  Vim.SM.PlayIfOnlineColl(, 500)
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg"))
; Use English input method for choosing concept when import
~!g::SetDefaultKeyboard(0x0409)  ; English-US

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMsgDialog"))
y::Send {text}y
n::Send {text}n

#if (Vim.IsVimGroup() && Vim.SM.IsEditingText())
^/::Send {home}//{space}
+!a::Send /*  */{left 3}
^+!a::Send /*{enter 2}*/{up}
^!+h::Send {text}==================================================

^+k::Vim.SM.RegMember()

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TElParamDlg") && OldConcept)
Enter::
  NewConcept := ControlGetText("Edit2")
  Send {enter}
return
