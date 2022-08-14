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
  Shift := InStr(A_ThisHotkey, "+")
  WinClip.Snap(ClipData)
  Clipboard := ""
  send !{f10}tc  ; copy template
  Vim.State.SetNormal()
  ClipWait 0.2
  if (InStr(Clipboard, "Link:")) {
    RegExMatch(Clipboard, "(?<=#Link: <a href="").*(?="")", Link)
    Clipboard := ClipSaved  ; restore clipboard here in case Run doesn't work
    if (Shift) {
      Run % "iexplore.exe " . Link
    } Else {
      Run % Link
    }
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
	ReleaseKey("shift")
  if (WinActive("ahk_class TElWind")) {
    ControlClickWinCoord(555, 66)
  } else if (WinActive("ahk_class TBrowser")) {
    ControlClickWinCoord(294, 45)
  }
  Vim.State.SetMode()
Return

; g state, for both browsing and editing
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") and (Vim.State.g)
c::  ; gc: go to next *c*omponent
  send ^t
  Vim.State.SetMode()
Return

+c::  ; gC: go to previous *c*omponent
  send !{f12}fl  ; previous component
  Vim.State.SetMode()
Return

; Need scrolling bar present
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
; Scrolling
h::Vim.Move.Repeat("h")
l::Vim.Move.Repeat("l")
^e::
j::Vim.Move.Repeat("j")
^y::
k::Vim.Move.Repeat("k")
d::Vim.Move.Repeat("^d")
u::Vim.Move.Repeat("^u")
Return

; "Browsing" mode
#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
+g::Vim.Move.Move("+g")  ; 3G goes to the 3rd line on screen

; OG Vim commands
i::Vim.State.SetMode("Insert")
:::Vim.State.SetMode("Command") ;(:)

; Browser-like actions
r::  ; reload
  if (Vim.SM.IsGrading()) {
    ContinueGrading := true
  } else if (Vim.SM.IsLearning()) {
    ContinueLearning := true
  } else {
    ContinueGrading := false
    ContinueLearning := false
  }
  send !{home}
  if (ContinueLearning) {
    ControlSend, TBitBtn2, {enter}
  } else if (ContinueGrading) {
    ControlSend, TBitBtn2, {enter}
    ControlTextWait("TBitBtn3", "Show answer")
    ControlSend, TBitBtn3, {enter}
  } else {
    sleep 100
    send !{left}
  }
return

n::send !n  ; create new topic
+n::send !a  ; create new item
x::send {del}  ; delete element/component
#If (Vim.IsVimGroup()
     && Vim.State.IsCurrentVimMode("Vim_Normal")
     && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
         || WinActive("ahk_class TContents")
         || WinActive("ahk_class TBrowser")))
+x::send ^+{enter}  ; Done!

#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
p::
  send ^{f10}  ; replay auto-play
  WinWaitActive, ahk_class TMsgDialog,, 0
  if (!ErrorLevel)
    send y 
return

+p::send ^{t 2}{f9}  ; play video in default system player / edit script component
^i::send ^{f8}  ; download images

; Element navigation
#If (Vim.IsVimGroup()
     && Vim.State.IsCurrentVimMode("Vim_Normal")
     && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
         || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
+h::send !{left}  ; go back in history
+l::send !{right}  ; go forward in history
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
+j::send !{pgdn}  ; J, ge: go down one element
+k::send !{pgup}  ; K, gE: go up one element

; Open windows
c::send !c  ; open content window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow()
c::send !c
#If (Vim.IsVimGroup()
     && Vim.State.IsCurrentVimMode("Vim_Normal")
     && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
         || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
b::
  if (WinExist("ahk_class TBrowser")) {
    WinActivate
  } else {
    ; Sometimes a bug makes that you can't use ^space to open browser in content window
    ; After a while, I found out it's due to my Chinese input method
    SetDefaultKeyboard(0x0409)  ; english-US	
    send ^{space}  ; open browser
  }
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TBrowser")
b::WinActivate, ahk_class TBrowser  ; why not
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
o::
  Vim.State.SetMode("Insert")
  send ^o  ; favourites
  BackToNormal := 1
