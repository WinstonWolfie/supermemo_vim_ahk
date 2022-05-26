; Hotkeys in this file are inspired by Vimium: https://github.com/philc/vimium

; g state on top to have higher priority
; putting those below would make gu stops working (u also triggers scroll up)

; Element window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() and !(Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() and (Vim.State.g)
g::Vim.Move.Move("g")  ; 3gg goes to the 3rd line of entire text

+s::
s::  ; gs: go to source link
  Shift := GetKeyState("Shift")
  ClipSaved := ClipboardAll
  Clipboard := ""
  send !{f10}fs  ; show reference
  WinWaitActive, Information,, 0
  send p{esc}  ; copy reference
  Vim.State.SetNormal()
  ClipWait 0.2
  if InStr(Clipboard, "Link:") {
    RegExMatch(Clipboard, "Link: \K.*", Link)
    Clipboard := ClipSaved  ; restore clipboard here in case Run doesn't work
    if Shift
      Run, iexplore.exe %Link%
    Else
      Run % Link
  } else {
    Vim.ToolTip("No link found.")
    Clipboard := ClipSaved
  }
Return

; Element/content window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) && !Vim.SM.IsEditingText() and (Vim.State.g)
+e::  ; K, gE: go up one *e*lement
  send !{pgup}
  Vim.State.SetMode()
Return

e::  ; J, ge: go down one *e*lement
  send !{pgdn}
  Vim.State.SetMode()
Return

0::  ; g0: go to root element
  send !{home}
  Vim.State.SetMode()
Return

$::  ; g$: go to last element
  send !{end}
  Vim.State.SetMode()
Return

u::  ; gu: go up
  send ^{up}
  Vim.State.SetMode()
Return

; Element window / browser
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TBrowser")) && !Vim.SM.IsEditingText() and (Vim.State.g)
+u::  ; gU: click source button
  if WinActive("ahk_class TElWind")
    FindClick(A_ScriptDir . "\lib\bind\util\source_element_window.png")
  else
    FindClick(A_ScriptDir . "\lib\bind\util\source_browser.png")
  Vim.State.SetMode()
Return

; g state, for both browsing and editing
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") and (Vim.State.g)
c::  ; gc: go to next *c*omponent
  send ^t
  Vim.State.SetMode()
Return

+c::  ; gC: go to previous *c*omponent
  send !{f12}fl
  Vim.State.SetMode()
Return

; Need scrolling bar present
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
; Scrolling
h::SendMessage, 0x114, 0, 0, Internet Explorer_Server1, A ; scroll left
l::SendMessage, 0x114, 1, 0, Internet Explorer_Server1, A ; scroll right
^e::
j::SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A ; scroll down
^y::
k::SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A ; scroll up
d::
  SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A
  SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A
Return
u::
  SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A
  SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A
Return

; "Browsing" mode
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
+g::Vim.Move.Move("+g")  ; 3G goes to the 3rd line on screen

; OG Vim commands
i::Vim.State.SetMode("Insert")
:::Vim.State.SetMode("Command") ;(:)

; Browser-like actions
r::send !{home}!{left}  ; reload
n::send !n  ; create new topic
+n::send !a  ; create new item
x::send {del}  ; delete element/component
+x::send ^+{enter}  ; Done!
p::send ^{f10}  ; replay auto-play
+p::send ^{t 2}{f9}  ; play video in default system player / edit script component
^i::send ^{f8}  ; download images

; Element navigation
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
or (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow()))
+h::send !{left}  ; go back in history
+l::send !{right}  ; go forward in history
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
+j::send !{pgdn}  ; J, ge: go down one element
+k::send !{pgup}  ; K, gE: go up one element

; Open windows
c::send !c  ; open content window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow()
c::send {esc}  ; close content window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
or (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow()))
b::
  if WinExist("ahk_class TBrowser") {
    WinActivate
  } else {
    send ^{space}  ; open browser
  }
Return
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TBrowser")
b::send {esc}  ; close browser
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
o::send ^o  ; favourites

f::  ; click on html component
  if (Vim.SM.MouseMoveMiddle(true)) {
    Vim.SM.WaitTextFocus(200)
    send {left}{home}
  } else {
    send ^t
    Vim.SM.WaitTextFocus(200)
    send {home}
  }
Return

; Copy
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_ydc_y")) && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
y::  ; yy: copy current source url
  ClipSaved := ClipboardAll
  Clipboard := ""
  send !{f10}fs  ; show reference
  WinWaitActive, Information,, 0
  send p{esc}  ; copy reference
  Vim.State.SetNormal()
  ClipWait 0.2
  if InStr(Clipboard, "Link:") {
    RegExMatch(Clipboard, "Link: \K.*", link)
    Clipboard := link
  }
  Vim.ToolTip("Copied " . link)
Return

e::  ; ye: duplicate current element
  send !d
  Vim.State.SetNormal()
Return

; Plan/tasklist window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingPlan()
s::ClickDPIAdjusted(253, 48)  ; *s*witch plan
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingTask()
s::ClickDPIAdjusted(153, 52)  ; *s*witch tasklist

