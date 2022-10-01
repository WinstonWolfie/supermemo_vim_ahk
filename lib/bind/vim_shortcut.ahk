; Launch Settings
#if (Vim.State.Vim.Enabled)
^!+c::Vim.Setting.ShowGui()

; Check Mode
; #if (Vim.IsVimGroup())
; ^!+c::Vim.State.CheckMode(4, Vim.State.Mode)

; Suspend/restart
; Every other shortcut is disabled when vim_ahk is disabled, save for this one
#if
^!+v::Vim.State.ToggleEnabled()

#if (Vim.State.Vim.Enabled)
; Testing
; ^!+t::
;   send !{f10}fe  ; open registry editor
;   WinWaitActive, ahk_class TInputDlg,, 3
;   ControlGetText, OldRef, TMemo1
;   RegExMatch(OldRef, "#Title: .*", v)
;   msgbox % v
; return

; Shortcuts
^!r::reload

LAlt & RAlt::  ; for laptop
  KeyWait LAlt
  KeyWait RAlt
  send {AppsKey}
  Vim.State.SetMode("Insert")
return

#f::run % "D:\OneDrive\Miscellany\Programs\Everything\Everything64.exe"
^#h::send ^#{left}
^#l::send ^#{right}

^+!p::
  KeyWait ctrl
  KeyWait shift
  KeyWait alt
SMPlan:
  if (!WinExist("ahk_group SuperMemo")) {
    run C:\SuperMemo\systems\all.kno
    WinWaitActive, ahk_class TElWind,, 10
    if (ErrorLevel)
      return
  }
  if (WinExist("ahk_class TPlanDlg")) {
    ; Save first if there's an opened plan window
    ControlClickWinCoord(466, 46, "ahk_class TPlanDlg")  ; ControlSend doesn't work here in background
    WinClose
  }
  ControlGetText, CurrText, TBitBtn3, ahk_class TElWind
  if (CurrText == "Next repetition" || CurrText == "Show answer")  ; not to spoil answer
    ControlSend, TBitBtn3, {home}, ahk_class TElWind
	CurrTick := A_TickCount
  while (!WinExist("ahk_class TPlanDlg")) {
    if (WinExist("ahk_class TElParamDlg"))  ; ^+!p could trigger this
      WinClose
    if (WinExist("ahk_class TMsgDialog"))
      WinClose
    Vim.SM.PostMsg(243)  ; plan
		if (A_TickCount - CurrTick > 5000)
			return
  }
  WinActivate, ahk_class TPlanDlg
  Vim.State.SetMode("Vim_Normal")
return

; Browsers
#if (Vim.State.Vim.Enabled && WinActive("ahk_group Browsers"))
^!w::send ^w!{tab}  ; close tab and switch back

^!i::  ; open in *I*E
  Vim.Browser.RunInIE(Vim.Browser.ParseUrl(GetActiveBrowserURL()))
  ; run % "iexplore.exe " . Vim.Browser.ParseUrl(GetActiveBrowserURL())  ; RIP old method
Return

^!t::  ; copy title
	KeyWait ctrl
  Vim.Browser.GetInfo()
  ToolTip("Copied " . Vim.Browser.Title)
  Clipboard := Vim.Browser.Title
  Vim.Browser.Clear()
return

^!l::  ; copy link and parse *l*ink if if's from YT
  KeyWait ctrl
  KeyWait alt
  Vim.Browser.GetInfo()
  source := Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : ""
  date := Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : ""
  ToolTip("Copied " . Vim.Browser.Url . "`nTitle: " . Vim.Browser.Title . source . date)
  Clipboard := Vim.Browser.Url
return

^!d::  ; parse similar and opposite in google *d*efine
  WinClip.Snap(ClipData)
  WinClip.Clear()
  send ^c
  ClipWait 0.6
  if (ErrorLevel) {
    ToolTip("Text not found.")
    WinClip.Restore(ClipData)
    return
  }
  TempClip := RegExReplace(Clipboard, "(Similar|Synonymes).*\r\n", "`r`nsyn: ")
  TempClip := RegExReplace(TempClip, "(Opposite|Opuesta).*\r\n", "`r`nant: ")
  TempClip := RegExReplace(TempClip, "(?<![:]|(?<![^.])|(?<![^""]))\r\n(?!(syn:|ant:|\r\n))", ", ")
  Clipboard := TempClip := StrReplace(TempClip, "vulgar slang", "vulgar slang > ")
  ToolTip("Copied:`n`n" . TempClip)
