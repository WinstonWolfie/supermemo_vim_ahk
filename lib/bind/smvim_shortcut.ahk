#If (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!.::  ; find [...] and insert
  ReleaseKey("ctrl")
  Vim.SM.DeselectAllComponents()
  send q
  Vim.SM.WaitTextFocus()
  ; this is to make sure this finds in the question field
  if Vim.SM.IsEditingPlainText() {
    send ^a
    pos := InStr(clip(), "[...]")
    if pos {
      pos += 4
      SendInput {left}{right %pos%}
    } else {
      Vim.ToolTip("Not found.")
      Vim.State.SetNormal()
      Return
    }
  } else if Vim.SM.IsEditingHTML() {
    send {f3}
    WinWaitActive, ahk_class TMyFindDlg,, 0
    if (ErrorLevel) {
      send {esc}^{enter}h{enter}{f3}
      WinWaitActive, ahk_class TMyFindDlg,, 0
      if (ErrorLevel)
        Return
    }
		SetDefaultKeyboard(0x0409)  ; english-US	
    SendInput {raw}[...]
    send {enter}
    WinWaitNotActive, ahk_class TMyFindDlg,, 0  ; faster than wait for element window to be active
    send {right}^{enter}
    WinWaitActive, ahk_class TCommanderDlg,, 0
    if ErrorLevel {
      Vim.ToolTip("Not found.")
      Vim.State.SetNormal()
      send {esc}^{enter}h{enter}{esc}
      Return
    }
    send h{enter}q
    if WinExist("ahk_class TMyFindDlg")  ; clears search box window
      WinClose
  }
  Vim.State.SetMode("Insert")
return

^!c::  ; change default *c*oncept group
	ReleaseKey("ctrl")
  ControlClickWinCoord(723, 67)
  Vim.State.SetMode("Vim_Normal")
Return

~^+f12::  ; bomb format with no confirmation
  send {enter}
  Vim.State.SetNormal()
return

>!>+bs::  ; for laptop
>^>+bs::  ; for processing pending queue Advanced English 2018: delete element and keep learning
  ReleaseKey("Ctrl")
  ReleaseKey("Shift")
  WinGetTitle, CurrentTitle, A
  send ^+{del}
  WinWaitNotActive, ahk_class TElWind,, 0  ; wait for "Delete element?"
  send {enter}
  WinWaitActive, ahk_class TElWind,, 0  ; wait for element window to become focused again
  WinWaitTitleChange(CurrentTitle, 500)
  ; no need for sleep here
  if (WinActive("ahk_class TElWind"))
    ControlSend, TBitBtn2, {enter}, ahk_class TElWind
  Vim.State.SetNormal()
  Vim.SM.EnterInsertIfSpelling()
return

>!>+\::  ; for laptop
>^>+\::  ; Done! and keep learning
  ReleaseKey("Ctrl")
  ReleaseKey("Shift")
  WinGetTitle, CurrentTitle, A
  send ^+{enter}
  WinWaitNotActive, ahk_class TElWind,, 0  ; "Do you want to remove all element contents from the collection?"
  send {enter}
  WinWaitNotActive, ahk_class TElWind,, 0  ; wait for "Delete element?"
  send {enter}
  WinWaitActive, ahk_class TElWind,, 0  ; wait for element window to become focused again
  WinWaitTitleChange(CurrentTitle, 500)
  sleep 50
  if (WinActive("ahk_class TElWind"))
    ControlSend, TBitBtn2, {enter}, ahk_class TElWind
  Vim.State.SetNormal()
  Vim.SM.EnterInsertIfSpelling()
return

^!+g::  ; change element's concept *g*roup
  send ^+p!g
  Vim.State.SetNormal()
return

^!t::
  send !t
  GroupAdd, SMAltT, ahk_class TChoicesDlg
  GroupAdd, SMAltT, ahk_class TTitleEdit
  WinWaitActive, ahk_group SMAltT,, 0
  if (WinActive("ahk_class TChoicesDlg")) {
    send {enter}
    WinWaitActive, ahk_class TTitleEdit,, 0
  }
  if (WinActive("ahk_class TTitleEdit")) {
    ControlFocusWait("TMemo1")
    send ^v{enter}
  }
