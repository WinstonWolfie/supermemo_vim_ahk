#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!.::  ; find [...] and insert
  KeyWait ctrl
  Vim.SM.DeselectAllComponents()
  send q
  Vim.SM.WaitTextFocus()
  ; this is to make sure this finds in the question field
  if Vim.SM.IsEditingPlainText() {
    send ^a
    pos := InStr(clip(), "[...]")
    if pos {
      pos += 4
      send {left}{right %pos%}
    } else {
      ToolTip("Not found.")
      Vim.State.SetNormal()
      Return
    }
  } else if Vim.SM.IsEditingHTML() {
    send {f3}
    WinWaitActive, ahk_class TMyFindDlg,, 0
    if (ErrorLevel) {
      send {esc}^{enter}  ; open commander
      send {text}h  ; Highlight: Clear
      send {enter}{f3}
      WinWaitActive, ahk_class TMyFindDlg,, 0
      if (ErrorLevel)
        return
    }
    ControlSetText, TEdit1, [...]
    send {enter}
    WinWaitNotActive, ahk_class TMyFindDlg,, 0  ; faster than wait for element window to be active
    send {right}^{enter}  ; put caret on the right and open commander
    WinWaitActive, ahk_class TCommanderDlg,, 0
    if (ErrorLevel) {
      ToolTip("Not found.")
      Vim.State.SetNormal()
      send {esc}^{enter}  ; open commander
      send {text}h  ; Highlight: Clear
      send {enter}{esc}
      return
    }
    ControlSetText, TEdit2, h  ; Highlight: Clear
    send {enter}
    if (WinExist("ahk_class TMyFindDlg"))  ; clears search box window
      WinClose
    WinWaitActive, ahk_class TElWind,, 0
    if (!Vim.SM.IsEditingText())
      send q
  }
  Vim.State.SetMode("Insert")
return

