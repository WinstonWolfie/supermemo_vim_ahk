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

VisualLine:
+v::
  if (Vim.State.StrIsInCurrentVimMode("VisualLine")) {
    Vim.State.SetNormal()
  } else {
    send {home}
    if (Vim.State.n) {
      send % "+{down " . Vim.State.n - 1 . "}"
      Vim.State.SetMode("Vim_VisualLine")
    } else {
      Vim.State.SetMode("Vim_VisualLineFirst")
    }
    send +{end}
  }
Return

^v::
  if (Vim.State.StrIsInCurrentVimMode("VisualBlock")) {
    Vim.State.SetNormal()
  } else if (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) {
    if (Vim.IsHTML()) {
      Vim.Move.ParagraphDown()
      Vim.Move.ParagraphUp()
      if (Vim.State.n) {
        Vim.Move.SelectParagraphDown(Vim.State.n)
        Vim.State.SetMode("Vim_VisualParagraph")
      } else {
        Vim.Move.SelectParagraphDown()
        Vim.State.SetMode("Vim_VisualParagraphFirst")
      }
    } else if (Vim.SM.IsEditingPlainText()) {
      gosub VisualLine
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
  KeyWait shift
  ClipSaved := ClipboardAll
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  hwnd := WinGet()
  send ^f
  WinWaitNotActive, % "ahk_id " . hwnd,, 0.25
  send ^v!f
  Clipboard := ClipSaved
  Vim.State.SetMode("Vim_Normal")
Return

^p::
+p::
^+p::
p::
  JustPaste := Vim.State.Leader
  ; Get selection
  if (!JustPaste) {
    PrevClip := ClipboardAll
    LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
    send ^c
    ClipWait, LongCopy ? 0.6 : 0.2, True
    NewClip := ClipboardAll
    WinClip.Clear()
    Clipboard := PrevClip
  }

  ; Paste clipboard
  if (InStr(A_ThisHotkey, "^"))
    Clipboard := Clipboard  ; convert to plain text
  send ^v
  Vim.State.SetMode("Vim_Normal")

  if (!JustPaste) {
    while (WinClipAPI.GetOpenClipboardWindow())
      sleep 1
    Clipboard := NewClip
  }
Return

ConvertToLowercase:
u::
  ClipSaved := ClipboardAll
ConvertToLowercaseClipped:
  html := Vim.SM.IsEditingHTML() ? "sm" : Vim.IsHTML()
  selection := copy(false, html)
  StringLower, selection, selection
  clip(selection,, false, html)
  Clipboard := ClipSaved
  Vim.State.SetMode("Vim_Normal")
Return

ConvertToUppercase:
+u::
  ClipSaved := ClipboardAll
ConvertToUppercaseClipped:
  html := Vim.SM.IsEditingHTML() ? "sm" : Vim.IsHTML()
  selection := copy(false, html)
  StringUpper, selection, selection
  clip(selection,, false, html)
  Clipboard := ClipSaved
  Vim.State.SetMode("Vim_Normal")
Return

; https://www.autohotkey.com/board/topic/24431-convert-text-uppercase-lowercase-capitalized-or-inverted/
InvertCase:
~::
  ClipSaved := ClipboardAll
InvertCaseClipped:
  html := Vim.SM.IsEditingHTML() ? "sm" : Vim.IsHTML()
  selection := copy(false, html)
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
  clip(Lab_Invert_Char_Out,, false, html)
  Clipboard := ClipSaved
  Vim.State.SetMode("Vim_Normal")
Return

o::  ; move to other end of marked area; not perfect with line breaks
  ClipSaved := ClipboardAll
  if (!selection := copy(false)) {
    Clipboard := ClipSaved
    return
  }
  SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
  send +{right}
  SelectionRight := copy(false)
  SelectionRightLen := StrLen(Vim.ParseLineBreaks(SelectionRight))
  send +{left}
  if (SelectionLen < SelectionRightLen
   || (SelectionLen == SelectionRightLen && StrLen(selection) < StrLen(SelectionRight))) {  ; moving point of selection is on the right
    send % "{right}+{left " . SelectionLen . "}"
  } else if (SelectionLen > SelectionRightLen
          || (SelectionLen == SelectionRightLen && StrLen(selection) > StrLen(SelectionRight))) {
    send % "{left}+{right " . SelectionLen . "}"
  }
  Clipboard := ClipSaved
return

+s::Vim.State.SetMode("",,,,, 1)  ; surround