#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!.::  ; find [...] and insert
  KeyWait ctrl
  Vim.SM.ExitText()
  Vim.SM.EditFirstQuestion()
  Vim.SM.WaitTextFocus()
  ; this is to make sure this finds in the question field
  if (Vim.SM.IsEditingPlainText()) {
    send ^a
    pos := InStr(Copy(), "[...]")
    if (pos) {
      pos += 4
      send % "{left}{right " . pos . "}"
    } else {
      ToolTip("Not found.")
      Vim.State.SetNormal()
      Return
    }
  } else if (Vim.SM.IsEditingHTML()) {
    if (!Vim.SM.HandleF3(1))
      return
    ControlSetText, TEdit1, [...], ahk_class TMyFindDlg
    send {enter}
    WinWaitNotActive, ahk_class TMyFindDlg  ; faster than wait for element window to be active
    send {right}  ; put caret on the right
    if (!Vim.SM.HandleF3(2))
      return
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
  KeyWait alt
  KeyWait ctrl
  KeyWait shift
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
  send !{home}
  Vim.SM.WaitFileLoad()
  if (WinActive("ahk_class TElWind"))
    Vim.SM.Learn(, true)
return

^!+g::  ; change element's concept *g*roup
  KeyWait Alt
  KeyWait Shift
  Vim.State.SetMode("Insert")
  SetDefaultKeyboard(0x0409)  ; English-US
  send ^+p
  ; WinWaitActive, ahk_class TElParamDlg
  send !g  ; focus to concept group
  Vim.State.BackToNormal := 1
return

^!t::
  KeyWait alt
  KeyWait ctrl
  if (t := Vim.SM.IsEditingText())
    send {right}  ; so no text is selected
  Vim.SM.SetTitle()
  if (t)
    ControlSend,, {esc}, ahk_class TElWind
return

^!f::  ; use IE's search
  if (!Vim.SM.IsEditingText()) {
    send ^t
    Vim.SM.WaitTextFocus(500)
  }
  if (Vim.SM.IsEditingHTML())
    send {right}{left}{CtrlDown}cf{CtrlUp}  ; discovered by Harvey from the SuperMemo.wiki Discord server
return

~^enter::
  SetDefaultKeyboard(0x0409)  ; English-US
  Vim.State.SetMode("Insert")
  vim.state.BackToNormal := 1
return

^!p::  ; convert to a *p*lain-text template
  KeyWait alt
  KeyWait ctrl
  ContLearn := Vim.SM.IsLearning()
  send ^+p  ; much faster than ^+m
  WinWaitActive, ahk_class TElParamDlg
  send !t
  send {text}cl  ; my plain-text template name is classic
  send {enter 2}
  if (ContLearn == 1)
    vim.sm.learn()
  Vim.State.SetMode("Vim_Normal")
return

SMCtrlN:
  Vim.SM.PostMsg(96)  ; ctrl+N
~^n::
  Vim.State.SetMode("Vim_Normal")
  if (IfContains(Clipboard, "youtube.com")) {
    if (A_ThisHotkey == "~^n") {
      ClipSaved := ClipboardAll
      prio := ""
    }
    vim.browser.url := Clipboard
    text := vim.browser.title . "`n" . Vim.SM.MakeReference()
    Vim.SM.WaitFileLoad()
    Vim.SM.EditFirstQuestion()
    Vim.SM.WaitTextFocus()
    KeyWait ctrl
    send ^a{bs}{esc}
    Vim.SM.WaitTextExit()
    Clip(text,, false)
    Vim.SM.WaitTextFocus()
    KeyWait Ctrl
    Vim.SM.SetElParam(vim.browser.title, prio, "YouTube")
    vim.browser.title := prio := ""
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
  if (!btn := el.FindFirstBy("ControlType=Button AND Name='Start' AND AutomationId='start'"))
    return
  btn.Click()
  Vim.Caret.SwitchToSameWindow()  ; refresh caret
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
  Vim.SM.EditFirstQuestion()
  send ^t{f9}
  WinWaitActive, ahk_class TScriptEditor,, 0
  if (ErrorLevel) {
    ToolTip("Script editor not found.")
    return
  }
  send !c
  WinWaitActive, ahk_class TInputDlg,, 0.25
  if (ErrorLevel) {
    Send {esc}
    ToolTip("Can't be cloned because this script registry is the only instance in this collection.",, -5000)
    return
  }
  send {AltDown}oo{AltUp}
  ToolTip("Cloning successful.")
  Vim.SM.Reload()
return

; More intuitive inter-element linking, inspired by Obsidian
; 1. Go to the element you want to link to and press ctrl+alt+g
; 2. Go to the element you want to have the hyperlink, select text and press ctrl+alt+k
^!g::
  send ^g^c{esc}
  Vim.State.SetNormal()
return

#if (Vim.IsVimGroup() && Vim.SM.IsEditingHTML())
^!k::
  link := ""
  if (Clipboard ~= "^(https?:\/\/|file:\/\/\/)") {
    link := Clipboard
  } else if (RegExMatch(Clipboard, "^#(\d+)", v)) {
    link := "SuperMemoElementNo=(" . v1 . ")"
  }
  if (!link || !copy())  ; no selection or no link
    return
  send ^k
  WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("ahk_class Internet Explorer_TridentDlgFrame"))
  el.WaitElementExist("ControlType=Edit AND Name='URL: ' AND AutomationId='txtURL'").SetValue(link)
  send {enter}
  WinWaitClose, ahk_class Internet Explorer_TridentDlgFrame
  Vim.State.SetNormal()
  Vim.Caret.SwitchToSameWindow()
return

^!l::
  CurrTimeDisplay := FormatTime(, "yyyy-MM-dd HH:mm:ss:" . A_MSec)
  CurrTimeFileName := RegExReplace(CurrTimeDisplay, " |:", "-")
  ClipSaved := ClipboardAll
  KeyWait Ctrl
  KeyWait Alt
  KeyWait l
  if (!data := copy(false, true, 1))
    goto RestoreClipReturn
  ToolTip("LaTeX converting...", true)
  if (!IfContains(data, "<IMG")) {  ; text
    send {bs}^{f7}  ; set read point
    LatexFormula := ProcessLatexFormula(Clipboard)
    ; After almost a year since I wrote this script, I finially figured out this f**ker website encodes the formula twice. Well, I suppose I don't use math that often in SM
    LatexFormula := EncodeDecodeURI(EncodeDecodeURI(LatexFormula))
    LatexLink := "https://latex.vimsky.com/test.image.latex.php?fmt=png&val=%255Cdpi%257B150%257D%2520%255Cbg_white%2520%255Chuge%2520" . LatexFormula . "&dl=1"
    text := WinGetText("ahk_class TElWind")
    LatexFolderPath := Vim.SM.GetCollPath(text) . Vim.SM.GetCollName(text) . "\elements\LaTeX"
    LatexPath := LatexFolderPath . "\" . CurrTimeFileName . ".png"
    InsideHTMLPath := "file:///[PrimaryStorage]LaTeX\" . CurrTimeFileName . ".png"
    SetTimer, DownloadLatex, -1
    FileCreateDir % LatexFolderPath
    clip("<img alt=""" . LatexFormula . """ src=""" . InsideHTMLPath . """>",, false, true)
    HTMLPath := Vim.SM.SaveHTML(true, true)
    ; VarSetCapacity(HTML, 10240000)  ; ~10 MB
    if (!HTML := FileRead(HTMLPath))
      HTML := ImgHTML  ; in case the HTML is picture only and somehow not saved
    
    /*
      Recommended css setting for AntiMerge class:
      .AntiMerge {
        position: absolute;
        left: -9999px;
        top: -9999px;
      }
    */
    
    AntiMerge := "<SPAN class=AntiMerge>Last LaTeX to image conversion: " . CurrTimeDisplay . "</SPAN>"
    send {esc}
    Vim.SM.WaitTextExit()

    HTML := RegExReplace(HTML, "<SPAN class=AntiMerge>Last LaTeX to image conversion: .*?(<\/SPAN>|$)", AntiMerge, v)
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
    clip(LatexFormula, true, false)
    FileDelete % LatexPath
    Vim.State.SetMode("Vim_Visual")
  }
  Clipboard := ClipSaved
  RemoveToolTip()
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

#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))  ; SuperMemo Plan window
!r::
  if (refresh := Vim.SM.IsNavigatingPlan()) {
    send {home}{right}
    x := A_CaretX, y := A_CaretY
    send {f2}
    WaitCaretMove(x, y)
  }
	WinTitle := "ahk_id " . WinGet()
	ControlClick, % "x" . 39 * A_ScreenDPI / 96 . " y" . A_CaretY, % WinTitle,,,, NA
  if (refresh)
    send {tab}+{tab}
return

!t::send !mlt  ; Totals

^!b::
  KeyWait Ctrl
  KeyWait alt
  send !b
  WinWait, ahk_class TMsgDialog,, 0.25
  if (!ErrorLevel) {
    WinActivate
    send {text}y
    WinWaitClose, ahk_class TMsgDialog
    Vim.SM.Command("")
  } else {
    Vim.SM.Command("")
    WinWaitClose, ahk_class TCommanderDlg
    WinActivate, ahk_class TPlanDlg
    send ^s
    return
  }
  WinWait, ahk_class TMsgDialog,, 0.25
  if (!ErrorLevel) {
    WinActivate
    send {text}y
  }
  WinActivate, ahk_class TPlanDlg
  send ^s
return

!a::  ; insert/append activity
  SetDefaultKeyboard(0x0409)  ; English-US
  gui, PlanAdd:Add, Text,, A&ctivity:
  list := "Break||Gaming|Coding|Sports|Social|Family|Passive|Meal|Rest"
        . "|Planning|Investing|SM|Shower|IM|Piano|Meditation|Job|Misc|Out|Singing"
        . "|Calligraphy|Drawing|Movie|TV|VC"
  gui, PlanAdd:Add, Combobox, vActivity gAutoComplete w110, % list
  gui, PlanAdd:Add, Text,, &Time:
  gui, PlanAdd:Add, Edit, vTime w110
  gui, PlanAdd:Add, Button, default x10 w50 h24, &Insert
  gui, PlanAdd:Add, Button, x+10 w50 h24, &Append
  KeyWait Alt
  gui, PlanAdd:Show,, Add Activity
return

PlanAddGuiEscape:
PlanAddGuiClose:
  gui destroy
return

PlanAddButtonInsert:
PlanAddButtonAppend:
  aTime := StrSplit(CurrTime := FormatTime(, "HH:mm:ss"), ":")
  if (aTime[3] >= 30)
    aTime[2]++
  CurrTime := aTime[1] . ":" . aTime[2]
  KeyWait alt
  gui submit
  gui destroy
  WinActivate, ahk_class TPlanDlg
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
    WinWaitActive, ahk_class TMsgDialog,, 0.4
    if (!ErrorLevel)
      WinClose, ahk_class TMsgDialog
  } else {
    send % "+{tab}" . CurrTime
    send {enter}
    WinWaitActive, ahk_class TMsgDialog,, 0.4
    if (!ErrorLevel)
      send {text}y
  }
  send ^s
  if activity in Break,Sports,Out,Shower,Meal
    run b  ; my personal backup script
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
  prio := ControlGetText("TEdit5")
  if (prio ~= "^\.")
    ControlSetText, TEdit5, % "0" . prio
  send {enter}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMyFindDlg"))
; So ctrl+ff (hold ctrl and press f twice) could be a shorthand for search clipboard
^f::
  ControlSetText, TEdit1, % Clipboard, ahk_class TMyFindDlg
  ControlFocus, TEdit1, ahk_class TMyFindDlg
  ControlClick, TButton3, ahk_class TMyFindDlg
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingPlan())
d::Vim.State.SetMode("Vim_ydc_d", 0, -1, 0,,,-1)
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
  ControlFocusWait("TInplaceEdit1")
  WaitCaretMove(x, y)

  ; Move to the next entry
  x := A_CaretX, IniYCoord := A_CaretY
  send +{tab}{down}{right}
  WaitCaretMove(x, IniYCoord)

  ; Show caret in next entry
  x := A_CaretX, y := A_CaretY
  send {f2}
  ControlFocusWait("TInplaceEdit1")
  WaitCaretMove(x, y)

  ; Calculate entry height
  x := A_CaretX, y := A_CaretY
  PlanEntryGap := A_CaretY - IniYCoord
  send {up}{left}  ; go back
  WaitCaretMove(x, y)

  ; Move to position
  MouseMove, 20, % IniYCoord + PlanEntryGap / 2, 0
  MouseGetPos, IniXCoord, IniYCoord
  click down
  BlockInput, off
return

#if (Vim.IsVimGroup() && Vim.SM.IsNavigatingPlan() && Vim.State.IsCurrentVimMode("SMPlanDragging"))
j::
  n := Vim.State.n ? Vim.State.n : 1, Vim.State.n := 0
  MouseMove, 0, % n * PlanEntryGap,, R
return

k::
  n := Vim.State.n ? Vim.State.n : 1, Vim.State.n := 0
  MouseMove, 0, % -1 * n * PlanEntryGap,, R
return

p::
  MouseMove, 0, % PlanEntryGap,, R  ; put after
  sleep 70  ; wait for SM to update slot position
+p::  ; put before
  click up
  MouseGetPos, XCoord, YCoord
  if ((XCoord == IniXCoord) && (YCoord == IniYCoord) && (A_ThisHotkey == "+p"))  ; no change
    click  ; to unfix
  MouseMove, XCoordSaved, YCoordSaved, 0
  SMPlanDraggingPut := true
  Vim.State.SetMode("Vim_Normal")
return

; Incremental video
#if (Vim.State.Vim.Enabled && ((WinActive("ahk_group Browser") && WinExist("ahk_class TElWind")) || WinActive("ahk_class TElWind")))
^!s::  ; sync time
!+s::  ; sync time but browser tab stays open
^+!s::  ; sync time and keep learning
^!`::  ; clear time
!+`::  ; clear time but browser tab stays open
^+!`::  ; clear time and keep learning
BrowserSyncTime:
  sync := (A_ThisLabel == "BrowserSyncTime"), ResetTime := IfContains(A_ThisHotkey, "``")
  KeyWait alt
  KeyWait ctrl
  KeyWait shift
  if (BrowserHwnd := WinActive("ahk_group Browser")) {
    guiaBrowser := new UIA_Browser("ahk_id " . BrowserHwnd)
    send {esc}
    Vim.Browser.GetTitleSourceDate(!sync, false,, false)  ; get title for checking later
    ; SM uses "." instead of "..." in titles
    SMTitle := RegExReplace(WinGetTitle("ahk_class TElWind"), "^(\d{1,2}:)?\d{1,2}:\d{2} \| ")
    if (SMTitle != StrReplace(Vim.Browser.title, "...", ".")) {
      WinActivate, ahk_class TElWind
      MsgBox, 4,, Titles don't match. Continue?
      WinActivate % "ahk_id " . guiaBrowser.BrowserId
      IfMsgBox no
        goto BrowserSyncReturn
    }
    if (!ResetTime) {
      if (!Vim.Browser.VidTime := Vim.Browser.GetVidtime(Vim.Browser.FullTitle)) {
        SetDefaultKeyboard(0x0409)  ; English-US
        if ((!Vim.Browser.VidTime := InputBox("Video Time Stamp", "Enter video time stamp.")) || ErrorLevel)
          goto BrowserSyncReturn
      }
    }
    ; KeyWait enter  ; without this script may get stuck
    WinActivate % "ahk_id " . guiaBrowser.BrowserId
    if (IfContains(A_ThisHotkey, "^")) {  ; hotkeys with ctrl will close the tab
      if (ObjCount(oTabs := guiaBrowser.GetAllTabs()) == 1) {
        guiaBrowser.NewTab(), guiaBrowser.CloseTab(oTabs[1])
      } else {
        guiaBrowser.CloseTab()
      }
    }
  } else if (!Vim.Browser.VidTime && !IfContains(A_ThisHotkey, "``")) {
    SetDefaultKeyboard(0x0409)  ; English-US
    if ((!Vim.Browser.VidTime := InputBox("Video Time Stamp", "Enter video time stamp.")) || ErrorLevel)
      goto BrowserSyncReturn
  }
  while (WinExist("ahk_class TMsgDialog"))
    WinClose
  WinActivate, ahk_class TElWind

  if (ResetTime)
    Vim.Browser.VidTime := "0:00"
  if (BrowserHwnd && (vim.browser.IsVidSite(vim.browser.fullTitle) == 3)) {
    EditTitle := true
  } else {
    Vim.SM.EditFirstQuestion()
    send ^t{f9}
    WinWaitActive, ahk_class TScriptEditor,, 1.5
    if (ErrorLevel) {
      ToolTip("Script editor not found.")
      goto BrowserSyncReturn
    }
    ControlGetText, script, TMemo1, A
    sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime), EditTitle := false
    if (IfContains(script, "bilibili.com")) {
      replacement := "&t=" . sec, match := "&t=.*"
    } else if (IfContains(script, "youtube.com")) {
      replacement := "&t=" . sec . "s", match := "&t=.*s"
    } else {
      WinClose, ahk_class TScriptEditor
      send {esc}
      EditTitle := true
    }
  }

  if (!EditTitle) {  ; time in script component
    ControlSetText, TMemo1, % RegExReplace(script, match . "|$", replacement,, 1), A
    send !o{esc}  ; close script editor
    ToolTip("Time stamp in script component set as " . sec . "s")
  } else {  ; time in title
    SMTitle := RegExReplace(WinGetTitle("ahk_class TElWind"), "^(\d{1,2}:)?\d{1,2}:\d{2} \| ")
    Vim.SM.SetTitle(Vim.Browser.VidTime . " | " . SMTitle)
  }
  WinWaitActive, ahk_class TElWind
  if (IfContains(A_ThisHotkey, "^+!"))
    Vim.SM.Learn(,, true)
  Vim.Browser.Clear()
BrowserSyncReturn:
  if (sync)
    Clipboard := ClipSaved
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind")
                      && (title := WinGetTitle())
                      && (RegExMatch(title, "(?<=^p)[0-9]+", page) || epub := IfContains(title, " | ")))
!s::
  if (page) {
    clip := page
  } else if (epub) {
    RegExMatch(title, ".+?(?= \|)", clip)
  }
  Clipboard := clip := trim(clip)
  ToolTip("Copied " . clip)
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm"))
!p::ControlFocus, TEdit1  ; set priority for current selected concept in registry window
SMRegAltG:
!g::
  accButton := Acc_Get("Object", "4.5.4.2.4",, "ahk_id " . WinGet())
  accButton.accDoDefaultAction()
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg"))
; Use English input method for choosing concept when import
~!g::SetDefaultKeyboard(0x0409)  ; English-US

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle() ~= "^Concept Registry"))
^l::
  gosub SMRegAltG
  WinWaitActive, ahk_class TElWind
  goto SMLearnChild
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMsgDialog"))
y::send {text}y
n::send {text}n