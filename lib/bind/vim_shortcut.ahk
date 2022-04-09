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
; ^!+t::
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
#If Vim.State.Vim.Enabled && WinActive("ahk_group Browsers")
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

^!l::  ; copy link and parse *l*ink if if's from YT
	Vim.ReleaseKey("ctrl")
  Clipboard := ""
  While, !Clipboard {
    send ^l^c
    ClipWait, 0.2
  }
  send {f6 2}
  temp_clip := RegExReplace(Clipboard, "#(.*)$")
  if InStr(temp_clip, "https://www.youtube.com") && InStr(temp_clip, "v=") {
    RegExMatch(temp_clip, "v=\K[\w\-]+", yt_link)
    temp_clip = https://www.youtube.com/watch?v=%yt_link%
  }
  Clipboard := temp_clip
  Vim.ToolTip("Copied " . temp_clip)
return

^!d::  ; parse similar and opposite in google *d*efine
  Clipboard := ""
  send ^c
  ClipWait 0.6
  temp_clip := RegExReplace(Clipboard, "(?<!(Similar)|(?<![^:])|(?<![^.])|(?<![^""]))\r\n", "; ")
  temp_clip := StrReplace(temp_clip, "`r`nSimilar", "`r`n`r`nSimilar")
  temp_clip := StrReplace(temp_clip, "; Opposite", "`r`n`r`nOpposite")
  temp_clip := StrReplace(temp_clip, "Opposite; ", "Opposite`r`n")
  Clipboard := StrReplace(temp_clip, "vulgar slang", "vulgar slang > ")
  Vim.ToolTip("Copied:`n`n" . temp_clip)
return

; SumatraPDF/Calibre to SuperMemo
#If Vim.State.Vim.Enabled && (WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe ebook-viewer.exe"))
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
    if WinActive("ahk_class SUMATRA_PDF_FRAME") {
      reader := "p"
      send a
    } else if WinActive("ahk_exe ebook-viewer.exe") {
      reader := "e"
      send h
      sleep 10
      send ^{enter}
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
  if ctrl_state
    send !{left}
  else
    if (reader == "p")
      WinActivate, ahk_class SUMATRA_PDF_FRAME
    else if (reader == "e")
      WinActivate, ahk_exe ebook-viewer.exe
  Clipboard := ClipSaved
return

; SumatraPDF
#If Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") and !(Vim.State.IsCurrentVimMode("Z"))
+z::Vim.State.SetMode("Z")
#If Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") and (Vim.State.IsCurrentVimMode("Z"))
+z::  ; exit and save annotations
  send q
  WinWaitActive, Unsaved annotations,, 0
  if !ErrorLevel
    send {tab 2}{enter}
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
