; Visual Char/Block/Line
#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")))
v::
  if (Vim.State.IsCurrentVimMode("Vim_Normal")) {
    Vim.State.SetMode("Vim_VisualFirst")
  } else if (Vim.State.IsCurrentVimMode("Vim_VisualChar") || Vim.State.IsCurrentVimMode("Vim_VisualFirst")) {
    Vim.State.SetNormal()
  } else {
    Vim.State.SetMode("Vim_VisualChar")
  }
Return

+v::
  if (Vim.State.StrIsInCurrentVimMode("VisualLine")) {
    Vim.State.SetNormal()
  } else {
    if (Vim.SM.IsEditingPlainText()) {
      XSaved := A_CaretX, YSaved := A_CaretY
      send {home}+{down}
      if (A_CaretX == XSaved && A_CaretY == YSaved)  ; didn't move
        send +{end}
    } else {
      send {Home}+{Down}
    }
    Vim.State.SetMode("Vim_VisualLineFirst")
  }
Return

^v::
  if (Vim.State.StrIsInCurrentVimMode("VisualBlock")) {
    Vim.State.SetNormal()
  } else if (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) {
    if (Vim.IsHTML()) {
      Vim.Move.ParagraphDown()
      Vim.Move.ParagraphUp()
      Vim.Move.SelectParagraphDown()
      Vim.State.SetMode("Vim_VisualParagraphFirst")
    } else if (Vim.SM.IsEditingPlainText()) {
      send {Home}+{Down}
      Vim.State.SetMode("Vim_VisualLineFirst")
    } else {
      if (!WinActive("ahk_exe notepad++.exe"))  ; notepad++ requires alt down
        send ^b
      Vim.State.SetMode("Vim_VisualBlock")
    }
  }
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual"))
; Visual to insert
+i::
  send {left}
  Vim.State.SetMode("Insert")
Return

+a::
  send {right}
  Vim.State.SetMode("Insert")
Return

^g::Vim.State.SetMode("Insert")  ; select mode

; ydc
y::
  Clipboard :=
  send ^c
  send {Right}
  if WinActive("ahk_group VimCursorSameAfterSelect") {
    send {Left}
  }
  ClipWait, 1
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  } else {
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

d::
  Clipboard :=
  send ^x
  ClipWait, 1
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  } else {
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

x::
  Clipboard :=
  send ^x
  ClipWait, 1
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  } else {
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

c::
  Clipboard :=
  send ^x
  ClipWait, 1
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Insert", 0, 0, 1)
  } else {
    Vim.State.SetMode("Insert", 0, 0, 0)
  }
Return

*::
  ReleaseKey("shift")
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  WinGet, hwnd, ID, A
  send ^f
  WinWaitNotActive, % "ahk_id " . hwnd,, 0.25
  send ^v!f
  WinClip.Restore(ClipData)
  Vim.State.SetMode("Vim_Normal")
Return

^p::
+p::
p::
  WinClip.Snap(ClipData)
  if (InStr(A_ThisHotkey, "^")) {
    Clipboard := Clipboard
    ClipWait 10
  }
  send ^v
  Vim.State.SetMode("Vim_Normal")
  sleep 20
  WinClip.Restore(ClipData)
Return

ConvertToLowercase:
u::
  WinClip.Snap(ClipData)
  selection := clip("",, true)
  StringLower, selection, selection
  clip(selection,, true)
  WinClip.Restore(ClipData)
  Vim.State.SetMode("Vim_Normal")
Return

ConvertToUppercase:
+u::
  WinClip.Snap(ClipData)
  selection := clip("",, true)
  StringUpper, selection, selection
  clip(selection,, true)
  WinClip.Restore(ClipData)
  Vim.State.SetMode("Vim_Normal")
Return

; https://www.autohotkey.com/board/topic/24431-convert-text-uppercase-lowercase-capitalized-or-inverted/
InvertCase:
~::
  ReleaseKey("shift")
  selection := clip()
  Lab_Invert_Char_Out:= ""
  Loop % Strlen(selection) {
    Lab_Invert_Char:= Substr(selection, A_Index, 1)
    if Lab_Invert_Char is upper
       Lab_Invert_Char_Out:= Lab_Invert_Char_Out Chr(Asc(Lab_Invert_Char) + 32)
    else if Lab_Invert_Char is lower
       Lab_Invert_Char_Out:= Lab_Invert_Char_Out Chr(Asc(Lab_Invert_Char) - 32)
    else
       Lab_Invert_Char_Out:= Lab_Invert_Char_Out Lab_Invert_Char
  }
  clip(Lab_Invert_Char_Out)
  Vim.State.SetMode("Vim_Normal")
Return

o::  ; move to other end of marked area; not perfect with line breaks
  WinClip.Snap(ClipData)
  selection := clip("",, true)
  if (!selection)
    Return
  SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
  send +{right}
  SelectionRight := clip("",, true)
  SelectionRightLen := StrLen(Vim.ParseLineBreaks(SelectionRight))
  send +{left}
  if (SelectionLen < SelectionRightLen)
      || (SelectionLen == SelectionRightLen && StrLen(selection) < StrLen(SelectionRight)) {  ; moving point of selection is on the right
    send {right}
    SendInput % "{shift down}{left " SelectionLen "}{shift up}"
  } else if (SelectionLen > SelectionRightLen)
             || (SelectionLen == SelectionRightLen && StrLen(selection) > StrLen(SelectionRight)) {
    send {left}
    SendInput % "{shift down}{right " SelectionLen "}{shift up}"
  }
  WinClip.Restore(ClipData)
return
