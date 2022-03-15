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
return

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
	ToolTip
return

#If WinActive("ahk_class TPriorityDlg")
.::SendInput ^a0.