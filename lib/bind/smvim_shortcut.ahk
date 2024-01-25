#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!.::  ; find [...] and insert
  BlockInput, On
  if !(Vim.SM.HasTwoComp() && (ControlGetFocus() == "Internet Explorer_Server2")) {
    Vim.SM.ExitText()
    Vim.SM.EditFirstQuestion(), Vim.SM.WaitTextFocus()
  }
  if (Vim.SM.IsEditingPlainText()) {
    send ^a
    if (pos := InStr(Copy(), "[...]")) {
      send % "{left}{right " . pos + 4 . "}"
    } else {
      ToolTip("Not found.")
      Goto SetModeNormalReturn
    }
  } else if (Vim.SM.IsEditingHTML()) {
    if (!Vim.SM.HandleF3(1))
      Goto SetModeNormalReturn
    ControlSetText, TEdit1, [...], ahk_class TMyFindDlg
    send {enter}
    WinWaitNotActive, ahk_class TMyFindDlg  ; faster than wait for element window to be active
    send {right}  ; put caret on the right
    if (!Vim.SM.HandleF3(2))
      Goto SetModeNormalReturn
  }
  BlockInput, Off
  Vim.State.SetMode("Insert")
return

^!c::  ; change default *c*oncept group
  SetDefaultKeyboard(0x0409)  ; English-US
  Vim.SM.ChangeDefaultConcept()
  Vim.State.SetMode("Vim_Normal")
Return

~^+f12::  ; bomb format with no confirmation
  send {enter}
  Vim.State.SetNormal()
return

