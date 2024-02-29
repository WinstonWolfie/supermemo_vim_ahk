#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
.::  ; selected text becomes [...]
  if (!Vim.State.Leader)
    Send ^c
  if (Vim.SM.IsEditingHTML()) {
    Send {text}<span class="Cloze">[...]</span>
    Send +{Left 32}^+1
  } else if (Vim.SM.IsEditingPlainText()) {
    Send {text}[...]
  }
  Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingHTML())
~^+i::Vim.State.SetMode("Vim_Normal")  ; ignore

^h::  ; parse *h*tml
  Send ^+1
~^+1::Vim.State.SetMode("Vim_Normal")

SMParseHTMLGUI:
!a::  ; p*a*rse html
  GAltA := (A_ThisLabel == "SMParseHTMLGUI"), Vim.State.SetMode("Vim_Normal")
  SetDefaultKeyboard(0x0409)  ; English-US
  Gui, HTMLTag:Add, Text,, &HTML tag:
  RegExMatch(Vim.SM.CssClass, "hint.*$", v)
  list := "h1||h2|h3|h4|h5|h6|b|i|u|strong|code|pre|em|clozed|cloze|extract|sub"
        . "|sup|blockquote|ruby|small|" . v
  Gui, HTMLTag:Add, Combobox, vTag gAutoComplete, % list
  Gui, HTMLTag:Add, CheckBox, vOriginalHTML, &On original HTML
  Gui, HTMLTag:Add, CheckBox, vCopyText, &Copy the text
  Gui, HTMLTag:Add, CheckBox, vClass, C&lass
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
  if (GAltA) {
    GAltA := false, Vim.State.SetMode("SMVim_GAltA", 0, -1, 0,,, -1)
    Vim.Move.SMLastGAltATag := Tag
    return
  }

SMParseHTML:
  if (A_ThisLabel == "SMParseHTML")
    Tag := Vim.Move.SMLastGAltATag
  WinActivate, ahk_class TElWind
  KeyWait Alt
  if (CopyText)
    Copy(false)
  ClipSaved := ClipboardAll
  if (!Copy(false)) {
    Clipboard := ClipSaved
    return
  }
  if (OriginalHTML) {
    Content := GetClipHTMLBody()
  } else {
    Content := StrReplace(Clipboard, "<", "&lt;")
    Content := StrReplace(Content, ">", "&gt;")
  }
  StartingTag := "<", EndingTag := ">"
  if (Class || Vim.SM.IsCssClass(Tag)) {
    StartingTag := "<SPAN class=" . Tag, EndingTag := "SPAN>", Tag := ""
  } else if (Tag = "ruby") {
    Clipboard := ClipSaved
    InputBox, UserInput, Ruby tag annotation, Annotations:`n(annotations will appear above your selection`, like Pinyin),, 200, 180
    if (ErrorLevel || !UserInput)
      return
    Clip("<RUBY>" . Content . "<RP>(</RP><RT>" . UserInput
       . "</RT><RP>)</RP></RUBY>",,, "sm")
    return
  }
  Clip(StartingTag . Tag . ">" . Content . "</" . Tag . EndingTag,, false, "sm")
  Clipboard := ClipSaved
return

m::  ; highlight: *m*ark
  Send {AppsKey}rh
  Vim.State.SetMode("Vim_Normal")
return

q::  ; extract (*q*uote)
  Send !x
  Vim.State.SetMode("Vim_Normal")
return

+h::  ; move to top of screen
  Send {Shift Down}
  Vim.SM.ClickTop()
  Send {Shift Up}
Return

+m::  ; move to middle of screen
  Send {Shift Down}
  Vim.SM.ClickMid()
  Send {Shift Up}
Return

+l::  ; move to bottom of screen
  Send {Shift Down}
  Vim.SM.ClickBottom()
  Send {Shift Up}
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingPlainText())
m::Send % "{text}*" . Copy() . "*"

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWind())
b::Vim.SM.OpenBrowser(), Vim.State.SetMode("Vim_Normal")

