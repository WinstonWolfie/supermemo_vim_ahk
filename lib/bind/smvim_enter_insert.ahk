; Keys that need insert mode
#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_group SuperMemo")
~!f10::
~+f10::
~!f12::
~RButton:: ; this button is evil and sacrilegious to the purity of Vim. Adding it anyway since someone might need it in the adjusting period
#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_class TPlanDlg")
~Insert::
~NumpadIns::
~!m:: ; menu
~!h:: ; change hours
#If Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal")) && WinActive("ahk_class TElWind")
~!a:: ; new item
~!n:: ; new topic
~^+f6:: ; open source in notepad
	Vim.State.SetMode("Insert")
Return