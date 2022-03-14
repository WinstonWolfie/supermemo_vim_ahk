; Visual Char/Block/Line
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
v::Vim.State.SetMode("Vim_VisualFirst")
^v::
  if WinActive("ahk_class TElWind") {
	if IsSMEditingHTML() {
		send ^{down}^+{up}{left}^+{down}
		Vim.State.SetMode("Vim_VisualBlockFirst")
	} else {
		Send, {Home}+{Down}
		Vim.State.SetMode("Vim_VisualLineFirst")
	}
	Return
  } else if !WinActive("ahk_exe notepad++.exe") ; notepad++ requires alt down
	Send, ^b
  Vim.State.SetMode("Vim_VisualBlockFirst")
Return

+v::
  Vim.State.SetMode("Vim_VisualLineFirst")
  Send, {Home}+{Down}
Return

#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual"))
v::
	if Vim.State.IsCurrentVimMode("Vim_VisualChar") || Vim.State.IsCurrentVimMode("Vim_VisualFirst")
		Vim.State.SetNormal()
	else
		Vim.State.SetMode("Vim_VisualChar")
Return

^v::
	if Vim.State.StrIsInCurrentVimMode("VisualBlock") {
		Vim.State.SetNormal()
		Return
	} else if WinActive("ahk_class TElWind") {
		if IsSMEditingHTML() {
			send ^{down}^+{up}{left}^+{down}
			Vim.State.SetMode("Vim_VisualBlockFirst")
		} else {
			Send, {Home}+{Down}
			Vim.State.SetMode("Vim_VisualLineFirst")
		}
		Return
	} else if !WinActive("ahk_exe notepad++.exe") ; notepad++ requires alt down
		Send, ^b
	Vim.State.SetMode("Vim_VisualBlockFirst")
Return

+v::
  if Vim.State.StrIsInCurrentVimMode("VisualLine") {
	Vim.State.SetNormal()
	Return
  }
  Vim.State.SetMode("Vim_VisualLineFirst")
  Send, {Home}+{Down}
Return

; ydc
y::
  Clipboard :=
  Send, ^c
  Send, {Right}
  if WinActive("ahk_group VimCursorSameAfterSelect"){
    Send, {Left}
  }
  ClipWait, 1
  if(Vim.State.StrIsInCurrentVimMode("Line")){
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  }else{
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

d::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if(Vim.State.StrIsInCurrentVimMode("Line")){
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  }else{
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

x::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if(Vim.State.StrIsInCurrentVimMode("Line")){
    Vim.State.SetMode("Vim_Normal", 0, 0, 1)
  }else{
    Vim.State.SetMode("Vim_Normal", 0, 0, 0)
  }
Return

c::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if(Vim.State.StrIsInCurrentVimMode("Line")){
    Vim.State.SetMode("Insert", 0, 0, 1)
  }else{
    Vim.State.SetMode("Insert", 0, 0, 0)
  }
Return

*::
  bak := ClipboardAll
  Clipboard :=
  Send, ^c
  ClipWait, 1
  Send, ^f
  Send, ^v!f
  clipboard := bak
  Vim.State.SetMode("Vim_Normal")
Return

p::
	send ^v
	Vim.State.SetMode("Vim_Normal")
Return

s:: ; *s*ubstitue
	send {bs}
	Vim.State.SetMode("Insert")
return

o:: ; move to other end of marked area; not perfect with line breaks
	selection_len := StrLen(StrReplace(clip(), "`r"))
	send +{right}
	selection_right_len := StrLen(StrReplace(clip(), "`r"))
	send +{left}
	if (selection_len < selection_right_len) { ; moving point of selection is on the right
		send {right}
		SendInput % "{shift down}{left " selection_len "}{shift up}"
	} else {
		send {left}
		SendInput % "{shift down}{right " selection_len "}{shift up}"
	}
return