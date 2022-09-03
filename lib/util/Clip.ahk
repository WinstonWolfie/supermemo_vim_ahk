; Clip() - Send and Retrieve Text Using the Clipboard
; Originally by berban - updated February 18, 2019 - modified by Winston
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62156
Clip(Text="", Reselect="", NoRestore:=false) {
  if (text == clipboard) {
    send ^v
    sleep 20
    if (ReSelect)
      send % "{Shift Down}{Left " StrLen(StrReplace(Text, "`r")) "}{Shift Up}"
    return
  }
  if (!NoRestore) {
    global WinClip
    WinClip.Snap(ClipData)
  }
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  If (Text = "") {
    send ^c
    ClipWait, LongCopy ? 0.6 : 0.2, True
    Clipped := Clipboard
  } Else {
    Clipboard := Text
    ClipWait 10
    send ^v
    Sleep 20  ; Short sleep in case Clip() is followed by more keystrokes such as {Enter}
  }
  If (Text && ReSelect)
    send % "{Shift Down}{Left " StrLen(StrReplace(Text, "`r")) "}{Shift Up}"
  if (!NoRestore)  ; for scripts that restore clipboard at the end
    WinClip.Restore(ClipData)
  If (Text = "")
    Return Clipped
}