return

; Incremental video: Import current YT video to SM
; Import current webpage to supermemo
; +!x::
; !x::
^+!a::
^!a::
  FormatTime, CurrTime,, % "yyyy-MM-dd HH:mm:ss:" . A_MSec
  WinClip.Snap(ClipData)
  WinGet, hwnd, ID, A
  KeyWait ctrl
  KeyWait shift
  KeyWait alt
  Vim.Browser.GetInfo(true, true)
  sleep 20
  HTMLText := clip("",, true,, true)
  SMVidImport := refreshed := false
  if (!HTMLText && InStr(Vim.Browser.url, "youtube.com")) {
    sleep 20
    SMVidImport := true
    FullPageText := Vim.Browser.GetFullPage("", true)
    Vim.Browser.VidTime := Vim.Browser.MatchYTTime(FullPageText)
    Vim.Browser.date := Vim.Browser.MatchYTDate(FullPageText)
    Vim.Browser.source .= ": " . Vim.Browser.MatchYTSource(FullPageText)
    Clipboard := Vim.Browser.url
  } else if (!HTMLText && InStr(Vim.Browser.url, "bilibili.com")) {
    sleep 20
    SMVidImport := true
    FullPageText := Vim.Browser.GetFullPage(Vim.Browser.title, true)
    Vim.Browser.VidTime := Vim.Browser.MatchBLTime(FullPageText)
    Vim.Browser.date := Vim.Browser.MatchBLDate(FullPageText)
    Clipboard := Vim.Browser.url
  } else {
    if (!HTMLText) {
      send ^a
      HTMLText := clip("",, true,, true)
      send {esc}
      if (!HTMLText) {
        ToolTip("Text not found.")
        return
      }
    }
    HTML := Vim.HTML.Clean(HTMLText, true)
    RegExMatch(HTML, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", HTML)
    source := Vim.Browser.Source ? "<br>#Source: " . Vim.Browser.Source : ""
    date := ""
    if (!InStr(A_ThisHotkey, "x")) {
      date := Vim.Browser.Date ? "<br>#Date: " . Vim.Browser.Date
                               : "<br>#Date: Imported on " . CurrTime
    }
    clipboard := HTML
              . "<br>#SuperMemo Reference:"
              . "<br>#Link: " . Vim.Browser.Url
              . source
              . date
              . "<br>#Title: " . Vim.Browser.Title
    ClipWait 10
  }
  InfoToolTip := "
  (
Url: " . Vim.Browser.url . "
Title : " . Vim.Browser.Title . "
  )"
  if (Vim.Browser.Source)
    InfoToolTip .= "`nSource: " . Vim.Browser.Source
  if (Vim.Browser.Date)
    InfoToolTip .= "`nDate: " . Vim.Browser.Date
  if (Vim.Browser.VidTime)
    InfoToolTip .= "`nTime stamp: " . Vim.Browser.VidTime
  ToolTip(InfoToolTip)
  prio := concept := ""
  if (InStr(A_ThisHotkey, "+")) {
    SetDefaultKeyboard(0x0409)  ; english-US	
    gui, SMImport:Add, Text,, &Priority:
    gui, SMImport:Add, Edit, vPrio
    gui, SMImport:Add, Text,, &Concept:
    gui, SMImport:Add, Edit, vConcept
    gui, SMImport:Add, Button, default, &Import
    gui, SMImport:Show,, SuperMemo Import
    return
  }
SMImportContinue:
  if (InStr(A_ThisHotkey, "x"))
    ControlSend,, {alt down}{shift down}h{shift up}{alt up}, % "ahk_id " . hwnd
  WinActivate, ahk_class TElWind
  ; Clear search highlight, just in case
  send ^{enter}  ; open commander
  send {text}h  ; Highlight: Clear
  send {enter}
  if (concept) {
    ConceptBefore := Vim.SM.GetCurrConcept()
    if (RegExMatch(ConceptBefore, "i)^" . concept)) {
      concept := ""
    } else {
      Vim.SM.ChangeDefaultConcept(concept)
    }
  }
  if (SMVidImport) {
    if (Vim.SM.IsPassiveCollection()) {
      gosub SMHyperLinkToTopic
    } else {
      gosub SMCtrlN
    }
  } else {
    WinWaitActive, ahk_class TElWind,, 0
    ; send !n
    ; Vim.SM.WaitTextFocus()
    ; send {AppsKey}xp  ; Paste HTML  ; not reliable
    send ^n
    WinWaitNotActive, ahk_class TElWind,, 0.8  ; could appear a loading bar
    if (!ErrorLevel)
      WinWaitActive, ahk_class TElWind,, 5
    send ^a
    Vim.SM.WaitTextFocus()
    send ^+1
    WinWaitNotActive, ahk_class TElWind,, 0.8  ; could appear a loading bar
    if (!ErrorLevel)
      WinWaitActive, ahk_class TElWind,, 5
    send {esc}
    Vim.SM.WaitTextExit()
    if (!InStr(A_ThisHotkey, "x"))
      Vim.SM.SetTitle(Vim.Browser.title)
  }
  if (concept) {
    WinWaitActive, ahk_class TElWind,, 1
    Vim.SM.ChangeDefaultConcept(ConceptBefore)
    send !{left}
    Vim.SM.WaitFileLoad()
    refreshed := true
  }
  if (prio) {
    WinWaitActive, ahk_class TElWind,, 1
    if (RegExMatch(prio, "^\."))
      prio := "0" . prio
    send % "!p" . prio . "{enter}"
  }
  WinWaitActive, ahk_class TElWind,, 1
  if (!refreshed)
    Vim.SM.reload()
  Vim.Browser.Clear()
  Vim.State.SetMode("Vim_Normal")
  WinClip.Restore(ClipData)
return

GetBrowserUrl:
  CurrUrl := Vim.Browser.GetBrowserUrl()
return

SMImportGuiEscape:
SMImportGuiClose:
  gui destroy
  Vim.Browser.Clear()
  Vim.State.SetMode("Vim_Normal")
  WinClip.Restore(ClipData)
return

SMImportButtonImport:
  gui submit
  gui destroy
  goto SMImportContinue
return

^!c::  ; copy and save references
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (ErrorLevel)
    WinClip.Restore(ClipData)
  Vim.Browser.GetInfo()
  source := Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : ""
  date := Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : ""
  ToolTip("Copied " . Clipboard . "`nLink: " . Vim.Browser.Url . "`nTitle: " . Vim.Browser.Title . source . date)
return

^!m::  ; copy ti*m*e stamp
  VidTime := Vim.Browser.GetVidtime()
  if (!VidTime) {
    ToolTip("Not found.")
    Vim.Browser.VidTime := ""
    return
  }
  Clipboard := Vim.Browser.VidTime := VidTime
  ToolTip("Registered " . VidTime)
return

!+d::  ; check duplicates in SM
  ; Everything in this hotkey runs in the background
  KeyWait alt
  ; This is the function that works. inc_Uri() does not
  ; (2nd parameter) Encode in case there are Chinese characters in URL
  ; (3rd parameter) component := false because "/" doesn't need to be encoded
  url := EncodeDecodeURI(Vim.Browser.ParseUrl(Vim.Browser.GetBrowserUrl()),, false)
  ControlSend,, {ctrl down}f{ctrl up}, ahk_class TElWind
  WinWait, ahk_class TMyFindDlg,, 0
  ControlSetText, TEdit1, % url, ahk_class TMyFindDlg
  ControlSend,, {enter}, ahk_class TMyFindDlg
  GroupAdd, SMCtrlF, ahk_class TMsgDialog
  GroupAdd, SMCtrlF, ahk_class TBrowser
  WinWait, ahk_group SMCtrlF,, 10
  if (WinExist("ahk_class TMsgDialog")) {
    WinClose
    ToolTip("No duplicates found.",, -1000)
  } else if (WinExist("ahk_class TBrowser")) {
    WinActivate
  }
  Vim.Browser.Clear()
return

~^f::
  if (A_PriorHotkey != "~^f" || A_TimeSincePriorHotkey > 400) {
    KeyWait f
    return
  }
  send ^v
return

~^l::
  if (A_PriorHotkey != "~^l" || A_TimeSincePriorHotkey > 400) {
    KeyWait l
    return
  }
  send ^v
return

; SumatraPDF/Calibre/MS Word to SuperMemo
#if (Vim.State.Vim.Enabled && (WinActive("ahk_class SUMATRA_PDF_FRAME")  ; SumatraPDF
                            || WinActive("ahk_exe ebook-viewer.exe")     ; Calibre (a epub viewer)
                            || WinActive("ahk_group Browsers")           ; browser group (chrome, edge, etc)
                            || WinActive("ahk_exe WINWORD.exe")))        ; MS Word
