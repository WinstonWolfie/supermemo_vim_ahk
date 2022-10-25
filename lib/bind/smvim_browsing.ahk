; Hotkeys in this file are inspired by Vimium: https://github.com/philc/vimium

; g state on top to have higher priority
; putting those below would make gu stops working (u also triggers scroll up)

; Element window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
'::Vim.State.SetMode("",, -1,,, -1, 1)  ; leader key
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() && !Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() && Vim.State.g)
g::Vim.Move.Move("g")  ; 3gg goes to the 3rd line of entire text

+u::  ; gU: click source button
  Vim.SM.ClickElWindSourceBtn()
  Vim.State.SetMode()
Return

+s::  ; gS: open link in IE
SMGoToLink:
s::  ; gs: go to link
  Vim.State.SetMode()
  link := Vim.SM.GetLink()
  if (link) {
    if (InStr(A_ThisHotkey, "+")) {
      ; run % "iexplore.exe " . Link  ; RIP IE
      Vim.Browser.RunInIE(link)
    } else {
      run % Link
    }
  } else {
    ToolTip("No link found.")
  }
Return

; Element/content window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) && !Vim.SM.IsEditingText() && Vim.State.g)
u::  ; gu: go up
  send ^{up}
  Vim.State.SetMode()
Return

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

; Element window / browser
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TBrowser")) && !Vim.SM.IsEditingText() && Vim.State.g)
; g state, for both browsing and editing
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && Vim.State.g)
c::  ; gc: go to next *c*omponent
  send ^t
  Vim.State.SetMode()
Return

+c::  ; gC: go to previous *c*omponent
  ; Vim.SM.PostMsg(992, true)  ; not reliable???
  send !{f12}fl
  Vim.State.SetMode()
Return

; Need scrolling bar present
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() && !Vim.State.g)
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
; Unlike Vim, 3gg and 3G work differently
; 3gg goes to the 3rd line in the entire document
; 3G goes to the 3rd line on screen
+g::Vim.Move.Move("+g")

; OG Vim commands
i::Vim.State.SetMode("Insert")
:::Vim.State.SetMode("Command") ;(:)

; Browser-like actions
r::  ; reload
  ; Move mouse so WaitFileLoad() works correctly,
  ; which requires status bar text detection
  ContinueGrading := Vim.SM.IsGrading()
  ContinueLearning := ContinueGrading ? 0 : Vim.SM.IsLearning()
  CurrTitle := WinGetTitle()
  send !{home}
  if (ContinueLearning) {
    Vim.SM.Learn()
    Vim.SM.WaitFileLoad()
    ; When r is pressed, the review score in an item is submitted,
    ; thus refreshing and learning takes SM to a new element
    if (ContinueLearning == 2 && CurrTitle != WinGetTitle())
      send !{left 2}
  } else if (ContinueGrading) {
    Vim.SM.Learn()
    ControlTextWait("TBitBtn3", "Show answer")
    ControlSend, TBitBtn3, {enter}
  } else {
    Vim.SM.WaitFileLoad()
    while (WinExist("ahk_class Internet Explorer_TridentDlgFrame"))  ; sometimes could happen on YT videos
      WinClose
    ; If current element is home element
    if (RegExMatch(CurrTitle, "^Concept: ") && CurrTitle == WinGetTitle("ahk_class TElWind")) {
      send !{left}
      Vim.SM.WaitFileLoad()
      send !{right}
    } else {
      send !{left}
    }
  }
return

n::send !n  ; create new topic
+n::send !a  ; create new item
x::send {del}  ; delete element/component
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
   || WinActive("ahk_class TContents")
   || WinActive("ahk_class TBrowser")))
+x::send ^+{enter}  ; Done!

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
p::
  send ^{f10}  ; replay auto-play
  WinWaitActive, ahk_class TMsgDialog,, 0
  if (!ErrorLevel)
    send y 
return

+p::send q^{t}{f9}  ; play video in default system player / edit script component
^i::send ^{f8}  ; download images

; Element navigation
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
   || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
!h::
+h::send !{left}  ; go back in history
!l::
+l::send !{right}  ; go forward in history
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
!j::
+j::send !{pgdn}  ; J, ge: go down one element
!k::
+k::send !{pgup}  ; K, gE: go up one element

; Open windows
c::send !c  ; open content window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())
c::send !c  ; refocus
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
   || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
