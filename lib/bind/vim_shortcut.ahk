; Launch Settings
; #if (Vim.State.Vim.Enabled)
; ^!+c::Vim.Setting.ShowGui()

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
;   keywait shift
;   keywait ctrl
;   keywait alt
; return

; Shortcuts
^!r::reload

!+v::
  Clipboard := Clipboard
  send ^v
return

LAlt & RAlt::  ; for laptop
  KeyWait LAlt
  KeyWait RAlt
  send {AppsKey}
  if (Vim.IsVimGroup())
    Vim.State.SetMode("Insert")
return

#f::run % "D:\OneDrive\Miscellany\Programs\Everything\Everything64.exe"
^#h::send ^#{left}
^#l::send ^#{right}

^+!p::
SMPlan:
  KeyWait shift
  Vim.State.SetMode("Vim_Normal")
  if (!WinExist("ahk_group SuperMemo")) {
    run C:\SuperMemo\systems\all.kno
    WinWaitActive, ahk_class TElWind,, 10
    if (ErrorLevel)
      return
    while (!WinActive("ahk_class TPlanDlg"))
      Vim.SM.PostMsg(243)  ; Plan
    WinWaitActive, ahk_class TMsgDialog,, 1
    WinClose, ahk_class TMsgDialog
    return
  }
  while (WinExist("ahk_class TMsgDialog"))
    WinClose
  if (Vim.SM.IsLearning())  ; not to spoil answer
    ControlSend, TBitBtn3, {home}, ahk_class TElWind
  if (!WinExist("ahk_class TPlanDlg")) {
    Vim.SM.PostMsg(243)  ; Plan
    WinWait, ahk_class TPlanDlg
  }
  WinActivate, ahk_class TPlanDlg
  send {right 2}{home}
return

; Browsers
#if (Vim.State.Vim.Enabled && WinActive("ahk_group Browser"))
^!w::send ^w!{tab}  ; close tab and switch back

^!i::  ; open in *I*E
  Vim.Browser.RunInIE(Vim.Browser.ParseUrl(GetActiveBrowserURL()))
  ; run % "iexplore.exe " . Vim.Browser.ParseUrl(GetActiveBrowserURL())  ; RIP old method
Return

^!t::  ; copy title
  Vim.Browser.GetInfo(false, true)
  ToolTip("Copied " . Vim.Browser.Title)
  Clipboard := Vim.Browser.Title
  Vim.Browser.Clear()
return

^!l::  ; copy link and parse *l*ink if if's from YT
  Vim.Browser.GetInfo()
  source := Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : ""
  date := Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : ""
  vidtime := Vim.Browser.VidTime ? "`nTime stamp: " . Vim.Browser.VidTime : ""
  ToolTip("Copied " . Vim.Browser.Url . "`nTitle: " . Vim.Browser.Title . source . date . vidtime)
  Clipboard := Vim.Browser.Url
return

