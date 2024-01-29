#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")))
/::
  send ^f
  Vim.State.SetMode("Insert")
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.g && !Vim.State.fts)
*::
  ClipSaved := ClipboardAll
  Vim.State.SetMode("Vim_Visual")
  send ^{right}^{left}
  Vim.Move.Move("e",,,,, false)
  Copy(false)
  if (WinActive("ahk_class TElWind")) {
    UserInput := Clipboard, CurrFocus := ControlGetFocus("ahk_class TElWind")
    CapsState := CtrlState := AltState := ShiftState := ""
    Gosub SMSearch
  } else {
    hWnd := WinActive("A")
    send ^f
    WinWaitNotActive, % "ahk_id " . hWnd,, 0.3
    send ^v
    WinClip._waitClipReady()
    send {enter}
  }
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
Return

n::send {F3}
+n::send +{F3}

#if
