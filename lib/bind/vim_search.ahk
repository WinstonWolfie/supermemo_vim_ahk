#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && !WinActive("ahk_group SuperMemo")
/::
  Send, ^f
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
*::
  KeyWait Shift
  bak := ClipboardAll
  Clipboard=
  Send, ^{Left}+^{Right}^c
  ClipWait, 1
  sleep 20
  Send, ^f
  Send, ^v!f
  clipboard := bak
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal")) && !WinActive("ahk_group SuperMemo")
n::Send, {F3}
+n::Send, +{F3}

#If