^!c::  ; change default *c*oncept group
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
  KeyWait alt
  KeyWait ctrl
  KeyWait shift
  if (InStr(A_ThisHotkey, "\")) {
    send ^+{enter}
    WinWaitNotActive, ahk_class TElWind,, 0  ; "Do you want to remove all element contents from the Coll?"
    send {enter}
  } else {
    send ^+{del}
  }
  WinWaitNotActive, ahk_class TElWind,, 0  ; wait for "Delete element?"
  send {enter}
  WinWaitActive, ahk_class TElWind,, 0  ; wait for element window to become focused again
  Vim.SM.WaitFileLoad()
  if (WinActive("ahk_class TElWind"))
    Vim.SM.Learn()
  Vim.State.SetNormal()
  Vim.SM.EnterInsertIfSpelling()
return

^!+g::  ; change element's concept *g*roup
  send ^+p!g
  Vim.State.SetNormal()
return

^!t::Vim.SM.SetTitle()

^!f::  ; use IE's search
  if (Vim.SM.IsEditingHTML()) {
    send {right}{left}{ctrl down}cf{ctrl up}  ; discovered by Harvey from the SuperMemo.wiki Discord server
  } else if (!Vim.SM.IsEditingText()) {
    send ^t
    Vim.SM.WaitTextFocus()
    if (Vim.SM.IsEditingHTML())
      send {right}{left}{ctrl down}cf{ctrl up}
  }
return

~^enter::SetDefaultKeyboard(0x0409)  ; english-US	

^!p::  ; convert to a *p*lain-text template
  ContinueLearning := Vim.SM.IsLearning()
  send ^+p!t  ; much faster than ^+m
  send {text}cl  ; my plain-text template name is classic
  send {enter}
  if (ContinueLearning == 1)
    send {enter}
  Vim.State.SetMode("Vim_Normal")
return

SMCtrlN:
  send ^n
~^n::
  Vim.State.SetMode("Vim_Normal")
  if (InStr(Clipboard, "youtube.com")) {
    if (A_ThisHotkey == "~^n")
      ClipSaved := ClipboardAll
    Vim.SM.WaitFileLoad(10000)
    ; gosub SMSetLinkFromClipboard
    text := "#SuperMemo Reference:"
          . "`n#Link: " . Clipboard
    if (Vim.Browser.title)
      text .= "`n#Title: " . Vim.Browser.title
    if (Vim.Browser.source)
      text .= "`n#Source: " . Vim.Browser.source
    if (Vim.Browser.date)
      text .= "`n#Date: " . Vim.Browser.date
    WinClip.SetText(text)
    ; WinWaitActive, ahk_class TElWind,, 3
    send q
    Vim.SM.WaitTextFocus(2000)
    ; send ^+{down}{bs}{esc}
    send ^a^v{esc}
    Vim.SM.WaitTextExit()
    send ^+p
    WinWaitActive, ahk_class TElParamDlg,, 0
    ControlSetText, TEdit2, % Vim.Browser.Title
    send !t
    send {text}y  ; YouTube
    send {enter}
    sleep 20
    ; Wait for the YT component to exist
    ControlWait("Internet Explorer_Server2", "ahk_class TElWind",,,, 2000)
    sleep 800  ; needed for the html component to load
    ControlFocus, TEdit2
    send {right}t{bs}{enter}
    if (A_ThisHotkey == "~^n") {
      Clipboard := ClipSaved
      Vim.Browser.Clear()
    }
  }
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
  if (RegExMatch(Clipboard, "^https?:\/\/") || RegExMatch(Clipboard, "^file:\/\/\/")) {
    link := Clipboard
  } else if (RegExMatch(Clipboard, "^#")) {
    link := "SuperMemoElementNo=(" . RegExReplace(Clipboard, "^#") . ")"
  }
  WinClip.Snap(ClipData)
  if (!clip("",, true) || !link) {  ; no selection or no link
    WinClip.Restore(ClipData)
    return
  }
  send ^k
  WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame,, 2  ; a bit more delay since everybody knows how slow IE can be
  clip(link,, true)
  send {enter}
  Vim.State.SetNormal()
  WinActivate, ahk_class WorkerW
  WinActivate, ahk_class TElWind  ; refresh caret
  WinClip.Restore(ClipData)
return

^!l::
  KeyWait ctrl
  KeyWait alt
  FormatTime, CurrTimeDisplay,, % "yyyy-MM-dd HH:mm:ss:" . A_MSec
  CurrTimeFileName := RegExReplace(CurrTimeDisplay, " |:", "-")
  Vim.State.SetMode("Vim_Normal")
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  If (Vim.HTML.ClipboardGet_HTML(Data)) {
    ; To do: Detecting selection contents
    ; if (RegExMatch(data, "<IMG[^>]*>\K[\s\S]+(?=<!--EndFragment-->)")) {  ; match end of first IMG tag until start of last EndFragment tag
      ; ToolTip("Please select text or image only.")
      ; WinClip.Restore(ClipData)
      ; Return
    ; } else
    if (!InStr(data, "<IMG")) {  ; text only
      send {bs}^{f7}  ; set read point
      WinGetText, VisibleText, ahk_class TElWind
      CollName := Vim.SM.GetCollName(VisibleText)
      CollPath := Vim.SM.GetCollPath(VisibleText)
      LatexFormula := RegExReplace(Clipboard, "\\$", "\ ")  ; just in case someone would leave a \ at the end
      LatexFormula := Enc_Uri(LatexFormula)
      LatexLink := "https://latex.vimsky.com/test.image.latex.php?fmt=png&val=%255Cdpi%257B150%257D%2520%255Cnormalsize%2520%257B%255Ccolor%257Bwhite%257D%2520" . LatexFormula . "%257D&dl=1"
      LatexFolderPath := CollPath . CollName . "\elements\LaTeX"
      LatexPath := LatexFolderPath . "\" . CurrTimeFileName . ".png"
      InsideHTMLPath := "file:///[PrimaryStorage]LaTeX\" . CurrTimeFileName . ".png"
      SetTimer, DownloadLatex, -1
      FileCreateDir % LatexFolderPath
      ImgHTML = <img alt="%Clipboard%" src="%InsideHTMLPath%">
      clip(ImgHTML,, true, true)
      Vim.SM.SaveHTML()
      FileRead, HTML, % Vim.SM.GetFilePath(true)
      if (!HTML)
        HTML := ImgHTML  ; in case the HTML is picture only and somehow not saved
      
      /*
        recommended css setting for fuck_lexicon class:
        .fuck_lexicon {
          position: absolute;
          left: -9999px;
          top: -9999px;
        }
      */
      
      fuck_lexicon = <SPAN class=fuck_lexicon>Last LaTeX to image conversion: %CurrTimeDisplay%</SPAN>
      if (InStr(HTML, "<SPAN class=fuck_lexicon>Last LaTeX to image conversion: ")) {  ; converted before
        send {esc}
        Vim.SM.WaitTextExit(5000)
        NewHTML := RegExReplace(HTML, "<SPAN class=fuck_lexicon>Last LaTeX to image conversion: (.*?)(<\/SPAN>|$)", fuck_lexicon)
        FileDelete % HTMLPath
        FileAppend, % NewHTML, % HTMLPath
      } else {  ; first time conversion
        NewHTML := HTML . "`n" . fuck_lexicon
        Vim.SM.MoveAboveRef(true)
        send ^+{home}{bs}  ; this way read point is kept
        send +{down 2}{bs}  ; go down twice to makes sure all formats are deleted
        Vim.SM.SaveHTML()
        send ^{home}  ; put the caret on top
        clip(NewHTML,, true, true)
      }
      Vim.SM.Reload()
      Vim.SM.WaitTextFocus()
      send {right}
    } else {  ; image only
      RegExMatch(data, "(alt=""|alt=)\K.+?(?=(""|\s+src=))", LatexFormula)  ; getting formula from alt=""
      RegExMatch(data, "src=""file:\/\/\/\K[^""]+", LatexPath)  ; getting path from src=""
      LatexPath := StrReplace(LatexPath, "[PrimaryStorage]", Vim.SM.GetCollPath() . "\elements\")
      if (InStr(LatexFormula, "{\displaystyle")) {  ; from wikipedia, wikibooks, etc
        LatexFormula := StrReplace(LatexFormula, "{\displaystyle")
        LatexFormula := RegExReplace(LatexFormula, "}$")
      } else if (InStr(LatexFormula, "\displaystyle{")) {  ; from Better Explained
        LatexFormula := StrReplace(LatexFormula, "\displaystyle{")
        LatexFormula := RegExReplace(LatexFormula, "}$")
      }
      LatexFormula := RegExReplace(LatexFormula, "^\s+|\s+$")  ; removing start and end whitespaces
      LatexFormula := RegExReplace(LatexFormula, "^\\\[|\\\]$")  ; removing start \[ and end ]\ (in Better Explained)
      LatexFormula := HTML_decode(LatexFormula)
      clip(LatexFormula, true, true)
      FileDelete % LatexPath
      Vim.State.SetMode("Vim_Visual")
    }
  }
  WinClip.Restore(ClipData)
return

DownloadLatex:
  UrlDownloadToFile, % LatexLink, % LatexPath
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))  ; SuperMemo Plan window
!r::ControlClickWinCoord(39, A_CaretY)
!t::send !mlt  ; Totals

