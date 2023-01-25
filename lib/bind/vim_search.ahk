#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")))
/::
  send ^f
  Vim.State.SetMode("Insert")
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal"))
*::
  ClipSaved := ClipboardAll
  KeyWait shift
  copy(false,,, "^{Left}+^{Right}^c")
  send ^f
  send ^v!f
  Clipboard := ClipSaved
  Vim.State.SetMode("Insert")
Return

n::send {F3}
+n::send +{F3}

#if
