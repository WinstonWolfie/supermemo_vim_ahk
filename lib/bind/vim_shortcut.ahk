; Launch Settings
#if (Vim.State.Vim.Enabled)
^!+v::
  Vim.Setting.ShowGui()
Return

; Check Mode
#if (Vim.IsVimGroup())
^!+c::
  Vim.State.CheckMode(4, Vim.State.Mode)
Return

; Suspend/restart
; Every other shortcut is disabled when vim_ahk is disabled, save for this one
#if
^!+s::
  Vim.State.ToggleEnabled()
Return

; Testing
; ^!+t::
;   run, % ComSpec . " /c python -m http.server", C:\SuperMemo\server, hide
; return

; Shortcuts
#if (Vim.State.Vim.Enabled)
^!r::Reload

LAlt & RAlt::  ; for laptop
  KeyWait LAlt
  KeyWait RAlt
  send {AppsKey}
  Vim.State.SetMode("Insert")
return

#f::run % "C:\Program Files\Everything 1.5a\Everything64.exe"

; Browsers
#if (Vim.State.Vim.Enabled && WinActive("ahk_group Browsers"))
^!w::send ^w!{tab}  ; close tab and switch back
!l::
  if (WinActive("ahk_exe chrome.exe")) {
    send ^l+{f6}  ; focus to text
  } else if (WinActive("ahk_exe msedge.exe")) {
    send ^l{f6}
  }
return

^!i::  ; open in *I*E
	ReleaseKey("ctrl")
  Run % "iexplore.exe " . ParseUrl(GetActiveBrowserURL())
Return

^!t::  ; copy title
	ReleaseKey("ctrl")
  GetBrowserInfo(BrowserTitle, BrowserUrl, BrowserSource, BrowserDate)
  Vim.ToolTip("Copied " . BrowserTitle)
  Clipboard := BrowserTitle
  BrowserUrl := BrowserTitle := BrowserSource := BrowserDate := ""
return

^!l::  ; copy link and parse *l*ink if if's from YT
  GetBrowserInfo(BrowserTitle, BrowserUrl, BrowserSource, BrowserDate)
  source := BrowserSource ? "`nSource: " . BrowserSource : ""
  date := BrowserDate ? "`nDate: " . BrowserDate : ""
  Vim.ToolTip("Copied " . BrowserUrl . "`nTitle: " . BrowserTitle . source . date)
  Clipboard := BrowserUrl
return

^!d::  ; parse similar and opposite in google *d*efine
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  TempClip := RegExReplace(Clipboard, "(?<!(Similar)|(?<![^:])|(?<![^.])|(?<![^""]))\r\n", ", ")
  TempClip := StrReplace(TempClip, "`r`nSimilar`r`n", "`r`n`r`nsyn: ")
  TempClip := StrReplace(TempClip, "Similar:`r`n", "`r`nsyn: ")
  TempClip := StrReplace(TempClip, "Synonymes :`r`n", "`r`nsyn: ")
  TempClip := StrReplace(TempClip, ", Opposite:`r`n", "`r`n`r`nant: ")
  TempClip := StrReplace(TempClip, ", Opposite`r`n", "`r`n`r`nant: ")
  TempClip := StrReplace(TempClip, ", Opuesta`r`n", "`r`n`r`nant: ")
  TempClip := StrReplace(TempClip, "ant: , ", "ant: ")
  Clipboard := StrReplace(TempClip, "vulgar slang", "vulgar slang > ")
  Vim.ToolTip("Copied:`n`n" . TempClip)
return

