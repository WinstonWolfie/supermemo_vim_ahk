#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!.::  ; find [...] and insert
  KeyWait ctrl
  Vim.SM.ExitText()
  send q
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
  SetDefaultKeyboard(0x0409)  ; english-US	
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
  WinWaitNotActive, ahk_class TElWind  ; wait for "Delete element?" or confirm registry deletion
  send {enter}
  WinWaitNotActive, ahk_class TElWind,, 0.25
  if (!ErrorLevel)
    send {enter}
  WinWaitActive, ahk_class TElWind,, 0.25  ; wait for element window to become focused again
  if (ErrorLevel)  ; could be several registry deletion confirmations; in that case, script is stopped
    return
  Vim.SM.WaitFileLoad()
  if (WinActive("ahk_class TElWind"))
    Vim.SM.Learn(, true)
return

^!+g::  ; change element's concept *g*roup
  SetDefaultKeyboard(0x0409)  ; english-US	
  send ^+p
  WinWaitActive, ahk_class TElParamDlg
  send !g  ; focus to concept group
  Vim.State.SetMode("Insert")
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
  SetDefaultKeyboard(0x0409)  ; english-US	
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
  send ^n
~^n::
  Vim.State.SetMode("Vim_Normal")
  if (InStr(Clipboard, "youtube.com")) {
    if (A_ThisHotkey == "~^n")
      prio := ""
    vim.browser.url := Clipboard
    text := vim.browser.title . "`n" . Vim.SM.MakeReference()
    Vim.SM.WaitFileLoad()
    KeyWait ctrl
    send q
    Vim.SM.WaitTextFocus()
    send ^a{bs}{esc}
    Vim.SM.WaitTextExit()
    send q
    Vim.SM.WaitTextFocus()
    send % "{text}" . text
    send {esc}
    Vim.SM.SetElParam(vim.browser.title, prio, "YouTube")
    vim.browser.title := prio := ""
    if (A_ThisHotkey == "~^n")
      Vim.Browser.Clear()
  }
return

~^+m::SetDefaultKeyboard(0x0409)  ; english-US	

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
  if (!Vim.SM.IsEditingText())
    send q
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
  send !o!o
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
  } else if (Clipboard ~= "^#") {
    link := "SuperMemoElementNo=(" . RegExReplace(Clipboard, "^#") . ")"
  }
  ClipSaved := ClipboardAll
  if (!copy(false) || !link) {  ; no selection or no link
    Clipboard := ClipSaved
    return
  }
  send ^k
  WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame,, 2  ; a bit more delay since everybody knows how slow IE can be
  clip(link,, false)
  send {enter}
  Vim.State.SetNormal()
  Vim.Caret.SwitchToSameWindow()
  Clipboard := ClipSaved
return

