#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
.::  ; selected text becomes [...]
  send ^c
  if (Vim.SM.IsEditingHTML()) {
    send {text}<span class="Cloze">[...]</span>
    send +{left 32}^+1
  } else if (Vim.SM.IsEditingPlainText()) {
    send {text}[...]
  }
  Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingHTML())
~^+i::Vim.State.SetMode("Vim_Normal")  ; ignore

^h::  ; parse *h*tml
  send ^+1
~^+1::Vim.State.SetMode("Vim_Normal")

SMParseHTMLGUI:
!a::  ; p*a*rse html
  GAltA := (A_ThisLabel == "SMParseHTMLGUI"), Vim.State.SetMode("Vim_Normal")
  SetDefaultKeyboard(0x0409)  ; English-US
  Gui, HTMLTag:Add, Text,, &HTML tag:
  RegExMatch(Vim.SM.CssClass, "(hint.*$)", v)
  list := "h1||h2|h3|h4|h5|h6|b|i|u|strong|code|pre|em|clozed|cloze|extract|sub"
        . "|sup|blockquote|ruby|small|" . v1
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
    Vim.Move.SMLastGAltATag := tag
    return
  }

SMParseHTML:
  if (A_ThisLabel == "SMParseHTML")
    tag := Vim.Move.SMLastGAltATag
  WinActivate, ahk_class TElWind
  KeyWait Alt
  if (CopyText)
    Copy(false)
  ClipSaved := ClipboardAll
  if (!Copy(false))
    Goto RestoreClipReturn
  if (OriginalHTML) {
    Vim.HTML.ClipboardGet_HTML(data)
    RegExMatch(data, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", content)
  } else {
    content := StrReplace(Clipboard, "<", "&lt;")
    content := StrReplace(content, ">", "&gt;")
  }
  StartingTag := "<", EndingTag := ">"
  if (Class || Vim.SM.IsCssClass(tag)) {
    StartingTag := "<SPAN class=" . tag, EndingTag := "SPAN>", tag := ""
  } else if (tag = "ruby") {
    Clipboard := ClipSaved
    InputBox, UserInput, Ruby tag annotation, Annotations:`n(annotations will appear above your selection`, like Pinyin),, 200, 180
    if (ErrorLevel || !UserInput)
      return
    Clip("<RUBY>" . content . "<RP>(</RP><RT>" . UserInput
       . "</RT><RP>)</RP></RUBY>",,, "sm")
    return
  }
  Clip(StartingTag . tag . ">" . content . "</" . tag . EndingTag,, false, "sm")
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
  send {Shift Down}
  Vim.SM.ClickTop()
  send {Shift Up}
Return

+m::  ; move to middle of screen
  send {Shift Down}
  Vim.SM.ClickMid()
  send {Shift Up}
Return

+l::  ; move to bottom of screen
  send {Shift Down}
  Vim.SM.ClickBottom()
  send {Shift Up}
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingPlainText())
m::send % "{text}*" . Copy() . "*"

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())
b::
  Vim.SM.OpenBrowser()
  Vim.State.SetMode("Vim_Normal")
return

ExtractStay:
#if (Vim.IsVimGroup() && Vim.SM.IsEditingText())
^!x::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
^q::  ; extract (*q*uote)
  send !x
  Vim.SM.WaitExtractProcessing()
  Vim.SM.GoBack(), Vim.State.SetMode("Vim_Normal")
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
#if (Vim.IsVimGroup() && Vim.SM.IsEditingText())
^!z::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
^z::
  send !z
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.WaitClozeProcessing() != -1)  ; warning on trying to cloze on items
    Vim.SM.GoBack()
Return

~!t::
~!q::Vim.State.SetMode("Vim_Normal")

