#if Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && Vim.SM.IsEditingHTML()
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
  gui, HTMLTag:Add, Text,, &HTML tag:
  list := "H1||H2|H3|H4|H5|H6|B|I|U|STRONG|CODE|PRE|EM|cloze|clozed|extract|SUB|SUP|BLOCKQUOTE|RUBY"
  gui, HTMLTag:Add, Combobox, vTag gAutoComplete, % list
  gui, HTMLTag:Add, CheckBox, vOriginalHTML, &On original HTML
  gui, HTMLTag:Add, Button, default, &Add
  gui, HTMLTag:Show,, Add HTML Tag
Return

HTMLTagGuiEscape:
HTMLTagGuiClose:
  gui destroy
return

HTMLTagButtonAdd:
  gui submit
  gui destroy
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (OriginalHTML) {
    if (Vim.HTML.ClipboardGet_HTML(data))
      RegExMatch(data, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", content)
  } else {
    content := clipboard
  }
  WinActivate, ahk_class TElWind
  if (tag == "cloze" || tag == "extract" || tag == "clozed") {
    StartingTag := "<SPAN class=" . tag
    EndingTag := "SPAN>"
    tag := ""
  } else if (tag = "ruby") {
    InputBox, UserInput, Ruby tag annotation, Enter your annotations.`nAnnotations will appear above`, like Pinyin,, 272, 144
    if (ErrorLevel || !UserInput)
      return
    clip("<RUBY>" . content . "<RP>(</RP><RT>" . UserInput
       . "</RT><RP>)</RP></RUBY>", true, true)
    send ^+1
    WinClip.Restore(ClipData)
    return
  } else {
    StartingTag := "<" 
    EndingTag := ">" 
  }
  clip(StartingTag . tag . ">" . content . "</" . tag . EndingTag, true, true)
  send ^+1
  WinClip.Restore(ClipData)
return

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
  Vim.SM.ClickBottom()
  send {shift up}
Return

ExtractStay:
#if Vim.IsVimGroup() and WinActive("ahk_class TElWind")
^!x::
#if Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
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
#if Vim.IsVimGroup() and WinActive("ahk_class TElWind")
^!z::
#if Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
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
#if Vim.IsVimGroup() && WinActive("ahk_class TElWind")
^!+z::
!+z::
#if Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
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
  gui, ClozeHinter:Add, Text,, &Hint:
  gui, ClozeHinter:Add, Edit, vHint w196, % InitialText
  gui, ClozeHinter:Add, CheckBox, vInside, &Inside square brackets
  gui, ClozeHinter:Add, CheckBox, vFullWidthChars, &Use fullwidth characters
  gui, ClozeHinter:Add, Button, default, Clo&ze
  gui, ClozeHinter:Show,, Cloze Hinter
Return

ClozeHinterGuiEscape:
ClozeHinterGuiClose:
  gui destroy
  Vim.State.SetMode("Vim_Normal")
return

ClozeHinterButtonCloze:
  gui submit
  gui destroy
  WinActivate, ahk_class TElWind
  send !z
  Vim.State.SetMode("Vim_Normal")
  if (!hint)  ; entered nothing
    return
  ToolTip("Cloze hinting...", true)
  SleepCalc := A_TickCount
  Vim.SM.WaitProcessing()
  if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
    return
  send !{left}
  sleep % (A_TickCount - SleepCalc) / 3 * 2
  send q
  if (Inside) {
    if (FullWidthChars)
      hint := StrReplace(hint, "/", "／")
    cloze := hint . "]"
  } else {
    if (FullWidthChars) {
      cloze := "...]（" . hint . "）"
    } else {
      cloze := "...](" . hint . ")"
    }
  }
  Vim.SM.WaitTextFocus()
  if (Vim.SM.IsEditingPlainText()) {  ; editing plain text
    send ^a
    WinClip.Snap(ClipData)
    clip(StrReplace(clip("",, true), "[...]", "[" . cloze),, true)
    WinClip.Restore(ClipData)
  } else if (Vim.SM.IsEditingHTML()) {
    send {f3}
    WinWaitActive, ahk_class TMyFindDlg,, 0
    if (ErrorLevel) {
      send {esc}^{enter}  ; open commander
      send {text}h  ; Highlight: Clear
      send {enter}{f3}
      WinWaitActive, ahk_class TMyFindDlg,, 0
      if (ErrorLevel)
        return
    }
    ControlSetText, TEdit1, [...]
		send {enter}
		WinWaitNotActive, ahk_class TMyFindDlg,, 0 ; faster than wait for element window to be active
		send ^{enter}
		WinWaitActive, ahk_class TCommanderDlg,, 0
    ControlSetText, TEdit2, h
		send {enter}q{left}{right}  ; put the caret after the [ of [...]
		WinClip.Paste(cloze)  ; works slightly better than clip()
		send {del 4}  ; delete ...]
		if (WinExist("ahk_class TMyFindDlg")) ; clears search box window
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