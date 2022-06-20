#If Vim.IsVimGroup() && WinActive("ahk_class TElWind")
^!.::  ; find [...] and insert
  Vim.ReleaseKey("ctrl")
  Vim.SM.DeselectAllComponents()
  send q
  Vim.SM.WaitTextFocus()
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
  } else if Vim.SM.IsEditingHtml() {
    send {f3}
    WinWaitActive, ahk_class TMyFindDlg,, 0
    if (ErrorLevel) {
      send {esc}^{enter}h{enter}{f3}
      WinWaitActive, ahk_class TMyFindDlg,, 0
      if (ErrorLevel)
        Return
    }
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
  KeyWait alt
  FindClick(A_ScriptDir . "\lib\bind\util\concept_lightbulb.png")
  Vim.State.SetMode("Vim_Normal")
Return

~^+f12::  ; bomb format with no confirmation
  send {enter}
  Vim.State.SetNormal()
return

>!>+bs::  ; for laptop
>^>+bs::  ; for processing pending queue Advanced English 2018: delete element and keep learning
  Vim.ReleaseKey("Ctrl")
  Vim.ReleaseKey("Shift")
  WinGetTitle, current_title, A
  send ^+{del}
  WinWaitNotActive, ahk_class TElWind,, 0  ; wait for "Delete element?"
  send {enter}
  WinWaitActive, ahk_class TElWind,, 0  ; wait for element window to become focused again
  Vim.WinWaitTitleChange(current_title)
  if (WinActive("ahk_class TElWind"))
    send {enter}
  Vim.State.SetNormal()
  Vim.SM.EnterInsertIfSpelling()
return

>!>+\::  ; for laptop
>^>+\::  ; Done! and keep learning
  Vim.ReleaseKey("Ctrl")
  Vim.ReleaseKey("Shift")
  WinGetTitle, current_title, A
  send ^+{enter}
  WinWaitNotActive, ahk_class TElWind,, 0  ; "Do you want to remove all element contents from the collection?"
  send {enter}
  WinWaitNotActive, ahk_class TElWind,, 0  ; wait for "Delete element?"
  send {enter}
  WinWaitActive, ahk_class TElWind,, 0  ; wait for element window to become focused again
  Vim.WinWaitTitleChange(current_title)
  sleep 100
  if (WinActive("ahk_class TElWind"))
    send {alt}ll
  Vim.State.SetNormal()
  Vim.SM.EnterInsertIfSpelling()
return

^!+g::  ; change element's concept *g*roup
  send ^+p!g
  Vim.State.SetNormal()
return

; more intuitive inter-element linking, inspired by obsidian
; 1. go to the element you want to link to and press ctrl+alt+g
; 2. go to the element you want to have the hyperlink, select text and press ctrl+alt+k
^!g::
  send ^g^c{esc}
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

#If (Vim.IsVimGroup() && Vim.SM.IsEditingHtml())
^!k::
  element_number := RegExReplace(Clipboard, "^#")
  if !clip()  ; no selection
    Return
  send ^k
  WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame,, 2  ; a bit more delay since everybody knows how slow IE can be
  clip("SuperMemoElementNo=(" . element_number . ")")
  send {enter}
  Vim.Caret.SwitchToSameWindow()  ; refresh caret
  Vim.State.SetNormal()
return

^!l::
  Vim.ReleaseKey("ctrl")
  KeyWait alt
  FormatTime, CurrentTimeDisplay,, yyyy-MM-dd HH:mm:ss:%A_msec%
  CurrentTimeFileName := RegExReplace(CurrentTimeDisplay, " |:", "-")
  Vim.State.SetMode("Vim_Normal")
  ClipSaved := ClipboardAll
  Clipboard := ""
  send ^c
  ClipWait 0.6
  If (Vim.Html.ClipboardGet_Html(Data)) {
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
      ImgHtml = <img alt="%Clipboard%" src="%LatexPath%">
      ; SetClipboardHTML(ImgHtml)
      ; send ^v{esc}
      clip(ImgHtml, true, true)
      send ^+1{esc}
      send ^+{f6}  ; opens notepad
      WinWaitNotActive, ahk_class TElWind,, 5
      WinKill, ahk_class Notepad
      WinActivate, ahk_class TElWind
      ; Vim.SM.WaitTextSave()
      ; send ^t
      ; Vim.SM.WaitTextFocus()
      Clipboard := ""
      ; send !{f12}fc  ; copy file path
      DetectHiddenWindows, On
      WinGet, vWinList, List, ahk_class TPUtilWindow
      Loop, %vWinList%
      {
        hWnd := vWinList%A_Index%
        WinGet, vWinProcess, ProcessName, ahk_id %hWnd%
        if (vWinProcess = "sm18.exe")
          SendMessage,0x111,987,0,,ahk_id %hWnd%  ; copy file path
      }
      ClipWait 0.2
      HtmlPath := Clipboard
      FileRead, Html, % HtmlPath
      if (!Html)
        Html := ImgHtml  ; in case the Html is picture only and somehow not saved
      
      /*
        recommended css setting for fuck_lexicon class:
        .fuck_lexicon {
          position: absolute;
          left: -9999px;
          top: -9999px;
        }
      */
      
      fuck_lexicon = <SPAN class=fuck_lexicon>Last LaTeX to image conversion: %CurrentTimeDisplay%</SPAN>
      if (InStr(Html, "<SPAN class=fuck_lexicon>Last LaTeX to image conversion: ")) {  ; converted before
        Vim.SM.WaitTextSave(5000)
        NewHtml := RegExReplace(Html, "<SPAN class=fuck_lexicon>Last LaTeX to image conversion: (.*?)(<\/SPAN>|$)", fuck_lexicon)
        FileDelete % HtmlPath
        FileAppend, % NewHtml, % HtmlPath
        ; send !{home}!{left}  ; refresh so the conversion time would display correctly
      } else {  ; first time conversion
        NewHtml := Html . "`n" . fuck_lexicon
        Vim.SM.MoveAboveRef(true)
        ; this way read point is kept
        send ^+{home}{bs}{esc}  ; delete everything and save
        send ^+{f6}  ; opens notepad
        WinWaitNotActive, ahk_class TElWind,, 5
        WinKill, ahk_class Notepad
        WinActivate, ahk_class TElWind
        send ^{home}  ; put the caret on top
        ; send !\\
        ; WinWaitNotActive, ahk_class TElWind,, 0
        ; if (!ErrorLevel)
        ;   send {enter}
        ; SetClipboardHTML(NewHtml)
        ; send ^v
        clip(NewHtml,, true)
        send ^+{home}^+1
        ; Vim.SM.WaitTextSave(5000)
        ; no need for !home!left refreshing here
      }
      send !{f7}  ; go to read point
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
      LatexFormula := Html_decode(LatexFormula)
      clip(LatexFormula, true, true)
      FileDelete % LatexPath
    }
  }
  Clipboard := ClipSaved
