#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
; `;::Vim.State.SetMode("Command") ;(;)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command"))
w::Vim.State.SetMode("Command_w")
q::Vim.State.SetMode("Command_q")
h::
  Send, {F1}
  Vim.State.SetMode("Vim_Normal")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_w"))
Return::
  Send, ^s
  Vim.State.SetMode("Vim_Normal")
Return

q::
  Send, ^s^w
  Vim.State.SetMode("Insert")
Return

Space:: ; save as
  Send, !fa
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_q"))
Return::
  Send, ^w
  Vim.State.SetMode("Insert")
Return

; Commander, can be launched anywhere as long as vim_ahk is enabled
#If Vim.State.Vim.Enabled && !Vim.State.IsCurrentVimMode("Command")
^`;::
	WinGet, hwnd, ID, A
	Gui, VimCommander:Add, Text,, &Command:
	; list names are the same as subroutine name, just replacing the space with _, and no final parentheses
	list = SM Plan||Window Spy|Regex101|Watch later (YT)|Search|Move mouse to caret|LaTeX|Wayback Machine|DeepL|YouGlish
	if Vim.State.IsCurrentVimMode("Vim_Normal") {
		list .= 
		mode_commander = n
	} else if Vim.State.StrIsInCurrentVimMode("Visual") {
		list .= Convert to lowercase (= u)|Convert to uppercase (= U)|Invert case (= ~)
		mode_commander = v
	}
	Gui, VimCommander:Add, Combobox, vCommand gAutoComplete, %list%
	Gui, VimCommander:Add, Button, default, &Execute
	Gui, VimCommander:Show,, Vim Commander
	Vim.State.SetMode("Insert")
Return

VimCommanderGuiEscape:
VimCommanderGuiClose:
	Gui, Destroy
return

VimCommanderButtonExecute:
	Gui, Submit
	Gui, Destroy
	if (command == "Watch later (YT)")
		command = watch_later_yt
	else if InStr("|" . list . "|", "|" . command . "|") {
		StringLower, command, command
		command := RegExReplace(command, " \(.*") ; removing parentheses
		command := StrReplace(command, " ", "_")
	} else { ; command has to be in the list. If not, google the command
		run https://www.google.com/search?q=%command% ; this could be a shorthand for searching
		Return
	}
	WinActivate, ahk_id %hwnd%
	Gosub % command
Return

sm_plan:
	if WinExist("ahk_class TPlanDlg") {
		WinActivate
		Vim.State.SetMode("Vim_Normal")
		Return
	}
	if WinExist("ahk_group SuperMemo") {
		WinActivate, ahk_class TElWind
		WinWaitActive, ahk_class TElWind,, 0
	} else {
		run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SuperMemo\SuperMemo.lnk
		WinWaitActive, ahk_class TElWind,, 5
		if ErrorLevel
			Return
	}
	send ^{enter} ; commander; seems to be a more reliable option than {alt}kp or ^p
	SendInput {raw}pl ; open plan
	send {enter}
	Vim.State.SetMode("Vim_Normal")
Return

window_spy:
	run C:\Program Files\AutoHotkey\WindowSpy.ahk
Return

regex101:
	run https://regex101.com/
Return

watch_later_yt:
	run https://www.youtube.com/playlist?list=WL
Return

search:
	search_term := clip()
	if !search_term {
		InputBox, search_term, Google Search, Enter your search term.,, 192, 128
		if !search_term || ErrorLevel
			return
	}
	run https://www.google.com/search?q=%search_term%
Return

move_mouse_to_caret:
	MouseMove, % A_CaretX, % A_CaretY
	if A_CaretX
		Vim.ToolTip("Current caret position: " . A_CaretX . " " . A_CaretY)
	else
		Vim.ToolTip("Caret not found.")
Return

latex:
	run https://latex.vimsky.com/
Return

wayback_machine:
	url := clip()
	if !url {
		InputBox, url, Wayback Machine, Enter your URL.,, 192, 128
		if !url || ErrorLevel
			return
	}
	run https://web.archive.org/web/*/%url%
Return

deepl:
	text := clip()
	if !text {
		InputBox, text, DeepL Translation, Enter your text.,, 192, 128
		if !text || ErrorLevel
			return
	}
	run https://www.deepl.com/en/translator#?/en/%text%
Return

youglish:
	text := clip()
	if !text {
		InputBox, text, DeepL Translation, Enter your text.,, 192, 128
		if !text || ErrorLevel
			return
	}
	InputBox, lang_code, YouGlish, Enter a language code., , 256, 128
	if ErrorLevel
		return
	if (lang_code = "en")
		run https://youglish.com/pronounce/%text%/english?
	else if (lang_code = "es")
		run https://youglish.com/pronounce/%text%/spanish?
	else if (lang_code = "fr")
		run https://youglish.com/pronounce/%text%/french?
	else if (lang_code = "it")
		run https://youglish.com/pronounce/%text%/italian?
	else if (lang_code = "ja")
		run https://youglish.com/pronounce/%text%/japanese?
	else if (lang_code = "de")
		run https://youglish.com/pronounce/%text%/german?
	else if (lang_code = "ru")
		run https://youglish.com/pronounce/%text%/russian?
	else if (lang_code = "el")
		run https://youglish.com/pronounce/%text%/greek?
	else if (lang_code = "he")
		run https://youglish.com/pronounce/%text%/hebrew?
	else if (lang_code = "ar")
		run https://youglish.com/pronounce/%text%/arabic?
	else if (lang_code = "pl")
		run https://youglish.com/pronounce/%text%/polish?
	else if (lang_code = "pt")
		run https://youglish.com/pronounce/%text%/portuguese?
	else if (lang_code = "ko")
		run https://youglish.com/pronounce/%text%/korean?
	else if (lang_code = "sv")
		run https://youglish.com/pronounce/%text%/swedish?
	else if (lang_code = "nl")
		run https://youglish.com/pronounce/%text%/dutch?
	else if (lang_code = "tr")
		run https://youglish.com/pronounce/%text%/turkish?
	else if (lang_code = "asl")
		run https://youglish.com/pronounce/%text%/signlanguage?
Return