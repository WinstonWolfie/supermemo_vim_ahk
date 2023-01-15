; Hotkeys in this file are inspired by Vimium: https://github.com/philc/vimium

; g state on top to have higher priority
; putting those below would make gu stops working (u also triggers scroll up)

; Element window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing())
'::Vim.State.SetMode("",, -1,,, -1, 1)  ; leader key
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing() && !Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing() && Vim.State.g)
g::Vim.Move.Move("g")  ; 3gg goes to the 3rd line of entire text

+u::  ; gU: click source button
  Vim.SM.ClickElWindSourceBtn()
  Vim.State.SetMode()
Return

+s::  ; gS: open link in IE
SMGoToLink:
s::  ; gs: go to link
  Vim.State.SetMode()
  if (link := Vim.SM.GetLink()) {
    if (IfContains(A_ThisHotkey, "+")) {
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

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing() && !Vim.State.g)
; Scrolling
h::Vim.Move.Repeat("h")
l::Vim.Move.Repeat("l")
^e::
j::Vim.Move.Repeat("j")
^y::
k::Vim.Move.Repeat("k")
d::Vim.Move.Repeat("^d")
u::Vim.Move.Repeat("^u")
0::Vim.Move.Move("0")
$::Vim.Move.Move("$")
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
  ContinueGrading := Vim.SM.IsGrading()
  ContLearn := ContinueGrading ? 0 : Vim.SM.IsLearning()
  CurrTitle := WinGetTitle()
  send !{home}
  if (ContLearn) {
    Vim.SM.Learn()
    Vim.SM.WaitFileLoad()
    ; When r is pressed, the review score in an item is submitted,
    ; thus refreshing and learning takes SM to a new element
    if ((ContLearn == 2) && (CurrTitle != WinGetTitle()))
      send !{left 2}
  } else if (ContinueGrading) {
    Vim.SM.Learn()
    ControlTextWait("TBitBtn3", "Show answer")
    ControlSend, TBitBtn3, {enter}
  } else {
    text := Vim.SM.WaitFileLoad()
    while (WinExist("ahk_class Internet Explorer_TridentDlgFrame"))  ; sometimes could happen on YT videos
      WinClose
    ; If current element is home element
    if ((CurrTitle ~= "^Concept: ") && (CurrTitle == WinGetTitle())) {
      send !{left}
      Vim.SM.WaitFileLoad()
      send !{right}
    } else {
      send !{left}
    }
  }
return

p::
  Vim.SM.AutoPlay()
  WinWaitActive, ahk_class TMsgDialog,, 0
  if (!ErrorLevel)
    send {text}y 
return

+p::send q^{t}{f9}  ; play video in default system player / edit script component

n::Vim.SM.AltN()  ; = alt+N
+n::Vim.SM.PostMsg(95)  ; = alt+A
x::send {del}  ; delete element/component

^i::send ^{f8}  ; download images

!+f::  ; open in IE
^!+f::  ; open in IE and persistent
!f::
+f::
f::
  KeyWait Alt
  KeyWait Shift
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_ydc_y") && Vim.SM.IsBrowsing())
f::
v::
c::
  if (Vim.State.IsCurrentVimMode("Vim_ydc_y") && (A_ThisHotkey == "f")) {
    HinterMode := "YankLink"
  } else if (IfIn(A_ThisHotkey, "^!+f,!f")) {
    HinterMode := "Persistent"
  } else if (A_ThisHotkey == "v") {
    HinterMode := "Visual"
  } else if (A_ThisHotkey == "c") {
    HinterMode := "Normal"
  } else if (A_ThisHotkey == "+f") {
    HinterMode := "OpenLinkInNew"
  } else {
    HinterMode := "OpenLink"
    OpenInIE := IfContains(A_ThisHotkey, "!+f")
  }
  UIA := UIA_Interface()
  Control := "Internet Explorer_Server2"
  LearningState := Vim.SM.IsLearning()
  if (!hCtrl := ControlGet(,, Control)) {
    Control := "Internet Explorer_Server1"
    if (!hCtrl := ControlGet(,, Control))
      return
  }
  Caret := IfIn(A_ThisHotkey, "v,c")
  Type := Caret ? "Text" : "Hyperlink"
  aHints := CreateHintsArray(Control, hCtrl, Type, Caret)
  if ((Control == "Internet Explorer_Server2") && (LearningState != 1)) {  ; so answer isn't revealed
    Control := "Internet Explorer_Server1"
    if (hCtrl := ControlGet(,, Control)) {
      a := CreateHintsArray(Control, hCtrl, Type, Caret)
      aHints.Push(a*)
    }
  }
  if (!n := ObjCount(aHints))
    return
  Vim.State.SetMode("KeyListener")
  aHintStrings := hintStrings(n)
  CreateHints(aHints, aHintStrings)
return

CreateHintsArray(Control, hCtrl, Type, Caret) {
  global Vim, UIA
  if (Caret)
    Vim.SM.ClickMid(Control)
  el := UIA.ElementFromHandle(hCtrl)
  auiaHints := el.FindAllByType(Type)
  aHints := [], i := 0
  for k, v in auiaHints {
    if (((v.CurrentBoundingRectangle.l == 0) && (v.CurrentBoundingRectangle.t == 0))  ; text not shown
     || (!Caret && !v.CurrentValue))  ; some hyperlinks don't have value
      continue
    pos := v.GetCurrentPos("screen"), i++
    if (Caret) {
      aHints[i] := {x:pos.x, y:pos.y, Control:Control}
    } else {
      aHints[i] := {x:pos.x, y:pos.y, Link:v.CurrentValue}
    }
  }
  return aHints
}

#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && ((Vim.SM.IsBrowsing())
   || WinActive("ahk_class TContents")
   || WinActive("ahk_class TBrowser")))
