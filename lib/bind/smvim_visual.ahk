#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
.::  ; selected text becomes [...]
  copy(false)
  if (Vim.SM.IsEditingHTML()) {
    clip("<span class=""Cloze"">[...]</span>",,, "sm")
  } else if (Vim.SM.IsEditingPlainText()) {
    clip("[...]")
  }
  Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingHTML())
~^+i::Vim.State.SetMode("Vim_Normal")  ; ignore

^h::  ; parse *h*tml
  send ^+1
~^+1::
  Vim.State.SetMode("Vim_Normal")
return

!a::  ; p*a*rse html
  Vim.State.SetMode("Vim_Normal")
  SetDefaultKeyboard(0x0409)  ; English-US
  Gui, HTMLTag:Add, Text,, &HTML tag:
  list := "h1||h2|h3|h4|h5|h6|b|i|u|strong|code|pre|em|clozed|cloze|extract|sub"
        . "|sup|blockquote|ruby|hint|note|ignore|headers|RefText|reference|highlight"
        . "|SearchHighlight|TableLabel|AntiMerge"
  Gui, HTMLTag:Add, Combobox, vTag gAutoComplete, % list
  Gui, HTMLTag:Add, CheckBox, vOriginalHTML, &On original HTML
  Gui, HTMLTag:Add, Button, default, &Add
  KeyWait alt
  Gui, HTMLTag:Show,, Add HTML Tag
Return

HTMLTagGuiEscape:
HTMLTagGuiClose:
  Gui destroy
return

HTMLTagButtonAdd:
  Gui submit
  Gui destroy
  ClipSaved := ClipboardAll
  WinActivate, ahk_class TElWind
  if (!copy(false))
    goto RestoreClipReturn
  if (OriginalHTML) {
    Vim.HTML.ClipboardGet_HTML(data)
    RegExMatch(data, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", content)
  } else {
    content := StrReplace(Clipboard, "<", "&lt;"), content := StrReplace(content, ">", "&gt;")
  }
  StartingTag := "<", EndingTag := ">"
  if (Vim.SM.IsCssClass(tag)) {
    StartingTag := "<SPAN class=" . tag, EndingTag := "SPAN>", tag := ""
  } else if (tag = "ruby") {
    Clipboard := ClipSaved
    InputBox, UserInput, Ruby tag annotation, Enter your annotations.`nAnnotations will appear above your selection`, like Pinyin,, 200, 180
    if (ErrorLevel || !UserInput)
      return
    clip("<RUBY>" . content . "<RP>(</RP><RT>" . UserInput
       . "</RT><RP>)</RP></RUBY>",,, "sm")
    return
  }
  clip(StartingTag . tag . ">" . content . "</" . tag . EndingTag,, false, "sm")
  Clipboard := ClipSaved
return

m::  ; highlight: *m*ark
  send {AppsKey}rh
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
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!x::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TElWind"))
^q::  ; extract (*q*uote)
  send {Blind}{CtrlUp}
  send !x
  Vim.SM.WaitExtractProcessing()
  send !{left}
  Vim.State.SetMode("Vim_Normal")
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
  send {Blind}{CtrlUp}
  send !z
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.WaitClozeProcessing() != -1)  ; warning on trying to cloze on items
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
  if (ClozeHinterCtrlState && (A_ThisLabel == "ClozeHinter")) {  ; from cloze hinter label and ctrl is down
    CtrlState := 1, ClozeHinterCtrlState := 0
  } else {
    CtrlState := IfContains(A_ThisHotkey, "^")
  }
  Send {Blind}{CtrlUp}{Shift Up}
  if (!InitText := Copy())
    return
  CurrFocus := ControlGetFocus("ahk_class TElWind"), inside := true
  if (InitText ~= "i)^(more|less)$") {
    InitText := "more/less"
  } else if (InitText ~= "i)^(faster|slower)$") {
    InitText := "faster/slower"
  } else if (InitText ~= "i)^(fast|slow)$") {
    InitText := "fast/slow"
  } else if (InitText ~= "i)^(higher|lower)$") {
    InitText := "higher/lower"
  } else if (InitText ~= "i)^(high|low)$") {
    InitText := "high/low"
  } else if (InitText ~= "i)^(increased|decreased)$") {
    InitText := "increased/decreased"
  } else if (InitText ~= "i)^(increases|decreases)$") {
    InitText := "increases/decreases"
  } else if (InitText ~= "i)^(increase|decrease)$") {
    InitText := "increase/decrease"
  } else if (InitText ~= "i)^(reduced)$") {
    InitText := "increased/reduced"
  } else if (InitText ~= "i)^(reduces)$") {
    InitText := "increases/reduces"
  } else if (InitText ~= "i)^(reduce)$") {
    InitText := "increase/reduce"
  } else if (InitText ~= "i)^(positive|negative)$") {
    InitText := "positive/negative"
  } else if (InitText ~= "i)^(acidic|alkaline)$") {
    InitText := "acidic/alkaline"
  } else if (InitText ~= "i)^(same|different)$") {
    InitText := "same/different"
  } else if (InitText ~= "i)^(inside|outside)$") {
    InitText := "inside/outside"
  } else if (!IfContains(InitText, "/")) {
    inside := false
  }
  Gui, ClozeHinter:Add, Text,, &Hint:
  Gui, ClozeHinter:Add, Edit, vHint w196 r1 -WantReturn, % InitText
  Gui, ClozeHinter:Add, CheckBox, % "vInside " . (inside ? "checked" : ""), &Inside square brackets
  Gui, ClozeHinter:Add, CheckBox, vFullWidthParen, Use &fullwidth parentheses
  Gui, ClozeHinter:Add, CheckBox, % "vCtrlState " . (CtrlState ? "checked" : ""), &Stay in clozed item
  Gui, ClozeHinter:Add, Button, default, Clo&ze
  Gui, ClozeHinter:Show,, Cloze Hinter
