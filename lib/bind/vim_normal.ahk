#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.g)
; Undo/Redo
u::Send % "^{z " . Vim.State.GetN() . "}"

^r::Send,^y

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.g && !Vim.IsNavigating())
; Combine lines
+j:: Send {End}{Space}{Delete}
+k:: Send {Up}{End}{Space}{Delete}

; Change case
~::
  Send +{Right}
  if (IfIs(Selection := Copy(), "lower")) {
    Selection := StrUpper(Selection)
  } else if (IfIs(Selection, "upper")) {
    Selection := StrLower(Selection)
  }
  Send % "{text}" . Selection
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.g)
+z::Vim.State.SetMode("Z")
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Z"))
+z::
  if (WinActive("ahk_class TInputDlg")) {
    Send ^{Enter}
  } else {
    Send ^s
    if (WinActive("ahk_exe Notepad.exe")) {
      Send ^w
    } else {
      Send !{F4}
    }
  }
  Vim.State.SetMode("Vim_Normal")
Return

+q::
  hWnd := WinActive("A"), SMInputDlg := WinActive("ahk_class TInputDlg")
  if (WinActive("ahk_exe Notepad.exe")) {
    Send ^w
  } else {
    Send !{F4}
  }
  if (SMInputDlg) {
    WinWaitActive, ahk_class TMsgDialog,, 0
    if (!ErrorLevel)
      Send {text}n
  } else {
    WinWaitClose, % "ahk_id " . hWnd,, 0.3
    if (ErrorLevel) {
      if (hWnd := WinActive("ahk_exe Notepad.exe")) {
        UIA := UIA_Interface(), el := UIA.ElementFromHandle(hWnd)
        el.WaitElementExist("ControlType=Button AND Name='Don\'t save' AND AutomationId='SecondaryButton'",,,, 1000).Click()
      }
    }
  }
  Vim.State.SetMode("Vim_Normal")
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.Move.LastKey)
; Period
; .::Send +^{Right}{BS}^v  ; original vim_ahk; no idea what that means
.::  ; dot repeat
  Vim.State.n := Vim.State.n ? Vim.State.n : Vim.Move.LastN
  Vim.State.Mode := Vim.Move.LastMode, Vim.State.Surround := Vim.Move.LastSurround
  if (Vim.Move.LastFtsChar)
    Vim.State.FtsChar := Vim.Move.LastFtsChar
  if (Vim.Move.LastLineCopy) {
    Vim.Move.YDCMove()
  } else if (Vim.Move.LastInOrOut == "Inner") {
    Vim.Move.Inner(Vim.Move.LastKey)
  } else if (Vim.Move.LastInOrOut == "Outer") {
    Vim.Move.Outer(Vim.Move.LastKey)
  } else if (Vim.Move.LastRepeat) {
    Vim.Move.Repeat(Vim.Move.LastKey)
  } else {
    Vim.Move.Move(Vim.Move.LastKey)
  }
  if (Vim.Move.LastSurround)
    Goto VimSurround
return

#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")))
^e::Vim.Move.Repeat("^e")
^y::Vim.Move.Repeat("^y")

; Q-dir
#if (Vim.IsVimGroup() && WinActive("ahk_group VimQdir") && (Vim.State.Mode == "Vim_Normal"))
; For Q-dir, ^X mapping does not work, use !X instead.
; ^X does not work to be sent, too, use Down/Up
; switch to left top (1), right top (2), left bottom (3), right bottom (4)
!u::Send {LControl Down}{1 Down}{1 Up}{LControl Up}
!i::Send {LControl Down}{2 Down}{2 Up}{LControl Up}
!j::Send {LControl Down}{3 Down}{3 Up}{LControl Up}
!k::Send {LControl Down}{4 Down}{4 Up}{LControl Up}
; Ctrl+q, menu Quick-links
'::Send {LControl Down}{q Down}{q Up}{LControl Up}
; Keep the e key in Normal mode, use the right button and then press the refresh (e) function, do nothing, return to the e key directly
~e::
Return

#if
