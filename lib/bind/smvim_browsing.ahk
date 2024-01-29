#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Hotkeys in this file are inspired by Vimium: https://github.com/philc/vimium

; g state on top to have higher priority
; putting those below would make gu stops working (u also triggers scroll up)

; Element window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing())
'::Vim.State.SetMode("",, -1,,, -1, 1)  ; leader key
q::Vim.SM.EditFirstQuestion()
a::Vim.SM.EditFirstAnswer()
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing() && !Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing() && Vim.State.g)
g::Vim.Move.Move("g")  ; 3gg goes to the 3rd line of entire text

+u::  ; gU: click source button
  KeyWait Shift
  Vim.SM.ClickElWindSourceBtn()
  Vim.State.SetMode()
Return

+s::  ; gS: open link in IE
SMGoToLink:
s::  ; gs: go to link
m::  ; gm: go to link in comment
+m::  ; gM: go to link in comment in IE
  Vim.State.SetMode()
  if (IfIn(A_ThisLabel, "m,+m")) {
    link := Vim.SM.GetLinkInComment()
  } else {
    link := Vim.SM.GetLink()
  }
  if (link) {
    if (IfContains(A_ThisLabel, "+")) {
      ; ShellRun("iexplore.exe " . link)  ; RIP IE
      Vim.Browser.RunInIE(link)
    } else {
      try ShellRun(link)
      catch {
        RunDefaultBrowser()
        WinWaitActive, ahk_group Browser
        uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
        if (Vim.Browser.GetFullTitle() != "new tab")
          uiaBrowser.NewTab()
        uiaBrowser.Navigate(link)
      }
    }
  } else {
    ToolTip("No link found.")
  }
Return

; Element/content window
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents"))
  && Vim.SM.IsBrowsing()
  && Vim.State.g)
0::Vim.SM.Gohome(), Vim.State.SetMode()  ; g0: go to root element

$::  ; g$: go to last element
  send !{end}
  Vim.State.SetMode()
Return

; g state, for both browsing and editing
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && Vim.State.g)
c::  ; gc: go to next *c*omponent
  send ^t
  Vim.State.SetMode()
Return

+c::  ; gC: go to previous *c*omponent
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
  ContLearn := (ContinueGrading := Vim.SM.IsGrading()) ? 0 : Vim.SM.IsLearning()
  Item := (ContLearn == 2) ? Vim.SM.IsItem() : false
  CurrTitle := WinGetTitle("A")
  Vim.SM.GoHome()
  Vim.SM.WaitFileLoad()
  if (ContLearn) {
    if ((ContLearn == 2) && Item) {  ; item and just finished grading
      Vim.SM.GoBack()
    } else {
      RootTitle := WinGetTitle("A")
      Vim.SM.Learn(false)  ; false bc on pending queue ^l triggers the "learn new material?" window
      ; In neural review, going to root element and press learn goes to the next neural review queue
      if (ContLearn == 2) {
        if (WinWaitTitleChange(RootTitle, "A", 1500) != CurrTitle) {
          Vim.SM.WaitFileLoad()
          Vim.SM.GoBack()
          Vim.SM.WaitFileLoad()
          Vim.SM.GoBack()
        }
      }
    }
  } else if (ContinueGrading) {
    Vim.SM.Learn()
    ControlTextWait("TBitBtn3", "Show answer", "A")
    ControlSend, TBitBtn3, {enter}, A
  } else {
    while (WinExist("ahk_class Internet Explorer_TridentDlgFrame"))  ; sometimes could happen on YT videos
      WinClose
    t := WinGetTitle("A")
    Vim.SM.GoBack()
    ; If current element is root element
    if ((CurrTitle == t) && (CurrTitle ~= "^Concept: ")) {
      Vim.SM.WaitFileLoad()
      send !{right}
    }
  }
return

p::
  Vim.SM.AutoPlay()
  WinWaitActive, ahk_class TMsgDialog,, 0
  if (!ErrorLevel)
    send {text}y 
return

+p::  ; play video/sound in default system player / edit script component
  Vim.SM.EditFirstQuestion()
  send ^t!{f12}fv
  WinWaitActive, ahk_class mpv,, 1.5
  if (!ErrorLevel) {
    RegExMatch(Vim.SM.GetHTMLMarker(), "^SMVim time stamp: (.*)", v)
    if (v1 ~= "(([1-9]){1,2}:)?([1-9]){1,2}:([1-9]){1,2}") {
      sleep 700
      ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{space}, ahk_class mpv
    }
  }