^!l::
  FormatTime, CurrTimeDisplay,, % "yyyy-MM-dd HH:mm:ss:" . A_MSec
  CurrTimeFileName := RegExReplace(CurrTimeDisplay, " |:", "-")
  ClipSaved := ClipboardAll
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (!Vim.HTML.ClipboardGet_HTML(Data)) {
    Clipboard := ClipSaved
    return
  }
  ; To do: Detecting selection contents
  ; if (data ~= "<IMG[^<>]*>\K[\s\S]+(?=<!--EndFragment-->)") {  ; match end of first IMG tag until start of last EndFragment tag
    ; ToolTip("Please select text or image only.")
    ; Clipboard := ClipSaved
    ; Return
  ; } else

  if (!InStr(data, "<IMG")) {  ; text only
    send {bs}^{f7}  ; set read point
    LatexFormula := RegExReplace(Clipboard, "\\$", "\ ")  ; just in case someone would leave a \ at the end
    LatexFormula := EncodeDecodeURI(LatexFormula,, false)
    LatexLink := "https://latex.vimsky.com/test.image.latex.php?fmt=png&val=%255Cdpi%257B150%257D%2520%255Cnormalsize%2520%257B%255Ccolor%257Bwhite%257D%2520" . LatexFormula . "%257D&dl=1"
    text := WinGetText("ahk_class TElWind")
    LatexFolderPath := Vim.SM.GetCollPath(text) . Vim.SM.GetCollName(text) . "\elements\LaTeX"
    LatexPath := LatexFolderPath . "\" . CurrTimeFileName . ".png"
    InsideHTMLPath := "file:///[PrimaryStorage]LaTeX\" . CurrTimeFileName . ".png"
    SetTimer, DownloadLatex, -1
    FileCreateDir % LatexFolderPath
    ImgHTML := "<img alt=""" . Clipboard . """ src=""" . InsideHTMLPath . """>"
    Vim.HTML.SetClipboardHTML(ImgHTML)
    send ^v
    HTMLPath := Vim.SM.SaveHTML(true, true)
    ; VarSetCapacity(HTML, 10240000)  ; ~10 MB
    FileRead, HTML, % HTMLPath
    if (!HTML)
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

    if (InStr(HTML, "<SPAN class=AntiMerge>Last LaTeX to image conversion: ")) {  ; converted before
      NewHTML := RegExReplace(HTML, "<SPAN class=AntiMerge>Last LaTeX to image conversion: .*?(<\/SPAN>|$)", AntiMerge)
      FileDelete % HTMLPath
      FileAppend, % NewHTML, % HTMLPath
    } else {  ; first time conversion
      FileAppend, % "`n" . AntiMerge, % HTMLPath
    }
    Vim.SM.SaveHTML()  ; better than Vim.SM.Reload()
    Vim.SM.WaitTextFocus()
    send {right}
    Vim.State.SetMode("Vim_Normal")

  } else {  ; image only
    if (InStr(data, "alt=""")) {
      RegExMatch(data, "alt=""(.*?)""", LatexFormula)  ; getting formula from alt=""
    } else if (InStr(data, "alt=")) {
      RegExMatch(data, "alt=(.*?) ", LatexFormula)  ; getting formula from alt=""
    }
    LatexFormula := LatexFormula1
    if (InStr(data, "src=""")) {
      RegExMatch(data, "src=""(.*?)""", LatexPath)  ; getting formula from src=""
    } else if (InStr(data, "src=")) {
      RegExMatch(data, "src=(.*?) ", LatexPath)  ; getting formula from src=""
    }
    LatexPath := StrReplace(LatexPath1, "file:///")
    LatexFormula := StrReplace(LatexFormula, "{\displaystyle")  ; from Wikipedia, Wikibooks, etc
    LatexFormula := StrReplace(LatexFormula, "\displaystyle{")  ; from Better Explained
    LatexFormula := trim(RegExReplace(LatexFormula, "}$"))
    LatexFormula := RegExReplace(LatexFormula, "^\\\[|\\\]$")  ; removing start \[ and end ]\ (in Better Explained)
    LatexFormula := HTML_decode(LatexFormula)
    clip(LatexFormula, true, false)
    FileDelete % LatexPath
    Vim.State.SetMode("Vim_Visual")
  }
  Clipboard := ClipSaved
return

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
  send !b
  WinWait, ahk_class TMsgDialog,, 0.25
  if (!ErrorLevel) {
    WinActivate
    send y
    WinWaitClose, ahk_class TMsgDialog
    Vim.SM.Command("")
  } else {
    Vim.SM.Command("")
    WinWaitClose, ahk_class TCommanderDlg
    WinActivate, ahk_class TPlanDlg
    return
  }
  WinWait, ahk_class TMsgDialog,, 0.25
  if (!ErrorLevel) {
    WinActivate
    send y
  }
  WinActivate, ahk_class TPlanDlg
return

!a::  ; insert/append activity
  SetDefaultKeyboard(0x0409)  ; english-US	
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
  FormatTime, CurrTime,, HH:mm
  KeyWait alt
  gui submit
  gui destroy
  WinActivate, ahk_class TPlanDlg
  if (InStr(A_ThisLabel, "Insert")) {
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
      send y
  }
  send ^s
  if activity in Break,Sports,Piano,Out,Shower
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
  ControlTextWaitChange("TEdit1",, "ahk_class TMyFindDlg")
  ; ControlSend, TEdit1, {enter}, ahk_class TMyFindDlg
  ControlClick, TButton3, ahk_class TMyFindDlg
return

#if (Vim.IsVimGroup() && Vim.SM.IsNavigatingPlan() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_d"))
d::
  Vim.State.SetMode("SMVim_PlanDragging")
  MouseGetPos, XCoordSaved, YCoordSaved

  ; Move to the name of current entry
  ; x := A_CaretX, y := A_CaretY
  send {home}{right}
  ; WaitCaretMove(x, y)

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
return

#if (Vim.IsVimGroup() && Vim.SM.IsNavigatingPlan() && Vim.State.IsCurrentVimMode("SMVim_PlanDragging"))
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
  sleep 100  ; wait for SM to update slot position
