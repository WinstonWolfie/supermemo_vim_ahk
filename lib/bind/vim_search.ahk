#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")))
/::
  Send ^f
  Vim.State.SetMode("Insert")
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.g && !Vim.State.fts)
*::
  ClipSaved := ClipboardAll
  Vim.State.SetMode("Vim_Visual")
  Send ^{Right}^{Left}
  Vim.Move.Move("e",,,,, false)
  Copy(false)
  if (WinActive("ahk_class TElWind")) {
    UserInput := Clipboard, CurrFocus := ControlGetFocus("ahk_class TElWind")
    CapsState := CtrlState := AltState := ShiftState := ""
    Gosub SMSearch
  } else {
    hWnd := WinActive("A")
    Send ^f
    WinWaitNotActive, % "ahk_id " . hWnd,, 0.3
    Send ^v
    WinClip._waitClipReady()
    Send {Enter}
  }
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
Return

n::Send {F3}
+n::Send +{F3}

#if
