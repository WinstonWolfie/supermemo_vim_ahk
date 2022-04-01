#If Vim.IsVimGroup() && WinActive("ahk_class TElWind")
^!.::  ; find [...] and insert
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
      Return
    }
  } else if Vim.SM.IsEditingHTML() {
    send {f3}
    WinWaitNotActive, ahk_class TElWind,, 0  ; faster than wait for element window to be active
    SendInput {raw}[...]
    send {enter}
    WinWaitNotActive, ahk_class TMyFindDlg,, 0  ; faster than wait for element window to be active
    send {right}^{enter}
    WinWaitActive, ahk_class TCommanderDlg,, 0.25
    if ErrorLevel {
      Vim.ToolTip("Not found.")
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
  if WinActive("ahk_class TElWind")
    send {enter}
  Vim.State.SetNormal()
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
  if WinActive("ahk_class TElWind")
    send {enter}
  Vim.State.SetNormal()
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

#If Vim.IsVimGroup() && Vim.SM.IsEditingHTML()
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
  FormatTime, current_time_display,, yyyy-MM-dd HH:mm:ss:%A_msec%
  current_time_file_name := RegExReplace(current_time_display, " |:", "-")
  Vim.State.SetMode("Vim_Normal")
  ClipSaved := ClipboardAll
  Clipboard := ""
  send ^c
  ClipWait 0.6
  sleep 20
  If Vim.HTML.ClipboardGet_HTML( Data ) {
    ; To do: detect selection contents
    ; if RegExMatch(data, "<IMG[^>]*>\K[\s\S]+(?=<!--EndFragment-->)") {  ; match end of first IMG tag until start of last EndFragment tag
      ; Vim.ToolTip("Please select text or image only.")
      ; Clipboard := ClipSaved
      ; Return
    ; } else
    if !InStr(data, "<IMG") {  ; text only
      send {bs}^{f7}  ; set read point
      WinGetText, visible_text, ahk_class TElWind
      RegExMatch(visible_text, "(?<=LearnBar\r\n)(.*?)(?= \(SuperMemo 18: )", collection_name)
      RegExMatch(visible_text, "(?<= \(SuperMemo 18: )(.*)(?=\)\r\n)", collection_path)
      latex_formula := RegExReplace(Clipboard, "\\$", "\ ")  ; just in case someone would leave a \ at the end
      latex_formula := Enc_Uri(latex_formula)
      latex_link := "https://latex.vimsky.com/test.image.latex.php?fmt=png&val=%255Cdpi%257B150%257D%2520%255Cnormalsize%2520%257B%255Ccolor%257Bwhite%257D%2520" . latex_formula . "%257D&dl=1"
      latex_folder_path := collection_path . collection_name . "\LaTeX"
      latex_path := latex_folder_path . "\" . current_time_file_name . ".png"
      SetTimer, DownloadLaTeX, -1
      FileCreateDir % latex_folder_path
      img_html = <img alt="%Clipboard%" src="%latex_path%">
      clip(img_html, true, true)
      send ^+1
      Vim.SM.WaitTextSave()
      if ErrorLevel
        Return
      send ^t
      Vim.SM.WaitTextFocus()
      Clipboard := ""
      send !{f12}fc  ; copy file path
      ClipWait 0.2
      sleep 20
      html_path := Clipboard
      FileRead, html, % html_path
      if !html
        html := img_html  ; in case the html is picture only and somehow not saved
      
      /* recommended css setting for fuck_lexicon class:
      .fuck_lexicon {
        position: absolute;
        left: -9999px;
        top: -9999px;
      }
      */
      
      fuck_lexicon = <SPAN class=fuck_lexicon>Last LaTeX to image conversion: %current_time_display%</SPAN>
      if InStr(html, "<SPAN class=fuck_lexicon>Last LaTeX to image conversion: ") {  ; converted before
        Vim.SM.WaitTextSave()
        if ErrorLevel
          Return
        new_html := RegExReplace(html, "<SPAN class=fuck_lexicon>Last LaTeX to image conversion: (.*?)(<\/SPAN>|$)", fuck_lexicon)
        FileDelete % html_path
        FileAppend, % new_html, % html_path
        send !{home}!{left}  ; refresh so the conversion time would display correctly
      } else {  ; first time conversion
        new_html := html . "`n" . fuck_lexicon
        Vim.SM.MoveAboveRef(true)
        send ^+{home}{bs}{esc}  ; delete everything and save
        send ^+{f6}  ; opens notepad
        WinWaitNotActive, ahk_class TElWind,, 0
        send ^w
        WinWaitActive, ahk_class TElWind,, 0
        send ^{home}  ; put the caret on top
        clip(new_html,, true)
        send ^+{home}^+1
        Vim.SM.WaitTextSave()
        if ErrorLevel {
          Clipboard := ClipSaved
          Return
        }
        ; no need for !home!left refreshing here
      }
      send !{f7}  ; go to read point
      sleep 250
      send {right}
    } else {  ; image only
      RegExMatch(data, "(alt=""|alt=)\K.+?(?=(""|\s+src=))", latex_formula)  ; getting formula from alt=""
      RegExMatch(data, "src=""file:\/\/\/\K[^""]+", latex_path)  ; getting path from src=""
      if InStr(latex_formula, "{\displaystyle") {  ; from wikipedia, wikibooks, etc
        latex_formula := StrReplace(latex_formula, "{\displaystyle")
        latex_formula := RegExReplace(latex_formula, "}$")
      } else if InStr(latex_formula, "\displaystyle{") {  ; from better explained
        latex_formula := StrReplace(latex_formula, "\displaystyle{")
        latex_formula := RegExReplace(latex_formula, "}$")
      }
      latex_formula := RegExReplace(latex_formula, "^\s+|\s+$")  ; removing start and end whitespaces
      latex_formula := RegExReplace(latex_formula, "^\\\[|\\\]$")  ; removing start \[ and end ]\ (in better explained)
      latex_formula := html_decode(latex_formula)
      clip(latex_formula, true, true)
      FileDelete % latex_path
    }
  }
  Clipboard := ClipSaved
Return

DownloadLaTeX:
  UrlDownloadToFile, % latex_link, % latex_path
Return

#If Vim.IsVimGroup() and WinActive("ahk_class TPlanDlg")  ; SuperMemo Plan window
!a::  ; insert activity
  Vim.State.SetNormal()
  Gui, PlanInsert:Add, Text,, &Activity:
  list = Break||Gaming|Coding|Sports|Social|Writing|Family|Passive|Meal|Rest|School|Planning|Investing|SM|Shower|IM
  Gui, PlanInsert:Add, Combobox, vActivity gAutoComplete, %list%
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
  if !NoSplit {
    send ^t  ; split
    WinWaitActive, ahk_class TInputDlg,, 0
    send {enter}
    WinWaitActive, ahk_class TPlanDlg,, 0
  }
  send {down}{Insert}  ; inserting one activity below the current selected activity and start editing
  SendInput {raw}%activity%  ; SendInput is faster than clip() here
  send !b  ; begin
  WinWaitNotActive, ahk_class TPlanDlg,, 0.3  ; wait for "Mark the slot with the drop to efficiency?"
  if !ErrorLevel
    send y
  WinWaitActive, ahk_class TPlanDlg,, 0
  send ^s{esc}  ; save and exits
  WinWaitNotActive, ahk_class TPlanDlg,, 0
  send ^{enter}{enter}  ; cancel alarm
  send ^{enter}  ; use commander to open Plan; seems to be a more reliable option than {alt}kp or ^p
  SendInput {raw}pl  ; open Plan again
  send {enter}
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