Return

ClozeHinterGuiEscape:
ClozeHinterGuiClose:
  Gui destroy
  Vim.State.SetMode("Vim_Normal")
return

ClozeHinterButtonCloze:
  KeyWait alt
  Gui submit
  Gui destroy
  WinActivate, ahk_class TElWind
ClozeNoBracket:
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TElWind") && (CtrlState := GetKeyState("ctrl")))
CapsLock & z::  ; delete [...]
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TElWind"))
CapsLock & z::  ; delete [...]
  ClozeNoBracket := IfIn(A_ThisLabel, "ClozeNoBracket,CapsLock & z"), TopicTitle := WinGetTitle("ahk_class TElWind")
  if ((A_ThisLabel == "ClozeNoBracket") && ClozeNoBracketCtrlState)
    CtrlState := 1, ClozeNoBracketCtrlState := 0
  KeyWait Capslock
  if (!ClozeNoBracket && !inside && hint && IfContains(hint, "/")) {
    MsgBox, 4,, Your hint has a slash. Press yes to make it inside square brackets.
    IfMsgBox yes
      inside := true
    WinWaitActive, ahk_class TElWind
  }
  send !z
  Vim.State.SetMode("Vim_Normal")
  if (!ClozeNoBracket && !hint)  ; entered nothing
    return

  ToolTip("Cloze processing...", true)
  if (Vim.SM.WaitClozeProcessing() == -1)  ; warning on trying to cloze on items
    return
  send !{left}
  Vim.SM.WaitFileLoad()
  if (WinWaitTitleChange(TopicTitle, "ahk_class TElWind", 200)) {
    if (!Vim.SM.SpamQ(, 1500))
      return
  } else {
    Vim.SM.EditFirstQuestion()
    Vim.SM.WaitTextFocus()
  }
  if (!ClozeNoBracket && inside) {
    cloze := "[" . hint . "]"
  } else {
    if (FullWidthParen) {
      cloze := "[...]（" . hint . "）"
    } else {
      cloze := "[...](" . hint . ")"
    }
  }
  if (Vim.SM.IsEditingPlainText()) {
    send ^a
    ClipSaved := ClipboardAll
    if (ClozeNoBracket) {
      clip(RegExReplace(copy(false), "\s?[...]"),, false)
    } else {
      clip(StrReplace(copy(false), "[...]", cloze),, false)
    }
    Clipboard := ClipSaved
  } else if (Vim.SM.IsEditingHTML()) {
    if (!Vim.SM.HandleF3(1))
      return
    ControlSetText, TEdit1, [...], ahk_class TMyFindDlg
    send {enter}
    WinWaitNotActive, ahk_class TMyFindDlg  ; faster than wait for element window to be active
    if (!Vim.SM.HandleF3(2))
      return
    WinWaitActive, ahk_class TElWind
    if (copy() = " [...")  ; a bug in SM
      send {left}{right}+{right 5}
    send % ClozeNoBracket ? "{bs}" : "{text}" . cloze
		if (WinExist("ahk_class TMyFindDlg")) ; clears search box window
			WinClose
  }
  if (!CtrlState)  ; only goes back to topic if ctrl is up
    send !{right}  ; add a ctrl to keep editing the clozed item
  RemoveToolTip()
return