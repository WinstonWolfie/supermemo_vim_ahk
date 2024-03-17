#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Hotkeys in this file are inspired by Vimium: https://github.com/philc/vimium

; g state on top to have higher priority
; putting those below would make gu stops working (u also triggers scroll up)

; Element window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsBrowsing())
'::Vim.State.SetMode(,, -1,,, -1, 1)  ; leader key
q::SM.EditFirstQuestion()
a::SM.EditFirstAnswer()
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsBrowsing() && !Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsBrowsing() && Vim.State.g)
g::Vim.Move.Move("g")  ; 3gg goes to the 3rd line of entire text

+u::  ; gU: click source button
  KeyWait Shift
  SM.ClickElWindSourceBtn()
  Vim.State.SetMode()
Return

SMGoToLink:
s::  ; gs: go to link
+s::  ; gS: open link in IE
m::  ; gm: go to link in comment
+m::  ; gM: go to link in comment in IE
  Vim.State.SetMode(), Links := [], Success := false
  if (IfIn(A_ThisLabel, "m,+m")) {
    Links := SM.GetLinksInComment()
  } else if (Link := SM.GetLink()) {
    Links.Push(Link)
  }
  if (ObjCount(Links) > 0) {
    for i, Link in Links {
      if (Link) {
        if (IfContains(A_ThisLabel, "+")) {
          ; ShellRun("iexplore.exe " . Link)  ; RIP IE
          Browser.RunInIE(Link)
        } else {
          try ShellRun(Link)
          catch {
            RunDefaultBrowser()
            WinWaitActive, ahk_group Browser
            uiaBrowser := new UIA_Browser("A")
            if (Browser.GetFullTitle() != "new tab")
              uiaBrowser.NewTab()
            uiaBrowser.Navigate(Link)
          }
        }
        Success := true
      }
    }
  }
  if (!Success)
    SetToolTip("Link not found.")
Return

; Element/content window
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents"))
  && SM.IsBrowsing()
  && Vim.State.g)
0::SM.Gohome(), Vim.State.SetMode()  ; g0: go to root element

$::  ; g$: go to last element
  Send !{End}
  Vim.State.SetMode()
Return

; g state, for both browsing and editing
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && Vim.State.g)
c::  ; gc: go to next *c*omponent
  Send ^t
  Vim.State.SetMode()
Return

+c::  ; gC: go to previous *c*omponent
  SM.PrevComp(), Vim.State.SetMode()
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsBrowsing() && !Vim.State.g)
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
  ContLearn := (ContGrade := SM.IsGrading()) ? 0 : SM.IsLearning()
  Item := (ContLearn == 2) ? SM.IsItem() : false
  CurrTitle := WinGetTitle("A")
  SM.GoHome()
  SM.WaitFileLoad()
  if (ContLearn) {
    if ((ContLearn == 2) && Item) {  ; item and just finished grading
      SM.GoBack()
    } else {
      RootTitle := WinWaitTitleRegEx("^Concept: ", "A", 1500)
      SM.WaitStatBarRegEx("^(Priority|Int)")
      SM.Learn(false)  ; CtrlL:=false bc on pending queue it triggers the "learn new material?" window
      SM.WaitFileLoad()
      ; In neural review, going to root element and press learn goes to the next neural review queue
      if (ContLearn == 2) {
        if (WinWaitTitleChange(RootTitle, "A", 1500) != CurrTitle) {
          SM.GoBack()
          SM.WaitFileLoad()
          SM.GoBack()
        }
      }
    }
  } else if (ContGrade) {
    SM.Learn()
    ControlTextWait("TBitBtn3", "Show answer", "A")
    ControlSend, TBitBtn3, {Enter}, A
  } else {
    t := WinGetTitle("A")
    SM.GoBack()
    ; If current element is root element
    if ((CurrTitle == t) && (CurrTitle ~= "^Concept: ")) {
      SM.WaitFileLoad()
      Send !{Right}
    }
  }
return

p::SM.AutoPlay()

+p::  ; play video/sound in default system player / edit script component
  Marker := SM.GetMarkerFromTextArray()
  KeyWait Shift
  SM.EditFirstQuestion()
  Send ^t
  SM.ViewFile()
  GroupAdd, SMF9, ahk_class mpv
  GroupAdd, SMF9, ahk_class TScriptEditor
  WinWaitActive, ahk_group SMF9,, 1.5
  if (!ErrorLevel && (WinGetClass() == "mpv") && Marker) {
    RegExMatch(Marker, "^SMVim time stamp: (.*)", v)
    if (Browser.GetSecFromTime(v1) > 0) {
      Sleep 700
      ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Space}
      WinActivate
    }
  }
return

n::SM.AltN()
+n::SM.AltA()
x::Send {Del}  ; delete element/component
^i::Send ^{f8}  ; download images

!+f::  ; open in IE
^!+f::  ; open in IE and persistent
!f::
+f::
f::
  y := false
#if (Vim.IsVimGroup() && (y := Vim.State.IsCurrentVimMode("Vim_ydc_y")) && SM.IsBrowsing())
f::
v::
c::
  Vim.State.SetNormal()
  if (!hCtrl := ControlGet(,, Control := "Internet Explorer_Server2")) {
    if (!hCtrl := ControlGet(,, Control := "Internet Explorer_Server1"))
      return
  }
  BlockInput, On
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
  UIA := UIA_Interface(), LearningState := SM.IsLearning()
  Caret := IfIn(A_ThisLabel, "v,c")
  ; Some hyperlinks seem to be text type
  ; Type := Caret ? "Text" : "Hyperlink"
  Type := "Text"
  if (!aHints := CreateHintsArray(Control, hCtrl, Type, Caret)) {
    BlockInput, Off
    SetToolTip("Text too long.")
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
    SetToolTip("No link found.")
  }
  BlockInput, Off