return

n::Vim.SM.AltN()
+n::Vim.SM.AltA()
x::send {del}  ; delete element/component

^i::send ^{f8}  ; download images

!+f::  ; open in IE
^!+f::  ; open in IE and persistent
!f::
+f::
f::
  y := false
#if (Vim.IsVimGroup() && (y := Vim.State.IsCurrentVimMode("Vim_ydc_y")) && Vim.SM.IsBrowsing())
f::
v::
c::
  Vim.State.SetNormal()
  if (!hCtrl := ControlGet(,, Control := "Internet Explorer_Server2")) {
    if (!hCtrl := ControlGet(,, Control := "Internet Explorer_Server1"))
      return
  }
  BlockInput, on
  HinterMode := "OpenLink", OpenInIE := IfContains(A_ThisLabel, "!+f")
  if (y && (A_ThisLabel == "f")) {
    HinterMode := "YankLink"
  } else if (IfIn(A_ThisLabel, "^!+f,!f")) {
    HinterMode := "Persistent"
  } else if (y && (A_ThisLabel == "v")) {
    HinterMode := "Visual"
  } else if (y && (A_ThisLabel == "c")) {
    HinterMode := "Normal"
  } else if (A_ThisLabel == "+f") {
    HinterMode := "OpenLinkInNew"
  }
  UIA := UIA_Interface(), LearningState := Vim.SM.IsLearning()
  Caret := IfIn(A_ThisLabel, "v,c")
  ; Some hyperlinks seem to be text type
  ; Type := Caret ? "Text" : "Hyperlink"
  Type := "Text"
  if (!aHints := CreateHintsArray(Control, hCtrl, Type, Caret)) {
    BlockInput, off
    ToolTip("Text too long.")
    return
  }    
  if ((Control == "Internet Explorer_Server2") && (LearningState != 1)) {  ; so answer isn't revealed
    if (hCtrl := ControlGet(,, Control := "Internet Explorer_Server1"))
      aHints.Push(CreateHintsArray(Control, hCtrl, Type, Caret)*)
  }
  if (n := ObjCount(aHints)) {
    Critical  ; adding critical increases performance
    Vim.State.SetMode("KeyListener")
    ; aHintStrings is later used in key listener
    CreateHints(aHints, aHintStrings := hintStrings(n))
  } else {
    ToolTip("No link found.")
  }
  BlockInput, off
return

CreateHintsArray(Control, hCtrl, Type, Caret, Limit:=1000) {
  global Vim, UIA
  if (Caret)
    Vim.SM.ClickMid(Control)
  el := UIA.ElementFromHandle(hCtrl), auiaHints := el.FindAllByType(Type)
  if (ObjCount(auiaHints) > Limit)
    return
  aHints := [], HintsIndex := 0
  for i, v in auiaHints {
    if (v.CurrentBoundingRectangle.l && (Caret || v.CurrentValue)) {  ; some hyperlinks don't have value
      HintsIndex++
      if (Caret) {
        aHints[HintsIndex] := {x:v.CurrentBoundingRectangle.l, y:v.CurrentBoundingRectangle.t, Control:Control}
      } else {
        aHints[HintsIndex] := {x:v.CurrentBoundingRectangle.l, y:v.CurrentBoundingRectangle.t, Link:v.CurrentValue}
      }
    }
  }
  return aHints
}

#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (Vim.SM.IsBrowsing()
   || WinActive("ahk_class TContents")
   || WinActive("ahk_class TBrowser")))
+x::send ^+{enter}  ; Done!


; Element/content window
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents"))
  && Vim.SM.IsBrowsing()
  && Vim.State.g)
+e::  ; K, gE: go up *e*lements
e::  ; J, ge: go down *e*lements
u::  ; gu: go to parent
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (WinActive("ahk_class TElWind")
   || WinActive("ahk_class TContents")
   || WinActive("ahk_class TBrowser")))
