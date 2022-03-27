#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
; Undo/Redo
u::Send,^z
^r::Send,^y

; Combine lines
+j:: Send, {End}{Space}{Delete}
+k:: Send, {up}{End}{Space}{Delete}

; Change case
~::
  Vim.ReleaseKey("shift")
  Send, +{Right}
  Selection := Clip()
  if Selection is lower
    StringUpper, Selection, Selection
  else if Selection is upper
    StringLower, Selection, Selection
  SendInput {raw}%Selection%
Return

+z::Vim.State.SetMode("Z")
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Z"))
+z::
  Send, ^s
  Send, !{F4}
  Vim.State.SetMode("Vim_Normal")
Return

+q::
  Send, !{F4}
  Vim.State.SetMode("Vim_Normal")
Return

; #If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
; Space::Send, {Right}

; period
; .::Send, +^{Right}{BS}^v

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual"))
^e::
  if Vim.SM.IsEditingHTML()
    Vim.SM.MouseMoveTop()
  Vim.ReleaseKey("ctrl")
  send {WheelDown}{CtrlDown}
return

^y::
  if Vim.SM.IsEditingHTML()
    Vim.SM.MouseMoveTop()
  Vim.ReleaseKey("ctrl")
  send {WheelUp}{CtrlDown}
return

; Q-dir
#If Vim.IsVimGroup() and WinActive("ahk_group VimQdir") and (Vim.State.Mode == "Vim_Normal")
; For Q-dir, ^X mapping does not work, use !X instead.
; ^X does not work to be sent, too, use Down/Up
; switch to left top (1), right top (2), left bottom (3), right bottom (4)
!u::Send, {LControl Down}{1 Down}{1 Up}{LControl Up}
!i::Send, {LControl Down}{2 Down}{2 Up}{LControl Up}
!j::Send, {LControl Down}{3 Down}{3 Up}{LControl Up}
!k::Send, {LControl Down}{4 Down}{4 Up}{LControl Up}
; Ctrl+q, menu Quick-links
'::Send, {LControl Down}{q Down}{q Up}{LControl Up}
; Keep the e key in Normal mode, use the right button and then press the refresh (e) function, do nothing, return to the e key directly
~e::
Return

#If
