; Editing text only
#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText())
^q::Vim.State.SetMode("SMVim_ExtractStay", 0, -1, 0)
^z::Vim.State.SetMode("SMVim_ClozeStay", 0, -1, 0)
q::Vim.State.SetMode("SMVim_Extract", 0, -1, 0)
z::Vim.State.SetMode("SMVim_Cloze", 0, -1, 0)
+q::Vim.State.SetMode("SMVim_ExtractPriority", 0, -1, 0)
+z::
^+z::
  Vim.State.SetMode("SMVim_ClozeHinter", 0, -1, 0)
  cloze_hinter_ctrl_state := GetKeyState("Ctrl")
Return

#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText() && Vim.State.g)
!t::Vim.State.SetMode("SMVim_AltT", 0, -1, 0)
!q::Vim.State.SetMode("SMVim_AltQ", 0, -1, 0)

#If (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_Extract") && Vim.SM.IsEditingText())
q::Vim.Move.YDCMove()

#If (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_Cloze") && Vim.SM.IsEditingText())
z::Vim.Move.YDCMove()