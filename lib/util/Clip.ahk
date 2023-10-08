#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Clip() - Send and Retrieve Text Using the Clipboard
; Originally by berban - updated February 18, 2019 - modified by Winston
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62156
Clip(Text:="", Reselect:=false, RestoreClip:=true, HTML:=false, Method:=0, KeysToSend:="", WaitIndefinitely:=false) {
  global WinClip, Vim
  if (RestoreClip)
    ClipSaved := ClipboardAll
  If (Text = "") {
    LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
    send % KeysToSend ? KeysToSend : (Method ? "^{Ins}" : "^c")
    ClipWait, WaitIndefinitely ? "" : (LongCopy ? 0.6 : 0.2), True
    if (!ErrorLevel) {
      if (HTML) {
        Vim.HTML.ClipboardGet_HTML(Clipped)
        RegExMatch(Clipped, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", Clipped)
      } else {
        Clipped := Clipboard
      }
    }
  } Else {
    if (HTML && (HTML != "sm")) {
      Vim.HTML.SetClipboardHTML(text)
    } else {
      WinClip.Clear()
      Clipboard := Text
      ClipWait
    }
    if (HTML = "sm") {
      Vim.SM.PasteHTML()
    } else {
      send % KeysToSend ? KeysToSend : (Method ? "+{Ins}" : "^v")
      while (DllCall("GetOpenClipboardWindow"))
        sleep 1
      ; Sleep 20  ; Short sleep in case Clip() is followed by more keystrokes such as {Enter}
    }
  }
  If (Text && Reselect)
    send % "+{Left " . StrLen(Vim.ParseLineBreaks(text)) . "}"
  if (RestoreClip)  ; for scripts that restore clipboard at the end
    Clipboard := ClipSaved
  If (Text = "")
    Return Clipped
}

Copy(RestoreClip:=true, HTML:=false, CopyMethod:=0, KeysToSend:="", WaitIndefinitely:=false) {
  return Clip(,, RestoreClip, HTML, CopyMethod, KeysToSend, WaitIndefinitely)
}
