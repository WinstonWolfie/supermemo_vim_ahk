; Launch Settings
#If
^!+v::
  Vim.Setting.ShowGui()
Return

; Check Mode
#If Vim.IsVimGroup()
^!+c::
  Vim.State.CheckMode(4, Vim.State.Mode)
Return

; Suspend/restart
#If
^!+s::
  Vim.State.ToggleEnabled()
Return

; Shortcuts for all windows
#If Vim.State.Vim.Enabled
^!r::Reload

LAlt & RAlt:: ; for laptop
	send {blind}{LAlt up}{RAlt up}{AppsKey}
	Vim.State.SetMode("Insert")
return

; ^!+r::
	; MsgBox, Caret position: %A_CaretX% %A_CaretY%
	; MouseMove, %A_CaretX%, %A_CaretY%
; Return

; Chrome
#If Vim.State.Vim.Enabled && WinActive("ahk_exe chrome.exe") ; not using ahk_class because it's the same with the discord app
^!i:: ; open in *I*E
	send ^l
	sleep 100
	link := RegExReplace(clip(), "#(.*)$")
	send {f6 2}
	Run, iexplore.exe %link%
Return

^!l:: ; copy link and parse *l*ink if if's from YT
	send ^l
	sleep 100
	Clipboard =
	send ^c ; cannot use clip() here because it will try to restore the clipboard
	ClipWait 1
	sleep 20
	send {f6 2}
	temp_clip := RegExReplace(Clipboard, "#(.*)$")
	if InStr(temp_clip, "https://www.youtube.com") && InStr(temp_clip, "v=") {
		RegExMatch(temp_clip, "v=\K[\w\-]+", yt_link)
		temp_clip = https://www.youtube.com/watch?v=%yt_link%
	}
	Clipboard := temp_clip
	Vim.ToolTipFunc("Copied " . temp_clip)
return

^!d:: ; parse similar and opposite in google *d*efine
	Clipboard =
	send ^c
	ClipWait 1
	sleep 20
	temp_clip := RegExReplace(Clipboard, "(?<!(Similar)|(?<![^:])|(?<![^.])|(?<![^""]))\r\n", "; ")
	temp_clip := StrReplace(temp_clip, "`r`nSimilar", "`r`n`r`nSimilar")
	temp_clip := StrReplace(temp_clip, "; Opposite", "`r`n`r`nOpposite")
	temp_clip := StrReplace(temp_clip, "Opposite; ", "Opposite`r`n")
	Clipboard := StrReplace(temp_clip, "vulgar slang", "vulgar slang > ")
	Vim.ToolTipFunc("Copied:`n" . temp_clip)
return

; SumatraPDF/Calibre to SuperMemo
#If Vim.State.Vim.Enabled && (WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe ebook-viewer.exe"))
^!x::
!x:: ; pdf/epub extract to supermemo
	ctrl_state := GetKeyState("ctrl")
	clip_bak := Clipboardall
	Clipboard = 
	send ^c
	ClipWait 0.6
	sleep 20
	if !Clipboard {
		MsgBox, Nothing is selected.
		Clipboard := clip_bak
		return
	} else {
		if WinActive("ahk_class SUMATRA_PDF_FRAME") {
			reader = p
			send a
		} else if WinActive("ahk_exe ebook-viewer.exe") {
			reader = e
			send h
			sleep 100
			send ^{enter}
		}
		if !WinExist("ahk_group SuperMemo") {
			MsgBox, SuperMemo is not open, please open SuperMemo and paste your text.
			return
		}
	}
	WinActivate, ahk_class TElWind ; focus to element window
	send ^t{esc}q ; edit topic html component
	sleep 100
	ControlGetFocus, current_focus, ahk_class TElWind
	if (current_focus != "Internet Explorer_Server1") {
		MsgBox, No html component is focused, please go to your desired topic and paste your text.
		return
	}
	send ^{home}^+{down} ; go to top and select first paragraph below
	extract := Clipboardall
	if RegExMatch(clip(), "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])") { ; sometimes this messes with the clipboard, so extract is saved
		send {left}
		MsgBox, Please make sure current element is an empty html topic. Your extract is now on your clipboard.
		return
	}
	send {left}
	clip(extract,, true)
	send ^+{home} ; select everything
	sleep 50
	send !x ; extract
	sleep 1000
	send {down}
	send !\\
	WinWaitNotActive, ahk_class TElWind,, 0
	send {enter}
	WinWaitNotActive, ahk_class TMsgDialog,, 0
	send {esc}
	if ctrl_state
		send !{left}
	else
		if (reader == "p")
			WinActivate, ahk_class SUMATRA_PDF_FRAME
		else if (reader == "e")
			WinActivate, ahk_exe ebook-viewer.exe
	Clipboard := clip_bak
return

; SumatraPDF
#If Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME")
^!q:: ; exit and save annotations
	send q
	WinWaitActive, Unsaved annotations,, 0
	sleep 50
	if !ErrorLevel
		FindClick(A_ScriptDir . "\lib\bind\util\save_changes_to_existing_pdf.png", "o32")
return