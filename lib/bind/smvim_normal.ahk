; Editing text only
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText())
+h::  ; move to top of screen
  KeyWait shift  ; to avoid clicking becomes selecting
  Vim.SM.ClickTop()
Return

+m::  ; move to middle of screen
  KeyWait shift  ; to avoid clicking becomes selecting
  Vim.SM.ClickMid()
Return

+l::  ; move to bottom of screen
  KeyWait shift  ; to avoid clicking becomes selecting
  Vim.SM.ClickBottom()
Return

; Editing HTML
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText())
^/::send {home}//{space}
+!a::send /*  */{left 3}

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingHTML() && Vim.State.leader)
q::
  send {home}>{space}  ; add comment; useful when replying emails
  Vim.State.SetMode()
return

u::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingHTML() && Vim.State.g)
+x::
x::  ; open hyperlink in current caret position (Open in *n*ew window)
  Vim.State.SetMode()
  ClipSaved := ClipboardAll
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  KeyWait shift
  send +{right}^c{left}
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (ErrorLevel) {  ; end of line
    send +{right}^c{right}
  } else if (Clipboard ~= "\s") {
    WinClip.Clear()
    send +{left}^c{right}
  }
  ClipWait, LongCopy ? 0.6 : 0.2, True
  LinkMatch := "(<A((.|\r\n)*)href="")\K[^""]+", RunLink := false
  If (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, LinkMatch, CurrLink)
    if (!CurrLink) {
      WinClip.Clear()
      send +{left}^c{right}
      ClipWait, LongCopy ? 0.6 : 0.2, True
      If (Vim.HTML.ClipboardGet_HTML(data)) {
        RegExMatch(data, LinkMatch, CurrLink)
        if (!CurrLink) {
          ToolTip("No link found.")
        } else {
          RunLink := true
        }
      }
    } else {
      RunLink := true
    }
    if (RunLink) {
      if (A_ThisHotkey == "u") {
        Clipboard := CurrLink
        ToolTip("Copied " . CurrLink)
      } else if (IfContains(A_ThisHotkey, "x")) {
        vim.sm.runlink(currlink)
      }
    }
  }
  if ((A_ThisHotkey != "u") && RunLink)
    Clipboard := ClipSaved
return

s::  ; gs: go to source
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && Vim.State.g)
f::  ; gf: open source file
  Vim.State.SetMode()
  hwnd := WinGet(), ContLearn := Vim.SM.IsLearning(), path := Vim.SM.GetFilePath()
  SplitPath, path,,, ext
  if (IfIn(ext, "bmp,gif,jpg,jpeg,wmf,png,tif,tiff,ico")) {  ; image extensions that SM supports
    run % "C:\Program Files\Adobe\Adobe Photoshop 2021\Photoshop.exe " . path
  } else {
    send ^{f7}  ; save read point
    path := Vim.SM.SaveHTML(, true)  ; path may be updated
    send {esc}  ; leave html
    run % StrReplace(A_AppData, "Roaming") . "Local\Programs\Microsoft VS Code\Code.exe " . path
  }
  WinWaitNotActive % "ahk_id " . hwnd
  WinWaitActive % "ahk_id " . hwnd
  send !{home}
  if (ContLearn == 1) {
    Vim.SM.Learn()
  } else {
    Vim.SM.WaitFileLoad()
    send !{left}
  }
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TBrowser") && Vim.State.g)
+u::  ; gU: click source button
  Vim.SM.ClickBrowserSourceButton()
  Vim.State.SetMode()
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents") || WinActive("ahk_class TBrowser")))
!h::send !{left}
!l::send !{right}
!j::send !{pgdn}
!k::send !{pgup}
!u::send ^{up}

#if ((Vim.IsVimGroup() && Vim.State.Leader && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents") || WinActive("ahk_class TBrowser")))  ; main windows: require leader key
   || Vim.SM.IsLearning()
   || Vim.SM.IsGrading()
   || (WinGet() == ImportGuiHwnd)
   || (WinActive("Priority") && WinActive("ahk_class #32770"))
   || WinActive("ahk_class TPriorityDlg"))
; Priority script, originally made by Naess and modified by Guillem
; Details: https://www.youtube.com/watch?v=OwV5HPKMrbg
; Picture explaination: https://raw.githubusercontent.com/rajlego/supermemo-ahk/main/naess%20priorities%2010-25-2020.png
!0::
Numpad0::
NumpadIns::Vim.SM.SetRandPrio(0.00,3.6076)

!1::
Numpad1::
NumpadEnd::Vim.SM.SetRandPrio(3.6077,8.4131)

!2::
Numpad2::
NumpadDown::Vim.SM.SetRandPrio(8.4132,18.4917)

!3::
Numpad3::
NumpadPgdn::Vim.SM.SetRandPrio(18.4918,28.0885)

!4::
Numpad4::
NumpadLeft::Vim.SM.SetRandPrio(28.0886,37.2103)

!5::
Numpad5::
NumpadClear::Vim.SM.SetRandPrio(37.2104,46.24)

!6::
Numpad6::
NumpadRight::Vim.SM.SetRandPrio(46.25,57.7575)

!7::
Numpad7::
NumpadHome::Vim.SM.SetRandPrio(57.7576,70.5578)

!8::
Numpad8::
NumpadUp::Vim.SM.SetRandPrio(70.5579,90.2474)

!9::
Numpad9::
NumpadPgup::Vim.SM.SetRandPrio(90.2474,99.99)