!a::  ; insert activity
  SetDefaultKeyboard(0x0409)  ; english-US	
  gui, PlanInsert:Add, Text,, &Activity:
  list := "Break||Gaming|Coding|Sports|Social|Writing|Family|Passive|Meal|Rest"
        . "|Planning|Investing|SM|Shower|IM|Piano|Meditation|Job|Misc|Out|Singing"
        . "|Calligraphy|Drawing"
  gui, PlanInsert:Add, Combobox, vActivity gAutoComplete, % list
  gui, PlanInsert:Add, CheckBox, vNoSplit, &Do not split current activity
  gui, PlanInsert:Add, Button, default, &Insert
  KeyWait Alt
  gui, PlanInsert:Show,, Insert Activity
return

PlanInsertGuiEscape:
PlanInsertGuiClose:
  gui destroy
return

PlanInsertButtonInsert:
  KeyWait alt
  gui submit
  gui destroy
  FormatTime, CurrTime,, HH:mm
  WinActivate, ahk_class TPlanDlg
  if (!NoSplit) {
    send ^t  ; split
    WinWaitActive, ahk_class TInputDlg,, 0
    send {enter}
  }
  ControlSend, TStringGrid1, {down}{ins}, ahk_class TPlanDlg  ; inserting one activity below the current selected activity and start editing
  WinActivate, ahk_class TPlanDlg  ; just in case
  ; Cannot use ControlSendRaw, uppercase will become lowercase
  send % "{raw}" . activity
  send % "+{tab}" . CurrTime
  send {enter}^s
  if activity in Break,Sports,Piano,Out
    run b  ; my personal backup script
  Vim.State.SetNormal(true)
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg"))
!+d::ControlClickWinCoord(250, 66)
!+s::ControlClickWinCoord(173, 67)

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TElParamDlg"))
; Task value script, modified from Naess's priority script
!0::
Numpad0::
NumpadIns::Vim.SM.SetTaskValue(9024.74,9999)

