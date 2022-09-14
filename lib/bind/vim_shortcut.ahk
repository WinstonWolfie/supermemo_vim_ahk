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
; ie := ComObjCreate("InternetExplorer.Application")
; ie.Visible := true  ; This is known to work incorrectly on IE7.
; ie.Navigate("https://www.autohotkey.com/")
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
  ReleaseKey("ctrl")
  ReleaseKey("shift")
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
    ControlSend, TBitBtn2, {ctrl down}p{ctrl up}, ahk_class TElWind
		if (A_TickCount := CurrTick + 5000)
			return
  }
  WinActivate, ahk_class TPlanDlg
  Vim.State.SetMode("Vim_Normal")
return

; Browsers
#if (Vim.State.Vim.Enabled && WinActive("ahk_group Browsers"))
^!w::send ^w!{tab}  ; close tab and switch back

!l::Vim.Browser.FocusToText()

^!i::  ; open in *I*E
  Vim.Browser.RunInIE(Vim.Browser.ParseUrl(GetActiveBrowserURL()))
  ; run % "iexplore.exe " . Vim.Browser.ParseUrl(GetActiveBrowserURL())  ; RIP old method
Return

^!t::  ; copy title
	ReleaseKey("ctrl")
  Vim.Browser.GetInfo()
  ToolTip("Copied " . Vim.Browser.Title)
  Clipboard := Vim.Browser.Title
  Vim.Browser.Clear()
return

^!l::  ; copy link and parse *l*ink if if's from YT
  Vim.Browser.GetInfo()
  source := Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : ""
  date := Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : ""
  ToolTip("Copied " . Vim.Browser.Url . "`nTitle: " . Vim.Browser.Title . source . date)
  Clipboard := Vim.Browser.Url
return

^!d::  ; parse similar and opposite in google *d*efine
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  TempClip := RegExReplace(Clipboard, "(?<!(Similar)|(?<![^:])|(?<![^.])|(?<![^""]))\r\n", ", ")
  TempClip := StrReplace(TempClip, "Similar`r`n", "`r`nsyn: ")
  TempClip := StrReplace(TempClip, "Similar:`r`n", "`r`nsyn: ")
  TempClip := StrReplace(TempClip, "Synonymes :`r`n", "`r`nsyn: ")
  TempClip := StrReplace(TempClip, ", Opposite:`r`n", "`r`n`r`nant: ")
  TempClip := StrReplace(TempClip, ", Opposite`r`n", "`r`n`r`nant: ")
  TempClip := StrReplace(TempClip, ", Opuesta`r`n", "`r`n`r`nant: ")
  TempClip := StrReplace(TempClip, ", Opuesta, ", "`r`n`r`nant: ")
  TempClip := StrReplace(TempClip, "ant: , ", "ant: ")
  Clipboard := StrReplace(TempClip, "vulgar slang", "vulgar slang > ")
  ToolTip("Copied:`n`n" . TempClip)
return