Return

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

#If (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
; more intuitive inter-element linking, inspired by obsidian
; 1. go to the element you want to link to and press ctrl+alt+g
; 2. go to the element you want to have the hyperlink, select text and press ctrl+alt+k
^!g::
  WinClip.Snap(ClipDataElemLink)
  send ^g^c{esc}
  Vim.State.SetNormal()
return

#If (Vim.IsVimGroup() && Vim.SM.IsEditingHTML())
^!k::
  if (RegExMatch(Clipboard, "^https?:\/\/") || RegExMatch(Clipboard, "^file:\/\/\/")) {
    link := Clipboard
  } else if (RegExMatch(Clipboard, "^#")) {
    link := "SuperMemoElementNo=(" . RegExReplace(Clipboard, "^#") . ")"
  } else {
    link := ""
  }
  if (!clip() || !link)  ; no selection
    Return
  send ^k
  WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame,, 2  ; a bit more delay since everybody knows how slow IE can be
  clip(link)
  send {enter}
  Vim.Caret.SwitchToSameWindow()  ; refresh caret
  if (ClipDataElemLink) {
    WinClip.Restore(ClipDataElemLink)
    ClipDataElemLink := ""
  }
  Vim.State.SetNormal()
return

^!l::
  ReleaseKey("ctrl")
  KeyWait alt
  FormatTime, CurrentTimeDisplay,, % "yyyy-MM-dd HH:mm:ss:" . A_msec
  CurrentTimeFileName := RegExReplace(CurrentTimeDisplay, " |:", "-")
  Vim.State.SetMode("Vim_Normal")
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  If (Vim.HTML.ClipboardGet_HTML(Data)) {
    ; To do: detect selection contents
    ; if (RegExMatch(data, "<IMG[^>]*>\K[\s\S]+(?=<!--EndFragment-->)")) {  ; match end of first IMG tag until start of last EndFragment tag
      ; Vim.ToolTip("Please select text or image only.")
      ; Clipboard := ClipSaved
      ; Return
    ; } else
    if (!InStr(data, "<IMG")) {  ; text only
      send {bs}^{f7}  ; set read point
      WinGetText, VisibleText, ahk_class TElWind
      RegExMatch(VisibleText, "(?<=LearnBar\r\n)(.*?)(?= \(SuperMemo 18: )", CollectionName)
      RegExMatch(VisibleText, "(?<= \(SuperMemo 18: )(.*)(?=\)\r\n)", CollectionPath)
      LatexFormula := RegExReplace(Clipboard, "\\$", "\ ")  ; just in case someone would leave a \ at the end
      LatexFormula := Enc_Uri(LatexFormula)
      LatexLink := "https://latex.vimsky.com/test.image.latex.php?fmt=png&val=%255Cdpi%257B150%257D%2520%255Cnormalsize%2520%257B%255Ccolor%257Bwhite%257D%2520" . LatexFormula . "%257D&dl=1"
      LatexFolderPath := CollectionPath . CollectionName . "\LaTeX"
      LatexPath := LatexFolderPath . "\" . CurrentTimeFileName . ".png"
      SetTimer, DownloadLatex, -1
      FileCreateDir % LatexFolderPath
      ImgHTML = <img alt="%Clipboard%" src="%LatexPath%">
      clip(ImgHTML, true, true)
      send ^+1
      Vim.SM.SaveHTML()
      Clipboard := ""
      send !{f12}fc  ; copy file path
      ClipWait 2
      HTMLPath := Clipboard
      FileRead, HTML, % HTMLPath
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
      
      fuck_lexicon = <SPAN class=fuck_lexicon>Last LaTeX to image conversion: %CurrentTimeDisplay%</SPAN>
      if (InStr(HTML, "<SPAN class=fuck_lexicon>Last LaTeX to image conversion: ")) {  ; converted before
        send {esc}
        Vim.SM.WaitTextExit(5000)
        NewHTML := RegExReplace(HTML, "<SPAN class=fuck_lexicon>Last LaTeX to image conversion: (.*?)(<\/SPAN>|$)", fuck_lexicon)
        FileDelete % HTMLPath
        FileAppend, % NewHTML, % HTMLPath
        send !{home}
        sleep 100
        send !{left}
      } else {  ; first time conversion
        NewHTML := HTML . "`n" . fuck_lexicon
        Vim.SM.MoveAboveRef(true)
        send ^+{home}{bs}  ; this way read point is kept
        send +{down 2}{bs}  ; and makes sure all formats are deleted
        Vim.SM.SaveHTML()
        send ^{home}  ; put the caret on top
        clip(NewHTML,, true)
        send ^+{home}^+1
        ; no need for !home!left refreshing here
        send !{f7}  ; go to read point
      }
      sleep 250
      send {right}
    } else {  ; image only
      RegExMatch(data, "(alt=""|alt=)\K.+?(?=(""|\s+src=))", LatexFormula)  ; getting formula from alt=""
      RegExMatch(data, "src=""file:\/\/\/\K[^""]+", LatexPath)  ; getting path from src=""
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
Return

DownloadLatex:
  UrlDownloadToFile, % LatexLink, % LatexPath
Return

#If (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))  ; SuperMemo Plan window
!a::  ; insert activity
  Gui, PlanInsert:Add, Text,, &Activity:
  list := "Break||Gaming|Coding|Sports|Social|Writing|Family|Passive|Meal|Rest|School|Planning|Investing|SM|Shower|IM|Piano|Meditation|Translation|Job"
  Gui, PlanInsert:Add, Combobox, vActivity gAutoComplete, % list
  Gui, PlanInsert:Add, CheckBox, vNoSplit, &Do not split current activity
  Gui, PlanInsert:Add, Button, default, &Insert
  KeyWait Alt
  Gui, PlanInsert:Show,, Insert Activity
  SetDefaultKeyboard(0x0409)  ; english-US	
Return

PlanInsertGuiEscape:
PlanInsertGuiClose:
  Gui, Destroy
return

PlanInsertButtonInsert:
  KeyWait alt
  Gui, Submit
  Gui, Destroy
  FormatTime, CurrentTime,, HH:mm
  WinActivate, ahk_class TPlanDlg
  if (!NoSplit) {
    send ^t  ; split
    WinWaitActive, ahk_class TInputDlg,, 0
    send {enter}
    ; WinWaitActive, ahk_class TPlanDlg,, 0
  }
  ControlSend, TStringGrid1, {down}{ins}, ahk_class TPlanDlg  ; inserting one activity below the current selected activity and start editing
  WinActivate, ahk_class TPlanDlg  ; just in case
  ; cannot use ControlSendRaw, uppercase will become lowercase
  SendInput {raw}%activity%  ; SendInput is faster than clip() here
  send +{tab}
  SendInput {raw}%CurrentTime%
  send {enter}^s
  if (Activity == "Break" || Activity == "Sports" || Activity == "Piano")
    run b  ; my personal backup script
  Vim.State.SetNormal(true)
return

#If (Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg"))
!+d::ControlClickWinCoord(250, 66)
!+s::ControlClickWinCoord(173, 67)

#If Vim.State.Vim.Enabled && WinActive("ahk_class TElParamDlg")
; Task value script, modified from Naess's priority script
!0::
!Numpad0::
!NumpadIns::Vim.SM.SetTaskValue(9024.74,9999)

!1::
!Numpad1::
!NumpadEnd::Vim.SM.SetTaskValue(7055.79,9024.74)

!2::
!Numpad2::
!NumpadDown::Vim.SM.SetTaskValue(5775.76,7055.78)

!3::
!Numpad3::
!NumpadPgdn::Vim.SM.SetTaskValue(4625,5775.75)

!4::
!Numpad4::
!NumpadLeft::Vim.SM.SetTaskValue(3721.04,4624)

!5::
!Numpad5::
!NumpadClear::Vim.SM.SetTaskValue(2808.86,3721.03)

!6::
!Numpad6::
!NumpadRight::Vim.SM.SetTaskValue(1849.18,2808.85)

!7::
!Numpad7::
!NumpadHome::Vim.SM.SetTaskValue(841.32,1849.17)

!8::
!Numpad8::
!NumpadUp::Vim.SM.SetTaskValue(360.77,841.31)

!9::
!Numpad9::
!NumpadPgup::Vim.SM.SetTaskValue(0,360.76)