return

CreateHints(HintsArray, HintStrings) {
  for i, v in HintsArray
    ToolTipG(HintStrings[i], v.x, v.y, i,, "yellow", "black",, "S")
  global LastHintCount := i
}

CreateHintsArray(Control, hCtrl, Type, Caret, Limit:=1000) {
  global Vim, UIA
  if (Caret)
    SM.ClickMid(Control)
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
  && (SM.IsBrowsing()
   || WinActive("ahk_class TContents")
   || WinActive("ahk_class TBrowser")))
+x::Send ^+{Enter}  ; Done!


; Element/content window
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents"))
  && SM.IsBrowsing()
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
  && (SM.IsBrowsing()
   || (WinActive("ahk_class TContents") && SM.IsNavigatingContentWind())))
!h::
+h::  ; go back in history
!l::
+l::  ; go forward in history
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsBrowsing())
!j::
+j::  ; J, ge: go down one element
!k::
+k::  ; K, gE: go up one element
  n := Vim.State.GetN()
  if (n > 1)
    SM.PrepStatBar(1)
  loop % n {
    if (A_ThisLabel ~= "h$") {
      SM.GoBack()
    } else if (A_ThisLabel ~= "l$") {
      Send !{Right}
    } else if (A_ThisLabel ~= "j$|^\+e$") {
      Send !{pgdn}
    } else if (A_ThisLabel ~= "k$|^e$") {
      Send !{pgup}
    } else if (A_ThisLabel ~= "u$") {
      Send ^{Up}
    }
    if (n > 1)
      SM.WaitFileLoad(false)
  }
  if (n > 1)
    SM.PrepStatBar(2)
  if (Vim.State.g)
    Vim.State.SetMode()
return

; Open windows
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (SM.IsBrowsing()
   || (WinActive("ahk_class TContents") && SM.IsNavigatingContentWind())))
; c::Send !c  ; open content window  ; taken in sm19
b::
  if (WinExist("ahk_pid " . WinGet("PID", "A") . " ahk_class TBrowser")) {
    WinActivate
  } else {
    SM.OpenBrowser()
  }
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TBrowser"))
c::
  WinActivate, ahk_class TElWind
  Send !c
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
^o::
  KeyWait Ctrl
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsBrowsing() && !Vim.State.g)
o::  ; favourites
  BlockInput, On
  SetDefaultKeyboard(0x0409)  ; English-US
  l := SM.IsLearning()
  if (l == 1) {
    Send {Alt Down}
    PostMessage, 0x0104, 0x24, 1<<29,, ahk_class TElWind  ; home key
    PostMessage, 0x0105, 0x24, 1<<29,, ahk_class TElWind
    Send {Alt Up}
  } else if (l == 2) {
    SM.Reload()
  }
  if (l)
    SM.WaitFileLoad()
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1, SM.PostMsg(3)
  BlockInput, Off
return

t::SM.ClickMid()  ; *t*ext

; Copy
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsBrowsing())
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_ydc_y") && SM.IsBrowsing())
y::  ; yy: copy current source url
  if (!Link := SM.GetLink()) {
    SetToolTip("Link not found.")
  } else {
    SetToolTip("Copied " . Clipboard := Link)
  }
  Vim.State.SetNormal()
return

e::  ; ye: duplicate current element
  SM.Duplicate(), Vim.State.SetNormal()
Return

; Plan/tasklist window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsNavigatingPlan())
s::
  Acc_Get("Object", "4.1.4.1.4.1.4",, "A").accDoDefaultAction(2)
  ControlFocus, Edit1, A
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1
return

b::Send !b  ; begin
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsNavigatingTask())
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
  if (SM.IsEditingHTML())
    SM.ClickMid()
  Send ^{f7}  ; set read point
  SetToolTip("Read point set")
Return

!f7::
`::
  Send !{f7}  ; go to read point
  SetToolTip("Going to read point")
Return

!m::
^+f7::
  Send ^+{f7}  ; clear read point
  SetToolTip("Read point cleared")
Return

!+j::
!+k::
  n := Vim.State.GetN()
  if (n > 1)
    SM.PrepStatBar(1)
  loop % n {
    if (A_ThisLabel == "!+j") {
      Send !+{PgDn}  ; go to next sibling
    } else if (A_ThisLabel == "!+k") {
      Send !+{PgUp}  ; go to previous sibling
    }
    if (n > 1)
      SM.WaitFileLoad(false)
  }
  if (n > 1)
    SM.PrepStatBar(2)
return

#if (Vim.IsVimGroup()
  && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual"))
  && !Vim.State.StrIsInCurrentVimMode("Inner,Outer")
  && !Vim.State.Surround && !Vim.State.fts
  && WinActive("ahk_class TElWind"))
\::
  SM.CtrlF3()
~^f3::Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 2, SMCtrlF3 := true

#if (Vim.IsVimGroup() && SMCtrlF3 && WinActive("ahk_class TInputDlg"))
Enter::
  VimLastSearch := ControlGetText("TMemo1"), SMCtrlF3 := false
  Vim.State.BackToNormal--
  Send {Enter}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class TMyFindDlg"))
Enter::
  VimLastSearch := ControlGetText("TEdit1")
  Send {Enter}
return
