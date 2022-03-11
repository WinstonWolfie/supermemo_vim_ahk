; Hotkeys in this file are inspired by Vimium: https://github.com/philc/vimium

; G state on top to have higher priority
; putting those below would make gu stops working (u triggers scroll up)
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX and (Vim.State.g)
s:: ; gs: go to source link
	send !{f10}fs
	WinWaitActive, Information
	if ErrorLevel
		return
	clipSave := Clipboardall
	send p{esc}
	Vim.State.SetMode()
	ClipWait 1
	if InStr(Clipboard, "Link:") {
		RegExMatch(Clipboard, "Link: \K.*", link)
		Clipboard := clipSave ; restore clipboard here in case Run doesn't work
		run % link
	} else
		VimToolTipFunc("No link found.")
	Clipboard := clipSave
Return

+t:: ; J, gt: go down one element
	send !{pgup}
	Vim.State.SetMode()
Return

t:: ; K, gT: go up one element
	send !{pgdn}
	Vim.State.SetMode()
Return

0:: ; g0: go to root element
	send !{home}
	Vim.State.SetMode()
Return

$:: ; g$: go to last element
	send !{end}
	Vim.State.SetMode()
Return

u:: ; gu: go up
	send ^{up}
	Vim.State.SetMode()
Return

+u:: ; gU: click source button
	FindClick(A_ScriptDir . "\lib\bind\util\source_element_window.png")
	Vim.State.SetMode()
Return

; In normal mode, focused on element window, no caret
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX && SMMouseMoveTop()
h::send {WheelLeft}
j::send {WheelDown}
k::send {WheelUp}
l::send {WheelRight}
d::send {WheelDown 2}
u::send {WheelUp 2}

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX
r::send !{home}!{left} ; reload

f:: ; click on html component
	if !SMMouseMoveMiddle(true)
		send q
	send {home}
	; click 24 380
	; sleep 30
	; click 39 380
Return

; Open windows
c::send !c ; open content window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) && !A_CaretX
b::send ^{space} ; open browser
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX
o::send ^o ; favourites

; Navigation
+h::send !{left} ; go back in history
+l::send !{right} ; go forward in history
+j::send !{pgdn} ; J, gt: go down one element
+k::send !{pgup} ; K, gT: go up one element

t::send !n ; create new element

x::send ^+{del} ; delete current element
+x::send ^+{enter} ; done!

; Orginal SM shortcuts
~q:: ; focus to question field; smvim extract
~a:: ; focus to answer field; vim append
~e:: ; focus all fields; vim go forward
~^d:: ; dismiss; vim page down
~^j:: ; change interval; vim join lines
Return

#If Vim.IsVimGroup() and WinActive("ahk_class TElWind") && !A_CaretX and (Vim.State.IsCurrentVimMode("Vim_ydc_y"))
y:: ; yy: copy current source url
	send !{f10}fs
	WinWaitActive, Information
	if ErrorLevel
		return
	send p{esc}
	Vim.State.SetMode()
	ClipWait 1
	if InStr(Clipboard, "Link:") {
		RegExMatch(Clipboard, "Link: \K.*", link)
		Clipboard := link
	}
Return

t:: ; yt: duplicate current element
	send !d
	Vim.State.SetMode()
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TPlanDlg") || WinActive("ahk_class TTaskManager"))
s::
	ControlGetFocus, current_focus_plan, ahk_class TPlanDlg
	ControlGetFocus, current_focus_tasklist, ahk_class TTaskManager
	if current_focus_plan = TStringGrid1
		ClickDPIAdjusted(253, 48) ; *s*witch plan
	else if current_focus_tasklist = TStringGrid1
		ClickDPIAdjusted(153, 52) ; *s*witch tasklist
	else {
		send {del}
		Vim.State.SetMode("Insert")
	}
Return

; YouTube template
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start.png", "n o32", x_coord, y_coord)
m::FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start.png", "o32")

left::
right::
space::
	x_coord += 110
	y_coord -= 60
	CoordMode, Mouse, Screen
	click, %x_coord% %y_coord%
	send {%A_ThisHotkey%}
	if (A_ThisHotkey = "space") {
		sleep 350
		FindClick(A_ScriptDir . "\lib\bind\util\yt_more_videos_x.png", "o128")
	}
	send ^{t 2} ; focus to notes
Return