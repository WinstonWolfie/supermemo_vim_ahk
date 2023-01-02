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
bs::
esc::
capslock::
^[::
  esc := IfIn(A_ThisHotkey, "esc,capslock,^[")
  if (!esc) {
    if (bs := (HintsEntered && (A_ThisHotkey = "bs"))) {
      HintsEntered := RegExReplace(HintsEntered, ".$")
    } else {
      HintsEntered .= A_ThisHotkey
    }
    TT := StrUpper(HintsEntered)
    ToolTip(TT, true,,, 19)
    if (bs || (!ArrayIndex := HasVal(aHintStrings, HintsEntered)))
      return
    for k, v in aHints {
      if (A_Index == ArrayIndex) {
        if (HinterMode == "YankLink") {
          Clipboard := v
          ToolTip("Copied " . v)
        } else if (IfIn(HinterMode, "Visual,Normal")) {
          IE2 := ControlGet(,, "Internet Explorer_Server2")
          IE1 := ControlGet(,, "Internet Explorer_Server1")
          if (IE2 && IE1) {
            send ^t{esc}
            Vim.SM.WaitTextExit()
            sleep 20
          }
          if (v == "Internet Explorer_Server1") {
            if (IE2) {
              Vim.SM.EditFirstAnswer()
            } else {
              Vim.SM.EditFirstQuestion()
            }
          } else if (v == "Internet Explorer_Server2") {
            Vim.SM.EditFirstQuestion()
          }
          Vim.SM.WaitTextFocus()
          aCoords := StrSplit(k, " ")
          ControlClickScreen(aCoords[1], aCoords[2])
          if (HinterMode == "Visual")
            send {right}{left}^+{right}
        } else {
          if (!Vim.SM.RunLink(v, OpenInIE)) {
            ToolTip("An error occured when running " . v)
            break
          }
          if (HinterMode == "Persistent") {
            WinWaitNotActive, ahk_class TElWind
            WinActivate, ahk_class TElWind
          }
        }
        break
      }
    }
  }
  HintsEntered := ""
  RemoveToolTip(19)
  if (esc || (HinterMode != "Persistent")) {
    RemoveAllToopTip(LastHintCount, "g")
    if (HinterMode == "Visual") {
      Vim.State.SetMode("Vim_VisualChar")
    } else {
      Vim.State.SetNormal()
    }
  }
return

RemoveAllToopTip(n:=20, ToolTipKind:="") {
  loop % n {
    if (!ToolTipKind) {
      ToolTip,,,, % A_Index
    } else if (ToolTipKind = "ex") {
      ToolTipEx(,,, A_Index)
    } else if (ToolTipKind = "g") {
      ToolTipG(,,, A_Index)
    }
  }
}

CreateHints(HintsArray, HintStrings) {
  for k, v in HintsArray {
    aCoords := StrSplit(k, " ")
    ToolTipG(HintStrings[A_Index], aCoords[1], aCoords[2], A_Index,, "yellow", "black",, "S")
    global LastHintCount := A_Index
  }
}

hintStrings(linkCount) {  ; adapted from vimium
  hints := []
  offset := 0
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