#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
.::  ; selected text becomes [...]
  KeyWait ctrl
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
  send {ShiftDown}
  Vim.SM.ClickTop()
  send {ShiftUp}
Return

+m::  ; move to middle of screen
  send {ShiftDown}
  Vim.SM.ClickMid()
  send {ShiftUp}
Return

+l::  ; move to bottom of screen
  send {ShiftDown}
  Vim.SM.ClickBottom()
  send {ShiftUp}
Return

ExtractStay:
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^!x::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TElWind"))
^q::  ; extract (*q*uote)
  KeyWait ctrl
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
    CtrlState := IfContains(A_ThisHotkey, "^")
  }
  KeyWait ctrl
  KeyWait shift
  if (!InitText := Copy())
    return
  CurrFocus := ControlGetFocus("ahk_class TElWind"), inside := true
  if (InitText ~= "^(more|less)$") {
    InitText := "more/less"
  } else if (InitText ~= "^(faster|slower)$") {
    InitText := "faster/slower"
  } else if (InitText ~= "^(fast|slow)$") {
    InitText := "fast/slow"
  } else if (InitText ~= "^(higher|lower)$") {
    InitText := "higher/lower"
  } else if (InitText ~= "^(high|low)$") {
    InitText := "high/low"
  } else if (InitText ~= "^(increased|decreased)$") {
    InitText := "increased/decreased"
  } else if (InitText ~= "^(increases|decreases)$") {
    InitText := "increases/decreases"
  } else if (InitText ~= "^(increase|decrease)$") {
    InitText := "increase/decrease"
  } else if (InitText ~= "^(reduced)$") {
    InitText := "increased/reduced"
  } else if (InitText ~= "^(reduces)$") {
    InitText := "increases/reduces"
  } else if (InitText ~= "^(reduce)$") {
    InitText := "increase/reduce"
  } else if (InitText ~= "^(positive|negative)$") {
    InitText := "positive/negative"
  } else if (InitText ~= "^(acidic|alkaline)$") {
    InitText := "acidic/alkaline"
  } else if (InitText ~= "^(same|different)$") {
    InitText := "same/different"
  } else if (InitText ~= "^(inside|outside)$") {
    InitText := "inside/outside"
  } else if (!IfContains(InitText, "/")) {
    inside := false
  }
  gui, ClozeHinter:Add, Text,, &Hint:
  gui, ClozeHinter:Add, Edit, vHint w196 r1 -WantReturn, % InitText
  gui, ClozeHinter:Add, CheckBox, % "vInside " . (inside ? "checked" : ""), &Inside square brackets
  gui, ClozeHinter:Add, CheckBox, vFullWidthParen, Use &fullwidth parentheses
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
  KeyWait alt
  gui submit
  gui destroy
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
  if (WinWaitTitleChange(TopicTitle, "ahk_class TElWind", 100)) {
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
  goto RemoveToolTip
return