!1::
Numpad1::
NumpadEnd::Vim.SM.SetTaskValue(7055.79,9024.74)

!2::
Numpad2::
NumpadDown::Vim.SM.SetTaskValue(5775.76,7055.78)

!3::
Numpad3::
NumpadPgdn::Vim.SM.SetTaskValue(4625,5775.75)

!4::
Numpad4::
NumpadLeft::Vim.SM.SetTaskValue(3721.04,4624)

!5::
Numpad5::
NumpadClear::Vim.SM.SetTaskValue(2808.86,3721.03)

!6::
Numpad6::
NumpadRight::Vim.SM.SetTaskValue(1849.18,2808.85)

!7::
Numpad7::
NumpadHome::Vim.SM.SetTaskValue(841.32,1849.17)

!8::
Numpad8::
NumpadUp::Vim.SM.SetTaskValue(360.77,841.31)

!9::
Numpad9::
NumpadPgup::Vim.SM.SetTaskValue(0,360.76)

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TPriorityDlg"))  ; priority window (alt+p)
enter::
  prio := ControlGetText("TEdit5")
  if (RegExMatch(prio, "^\."))
    ControlSetText, TEdit5, % "0" . prio
  send {enter}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMyFindDlg"))
; So ctrl+ff (hold ctrl and press f twice) could be a shorthand for search clipboard
^f::send ^v{enter}

#if (Vim.IsVimGroup() && Vim.SM.IsNavigatingPlan() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_d"))
d::
  Vim.State.SetMode("SMVim_PlanDragging")
  MouseGetPos, XCoordSaved, YCoordSaved
  ; Get current entry coords
  send {home}{right}
  x := A_CaretX, y := A_CaretY
  send {f2}  ; sometimes A_Caret isn't accurate
  ControlFocusWait("TInplaceEdit1")
  WaitCaretMove(x, y)
  IniYCoord := A_CaretY
  send +{tab}
  ; Calculate entry height
  send {down}{right}
  x := A_CaretX, y := A_CaretY
  send {f2}
  ControlFocusWait("TInplaceEdit1")
  WaitCaretMove(x, y)
  PlanEntryGap := A_CaretY - IniYCoord
  send {up}{left}  ; go back
  ; Move to position
  MouseMove, 20, % IniYCoord + PlanEntryGap / 2, 0
  MouseGetPos, IniXCoord, IniYCoord
  click down
return

#if (Vim.IsVimGroup() && Vim.SM.IsNavigatingPlan() && Vim.State.IsCurrentVimMode("SMVim_PlanDragging"))
j::
  Vim.State.n := Vim.State.n ? Vim.State.n : 1
  MouseMove, 0, % Vim.State.n * PlanEntryGap, 0, R
  Vim.State.n := 0
return

k::
  Vim.State.n := Vim.State.n ? Vim.State.n : 1
  MouseMove, 0, % -1 * Vim.State.n * PlanEntryGap, 0, R
  Vim.State.n := 0
return

p::
  MouseMove, 0, % PlanEntryGap, 0, R  ; put after
+p::  ; put before
  click up
  MouseGetPos, XCoord, YCoord
  if (XCoord == IniXCoord && YCoord == IniYCoord)  ; no change
    click  ; to unfix
  MouseMove, XCoordSaved, YCoordSaved, 0
  SMVimPlanDraggingPut := true
  Vim.State.SetMode("Vim_Normal")
return

