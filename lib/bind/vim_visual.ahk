; Visual Char/Block/Line
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual"))
v::
	if Vim.State.IsCurrentVimMode("Vim_Normal")
		Vim.State.SetMode("Vim_VisualFirst")
	else if Vim.State.IsCurrentVimMode("Vim_VisualChar") || Vim.State.IsCurrentVimMode("Vim_VisualFirst")
		Vim.State.SetNormal()
	else
		Vim.State.SetMode("Vim_VisualChar")
Return

+v::
	if Vim.State.StrIsInCurrentVimMode("VisualLine")
		Vim.State.SetNormal()
	else {
		Send, {Home}+{Down}
		Vim.State.SetMode("Vim_VisualLineFirst")
	}
Return

^v::
	if Vim.State.StrIsInCurrentVimMode("VisualBlock")
		Vim.State.SetNormal()
	else if Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")
		if Vim.IsHTML() {
			Vim.Move.ParagraphDown()
			Vim.Move.ParagraphUp()
			Vim.Move.SelectParagraphDown()
			Vim.State.SetMode("Vim_VisualParagraphFirst")
		} else if Vim.SM.IsEditingPlainText() {
			Send, {Home}+{Down}
			Vim.State.SetMode("Vim_VisualLineFirst")
		} else {
			if !WinActive("ahk_exe notepad++.exe")  ; notepad++ requires alt down
				Send, ^b
			Vim.State.SetMode("Vim_VisualBlock")
		}
Return

#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual"))
; ydc
y::
  Clipboard :=
  Send, ^c
  Send, {Right}
  if WinActive("ahk_group VimCursorSameAfterSelect") {
    Send, {Left}
  }
  ClipWait, 1
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  }else{
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

d::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  }else{
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

x::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  }else{
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

c::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if (Vim.State.StrIsInCurrentVimMode("Line")) {
    Vim.State.SetMode("Insert", 0, 0, 1)
  }else{
    Vim.State.SetMode("Insert", 0, 0, 0)
  }
Return

*::
  Vim.ReleaseKey("shift")
  bak := ClipboardAll
  Clipboard :=
  Send, ^c
  ClipWait, 1
  sleep 20
  WinGet, hwnd, ID, A
  Send, ^f
  WinWaitNotActive, ahk_id %hwnd%,, 0.25
  Send, ^v!f
  clipboard := bak
  Vim.State.SetMode("Vim_Normal")
Return

^p::
p::
	if GetKeyState("ctrl")
		Clipboard := Clipboard
	send ^v
	Vim.State.SetMode("Vim_Normal")
Return

s::  ; *s*ubstitue
	send {bs}
	Vim.State.SetMode("Insert")
return

convert_to_lowercase:
u::
	selection := clip()
	StringLower, selection, selection
	clip(selection)
	Vim.State.SetMode("Vim_Normal")
Return

convert_to_uppercase:
+u::
	selection := clip()
	StringUpper, selection, selection
	clip(selection)
	Vim.State.SetMode("Vim_Normal")
Return

; https://www.autohotkey.com/board/topic/24431-convert-text-uppercase-lowercase-capitalized-or-inverted/
invert_case:
~::
	Vim.ReleaseKey("shift")
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

; !d::MsgBox % Vim.ParseLineBreaks(clip())  ; debugging

o::  ; move to other end of marked area; not perfect with line breaks
	selection := clip()
	if !clip()
		Return
	selection_len := StrLen(Vim.ParseLineBreaks(selection))
	send +{right}
	selection_right := clip()
	selection_right_len := StrLen(Vim.ParseLineBreaks(selection_right))
	send +{left}
	if (selection_len < selection_right_len)
	|| (selection_len == selection_right_len && StrLen(selection) < StrLen(selection_right)) {  ; moving point of selection is on the right
		send {right}
		SendInput % "{shift down}{left " selection_len "}{shift up}"
	} else if (selection_len > selection_right_len)
	|| (selection_len == selection_right_len && StrLen(selection) > StrLen(selection_right)) {
		send {left}
		SendInput % "{shift down}{right " selection_len "}{shift up}"
	}
return
