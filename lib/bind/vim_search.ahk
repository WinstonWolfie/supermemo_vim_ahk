#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")))
/::
  send ^f
  Vim.State.SetMode("Insert")
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal"))
*::
  ReleaseKey("shift")
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^{Left}+^{Right}^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  send ^f
  send ^v!f
  WinClip.Restore(ClipData)
  Vim.State.SetMode("Insert")
Return

n::send {F3}
+n::send +{F3}

#if
