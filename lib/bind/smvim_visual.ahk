#if Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && Vim.SM.IsEditingHTML()
~^+i::Vim.State.SetMode("Vim_Normal")  ; ignore

.::  ; selected text becomes [...]
  clip("<span class=""Cloze"">[...]</span>",,, true)
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
  list := "h1||h2|h3|h4|h5|h6|b|i|u|strong|code|pre|em|cloze|clozed|extract|sub|sup|blockquote|ruby|hint|note|ignore|headers|refText|reference|highlight|searchHighlight|tableLabel|fuck_lexicon"
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
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (OriginalHTML) {
    if (Vim.HTML.ClipboardGet_HTML(data))
      RegExMatch(data, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", content)
  } else {
    content := Clipboard
    content := StrReplace(content, "<", "&lt;")
    content := StrReplace(content, ">", "&gt;")
  }
  WinActivate, ahk_class TElWind
  ; Classes
  if (Vim.SM.IsCssClass(tag)) {
    StartingTag := "<SPAN class=" . tag
    EndingTag := "SPAN>"
    tag := ""
  } else if (tag = "ruby") {
    WinClip.Restore(ClipData)
    InputBox, UserInput, Ruby tag annotation, Enter your annotations.`nAnnotations will appear above`, like Pinyin,, 272, 160
    if (ErrorLevel || !UserInput)
      return
    clip("<RUBY>" . content . "<RP>(</RP><RT>" . UserInput
       . "</RT><RP>)</RP></RUBY>",,, true)
    return
  } else {
    StartingTag := "<" 
    EndingTag := ">" 
  }
  clip(StartingTag . tag . ">" . content . "</" . tag . EndingTag,, true, true)
  WinClip.Restore(ClipData)
return

m::  ; highlight: *m*ark
  Vim.SM.PostMsg(815, true)  ; highlight
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
  KeyWait ctrl
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
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!z::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TElWind"))
^z::
  KeyWait ctrl
  send !z
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.WaitProcessing()
  if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
    return
  send !{left}
Return

~!t::
~!q::Vim.State.SetMode("Vim_Normal")

ClozeHinter:
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind") && Vim.SM.IsEditingText())
^!+z::
!+z::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TElWind"))
^+z::
+z::  ; cloze hinter
  if (ClozeHinterCtrlState && A_ThisLabel == "ClozeHinter") {  ; from cloze hinter label and ctrl is down
    CtrlState := 1
    ClozeHinterCtrlState := 0
  } else {
    CtrlState := InStr(A_ThisHotkey, "^")
  }
  KeyWait ctrl
  KeyWait shift
  InitText := Clip()
  if (!InitText)
    return
  inside := true
  if (IfContains(InitText, "more,less")) {
    InitText := "more/less"
  } else if (IfContains(InitText, "faster,slower")) {
    InitText := "faster/slower"
  } else if (IfContains(InitText, "fast,slow")) {
    InitText := "fast/slow"
  } else if (IfContains(InitText, "higher,lower")) {
    InitText := "higher/lower"
  } else if (IfContains(InitText, "high,low")) {
    InitText := "high/low"
  } else if (IfContains(InitText, "increased,decreased")) {
    InitText := "increased/decreased"
  } else if (IfContains(InitText, "increase,decrease")) {
    InitText := "increase/decrease"
  } else if (!InStr(InitText, "/")) {
    inside := false
  }
  gui, ClozeHinter:Add, Text,, &Hint:
  gui, ClozeHinter:Add, Edit, vHint w196, % InitText
  gui, ClozeHinter:Add, CheckBox, % "vInside " . (inside ? "checked" : ""), &Inside square brackets
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
ClozeNoBracket:
CapsLock & z::  ; delete [...]
  if (A_ThisLabel == "ClozeNoBracket" && ClozeNoBracketCtrlState) {
    CtrlState := 1
    ClozeNoBracketCtrlState := 0
  }
  KeyWait Capslock
  if (A_ThisHotkey != "CapsLock & z" && A_ThisLabel != "ClozeNoBracket" && !inside && hint && IfContains(hint, "/,／")) {
    MsgBox, 4,, You sure you don't want to make the cloze inside square brackets?
    IfMsgBox no
      inside := true
    WinWaitActive, ahk_class TElWind,, 0
  }
  send !z
  Vim.State.SetMode("Vim_Normal")
  if (A_ThisHotkey != "CapsLock & z" && A_ThisLabel != "ClozeNoBracket" && !hint)  ; entered nothing
    return
  ToolTip("Cloze processing...", true)
  SleepCalc := A_TickCount
  Vim.SM.WaitProcessing(5000)
  if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
    return
  send !{left}
  sleep % (A_TickCount - SleepCalc) / 3 * 2
  Vim.SM.WaitFileLoad(5000)  ; double insurance
  send q
  if (A_ThisHotkey != "CapsLock & z" && A_ThisLabel != "ClozeNoBracket" && inside) {
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
    if (A_ThisHotkey != "CapsLock & z" && A_ThisLabel != "ClozeNoBracket") {
      clip(StrReplace(clip("",, true), "[...]", "[" . cloze),, true)
    } else {
      clip(StrReplace(clip("",, true), " [...]"),, true)
    }
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
		send {enter}
    WinWaitActive, ahk_class TElWind,, 0
    if (!Vim.SM.IsEditingText()) {
      send q
      Vim.SM.WaitTextFocus()
    }
    if (A_ThisHotkey != "CapsLock & z" && A_ThisLabel != "ClozeNoBracket") {
      send {left}{right}  ; put the caret after the [ of [...]
      WinClip.Paste(cloze)  ; much more robust than clip()
      send {del 4}  ; delete ...]
    } else {
      send {bs 2}
    }
		if (WinExist("ahk_class TMyFindDlg")) ; clears search box window
			WinClose
  }
  if (!CtrlState) {  ; only goes back to topic if ctrl is up
    send !{right}  ; add a ctrl to keep editing the clozed item
  } else {  ; refresh if staying in the cloze item
    send !{home}
    Vim.SM.WaitFileLoad()
    send !{left}
  }
  Gosub RemoveToolTip
return