+p::  ; put before
  click up
  MouseGetPos, XCoord, YCoord
  if (XCoord == IniXCoord && YCoord == IniYCoord && A_ThisHotkey == "+p")  ; no change
    click  ; to unfix
  MouseMove, XCoordSaved, YCoordSaved, 0
  SMVimPlanDraggingPut := true
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
  if ((b := (WinActive("ahk_group Browser")) && !Vim.Browser.VidTime)) {
    GetUrlDone := false
    SetTimer, GetUrl, -1
  }
  sync := (A_ThisLabel == "BrowserSyncTime")
  KeyWait alt
  KeyWait ctrl
  KeyWait shift
  if (b) {
    send {esc}
    hwnd := WinGet()
    while (!GetUrlDone)
      continue
    Vim.Browser.GetTitleSourceDate(!sync, false)  ; get title for checking later
    ; SM uses "." instead of "..." in titles
    if (WinGetTitle("ahk_class TElWind") != StrReplace(Vim.Browser.title, "...", ".")) {
      WinActivate, ahk_class TElWind
      MsgBox, 4,, Titles don't match. Continue?
      WinActivate % "ahk_id " . hwnd
      IfMsgBox no
        goto BrowserSyncReturn
    }
    if (!IfContains(A_ThisHotkey, "``")) {
      Vim.Browser.GetVidtime()
      if (!Vim.Browser.VidTime) {
        if (!Vim.Browser.VidTime := InputBox("Video Time Stamp", "Enter video time stamp."))
          goto BrowserSyncReturn
      }
    }
    ; KeyWait enter  ; without this script may get stuck
    WinActivate % "ahk_id " . hwnd
    if A_ThisHotkey contains ^  ; hotkeys with ctrl will close the tab
      Vim.Browser.CloseTab()
  } else if (!Vim.Browser.VidTime && !IfContains(A_ThisHotkey, "``")) {
    if (!Vim.SM.IsEditingText())  ; without this script may get stuck
      send q
      if (!Vim.Browser.VidTime := InputBox("Video Time Stamp", "Enter video time stamp."))
        goto BrowserSyncReturn
  }
  while (WinExist("ahk_class TMsgDialog"))
    WinClose
  WinActivate, ahk_class TElWind

  if (b && (vim.browser.IsVidSite(, true) == 2)) {
    EditRef := true
  } else {
    if (!Vim.SM.IsEditingText())
      send q
    send ^t{f9}
    WinWaitActive, ahk_class TScriptEditor,, 1.5
    if (ErrorLevel) {
      ToolTip("Script editor not found.")
      goto BrowserSyncReturn
    }
    ControlGetText, script, TMemo1
    sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime)
    if (!sec || IfContains(A_ThisHotkey, "``"))
      sec := 0
    EditRef := false
    if (IfContains(script, "bilibili.com")) {
      replacement := "&t=" . sec
      match := "&t=.*"
    } else if (IfContains(script, "youtube.com")) {
      replacement := "&t=" . sec . "s"
      match := "&t=.*s"
    } else {
      WinClose, ahk_class TScriptEditor
      send {esc}
      EditRef := true
    }
  }

  if (!EditRef) {  ; time in script component
    if (RegExMatch(script, match)) {
      ControlSetText, TMemo1, % RegExReplace(script, match, replacement)
    } else {
      ControlSetText, TMemo1, % script . replacement
    }
    send !o{esc}  ; close script editor
    ToolTip("Time stamp in script component set as " . sec . "s")
  } else {  ; time in comment
    if A_ThisHotkey contains ``
      Vim.Browser.VidTime := "0:00"
    Vim.Browser.comment := Vim.Browser.VidTime
    send !{f10}fe
    WinWaitActive, ahk_class TInputDlg
    ControlGetText, Ref, TMemo1
    Ref := RegExReplace(Ref, "(#Comment: [0-9:]+|$)", "`r`n#Comment: " . Vim.Browser.Comment,, 1)
    ControlSetText, TMemo1, % Ref
    send !{enter}
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
                      && (RegExMatch(title, "(?<=^p)[0-9]+", page) || epub := IfContains(title, "|")))
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
~!g::SetDefaultKeyboard(0x0409)  ; english-US	

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm") && (WinGetTitle() ~= "^Concept Registry"))
^!c::
  gosub SMRegAltG
  WinWaitActive, ahk_class TElWind
  goto SMLearnChild
return