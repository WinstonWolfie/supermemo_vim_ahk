#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && Vim.SM.IsEditingHTML()
~^+i::Vim.State.SetMode("Vim_Normal")  ; ignore

.::  ; selected text becomes [...]
  Clip("<span class=""Cloze"">[...]</span>", true)
  send ^+1
  ; ClipSave := ClipboardAll
  ; SetClipboardHTML("<span class=""Cloze"">[...]</span>")
  ; ClipWait 1
  ; send ^v 
  ; Clipboard := ClipSave
  Vim.State.SetMode("Vim_Normal")
return

a::  ; p*a*rse html
^+1::
  send ^+1
  Vim.State.SetMode("Vim_Normal")
return

+a::
  Vim.State.SetMode("Vim_Normal")
  Gui, HTMLTag:Add, Text,, &HTML tag:
  list = H1||H2|H3|H4|H5|H6|B|I|U|STRONG|CODE|PRE|EM|cloze|clozed|extract
  Gui, HTMLTag:Add, Combobox, vTag gAutoComplete, %list%
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
  WinActivate, ahk_class TElWind
  if (tag == "cloze" || tag == "extract" || tag == "clozed")
    clip("<SPAN class=" . tag . ">" . clip() . "</SPAN>", true)
  else
    clip("<" . tag . ">" . clip() . "</" . tag . ">", true)
  send ^+1
Return

m::  ; highlight: *m*ark
  send !{f12}rh
  Vim.State.SetMode("Vim_Normal")
return

q::  ; extract (*q*uote)
  send !x
  Vim.State.SetMode("Vim_Normal")
return

extract_stay:
#If Vim.IsVimGroup() and WinActive("ahk_class TElWind")
^!x::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
^q::  ; extract (*q*uote)
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

cloze_stay:
#If Vim.IsVimGroup() and WinActive("ahk_class TElWind")
^!z::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
^z::
  send !z
  Vim.State.SetMode("Vim_Normal")
  WinWaitActive, ahk_class TMsgDialog,, 0  ; warning on trying to cloze on items
  if !ErrorLevel
    return
  Vim.SM.WaitProcessing()
  send !{left}
Return

~!t::
~!q::
  Vim.State.SetMode("Vim_Normal")
Return

cloze_hinter:
#If Vim.IsVimGroup() && WinActive("ahk_class TElWind")
^!+z::
!+z::
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
^+z::  ; cloze hinter
+z::  ; cloze hinter
  if cloze_hinter_ctrl_state && (A_ThisLabel == "cloze_hinter") {  ; from cloze hinter label and ctrl is down
    ctrl_state := 1
    cloze_hinter_ctrl_state := 0
  } else
    ctrl_state := GetKeyState("Ctrl")
  Gui, ClozeHinter:Add, Text,, &Hint:
  Gui, ClozeHinter:Add, Edit, vHint
  Gui, ClozeHinter:Add, CheckBox, vInside, &Inside square brackets
  Gui, ClozeHinter:Add, Button, default, Clo&ze
  Gui, ClozeHinter:Show,, Cloze Hinter
Return

ClozeHinterGuiEscape:
ClozeHinterGuiClose:
  Gui, Destroy
return

ClozeHinterButtonCloze:
  Gui, Submit
  Gui, Destroy
  WinActivate, ahk_class TElWind
  send !z
  Vim.State.SetMode("Vim_Normal")
  if !hint  ; entered nothing
    return
  Vim.ToolTip("Cloze hinting...", true)
  sleep_calculation := A_TickCount
  Vim.SM.WaitProcessing()
  if ErrorLevel
    Return
  send !{left}
  sleep % (A_TickCount - sleep_calculation) / 3 * 2
  send q
  if Inside
    cloze = [%hint%]
  else
    cloze = [...](%hint%)
  Vim.SM.WaitTextFocus()
  if Vim.SM.IsEditingPlainText() {  ; editing plain text
    send ^a
    clip(StrReplace(clip(), "[...]", cloze))
  } else if Vim.SM.IsEditingHTML() {
    ClipSaved := ClipboardAll
    Clipboard := ""
    send !{f12}fc  ; copy file path
    ClipWait 0.2
    sleep 20
    FileRead, html, % Clipboard
    Vim.SM.MoveAboveRef(true)
    send !\\
    WinWaitNotActive, ahk_class TElWind,, 0
    if !ErrorLevel
      send {enter}
    clip(StrReplace(html, "<SPAN class=cloze>[...]</SPAN>", "<SPAN class=cloze>" . cloze . "</SPAN>"),, true)
    send ^+{home}^+1
    Vim.SM.WaitTextSave()
    Clipboard := ClipSaved
    if ErrorLevel
      Return
  }
  if !ctrl_state  ; only goes back to topic if ctrl is up
    send !{right}  ; add a ctrl to keep editing the clozed item
  else  ; refresh if staying in the cloze item
    send !{home}!{left}
  Gosub RemoveToolTip
return