ExtractStay:
#if (Vim.IsVimGroup() && Vim.SM.IsEditingText())
^!x::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
^q::  ; extract (*q*uote)
  Send !x
  Vim.SM.WaitExtractProcessing()
  Vim.SM.GoBack(), Vim.State.SetMode("Vim_Normal")
return

+q::  ; extract with priority
  Send !+x
  Vim.State.SetMode("Vim_Normal")
return

z::Vim.SM.Cloze(), Vim.State.SetMode("Vim_Normal")

SMClozeStay:
#if (Vim.IsVimGroup() && Vim.SM.IsEditingText())
^!z::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
^z::
  Vim.SM.Cloze(), Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.WaitClozeProcessing() != -1)  ; warning on trying to cloze on items
    Vim.SM.GoBack()
Return

~!t::
~!q::Vim.State.SetMode("Vim_Normal")

SMClozeHinter:
#if (Vim.IsVimGroup() && Vim.SM.IsEditingText())
^!+z::
!+z::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
^+z::
+z::  ; cloze hinter
  if (ClozeHinterCtrlState && (A_ThisLabel == "SMClozeHinter")) {  ; from cloze hinter label and ctrl is pressed
    CtrlState := 1, ClozeHintertrlState := 0
  } else {
    CtrlState := IfContains(A_ThisLabel, "^")
  }
  InitText := ((A_ThisLabel == "SMClozeHinter") && InitText) ? InitText : Copy()
  if (!InitText)
    return
  CurrFocus := ControlGetFocus("ahk_class TElWind"), Inside := true
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
  } else if (InitText = "reduced") {
    InitText := "increased/reduced"
  } else if (InitText = "reduces") {
    InitText := "increases/reduces"
  } else if (InitText = "reduce") {
    InitText := "increase/reduce"
  } else if (InitText ~= "i)^(positive|negative)$") {
    InitText := "positive/negative"
  } else if (InitText ~= "i)^(acid|alkaloid)$") {
    InitText := "acid/alkaloid"
  } else if (InitText ~= "i)^(acidic|alkaline)$") {
    InitText := "acidic/alkaline"
  } else if (InitText ~= "i)^(same|different)$") {
    InitText := "same/different"
  } else if (InitText ~= "i)^(inside|outside)$") {
    InitText := "inside/outside"
  } else if (InitText ~= "i)^(monetary|fiscal)$") {
    InitText := "monetary/fiscal"
  } else if (InitText ~= "i)^(activator|inhibitor)$") {
    InitText := "activator/inhibitor"
  } else if (InitText = "elevate") {
    InitText := "elevate/lower"
  } else if (InitText ~= "i)^(elevates|lowers)$") {
    InitText := "elevates/lowers"
  } else if (InitText ~= "i)^(elevated|lowered)$") {
    InitText := "elevated/lowered"
  } else if (InitText = "raise") {
    InitText := "raise/lower"
  } else if (InitText = "raises") {
    InitText := "raises/lowers"
  } else if (InitText = "raised") {
    InitText := "raised/lowered"
  } else if (InitText ~= "i)^(activate|inhibit)$") {
    InitText := "activate/inhibit"
  } else if (InitText ~= "i)^(activates|inhibits)$") {
    InitText := "activates/inhibits"
  } else if (InitText ~= "i)^(greater|smaller)$") {
    InitText := "greater/smaller"
  } else if (InitText ~= "i)^(male|female)$") {
    InitText := "male/female"
  } else {
    Inside := false
  }
  Gui, SMClozeHinter:Add, Text,, &Hint:
  Gui, SMClozeHinter:Add, Edit, vHint w196 r1 -WantReturn, % InitText
  Gui, SMClozeHinter:Add, CheckBox, % "vInside " . (Inside ? "checked" : ""), &Inside square brackets
  Gui, SMClozeHinter:Add, CheckBox, vFullWidthParentheses, Use &fullwidth parentheses
  Gui, SMClozeHinter:Add, CheckBox, % "vCtrlState " . (CtrlState ? "checked" : ""), &Stay in clozed item
  Gui, SMClozeHinter:Add, CheckBox, vDone, &Done!
  Gui, SMClozeHinter:Add, Button, default, Clo&ze
  Gui, SMClozeHinter:Show,, Cloze Hinter
