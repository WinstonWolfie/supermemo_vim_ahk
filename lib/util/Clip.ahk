; Clip() - Send and Retrieve Text Using the Clipboard
; Originally by berban - updated February 18, 2019 - modified by Winston
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62156
Clip(Text="", Reselect="", PassClip:=false, HTML:=false, SetText:=true, method:=0) {
  global WinClip, Vim
  if (!PassClip)
    WinClip.Snap(ClipData)
    ; ClipSaved := ClipboardAll
  If (Text = "") {
    LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
    if (!method) {
      send ^c
    } else {
      send ^{Ins}
    }
    ClipWait, LongCopy ? 0.6 : 0.2, True
    if (!ErrorLevel) {
      if (HTML) {
        Vim.HTML.ClipboardGet_HTML(clipped)
        RegExMatch(clipped, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", clipped)
      } else {
        Clipped := Clipboard
      }
    }
  } Else {
    WinClip.Clear()
    if (HTML && HTML != "sm") {
      Vim.HTML.SetClipboardHTML(text)
    } else {
      if (SetText) {
        WinClip.SetText(text)
      } else {
        Clipboard := Text
        ClipWait
      }
    }
    send ^v
    while (WinClipAPI.GetOpenClipboardWindow())
      sleep 1
    ; Sleep 20  ; Short sleep in case Clip() is followed by more keystrokes such as {Enter}
  }
  If (Text && (ReSelect || HTML = "sm")) {
    if (HTML = "sm") {
      n := StrLen(text)
    } else {
      n := StrLen(Vim.ParseLineBreaks(text))
    }
    send % "+{Left " . n . "}"
  }
  if (text && html = "sm")
    send ^+1
  if (!PassClip)  ; for scripts that restore clipboard at the end
    WinClip.Restore(ClipData)
    ; Clipboard := ClipSaved
  If (Text = "")
    Return Clipped
}

copy(PassClip:=false, HTML:=false, method:=0) {
  return clip("",, PassClip, HTML,, method)
}