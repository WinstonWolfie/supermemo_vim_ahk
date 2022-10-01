; Clip() - Send and Retrieve Text Using the Clipboard
; Originally by berban - updated February 18, 2019 - modified by Winston
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62156
Clip(Text="", Reselect="", NoRestore:=false, SMPasteHTML:=false, ReturnHTML:=false) {
  global WinClip, Vim
  if (!NoRestore)
    WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  If (Text = "") {
    send ^c
    ClipWait, LongCopy ? 0.6 : 0.2, True
    if (ReturnHTML && !ErrorLevel) {
      Vim.HTML.ClipboardGet_HTML(clipped)
    } else {
      Clipped := Clipboard
    }
  } Else {
    Clipboard := Text
    ClipWait 10
    if (SMPasteHTML) {
      ; send {AppsKey}xp  ; Paste HTML
      send ^v
      ReSelect := true
    } else {
      send ^v
    }
    Sleep 20  ; Short sleep in case Clip() is followed by more keystrokes such as {Enter}
  }
  If (Text && ReSelect)
    send % "{Shift Down}{Left " StrLen(Vim.ParseLineBreaks(text)) "}{Shift Up}"
  if (SMPasteHTML)
    send ^+1
  if (!NoRestore)  ; for scripts that restore clipboard at the end
    WinClip.Restore(ClipData)
  If (Text = "")
    Return Clipped
}