#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Visual Char/Block/Line
#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")))
v::
  if (Vim.State.IsCurrentVimMode("Vim_Normal")) {
    Vim.State.SetMode("Vim_VisualFirst")
  } else if (Vim.State.IsCurrentVimMode("Vim_VisualChar,Vim_VisualFirst")) {
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
        Vim.Move.SelectParagraphDown(Vim.State.n), Vim.State.SetMode("Vim_VisualParagraph")
      } else {
        Vim.Move.SelectParagraphDown(), Vim.State.SetMode("Vim_VisualParagraphFirst")
      }
    } else if (WinActive("ahk_group SuperMemo")) {
      Goto VisualLine
    } else {
      if (!WinActive("ahk_exe notepad++.exe"))  ; notepad++ requires alt down
        send ^b
      Vim.State.SetMode("Vim_VisualBlock")
    }
  }
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && !Vim.State.fts && !Vim.State.Surround)
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
  vim.move.YdcClipSaved := Copy(false,,, "^c{Right}")
  if (WinActive("ahk_group VimCursorSameAfterSelect"))
    send {Left}
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  } else {
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

d::
x::
  if (!Vim.State.Leader) {
    vim.move.YdcClipSaved := Copy(false,,, "^x")
  } else {
    send {bs}
  }
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  } else {
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

c::
  if (!Vim.State.Leader) {
    vim.move.YdcClipSaved := Copy(false,,, "^x")
  } else {
    send {bs}
  }
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Insert", 0, 0, 1)
  } else {
    Vim.State.SetMode("Insert", 0, 0, 0)
  }
Return

*::
  ClipSaved := ClipboardAll
  Copy(false)
  if (WinActive("ahk_class TElWind")) {
    UserInput := Clipboard, CurrFocus := ControlGetFocus("ahk_class TElWind")
    CapsState := CtrlState := AltState := ShiftState := ""
    Gosub SMSearchAgain
  } else {
    hWnd := WinActive("A")
    send ^f
    WinWaitNotActive, % "ahk_id " . hWnd,, 0.25
    send ^v!f
  }
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
Return

^p::
+p::
^+p::
p::
  PasteOnly := Vim.State.Leader
  ; Get selection
  if (!PasteOnly) {
    PrevClip := ClipboardAll
    Copy(false)
    NewClip := ClipboardAll
    if (PrevClip) {
      WinClip.Clear()
      Clipboard := PrevClip
      ClipWait
    }
  }

  ; Paste clipboard
  if (IfContains(A_ThisHotkey, "^"))
    Clipboard := Clipboard  ; convert to plain text
  send ^v
  Vim.State.SetMode("Vim_Normal")

  if (!PasteOnly) {
    while (WinClipAPI.GetOpenClipboardWindow())
      sleep 1
    Clipboard := NewClip
  }
Return

ConvertToLowercase:
ConvertToUppercase:
u::
+u::
  ClipSaved := ClipboardAll
ConvertToLowercaseClipped:
ConvertToUppercaseClipped:
  html := Vim.SM.IsEditingHTML() ? "sm" : Vim.IsHTML()
  if (IfIn(A_ThisLabel, "ConvertToLowercase,u,ConvertToLowercaseClipped")) {
    Clip(StrLower(Copy(false, html)),, false, html)
  } else if (IfIn(A_ThisLabel, "ConvertToUppercase,+u,ConvertToUppercaseClipped")) {
    Clip(StrUpper(Copy(false, html)),, false, html)
  }
  sleep 100  ; while (WinClipAPI.GetOpenClipboardWindow()) doesn't work for some reason
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
Return

; https://www.autohotkey.com/board/topic/24431-convert-text-uppercase-lowercase-capitalized-or-inverted/
InvertCase:
~::
  ClipSaved := ClipboardAll
InvertCaseClipped:
  selection := Copy(false, html := Vim.SM.IsEditingHTML() ? "sm" : Vim.IsHTML())
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
  Clip(Lab_Invert_Char_Out,, false, html)
  sleep 100  ; while (WinClipAPI.GetOpenClipboardWindow()) doesn't work for some reason
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
Return

o::  ; move to other end of marked area; not perfect with line breaks
  ClipSaved := ClipboardAll
  if (!selection := Copy(false))
    Goto RestoreClipReturn
  SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
  send +{right}
  SelectionRight := Copy(false), SelectionRightLen := StrLen(Vim.ParseLineBreaks(SelectionRight))
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

+s::Vim.State.SetMode(,,,,, 1)  ; surround
