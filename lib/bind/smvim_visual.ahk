#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && Vim.SM.IsEditingHTML()
~^+i::Vim.State.SetMode("Vim_Normal")  ; ignore

.::  ; selected text becomes [...]
  Clip("<span class=""Cloze"">[...]</span>", true)
  send ^+1
  Vim.State.SetMode("Vim_Normal")
return

a::  ; p*a*rse html
^+1::
  send ^+1
  Vim.State.SetMode("Vim_Normal")
return

!a::  ; parse ht*m*l
  KeyWait alt
  Vim.State.SetMode("Vim_Normal")
  Gui, HTMLTag:Add, Text,, &HTML tag:
  list := "H1||H2|H3|H4|H5|H6|B|I|U|STRONG|CODE|PRE|EM|cloze|clozed|extract|SUB|SUP|BLOCKQUOTE"
  Gui, HTMLTag:Add, Combobox, vTag gAutoComplete, % list
  Gui, HTMLTag:Add, Button, default, &Add
  Gui, HTMLTag:Show,, Add HTML Tag
Return

HTMLTagGuiEscape:
HTMLTagGuiClose:
  Gui, Destroy
return

HTMLTagButtonAdd:
  Gui, Submit
  Gui, Destroy
  WinClip.Snap(ClipData)
  WinActivate, ahk_class TElWind
  if (tag == "cloze" || tag == "extract" || tag == "clozed") {
    StartingTag := "<SPAN class=" . tag
    EndingTag := "</SPAN>"
    tag := ""
  } else {
    StartingTag := "<" 
    EndingTag := ">" 
  }
  clip(StartingTag . tag . ">" . clip("",, true) . "</" . tag . EndingTag, true, true)
  send ^+1
  WinClip.Restore(ClipData)
Return

m::  ; highlight: *m*ark
  send {AppsKey}rh  ; highlight
  Vim.State.SetMode("Vim_Normal")
return

q::  ; extract (*q*uote)
  send !x
  Vim.State.SetMode("Vim_Normal")
return

+h::  ; move to top of screen
  send {shift down}
  Vim.SM.ClickTop()
  send {shift up}
Return

+m::  ; move to middle of screen
  send {shift down}
  Vim.SM.ClickMid()
  send {shift up}
Return

+l::  ; move to bottom of screen
  send {shift down}
  Vim.SM.ClickButtom()
  send {shift up}
Return

ExtractStay:
#If Vim.IsVimGroup() and WinActive("ahk_class TElWind")
^!x::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
^q::  ; extract (*q*uote)
  ReleaseKey("ctrl")
  send !x
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.WaitProcessing()
  send !{left}
return

+q::  ; extract with priority
  send !+x
  Vim.State.SetMode("Vim_Normal")
return

z::  ; clo*z*e
  send !z
  Vim.State.SetMode("Vim_Normal")
return

ClozeStay:
#If Vim.IsVimGroup() and WinActive("ahk_class TElWind")
^!z::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
^z::
  ReleaseKey("ctrl")
  send !z
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.WaitProcessing()
  if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
    Return
  send !{left}
Return

~!t::
~!q::
  Vim.State.SetMode("Vim_Normal")
Return

ClozeHinter:
#If Vim.IsVimGroup() && WinActive("ahk_class TElWind")
^!+z::
!+z::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
^+z::
+z::  ; cloze hinter
  if (ClozeHinterCtrlState && A_ThisLabel == "ClozeHinter") {  ; from cloze hinter label and ctrl is down
    CtrlState := 1
    ClozeHinterCtrlState := 0
  } else {
    CtrlState := InStr(A_ThisHotkey, "^")
  }
  ReleaseKey("ctrl")
  ReleaseKey("shift")
  InitialText := Clip()
  Gui, ClozeHinter:Add, Text,, &Hint:
  Gui, ClozeHinter:Add, Edit, vHint w196, % InitialText
  Gui, ClozeHinter:Add, CheckBox, vInside, &Inside square brackets
  Gui, ClozeHinter:Add, Button, default, Clo&ze
  Gui, ClozeHinter:Show,, Cloze Hinter
Return

ClozeHinterGuiEscape:
ClozeHinterGuiClose:
  Gui, Destroy
  Vim.State.SetMode("Vim_Normal")
return

ClozeHinterButtonCloze:
  Gui, Submit
  Gui, Destroy
  WinActivate, ahk_class TElWind
  send !z
  Vim.State.SetMode("Vim_Normal")
  if (!hint)  ; entered nothing
    return
  Vim.ToolTip("Cloze hinting...", true)
  sleep_calculation := A_TickCount
  Vim.SM.WaitProcessing()
  if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
    Return
  send !{left}
  sleep % (A_TickCount - sleep_calculation) / 3 * 2
  send q
  if (Inside) {
    cloze := hint . "]"
  } else {
    cloze := "...](" . hint . ")"
  }
  Vim.SM.WaitTextFocus()
  if (Vim.SM.IsEditingPlainText()) {  ; editing plain text
    send ^a
    clip(StrReplace(clip(), "[...]", "[" . cloze))
  } else if (Vim.SM.IsEditingHTML()) {
    send {f3}
    WinWaitActive, ahk_class TMyFindDlg,, 0
    if (ErrorLevel) {
      send {esc}^{enter}h{enter}{f3}
      WinWaitActive, ahk_class TMyFindDlg,, 0
      if (ErrorLevel)
        Return
    }
		SetDefaultKeyboard(0x0409)  ; english-US	
		SendInput {raw}[...]
		send {enter}
		WinWaitNotActive, ahk_class TMyFindDlg,, 0 ; faster than wait for element window to be active
		send ^{enter}
		WinWaitActive, ahk_class TCommanderDlg,, 0
		if ErrorLevel
			return
		send h{enter}q{left}{right} ; put the caret after the [ of [...]
		clip(cloze)
		SendInput {del 4} ; delete ...] ; somehow, here send wouldn't be working well in slow computers
		if WinExist("ahk_class TMyFindDlg") ; clears search box window
			WinClose
  }
  if (!CtrlState) {  ; only goes back to topic if ctrl is up
    send !{right}  ; add a ctrl to keep editing the clozed item
  } else {  ; refresh if staying in the cloze item
    send !{home}
    sleep 100
    send !{left}
  }
  Gosub RemoveToolTip
return