>!>+bs::  ; for laptop
>^>+bs::  ; for processing pending queue Advanced English 2018: delete element and keep learning
>!>+\::  ; for laptop
>^>+\::  ; Done! and keep learning
  Vim.State.SetNormal()
  if (IfContains(A_ThisLabel, "\")) {
    send ^+{enter}
    WinWaitNotActive, ahk_class TElWind  ; "Do you want to remove all element contents from the collection?"
    send {enter}
  } else {
    send ^+{del}
  }
  WinWaitActive, ahk_class TMsgDialog  ; wait for "Delete element?" or confirm registry deletion
  send {enter}
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
  send ^+p!g  ; focus to concept group
  Vim.State.BackToNormal := 1
return

^!t::
  if (t := Vim.SM.IsEditingText()) {
    send {right}
    while (Copy())  ; still selecting text
      sleep 200
  }
  Vim.SM.SetTitle(, 1500)
  if (t)
    Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind") && Vim.SM.DoesHTMLExist())
^!f::  ; use IE's search
  pidSM := WinGet("PID", "A")
  send ^t
  Vim.SM.WaitHTMLFocus()
  if (Vim.SM.IsEditingHTML())
    send {right}{left}{Ctrl Down}cf{Ctrl Up}  ; discovered by Harvey from the SuperMemo.wiki Discord server
  WinWaitActive, ahk_class #32770,, 1.5
  if (VimLastSearch) {
    ControlSetText, Edit1, % SubStr(VimLastSearch, 2)
    ControlSend, Edit1, % "{text}" . SubStr(VimLastSearch, 1, 1)
    send !f  ; select all text
  }
  SetTimer, RegisterVimLastSearchForSMCtrlAltF, -1
return

RegisterVimLastSearchForSMCtrlAltF:
  while (WinExist("ahk_class #32770 ahk_pid " . pidSM)) {
    if (v := ControlGetText("Edit1"))
      VimLastSearch := v
    sleep 100
  }
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
~^enter::
  SetDefaultKeyboard(0x0409)  ; English-US
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1
return

^!p::  ; convert to a *p*lain-text template
^!i::  ; convert to the "item" template
  ContLearn := Vim.SM.IsLearning()
  KeyWait Ctrl
  KeyWait Alt
  BlockInput, On
  if (A_ThisLabel == "^!p") {
    template := "classic"  ; my plain-text template name is classic
  } else if (A_ThisLabel == "^!i") {
    template := "item"
  }
  Vim.SM.SetElParam(,, template)
  WinWaitClose, ahk_class TElParamDlg
  if (ContLearn == 1)
    Vim.SM.learn()
  BlockInput, Off
  MsgBox, 3,, Permanently remove extra components?
  WinWaitActive, ahk_class TElWind
  BlockInput, On
  if (IfMsgBox("Yes")) {
    send ^+{f2}  ; impose template
    WinWaitActive, ahk_class TMsgDialog
    send {enter}
    WinWaitClose
    WinWaitActive, ahk_class TMsgDialog
    send {enter}
    WinWaitClose
    Vim.SM.SetElParam(,, template)
    WinWaitClose, ahk_class TElParamDlg
    if (ContLearn == 1)
      Vim.SM.learn()
  } else if (IfMsgBox("Cancel")) {
    send !{f10}td
  }
  BlockInput, Off
  Vim.State.SetMode("Vim_Normal")
return

SMCtrlN:
^n::
  Vim.SM.CtrlN(), Vim.State.SetMode("Vim_Normal")
  if (IfContains(Clipboard, "youtube.com") && IsUrl(Clipboard)) {
    Vim.Browser.Url := Clipboard
    ; Register browser time stamp to YT comp time stamp
    if (Vim.Browser.VidTime) {
      RegExMatch(Clipboard, "v=(.{11})", v), YTID := v1
      Clipboard := "{SuperMemoYouTube:" . YTID . "," . Vim.Browser.VidTime . ",0:00,0:00,3}"
    }
    if (A_ThisLabel == "~^n") {
      ClipSaved := ClipboardAll
      Prio := ""
    }
    text := Vim.Browser.Title . "`n" . Vim.SM.MakeReference()
    Vim.SM.WaitFileLoad()
    Vim.SM.EditFirstQuestion()
    Vim.SM.WaitTextFocus()
    send ^a{bs}{esc}
    Vim.SM.WaitTextExit()
    Clip(text,, false)
    Vim.SM.WaitTextFocus()
    Vim.SM.SetElParam(Vim.Browser.Title, Prio, "YouTube")
    Vim.Browser.Title := Prio := ""
    if (A_ThisLabel == "~^n") {
      Vim.Browser.Clear()
      Clipboard := ClipSaved
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
  BlockInput, on
  Vim.SM.EditFirstQuestion()
  send ^t{f9}
  WinWaitActive, ahk_class TScriptEditor,, 1.5
  if (ErrorLevel) {
    ToolTip("Script editor not found.")
    BlockInput, off
    return
  }
  send !c
  WinWaitActive, ahk_class TInputDlg,, 0.25
  if (ErrorLevel) {
    Send {esc}
    BlockInput, off
    ToolTip("Can't be cloned because this script registry is the only instance in this collection.",, -5000)
    return
  }
  send {Alt Down}oo{Alt Up}
  ToolTip("Cloning successful.")
  send {esc}
  BlockInput, off
return

; More intuitive inter-element linking, inspired by Obsidian
; 1. Go to the element you want to link to and press ctrl+alt+g
; 2. Go to the element you want to have the hyperlink, select text and press ctrl+alt+k
^!g::
  Clipboard := ""
  send ^g^c{esc}
  ClipWait
  Vim.State.SetNormal()
  Clipboard := (Clipboard ~= "^#") ? Clipboard : "#" . Clipboard
  ToolTip("Copied " . Clipboard)
  WinWaitActive, Error! ahk_class TMsgDialog,, 0
  if (!ErrorLevel)
    WinClose
return

#if (Vim.IsVimGroup() && Vim.SM.IsEditingHTML())
^!k::
  if (link := IsUrl(Trim(Clipboard))) {
    link := Clipboard
  } else if (RegExMatch(Clipboard, "^#(\d+)", v)) {
    link := "SuperMemoElementNo=(" . v1 . ")"
  } else if (Clipboard ~= "^SuperMemoElementNo=\(\d+\)$") {
    link := Clipboard
  }
  if (!link || !Copy())  ; no selection or no link
    return
  send ^k
  WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("ahk_class Internet Explorer_TridentDlgFrame"))
  el.WaitElementExist("ControlType=Edit AND Name='URL: ' AND AutomationId='txtURL'").SetValue(link)
  send {enter}
  WinWaitClose, ahk_class Internet Explorer_TridentDlgFrame
  Vim.State.SetNormal(), Vim.Caret.SwitchToSameWindow()
  send {left}
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
  ToolTip("LaTeX converting...", true)
  if (!IfContains(data, "<IMG")) {  ; text
    send {bs}^{f7}  ; set read point
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
      send {esc}
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
    send ^{home}
    Clip(HTML,, false, "sm")
    if (ContLearn == 1) {  ; item and "Show answer"
      send {esc}
      Vim.SM.WaitTextExit()
    }
    Vim.SM.SaveHTML()
    if (Item) {
      WinWaitActive, ahk_class TElWind
      send ^+{f7}  ; clear read point
    }
    Vim.State.SetMode("Vim_Normal")
  } else {  ; image
    send {bs}  ; otherwise might contain unwanted format
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
  Clipboard := ClipSaved, RemoveToolTip()
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
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("A"))
  el.WaitElementExist("ControlType=TabItem AND Name='Edit'").ControlClick()
  el.WaitElementExist("ControlType=ToolBar AND Name='Format'").FindByPath("19").ControlClick()
  el.WaitElementExist("ControlType=TabItem AND Name='Learn'").ControlClick()
  Vim.Caret.SwitchToSameWindow(), Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))  ; SuperMemo Plan window