+x::send ^+{enter}  ; Done!

; Element navigation
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && ((Vim.SM.IsBrowsing())
   || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
!h::
+h::send !{left}  ; go back in history
!l::
+l::send !{right}  ; go forward in history
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing())
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
  && ((Vim.SM.IsBrowsing())
   || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
b::
  if (WinExist("ahk_class TBrowser")) {
    WinActivate
  } else {
    ; Sometimes a bug makes that you can't use ^space to open browser in content window
    ; After a while, I found out it's due to my Chinese input method
    ; Fixed in win11?
    ; SetDefaultKeyboard(0x0409)  ; English-US
    send ^{space}  ; open browser
  }
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^o::
  KeyWait ctrl
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing() && !Vim.State.g)
o::
  BlockInput, on
  SetDefaultKeyboard(0x0409)  ; English-US
  l := Vim.SM.IsLearning()
  if (l == 1) {
    send !{home}
  } else if (l == 2) {
    Vim.SM.Reload()
    Vim.SM.WaitFileLoad()
  }
  Vim.State.SetMode("Insert")
  Vim.SM.PostMsg(3)  ; favourites
  BlockInput, off
  Vim.State.BackToNormal := 1
return

t::Vim.SM.ClickMid()  ; *t*ext

; Copy
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing())
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_ydc_y") && Vim.SM.IsBrowsing())
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
  ; ControlClickWinCoordDPIAdjusted(253, 48)  ; *s*witch plan
  accButton := Acc_Get("Object", "4.1.4.1.4.1.4",, "ahk_id " . WinGet())
  accButton.accDoDefaultAction(2)
  ControlFocus, Edit1
return

b::send !b  ; begin
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingTask())
s::
  ; ControlClickWinCoordDPIAdjusted(153, 52)  ; *s*witch tasklist
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

#if (Vim.IsVimGroup()
  && (Vim.State.IsCurrentVimMode("Vim_Normal") || (Vim.State.StrIsInCurrentVimMode("Visual") && !Vim.State.Surround && !Vim.State.fts))
  && !Vim.State.StrIsInCurrentVimMode("Inner")
  && !Vim.State.StrIsInCurrentVimMode("Outer")
  && WinActive("ahk_class TElWind"))
\::
  Vim.SM.PostMsg(151)
~^f3::
  Vim.State.SetMode("Insert")
  Vim.State.BackToNormal := 2
Return