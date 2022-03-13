#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_group SuperMemo")
; Keys that need insert mode
~!f10::
~!f12::
~RButton::
	Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_class TPlanDlg")
~Insert::
~NumpadIns::
~!m::
	Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_class TElWind")
~!a::
	Vim.State.SetMode("Insert")
Return