; For incremental YouTube
; Need "Start" button on screen
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start.png", "n o32", x_coord, y_coord) || FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start_hover.png", "n o32", x_coord, y_coord))
m::
  CoordMode, Mouse, Screen
  click, %x_coord% %y_coord%  ; click start (similar to mark read point)
Return

`::
  x_coord += 170
  CoordMode, Mouse, Screen
  click, %x_coord% %y_coord%  ; click play (similar to go to read point)
Return

!m::
  x_coord += 195
  CoordMode, Mouse, Screen
  click, %x_coord% %y_coord%  ; click reset (similar to clear read point)
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Insert")) && WinActive("ahk_class TElWind") && (FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start.png", "n o32", x_coord, y_coord) || FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start_hover.png", "n o32", x_coord, y_coord))
^+!left::
^+!right::
^+!numpadleft::
^+!numpadright::
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start.png", "n o32", x_coord, y_coord) || FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start_hover.png", "n o32", x_coord, y_coord))
NumpadLeft::
left::  ; left 5s
NumpadRight::
right::  ; right 5s
  x_coord += 110
  y_coord -= 60
  CoordMode, Mouse, Screen
  click, %x_coord% %y_coord%
  if (InStr(A_ThisHotkey, "left")) {
    send {left}
  } else if (InStr(A_ThisHotkey, "right")) {
    send {right}
  }
  send ^t
  sleep 10
  send ^t
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Insert")) && WinActive("ahk_class TElWind") && (FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start.png", "n o32", x_coord, y_coord) || FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start_hover.png", "n o32", x_coord, y_coord))
^+!y::  ; focus to youtube video
  Vim.ReleaseKey("ctrl")
  Vim.ReleaseKey("shift")
  KeyWait alt
  x_coord += 110
  y_coord -= 60
  CoordMode, Mouse, Screen
  click, %x_coord% %y_coord%
  Vim.State.SetMode("Insert")  ; insert so youtube can read keys like j, l, etc
Return

^+!k::  ; pause
  Vim.ReleaseKey("ctrl")
  Vim.ReleaseKey("shift")
  KeyWait alt
  CoordMode, Mouse, Screen
  y_coord -= 60
  click, %x_coord% %y_coord%
  send ^t
  sleep 10
  send ^t
  sleep 400
  if FindClick(A_ScriptDir . "\lib\bind\util\yt_more_videos_right.png", "o96", x_coord, y_coord) {
    x_coord -= 10
    y_coord -= 65
    click % x_coord . " " . y_coord
    send ^t
    sleep 10
    send ^t
  }
Return

^+!n::  ; focus to notes
  Vim.ReleaseKey("ctrl")
  Vim.ReleaseKey("shift")
  KeyWait alt
  send ^t
  sleep 10
  send ^t
  Vim.State.SetNormal()
Return

; Browsing/editing
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") and (Vim.State.g)
{::Vim.Move.Move("{")
}::Vim.Move.Move("}")

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && !Vim.State.fts && WinActive("ahk_class TElWind")
'::
  send ^{f3}
  Vim.State.SetMode("Insert")
  back_to_normal := 2
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind")
^f7::
m::
  ; if (Vim.SM.IsEditingHTML() && Vim.SM.MouseMoveMiddle(true))
  ;   send {home}
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
  shift_state := GetKeyState("shift")  ; caret on the right
  r_shift_state := GetKeyState("RShift")  ; caret on the right
  l_shift_state := GetKeyState("LShift")  ; start from top
  alt_state := GetKeyState("alt")  ; followed by a cloze
  if !Vim.SM.IsEditingText() {
    send ^t
    Vim.SM.WaitTextFocus()  ; make sure current_focus is updated    
    if !Vim.SM.IsEditingText() {  ; still found no text
      Vim.ToolTip("Text not found.")
      Vim.State.SetNormal()
      Return
    }
  }
  if (l_shift_state)
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
    if (pos) {
      pos -= 1
      SendInput {left}{right %pos%}
      input_len := StrLen(UserInput)
      if (r_shift_state) {
        SendInput {right %input_len%}
      } else if (ctrl_state || alt_state) {
        SendInput +{right %input_len%}
        if (ctrl_state) {
          Vim.State.SetMode("Vim_VisualFirst")
        } else if (alt_state) {
          send !z
        }
      }
    } else {
      Vim.ToolTip("Not found.")
      Vim.State.SetNormal()
      Return
    }
  } else {
    send {esc}{f3}  ; esc to exit field, so it can return to the same field later
    WinWaitActive, ahk_class TMyFindDlg,, 0
    if ErrorLevel
      Return
    clip(UserInput)
    send !c{enter}
    WinWaitNotActive, ahk_class TMyFindDlg,, 0  ; faster than wait for element window to be active
    if ErrorLevel
      Return
    if !alt_state
      if r_shift_state
        send {right}  ; put caret on right of searched text
      else if ctrl_state
        Vim.State.SetMode("Vim_VisualFirst")
      else  ; all modifier keys are not pressed
        send {left}  ; put caret on left of searched text
    send ^{enter}  ; to open commander; convienently, if a "not found" window pops up, this would close it
    WinWaitActive, ahk_class TCommanderDlg,, 0.25
    if ErrorLevel {
      Vim.ToolTip("Not found.")
      Vim.State.SetNormal()
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