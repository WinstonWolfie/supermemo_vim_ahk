; Launch Settings
#If Vim.State.Vim.Enabled
^!+v::
  Vim.Setting.ShowGui()
Return

; Check Mode
#If Vim.IsVimGroup()
^!+c::
  Vim.State.CheckMode(4, Vim.State.Mode)
Return

; Suspend/restart
; Every other shortcut is disabled when vim_ahk is disabled, save for this one
#If
^!+s::
  Vim.State.ToggleEnabled()
Return

; Testing
; ^!+t::WinMinimize, ahk_exe sm18.exe
;   clip_saved := ClipboardAll
;   LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
;   SendInput, ^c
;   ClipWait, LongCopy ? 0.6 : 0.2, True
;   MsgBox % Clipboard
;   Clipboard := clip_saved
; Return

; Shortcuts
#If Vim.State.Vim.Enabled
^!r::Reload

LAlt & RAlt::  ; for laptop
  KeyWait LAlt
  KeyWait RAlt
  send {AppsKey}
  Vim.State.SetMode("Insert")
return

#f::run % "C:\Program Files\Everything 1.5a\Everything64.exe"

; Browsers
#If (Vim.State.Vim.Enabled && WinActive("ahk_group Browsers"))
^!w::send ^w!{tab}  ; close tab and switch back

^!i::  ; open in *I*E
	Vim.ReleaseKey("ctrl")
  clip_saved := ClipboardAll
  Clipboard := ""
  While, !Clipboard {
    send ^l^c
    ClipWait, 0.2
  }
  send {f6 2}
  link := RegExReplace(Clipboard, "#(.*)$")
  Run, % "iexplore.exe " . link
  Clipboard := clip_saved
Return

^!d::  ; copy title
	Vim.ReleaseKey("ctrl")
  WinGetActiveTitle, CurrentTitle
  send ^d
  WinWaitNotActive, % CurrentTitle,, 1
  Clipboard := ""
  while !Clipboard {
    send ^c
    ClipWait 0.2
  }
  Clipboard := StrReplace(Clipboard, " - YouTube")
  send +{tab 2}{enter}
  Vim.ToolTip("Copied " . Clipboard)
return

^!l::  ; copy link and parse *l*ink if if's from YT
	Vim.ReleaseKey("ctrl")
  GetBrowserInfo(BrowserTitle, BrowserUrl, BrowserSource)
  Vim.ToolTip("Copied " . BrowserUrl . "`nTitle: " . BrowserTitle . "`nSource: " . BrowserSource)
  Clipboard := BrowserUrl
return

^!+d::  ; parse similar and opposite in google *d*efine
  Clipboard := ""
  send ^c
  ClipWait 0.6
  temp_clip := RegExReplace(Clipboard, "(?<!(Similar)|(?<![^:])|(?<![^.])|(?<![^""]))\r\n", "; ")
  temp_clip := StrReplace(temp_clip, "`r`nSimilar", "`r`n`r`nSimilar")
  temp_clip := StrReplace(temp_clip, "; Opposite", "`r`n`r`nOpposite")
  temp_clip := StrReplace(temp_clip, "; Opuesta", "`r`n`r`nOpuesta")
  temp_clip := StrReplace(temp_clip, "Opposite; ", "Opposite`r`n")
  temp_clip := StrReplace(temp_clip, "Opuesta; ", "Opuesta`r`n")
  Clipboard := StrReplace(temp_clip, "vulgar slang", "vulgar slang > ")
  Vim.ToolTip("Copied:`n`n" . temp_clip)
return

