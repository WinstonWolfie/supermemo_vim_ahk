#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Editing text only
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingText())
+h::  ; move to top of screen
  KeyWait Shift  ; to avoid clicking becomes selecting
  SM.ClickTop()
Return

+m::  ; move to middle of screen
  KeyWait Shift  ; to avoid clicking becomes selecting
  SM.ClickMid()
Return

+l::  ; move to bottom of screen
  KeyWait Shift  ; to avoid clicking becomes selecting
  SM.ClickBottom()
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && SM.IsBrowsing() && Vim.State.g && VimLastSearch)
n::
  if (!SM.DoesTextExist()) {
    SetToolTip("Text not found.")
    return
  }
  SM.EditFirstQuestion(), SM.WaitTextFocus()
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && SM.IsEditingText() && Vim.State.g && VimLastSearch)
n::Vim.Move.Move("gn")

; Editing HTML
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingHTML() && Vim.State.Leader)
q::
  loop % n := Vim.State.GetN() {
    Send {Home}>{Space}  ; add comment; useful when replying emails
    if (n > 1)
      Send {Down}
    n--
  }
  Vim.State.SetMode()
return

u::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingHTML() && Vim.State.g)
+x::
x::  ; gx: open hyperlink in current caret position
  Vim.State.SetMode(), ClipSaved := ClipboardAll
  if (!Copy(false,, "+{Right}^c{Left}")) {  ; end of line
    Copy(false,, "+{Right}^c{Right}")
  } else if (Clipboard ~= "\s") {
    Copy(false,, "+{Left}^c{Right}")
  }
  LinkMatch := "(<A((.|\r\n)*)href="")\K[^""]+"
  If (ClipboardGet_HTML(data)) {
    RegExMatch(data, LinkMatch, CurrLink)
    if (!CurrLink) {
      Copy(false,, "+{Left}^c{Right}")
      If (ClipboardGet_HTML(data)) {
        RegExMatch(data, LinkMatch, CurrLink)
        if (!CurrLink)
          SetToolTip("No link found.")
      }
    }
    if (CurrLink) {
      CurrLink := StrReplace(CurrLink, "&amp;", "&")
      if (A_ThisLabel == "u") {
        SetToolTip("Copied " . Clipboard := CurrLink)
      } else if (IfContains(A_ThisLabel, "x")) {
        SM.RunLink(Currlink)
      }
    }
  }
  if (A_ThisLabel != "u")
    Clipboard := ClipSaved
return

s::  ; gs: go to source
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && Vim.State.g)
f::  ; gf: open source file
t::  ; gt: open in Notepad
  Vim.State.SetMode(), ContLearn := SM.IsLearning()
  ClipSaved := "", CurrTitle := WinGetTitle("A")
  if (Notepad := IfIn(A_ThisLabel, "^+f6,t")) {
    Send ^{f7}  ; save read point
    SM.OpenNotepad(), w := "ahk_exe Notepad.exe"
  } else {
    ClipSaved := ClipboardAll
    SMFilePath := SM.GetFilePath(false)
    SplitPath, SMFilePath,,, ext
    if (IfIn(ext, "bmp,gif,jpg,jpeg,wmf,png,tif,tiff,ico")) {  ; image extensions that SM supports
      ShellRun("ps", SMFilePath)
      w := "ahk_class Photoshop ahk_exe Photoshop.exe"
    } else {
      Send ^{f7}  ; save read point
      SM.SaveHTML()  ; path may be updated
      WinWaitActive, ahk_class TElWind
      SMFilePath := SM.GetFilePath(false)
      SM.ExitText(true)
      ShellRun("vim", SMFilePath)
      GroupAdd, Vim, ahk_class CASCADIA_HOSTING_WINDOW_CLASS ahk_exe WindowsTerminal.exe  ; Win 11
      GroupAdd, Vim, ahk_class ConsoleWindowClass ahk_exe cmd.exe  ; Win 10
      w := "ahk_group Vim"
    }
  }
  if (ClipSaved)
    Clipboard := ClipSaved
  WinWait % w
  WinWaitClose
  SM.ActivateElWind()
  if (Notepad) {
    Send !{f7}  ; go to read point
  } else {
    SM.GoHome()
  }
  if (ContLearn == 1) {
    SM.Learn()
  } else if (!Notepad) {
    SM.WaitFileLoad()
    t := WinGetTitle("A")
    SM.GoBack()
    if ((CurrTitle == t) && (CurrTitle ~= "^Concept: ")) {
      SM.WaitFileLoad()
      Send !{Right}
    }
  }
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingHTML())
>::Vim.State.SetMode("SMHTMLIncreaseIndent")
<::Vim.State.SetMode("SMHTMLDecreaseIndent")
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMHTMLIncreaseIndent") && SM.IsEditingHTML())
>::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && SM.IsEditingHTML())
>::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMHTMLDecreaseIndent") && SM.IsEditingHTML())
<::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && SM.IsEditingHTML())
<::
  KeyWait Shift
  if (A_ThisLabel == ">") {
    SM.EditBar(21) 
  } else if (A_ThisLabel == "<") {
    SM.EditBar(20)
  }
  Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TBrowser") && Vim.State.g)
