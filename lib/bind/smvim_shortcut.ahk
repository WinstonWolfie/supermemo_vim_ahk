#If Vim.IsVimGroup() && WinActive("ahk_class TElWind")
^!.:: ; find [...] and insert
	send ^t{esc}q
	sleep 100
	if Vim.SM.IsEditingPlainText() {
		send ^a
		pos := InStr(clip(), "[...]")
		if pos {
			pos += 4
			SendInput {left}{right %pos%}
		} else {
			MsgBox, Not found.
			Return
		}
	} else if Vim.SM.IsEditingHTML() {
		send {f3}
		WinWaitNotActive, ahk_class TELWind,, 0 ; double insurance to make sure the enter below does not trigger learn (which sometimes happens in slow computers)
		WinWaitActive, ahk_class TMyFindDlg,, 0
		SendInput {raw}[...]
		send {enter}
		WinWaitNotActive, ahk_class TMyFindDlg,, 0 ; faster than wait for element window to be active
		send {right}^{enter}
		WinWaitActive, ahk_class TCommanderDlg,, 0
		if ErrorLevel
			return
		send h{enter}q
		if WinExist("ahk_class TMyFindDlg") ; clears search box window
			WinClose
	}
	Vim.State.SetMode("Insert")
return

^!c:: ; change default *c*oncept group
	FindClick(A_ScriptDir . "\lib\bind\util\concept_lightbulb.png")
	Vim.State.SetNormal()
Return

~^+f12::  ; bomb format with no confirmation
	send {enter}
	Vim.State.SetNormal()
return

!+bs:: ; for laptop
^+bs:: ; for processing pending queue Advanced English 2018: delete element and keep learning
	send ^+{del}
	WinWaitNotActive, ahk_class TElWind,, 0 ; wait for "Delete element?"
	send {enter}
	WinWaitNotActive, ahk_class TMsgDialog,, 0 ; wait for element window to become focused again
	send {enter}
	Vim.State.SetNormal()
return

!+\:: ; for laptop
^+\:: ; done! and keep learning
	send ^+{enter}
	WinWaitNotActive, ahk_class TElWind,, 0 ; "Do you want to remove all element contents from the collection?"
	send {enter}
	WinWaitNotActive, ahk_class TElWind,, 0 ; wait for "Delete element?"
	send {enter}
	WinWaitNotActive, ahk_class TMsgDialog,, 0 ; wait for element window to become focused again
	send {enter}
	Vim.State.SetNormal()
return

^!+g::  ; change element's concept *g*roup
	send ^+p!g
	Vim.State.SetNormal()
return

; more intuitive inter-element linking, inspired by obsidian
; 1. go to the element you want to link to and press ctrl+alt+g
; 2. go to the element you want to have the hyperlink, select text and press ctrl+alt+k
^!g::
	send ^g
	WinWaitActive, ahk_class TInputDlg,, 0
	send ^c{esc}
	Vim.State.SetNormal()
return

#If Vim.IsVimGroup() && Vim.SM.IsEditingHTML()
^!k::
	send ^k
	WinWaitActive, ahk_class Internet Explorer_TridentDlgFrame,, 2 ; a bit more delay since everybody knows how slow IE can be
	clip("SuperMemoElementNo=(" . RegExReplace(Clipboard, "^#") . ")")
	send {enter}
	Vim.State.SetNormal()
	Vim.Caret.SwitchToSameWindow() ; refresh caret
return

