; Editing text only
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText())
+h::  ; move to top of screen
  KeyWait Shift  ; to avoid clicking becomes selecting
  Vim.SM.ClickTop()
Return

+m::  ; move to middle of screen
  KeyWait Shift  ; to avoid clicking becomes selecting
  Vim.SM.ClickMid()
Return

+l::  ; move to bottom of screen
  KeyWait Shift  ; to avoid clicking becomes selecting
  Vim.SM.ClickBottom()
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText())
^/::send {home}//{space}
+!a::send /*  */{left 3}

; Editing HTML
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
  if (!copy(false,,, "+{right}^c{left}")) {  ; end of line
    copy(false,,, "+{right}^c{right}")
  } else if (Clipboard ~= "\s") {
    copy(false,,, "+{left}^c{right}")
  }
  LinkMatch := "(<A((.|\r\n)*)href="")\K[^""]+"
  If (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, LinkMatch, CurrLink)
    if (!CurrLink) {
      copy(false,,, "+{left}^c{right}")
      If (Vim.HTML.ClipboardGet_HTML(data)) {
        RegExMatch(data, LinkMatch, CurrLink)
        if (!CurrLink)
          ToolTip("No link found.")
      }
    }
    if (CurrLink) {
      if (A_ThisHotkey == "u") {
        Clipboard := CurrLink, ToolTip("Copied " . CurrLink)
      } else if (IfContains(A_ThisHotkey, "x")) {
        Vim.SM.RunLink(Currlink)
      }
    }
  }
  if (A_ThisHotkey != "u")
    Clipboard := ClipSaved
return

s::  ; gs: go to source
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^+f6::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && Vim.State.g)
f::  ; gf: open source file
n::  ; gn: open in Notepad
  Vim.State.SetMode()
  hwnd := WinGet(), ContLearn := Vim.SM.IsLearning()
  if (Notepad := IfIn(A_ThisHotkey, "^+f6,n")) {
    Vim.SM.ExitText(true)
    send ^{f7}
    send ^+{f6}
  } else {
    path := Vim.SM.GetFilePath()
    SplitPath, path,,, ext
    if (IfIn(ext, "bmp,gif,jpg,jpeg,wmf,png,tif,tiff,ico")) {  ; image extensions that SM supports
      run % "C:\Program Files\Adobe\Adobe Photoshop 2021\Photoshop.exe " . path
    } else {
      send ^{f7}  ; save read point
      path := Vim.SM.SaveHTML(, true)  ; path may be updated
      Vim.SM.ExitText(true)
      run % StrReplace(A_AppData, "Roaming") . "Local\Programs\Microsoft VS Code\Code.exe " . path
    }
  }
  WinWaitNotActive % "ahk_id " . hwnd
  WinWaitActive % "ahk_id " . hwnd
  if (Notepad) {
    send !{f7}
  } else {
    send !{home}
  }
  if (ContLearn == 1) {
    Vim.SM.Learn()
  } else if (!Notepad) {
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

#if (Vim.State.Vim.Enabled
  && ((Vim.State.Leader && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents") || WinActive("ahk_class TBrowser")))  ; main windows: require leader key
   || Vim.SM.IsLearning()
   || Vim.SM.IsGrading()
   || (WinGet() == ImportGuiHwnd)
   || (WinActive("Priority") && WinActive("ahk_class #32770"))
   || WinActive("ahk_class TPriorityDlg")))
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

#if (Vim.State.Vim.Enabled && ((Vim.State.Leader && WinActive("ahk_class TElWind")) || Vim.SM.IsLearning() || Vim.SM.IsGrading()))
^!0::
^Numpad0::
^NumpadIns::Vim.SM.RandCtrlJ(1, 3)

^!1::
^Numpad1::
^NumpadEnd::Vim.SM.RandCtrlJ(4, 8)

^!2::
^Numpad2::
^NumpadDown::Vim.SM.RandCtrlJ(9, 18)

^!3::
^Numpad3::
^NumpadPgdn::Vim.SM.RandCtrlJ(19, 28)

^!4::
^Numpad4::
^NumpadLeft::Vim.SM.RandCtrlJ(29, 37)

^!5::
^Numpad5::
^NumpadClear::Vim.SM.RandCtrlJ(38, 46)

^!6::
^Numpad6::
^NumpadRight::Vim.SM.RandCtrlJ(47, 57)

^!7::
^Numpad7::
^NumpadHome::Vim.SM.RandCtrlJ(58, 70)

^!8::
^Numpad8::
^NumpadUp::Vim.SM.RandCtrlJ(71, 90)

^!9::
^Numpad9::
^NumpadPgup::Vim.SM.RandCtrlJ(91, 99)