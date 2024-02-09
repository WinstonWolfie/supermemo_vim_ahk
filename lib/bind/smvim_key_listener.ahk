#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("KeyListener"))
s::
a::
d::
f::
j::
k::
l::
e::
w::
c::
m::
p::
g::
h::
BS::
Esc::
CapsLock::
^[::
  Esc := IfIn(A_ThisLabel, "Esc,CapsLock,^[")
  if (!Esc) {
    if (BS := (A_ThisLabel = "BS")) {
      HintsEntered := RegExReplace(HintsEntered, ".$")
    } else {
      if (!HintsEntered) {
        for i, v in aHintStrings {
          if (Cont := (v ~= "i)^" . A_ThisLabel))
            Break
        }
        if (!Cont)
          return
      }
      HintsEntered .= A_ThisLabel
    }
    if (BS || (!ArrayIndex := HasVal(aHintStrings, HintsEntered))) {
      Vim.State.SetToolTip(StrUpper(HintsEntered), 0, 19)
      return
    }
    v := aHints[ArrayIndex]
    if (HinterMode == "YankLink") {
      Vim.State.SetToolTip("Copied " . Clipboard := v.Link)
    } else if (IfIn(HinterMode, "Visual,Normal")) {
      IE2 := ControlGet(,, "Internet Explorer_Server2", "A")
      IE1 := ControlGet(,, "Internet Explorer_Server1", "A")
      if (IE2 && IE1) {
        send ^t{Esc}
        Vim.SM.WaitTextExit()
        sleep 20
      }
      if (v.Control == "Internet Explorer_Server1") {
        if (IE2) {
          Vim.SM.EditFirstAnswer()
        } else {
          Vim.SM.EditFirstQuestion()
        }
      } else if (v.Control == "Internet Explorer_Server2") {
        Vim.SM.EditFirstQuestion()
      }
      Vim.SM.WaitTextFocus()
      sleep 20  ; needed lest text changes position when you click
      ControlClickScreen(v.x, v.y)
      if (HinterMode == "Visual")
        send {right}{left}^+{right}
    } else {
      if (e := !Vim.SM.RunLink(v.Link, OpenInIE))
        Vim.State.SetToolTip("An error occured when running " . v.Link)
      if (!e && IfContains(HinterMode, "Persistent,OpenLinkInNew")) {
        WinWaitNotActive, ahk_class TElWind
        WinActivate, ahk_class TElWind
      }
    }
  }
  HintsEntered := "", Vim.VimToolTip.RemoveToolTip(19)
  if (Esc || (HinterMode != "Persistent")) {
    loop % LastHintCount
      ToolTipG(,,, A_Index)
    if (HinterMode == "Visual") {
      Vim.State.SetMode("Vim_VisualChar")
    } else {
      Vim.State.SetNormal()
    }
  }
return

hintStrings(linkCount) {  ; adapted from vimium: https://github.com/philc/vimium
  hints := [], offset := 0
  linkHintCharacters := ["S", "A", "D", "J", "K", "L", "E", "W", "C", "M", "P", "G", "H"]
  while (((ObjCount(hints) - offset) < linkCount) || (ObjCount(hints) == 1)) {
    hint := hints[offset++]
    for i, v in linkHintCharacters
      hints[ObjCount(hints) + 1] := v . hint
  }
  hints := slice(hints, offset + 1, offset + linkCount)

  ; Shuffle the hints so that they're scattered; hints starting with the same character and short hints are
  ; spread evenly throughout the array.
  for i, v in hints
    hints[i] := StrReverse(v)
  sortArray(hints)
  return hints
}
