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

#f::run D:\OneDrive\Miscellany\Programs\Everything\Everything64.exe
^#h::send ^#{left}
^#l::send ^#{right}

^+!p::
SMPlan:
  Vim.State.SetMode("Vim_Normal")
  KeyWait shift
  if (!WinExist("ahk_group SuperMemo")) {
    run C:\SuperMemo\systems\all.kno
    WinWait, ahk_class TElWind
    WinActivate
    Vim.SM.PostMsg(243)  ; Plan
    WinWait, ahk_class TMsgDialog,, 1
    if (!ErrorLevel) {
      WinClose
      WinWaitClose, ahk_class TMsgDialog
    }
    WinActivate, ahk_class TPlanDlg
    return
  }
  while (WinExist("ahk_class TMsgDialog"))
    WinClose
  if (!WinExist("ahk_class TPlanDlg")) {
    l := this.IsLearning()
    if (l == 2) {
      Vim.SM.Reload(, 1)
    } else if (l == 1) {
      Vim.SM.GoToTopEl()
    }
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
  Vim.Browser.GetInfo(false, false, false)
  ToolTip("Copied " . Vim.Browser.Title)
  Clipboard := Vim.Browser.Title
  Vim.Browser.Clear()
return

^!l::  ; copy link and parse *l*ink if if's from YT
  KeyWait ctrl
  KeyWait alt
  KeyWait l
  send {esc}
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
  TempClip := StrReplace(TempClip, "Vulgar slang:", "vulgar slang: ")
  Clipboard := TempClip := StrReplace(TempClip, "Derogatory:", "derogatory: ")
  ToolTip("Copied:`n" . TempClip)
return

; Incremental web browsing
; +!x::
; !x::
IncrementalWebBrowsingNewTopic:
IncrementalWebBrowsingNewTopicWithPriorityAndConcept:
; Incremental video: Import current YT video to SM
; Import current webpage to SuperMemo
^+!a::
^!a::
  if (WinExist("ahk_id " . ImportGuiHwnd)) {
    WinActivate
    return
  }
  Vim.Browser.Clear()
  IncWB := (IfContains(A_ThisHotkey, "x") || IfContains(A_ThisLabel, "IncrementalWebBrowsing"))
  if (!IncWB) {
    GetAddressBarUrlDone := false
    SetTimer, GetAddressBarUrl, -1
  }
  PressYTShowMoreButtonDone := false, BrowserExe := WinGet("ProcessName")
  SetTimer, PressYTShowMoreButton, -1
  ClipSaved := ClipboardAll
  ImportDlg := (IfContains(A_ThisHotkey, "+") || A_ThisLabel == "IncrementalWebBrowsingNewTopicWithPriorityAndConcept")
  hwnd := WinGet()
  CollName := vim.sm.GetCollName(), ConceptBefore := Vim.SM.GetCurrConcept()
  Passive := Vim.SM.IsPassive(CollName, ConceptBefore)
  KeyWait shift
  KeyWait ctrl
  KeyWait alt
  if (!IncWB) {
    WaitVarExists(GetAddressBarUrlDone)
    if (!vim.browser.url) {
      ToolTip("Web page not found.")
      return
    }
    vim.browser.url := vim.sm.ParseUrl(vim.browser.url)
    if (vim.sm.CheckDup(vim.browser.url, false))
      MsgBox, 4,, Continue import?
  }
  WinClose, ahk_class TBrowser
  WinActivate % "ahk_id " . hwnd
  ; Have to put below WinActivate, otherwise would make element window focus again
  ; Cannot use SetTimer for SM.ClearUp(), exceeds recursion limit
  ; ClearUp := Vim.SM.ClearUp
  ; SetTimer, % ClearUp, -1
  IfMsgBox, no
    goto ImportReturn

  prio := concept := CloseTab := ""
  WaitVarExists(PressYTShowMoreButtonDone)
  if (ImportDlg) {
    SetDefaultKeyboard(0x0409)  ; english-US	
    gui, SMImport:Add, Text,, % "Current collection: " . CollName
    gui, SMImport:Add, Text,, &Priority:
    gui, SMImport:Add, Edit, vPrio w196
    gui, SMImport:Add, Text,, &Concept:
    gui, SMImport:Add, Edit, vConcept w196, % ConceptBefore
    gui, SMImport:Add, Checkbox, vCloseTab checked, Close &tab
    gui, SMImport:Add, Button, default, &Import
    gui, SMImport:Show,, SuperMemo Import
    gui, SMImport:+HwndImportGuiHwnd
    return
  }

SMImportButtonImport:
  FormatTime, CurrTime,, % "yyyy-MM-dd HH:mm:ss:" . A_MSec
  if (A_ThisLabel == "SMImportButtonImport") {
    ; Without KeyWait WinActivate below could fail???
    KeyWait enter
    KeyWait alt
    gui submit
    if (Passive != 2)
      Passive := (InStr("online", concept) == 1 || InStr("source", concept) == 1) ? true : false
    gui destroy
    WinActivate % "ahk_id " . hwnd
  }

  ; VarSetCapacity(HTMLText, "40960000")  ; ~40 MB
  HTMLText := Passive ? "" : copy(false, true)
  if (IncWB) {
    if (!HTMLText) {
      ToolTip("Text not found.")
      Clipboard := ClipSaved
      return
    }
    Vim.Browser.Highlight()
  }
  Vim.Browser.GetTitleSourceDate(false)
  SMVidImport := (Passive || (!HTMLText && vim.browser.VidSite))
  if (!HTMLText && !SMVidImport) {
    WinClip.Clear()
    send ^a^c
    ClipWait % Vim.Browser.FullPageCopyTimeout
    Vim.HTML.ClipboardGet_HTML(clipped)
    RegExMatch(clipped, "s)<!--StartFragment ?-->\K.*(?=<!--EndFragment ?-->)", HTMLText)
    send {esc}
    if (!HTMLText) {
      ToolTip("Text not found.")
      goto ImportReturn
    }
  }
  Vim.Browser.GetUrl(, false)

  WinClip.Clear()
  if (SMVidImport) {
    if (Passive) {
      Clipboard := Vim.SM.MakeReference()
    } else {
      Clipboard := Vim.Browser.Url
    }
  } else {
    LineBreakList := "baike.baidu.com,m.shuaifox.com,khanacademy.org"
    LineBreak := IfContains(Vim.Browser.Url, LineBreakList)
    HTMLText := Vim.HTML.Clean(HTMLText, true, LineBreak)
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
  if (CloseTab)
    send ^w
  WinActivate, ahk_class TElWind

  if (concept) {
    ; No need for changing if entered concept = current concept
    if (!Vim.SM.ChangeDefaultConcept(concept,, ConceptBefore))
      concept := ""
    WinWaitClose, ahk_class TRegistryForm
    WinActivate, ahk_class TElWind
  }

  if (SMVidImport) {
    if (Passive) {
      gosub SMHyperLinkToTopic
    } else {
      gosub SMCtrlN
    }
  } else {
    Vim.SM.PostMsg(98)  ; = !n
    send {AppsKey}xp  ; Paste HTML
    WinClip._waitClipReady()
    WinWaitActive, ahk_class TElWind
  }

  if (vim.browser.title && !IncWB && !prio) {
    Vim.SM.SetTitle(Vim.Browser.title)
  } else if ((IncWB || !vim.browser.title) && prio) {
    ; Cannot just send the priority, might send into the wrong window
    Vim.SM.SetPrio(prio, true)
  } else if (vim.browser.title && prio) {
    WinActivate, ahk_class TElWind
    Vim.SM.SetElParam(vim.browser.title, prio)
  }
  Vim.SM.reload(, 1)

SMImportGuiEscape:
SMImportGuiClose:
  if A_ThisLabel contains SMImportGui
    gui destroy
ImportReturn:
  Vim.SM.ClearHighlight()
  if (A_ThisLabel == "SMImportButtonImport" || A_ThisLabel == "^!a") {
    ; Without this sometimes SM would focus to the window menu
    send {AltUp}  ; reload would send alt down
    Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
  }
  Vim.Browser.Clear()
  Vim.State.SetMode("Vim_Normal")
  Clipboard := ClipSaved
return

GetAddressBarUrl:
  vim.browser.url := Vim.Browser.GetAddressBarUrl()
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
  if (!url := Vim.Browser.GetAddressBarUrl()) {
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
  send ^c  ; Copy() doesn't keep format; nor ClipboardAll can work with functions
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (ErrorLevel) {
    ToolTip("Nothing is selected.")
    Clipboard := ClipSaved
    return
  } else {
    hwnd := WinGet()
    if (prio := InStr(A_ThisHotkey, "+")) {
      InputBox, prio, Priority, Enter extract priority.,, 196, 128
      if (!prio)
        return
      if (prio ~= "^\.")
        prio := "0" . prio
      WinWaitActive, % "ahk_id " . hwnd
    }
    if (IsBrowser := WinActive("ahk_group Browser")) {
      Vim.Browser.Highlight()
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
  Vim.SM.ExitText()
  send q
  Vim.SM.WaitTextFocus(1000)
  if (!Vim.SM.IsEditingHTML()) {
    ToolTip("No html component is focused, please go to the topic you want and paste your text.")
    return
  }
  send ^{home}^+{down}  ; go to top and select first paragraph below
  if (copy(false) ~= "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])") {
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
    RegExMatch(data, "s)<!--StartFragment ?-->\K.*(?=<!--EndFragment ?-->)", data)
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
  sleep 40  ; short sleep to make sure the extraction is done
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
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && !Vim.State.IsCurrentVimMode("Z") && !ControlGetFocus())
+z::Vim.State.SetMode("Z")
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && Vim.State.IsCurrentVimMode("Z") && !ControlGetFocus())
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
^f::
  if (!selection := Copy())
    return
  send ^f
  ControlSetText, Edit2, % selection
  send {enter}
return

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

#if (Vim.State.Vim.Enabled
  && !Vim.SM.IsPassive("", -1)  ; current concept doesn't matter
  && (WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe ebook-viewer.exe") || WinActive("ahk_group Browser"))
  && WinExist("ahk_class TElWind"))
!+s::
^!s::
^+!s::
  ClipSaved := ClipboardAll
  KeyWait alt
  KeyWait ctrl
  marker := trim(copy(false), " `t`r`n")
  if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
    marker := marker ? marker : "p" . ControlGetText("Edit1")
    if (!marker) {
      ToolTip("No text selected and page number not found.")
      Clipboard := ClipSaved
      return
    }
    if (InStr(A_ThisHotkey, "^")) {
      send q
      WinWaitActive, Unsaved annotations,, 0
      if (!ErrorLevel)
        send s
    }
  } else if (WinActive("ahk_exe ebook-viewer.exe") || WinActive("ahk_group Browser")) {
    if (!marker) {
      if (WinActive("ahk_group Browser"))
        goto BrowserSyncTime
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
  Vim.SM.ExitText()
  send q
  if (!Vim.SM.WaitTextFocus(500)) {
    ToolTip("No text component.")
    Clipboard := ClipSaved
    return
  }
  send ^{home}^+{down}  ; go to top and select first paragraph below
  if (copy(false) ~= "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])") {
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
    title := RegExReplace(CurrText, "((^.+ \| )|^)", marker . " | ")
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
    send % "{text}" . Vim.SM.MakeReference()
  } else {
    send {text}Listening comprehension:
  }
  send {ctrl down}ttq{ctrl up}
  GroupAdd, SMCtrlQ, ahk_class TFileBrowser
  GroupAdd, SMCtrlQ, ahk_class TMsgDialog
  WinWaitActive, ahk_group SMCtrlQ
  while (!WinActive("ahk_class TFileBrowser")) {
    while (WinActive("ahk_class TMsgDialog"))
      send n  ; Directory not found; Create?
    WinWaitActive, ahk_group SMCtrlQ
  }
  ControlSend, TDriveComboBox1, c, ahk_class TFileBrowser
  ControlSetText, TEdit1, % TempPath, ahk_class TFileBrowser
  ControlSend, TEdit1, {enter}, ahk_class TFileBrowser
  WinWaitActive, ahk_class TInputDlg
  if (Vim.Browser.title) {
    ControlSetText, TMemo1, % Vim.Browser.title . " (excerpt)"
  } else {
    ControlSetText, TMemo1, listening comprehension_
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
^+!a::
^!a::  ; import
  ClipSaved := ClipboardAll
  hwnd := WinGet()
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
  if (vim.sm.CheckDup(TitleArr[2], false))
    MsgBox, 4,, Continue import?
  WinActivate % "ahk_id " . hwnd
  WinClose, ahk_class TBrowser
  IfMsgBox, no
    goto HBImportReturn
  if (prio := InStr(A_ThisHotkey, "+")) {
    InputBox, prio, Priority, Enter extract priority.,, 196, 128
    if (!prio)
      return
  }
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
  if (prio)
    Vim.SM.SetPrio(prio)
  WinActivate, ahk_class TElWind
  Vim.SM.reload()

HBImportReturn:
  Vim.SM.ClearHighlight()
  WinActivate, ahk_class TElWind
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