!r::
  if (refresh := Vim.SM.IsNavigatingPlan()) {
    send {home}{right}
    x := A_CaretX, y := A_CaretY
    send {f2}
    WaitCaretMove(x, y)
    sleep 70
  }
	ControlClick, % "x" . 39 * A_ScreenDPI / 96 . " y" . A_CaretY, A,,,, NA
  if (refresh)
    send {tab}+{tab}
return

!t::send !mlt  ; Totals
!d::send !mld  ; Totals

^b::
^!b::
  CancelAlarm := (A_ThisLabel == "^!b")
  BlockInput, On
  send !b
  WinActivate, ahk_class TPlanDlg
  ControlSend, ahk_parent, {Ctrl Down}s{Ctrl Up}, ahk_class TPlanDlg
  BlockInput, Off
  WinWaitActive, Question ahk_class TMsgDialog,, 0.3
  if (!ErrorLevel) {
    send {text}y
    WinWaitClose
    if (CancelAlarm)
      Vim.SM.Command("")
  } else {
    if (CancelAlarm) {
      Vim.SM.Command("")
      WinWaitClose, ahk_class TCommanderDlg
    }
    if (WinExist("ahk_class TPlanDlg")) {
      WinActivate
      ControlSend, ahk_parent, {Ctrl Down}s{Ctrl Up}
    }
    return
  }
  WinWaitActive, ahk_class TMsgDialog,, 0.3
  if (!ErrorLevel) {
    WinActivate
    send {text}y
  }
  if (WinExist("ahk_class TPlanDlg")) {
    WinActivate
    ControlSend, ahk_parent, {Ctrl Down}s{Ctrl Up}
  }
return

!a::  ; insert/append activity
  SetDefaultKeyboard(0x0409)  ; English-US
  if (WinExist("ahk_id " . PlanAddHwnd)) {
    WinActivate
    return
  }
  Gui, PlanAdd:Add, Text,, A&ctivity:
  list := "Break||Game|Code|Sports|Social|Family|Listen|Meal|Rest"
        . "|Plan|Invest|SM|Shower|IM|Piano|Medit|Job|Misc|Out"
        . "|Sing|Write|Draw|Movie|TV|GF|Music|Sun|Lang|SocMed"
        . "|MP|Tidy|Read|Write|Poker|Video"
  Gui, PlanAdd:Add, Combobox, vActivity gAutoComplete w110, % list
  Gui, PlanAdd:Add, Text,, &Time:
  Gui, PlanAdd:Add, Edit, vTime w110
  Gui, PlanAdd:Add, CheckBox, vNoBackup, Do &not backup
  Gui, PlanAdd:Add, Button, default x10 w50 h24, &Insert
  Gui, PlanAdd:Add, Button, x+10 w50 h24, &Append
  Gui, PlanAdd:Show,, Add Activity
  Gui, PlanAdd:+HwndPlanAddHwnd
return

PlanAddGuiEscape:
PlanAddGuiClose:
  Gui, Destroy
return

