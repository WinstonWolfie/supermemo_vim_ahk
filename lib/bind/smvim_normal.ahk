; Editing text only
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText()
+h::  ; move to top of screen
  Vim.ReleaseKey("shift")  ; to avoid clicking becomes selecting
  if Vim.SM.MouseMoveTop(true)
    send {left}{home}
  else
    send ^{home}
Return

+m::  ; move to middle of screen
  Vim.ReleaseKey("shift")  ; to avoid clicking becomes selecting
  Vim.SM.MouseMoveMiddle(true)
  send {left}{home}
Return

+l::  ; move to bottom of screen
  Vim.ReleaseKey("shift")  ; to avoid clicking becomes selecting
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
  If (clipboard ~= "\s" || !Clipboard) {
    SendInput {Left}{Shift Down}{Right}{Shift up}{Ctrl down}c{Ctrl Up}{Left}
    ClipWait 0.1
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
  send {esc}
  Run, % "C:\Program Files (x86)\Vim\vim82\gVim.exe " . Clipboard
  Clipboard := ClipSaved
Return