!h::
!l::
!j::
!k::
!u::
; Element navigation
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (Vim.SM.IsBrowsing()
   || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
!h::
+h::  ; go back in history
!l::
+l::  ; go forward in history
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing())
!j::
+j::  ; J, ge: go down one element
!k::
+k::  ; K, gE: go up one element
  n := Vim.State.GetN()
  if (n > 1)
    Vim.SM.PrepareStatBar(1)
  loop % n {
    if (A_ThisLabel ~= "h$") {
      Vim.SM.GoBack()
    } else if (A_ThisLabel ~= "l$") {
      send !{right}
    } else if (A_ThisLabel ~= "j$|^\+e$") {
      send !{pgdn}
    } else if (A_ThisLabel ~= "k$|^e$") {
      send !{pgup}
    } else if (A_ThisLabel ~= "u$") {
      send ^{up}
    }
    if (n > 1)
      Vim.SM.WaitFileLoad(,, false)
  }
  if (n > 1)
    Vim.SM.PrepareStatBar(2)
  if (Vim.State.g)
    Vim.State.SetMode()
return

; Open windows
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (Vim.SM.IsBrowsing()
   || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
; c::send !c  ; open content window  ; taken in sm19
b::
  if (WinExist("ahk_pid " . WinGet("PID", "A") . " ahk_class TBrowser")) {
    WinActivate
  } else {
    Vim.SM.OpenBrowser()
  }
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TBrowser"))
c::
  WinActivate, ahk_class TElWind
  send !c
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^o::
  KeyWait Ctrl
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing() && !Vim.State.g)
o::  ; favoourites
  BlockInput, on
  SetDefaultKeyboard(0x0409)  ; English-US
  l := Vim.SM.IsLearning()
  if (l == 1) {
    send {Alt Down}
    PostMessage, 0x0104, 0x24, 1<<29,, ahk_class TElWind  ; home key
    PostMessage, 0x0105, 0x24, 1<<29,, ahk_class TElWind
    send {Alt Up}
  } else if (l == 2) {
    Vim.SM.Reload(, true)
  }
  if (l)
    Vim.SM.WaitFileLoad()
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1, Vim.SM.PostMsg(3)
  BlockInput, off
return

t::Vim.SM.ClickMid()  ; *t*ext

; Copy
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing())
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_ydc_y") && Vim.SM.IsBrowsing())
y::  ; yy: copy current source url
  if (!link := Vim.SM.GetLink()) {
    ToolTip("Link not found.")
  } else {
    ToolTip("Copied " . Clipboard := link)
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
  Acc_Get("Object", "4.1.4.1.4.1.4",, "A").accDoDefaultAction(2)
  ControlFocus, Edit1, A
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1
return

b::send !b  ; begin
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingTask())
s::
  Acc_Get("Object", "4.3.4.1.4",, "A").accDoDefaultAction(2)
  ControlFocus, Edit1, A
return

; Browsing/editing
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && Vim.State.g)
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
  ToolTip("Going to read point")
Return

!m::
^+f7::
  send ^+{f7}  ; clear read point
  ToolTip("Read point cleared")
Return

!+j::
!+k::
  n := Vim.State.GetN()
  if (n > 1)
    Vim.SM.PrepareStatBar(1)
  loop % n {
    if (A_ThisLabel == "!+j") {
      send !+{PgDn}  ; go to next sibling
    } else if (A_ThisLabel == "!+k") {
      send !+{PgUp}  ; go to previous sibling
    }
    if (n > 1)
      Vim.SM.WaitFileLoad(,, false)
  }
  if (n > 1)
    Vim.SM.PrepareStatBar(2)
return

#if (Vim.IsVimGroup()
  && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual"))
  && !Vim.State.StrIsInCurrentVimMode("Inner,Outer")
  && !Vim.State.Surround && !Vim.State.fts
  && WinActive("ahk_class TElWind"))
\::
  if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
    Vim.SM.PostMsg(150)
  } else {
    Vim.SM.PostMsg(151)
  }
~^f3::Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 2, SMCtrlF3 := true

#if (Vim.IsVimGroup() && SMCtrlF3 && WinActive("ahk_class TInputDlg"))
enter::
  VimLastSearch := ControlGetText("TMemo1"), SMCtrlF3 := false
  send {enter}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMyFindDlg"))
enter::
  VimLastSearch := ControlGetText("TEdit1")
  send {enter}
return