PlanAddButtonInsert:
PlanAddButtonAppend:
  aTime := StrSplit(CurrTime := FormatTime(, "HH:mm:ss"), ":")
  if (aTime[3] >= 30)
    aTime[2]++
  CurrTime := aTime[1] . ":" . aTime[2]
  Gui, Submit
  Gui, Destroy
  KeyWait Alt
  Vim.Caret.SwitchToSameWindow("ahk_class TPlanDlg")
  BlockInput, on
  if (IfContains(A_ThisLabel, "Insert")) {
    send ^t  ; split
    WinWaitActive, ahk_class TInputDlg
    send {enter}
    WinWaitActive, ahk_class TPlanDlg
  }
  send {down}{ins}  ; inserting one activity below the current selected activity and start editing
  send % "{text}" . activity
  if (time) {
    send {enter}
    send % "{text}" . time
    send {enter}{up}!b
    WinWaitActive, ahk_class TMsgDialog,, 0.3
    if (!ErrorLevel)
      WinClose, ahk_class TMsgDialog
  } else {
    send +{tab}
    send % "{text}" . CurrTime
    send {enter}
    WinWaitActive, ahk_class TMsgDialog,, 0.3
    if (!ErrorLevel)
      send {text}y
  }
  if (A_ThisLabel == "PlanAddButtonAppend")
    send ^s
  if (!NoBackup && IfIn(activity, "Break,Sports,Out,Shower"))
    try ShellRun("b")  ; my personal backup script
  BlockInput, off
  Vim.State.SetNormal()
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
enter::
  Prio := ControlGetText("TEdit5", "A")
  if (Prio ~= "^\.")
    ControlSetText, TEdit5, % "0" . Prio
  send {enter}
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
  BlockInput, on
  Vim.State.SetMode("SMPlanDragging")
  MouseGetPos, XCoordSaved, YCoordSaved

  ; Move to the name of current entry
  send {home}{right}

  ; Get current entry coords
  x := A_CaretX, y := A_CaretY
  send {f2}  ; sometimes A_Caret isn't accurate
  ControlFocusWait("TInplaceEdit1", "A")
  sleep 70
  coords := StrSplit(WaitCaretMove(x, y), " ")

  ; Move to the next entry
  send +{tab}{down}{right}
  coords := StrSplit(WaitCaretMove(coords[1], IniYCoord := coords[2]), " ")

  ; Show caret in next entry
  send {f2}
  ControlFocusWait("TInplaceEdit1", "A")
  sleep 70
  coords := StrSplit(WaitCaretMove(coords[1], coords[2]), " ")

  ; Calculate entry height
  PlanEntryGap := A_CaretY - IniYCoord
  send {up}{left}  ; go back
  WaitCaretMove(coords[1], coords[2])

  ; Move to position
  MouseMove, 20, % IniYCoord + PlanEntryGap / 2, 0
  MouseGetPos, IniXCoord, IniYCoord
  click down
  BlockInput, off
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
  sleep 70  ; wait for SM to update slot position