^+!x::
^!x::
!+x::
!x::  ; pdf/epub extract to supermemo
  KeyWait alt
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c  ; clip() doesn't keep format; nor ClipboardAll can work with functions
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (!Clipboard) {
    ToolTip("Nothing is selected.")
    WinClip.Restore(ClipData)
    return
  } else {
    WinGet, hwnd, ID, A
    prio := IsBrowser := ""
    if (InStr(A_ThisHotkey, "+")) {
      InputBox, prio, Priority, Enter extract priority.,, 196, 128
      if (RegExMatch(prio, "^\."))
        prio := "0" . prio
      WinWaitActive, % "ahk_id " . hwnd,, 1
    }
    if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
      send {text}a
    } else if (WinActive("ahk_exe ebook-viewer.exe")) {
      send {text}q  ; need to enable this shortcut in settings
    } else if (WinActive("ahk_group Browsers")) {
      ControlSend,, {alt down}{shift down}h{shift up}{alt up}, % "ahk_id " . hwnd  ; need to enable this shortcut in settings
      IsBrowser := true
    } else if (WinActive("ahk_exe WINWORD.exe")) {
      send ^!h
    }
    if (!WinExist("ahk_group SuperMemo")) {
      ToolTip("SuperMemo is not open, please open SuperMemo and paste your text.")
      return
    }
  }
  extract := ClipboardAll
  WinActivate, ahk_class TElWind  ; focus to element window