return

f::Vim.SM.ClickMid()  ; click on html component

; Copy
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_ydc_y")) && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
y::  ; yy: copy current source url
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send !{f10}tc  ; copy template
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (InStr(Clipboard, "Link:")) {
    RegExMatch(Clipboard, "(?<=#Link: <a href="").*(?="")", Link)  ; regexmatch cannot store into clipboard
    Clipboard := link
    Vim.ToolTip("Copied " . clipboard)
  } else {
    Vim.ToolTip("Link not found.")
    Clipboard := ClipSaved
  }
  Vim.State.SetNormal()
Return

e::  ; ye: duplicate current element
  send !d
  Vim.State.SetNormal()
Return

; Plan/tasklist window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingPlan()
s::ControlClickWinCoord(253, 48)  ; *s*witch plan
b::send !b  ; begin
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingTask()
s::ControlClickWinCoord(153, 52)  ; *s*witch tasklist

; For incremental YouTube
; Need "Start" button on screen
#If Vim.IsVimGroup() && WinActive("ahk_class TElWind") && (FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start.png", "n o64", x_coord, y_coord) || FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start_hover.png", "n o64", x_coord, y_coord))
^+!s::
  CoordMode, Mouse, Screen
  click, %x_coord% %y_coord%  ; click start (similar to mark read point)
Return

^+!`::
  x_coord += 170
  CoordMode, Mouse, Screen
  click, %x_coord% %y_coord%  ; click play (similar to go to read point)
Return

^+!r::
  x_coord += 195
  CoordMode, Mouse, Screen
  click, %x_coord% %y_coord%  ; click reset (similar to clear read point)
Return

^+!left::
^+!right::
^+!numpadleft::
^+!numpadright::
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
  BackToNormal := 2
Return

#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind"))
^f7::
m::
  if (Vim.SM.IsEditingHTML())
    Vim.SM.ClickMid()
  send ^{f7}  ; set read point
  Vim.ToolTip("Read point set")
Return

!f7::
`::
  send !{f7}  ; go to read point
  Vim.ToolTip("Go to read point")
Return

!m::
^+f7::
  send ^+{f7}  ; clear read point
  Vim.ToolTip("Read point cleared")
Return

!+j::send !+{pgdn}  ; go to next sibling
!+k::send !+{pgup}  ; go to previous sibling

#If (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && !Vim.State.fts && WinActive("ahk_class TElWind"))
^/::  ; visual
^+/::  ; visual and start from the beginning
#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind"))
?::  ; caret on the right
!/::  ; followed by a cloze
^!/::  ; followed by a cloze and stays in clozed item
+!/::  ; followed by a cloze hinter
^+!/::  ; also cloze hinter but stays in clozed item
/::  ; better search
  CtrlState := InStr(A_ThisHotkey, "^")  ; visual
  ShiftState := InStr(A_ThisHotkey, "+")  ; caret on the right
  RShiftState := GetKeyState("RShift")  ; caret on the right
  LShiftState := GetKeyState("LShift")  ; start from top
  AltState := InStr(A_ThisHotkey, "!")  ; followed by a cloze
  if (!Vim.SM.IsEditingText()) {
    send ^t
    Vim.SM.WaitTextFocus()  ; make sure CurrentFocus is updated    
    if (!Vim.SM.IsEditingText()) {  ; still found no text
      Vim.ToolTip("Text not found.")
      Vim.State.SetNormal()
      Return
    }
  } 
  if (Vim.State.StrIsInCurrentVimMode("Visual")) {
    send {right}
    Vim.State.SetNormal()
  }
  if (LShiftState)
    send ^{Home}
  ControlGetFocus, CurrentFocus, ahk_class TElWind
  if (AltState) {
    Gui, Search:Add, Text,, &Find text:`n(your search result will be clozed)
  } else if (CtrlState) {
    Gui, Search:Add, Text,, &Find text:`n(will go to visual mode after the search)
  } else {
    Gui, Search:Add, Text,, &Find text:
  }
  Gui, Search:Add, Edit, vUserInput w196, % VimLastSearch
  Gui, Search:Add, CheckBox, vWholeWord, Match &whole word only
  Gui, Search:Add, Button, default, &Search
  Gui, Search:Show,, Search