+p::  ; put before
  click up
  MouseGetPos, XCoord, YCoord
  ; If the slot remains in the same place as before, it will be fixed
  if ((XCoord == IniXCoord) && (YCoord == IniYCoord))  ; no change
    click  ; to unfix
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
  sync := (A_ThisLabel == "BrowserSyncTime")
  ResetTime := IfContains(A_ThisLabel, "``")
  CloseWnd := IfContains(A_ThisLabel, "^")
  wMpvId := WinActive("ahk_class mpv")
  wSMElWnd := TemplCode := ""
  if (wBrowserId := WinActive("ahk_group Browser")) {
    Vim.Browser.Clear(), guiaBrowser := new UIA_Browser(wBrowser := "ahk_id " . wBrowserId)
    ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{esc}, % wBrowser
    Vim.Browser.GetTitleSourceDate(!sync, false,, false)  ; get title for checking later
    WinGet, paSMTitles, List, ahk_class TElWind  ; can't get pseudo-array by WinActive("A")
    loop % paSMTitles {
      SMTitle := WinGetTitle("ahk_id " . hWnd := paSMTitles%A_Index%)
      ; SM uses "." instead of "..." in titles
      if (TitleMatched := (SMTitle == RegExReplace(Vim.Browser.Title, "\.\.\.?", "."))) {
        wSMElWnd := hWnd
        break
      }
    }
    SkipCheckUrl := false
    if (!TitleMatched) {
      WinActivate, ahk_class TElWind
      MsgBox, 3,, % "Titles don't match. Continue?`nBrowser title: " . Vim.Browser.Title
      WinActivate % wBrowser
      if (IfMsgbox("No") || IfMsgbox("Cancel"))
        Goto SMSyncTimeReturn
      SkipCheckUrl := IfMsgBox("Yes")
    }
    if (!SkipCheckUrl && ((Vim.Browser.Title == "Netflix") || (Vim.Browser.Source == "MoviesJoy"))) {
      BrowserUrl := Vim.Browser.GetParsedUrl()
      WinActivate, % wSMElWnd ? "ahk_id " . wSMElWnd : "ahk_class TElWind"
      SMUrl := Vim.SM.GetLink(TemplCode := Vim.SM.GetTemplCode())
      if (BrowserUrl != SMUrl) {
        MsgBox, 3,, % "Link in SM reference is not the same as in the browser. Continue?"
                    . "`nBrowser url: " . BrowserUrl
                    . "`n     SM url: " . SMUrl
        WinActivate % wBrowser
        if (IfMsgBox("No") || IfMsgBox("Cancel"))
          Goto SMSyncTimeReturn
      }
    }
    if (!ResetTime) {
      if (!Vim.Browser.VidTime := Vim.Browser.GetVidtime(Vim.Browser.FullTitle)) {
        SetDefaultKeyboard(0x0409)  ; English-US
        if ((!Vim.Browser.VidTime := InputBox("Video Time Stamp", "Enter video time stamp.")) || ErrorLevel)
          Goto SMSyncTimeReturn
      }
    }
    WinActivate % wBrowser
    if (CloseWnd)  ; hotkeys with ctrl will close the tab
      ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Ctrl Down}w{Ctrl Up}, % wBrowser
  } else if (!Vim.Browser.VidTime && !ResetTime) {
    SetDefaultKeyboard(0x0409)  ; English-US
    if ((!Vim.Browser.VidTime := InputBox("Video Time Stamp", "Enter video time stamp.")) || ErrorLevel)
      Goto SMSyncTimeReturn
  }
  Vim.SM.CloseMsgWind()
  if (wMpvId && CloseWnd && !ResetTime) {
    ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Shift Down}q{Shift Up}, % "ahk_id " . wMpvId
  } else if (wMpvId && CloseWnd && ResetTime) {
    ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}q, % "ahk_id " . wMpvId
  }
  Vim.SM.CloseMsgWind()
  WinActivate, % wSMElWnd ? "ahk_id " . wSMElWnd : "ahk_class TElWind"
  if (ResetTime)
    Vim.Browser.VidTime := "0:00"

  TemplCode := TemplCode ? TemplCode : Vim.SM.GetTemplCode()
  RegExMatch(TemplCode, "ScriptFile=\K.*", ScriptPath) 
  Script := FileRead(ScriptPath)
  Sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime)
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
    Vim.SM.EditFirstQuestion()
    OldText := Vim.SM.GetFirstParagraph()
    NewText := "SMVim time stamp: " . Vim.Browser.VidTime
    if (OldText != NewText) {
      send ^{home}
      if (OldText ~= "^SMVim time stamp:") {
        send ^+{down}+{left}
      } else if (OldText) {
        send {enter}{up}
      }
      Clip(NewText,, false, "sm")
      send {esc}
    }
  }

  if (EditScript) {
    FileDelete, % ScriptPath
    FileAppend, % RegExReplace(Script, Match . "|$", Replacement,, 1), % ScriptPath
    ToolTip("Time stamp in script component set as " . Sec . "s")
  }
  WinWaitActive, ahk_class TElWind
  if (IfContains(A_ThisLabel, "^+!"))
    Vim.SM.Learn(false,, true)
  if ((A_ThisLabel == "!+s") || (A_ThisLabel == "!+``"))
    WinActivate % wBrowser
SMSyncTimeReturn:
  Vim.Browser.Clear()
  if (sync)
    Clipboard := ClipSaved
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
!s::
  if ((p := Vim.SM.GetFirstParagraph()) && (p ~= "SMVim (read point|page number|time stamp): ")) {
    ToolTip("Copied " . Clipboard := RegExReplace(p, "SMVim (read point|page number|time stamp): "))
  } else {
    KeyWait Alt
    send !s
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
  send !b
  WinWaitActive, ahk_class TBrowser
  Goto SMLearnChildActiveBrowser
return

~!n::
  WinWaitActive, ahk_class TElWind,, 1
  Vim.SM.PlayIfPassiveColl(, 500)
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg"))
; Use English input method for choosing concept when import
~!g::SetDefaultKeyboard(0x0409)  ; English-US

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMsgDialog"))
y::send {text}y
n::send {text}n

#if (Vim.IsVimGroup() && Vim.SM.IsEditingText())
^/::send {home}//{space}
+!a::send /*  */{left 3}
^+!a::send /*{enter 2}*/{up}
^!+h::send {text}==================================================

^+k::send !{f12}kr  ; registry member