ExtractToSM:
  Vim.SM.DeselectAllComponents()
  send q
  Vim.SM.WaitTextFocus()
  if (!Vim.SM.IsEditingHTML()) {
    ToolTip("No html component is focused, please go to the topic you want and paste your text.")
    return
  }
  send ^{home}^+{down}  ; go to top and select first paragraph below
  if (RegExMatch(clip("",, true), "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])")) {
    send {left}
    if (SMExtractGoToSource) {
      ret := true
    } else {
      MsgBox, 4,, Go to source and try again?
      IfMsgBox, yes, {
        WinWaitActive, ahk_class TElWind,, 1
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        SMExtractGoToSource := true
        goto ExtractToSM
      } else {
        ret := true
      }
    }
    if (ret) {
      ret := SMExtractGoToSource := false
      Clipboard := extract
      ToolTip("Please make sure current element is an empty html topic. Your extract is now on your clipboard.")
      return
    }
  }
  send {left}
  if (!IsBrowser) {
    clip(extract,, true)
  } else {
    Clipboard := extract
    ClipWait 10
    Vim.HTML.ClipboardGet_HTML(data)
    RegExMatch(data, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", data)
    clip(Vim.HTML.Clean(data),, true, true)
  }
  send ^+{home}  ; select everything
  if (prio) {
    send !+x
    WinWaitActive, ahk_class TPriorityDlg,, 5
    if (ErrorLevel) {
      WinClip.Restore(ClipData)
      return
    }
    ControlSetText, TEdit5, % prio
    send {enter}
  } else {
    send !x  ; extract
  }
  Vim.SM.WaitProcessing()
  sleep 40  ; short sleep to make sure the extraction is done
  Vim.SM.MoveAboveRef(true)
  send !\\
  WinWaitNotActive, ahk_class TElWind,, 2
  if (ErrorLevel) {
    WinClip.Restore(ClipData)
    return
  }
  send {enter}
  WinWaitNotActive, ahk_class TMsgDialog,, 0
  send {esc}
  if (InStr(A_ThisHotkey, "^")) {
    send !{left}
  } else {
    WinActivate % "ahk_id " . hwnd
  }
  WinClip.Restore(ClipData)
return

; SumatraPDF
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && !Vim.State.IsCurrentVimMode("Z") && !A_CaretX && !ControlGetFocus())
+z::Vim.State.SetMode("Z")
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && Vim.State.IsCurrentVimMode("Z") && !A_CaretX && !ControlGetFocus())
+z::  ; exit and save annotations
  send q
  WinWaitActive, Unsaved annotations,, 0
  if (!ErrorLevel)
    send s
  if (WinExist("ahk_class TElWind"))
    WinActivate
  Vim.State.SetMode("Vim_Normal")