ClozeHinter:
#if (Vim.IsVimGroup() && Vim.SM.IsEditingText())
^!+z::
!+z::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
^+z::
+z::  ; cloze hinter
  if (ClozeHinterCtrlState && (A_ThisLabel == "ClozeHinter")) {  ; from cloze hinter label and ctrl is pressed
    CtrlState := 1, ClozeHinterCtrlState := 0
  } else {
    CtrlState := IfContains(A_ThisLabel, "^")
  }
  InitText := ((A_ThisLabel == "ClozeHinter") && InitText) ? InitText : Copy()
  if (!InitText)
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
  } else if (InitText ~= "i)^reduced$") {
    InitText := "increased/reduced"
  } else if (InitText ~= "i)^reduces$") {
    InitText := "increases/reduces"
  } else if (InitText ~= "i)^reduce$") {
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
  } else if (InitText ~= "i)^elevate$") {
    InitText := "elevate/lower"
  } else if (InitText ~= "i)^(elevates|lowers)$") {
    InitText := "elevates/lowers"
  } else if (InitText ~= "i)^(elevated|lowered)$") {
    InitText := "elevated/lowered"
  } else if (InitText ~= "i)^raise$") {
    InitText := "raise/lower"
  } else if (InitText ~= "i)^raises$") {
    InitText := "raises/lowers"
  } else if (InitText ~= "i)^raised$") {
    InitText := "raised/lowered"
  } else if (InitText ~= "i)^(activate|inhibit)$") {
    InitText := "activate/inhibit"
  } else if (InitText ~= "i)^(activates|inhibits)$") {
    InitText := "activates/inhibits"
  } else if (InitText ~= "i)^(greater|smaller)$") {
    InitText := "greater/smaller"
  } else {
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
  Gui, Destroy
  Vim.State.SetMode("Vim_Normal")
return

ClozeHinterButtonCloze:
  Gui, Submit
  Gui, Destroy
  WinActivate, ahk_class TElWind

ClozeNoBracket:
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && (CtrlState := GetKeyState("ctrl")) && Vim.SM.IsEditingText())
CapsLock & z::  ; delete [...]
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && Vim.SM.IsEditingText())
CapsLock & z::  ; delete [...]
  ClozeNoBracket := IfIn(A_ThisLabel, "ClozeNoBracket,CapsLock & z")
  TopicTitle := WinGetTitle("ahk_class TElWind")
  if ((A_ThisLabel == "ClozeNoBracket") && ClozeNoBracketCtrlState)
    CtrlState := 1, ClozeNoBracketCtrlState := 0
  if (!ClozeNoBracket && !inside && hint && IfContains(hint, "/")) {
    MsgBox, 3,, Your hint has a slash. Press yes to make it inside square brackets.
    IfMsgBox, Yes
      inside := true
    WinWaitActive, ahk_class TElWind
  }
  KeyWait Capslock
  KeyWait Alt
  KeyWait Enter
  send !z
  Vim.State.SetMode("Vim_Normal")
  if (!ClozeNoBracket && !hint && !CtrlState)  ; entered nothing
    return

  ToolTip("Cloze processing...", true)
  if (Vim.SM.WaitClozeProcessing() == -1)  ; warning on trying to cloze on items
    Goto RemoveToolTipReturn
  ; ElNumber := CtrlState ? 1 : Vim.SM.GetElNumber()
  Vim.SM.GoBack(), Vim.SM.WaitFileLoad()
  WinWaitTitleChange(TopicTitle, "ahk_class TElWind", 500)
  if (!ClozeNoBracket && !hint && CtrlState)  ; entered nothing
    Goto RemoveToolTipReturn
  if (!Vim.SM.SpamQ(, 10000))  ; not editing text after 10000ms
    Goto RemoveToolTipReturn

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
      Clip(RegExReplace(Copy(false), "\s?\[\.\.\.\]"),, false)
    } else {
      Clip(StrReplace(Copy(false), "[...]", cloze),, false)
    }
    Clipboard := ClipSaved
  } else if (Vim.SM.IsEditingHTML()) {
    ; Using F3 method
    ; if (!Vim.SM.HandleF3(1))
    ;   return
    ; ControlSetText, TEdit1, [...], ahk_class TMyFindDlg
    ; send {enter}
    ; WinWaitNotActive, ahk_class TMyFindDlg  ; faster than wait for element window to be active
    ; if (!Vim.SM.HandleF3(2))
    ;   return
    ; WinWaitActive, ahk_class TElWind
    ; ; Keeps reporting errors that SM can't access clipboard!
    ; ; if (Copy() = " [...")  ; bug in SM
    ; ;   send {left}{right}+{right 5}
    ; send % ClozeNoBracket ? "{bs}" : "{text}" . cloze
		; if (WinExist("ahk_class TMyFindDlg")) ; clear search box window
		; 	WinClose

    ; Replacing [...] directly in HTML. Much faster!
    HTML := FileRead(HTMLPath := Vim.SM.LoopForFilePath())
    ; if (HTML = "<SPAN class=cloze>[...]</SPAN>") {
    ;   if (ClozeNoBracket) {
    ;     send {del 5}
    ;   } else {
    ;     send +{right 5}
    ;     send % "{text}" . cloze
    ;   }
    ; } else {
    ;   send !{f12}fw  ; open html in notepad
    ;   if (ClozeNoBracket) {
    ;     HTML := RegExReplace(HTML, "\s?<SPAN class=cloze>\[\.\.\.\]<\/SPAN>",, v)
    ;   } else {
    ;     HTML := StrReplace(HTML, "<SPAN class=cloze>[...]</SPAN>"
    ;                            , "<SPAN class=cloze>" . cloze . "</SPAN>", v)
    ;   }
    ;   if (v) {
    ;     FileDelete % HTMLPath
    ;     FileAppend, % HTML, % HTMLPath
    ;     WinWaitActive, ahk_exe Notepad.exe
    ;     send ^w
    ;     WinClose
    ;     WinActivate, ahk_class TElWind
    ;     Vim.SM.EditFirstQuestion()  ; must focus on html, otherwise won't update it
    ;     Vim.SM.WaitHTMLFocus()
    ;     send !{f12}kr
    ;     WinWaitActive, ahk_class TRegistryForm
    ;     send {esc}  ; cannot use WinClose, won't update html
    ;     WinWaitClose
    ;   } else {
    ;     ToolTip("Cloze not found!")
    ;     WinWaitActive, ahk_exe Notepad.exe
    ;     send ^w
    ;     WinClose
    ;   }
    ; }

    Vim.SM.DeleteHTML()
    send ^{home}
    if (ClozeNoBracket) {
      HTML := RegExReplace(HTML, "\s?<SPAN class=cloze>\[\.\.\.\]<\/SPAN>",, v)
    } else {
      HTML := StrReplace(HTML, "<SPAN class=cloze>[...]</SPAN>"
                              , "<SPAN class=cloze>" . cloze . "</SPAN>", v)
    }
    Clip(HTML,,, "sm")
  }

  if (CtrlState) {
    send {esc}
  } else {
    send !{right}
  }

  ; WinWaitActive, ahk_class TElWind
  ; ; If you use !{right} the html won't get updated????
  ; send ^g
  ; send % "{text}" . ElNumber  ; ElNumber = 1 (root element) if ctrl is pressed
  ; send {enter}
  ; if (CtrlState) {  ; go back to item is ctrl is pressed
  ;   WinWaitActive, ahk_class TElWind
  ;   Vim.SM.WaitFileLoad()
  ;   Vim.SM.GoBack()
  ; }

  RemoveToolTip()
return
