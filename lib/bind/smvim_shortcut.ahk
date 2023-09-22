#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!.::  ; find [...] and insert
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
  if (IfContains(A_ThisHotkey, "\")) {
    send ^+{enter}
    WinWaitNotActive, ahk_class TElWind  ; "Do you want to remove all element contents from the collection?"
    send {enter}
  } else {
    send ^+{del}
  }
  WinWaitActive, ahk_class TMsgDialog  ; wait for "Delete element?" or confirm registry deletion
  send {enter}
  WinWaitClose
  WinWaitNotActive, ahk_class TElWind,, 0.4
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
  send ^+p!g  ; focus to concept group
  Vim.State.BackToNormal := 1
return

^!t::
  if (t := Vim.SM.IsEditingText()) {
    x := A_CaretX, y := A_CaretY
    send {right}  ; so no text is selected
    WaitCaretMove(x, y)
    sleep 70
    send {left}
  }
  Vim.SM.SetTitle(, 1500)
  if (t)
    ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{esc}, ahk_class TElWind
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind") && Vim.SM.DoesHTMLExist())
^!f::  ; use IE's search
  SMPID := WinGet("PID", "A")
  send ^t
  Vim.SM.WaitHTMLFocus()
  if (Vim.SM.IsEditingHTML())
    send {right}{left}{CtrlDown}cf{CtrlUp}  ; discovered by Harvey from the SuperMemo.wiki Discord server
  WinWaitActive, ahk_class #32770,, 1.5
  if (VimLastSearch) {
    ControlSetText, Edit1, % SubStr(VimLastSearch, 2)
    ControlSend, Edit1, % "{text}" . SubStr(VimLastSearch, 1, 1)
    send !f  ; select all text
  }
  SetTimer, RegisterVimLastSearchForSMCtrlAltF, -1
return

RegisterVimLastSearchForSMCtrlAltF:
  while (WinExist("ahk_class #32770 ahk_pid " . SMPID)) {
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
  ContLearn := Vim.SM.IsLearning()
  send ^+p  ; much faster than ^+m
  WinWaitActive, ahk_class TElParamDlg
  send !t
  send {text}classic  ; my plain-text template name is classic
  send {enter 2}
  if (ContLearn == 1)
    vim.sm.learn()
  Vim.State.SetMode("Vim_Normal")
return

SMCtrlN:
  Vim.SM.CtrlN()
~^n::
  Vim.State.SetMode("Vim_Normal")
  if (IsUrl(Clipboard) && IfContains(Clipboard, "youtube.com")) {
    if (A_ThisHotkey == "~^n") {
      ClipSaved := ClipboardAll
      Prio := ""
    }
    Vim.Browser.Url := Clipboard
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
    if (A_ThisHotkey == "~^n") {
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
  }
return

^!space::
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("ahk_class TElWind"))
  ; Can't detect pause/play button, sometimes not present on screen
  ; btn := el.FindFirstBy("ControlType=Button AND Name='Play keyboard shortcut k' OR Name='Pause keyboard shortcut k'")
  if (!btn := el.FindFirstBy("ControlType=Group AND Name='Video'"))
    return
  btn.Click()
  btn := el.WaitElementExist("ControlType=Button AND Name='Hide more videos' OR Name='More videos'",,,, 1000)
  if (btn.CurrentName == "Hide more videos")
    btn.Click()
  Vim.Caret.SwitchToSameWindow()  ; refresh caret
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
  send {AltDown}oo{AltUp}
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
  if (link := IsUrl(Clipboard)) {
    link := Clipboard
  } else if (RegExMatch(Clipboard, "^#(\d+)", v)) {
    link := "SuperMemoElementNo=(" . v1 . ")"
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
  CurrTimeDisplay := GetTimeMSec()
  CurrTimeFileName := RegExReplace(CurrTimeDisplay, " |:", "-")
  ClipSaved := ClipboardAll
  if (!data := Copy(false, true, 1))
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
    Clip("<img alt=""" . LatexFormula . """ src=""" . InsideHTMLPath . """>",, false, true)
    Vim.SM.SaveHTML()
    WinWaitActive, ahk_class TElWind
    HTMLPath := Vim.SM.GetFilePath(false)
    if (!HTML := FileRead(HTMLPath))
      HTML := ImgHTML  ; in case the HTML is picture only and somehow not saved
    
    /*
      Recommended css setting for anti-merge class:
      .anti-merge {
        position: absolute;
        left: -9999px;
        top: -9999px;
      }
    */
    
    AntiMerge := "<SPAN class=anti-merge>Last LaTeX to image conversion at " . CurrTimeDisplay . "</SPAN>"
    send {esc}
    Vim.SM.WaitTextExit()

    HTML := RegExReplace(HTML, "<SPAN class=anti-merge>Last LaTeX to image conversion at .*?(<\/SPAN>|$)", AntiMerge, v)
    if (!v)
      HTML .= "`n" . AntiMerge
    FileDelete % HTMLPath
    FileAppend, % HTML, % HTMLPath
    Vim.SM.SaveHTML()  ; better than Vim.SM.Reload()
    Vim.SM.WaitTextFocus()
    send !{f7}  ; go to read point
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
    LatexPath := StrReplace(v1, "file:///"), LatexFormula := HTML_decode(LatexFormula)
    Clip(LatexFormula, true, false)
    FileDelete % LatexPath
    Vim.State.SetMode("Vim_Visual")
  }
  Clipboard := ClipSaved, RemoveToolTip()
return

ProcessLatexFormula(LatexFormula) {
  LatexFormula := RegExReplace(LatexFormula, "{\\displaystyle |\\displaystyle{ ?",, v)  ; from Wikipedia, Wikibooks, Better Explained, etc
  if (v)
    LatexFormula := RegExReplace(LatexFormula, "}$")
  LatexFormula := StrReplace(LatexFormula, "{\ce ",, v)  ; from Wikipedia's chemistry formulae
  if (v)
    LatexFormula := RegExReplace(LatexFormula, "}$")
  LatexFormula := RegExReplace(LatexFormula, "^\\\[|\\\]$")  ; removing start \[ and end ]\ (in Better Explained)
  return LatexFormula
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
  }
	WinTitle := "ahk_id " . WinActive("A")
	ControlClick, % "x" . 39 * A_ScreenDPI / 96 . " y" . A_CaretY, % WinTitle,,,, NA
  if (refresh)
    send {tab}+{tab}
return

!t::send !mlt  ; Totals

^b::
^!b::
  CancelAlarm := (A_ThisHotkey == "^!b")
  BlockInput, On
  send !b
  WinActivate, ahk_class TPlanDlg
  ControlSend, ahk_parent, {CtrlDown}s{CtrlUp}, ahk_class TPlanDlg
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
      send ^s
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
    send ^s
  }
return

!a::  ; insert/append activity
  SetDefaultKeyboard(0x0409)  ; English-US
  if (WinExist("ahk_id " . PlanAddHwnd)) {
    WinActivate
    return
  }
  Gui, PlanAdd:Add, Text,, A&ctivity:
  list := "Break||Gaming|Coding|Sports|Social|Family|Passive|Meal|Rest"
        . "|Planning|Investing|SM|Shower|IM|Piano|Meditation|Job|Misc"
        . "|Out|Singing|Calligraphy|Drawing|Movie|TV|VC|GF|Music|AE"
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
  send ^s
  if (!NoBackup && IfIn(activity, "Break,Sports,Out,Shower"))
    try run b  ; my personal backup script
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
  ControlSetText, TEdit1, % Clipboard
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
  if (A_ThisHotkey == "j") {
    c := 1
  } else if (A_ThisHotkey == "k") {
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
  ResetTime := IfContains(A_ThisHotkey, "``")
  CloseWnd := IfContains(A_ThisHotkey, "^")
  wMpvId := WinActive("ahk_class mpv"), wSMElWnd := ""
  if (wBrowserId := WinActive("ahk_group Browser")) {
    Vim.Browser.Clear(), guiaBrowser := new UIA_Browser(wBrowser := "ahk_id " . wBrowserId)
    ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{esc}, % wBrowser
    Vim.Browser.GetTitleSourceDate(!sync, false,, false)  ; get title for checking later
    WinGet, paSMTitles, List, ahk_class TElWind  ; can't get pseudo-array by WinActive("A")
    loop % paSMTitles {
      SMTitle := WinGetTitle("ahk_id " . hWnd := paSMTitles%A_Index%)
      if (SMTitle ~= "^(\d{1,2}:)?\d{1,2}:\d{1,2} \| ")
        SMTitle := RegExReplace(SMTitle, "^(\d{1,2}:)?\d{1,2}:\d{1,2} \| ")
      ; SM uses "." instead of "..." in titles
      if (ret := (SMTitle == RegExReplace(Vim.Browser.Title, "\.\.\.?", "."))) {
        wSMElWnd := hWnd
        break
      }
    }
    if (!ret) {
      WinActivate, ahk_class TElWind
      MsgBox, 3,, % "Titles don't match. Continue?`nBrowser title: " . Vim.Browser.Title
      WinActivate % wBrowser
      if (IfMsgbox("No") || IfMsgbox("Cancel"))
        Goto SMSyncTimeReturn
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
      ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{CtrlDown}w{CtrlUp}, % wBrowser
  } else if (!Vim.Browser.VidTime && !ResetTime) {
    SetDefaultKeyboard(0x0409)  ; English-US
    if ((!Vim.Browser.VidTime := InputBox("Video Time Stamp", "Enter video time stamp.")) || ErrorLevel)
      Goto SMSyncTimeReturn
  }
  Vim.SM.CloseMsgWind()
  if (CloseWnd && wMpvId)
    ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Shift Down}q{Shift Up}, % "ahk_id " . wMpvId
  Vim.SM.CloseMsgWind()
  WinActivate, % wSMElWnd ? "ahk_id " . wSMElWnd : "ahk_class TElWind"

  if (ResetTime)
    Vim.Browser.VidTime := "0:00"

  if (!EditTitle := (wMpv || (wBrowserId
                           && (Vim.Browser.IsVidSite(vim.browser.fullTitle) == 3)))) {
    Vim.SM.EditFirstQuestion()
    send ^t{f9}
    WinWaitActive, ahk_class TScriptEditor,, 0.3
    if (ErrorLevel) {
      EditTitle := true
    } else {
      sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime)
      if (IfContains(script := ControlGetText("TMemo1", "A"), "bilibili.com")) {
        if (script ~= "\?p=\d+") {
          match := "&t=.*", replacement := "&t=" . sec
        } else {
          match := "\?t=.*", replacement := "?t=" . sec
        }
      } else if (IfContains(script, "youtube.com")) {
        match := "&t=.*s", replacement := "&t=" . sec . "s"
      } else if (EditTitle := true) {
        WinClose, ahk_class TScriptEditor
        send {esc}
      }
    }
  }

  if (!EditTitle) {  ; time in script component
    ControlSetText, TMemo1, % RegExReplace(script, match . "|$", replacement,, 1), A
    send !o{esc}  ; close script editor
    ToolTip("Time stamp in script component set as " . sec . "s")
  } else {  ; time in title
    Vim.SM.SetTitle(Vim.Browser.VidTime . " | "
                  . RegExReplace(WinGetTitle("ahk_class TElWind") 
                               , "^(\d{1,2}:)?\d{1,2}:\d{1,2} \| "))
  }
  WinWaitActive, ahk_class TElWind
  if (IfContains(A_ThisHotkey, "^+!"))
    Vim.SM.Learn(false,, true)
  if ((A_ThisHotkey == "!+s") || (A_ThisHotkey == "!+``"))
    WinActivate % "ahk_id " . guiaBrowser.BrowserId
  Vim.Browser.Clear()
SMSyncTimeReturn:
  if (sync)
    Clipboard := ClipSaved
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind")
                      && (title := WinGetTitle("A"))
                      && (RegExMatch(title, "i)(?<=^p)(\d+|[MDCLXVI]+)(?= \|)", page)  ; eg, p12 | title
                       || RegExMatch(title, ".+?(?= \|)", clip)))  ; eg, last reading point | title
!s::ToolTip("Copied " . Clipboard := Trim(page ? page : clip))

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle("A") ~= "^Concept Registry \(\d+ members\)"))
!p::ControlFocus, TEdit1  ; set priority for current selected concept in registry window

SMRegAltG:
!g::Acc_Get("Object", "4.5.4.2.4",, "A").accDoDefaultAction()

!i::Acc_Get("Object", "4.6.4.3.4.9.4",, "A").accDoDefaultAction()  ; default item template
!t::Acc_Get("Object", "4.6.4.3.4.10.4",, "A").accDoDefaultAction()  ; default topic template

^l::
  Gosub SMRegAltG
  WinWaitActive, ahk_class TElWind
  Goto SMLearnChild
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle("A") ~= "^Reference Registry \(\d+ members\)"))
!i::Acc_Get("Object", "4.5.4.8.4",, "A").accDoDefaultAction()

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