return

#if (WinActive("ahk_class SUMATRA_PDF_FRAME"))
!p::ControlFocus, Edit1  ; focus to page number field so you can enter a number

^!p::  ; copy page number
  Clipboard := "p" . ControlGetText("Edit1")
  ClipWait 1
  ToolTip("Copied " . Clipboard)
return

#if ((WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe ebook-viewer.exe")) && WinExist("ahk_class TElWind"))
!+s::
^!s::
^+!s::
  WinClip.Snap(ClipData)
  KeyWait alt
  marker := PageNumber := ""
  if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
    PageNumber := "p" . ControlGetText("Edit1")
    if (InStr(A_ThisHotkey, "^")) {
      send q
      WinWaitActive, Unsaved annotations,, 0
      if (!ErrorLevel)
        send s
    }
  } else if (WinActive("ahk_exe ebook-viewer.exe")) {
    marker := clip("",, true)
    if (!marker) {
      WinClip.Restore(ClipData)
      return
    }
    if (InStr(A_ThisHotkey, "^"))
      send !{f4}
  }
  WinActivate, ahk_class TElWind
MarkInSMTitle:
  Vim.SM.DeselectAllComponents()
  send q
  Vim.SM.WaitTextFocus()
  if (!Vim.SM.IsEditingText()) {
    ToolTip("No text component.")
    WinClip.Restore(ClipData)
    return
  }
  send ^{home}^+{down}  ; go to top and select first paragraph below
  if (RegExMatch(clip("",, true), "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])")) {
    send {left}
    if (SMGoToSource) {
      ret := true
    } else {
      MsgBox, 4,, Go to source and try again?
      IfMsgBox, yes, {
        WinWaitActive, ahk_class TElWind,, 1
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        SMGoToSource := true
        goto MarkInSMTitle
      } else {
        ret := true
      }
    }
    if (ret) {
      ret := SMGoToSource := false
      ToolTip("No source element found or source element isn't empty.")
      WinClip.Restore(ClipData)
      return
    }
  }
  send {left}{esc}
  Vim.SM.WaitTextExit()
  Vim.SM.PostMsg(116)  ; edit title
  GroupAdd, SMAltT, ahk_class TChoicesDlg
  GroupAdd, SMAltT, ahk_class TTitleEdit
  WinWait, ahk_group SMAltT,, 3
  if (WinExist("ahk_class TChoicesDlg")) {
    ControlSend, TGroupButton3, {enter}, ahk_class TChoicesDlg
    WinWait, ahk_class TTitleEdit,, 3
  }
  if (WinExist("ahk_class TTitleEdit")) {
    ControlGetText, CurrText, TMemo1, ahk_class TTitleEdit
    if (PageNumber) {
      title := RegExReplace(CurrText, "(^p[0-9]+ |^)", PageNumber . " ")
    } else if (marker) {
      title := RegExReplace(CurrText, "(^.* \| |^)", marker . " | ")
    }
    ControlSetText, TMemo1, % title
    ControlSend, TMemo1, {enter}, ahk_class TTitleEdit
  }
  if (InStr(A_ThisHotkey, "^+!"))
    Vim.SM.Learn()
  WinClip.Restore(ClipData)
return

; IE
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe"))
; Open in default browser (in my case, chrome); similar to default shortcut ^+e to open in ms edge
^+c::run % ControlGetText("Edit1")  ; browser url field