; Incremental video: Import current YT video to SM
; Import current webpage to supermemo
^+!a::
^!a::
	ReleaseKey("ctrl")
	ReleaseKey("shift")
  KeyWait alt
  SetTimer, GetChromeUrl, -1
  FormatTime, CurrTime,, % "yyyy-MM-dd HH:mm:ss:" . A_MSec
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  SMImportCtrlA := SMYTImport := false
  if (!Clipboard) {
    SMImportCtrlA := true
    if (InStr(CurrUrl, "bilibili.com")) {
      MouseGetPos, XSaved, YSaved
      MouseMove, % A_ScreenWidth / 2, % A_ScreenHeight / 2, 0
      sleep 200
    }
    send ^a^c
    ClipWait 1
    if (!Clipboard)
      return
    if (InStr(CurrUrl, "bilibili.com"))
      MouseMove, XSaved, YSaved
  }
  Vim.Browser.GetInfo()
  if (InStr(Vim.Browser.url, "youtube.com") && SMImportCtrlA) {
    SMYTImport := true
    send {esc}
    Vim.Browser.VidTime := Vim.Browser.MatchYTTime(Clipboard)
    Vim.Browser.date := Vim.Browser.MatchYTDate(Clipboard)
    Clipboard := Vim.Browser.url
  } else if (InStr(Vim.Browser.url, "bilibili.com") && SMImportCtrlA) {
    SMYTImport := true
    send {esc}
    Vim.Browser.VidTime := Vim.Browser.MatchBLTime(Clipboard)
    Vim.Browser.date := Vim.Browser.MatchBLDate(Clipboard)
    Clipboard := Vim.Browser.url
  } else {
    if (!Vim.HTML.ClipboardGet_HTML(data))
      return
    HTML := Vim.HTML.Clean(data)
    RegExMatch(HTML, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", HTML)
    source := Vim.Browser.Source ? "<br>#Source: " . Vim.Browser.Source : ""
    date := Vim.Browser.Date ? "<br>#Date: " . Vim.Browser.Date
                             : "<br>#Date: Imported on " . CurrTime
    clipboard := HTML
              . "<br>#SuperMemo Reference:"
              . "<br>#Link: " . Vim.Browser.Url
              . source
              . date
              . "<br>#Title: " . Vim.Browser.Title
    ClipWait 10
  }
  SetDefaultKeyboard(0x0409)  ; english-US	
  prio := concept := ""
  if (InStr(A_ThisHotkey, "+")) {
    gui, SMImport:Add, Text,, &Priority:
    gui, SMImport:Add, Edit, vPrio
    gui, SMImport:Add, Text,, &Concept:
    gui, SMImport:Add, Edit, vConcept
    gui, SMImport:Add, Button, default, &Import
    gui, SMImport:Show,, SuperMemo Import
    return
  }
SMImportContinue:
  WinActivate, ahk_class TElWind
  if (concept) {
    ConceptBefore := Vim.SM.GetCurrConcept()
    if (RegExMatch(ConceptBefore, "i)^" . concept)) {
      concept := ""
    } else {
      ControlClickWinCoord(723, 67)
      WinWaitActive, ahk_class TRegistryForm,, 3
      ControlSetText, Edit1, % SubStr(concept, 2)
      send % SubStr(concept, 1, 1) . "{enter}"  ; needed for updating the template
      WinWaitActive, ahk_class TElWind,, 3
    }
  }
  if (SMYTImport) {
    NewImport := true
    if (Vim.SM.IsPassiveCollection()) {
      gosub SMHyperLinkToTopic
    } else {
      gosub SMCtrlN
    }
  } else {
    send ^{enter}h{enter}  ; clear search highlight, just in case
    WinWaitActive, ahk_class TElWind,, 0
    send ^n
    WinWaitNotActive, ahk_class TElWind,, 2  ; could appear a loading bar
    if (!ErrorLevel)
      WinWaitActive, ahk_class TElWind,, 5
    send ^a^+1
    WinWaitNotActive, ahk_class TElWind,, 1.5  ; could appear a loading bar
    if (!ErrorLevel)
      WinWaitActive, ahk_class TElWind,, 5
    send {esc}
    WinWaitNotActive, ahk_class TElWind,, 0  ; could appear a loading bar
    if (!ErrorLevel)
      WinWaitActive, ahk_class TElWind,, 5
    Vim.SM.SaveHTML(true)
    Vim.SM.SetTitle(Vim.Browser.title)
  }
  if (prio)
    send % "!p" . prio . "{enter}"
  if (concept) {
    WinWaitActive, ahk_class TElWind,, 1
    ControlClickWinCoord(723, 67, "ahk_class TElWind")
    WinWaitActive, ahk_class TRegistryForm,, 3
    ControlSetText, Edit1, % SubStr(ConceptBefore, 2)
    send % SubStr(ConceptBefore, 1, 1) . "{enter}"  ; needed for updating the template
    WinWaitActive, ahk_class TElWind,, 3
    send !{left}
  }
  Vim.Browser.Clear()
  Vim.State.SetMode("Vim_Normal")
  WinClip.Restore(ClipData)
return

GetChromeUrl:
  CurrUrl := Vim.Browser.GetChromeUrl()
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
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
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
  WinClip.Snap(ClipData)
  Vim.Browser.GetUrl(true)
  WinActivate, ahk_class TElWind
  send ^f^v{enter}
  Vim.Browser.Clear()
  WinClip.Restore(ClipData)
  WinWaitActive, ahk_class TMsgDialog,, 10
  if (!ErrorLevel) {
    WinClose, ahk_class TMsgDialog
    ToolTip("No duplicates found.")
  }
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
  SetDefaultKeyboard(0x0409)  ; english-US	
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c  ; clip() doesn't keep format; nor ClipboardAll can work with functions
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (!Clipboard) {
    ToolTip("Nothing is selected.")
    WinClip.Restore(ClipData)
    return
  } else {
    WinGet, hwnd, ID, A
    prio := ""
    if (InStr(A_ThisHotkey, "+")) {
      InputBox, prio, Priority, Enter extract priority.,, 196, 128
      if (ErrorLevel || !prio) {
        WinClip.Restore(ClipData)
        return
      }
      WinWaitActive, % "ahk_id " . hwnd,, 1
    }
    if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
      send a
    } else if (WinActive("ahk_exe ebook-viewer.exe")) {
      send q  ; needs to enable this shortcut in settings
    } else if (WinActive("ahk_group Browsers")) {
      send !h
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
        WinGetTitle, CurrTitle, ahk_class TElWind
        ControlClickWinCoord(555, 66)
        WinWaitTitleChange(CurrTitle)
        SMExtractGoToSource := true
        goto ExtractToSM
      } else {
        ret := true
      }
    }
    if (ret) {
      ret := false
      SMExtractGoToSource := false
      Clipboard := extract
      ToolTip("Please make sure current element is an empty html topic. Your extract is now on your clipboard.")
      return
    }
  }
  send {left}
  clip(extract,, true)
  send ^+{home}  ; select everything
  if (prio) {
    send !+x
    WinWaitActive, ahk_class TPriorityDlg,, 5
    if (ErrorLevel) {
      WinClip.Restore(ClipData)
      return
    }
    send % prio . "{enter}"
  } else {
    send !x  ; extract
  }
  Vim.SM.WaitProcessing()
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
  WinWaitActive, Unsaved annotations,, 2
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

