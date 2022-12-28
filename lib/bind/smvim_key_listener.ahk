#if (Vim.State.IsCurrentVimMode("KeyListener"))
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
esc::
capslock::
  if (!IfIn(A_ThisHotkey, "esc,capslock")) {
    HintsEntered .= A_ThisHotkey
    if (!ArrayIndex := HasVal(aHintStrings, HintsEntered))
      return
    i := 0
    for k, v in aHints {
      i++
      if (i == ArrayIndex) {
        Vim.SM.RunLink(v)
        break
      }
    }
  }
  if (LastHintCount > 8) {
    reload  ; for more than 8 hints, reload is necessary, otherwise the second time tooltip won't show up somehow
  } else {
    HintsEntered := ""
    RemoveAllToopTip(LastHintCount, "g")
    Vim.State.SetNormal()
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
  i := 0
  for k, v in HintsArray {
    i++
    aCoords := StrSplit(k, " ")
    ; ToolTip, % HintStrings[i], aCoords[1], aCoords[2], i
    ToolTipG(HintStrings[i], aCoords[1], aCoords[2], i,, "yellow", "black")
  }
  global LastHintCount := i
}

hintStrings(linkCount) {  ; adapted from vimium
  hints := []
  offset := 0
  linkHintCharacters := ["S", "A", "D", "J", "K", "L", "E", "W", "C", "M", "P", "G", "H"]
  while (((ObjCount(hints) - offset) < linkCount) || (ObjCount(hints) == 1)) {
    offset++
    hint := hints[offset]
    for i, v in linkHintCharacters {
      n := ObjCount(hints) + 1
      hints[n] := v . hint
    }
  }
  hints := slice(hints, offset + 1, offset + linkCount)

  ; Shuffle the hints so that they're scattered; hints starting with the same character and short hints are
  ; spread evenly throughout the array.
  for i, v in hints
    hints[i] := StrReverse(v)
  sortArray(hints)
  return hints
}

; GetHintStrings(hintCount) {  ; adapted from hunt-and-peck (Github)
;   hintStrings := []
;   if (hintCount <= 0)
;       return

;   hintCharacters := ["S", "A", "D", "F", "J", "K", "L", "E", "W", "C", "M", "P", "G", "H"]
;   hintCharactersLength := ObjCount(hintCharacters)
;   digitsNeeded := ceil(log(hintCount) / log(hintCharactersLength))

;   wholeHintCount := hintCharactersLength ** digitsNeeded
;   shortHintCount := (wholeHintCount - hintCount) / hintCharactersLength
;   longHintCount := hintCount - shortHintCount

;   longHintPrefixCount := wholeHintCount / hintCharactersLength - shortHintCount
;   i := 0, j := 0
;   while (i < longHintCount) {
;     k := ObjCount(hintStrings) + 1
;     hintStrings[k] := StrReverse(NumberToHintString(j, hintCharacters, digitsNeeded))
;     if ((longHintPrefixCount > 0) && (mod(i + 1, longHintPrefixCount) == 0))
;       j += shortHintCount
;     i++, j++
;   }

;   if (digitsNeeded > 1) {
;     i := 0
;     while (i < shortHintCount) {
;       k := ObjCount(hintStrings) + 1
;       hintStrings[k] := StrReverse(NumberToHintString(i + longHintPrefixCount, hintCharacters, digitsNeeded - 1))
;       i++
;     }
;   }

;   return hintStrings
; }

; NumberToHintString(number, characterSet, noHintDigits:=0) {
;   divisor := ObjCount(characterSet)
;   hintString := ""

;   while (number > 0) {
;     remainder := mod(number, divisor)
;     hintString := characterSet[remainder + 1] . hintString
;     number -= remainder
;     number /= floor(divisor)
;   }

;   ; Pad the hint string we're returning so that it matches numHintDigits.
;   ; Note: the loop body changes StrLen(hintString), so the original length must be cached!
;   length := StrLen(hintString)
;   i := 0
;   while (i < (noHintDigits - length)) {
;     hintString := characterSet[1] . hintString
;     i++
;   }

;   return hintString
; }