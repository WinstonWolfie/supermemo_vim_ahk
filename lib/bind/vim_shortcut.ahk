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

LAlt & RAlt:: ; for laptop
	KeyWait LAlt
	KeyWait RAlt
	send {AppsKey}
	Vim.State.SetMode("Insert")
return

^!+r::MsgBox, Caret position: %A_CaretX% %A_CaretY%

#if WinActive("ahk_exe chrome.exe") ; not using ahk_class because it's the same with the discord app
^!i:: ; open in *I*E
	send ^l
	sleep 100
	link := RegExReplace(clip(), "#(.*)$")
	Run, iexplore.exe %link%
Return

^!l:: ; copy link and parse *l*ink if if's from YT
	send ^l
	sleep 100
	Clipboard =
	send ^c
	ClipWait 1
	sleep 100
	if InStr(Clipboard, "https://www.youtube.com")
		if InStr(Clipboard, "v=") {
			RegExMatch(Clipboard, "v=\K[\w\-]+", YT_link)
			Clipboard = https://www.youtube.com/watch?v=%YT_link%
		}
	send {tab}
return

^!d:: ; parse similar and opposite in google *d*efine
	Clipboard =
	send ^c
	ClipWait 1
	sleep 300
	Clipboard := RegExReplace(Clipboard, "(?<!(Similar)|(?<![^:])|(?<![^.])|(?<![^""]))\r\n", "; ")
	Clipboard := StrReplace(Clipboard, "`r`nSimilar", "`r`n`r`nSimilar")
	Clipboard := StrReplace(Clipboard, "; Opposite:", "`r`n`r`nOpposite:")
	Clipboard := StrReplace(Clipboard, "vulgar slang", "vulgar slang > ")
return

#if WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe ebook-viewer.exe")
*!x:: ; pdf/epub extract to supermemo
	ctrl_state := GetKeyState("ctrl")
	clipSave := Clipboardall
	Clipboard = 
	send ^c
	ClipWait 0.5
	if !Clipboard {
		MsgBox, Nothing is selected.
		Clipboard := clipSave
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
	sleep 100
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
	clip(extract)
	send ^+{home} ; select everything
	sleep 50
	send !x ; extract
	sleep 1000
	send {down}
	send !\\
	WinWaitActive ahk_class TMsgDialog,, 0
	send {enter}
	WinWaitActive ahk_class TElWind,, 0
	send {esc}
	if (ctrl_state = 1)
		send !{left}
	else {
		if (reader = "p")
			WinActivate, ahk_class SUMATRA_PDF_FRAME
		else if (reader = "e")
			WinActivate, ahk_exe ebook-viewer.exe
	}
	Clipboard := clipSave
return

#if WinActive("ahk_class SUMATRA_PDF_FRAME")
^!q:: ; exit and save annotations
	send q
	WinWaitActive, Unsaved annotations,, 0
	sleep 50
	if !ErrorLevel
		FindClick(A_ScriptDir . "\lib\bind\util\save_changes_to_existing_pdf.png", "o32")
return

#If Vim.IsVimGroup() and WinActive("ahk_class TPlanDlg") ; SuperMemo Plan window
!a:: ; insert the accident activity
	Vim.State.SetNormal()
	InputBox, user_input, Accident activity, Please enter the name of the activity. Add ! at the beginning if you don't want to split the current activity.,, 256, 164
	if ErrorLevel
		return
	replacement := RegExReplace(user_input, "^!") ; remove the "!"
	if (replacement != user_input) { ; you entered an "!"
		split = 0
		user_input := replacement
	} else
		split = 1
	if (user_input = "b") ; shortcuts
		user_input = Break
	else if (user_input = "g")
		user_input = Gaming
	else if (user_input = "c")
		user_input = Coding
	else if (user_input = "s")
		user_input = Sports
	else if (user_input = "o")
		user_input = Social
	else if (user_input = "w")
		user_input = Writing
	else if (user_input = "f")
		user_input = Family
	else if (user_input = "p")
		user_input = Passive
	else if (user_input = "m")
		user_input = Meal
	else if (user_input = "r")
		user_input = Rest
	else if (user_input = "h")
		user_input = School
	else if (user_input = "l")
		user_input = Planning
	if (split = 1) {
		send ^t ; split
		WinWaitActive, ahk_class TInputDlg,, 0
		send {enter}
		WinWaitActive, ahk_class TPlanDlg,, 0
	}
	send {down}{Insert} ; inserting one activity below the current selected activity and start editing
	SendInput {raw}%user_input% ; SendInput is faster than clip() here
	send !b ; begin
	sleep 400 ; wait for "Mark the slot with the drop to efficiency?"
	if WinActive("ahk_class TMsgDialog")
		send y
	WinWaitActive, ahk_class TPlanDlg,, 0
	send ^s{esc} ; save and exits
	WinWaitActive, ahk_class TElWind,, 0
	send ^{enter} ; commander
	WinWaitActive, ahk_class TCommanderDlg,, 0
	send {enter} ; cancel alarm
	WinWaitActive, ahk_class TElWind,, 0
	send ^p ; open plan again
return