#if (WinActive("ahk_class SUMATRA_PDF_FRAME") && WinExist("ahk_class TElWind"))
^!s::
^+!s::
  PageNumber := "p" . ControlGetText("Edit1")
  if (InStr(A_ThisHotkey, "+")) {
    send q
    WinWaitActive, Unsaved annotations,, 2
    if (!ErrorLevel)
      send s
  }
  WinActivate, ahk_class TElWind
  Vim.SM.SetTitle(PageNumber)
return

; IE
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe"))
; Open in default browser (in my case, chrome); similar to default shortcut ^+e to open in ms edge
^+c::run % ControlGetText("Edit1")  ; browser url field

#if (Vim.State.Vim.Enabled && WinActive("ahk_class wxWindowNR") && WinExist("ahk_class TElWind"))  ; audacity.exe
^!x::
!x::
  FormatTime, CurrTime,, % "yyyy-MM-dd HH:mm:ss:" . A_MSec
  WinClip.Snap( clipData )
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
    send !fer  ; export selected audio
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
  Control, choose, 3, ComboBox3  ; choose mp3 from file type
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
    clip(QuestionField,, true)
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
      WinWaitActive, ahk_group SMCtrlQ,, 0
    } else if (A_TickCount - StartTime > 500) {
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
  send !{f10}np  ; previous component
  send !{f10}np
  ControlFocusWait(QuestionFieldName)
  if (QuestionField)
    send ^+{down}{bs}  ; delete text so the question field is empty
  send ^t
  ControlWaitNotFocus(QuestionFieldName)
  WinClip.Restore( clipData )
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