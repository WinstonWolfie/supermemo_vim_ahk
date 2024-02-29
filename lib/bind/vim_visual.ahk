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
    Send {Home}
    if (Vim.State.n) {
      Send % "+{Down " . Vim.State.n - 1 . "}"
      Vim.State.SetMode("Vim_VisualLine")
    } else {
      Vim.State.SetMode("Vim_VisualLineFirst")
    }
    Send +{End}
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
    } else if (WinActive("ahk_group SM")) {
      Goto VisualLine
    } else {
      if (!WinActive("ahk_exe notepad++.exe"))  ; notepad++ requires alt down
        Send ^b
      Vim.State.SetMode("Vim_VisualBlock")
    }
  }
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && !Vim.State.fts && !Vim.State.Surround)
; Visual to insert
+i::
  Send {Left}
  Vim.State.SetMode("Insert")
Return

+a::
  Send {Right}
  Vim.State.SetMode("Insert")
Return

^g::Vim.State.SetMode("Insert")  ; select mode

; ydc
y::
  vim.move.YdcClipSaved := Copy(false,, "^c{Right}")
  if (WinActive("ahk_group VimCursorSameAfterSelect"))
    Send {Left}
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  } else {
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

d::
x::
  if (!Vim.State.Leader) {
    vim.move.YdcClipSaved := Copy(false,, "^x")
  } else {
    Send {BS}
  }
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  } else {
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

c::
  if (!Vim.State.Leader) {
    vim.move.YdcClipSaved := Copy(false,, "^x")
  } else {
    Send {BS}
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
    Send ^f
    WinWaitNotActive, % "ahk_id " . hWnd,, 0.3
    Send ^v
    WinClip._waitClipReady()
    Send {Enter}
  }
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
Return

^p::
+p::
^+p::
p::
  ; Get selection
  if (!Vim.State.Leader) {
    PrevClip := ClipboardAll
    Copy(false)
    NewClip := ClipboardAll
    if (PrevClip) {
      WinClip.Clear()
      Clipboard := PrevClip
      ClipWait
    }
  }

  if (IfContains(A_ThisLabel, "^"))
    Clipboard := Clipboard  ; convert to plain text
  Send ^v

  if (!Vim.State.Leader) {
    WinClip._waitClipReady()
    Clipboard := NewClip
  }
  Vim.State.SetMode("Vim_Normal")
Return

ConvertToLowercase:
ConvertToUppercase:
u::
+u::
  ClipSaved := ClipboardAll
ConvertToLowercaseClipped:
ConvertToUppercaseClipped:
  html := Vim.SM.IsEditingHTML() ? "sm" : Vim.IsHTML()
  KeyWait Shift
  if (IfIn(A_ThisLabel, "ConvertToLowercase,u,ConvertToLowercaseClipped")) {
    Clip(StrLower(Copy(false, html)),, false, html)
  } else if (IfIn(A_ThisLabel, "ConvertToUppercase,+u,ConvertToUppercaseClipped")) {
    Clip(StrUpper(Copy(false, html)),, false, html)
  }
  WinClip._waitClipReady()
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
Return

; https://www.autohotkey.com/board/topic/24431-convert-text-uppercase-lowercase-capitalized-or-inverted/
InvertCase:
~::
  ClipSaved := ClipboardAll
InvertCaseClipped:
  Selection := Copy(false, html := Vim.SM.IsEditingHTML() ? "sm" : Vim.IsHTML())
  Lab_Invert_Char_Out:= ""
  Loop % Strlen(Selection) {
    Lab_Invert_Char:= Substr(Selection, A_Index, 1)
    if Lab_Invert_Char is upper
       Lab_Invert_Char_Out:= Lab_Invert_Char_Out Chr(Asc(Lab_Invert_Char) + 32)
    else if Lab_Invert_Char is lower
       Lab_Invert_Char_Out:= Lab_Invert_Char_Out Chr(Asc(Lab_Invert_Char) - 32)
    else
       Lab_Invert_Char_Out:= Lab_Invert_Char_Out Lab_Invert_Char
  }
  KeyWait Shift
  Clip(Lab_Invert_Char_Out,, false, html)
  WinClip._waitClipReady()
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
Return

o::  ; move to other end of marked area; not perfect with line breaks
  ClipSaved := ClipboardAll
  if (!Selection := Copy(false)) {
    Clipboard := ClipSaved
    return
  }
  SelectionLen := StrLen(Vim.ParseLineBreaks(Selection))
  Send +{Right}
  SelectionRight := Copy(false)
  SelectionRightLen := StrLen(Vim.ParseLineBreaks(SelectionRight))
  Send +{Left}
  if ((SelectionLen < SelectionRightLen)
   || ((SelectionLen == SelectionRightLen)
    && (StrLen(Selection) < StrLen(SelectionRight)))) {  ; moving point of selection is on the right
    Send % "{Right}+{Left " . SelectionLen . "}"
  } else if ((SelectionLen > SelectionRightLen)
          || ((SelectionLen == SelectionRightLen)
           && (StrLen(Selection) > StrLen(SelectionRight)))) {
    Send % "{Left}+{Right " . SelectionLen . "}"
  }
  Clipboard := ClipSaved
return

+s::Vim.State.SetMode(,,,,, 1)  ; surround
