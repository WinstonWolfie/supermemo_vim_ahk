; Editing text only
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText()
+h::  ; move to top of screen
  if Vim.SM.MouseMoveTop(true)
    send {left}{home}
  else
    send ^{home}
Return

+m::  ; move to middle of screen
  Vim.SM.MouseMoveMiddle(true)
  send {home}
Return

+l::  ; move to bottom of screen
  if !Vim.SM.MouseMoveBottom(true)
    send ^{end}
  send {home}
Return

; Editing HTML
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingHTML()
+n::
n::  ; open hyperlink in current caret position (Open in *n*ew window)
  Shift := GetKeyState("shift")
  Vim.ReleaseKey("shift")
  BlockInput, Send
  tempClip := Clipboardall
  clipboard := ""
  SendInput {Shift Down}{Right}{Shift up}{Ctrl down}c{Ctrl Up}{Left}
  ClipWait 0.1
  sleep 10  ; short sleep to make sure clipboard updates
  If (clipboard ~= "\s") {
    SendInput {Left}{Shift Down}{Right}{Shift up}{Ctrl down}c{Ctrl Up}{Left}
    ClipWait 0.1
    sleep 10
  }
  BlockInput, off
  If Vim.HTML.ClipboardGet_HTML( Data ) {
    RegExMatch(data, "(<A((.|\r\n)*)href="")\K[^""]+", CurrentLink)
    if !CurrentLink
      Vim.ToolTip("No link found.")
    else if InStr(CurrentLink, "SuperMemoElementNo=(") {  ; goes to a supermemo element
      click, %A_CaretX% %A_CaretY%, right
      send n
    } else
      if Shift
        Run, iexplore.exe %CurrentLink%
      else
        run % CurrentLink
  }
    clipboard := tempClip
return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingHTML() and (Vim.State.g)
s::
  ClipSaved := ClipboardAll
  Clipboard := ""
  send !{f12}fc
  ClipWait 0.2
  sleep 20
  send {esc}
  Run, % "C:\Program Files (x86)\Vim\vim82\vim.exe " . Clipboard
  Clipboard := ClipSaved
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") and (Vim.State.g)
{::Vim.Move.Move("{")
}::Vim.Move.Move("}")

; Browsing/editing
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && WinActive("ahk_class TElWind")
'::
  send ^{f3}
  Vim.State.SetMode("Insert")
  back_to_normal := 2
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind")
^f7::
m::
  send ^{f7}  ; set read point
  Vim.ToolTip("Read point set")
Return

!f7::
`::
  send !{f7}  ; go to read point
  Vim.ToolTip("Go to read point")
Return

!m::
  KeyWait alt
^+f7::
  send ^+{f7}  ; clear read point
  Vim.ToolTip("Read point cleared")
Return

!+j::send !+{pgdn}  ; go to next sibling
!+k::send !+{pgup}  ; go to previous sibling

^/::  ; visual
?::  ; caret on the right
!/::  ; followed by a cloze
^!/::  ; followed by a cloze and stays in clozed item
+!/::  ; followed by a cloze hinter
^+!/::  ; also cloze hinter but stays in clozed item
/::  ; better search
  ctrl_state := GetKeyState("Ctrl")  ; visual
  shift_state := GetKeyState("RShift")  ; caret on the right
  alt_state := GetKeyState("alt")  ; followed by a cloze
  if !Vim.SM.IsEditingText() {
    send ^t
    Vim.SM.WaitTextFocus()  ; make sure current_focus is updated    
    if !Vim.SM.IsEditingText() {  ; still found no text
      Vim.ToolTip("Text not found.")
      Return
    }
  }
  if (GetKeyState("LShift"))
    send ^{Home}
  ControlGetFocus, current_focus, ahk_class TElWind
  if alt_state
    InputBox, UserInput, Search, Find text:`n(your search result will be clozed),, 272, 144,,,,, % Vim.Move.LastSearch
  else if ctrl_state
    InputBox, UserInput, Search, Find text:`n(will go to visual mode after the search),, 272, 144,,,,, % Vim.Move.LastSearch
  else
    InputBox, UserInput, Search, Find text:,, 272, 128,,,,, % Vim.Move.LastSearch
  if ErrorLevel || !UserInput
    Return
  Vim.Move.LastSearch := UserInput  ; register UserInput into LastSearch
  WinActivate, ahk_class TElWind
  if InStr(current_focus, "TMemo") {
    send ^a
    pos := InStr(clip(), UserInput)
    if pos {
      pos -= 1
      SendInput {left}{right %pos%}
      input_len := StrLen(UserInput)
      if shift_state
        SendInput {right %input_len%}
      else if ctrl_state || alt_state {
        SendInput +{right %input_len%}
        if ctrl_state
          Vim.State.SetMode("Vim_VisualChar")
        else if alt_state
          send !z
      }
    } else {
      Vim.ToolTip("Not found.")
      Return
    }
  } else {
    send {esc}{f3}  ; esc to exit field, so it can return to the same field later
    WinWaitActive, ahk_class TMyFindDlg,, 0
    if ErrorLevel
      Return
    clip(UserInput)
    send {enter}
    WinWaitNotActive, ahk_class TMyFindDlg,, 0  ; faster than wait for element window to be active
    if ErrorLevel
      Return
    if !alt_state
      if shift_state
        send {right}  ; put caret on right of searched text
      else if ctrl_state
        Vim.State.SetMode("Vim_VisualChar")
      else  ; all modifier keys are not pressed
        send {left}  ; put caret on left of searched text
    send ^{enter}  ; to open commander; convienently, if a "not found" window pops up, this would close it
    WinWaitActive, ahk_class TCommanderDlg,, 0.25
    if ErrorLevel {
      Vim.ToolTip("Not found.")
      send {esc}^{enter}h{enter}{esc}
      Return
    }
    send h{enter}
    if WinExist("ahk_class TMyFindDlg")  ; clears search box window
      WinClose
    if alt_state {
      if !ctrl_state && !shift_state
        send !z
      else if shift_state {
        if ctrl_state
          cloze_hinter_ctrl_state := 1
        WinWaitActive, ahk_class TElWind,, 0
        gosub cloze_hinter
      } else if ctrl_state
        gosub cloze_stay
    } else if !ctrl_state  ; alt is up and ctrl is up; shift can be up or down
      send {esc}^t  ; to return to the same field
    else if ctrl_state {  ; sometimes SM doesn't focus to anything after the search
      WinWaitActive, ahk_class TElWind,, 0
      ControlGetFocus, current_focus_after, ahk_class TElWind
      if !current_focus_after
        ControlFocus, %current_focus%, ahk_class TElWind
    }
  }
Return