#if (Vim.State.Vim.Enabled && WinActive("ahk_class wxWindowNR") && WinExist("ahk_class TElWind"))  ; audacity.exe
^!x::
!x::
  KeyWait alt
  FormatTime, CurrTime,, % "yyyy-MM-dd HH:mm:ss:" . A_MSec
  if (A_ThisHotkey == "^!x") {
    send ^a!ct{enter}  ; truncate silence
    WinWaitActive, Truncate Silence,, 5
    ; Settings for truncate complete silence
    ControlSetText, Edit1, -80
    ControlSetText, Edit2, 0.001
    ControlSetText, Edit3, 0
    send {enter}
    WinWaitActive, Truncate Silence,, 0
    if (!ErrorLevel)
      WinWaitNotActive, Truncate Silence,, 10
    send ^+e  ; save
    WinWaitActive, Export Audio,, 5
  } else if (A_ThisHotkey == "!x") {
    PostMessage, 0x0111, 17011,,, A  ; export selected audio
    return
    WinWaitActive, Export Selected Audio,, 5
  }
  if (ErrorLevel)
    return
  FileName := RegExReplace(Vim.Browser.title, "[^a-zA-Z0-9\\.\\-]", "_")
  if (Vim.Browser.title) {
    TempPath := A_Desktop . "\" . FileName . " (excerpt).mp3"
  } else {
    TempPath := A_Desktop . "\temp.mp3"
  }
  control, choose, 3, ComboBox3  ; choose mp3 from file type
  ControlSetText, Edit1, % TempPath
  send {enter}
  WinWaitActive, Warning,, 0
  if (!ErrorLevel) {
    send {enter}
    WinWaitNotActive, Warning,, 0
  }
  send ^a{bs}
  WinActivate, ahk_class TElWind
  send !a  ; new item
  Vim.SM.WaitTextFocus()
  ControlGetFocus, QuestionFieldName, A
  if (Vim.Browser.title) {
    QuestionField := Vim.Browser.title
                   . "`n#SuperMemo Reference:"
                   . "`n#Link: " . Vim.Browser.url
                   . "`n#Title: " . Vim.Browser.title
    if (Vim.Browser.source)
      QuestionField .= "`n#Source: " . Vim.Browser.source
    if (Vim.Browser.date)
      QuestionField .= "`n#Source: " . Vim.Browser.date
    clip(QuestionField)
  } else {
    QuestionField := ""
    send C:
  }
  send {ctrl down}ttq{ctrl up}
  GroupAdd, SMCtrlQ, ahk_class TFileBrowser
  GroupAdd, SMCtrlQ, ahk_class TMsgDialog
  WinWaitActive, ahk_group SMCtrlQ,, 5
  while (!WinActive("ahk_class TFileBrowser")) {
    StartTime := A_TickCount
    if (WinActive("ahk_class TMsgDialog")) {
      send {esc}  ; Directory not found; Create? or MCI error
      WinWaitActive, ahk_group SMCtrlQ,, 0.1
    } else if (A_TickCount - StartTime > 1000) {
      return
    }
  }
  send !dc  ; select C drive
  send !n  ; select file name
  ControlSetText, TEdit1, % TempPath
  send {enter}
  WinWaitActive, ahk_class TInputDlg,, 0
  if (Vim.Browser.title) {
    ControlSetText, TMemo1, % Vim.Browser.title . " (excerpt)"
  } else {
    ControlSetText, TMemo1, temp_
  }
  send {enter}
  WinWaitNotActive, ahk_class TInputDlg,, 0
  send n
  WinWaitNotActive, ahk_class TInputDlg,, 0
  send y
  Vim.SM.PostMsg(992, true)  ; previous component
  Vim.SM.PostMsg(992, true)
  ControlFocusWait(QuestionFieldName)
  if (QuestionField)
    send ^+{down}{bs}  ; delete text so the question field is empty
  send ^t
  ControlWaitNotFocus(QuestionFieldName)
  send ^v  ; paste: text or image
  WinWaitNotActive, ahk_class TElWind,, 5  ; if it's an image
  if (!ErrorLevel) {
    send {enter}
    WinWaitNotActive, ahk_class TMsgDialog,, 0
    send {enter}
  }
  Vim.Browser.Clear()
Return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm"))
!p::ControlFocus, TEdit1  ; set priority for current selected concept in registry window

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg"))
; Use English input method for choosing concept when import
~!g::SetDefaultKeyboard(0x0409)  ; english-US	