b::
  if (WinExist("ahk_class TBrowser")) {
    WinActivate
  } else {
    ; Sometimes a bug makes that you can't use ^space to open browser in content window
    ; After a while, I found out it's due to my Chinese input method
    ; Fixed in win11?
    ; SetDefaultKeyboard(0x0409)  ; english-US	
    send ^{space}  ; open browser
  }
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() && !Vim.State.g)
o::
  Vim.State.SetMode("Insert")
  send ^o  ; favourites
  Vim.State.BackToNormal := 1
return

f::Vim.SM.ClickMid()  ; click on html component

; Copy
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_ydc_y") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
y::  ; yy: copy current source url
  link := Vim.SM.GetLink()
  if (!link) {
    ToolTip("Link not found.")
  } else {
    Clipboard := link
    ToolTip("Copied " . link)
  }
  Vim.State.SetNormal()
return

e::  ; ye: duplicate current element
  send !d
  Vim.State.SetNormal()
Return

; Plan/tasklist window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingPlan())
s::
  ; ControlClickWinCoord(253, 48)  ; *s*witch plan
  accButton := Acc_Get("Object", "4.1.4.1.4.1.4",, "ahk_id " . WinGet())
  accButton.accDoDefaultAction(2)
  ControlFocus, Edit1
return

b::send !b  ; begin
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingTask())
s::
  ; ControlClickWinCoord(153, 52)  ; *s*witch tasklist
  accButton := Acc_Get("Object", "4.3.4.1.4",, "ahk_id " . WinGet())
  accButton.accDoDefaultAction(2)
  ControlFocus, Edit1
return

; Browsing/editing
#if Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") and (Vim.State.g)
{::Vim.Move.Move("{")
}::Vim.Move.Move("}")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind"))
^f7::
m::
  if (Vim.SM.IsEditingHTML())
    Vim.SM.ClickMid()
  send ^{f7}  ; set read point
  ToolTip("Read point set")
Return