^+!a::  ; import to supermemo
	Vim.ReleaseKey("ctrl")
	Vim.ReleaseKey("shift")
  KeyWait alt
  FormatTime, CurrentTime,, yyyy-MM-dd HH:mm:ss:%A_msec%
  ClipSaved := ClipboardAll
  clipboard := ""
  send ^c
  ClipWait 0.6
  if (ErrorLevel) {
    send ^a^c
    clipwait 0.6
    if (ErrorLevel)
      Return
  }
  GetBrowserInfo(BrowserTitle, BrowserUrl, BrowserSource)
  if (Vim.HTML.ClipboardGet_Html(Data)) {
    Html := Vim.HTML.Clean(data)
    RegExMatch(Html, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", Html)
    ; SetClipboardHTML(Html)
    if (BrowserSource) {
      clipboard := Html . "<br>#SuperMemo Reference:"
                  . "<br>#Date: Imported on " . CurrentTime
                  . "<br>#Source: " . BrowserSource
                  . "<br>#Link: " . BrowserUrl
                  . "<br>#Title: " . BrowserTitle
    } else {
      clipboard := Html . "<br>#SuperMemo Reference:"
                  . "<br>#Date: Imported on " . CurrentTime
                  . "<br>#Link: " . BrowserUrl
                  . "<br>#Title: " . BrowserTitle
    }
    ClipWait
    WinActivate, ahk_class TElWind
    send ^n
		WinWaitNotActive, ahk_class TElWind,, 1.5  ; could appear a loading bar
		if (!ErrorLevel)
			WinWaitActive, ahk_class TElWind,, 5
		send ^a^+1
		WinWaitNotActive, ahk_class TElWind,, 1.5  ; could appear a loading bar
		if (!ErrorLevel)
			WinWaitActive, ahk_class TElWind,, 5
    send +{home}!t  ; set title
    send {esc}^+{f6}
    ; WinWaitActive, ahk_class Notepad,, 5
    WinWaitNotActive, ahk_class TElWind,, 5
    WinKill, ahk_class Notepad
  }
  BrowserUrl := BrowserTitle := BrowserSource := ""
  Vim.State.SetMode("Vim_Normal")
  sleep 700
  clipboard := ClipSaved
Return

; SumatraPDF/Calibre to SuperMemo
#If Vim.State.Vim.Enabled && (WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe ebook-viewer.exe") || WinActive("ahk_group Browsers"))
^!x::
!x::  ; pdf/epub extract to supermemo
  ctrl_state := GetKeyState("ctrl")
  KeyWait alt
  ClipSaved := ClipboardAll
  Clipboard := ""
  send ^c  ; clip() doesn't keep format; nor Clipboardall can work with functions
  ClipWait 0.6
  extract := Clipboardall
  if !extract {
    Vim.ToolTip("Nothing is selected.")
    return
  } else {
    WinGet, hwnd, ID, A
    if WinActive("ahk_class SUMATRA_PDF_FRAME") {
      send a
    } else if WinActive("ahk_exe ebook-viewer.exe") {
      send q  ; needs to enable this shortcut in settings
    } else if WinActive("ahk_group Browsers") {
      send !h
    }
    if !WinExist("ahk_group SuperMemo") {
      Vim.ToolTip("SuperMemo is not open, please open SuperMemo and paste your text.")
      return
    }
  }
  WinActivate, ahk_class TElWind  ; focus to element window
  Vim.SM.DeselectAllComponents()
  send q
  Vim.SM.WaitTextFocus()
  ControlGetFocus, current_focus, ahk_class TElWind
  if (current_focus != "Internet Explorer_Server1") {
    Vim.ToolTip("No html component is focused, please go to the topic you want and paste your text.")
    return
  }
  send ^{home}^+{down}  ; go to top and select first paragraph below
  if RegExMatch(clip(), "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])") {
    send {left}
    Vim.ToolTip("Please make sure current element is an empty html topic. Your extract is now on your clipboard.")
    return
  }
  send {left}
  clip(extract,, true)
  send ^+{home}  ; select everything
  send !x  ; extract
  Vim.SM.WaitProcessing()
  send {down}
  send !\\
  WinWaitNotActive, ahk_class TElWind,, 0
  send {enter}
  WinWaitNotActive, ahk_class TMsgDialog,, 0
  send {esc}
  if ctrl_state {
    send !{left}
  } else {
    WinActivate, ahk_id %hwnd%
  }
  Clipboard := ClipSaved
return

; SumatraPDF
#If (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && !Vim.State.IsCurrentVimMode("Z"))
+z::Vim.State.SetMode("Z")
#If (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && Vim.State.IsCurrentVimMode("Z"))
+z::  ; exit and save annotations
  send q
  WinWaitActive, Unsaved annotations,, 1
  if (!ErrorLevel)
    send {tab 2}{enter}
  if (WinExist("ahk_class TElWind"))
    WinActivate
  Vim.State.SetMode("Vim_Normal")
return

; IE
#If Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe")
^+c::  ; open in default browser (in my case, chrome); similar to default shortcut ^+e to open in ms edge
  Vim.KeyRelease("ctrl")
  Vim.KeyRelease("shift")
  loop {
    sleep 20
    ControlGetFocus, current_focus, ahk_class IEFrame
    if (current_focus == "Edit1") {
      ControlGetText, current_text, Edit1
      run % current_text
      Return
    } else
      send ^l
    if (A_Index > 10)
      Return
  }
Return
