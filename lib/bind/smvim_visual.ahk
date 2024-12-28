#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && SM.IsEditingText())
.::  ; selected text becomes [...]
  if (!Vim.State.Leader)
    Send ^c
  if (SM.IsEditingHTML()) {
    Send {text}<span class="Cloze">[...]</span>
    Send +{Left 32}^+1
  } else if (SM.IsEditingPlainText()) {
    Send {text}[...]
  }
  Vim.State.SetMode("Vim_Normal")
return

~!t::
~!q::Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && SM.IsEditingHTML())
~^+i::Vim.State.SetMode("Vim_Normal")  ; ignore

^h::  ; parse *h*tml
  Send ^+1
~^+1::Vim.State.SetMode("Vim_Normal")

SMParseHTMLGUI:
!a::  ; p*a*rse html
  GAltA := (A_ThisLabel == "SMParseHTMLGUI"), Vim.State.SetMode("Vim_Normal")
  SetDefaultKeyboard(0x0409)  ; English-US
  Gui, HTMLTag:Add, Text,, &HTML tag:
  RegExMatch(SM.CssClass, "hint.*$", v)
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
  if (Copy(false) = "") {
    Clipboard := ClipSaved
    SetToolTip("Text not found.")
    return
  }
  if (OriginalHTML) {
    Content := GetClipHTMLBody()
  } else {
    Content := StrReplace(Clipboard, "<", "&lt;")
    Content := StrReplace(Content, ">", "&gt;")
  }
  StartingTag := "<", EndingTag := ">"
  if (Class || SM.IsCssClass(Tag)) {
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
  SM.ClickTop()
  Send {Shift Up}
Return

+m::  ; move to middle of screen
  Send {Shift Down}
  SM.ClickMid()
  Send {Shift Up}
Return

+l::  ; move to bottom of screen
  Send {Shift Down}
  SM.ClickBottom()
  Send {Shift Up}
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && SM.IsEditingPlainText())
m::Send % "{text}*" . Copy() . "*"

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && WinActive("ahk_class TContents") && SM.IsNavigatingContentWind())
b::SM.OpenBrowser(), Vim.State.SetMode("Vim_Normal")
