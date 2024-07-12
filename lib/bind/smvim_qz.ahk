#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
ExtractStay:
#if (Vim.IsVimGroup() && SM.IsEditingText())
^!x::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && SM.IsEditingText())
^q::  ; extract (*q*uote)
  Send !x
  SM.WaitExtractProcessing()
  SM.GoBack(), Vim.State.SetMode("Vim_Normal")
return

+q::  ; extract with priority
  Send !+x
  Vim.State.SetMode("Vim_Normal")
return

z::SM.Cloze(), Vim.State.SetMode("Vim_Normal")

SMClozeStay:
#if (Vim.IsVimGroup() && SM.IsEditingText())
^!z::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && SM.IsEditingText())
^z::
  SM.Cloze(), Vim.State.SetMode("Vim_Normal")
  if (SM.WaitClozeProcessing() != -1)  ; warning on trying to cloze on items
    SM.GoBack()
Return

SMClozeHinter:
#if (Vim.IsVimGroup() && SM.IsEditingText())
^!+z::
!+z::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && SM.IsEditingText())
^+z::
+z::  ; cloze hinter
  if (ClozeHinterCtrlState && (A_ThisLabel == "SMClozeHinter")) {  ; from cloze hinter label and ctrl is pressed
    CtrlState := 1, ClozeHintertrlState := 0
  } else {
    CtrlState := IfContains(A_ThisLabel, "^")
  }
  InitText := ((A_ThisLabel == "SMClozeHinter") && InitText) ? InitText : Copy()
  if (!InitText)
    return
  CurrFocus := ControlGetFocus("ahk_class TElWind"), Inside := true
  if (InitText ~= "i)^(more|less)$") {
    InitText := "more/less"
  } else if (InitText ~= "i)^(faster|slower)$") {
    InitText := "faster/slower"
  } else if (InitText ~= "i)^(fast|slow)$") {
    InitText := "fast/slow"
  } else if (InitText ~= "i)^(higher|lower)$") {
    InitText := "higher/lower"
  } else if (InitText ~= "i)^(high|low)$") {
    InitText := "high/low"
  } else if (InitText ~= "i)^(increased|decreased)$") {
    InitText := "increased/decreased"
  } else if (InitText ~= "i)^(increases|decreases)$") {
    InitText := "increases/decreases"
  } else if (InitText ~= "i)^(increase|decrease)$") {
    InitText := "increase/decrease"
  } else if (InitText = "reduced") {
    InitText := "increased/reduced"
  } else if (InitText = "reduces") {
    InitText := "increases/reduces"
  } else if (InitText = "reduce") {
    InitText := "increase/reduce"
  } else if (InitText ~= "i)^(positive|negative)$") {
    InitText := "positive/negative"
  } else if (InitText ~= "i)^(acid|alkaloid)$") {
    InitText := "acid/alkaloid"
  } else if (InitText ~= "i)^(acidic|alkaline)$") {
    InitText := "acidic/alkaline"
  } else if (InitText ~= "i)^(same|different)$") {
    InitText := "same/different"
  } else if (InitText ~= "i)^(inside|outside)$") {
    InitText := "inside/outside"
  } else if (InitText ~= "i)^(monetary|fiscal)$") {
    InitText := "monetary/fiscal"
  } else if (InitText ~= "i)^(activator|inhibitor)$") {
    InitText := "activator/inhibitor"
  } else if (InitText = "elevate") {
    InitText := "elevate/lower"
  } else if (InitText ~= "i)^(elevates|lowers)$") {
    InitText := "elevates/lowers"
  } else if (InitText ~= "i)^(elevated|lowered)$") {
    InitText := "elevated/lowered"
  } else if (InitText = "raise") {
    InitText := "raise/lower"
  } else if (InitText = "raises") {
    InitText := "raises/lowers"
  } else if (InitText = "raised") {
    InitText := "raised/lowered"
  } else if (InitText ~= "i)^(activate|inhibit)$") {
    InitText := "activate/inhibit"
  } else if (InitText ~= "i)^(activates|inhibits)$") {
    InitText := "activates/inhibits"
  } else if (InitText ~= "i)^(greater|smaller)$") {
    InitText := "greater/smaller"
  } else if (InitText ~= "i)^(male|female)$") {
    InitText := "male/female"
  } else {
    Inside := false
  }
  Gui, SMClozeHinter:Add, Text,, &Hint:
  Gui, SMClozeHinter:Add, Edit, vHint w196 r1 -WantReturn, % InitText
  Gui, SMClozeHinter:Add, CheckBox, % "vInside " . (Inside ? "checked" : ""), &Inside square brackets
  Gui, SMClozeHinter:Add, CheckBox, vFullWidthParentheses, Use &fullwidth parentheses
  Gui, SMClozeHinter:Add, CheckBox, % "vCtrlState " . (CtrlState ? "checked" : ""), &Stay in clozed item
  Gui, SMClozeHinter:Add, CheckBox, vDone, &Done!
  Gui, SMClozeHinter:Add, Button, default, Clo&ze
  Gui, SMClozeHinter:Show,, Cloze Hinter
