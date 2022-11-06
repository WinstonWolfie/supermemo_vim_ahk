#if Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && Vim.SM.IsEditingHTML()
~^+i::Vim.State.SetMode("Vim_Normal")  ; ignore

.::  ; selected text becomes [...]
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  clip("<span class=""Cloze"">[...]</span>",,, true)
  Vim.State.SetMode("Vim_Normal")
return

^h::  ; parse *h*tml
  send ^+1
~^+1::
  Vim.State.SetMode("Vim_Normal")
return

!a::  ; p*a*rse html
  Vim.State.SetMode("Vim_Normal")
  gui, HTMLTag:Add, Text,, &HTML tag:
  list := "h1||h2|h3|h4|h5|h6|b|i|u|strong|code|pre|em|clozed|cloze|extract|sub"
        . "|sup|blockquote|ruby|hint|note|ignore|headers|RefText|reference|highlight"
        . "|SearchHighlight|TableLabel|AntiMerge"
  gui, HTMLTag:Add, Combobox, vTag gAutoComplete, % list
  gui, HTMLTag:Add, CheckBox, vOriginalHTML, &On original HTML
  gui, HTMLTag:Add, Button, default, &Add
  KeyWait alt
  gui, HTMLTag:Show,, Add HTML Tag
Return

HTMLTagGuiEscape:
HTMLTagGuiClose:
  gui destroy
return

HTMLTagButtonAdd:
  gui submit
  gui destroy
  ClipSaved := ClipboardAll
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (ErrorLevel) {
    Clipboard := ClipSaved
    return
  }
  if (OriginalHTML) {
    Vim.HTML.ClipboardGet_HTML(data)
    RegExMatch(data, "s)<!--StartFragment ?-->\K.*(?=<!--EndFragment ?-->)", content)
  } else {
    content := Clipboard
    content := StrReplace(content, "<", "&lt;")
    content := StrReplace(content, ">", "&gt;")
  }
  WinActivate, ahk_class TElWind
  if (Vim.SM.IsCssClass(tag)) {
    StartingTag := "<SPAN class=" . tag, EndingTag := "SPAN>", tag := ""
  } else if (tag = "ruby") {
    Clipboard := ClipSaved
    InputBox, UserInput, Ruby tag annotation, Enter your annotations.`nAnnotations will appear above`, like Pinyin,, 272, 160
    if (ErrorLevel || !UserInput)
      return
    clip("<RUBY>" . content . "<RP>(</RP><RT>" . UserInput
       . "</RT><RP>)</RP></RUBY>",,, "sm")
    return
  } else {
    StartingTag := "<", EndingTag := ">"
  }
  clip(StartingTag . tag . ">" . content . "</" . tag . EndingTag,, false, "sm")
  Clipboard := ClipSaved
return