^!a::  ; import to supermemo
	ReleaseKey("ctrl")
	ReleaseKey("shift")
  KeyWait alt
  FormatTime, CurrentTime,, % "yyyy-MM-dd HH:mm:ss:" . A_msec
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (!Clipboard) {
    send ^a^c
    ClipWait, LongCopy ? 0.6 : 0.2, True
    if (!Clipboard)
      Return
  }
  GetBrowserInfo(BrowserTitle, BrowserUrl, BrowserSource, BrowserDate)
  if (Vim.HTML.ClipboardGet_HTML(data)) {
    HTML := Vim.HTML.Clean(data)
    RegExMatch(HTML, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", HTML)
    source := BrowserSource ? "<br>#Source: " . BrowserSource : ""
    date := BrowserDate ? "<br>#Date: " . BrowserDate
                        : "<br>#Date: Imported on " . CurrentTime
    clipboard := HTML
               . "<br>#SuperMemo Reference:"
               . "<br>#Link: " . BrowserUrl
               . source
               . date
               . "<br>#Title: " . BrowserTitle
    ClipWait 10
    WinActivate, ahk_class TElWind
    SetDefaultKeyboard(0x0409)  ; english-US	
    send ^{enter}h{enter}  ; clear search highlight, just in case
    WinWaitActive, ahk_class TElWind,, 0
    send ^n
		WinWaitNotActive, ahk_class TElWind,, 1.5  ; could appear a loading bar
		if (!ErrorLevel)
			WinWaitActive, ahk_class TElWind,, 5
		send ^a^+1
		WinWaitNotActive, ahk_class TElWind,, 1.5  ; could appear a loading bar
		if (!ErrorLevel)
			WinWaitActive, ahk_class TElWind,, 5
    MouseGetPos, XCoord, YCoord
    send +{home}
    WaitCaretMove(XCoord, YCoord)
    send !t  ; set title
		WinWaitNotActive, ahk_class TElWind,, 1.5  ; could appear a loading bar
		if (!ErrorLevel)
			WinWaitActive, ahk_class TElWind,, 5
    send {esc}^+{f6}
    ; WinWaitActive, ahk_class Notepad,, 5
    WinWaitNotActive, ahk_class TElWind,, 5
    WinClose, ahk_class Notepad
  }
  BrowserUrl := BrowserTitle := BrowserSource := BrowserDate := ""
  Vim.State.SetMode("Vim_Normal")
  sleep 700
  WinClip.Restore(ClipData)
Return

^!c::  ; copy and save references
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (ErrorLevel)
    WinClip.Restore(ClipData)
  GetBrowserInfo(BrowserTitle, BrowserUrl, BrowserSource, BrowserDate)
  source := BrowserSource ? "`nSource: " . BrowserSource : ""
  date := BrowserDate ? "`nDate: " . BrowserDate : ""
  Vim.ToolTip("Copied " . Clipboard . "`nLink: " . BrowserUrl . "`nTitle: " . BrowserTitle . source . date)
return

; SumatraPDF/Calibre/MS Word to SuperMemo
#if (Vim.State.Vim.Enabled && (WinActive("ahk_class SUMATRA_PDF_FRAME")  ; SumatraPDF
                            || WinActive("ahk_exe ebook-viewer.exe")     ; Calibre (a epub viewer)
                            || WinActive("ahk_group Browsers")           ; browser group (chrome, edge, etc)
                            || WinActive("ahk_exe WINWORD.exe")))        ; MS Word