^!l::
	KeyWait ctrl
	KeyWait alt
	FormatTime, current_time_display,, yyyy-MM-dd HH:mm:ss:%A_msec%
	FormatTime, current_time_file_name,, yyyy-MM-dd-HH-mm-ss-%A_msec%
	Vim.State.SetMode("Vim_Normal")
	clip_bak := Clipboardall
	Clipboard =
	send ^c
	ClipWait 1
	sleep 20
	If ClipboardGet_HTML( Data ){
		; if RegExMatch(data, "<IMG[^>]*>\K[\s\S]+(?=<!--EndFragment-->)") { ; match end of first IMG tag until start of last EndFragment tag
			; MsgBox Please select text or image only.
			; Clipboard := clip_bak
			; Return
		; } else
		if !InStr(data, "<IMG") { ; text only
			WinGetText, visible_text, ahk_class TElWind
			RegExMatch(visible_text, "(?<=LearnBar\r\n)(.*?)(?= \(SuperMemo 18: )", collection_name)
			RegExMatch(visible_text, "(?<= \(SuperMemo 18: )(.*)(?=\)\r\n)", collection_path)
			latex_formula := Enc_Uri(Clipboard)
			latex_link := "https://latex.vimsky.com/test.image.latex.php?fmt=png&val=%255Cdpi%257B150%257D%2520%255CLARGE%2520%257B%255Ccolor%257BWhite%257D%2520" . latex_formula . "%257D&dl=1"
			latex_foler_path := collection_path . collection_name . "\LaTex"
			latex_path := latex_foler_path . "\" . current_time_file_name . ".png"
			FileCreateDir % latex_foler_path
			img_html = <img alt="%Clipboard%" src="%latex_path%">
			clip(img_html, true, true)
			send ^+1
			send {esc}^t ; save html
			Clipboard =
			send !{f12}fc ; copy file path
			ClipWait 1
			sleep 20
			FileRead, html, %Clipboard%
			Vim.Move.Move("+g")
			send {end}{down}!\\
			WinWaitNotActive, ahk_class TElWind,, 0
			if !ErrorLevel
				send {enter}
			fuck_lexicon = <P><SMALL>Last LaTex to image conversion: %current_time_display%
			if InStr(html, "<P><SMALL>Last LaTex to image conversion: ")
				new_html := RegExReplace(html, "<P><SMALL>Last LaTex to image conversion: (.*)", fuck_lexicon)
			else if !html ; sometimes save html would empty it
				new_html := img_html . "`n" . fuck_lexicon
			else
				new_html := html . "`n" . fuck_lexicon
			clip(new_html,, true)
			send ^+{home}^+1
			UrlDownloadToFile, %latex_link%, %latex_path%
			send !{home}!{left} ; refresh
		} else { ; image only
			RegExMatch(data, "<IMG (alt=""|alt=)\K.+?(?=(""|\s+src=))", latex_formula)
			RegExMatch(data, "src=""file:\/\/\/\K[^""]+", latex_path)
			clip(latex_formula,, true)
			FileDelete %latex_path%
		}
	}
	Clipboard := clip_bak
Return

#If Vim.IsVimGroup() and WinActive("ahk_class TPlanDlg") ; SuperMemo Plan window
!a:: ; insert activity
	Vim.State.SetNormal()
	Gui, PlanInsert:Add, Text,, &Activity:
	list = Break||Gaming|Coding|Sports|Social|Writing|Family|Passive|Meal|Rest|School|Planning|Investing|SM|Shower|IM
	Gui, PlanInsert:Add, Combobox, vActivity gAutoComplete, %list%
	Gui, PlanInsert:Add, CheckBox, vNoSplit, &Do not split current activity
	Gui, PlanInsert:Add, Button, default, &Insert
	Gui, PlanInsert:Show,, Insert Activity
Return

PlanInsertGuiEscape:
PlanInsertGuiClose:
	Gui, Destroy
return

PlanInsertButtonInsert:
	Gui, Submit
	Gui, Destroy
	if !NoSplit {
		send ^t ; split
		WinWaitActive, ahk_class TInputDlg,, 0
		send {enter}
		WinWaitActive, ahk_class TPlanDlg,, 0
	}
	send {down}{Insert} ; inserting one activity below the current selected activity and start editing
	SendInput {raw}%activity% ; SendInput is faster than clip() here
	send !b ; begin
	WinWaitNotActive, ahk_class TPlanDlg,, 0.3 ; wait for "Mark the slot with the drop to efficiency?"
	if !ErrorLevel
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

#If Vim.State.Vim.Enabled && WinActive("ahk_class TPriorityDlg")
.::SendInput ^a0.

#If Vim.State.Vim.Enabled && WinActive("ahk_class TWebDlg")
!+d::FindClick(A_ScriptDir . "\lib\bind\util\web_import_duplicates.png")

#If Vim.State.Vim.Enabled && WinActive("ahk_class TElParamDlg")
; Task value script, modified from Naess's priority script
!0::
!Numpad0::
!NumpadIns::
	Vim.SM.SetTaskValue(9024.74,9999)
return

!1::
!Numpad1::
!NumpadEnd::
	Vim.SM.SetTaskValue(7055.79,9024.74)
return

!2::
!Numpad2::
!NumpadDown::
	Vim.SM.SetTaskValue(5775.76,7055.78)
return

!3::
!Numpad3::
!NumpadPgdn::
	Vim.SM.SetTaskValue(4625,5775.75)
return

!4::
!Numpad4::
!NumpadLeft::
	Vim.SM.SetTaskValue(3721.04,4624)
return

!5::
!Numpad5::
!NumpadClear::
	Vim.SM.SetTaskValue(2808.86,3721.03)
return

!6::
!Numpad6::
!NumpadRight::
	Vim.SM.SetTaskValue(1849.18,2808.85)
return

!7::
!Numpad7::
!NumpadHome::
	Vim.SM.SetTaskValue(841.32,1849.17)
return

!8::
!Numpad8::
!NumpadUp::
	Vim.SM.SetTaskValue(360.77,841.31)
return

!9::
!Numpad9::
!NumpadPgup::
	Vim.SM.SetTaskValue(0,360.76)
return