; Incremental video
#if (WinActive("ahk_group Browsers") || WinActive("ahk_class TElWind"))
^!s::  ; sync time
!+s::  ; sync time but browser tab stays open
^+!s::  ; sync time and keep learning
^!`::  ; clear time
!+`::  ; clear time but browser tab stays open
^+!`::  ; clear time and keep learning
  KeyWait alt
  if (WinActive("ahk_group Browsers") && !Vim.Browser.VidTime) {
    send {esc 2}
    Vim.Browser.GetTitleSourceDate("", true)
    if (!InStr(A_ThisHotkey, "``")) {
      Vim.Browser.VidTime := Vim.Browser.GetVidtime()
      if (!Vim.Browser.VidTime) {
        Vim.Browser.VidTime := InputBox("Video Time Stamp", "Enter video time stamp.",, 192, 128)
        if (!Vim.Browser.VidTime || ErrorLevel)
          return
      }
    }
    WinGet, hwnd, ID, A
    if (WinGetTitle("ahk_class TElWind") != Vim.Browser.title) {
      WinActivate, ahk_class TElWind
      MsgBox, 4,, Titles don't match. Continue?
      IfMsgBox, no, {
        Vim.Browser.Clear()
        return
      }
      WinActivate % "ahk_id " . hwnd
    }
    if (InStr(A_ThisHotkey, "^"))  ; hotkeys with ctrl will close the tab
      send ^w
    WinActivate, ahk_class TElWind
  }
  if (!Vim.Browser.VidTime && !InStr(A_ThisHotkey, "``")) {
    Vim.Browser.VidTime := InputBox("Video Time Stamp", "Enter video time stamp.",, 192, 128)
    if (!Vim.Browser.VidTime || ErrorLevel)
      return
  }
  ToolTip := EditRef := BL := false
  if (Vim.SM.IsPassiveColl()) {
    Vim.SM.DeselectAllComponents()
    sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime)
    send q^t{f9}
    WinWaitActive, ahk_class TScriptEditor,, 0
    ControlGetText, script, TMemo1
    if (InStr(A_ThisHotkey, "``") || !sec)
      sec := 0
    if (InStr(script, "youtube.com")) {
      replacement := "&t=" . sec . "s"
      match := "&t=.*s"
    } else if (InStr(script, "bilibili.com")) {
      replacement := "&t=" . sec
      match := "&t=.*"
      BL := true
    } else {
      send {esc 2}
      EditRef := true
    }
    if (!EditRef) {  ; time in script component
      if (RegExMatch(script, match)) {
        ControlSetText, TMemo1, % RegExReplace(script, match, replacement)
      } else {
        if (BL && !RegExMatch(script, "p=[0-9]+"))
          replacement := "?" . replacement
        ControlSetText, TMemo1, % script . replacement
      }
      send !o{esc}  ; close script editor
      ToolTip := true
    } else {  ; time in comment
      if (InStr(A_ThisHotkey, "``"))
        Vim.Browser.VidTime := "0:00"
      Vim.Browser.comment := Vim.Browser.VidTime
      Vim.SM.PostMsg(660, true)
      WinWaitActive, ahk_class TInputDlg,, 0
      ControlGetText, OldRef, TMemo1
      NewComment := "`n#Comment: " . Vim.Browser.comment . "`n"
      if (InStr(OldRef, "#Comment") && Vim.Browser.comment) {
        NewRef := RegExReplace(OldRef, "#Comment: .*", NewComment)
      } else {
        NewRef := OldRef . NewComment
      }
      ControlSetText, TMemo1, % NewRef
      send !{enter}
    }
  }
  WinActivate, ahk_class TElWind
  if (InStr(A_ThisHotkey, "^+!")) {
    Vim.SM.Learn()
    Vim.SM.PlayIfCertainColl()
  }
  if (ToolTip)
    ToolTip("Time stamp in script component set as " . sec . "s")
  Vim.Browser.Clear()
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind")
                      && (title := WinGetActiveTitle())
                      && (RegExMatch(title, "(?<=^p)[0-9]+(?= )", page) || epub := InStr(title, "|")))
!s::
  if (page) {
    clip := page
  } else if (epub) {
    RegExMatch(title, ".*?(?= \|)", clip)
  }
  Clipboard := clip
  ToolTip("Copied " . clip)
return