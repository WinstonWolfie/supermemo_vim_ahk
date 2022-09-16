; Editing text only
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText())
+h::  ; move to top of screen
  ReleaseKey("shift")  ; to avoid clicking becomes selecting
  Vim.SM.ClickTop()
  send {shift}
Return

+m::  ; move to middle of screen
  ReleaseKey("shift")  ; to avoid clicking becomes selecting
  Vim.SM.ClickMid()
  send {shift}
Return

+l::  ; move to bottom of screen
  ReleaseKey("shift")  ; to avoid clicking becomes selecting
  Vim.SM.ClickBottom()
  send {shift}
Return

; Editing HTML
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingHTML())
^c::send {home}>{space}

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingHTML() && Vim.State.g)
+x::
x::  ; open hyperlink in current caret position (Open in *n*ew window)
  ReleaseKey("shift")
  Shift := InStr(A_ThisHotkey, "+")
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send +{right}^c{left}
  ClipWait, LongCopy ? 0.6 : 0.2, True
  If (clipboard ~= "\s" || !Clipboard) {
    send +{left}^c{right}
    ClipWait, LongCopy ? 0.6 : 0.2, True
  }
  If (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, "(<A((.|\r\n)*)href="")\K[^""]+", CurrLink)
    RunLink := false
    if (!CurrLink) {
      WinClip.Clear()
      send +{left}^c{right}
      ClipWait, LongCopy ? 0.6 : 0.2, True
      If (Vim.HTML.ClipboardGet_HTML(data)) {
        RegExMatch(data, "(<A((.|\r\n)*)href="")\K[^""]+", CurrLink)
        if (!CurrLink) {
          ToolTip("No link found.")
        } else {
          RunLink := true
        }
      }
    } else {
      RunLink := true
    }
    if (RunLink) {
      if (InStr(CurrLink, "SuperMemoElementNo=(")) {  ; goes to a supermemo element
        RegExMatch(CurrLink, "SuperMemoElementNo=\(\K[0-9]+", ElementNumber)
        send % "^g" . ElementNumber . "{enter}"
      } else {
        if (Shift) {
          ; run % "iexplore.exe " . CurrLink  ; RIP IE
          Vim.Browser.RunInIE(CurrLink)
        } else {
          run % CurrLink
        }
      }
    }
  }
  Vim.State.SetMode()
  WinClip.Restore(ClipData)
return

s::
  if (Vim.SM.IsLearning()) {
    ContinueLearning := true
  } else {
    ContinueLearning := false
  }
  WinGet, hwnd, ID, A
  send ^{f7}
  Vim.SM.SaveHTML()
  send {esc}  ; leave html
  run % StrReplace(A_AppData, "Roaming") . "Local\Programs\Microsoft VS Code\Code.exe " . Vim.SM.GetFilePath()
  WinWaitNotActive % "ahk_id " . hwnd
  WinWaitActive % "ahk_id " . hwnd
  send !{home}
  if (ContinueLearning) {
    ControlSend, TBitBtn2, {enter}, ahk_class TElWind
  } else {
    sleep 100
    send !{left}
  }
  Vim.State.SetMode()
return

#if (Vim.State.Vim.Enabled
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && (WinActive("ahk_class TElWind")
   || WinActive("ahk_class TContents")
   || WinActive("ahk_class TBrowser")))
!h::send !{left}
!l::send !{right}
!j::send !{pgdn}
!k::send !{pgup}
!u::send ^{up}