^!x::
!x::  ; pdf/epub extract to supermemo
  CtrlState := InStr(A_ThisHotkey, "^")
  KeyWait alt
  SetDefaultKeyboard(0x0409)  ; english-US	
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c  ; clip() doesn't keep format; nor ClipboardAll can work with functions
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (!Clipboard) {
    Vim.ToolTip("Nothing is selected.")
    return
  } else {
    WinGet, hwnd, ID, A
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
      Vim.ToolTip("SuperMemo is not open, please open SuperMemo and paste your text.")
      return
    }
  }
  extract := ClipboardAll
  WinActivate, ahk_class TElWind  ; focus to element window
  Vim.SM.DeselectAllComponents()
  send q
  Vim.SM.WaitTextFocus()
  if (ControlGetFocus() != "Internet Explorer_Server1") {
    Vim.ToolTip("No html component is focused, please go to the topic you want and paste your text.")
    return
  }
  send ^{home}^+{down}  ; go to top and select first paragraph below
  if (RegExMatch(clip(), "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])")) {
    send {left}
    Vim.ToolTip("Please make sure current element is an empty html topic. Your extract is now on your clipboard.")
    return
  }
  send {left}
  clip(extract,, true)
  send ^+{home}  ; select everything
  send !x  ; extract
  Vim.SM.WaitProcessing()
  Vim.SM.MoveAboveRef(true)
  send !\\
  WinWaitNotActive, ahk_class TElWind,, 0
  send {enter}
  WinWaitNotActive, ahk_class TMsgDialog,, 0
  send {esc}
  if (CtrlState) {
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
  WinWaitActive, Unsaved annotations,, 1
  if (!ErrorLevel)
    send s
  if (WinExist("ahk_class TElWind"))
    WinActivate
  Vim.State.SetMode("Vim_Normal")
return

#if (WinActive("ahk_class SUMATRA_PDF_FRAME"))
!p::ControlFocus, Edit1, A  ; focus to page number field so you can enter a number

; IE
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe"))
^+c::  ; open in default browser (in my case, chrome); similar to default shortcut ^+e to open in ms edge
  Vim.KeyRelease("ctrl")
  Vim.KeyRelease("shift")
  run % ControlGetText("Edit1")  ; browser url field
Return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class wxWindowNR") && WinExist("ahk_class TElWind"))  ; audacity.exe
^!x::
!x::
  FormatTime, CurrentTime,, yyyy-MM-dd HH:mm:ss:%A_msec%
  WinClip.Snap( clipData )
  if (A_ThisHotkey == "^!x") {
    send ^a^d  ; truncate silence
    WinWaitActive, Truncate Silence,, 5
    send -80{tab}0.001{tab 2}0{enter}  ; settings for truncate complete silence
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
  FileName := RegExReplace(BrowserTitle, "[^a-zA-Z0-9\\.\\-]", "_")
  if (BrowserTitle) {
    TempPath := A_Desktop . "\" . FileName . " (excerpt).mp3"
  } else {
    TempPath := A_Desktop . "\temp.mp3"
  }
  clip(TempPath,, true)
  send {enter}
  WinWaitActive, Warning,, 0.4
  if (!ErrorLevel) {
    send {enter}
    WinWaitNotActive, Warning,, 0
  }
  send ^a{bs}
  WinActivate, ahk_class TElWind
  send !a  ; new item
  Vim.SM.WaitTextFocus()
  ControlGetFocus, QuestionFieldName, A
  if (BrowserTitle) {
    if (BrowserSource) {
      QuestionField := BrowserTitle
                      . "`n#SuperMemo Reference:"
                      . "`n#Source: " . BrowserSource
                      . "`n#Link: " . BrowserUrl
                      . "`n#Title: " . BrowserTitle
    } else {
      QuestionField := BrowserTitle
                      . "`n#SuperMemo Reference:"
                      . "`n#Link: " . BrowserUrl
                      . "`n#Title: " . BrowserTitle
    }
    clip(QuestionField,, true)
  } else {
    QuestionField := ""
    send C:
  }
  send {ctrl down}ttq{ctrl up}
  GroupAdd, SMCtrlQ, ahk_class TFileBrowser
  GroupAdd, SMCtrlQ, ahk_class TMsgDialog
  WinWaitActive, ahk_group SMCtrlQ,, 5
  if (WinActive("ahk_class TMsgDialog")) {
    send n  ; Directory not found; Create?
    WinWaitActive, ahk_class TFileBrowser,, 5
  }
  send !dc  ; select C drive
  send !n  ; select file name
  clip(TempPath,, true)
  send {enter}
  WinWaitNotActive, ahk_class TFileBrowser,, 0
  if (BrowserTitle) {
    clip(BrowserTitle . " (excerpt)",, true)
  } else {
    clip("temp_",, true)
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
  BrowserUrl := BrowserTitle := BrowserSource := ""
Return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TRegistryForm"))
!p::ControlFocus, TEdit1  ; set priority for current selected concept in registry window

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg"))
; Use English input method for choosing concept when import
~!g::SetDefaultKeyboard(0x0409)  ; english-US	