return

SearchGuiEscape:
SearchGuiClose:
  Gui, Destroy
return

SearchButtonSearch:
  Gui, Submit
  Gui, Destroy
  if (!UserInput)
    Return
  VimLastSearch := UserInput  ; register UserInput into VimLastSearch
  ; Previously, UserInput is stored in Vim.Move.LastSearch, but it turned out this would add 000... in floating numbers
  ; i.e. 3.8 would become 3.80000
  WinActivate, ahk_class TElWind
  if (InStr(CurrentFocus, "TMemo")) {
    send ^a
    if (Vim.State.n) {
      n := Vim.State.n
      Vim.State.n := 0
    } else {
      n := 1
    }
    pos := InStr(clip(), UserInput, true,, n)
    if (pos) {
      pos -= 1
      SendInput {left}{right %pos%}
      input_len := StrLen(UserInput)
      if (RShiftState) {
        SendInput {right %input_len%}
      } else if (CtrlState || AltState) {
        SendInput +{right %input_len%}
        if (CtrlState) {
          Vim.State.SetMode("Vim_VisualFirst")
        } else if (AltState) {
          send !z
        }
      }
    } else {
      Vim.ToolTip("Not found.")
      Vim.State.SetNormal()
      Return
    }
  } else {
    send {esc}  ; esc to exit field, so it can return to the same field later
    Vim.SM.WaitTextExit(2000)
    send {f3}
    WinWaitActive, ahk_class TMyFindDlg,, 0
    if (ErrorLevel) {
      send {esc}^{enter}h{enter}{f3}
      WinWaitActive, ahk_class TMyFindDlg,, 0
      if (ErrorLevel)
        Return
    }
    clip(UserInput)
    if (WholeWord)
      send !w  ; match whole word
    send !c  ; match case
    send {enter}
    if (Vim.State.n) {
      send % "{f3 " . Vim.State.n - 1 . "}"
      Vim.State.n := 0
    }
    WinWaitNotActive, ahk_class TMyFindDlg,, 0  ; faster than wait for element window to be active
    if (ErrorLevel)
      Return
    if (!AltState) {
      if (RShiftState) {
        send {right}  ; put caret on right of searched text
      } else if (CtrlState) {
        Vim.State.SetMode("Vim_VisualFirst")
      } else {  ; all modifier keys are not pressed
        send {left}  ; put caret on left of searched text
      }
    }
    send ^{enter}  ; to open commander; convienently, if a "not found" window pops up, this would close it
    WinWaitActive, ahk_class TCommanderDlg,, 1
    if (ErrorLevel) {
      Vim.ToolTip("Not found.")
      Vim.State.SetNormal()
      send {esc}^{enter}h{enter}{esc}
      Return
    }
    send h{enter}
    if WinExist("ahk_class TMyFindDlg")  ; clears search box window
      WinClose
    if AltState {
      if !CtrlState && !ShiftState
        send !z
      else if ShiftState {
        if CtrlState
          ClozeHinterCtrlState := 1
        WinWaitActive, ahk_class TElWind,, 0
        gosub ClozeHinter
      } else if CtrlState
        gosub ClozeStay
    } else if !CtrlState  ; alt is up and ctrl is up; shift can be up or down
      send {esc}^t  ; to return to the same field
    else if CtrlState {  ; sometimes SM doesn't focus to anything after the search
      WinWaitActive, ahk_class TElWind,, 0
      ControlGetFocus, CurrentFocusAfter, ahk_class TElWind
      if !CurrentFocusAfter
        ControlFocus, %CurrentFocus%, ahk_class TElWind
    }
  }
Return