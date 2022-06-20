#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && !WinActive("ahk_group SuperMemo")
/::
  send ^f
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
*::
  Vim.ReleaseKey("shift")
  bak := ClipboardAll
  Clipboard=
  send ^{Left}+^{Right}^c
  ClipWait, 0.2
  send ^f
  send ^v!f
  clipboard := bak
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal")) && !WinActive("ahk_group SuperMemo")
n::send {F3}
+n::send +{F3}

#If