; gU: click source button
+u::SM.ClickBrowserSourceButton(), Vim.State.SetMode()

#if (Vim.State.Vim.Enabled
  && ((Vim.State.Leader && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents") || WinActive("ahk_class TBrowser")))  ; main windows: require leader key
   || SM.IsLearning()
   || SM.IsGrading()
   || (WinActive("A") == SMImportGuiHwnd)
   || SM.IsPrioInputBox()
   || WinActive("ahk_class TPriorityDlg")))
; Priority script, originally made by Naess and modified by Guillem
; Details: https://www.youtube.com/watch?v=OwV5HPKMrbg
; Picture explaination: https://raw.githubusercontent.com/rajlego/supermemo-ahk/main/naess%20priorities%2010-25-2020.png
!0::
Numpad0::
NumpadIns::SM.SetRandPrio(0.00,3.6076)

!1::
Numpad1::
NumpadEnd::SM.SetRandPrio(3.6077,8.4131)

!2::
Numpad2::
NumpadDown::SM.SetRandPrio(8.4132,18.4917)

!3::
Numpad3::
NumpadPgdn::SM.SetRandPrio(18.4918,28.0885)

!4::
Numpad4::
NumpadLeft::SM.SetRandPrio(28.0886,37.2103)

!5::
Numpad5::
NumpadClear::SM.SetRandPrio(37.2104,46.24)

!6::
Numpad6::
NumpadRight::SM.SetRandPrio(46.25,57.7575)

!7::
Numpad7::
NumpadHome::SM.SetRandPrio(57.7576,70.5578)

!8::
Numpad8::
NumpadUp::SM.SetRandPrio(70.5579,90.2474)

!9::
Numpad9::
NumpadPgup::SM.SetRandPrio(90.2474,99.99)

#if (Vim.State.Vim.Enabled && ((Vim.State.Leader && WinActive("ahk_class TElWind"))
                             || SM.IsLearning()
                             || WinActive("ahk_class TPriorityDlg")
                             || SM.IsGrading()))
^0::
^Numpad0::
^NumpadIns::SM.SetRandInterval(1, 3)

^1::
^Numpad1::
^NumpadEnd::SM.SetRandInterval(4, 8)

^2::
^Numpad2::
^NumpadDown::SM.SetRandInterval(9, 18)

^3::
^Numpad3::
^NumpadPgdn::SM.SetRandInterval(19, 28)

^4::
^Numpad4::
^NumpadLeft::SM.SetRandInterval(29, 37)

^5::
^Numpad5::
^NumpadClear::SM.SetRandInterval(38, 46)

^6::
^Numpad6::
^NumpadRight::SM.SetRandInterval(47, 57)

^7::
^Numpad7::
^NumpadHome::SM.SetRandInterval(58, 70)

^8::
^Numpad8::
^NumpadUp::SM.SetRandInterval(71, 90)

^9::
^Numpad9::
^NumpadPgup::SM.SetRandInterval(91, 99)

^.::SM.SetInterval(1)