Return

SMClozeHinterGuiEscape:
SMClozeHinterGuiClose:
  Gui, Destroy
  Vim.State.SetMode("Vim_Normal")
return

SMClozeHinterButtonCloze:
  Gui, Submit
  Gui, Destroy
  WinActivate, ahk_class TElWind

SMClozeNoBracket:
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && (CtrlState := GetKeyState("ctrl")) && SM.IsEditingText())
CapsLock & z::  ; delete [...]
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Visual") && SM.IsEditingText())
CapsLock & z::  ; delete [...]
  if (ClozeNoBracket := IfIn(A_ThisLabel, "SMClozeNoBracket,CapsLock & z"))
    Done := false
  TopicTitle := WinGetTitle("ahk_class TElWind")
  if ((A_ThisLabel == "SMClozeNoBracket") && ClozeNoBracketCtrlState)
    CtrlState := 1, ClozeNoBracketCtrlState := 0
  if (!ClozeNoBracket && !Inside && Hint && IfContains(Hint, "/")) {
    Inside := (MsgBox(3,, "Your hint has a slash. Press yes to make it inside square brackets.") = "Yes")
    WinWaitActive, ahk_class TElWind
  }
  KeyWait Capslock
  KeyWait Alt
  KeyWait Enter
  SM.Cloze(), Vim.State.SetMode("Vim_Normal")
  if (!ClozeNoBracket && !Hint && !CtrlState)  ; entered nothing
    return

  SetToolTip("Cloze processing...")
  if (SM.WaitClozeProcessing() == -1)  ; warning on trying to cloze on items
    return

  if (Done) {
    Send ^+{Enter}
    WinWaitActive, ahk_class TMsgDialog  ; "Do you want to remove all element contents from the collection?"
    Send {Enter}
    WinWaitActive, ahk_class TMsgDialog  ; wait for "Delete element?"
    Send {Enter}
    WinWaitClose
    WinWaitActive, ahk_class TElWind
    CtrlState := true  ; stay in item
  }

  SM.GoBack()
  if (!ClozeNoBracket && !Hint && CtrlState)  ; entered nothing
    return
  WinWaitTitleChange(TopicTitle, "ahk_class TElWind", 500)
  SM.WaitFileLoad()
  if (!SM.SpamQ(, 10000))
    return

  if (!ClozeNoBracket && Inside) {
    Cloze := "[" . Hint . "]"
  } else {
    if (FullWidthParentheses) {
      Cloze := "[...]（" . Hint . "）"
    } else {
      Cloze := "[...](" . Hint . ")"
    }
  }

  loop {  ; sometimes the question is not the first component
    if (SM.IsEditingPlainText()) {
      Send ^a
      ClipSaved := ClipboardAll
      if (ClozeNoBracket) {
        Clip(RegExReplace(Copy(false), "\s?\[\.\.\.\]"),, false)
      } else {
        Clip(StrReplace(Copy(false), "[...]", Cloze),, false)
      }
      Clipboard := ClipSaved
      Break
    } else if (SM.IsEditingHTML()) {
      if (HTML := FileRead(HTMLPath := SM.LoopForFilePath())) {
        Critical
        SM.EmptyHTMLComp()
        WinWaitActive, ahk_class TElWind
        SM.WaitTextFocus()
        x := A_CaretX, y := A_CaretY
        Send ^{Home}
        WaitCaretMove(x, y)
        if (ClozeNoBracket) {
          HTML := RegExReplace(HTML, "\s?<SPAN class=cloze>\[\.\.\.\]<\/SPAN>")
        } else {
          HTML := StrReplace(HTML, "<SPAN class=cloze>[...]</SPAN>"
                                 , "<SPAN class=cloze>" . Cloze . "</SPAN>")
        }
        Clip(HTML,,, "sm")
        Break
      } else {
        Send ^t
      }
    }
  }

  Send % CtrlState ? "{Esc}" : "!{Right}"
  WinWaitActive, ahk_class TChoicesDlg,, 0
  if (!ErrorLevel)
    WinClose