Return

SMClozeHinterGuiEscape:
SMClozeHinterGuiClose:
  Gui, Destroy
  Vim.State.SetMode("Vim_Normal")
return

SMClozeHinterButtonCloze:
  Gui, Submit
  Gui, Destroy
  WinActivate, ahk_class TElWind

SMClozeNoBracket:
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && (CtrlState := GetKeyState("ctrl")) && Vim.SM.IsEditingText())
CapsLock & z::  ; delete [...]
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
CapsLock & z::  ; delete [...]
  ClozeNoBracket := IfIn(A_ThisLabel, "SMClozeNoBracket,CapsLock & z")
  TopicTitle := WinGetTitle("ahk_class TElWind")
  if ((A_ThisLabel == "SMClozeNoBracket") && ClozeNoBracketCtrlState)
    CtrlState := 1, ClozeNoBracketCtrlState := 0
  if (!ClozeNoBracket && !Inside && Hint && IfContains(Hint, "/")) {
    Inside := (MsgBox(3,, "Your hint has a slash. Press yes to make it inside square brackets.") = "Yes")
    WinWaitActive, ahk_class TElWind
  }
  KeyWait Capslock
  KeyWait Alt
  KeyWait Enter
  Vim.SM.Cloze(), Vim.State.SetMode("Vim_Normal")
  if (!ClozeNoBracket && !Hint && !CtrlState)  ; entered nothing
    return

  Vim.State.SetToolTip("Cloze processing...")
  if (Vim.SM.WaitClozeProcessing() == -1)  ; warning on trying to cloze on items
    return
  if (Done) {
    Send ^+{Enter}
    WinWaitNotActive, ahk_class TElWind  ; "Do you want to remove all element contents from the collection?"
    Send {Enter}
    WinWaitNotActive, ahk_class TElWind  ; wait for "Delete element?"
    Send {Enter}
    CtrlState := true
  }
  Vim.SM.GoBack()
  if (!ClozeNoBracket && !Hint && CtrlState)  ; entered nothing
    return
  WinWaitTitleChange(TopicTitle, "ahk_class TElWind", 500)
  Vim.SM.WaitFileLoad()
  if (!Vim.SM.SpamQ(, 10000))
    return

  if (!ClozeNoBracket && Inside) {
    Cloze := "[" . Hint . "]"
  } else {
    if (FullWidthParentheses) {
      Cloze := "[...]（" . Hint . "）"
    } else {
      Cloze := "[...](" . Hint . ")"
    }
  }

  loop {  ; sometimes the question is not the first component
    if (Vim.SM.IsEditingPlainText()) {
      Send ^a
      ClipSaved := ClipboardAll
      if (ClozeNoBracket) {
        Clip(RegExReplace(Copy(false), "\s?\[\.\.\.\]"),, false)
      } else {
        Clip(StrReplace(Copy(false), "[...]", Cloze),, false)
      }
      Clipboard := ClipSaved
      Break
    } else if (Vim.SM.IsEditingHTML()) {
      if (HTML := FileRead(HTMLPath := Vim.SM.LoopForFilePath())) {
        Vim.SM.EmptyHTMLComp()
        WinWaitActive, ahk_class TElWind
        Send ^{Home}
        if (ClozeNoBracket) {
          HTML := RegExReplace(HTML, "\s?<SPAN class=cloze>\[\.\.\.\]<\/SPAN>")
        } else {
          HTML := StrReplace(HTML, "<SPAN class=cloze>[...]</SPAN>"
                                 , "<SPAN class=cloze>" . Cloze . "</SPAN>")
        }
        Clip(HTML,,, "sm")
        Break
      } else {
        Send ^t
      }
    }
  }

  Send % CtrlState ? "{Esc}" : "!{Right}"
  WinWaitActive, ahk_class TChoicesDlg,, 0
  if (!ErrorLevel)
    WinClose
return