m::  ; highlight: *m*ark
  send {AppsKey}rh
  ; Vim.SM.PostMsg(815, true)  ; highlight
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
  Vim.SM.WaitExtractProcessing()
  sleep 20
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
  if (Vim.SM.WaitClozeProcessing() == -1)  ; warning on trying to cloze on items
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
    CtrlState := 1, ClozeHinterCtrlState := 0
  } else {
    CtrlState := InStr(A_ThisHotkey, "^")
  }
  KeyWait ctrl
  KeyWait shift
  if (!InitText := Clip())
    return
  CurrFocus := ControlGetFocus("ahk_class TElWind"), inside := true
  if (RegExMatch(InitText, "\b(more|less)\b")) {
    InitText := "more/less"
  } else if (RegExMatch(InitText, "\b(faster|slower)\b")) {
    InitText := "faster/slower"
  } else if (RegExMatch(InitText, "\b(fast|slow)\b")) {
    InitText := "fast/slow"
  } else if (RegExMatch(InitText, "\b(higher|lower)\b")) {
    InitText := "higher/lower"
  } else if (RegExMatch(InitText, "\b(high|low)\b")) {
    InitText := "high/low"
  } else if (RegExMatch(InitText, "\b(increased|decreased)\b")) {
    InitText := "increased/decreased"
  } else if (RegExMatch(InitText, "\b(increased|reduced)\b")) {
    InitText := "increased/reduced"
  } else if (RegExMatch(InitText, "\b(increases|decreases)\b")) {
    InitText := "increases/decreases"
  } else if (RegExMatch(InitText, "\b(increase|decrease)\b")) {
    InitText := "increase/decrease"
  } else if (RegExMatch(InitText, "\b(positive|negative)\b")) {
    InitText := "positive/negative"
  } else if (RegExMatch(InitText, "\b(acidic|alkaline)\b")) {
    InitText := "acidic/alkaline"
  } else if (RegExMatch(InitText, "\b(same|different)\b")) {
    InitText := "same/different"
  } else if (!InStr(InitText, "/")) {
    inside := false
  }
  gui, ClozeHinter:Add, Text,, &Hint:
  gui, ClozeHinter:Add, Edit, vHint w196, % InitText
  gui, ClozeHinter:Add, CheckBox, % "vInside " . (inside ? "checked" : ""), &Inside square brackets
  gui, ClozeHinter:Add, CheckBox, vFullWidthChars, &Use fullwidth characters
  gui, ClozeHinter:Add, CheckBox, % "vCtrlState " . (CtrlState ? "checked" : ""), &Stay in clozed item
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
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TElWind") && CtrlState := GetKeyState("ctrl"))
CapsLock & z::  ; delete [...]
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TElWind"))
CapsLock & z::  ; delete [...]
  ClozeNoBracket := (A_ThisLabel == "ClozeNoBracket" || A_ThisHotkey == "CapsLock & z")
  if (A_ThisLabel == "ClozeNoBracket" && ClozeNoBracketCtrlState) {
    CtrlState := 1, ClozeNoBracketCtrlState := 0
  }
  KeyWait Capslock
  if (!ClozeNoBracket && !inside && hint && IfContains(hint, "/,／")) {
    MsgBox, 4,, You sure you don't want to make the cloze inside square brackets?
    IfMsgBox no
      inside := true
    WinWaitActive, ahk_class TElWind
  }
  send !z
  Vim.State.SetMode("Vim_Normal")
  if (!ClozeNoBracket && !hint)  ; entered nothing
    return

  ToolTip("Cloze processing...", true)
  SleepCalc := A_TickCount
  if (Vim.SM.WaitClozeProcessing() == -1)  ; warning on trying to cloze on items
    return
  send !{left}
  sleep % (A_TickCount - SleepCalc) / 3 * 2
  Vim.SM.WaitFileLoad()  ; double insurance?
  send ^t
  if (!ClozeNoBracket && inside) {
    if (FullWidthChars) {
      hint := StrReplace(hint, "/", "／")
      cloze := "［" . hint . "］"
    } else {
      cloze := "[" . hint . "]"
    }
  } else {
    if (FullWidthChars) {
      cloze := "［...］（" . hint . "）"
    } else {
      cloze := "[...](" . hint . ")"
    }
  }
  Vim.SM.WaitTextFocus()
  if (Vim.SM.IsEditingPlainText()) {
    send ^a
    ClipSaved := ClipboardAll
    if (!ClozeNoBracket) {
      clip(StrReplace(copy(false), "[...]", cloze),, false)
    } else {
      clip(RegExReplace(copy(false), "\s?[...]"),, false)
    }
    Clipboard := ClipSaved
  } else if (Vim.SM.IsEditingHTML()) {
    if (!Vim.SM.HandleF3(1))
      return
    ControlSetText, TEdit1, [...], ahk_class TMyFindDlg
		send {enter}
		WinWaitNotActive, ahk_class TMyFindDlg ; faster than wait for element window to be active
    Vim.SM.ClearHighlight()
    Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
    if (!ClozeNoBracket) {
      ; Not reliable???
      ; send +{left}  ; so format is kept
      ; clip(cloze)
      ; sleep 20  ; insurance
      ; send {del}
      send % "{text}" . cloze
    } else {
      send {bs}
    }
		if (WinExist("ahk_class TMyFindDlg")) ; clears search box window
			WinClose
  }
  if (!CtrlState)  ; only goes back to topic if ctrl is up
    send !{right}  ; add a ctrl to keep editing the clozed item
  goto RemoveToolTip
return