return

; Editing text only
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingText())
q::Vim.State.SetMode("SMVim_Extract", 0, -1, 0,,, -1)
z::Vim.State.SetMode("SMVim_Cloze", 0, -1, 0,,, -1)
^q::Vim.State.SetMode("SMVim_ExtractStay", 0, -1, 0,,, -1)
^z::Vim.State.SetMode("SMVim_ClozeStay", 0, -1, 0,,, -1)
+q::Vim.State.SetMode("SMVim_ExtractPriority", 0, -1, 0,,, -1)
+z::
^+z::
  Vim.State.SetMode("SMVim_ClozeHinter", 0, -1, 0,,, -1)
  ClozeHinterCtrlState := IfContains(A_ThisLabel, "^")
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingText() && ((ClozeNoBracketCtrlState := GetKeyState("ctrl")) || true))
CapsLock & z::Vim.State.SetMode("SMVim_ClozeNoBracket", 0, -1, 0,,, -1)

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingHTML())
^h::Vim.State.SetMode("SMVim_ParseHTML", 0, -1, 0,,, -1)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMVim_ParseHTML") && SM.IsEditingHTML())
^h::Vim.Move.YDCMove()

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingText() && Vim.State.g)
!t::Vim.State.SetMode("SMVim_AltT", 0, -1, 0,,, -1)
!q::Vim.State.SetMode("SMAltQ_Command", 0, -1, 0,,, -1)

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMVim_AltT") && SM.IsEditingText())
!t::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_Extract") && SM.IsEditingText())
q::
^q::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_Cloze") && SM.IsEditingText())
z::
^z::
+z::
^+z::
  KeyWait Shift
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMVim_ClozeNoBracket") && SM.IsEditingText() && ((ClozeNoBracketCtrlState := GetKeyState("ctrl")) || true))
CapsLock & z::Vim.Move.YDCMove()

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMAltQ_Command") && SM.IsEditingText())
!q::SMAltQYdcMove := true

a::
b::
c::
d::
e::
f::
g::
h::
i::
j::
k::
l::
m::
n::
o::
p::
q::
r::
s::
t::
u::
v::
w::
x::
y::
z::
+a::
+b::
+c::
+d::
+e::
+f::
+g::
+h::
+i::
+j::
+k::
+l::
+m::
+n::
+o::
+p::
+q::
+r::
+s::
+t::
+u::
+v::
+w::
+x::
+y::
+z::
0::
1::
2::
3::
4::
5::
6::
7::
8::
9::
`::
~::
!::
?::
@::
#::
$::
%::
^::
&::
*::
(::
)::
-::
_::
=::
+::
[::
{::
]::
}::
/::
\::
|::
:::
`;::
'::
"::
,::
<::
.::
>::
Space::
  Vim.Move.KeyAfterSMAltQ := A_ThisLabel
  if (SMAltQYdcMove) {
    Vim.Move.YDCMove(), SMAltQYdcMove := false
  } else {
    Vim.State.SetMode("SMVim_AltQ", 0, -1, 0)
  }
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingHTML() && Vim.State.g)
!a::Goto SMParseHTMLGUI
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_GAltA") && SM.IsEditingHTML())
!a::Vim.Move.YDCMove()