^!d::  ; parse similar and opposite in google *d*efine
  ClipSaved := ClipboardAll
  WinClip.Clear()
  send ^c
  ClipWait 0.6
  if (ErrorLevel) {
    ToolTip("Text not found.")
    Clipboard := ClipSaved
    return
  }
  TempClip := RegExReplace(Clipboard, "(Similar|Synonymes).*\r\n", "`r`nsyn: ")
  TempClip := RegExReplace(TempClip, "(Opposite|Opuesta).*\r\n", "`r`nant: ")
  TempClip := RegExReplace(TempClip, "(?<![:]|(?<![^.])|(?<![^""]))\r\n(?!(syn:|ant:|\r\n))", ", ")
  TempClip := RegExReplace(TempClip, "\.(?=\r\n)")
  TempClip := RegExReplace(TempClip, "(\r\n\K""|""(\r\n)?(?=\r\n))", "`r`n")
  TempClip := RegExReplace(TempClip, """$(?!\r\n)")
  TempClip := StrLower(SubStr(TempClip, 1, 1)) . SubStr(TempClip, 2)  ; make the first letter lower case
  Clipboard := TempClip := StrReplace(TempClip, "Vulgar slang:", "Vulgar slang: ")
  ToolTip("Copied:`n" . TempClip)
return

; Incremental web browsing
; +!x::
; !x::
IncrementalWebBrowsingNewTopic:
; Incremental video: Import current YT video to SM
; Import current webpage to SuperMemo
^+!a::
^!a::
  FormatTime, CurrTime,, % "yyyy-MM-dd HH:mm:ss:" . A_MSec
  IncWB := (InStr(A_ThisHotkey, "x") || A_ThisLabel == "IncrementalWebBrowsingNewTopic")
  if (!IncWB) {
    GetAddressBarUrlDone := false
    SetTimer, GetAddressBarUrl, -1
  }
  ClipSaved := ClipboardAll
  hwnd := WinGet()
  ImportDlg := InStr(A_ThisHotkey, "+")
  CurrText := WinGetText("ahk_class TElWind")
  CollName := Vim.SM.GetCollName(CurrText)
  PC := Vim.SM.IsPassiveColl(CollName)
  KeyWait shift
  KeyWait ctrl
  KeyWait alt
  ; VarSetCapacity(HTMLText, 40960000)  ; ~40mb
  if (!IncWB) {
    WaitVarExists(GetAddressBarUrlDone)
    if (!vim.browser.url := Vim.Browser.GetAddressBarUrl(1)) {
      ToolTip("Web page not found.")
      return
    }
    vim.browser.url := vim.sm.ParseUrl(vim.browser.url)
    if (vim.sm.CheckDup(vim.browser.url, false))
      MsgBox, 4,, Continue import?
  }
  WinActivate % "ahk_id " . hwnd
  WinClose, ahk_class TBrowser
  ; Have to put below WinActivate, otherwise would make element window focus again
  ; Cannot use SetTimer for SM.ClearUp(), exceeds recursion limit
  ; ClearUp := Vim.SM.ClearUp
  ; SetTimer, % ClearUp, -1
  IfMsgBox no
    goto ImportReturn

  prio := concept := ""
  if (ImportDlg) {
    SetDefaultKeyboard(0x0409)  ; english-US	
    gui, SMImport:Add, Text,, &Priority:
    gui, SMImport:Add, Edit, vPrio
    gui, SMImport:Add, Text,, &Concept:
    gui, SMImport:Add, Edit, vConcept
    gui, SMImport:Add, Button, default, &Import
    gui, SMImport:Show,, SuperMemo Import
    return
  }

SMImportButtonImport:
  if (A_ThisLabel == "SMImportButtonImport") {
    ; Without KeyWait WinActivate below could fail???
    KeyWait enter
    KeyWait alt
    gui submit
    gui destroy
    WinActivate % "ahk_id " . hwnd
  }

  HTMLText := PC ? "" : clip("",, false, true)
  if (IncWB) {
    if (!HTMLText) {
      ToolTip("Text not found.")
      Clipboard := ClipSaved
      return
    }
    ; ControlSend,, {alt down}{shift down}h{shift up}{alt up}, % "ahk_id " . hwnd  ; not reliable
    send !+h
    sleep 20
  }
  Vim.Browser.GetTitleSourceDate(false)
  SMVidImport := (PC || (!HTMLText && vim.browser.VidSite))
  if (!HTMLText && !SMVidImport) {
    send ^a
    HTMLText := clip("",, false, true)
    send {esc}
    if (!HTMLText)
      goto ImportReturn
  }
  Vim.Browser.GetUrl(0, false)

  WinClip.Clear()
  if (SMVidImport) {
    if (SMVidImport && !PC) {
      Clipboard := Vim.Browser.Url
    } else {
      Clipboard := Vim.SM.MakeReference()
    }
  } else {
    HTMLText := Vim.HTML.Clean(HTMLText, true)
    if (IncWB) {
      Vim.browser.date := ""
    } else if (!IncWB && !vim.browser.date) {
      vim.browser.date := "Imported on " . CurrTime
    }
    Clipboard := HTMLText . "<br>" . Vim.SM.MakeReference(true)
  }
  ClipWait

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

  if (prio && RegExMatch(prio, "^\."))
    prio := "0" . prio
  WinActivate, ahk_class TElWind

  if (concept) {
    ConceptBefore := Vim.SM.GetCurrConcept(CurrText)
    if (InStr(ConceptBefore, concept) == 1) {  ; entered concept = current concept
      concept := ""
    } else {
      Vim.SM.ChangeDefaultConcept(concept)
    }
    WinWaitClose, ahk_class TRegistryForm
    WinActivate, ahk_class TElWind
  }

  if (SMVidImport) {
    if (PC) {
      gosub SMHyperLinkToTopic
    } else {
      gosub SMCtrlN
    }
  } else {
    Vim.SM.PostMsg(98)  ; = send !n
    ; Vim.SM.PostMsg(843, true)  ; not reliable???
    send {AppsKey}xp  ; Paste HTML  ; not reliable?
    ; send !{f12}xp  ; Paste HTML  ; not reliable?
    WinClip._waitClipReady()
    WinWaitActive, ahk_class TElWind
    ; send ^n
    ; WinWaitNotActive, ahk_class TElWind,, 1  ; could appear a loading bar
    ; if (!ErrorLevel)
    ;   WinWaitActive, ahk_class TElWind
    ; send ^a
    ; Vim.SM.WaitTextFocus()
    ; send ^+1
    ; WinWaitNotActive, ahk_class TElWind,, 1  ; could appear a loading bar
    ; if (!ErrorLevel)
    ;   WinWaitActive, ahk_class TElWind
    ; send {esc}
    ; Vim.SM.WaitTextExit()
  }

  if (vim.browser.title && !IncWB && !prio) {
    Vim.SM.SetTitle(Vim.Browser.title)
  } else if ((IncWB || !vim.browser.title) && prio) {
    ; Cannot just send the priority, might send into the wrong window
    send {alt down}
    PostMessage, 0x0104, 0x50, 1<<29,, ahk_class TElWind  ; P key
    PostMessage, 0x0105, 0x50, 1<<29,, ahk_class TElWind
    send {alt up}
    WinWait, ahk_class TPriorityDlg
    ControlSetText, TEdit5, % prio, ahk_class TPriorityDlg
    ControlSend, TEdit5, {enter}, ahk_class TPriorityDlg
  } else if (vim.browser.title && prio) {
    Vim.SM.SetElParam(vim.browser.title, prio)
  }

  if (refreshed := concept) {
    Vim.SM.ChangeDefaultConcept(ConceptBefore)
    ; WinActivate, ahk_class TElWind
    ; WinWaitActive, ahk_class TElWind  ; needed to make sure !{left} works
    Vim.SM.WaitFileLoad()
    ; send !{left}
    send {alt down}
    PostMessage, 0x0104, 0x25, 1<<29,, ahk_class TElWind  ; left arrow key
    PostMessage, 0x0105, 0x25, 1<<29,, ahk_class TElWind
    send {alt up} ;{esc}  ; esc because alt is pressed
  }
  if (!refreshed)
    Vim.SM.reload(0, 1)

SMImportGuiEscape:
SMImportGuiClose:
  if A_ThisLabel contains SMImportGuiEscape,SMImportGuiClose
    gui destroy
ImportReturn:
  Vim.SM.ClearHighlight()
  Vim.Browser.Clear()
  Vim.State.SetMode("Vim_Normal")
  Clipboard := ClipSaved
  goto RemoveToolTip
return

GetAddressBarUrl:
  vim.browser.url := Vim.Browser.GetAddressBarUrl(1)
  GetAddressBarUrlDone := true
return

^!c::  ; copy and save references
  ClipSaved := ClipboardAll
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (ErrorLevel)
    Clipboard := ClipSaved
  Vim.Browser.GetInfo()
  source := Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : ""
  date := Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : ""
  ToolTip("Copied " . Clipboard . "`nLink: " . Vim.Browser.Url . "`nTitle: " . Vim.Browser.Title . source . date)
return

^!m::  ; copy ti*m*e stamp
  if (!Vim.Browser.GetVidtime()) {
    ToolTip("Not found.")
    return
  }
  Clipboard := Vim.Browser.VidTime
  ToolTip("Registered " . vim.browser.VidTime)
return

!+d::  ; check duplicates in SM
  if (!WinExist("ahk_class TElWind")) {
    ToolTip("SuperMemo hasn't opened yet.")
    return
  }
  ; Everything in this hotkey runs in the background
  if (!url := Vim.Browser.GetAddressBarUrl(1)) {
    ToolTip("Url not found.")
    return
  }
  url := Vim.SM.ParseUrl(url)
  KeyWait alt
  KeyWait shift
  Vim.SM.CheckDup(url)
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
                            || WinActive("ahk_group Browser")           ; browser group (chrome, edge, etc)
                            || WinActive("ahk_exe WINWORD.exe")))        ; MS Word
^+!x::
^!x::
!+x::
!x::  ; pdf/epub extract to supermemo
  KeyWait shift
  KeyWait ctrl
  KeyWait alt
  ClipSaved := ClipboardAll
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c  ; clip() doesn't keep format; nor ClipboardAll can work with functions
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (ErrorLevel) {
    ToolTip("Nothing is selected.")
    Clipboard := ClipSaved
    return
  } else {
    hwnd := WinGet()
    if (prio := InStr(A_ThisHotkey, "+")) {
      InputBox, prio, Priority, Enter extract priority.,, 196, 128
      if (ErrorLevel)
        return
      if (RegExMatch(prio, "^\."))
        prio := "0" . prio
      WinWaitActive, % "ahk_id " . hwnd
    }
    if (IsBrowser := WinActive("ahk_group Browser")) {
      ; ControlSend,, {alt down}{shift down}h{shift up}{alt up}, % "ahk_id " . hwnd  ; need to enable this shortcut in settings
      send !+h
      sleep 20
    } else if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
      send {text}a
    } else if (WinActive("ahk_exe ebook-viewer.exe")) {
      send {text}q  ; need to enable this shortcut in settings
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
  if (RegExMatch(copy(true), "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])")) {
    send {left}
    if (A_ThisLabel == "ExtractToSM") {
      ret := true
    } else {
      MsgBox, 4,, Go to source and try again?
      IfMsgBox, yes, {
        WinWaitActive, ahk_class TElWind
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        goto ExtractToSM
      } else {
        ret := true
      }
    }
    if (ret) {
      ret := false
      Clipboard := extract
      ToolTip("Please make sure current element is an empty html topic. Your extract is now on your clipboard.")
      return
    }
  }
  send {left}
  if (!IsBrowser) {
    clip(extract,, false,, false)
  } else {
    WinClip.Clear()
    Clipboard := extract
    ClipWait
    Vim.HTML.ClipboardGet_HTML(data)
    RegExMatch(data, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", data)
    WinClip.Clear()
    Clipboard := Vim.HTML.Clean(data, true)
    ClipWait
    send {AppsKey}xp  ; paste HTML
    WinClip._waitClipReady()
    WinWaitActive, ahk_class TElWind
  }
  send ^+{home}  ; select everything
  if (prio) {
    send !+x
    WinWaitActive, ahk_class TPriorityDlg
    ControlSetText, TEdit5, % prio
    send {enter}
  } else {
    send !x  ; extract
  }
  Vim.SM.WaitExtractProcessing()
  ; sleep 40  ; short sleep to make sure the extraction is done
  Vim.SM.MoveAboveRef(false)
  send !\\
  WinWaitNotActive, ahk_class TElWind
  send {enter}
  WinWaitNotActive, ahk_class TMsgDialog
  send {esc}
  if (InStr(A_ThisHotkey, "^")) {
    send !{left}
  } else {
    WinActivate % "ahk_id " . hwnd
  }
  Clipboard := ClipSaved
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

#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && !ControlGetFocus())
!p::ControlFocus, Edit1  ; focus to page number field so you can enter a number

#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && ControlGetFocus() == "Edit1")
!p::
  ControlSetText, Edit1, % Clipboard
  send {enter}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && ControlGetFocus() == "Edit2")
^f::
  ControlSetText, Edit2, % Clipboard
  send {enter}
return

#if (Vim.State.Vim.Enabled && (WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe ebook-viewer.exe") || WinActive("ahk_group Browser")) && WinExist("ahk_class TElWind") && !Vim.SM.IsPassiveColl())
!+s::
^!s::
^+!s::
  ClipSaved := ClipboardAll
  marker := PageNumber := ""
  KeyWait alt
  KeyWait ctrl
  if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
    PageNumber := "p" . ControlGetText("Edit1")
    if (InStr(A_ThisHotkey, "^")) {
      send q
      WinWaitActive, Unsaved annotations,, 0
      if (!ErrorLevel)
        send s
    }
  } else if (WinActive("ahk_exe ebook-viewer.exe") || WinActive("ahk_group Browser")) {
    marker := trim(copy(true), " `t`r`n")
    if (!marker) {
      ToolTip("No text selected.")
      Clipboard := ClipSaved
      return
    }
    if (InStr(A_ThisHotkey, "^")) {
      if (WinActive("ahk_exe ebook-viewer.exe")) {
        send !{f4}
      } else if (WinActive("ahk_class Browsers")) {
        send ^w
      }
    }
  }
  WinActivate, ahk_class TElWind

MarkInSMTitle:
  Vim.SM.DeselectAllComponents()
  send q
  Vim.SM.WaitTextFocus()
  if (!Vim.SM.IsEditingText()) {
    ToolTip("No text component.")
    Clipboard := ClipSaved
    return
  }
  send ^{home}^+{down}  ; go to top and select first paragraph below
  if (RegExMatch(copy(true), "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])")) {
    send {left}
    if (A_ThisLabel == "MarkInSMTitle") {
      ret := true
    } else {
      MsgBox, 4,, Go to source and try again?
      IfMsgBox, yes, {
        WinWaitActive, ahk_class TElWind
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        goto MarkInSMTitle
      } else {
        ret := true
      }
    }
    if (ret) {
      ret := false
      ToolTip("No source element found or source element isn't empty.")
      Clipboard := ClipSaved
      return
    }
  }
  send {left}{esc}
  Vim.SM.WaitTextExit()
  Vim.SM.PostMsg(116)  ; edit title
  GroupAdd, SMAltT, ahk_class TChoicesDlg
  GroupAdd, SMAltT, ahk_class TTitleEdit
  WinWait, ahk_group SMAltT
  if (WinExist("ahk_class TChoicesDlg")) {
    ControlSend, TGroupButton3, {enter}, ahk_class TChoicesDlg
    WinWait, ahk_class TTitleEdit
  }
  if (WinExist("ahk_class TTitleEdit")) {
    CurrText := ControlGetText("TMemo1", "ahk_class TTitleEdit")
    CurrText := StrReplace(CurrText, "Duplicate: ")
    if (PageNumber) {
      title := RegExReplace(CurrText, "(^p[0-9]+ |^)", PageNumber . " ")
    } else if (marker) {
      title := RegExReplace(CurrText, "(^.* \| |^)", marker . " | ")
    }
    ControlSetText, TMemo1, % title
    ControlSend, TMemo1, {enter}, ahk_class TTitleEdit
  }
  if (InStr(A_ThisHotkey, "^+!")) {
    Vim.SM.Learn()
    Vim.SM.EnterInsertIfSpelling()
  }
  Clipboard := ClipSaved
return

; IE
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe"))
; Open in default browser (in my case, Chrome); similar to default shortcut ^+e to open in ms edge
^+c::run % ControlGetText("Edit1")  ; browser url field

#if (Vim.State.Vim.Enabled && WinActive("ahk_class wxWindowNR") && WinExist("ahk_class TElWind"))  ; audacity.exe
^!x::
!x::
  FormatTime, CurrTime,, % "yyyy-MM-dd HH:mm:ss:" . A_MSec
  KeyWait ctrl
  KeyWait alt
  if (A_ThisHotkey == "^!x") {
    send ^a
    ; send !ct{enter}  ; truncate silence
    PostMessage, 0x0111, 17200,,, A  ; truncate silence
    WinWaitActive, Truncate Silence
    ; Settings for truncate complete silence
    ControlSetText, Edit1, -80
    ControlSetText, Edit2, 0.001
    ControlSetText, Edit3, 0
    send {enter}
    WinWaitNotActive, Truncate Silence
    WinWaitActive, ahk_class wxWindowNR  ; audacity main window
    send ^+e  ; save
    WinWaitActive, Export Audio
  } else if (A_ThisHotkey == "!x") {
    ; send !fer  ; export selected audio
    PostMessage, 0x0111, 17011,,, A  ; export selected audio
    WinWaitActive, Export Selected Audio
  }
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
    WinWaitNotActive, Warning
  }
  send ^a{bs}
  WinActivate, ahk_class TElWind
  Vim.SM.PostMsg(95)
  Vim.SM.WaitFileLoad()
  QuestionFieldName := ControlGetFocus()
  if (Vim.Browser.title) {
    clip(Vim.SM.MakeReference())
  } else {
    send {raw}Listening comprehension:
  }
  send {ctrl down}ttq{ctrl up}
  GroupAdd, SMCtrlQ, ahk_class TFileBrowser
  GroupAdd, SMCtrlQ, ahk_class TMsgDialog
  WinWaitActive, ahk_group SMCtrlQ
  while (!WinActive("ahk_class TFileBrowser")) {
    while (WinExist("ahk_class TMsgDialog"))
      WinClose  ; Directory not found; Create? or MCI error
    WinWaitActive, ahk_group SMCtrlQ
  }
  ; Control related commands doesn't work in file browser
  send !dc  ; select C drive
  send !n
  send % "{raw}" . TempPath
  send {enter}
  WinWaitActive, ahk_class TInputDlg
  if (Vim.Browser.title) {
    ControlSetText, TMemo1, % Vim.Browser.title . " (excerpt)"
  } else {
    ControlSetText, TMemo1, audio comprehension_
  }
  send {enter}
  WinWaitActive, ahk_class TMsgDialog
  send n
  WinWaitNotActive, ahk_class TMsgDialog,, 0
  WinWaitActive, ahk_class TMsgDialog
  send y
  Vim.SM.SetTitle(Vim.browser.title)
  CurrFocus := ControlGetFocus("ahk_class TElWind")
  WinActivate, ahk_class TElWind
  send !{f12}fl  ; previous component
  ; Vim.SM.PostMsg(992, true)  ; not reliable???
  ControlWaitNotFocus(CurrFocus, "ahk_class TElWind")
  send ^v  ; paste: text or image
  WinWaitActive, ahk_class TMsgDialog,, 5  ; if it's an image
  if (!ErrorLevel) {
    send {enter}
    WinWaitNotActive, ahk_class TMsgDialog  ; input window: image name
    send {enter}
  }
  Vim.Browser.Clear()
Return

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe ebook-viewer.exe"))
~^f::
  if (A_PriorHotkey != "~^f" || A_TimeSincePriorHotkey > 400) {
    KeyWait f
    return
  }
  send ^v
  WinClip._waitClipReady(300)
  send {enter}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe HiborClient.exe"))
!+d::  ; check duplicates
  ClipSaved := ClipboardAll
  KeyWait alt
  KeyWait shift
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^a^c
  ClipWait 0.6
  if (ErrorLevel) {
    Clipboard := ClipSaved
    return
  }
  title := MatchHiborTitle(Clipboard)
  TitleArr := StrSplit(title, "-")
  Vim.SM.CheckDup(TitleArr[2])
  Clipboard := ClipSaved
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe HiborClient.exe") && WinExist("ahk_class TElWind"))
^!a::  ; import
  ClipSaved := ClipboardAll
  KeyWait alt
  WinClip.Clear()
  send ^a^c
  ClipWait 0.6
  if (ErrorLevel) {
    Clipboard := ClipSaved
    return
  }
  title := MatchHiborTitle(Clipboard)
  link := MatchHiborLink(Clipboard)
  TitleArr := StrSplit(title, "-")
  WinActivate, ahk_class TElWind
  send !n
  Vim.SM.WaitTextFocus()
  Vim.SM.SetTitle(TitleArr[2])
  WinWaitActive, ahk_class TElWind,, 0
  text := "#SuperMemo Reference:"
        . "`n#Title: " . TitleArr[2]
        . "`n#Source: " . TitleArr[1]
        . "`n#Date: " . TitleArr[3]
        . "`n#Link: " . link
  clip(text,, false)
  Vim.SM.Reload()
  Clipboard := ClipSaved
return

MatchHiborTitle(text) {
  RegExMatch(text, "s)意见反馈\r\n(研究报告：)?\K.*?(?=\r\n)", v)
  return v
}

MatchHiborLink(text) {
  RegExMatch(text, "s)推荐给朋友:\r\n\K.*?(?=  )", v)
  return v
}