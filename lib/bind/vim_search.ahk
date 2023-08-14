#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")))
/::
  send ^f
  Vim.State.SetMode("Insert")
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.g)
*::
  ClipSaved := ClipboardAll
  KeyWait Shift
  Vim.State.SetMode("Vim_Visual")
  send ^{right}^{left}
  Vim.Move.Move("e",,,,, false)
  Copy(false)
  if (WinActive("ahk_class TElWind")) {
    UserInput := Clipboard, CurrFocus := ControlGetFocus("ahk_class TElWind")
    CapsState := CtrlState := AltState := ShiftState := ""
    Gosub SMSearch
  } else {
    hWnd := WinGet()
    send ^f
    WinWaitNotActive, % "ahk_id " . hWnd,, 0.25
    send ^v!f
  }
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
Return

n::send {F3}
+n::send +{F3}

#if