Return

DownloadLatex:
  UrlDownloadToFile, % LatexLink, % LatexPath
Return

#If Vim.IsVimGroup() and WinActive("ahk_class TPlanDlg")  ; SuperMemo Plan window
!a::  ; insert activity
  KeyWait Alt
  Gui, PlanInsert:Add, Text,, &Activity:
  list := "Break||Gaming|Coding|Sports|Social|Writing|Family|Passive|Meal|Rest|School|Planning|Investing|SM|Shower|IM|Piano|Meditation|Translation|Novel"
  Gui, PlanInsert:Add, Combobox, vActivity gAutoComplete, % list
  Gui, PlanInsert:Add, CheckBox, vNoSplit, &Do not split current activity
  Gui, PlanInsert:Add, Button, default, &Insert
  Gui, PlanInsert:Show,, Insert Activity
Return

PlanInsertGuiEscape:
PlanInsertGuiClose:
  Gui, Destroy
return

PlanInsertButtonInsert:
  Gui, Submit
  Gui, Destroy
  WinActivate, ahk_class TPlanDlg
  if (!NoSplit) {
    send ^t  ; split
    WinWaitActive, ahk_class TInputDlg,, 0
    send {enter}
    WinWaitActive, ahk_class TPlanDlg,, 0
  }
  send {down}{Insert}  ; inserting one activity below the current selected activity and start editing
  SendInput {raw}%activity%  ; SendInput is faster than clip() here
  send !b  ; begin
  WinWaitNotActive, ahk_class TPlanDlg,, 0.3  ; wait for "Mark the slot with the drop to efficiency?"
  if (!ErrorLevel)
    send y
  WinWaitActive, ahk_class TPlanDlg,, 0
  send ^s{esc}  ; save and exits
  WinWaitNotActive, ahk_class TPlanDlg,, 0
  send ^{enter}{enter}  ; cancel alarm
  WinWaitActive, ahk_class TElWind,, 0
  send {alt}kp  ; open Plan again
  if (Activity == "Break" || Activity == "Sports" || Activity == "Piano")
    run b  ; my personal backup script
  Vim.State.SetNormal(true)
return

#If Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg")
!+d::FindClick(A_ScriptDir . "\lib\bind\util\web_import_duplicates.png")

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