!f7::
`::
  send !{f7}  ; go to read point
  ToolTip("Go to read point")
Return

!m::
^+f7::
  send ^+{f7}  ; clear read point
  ToolTip("Read point cleared")
Return

!+j::send !+{pgdn}  ; go to next sibling
!+k::send !+{pgup}  ; go to previous sibling

#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && !Vim.State.fts && WinActive("ahk_class TElWind"))
^/::  ; visual
^<+/::  ; visual and start from the beginning
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (RShiftState := GetKeyState("RShift") || LShiftState := GetKeyState("LShift")))
?::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind"))
; >+/:  ; caret on the right
; <+/:  ; start from top
!/::  ; followed by a cloze
^!/::  ; followed by a cloze and stays in clozed item
<+!/::  ; followed by a cloze hinter and start from top
+!/::  ; followed by a cloze hinter
^+!/::  ; also cloze hinter but stays in clozed item
/::  ; better search
  CtrlState := InStr(A_ThisHotkey, "^")  ; visual
  ShiftState := InStr(A_ThisHotkey, "+")  ; caret on the right
  if (!InStr(A_ThisHotkey, "?"))
    LShiftState := InStr(A_ThisHotkey, "<+")  ; start from top
  AltState := InStr(A_ThisHotkey, "!")  ; followed by a cloze

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (GetKeyState("alt") || GetKeyState("ctrl")))
CapsLock & /::
  CapsState := InStr(A_ThisHotkey, "CapsLock")
  if (A_ThisHotkey == "CapsLock & /") {
    AltState := GetKeyState("alt")
    CtrlState := GetKeyState("ctrl")
  }
  if (!Vim.SM.IsEditingText()) {
    send ^t
    Vim.SM.WaitTextFocus()  ; make sure CurrFocus is updated    
    if (Vim.SM.IsEditingHTML())
      sleep 50  ; short sleep so the element window won't try to regain focus
    if (!Vim.SM.IsEditingText()) {  ; still found no text
      ToolTip("Text not found.")
      Vim.State.SetNormal()
      return
    }
  } 
  if (Vim.State.StrIsInCurrentVimMode("Visual")) {
    send {right}
    Vim.State.SetNormal()
  }
  if (LShiftState)
    send ^{Home}
  CurrFocus := ControlGetFocus("ahk_class TElWind")
  if (AltState) {
    gui, Search:Add, Text,, &Find text:`n(your search result will be clozed)
  } else if (CtrlState) {
    gui, Search:Add, Text,, &Find text:`n(will go to visual mode after the search)
  } else {
    gui, Search:Add, Text,, &Find text:
  }
  gui, Search:Add, Edit, vUserInput w196, % VimLastSearch
  gui, Search:Add, CheckBox, vWholeWord, Match &whole word only
  gui, Search:Add, Button, default, &Search
  gui, Search:Show,, Search
return

SearchGuiEscape:
SearchGuiClose:
  gui destroy
return

SearchButtonSearch:
  gui submit
  gui destroy
  if (!UserInput)
    Return
  VimLastSearch := UserInput  ; register UserInput into VimLastSearch
  ; Previously, UserInput is stored in Vim.Move.LastSearch, but it turned out this would add 000... in floating numbers
  ; i.e. 3.8 would become 3.80000
  WinActivate, ahk_class TElWind

SMSearchAgain:
  if (InStr(CurrFocus, "TMemo")) {
    send ^+{end}
    if (A_ThisLabel != "SMSearchAgain") {
      if (Vim.State.n)
        Vim.State.n--
      n := Vim.State.n ? Vim.State.n : 0
      Vim.State.n := 0
    }
    if (WholeWord) {
      match := "s)(\b(" . UserInput . ")\b.*?){" . n . "}\K\b" . UserInput . "\b"
    } else {
      match := "s)((" . UserInput . ").*?){" . n . "}\K" . UserInput
    }
    selection := Vim.ParseLineBreaks(clip())
    pos := RegExMatch(selection, match)
    if (pos == 1) {
      if (WholeWord) {
        match := "s)(\b(" . UserInput . ")\b.*?){" . n + 1 . "}\K\b" . UserInput . "\b"
      } else {
        match := "s)(" . UserInput . ".*?){" . n + 1 . "}\K" . UserInput
      }
      pos := RegExMatch(selection, match)
    }
    if (pos) {
      pos--
      send % "{left}{right " . pos . "}"
      InputLen := StrLen(UserInput)
      if (RShiftState) {
        send % "{right " . InputLen . "}"
      } else if (CtrlState || AltState) {
        send % "+{right " . InputLen . "}"
        if (CtrlState) {
          Vim.State.SetMode("Vim_VisualFirst")
        } else if (AltState) {
          send !z
        }
      }
    } else {
      send {left}
      if (A_ThisLabel != "SMSearchAgain") {
        send ^{home}
        ToolTip("Search started from the beginning.")
        goto SMSearchAgain
      }
      ToolTip("Not found.")
      Vim.State.SetNormal()
      Return
    }
  } else {
    if (!Vim.SM.HandleF3(1))
      return
    ; Left spaces need to be trimmed otherwise SM might eat the spaces in text
    UserInput := LTrim(UserInput)
    ControlSetText, TEdit1, % UserInput
    if (WholeWord)
      Control, Check,, TCheckBox2  ; match whole word
    Control, Check,, TCheckBox1  ; match case
    send {enter}
    if (Vim.State.n) {
      send % "{f3 " . Vim.State.n - 1 . "}"
      Vim.State.n := 0
    }
    WinWaitNotActive, ahk_class TMyFindDlg  ; faster than wait for element window to be active
    if (!AltState) {
      if (RShiftState) {
        send {right}  ; put caret on right of searched text
      } else if (CtrlState) {
        Vim.State.SetMode("Vim_VisualFirst")
      } else {  ; all modifier keys are not pressed
        send {left}  ; put caret on left of searched text
      }
    }
    if (!Vim.SM.HandleF3(2))
      return
    if (AltState) {
      if (!CtrlState && !ShiftState && !CapsState) {
        send !z
      } else if (ShiftState) {
        ClozeHinterCtrlState := CtrlState
        WinActivate, ahk_class TElWind
        gosub ClozeHinter
      } else if (CapsState) {
        ClozeHinterCtrlState := CtrlState
        WinActivate, ahk_class TElWind
        gosub ClozeNoBracket
      } else if (CtrlState) {
        gosub ClozeStay
      }
    } else if (!CtrlState) {  ; alt is up and ctrl is up; shift can be up or down
      Vim.Caret.SwitchToSameWindow("ahk_class TElWind")  ; to refresh caret
    } else if (CtrlState) {  ; sometimes SM doesn't focus to anything after the search
      WinActivate, ahk_class TElWind
      if (!ControlGetFocus())
        ControlFocus, % CurrFocus, ahk_class TElWind
    }
  }
return

#if (Vim.IsVimGroup()
  && (Vim.State.IsCurrentVimMode("Vim_Normal") || (Vim.State.StrIsInCurrentVimMode("Visual") && !Vim.State.Surround))
  && !Vim.State.StrIsInCurrentVimMode("Inner")
  && !Vim.State.StrIsInCurrentVimMode("Outer")
  && WinActive("ahk_class TElWind"))
\::
  send ^{f3}
~^f3::
  Vim.State.SetMode("Insert")
  Vim.State.BackToNormal := 2
Return