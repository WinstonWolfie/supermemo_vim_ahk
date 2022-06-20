; Keys that need insert mode
#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_group SuperMemo")
~!f10::
~+f10::
~!f12::
#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TPlanDlg"))
~Insert::
~NumpadIns::
~!m::  ; menu
#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind"))
~!a::  ; new item
~!n::  ; new topic
~^+f6::  ; open source in notepad
  Vim.State.SetMode("Insert")
Return

#If (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))
!h::  ; change hours
  ; click 320 50
  ControlFocus, TEdit1, A
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_group SuperMemo")
~RButton::  ; this button is evil and sacrilegious to the purity of Vim. Adding it anyway since someone might need it in the adjusting period
  Vim.State.SetMode("Insert",,,,, true)
Return
