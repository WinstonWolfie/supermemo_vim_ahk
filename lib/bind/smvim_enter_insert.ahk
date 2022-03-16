; Keys that need insert mode
#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_group SuperMemo")
~!f10::
~+f10::
~!f12::
~RButton::
#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_class TPlanDlg")
~Insert::
~NumpadIns::
~!m::
#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_class TElWind")
~!a::
~!n::
	Vim.State.SetMode("Insert")
Return