; Inspired by Vimium: https://github.com/philc/vimium

; In normal mode, focused on element window, no caret
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX
h::
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 10
		MouseMove, %x_coord%, %y_coord%
		send {WheelLeft}
	}
	; if IsSMEditingHTML()
		; send {left}
	; else
		; FindClick(A_ScriptDir . "\lib\bind\util\left_arrow.png")
Return
	
j::
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 10
		MouseMove, %x_coord%, %y_coord%
		send {WheelDown}
	}
Return

k::
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 10
		MouseMove, %x_coord%, %y_coord%
		send {WheelUp}
	}
Return

l::
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 10
		MouseMove, %x_coord%, %y_coord%
		send {WheelRight}
	}
Return

d::
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 10
		MouseMove, %x_coord%, %y_coord%
		send {WheelDown 2}
	}
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX and !(Vim.State.g)
u::
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_coord, y_coord)
	if x_coord {
		CoordMode, Mouse, Screen
		x_coord -= 10
		MouseMove, %x_coord%, %y_coord%
		send {WheelUp 2}
	}
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX
r::send !{home}!{left} ; reload

f:: ; click on html component
	FindClick(A_ScriptDir . "\lib\bind\util\up_arrow.png", "n", x_up, y_up)
	FindClick(A_ScriptDir . "\lib\bind\util\down_arrow.png", "n", x_down, y_down)
	if x_up {
		CoordMode, Mouse, Screen
		x_coord := x_up - 10
		y_coord := (y_up + y_down) / 2
		Click, %x_coord% %y_coord%
		send {home}
	} else
		send q{home}
	; click 24 380
	; sleep 30
	; click 39 380
Return

; Open windows
c::send !c ; open content window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) && !A_CaretX and !(Vim.State.g)
b::send ^{space} ; open browser
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX and !(Vim.State.g)
o::send ^o ; favourites

; Navigation
+h::send !{left} ; go back in history
+l::send !{right} ; go forward in history
+j::send !{pgdn} ; J, gt: go down one element
+k::send !{pgup} ; K, gT: go up one element

t::send !n ; create new element

x::send ^+{del} ; delete current element
+x::send ^+{enter} ; done!

m::send ^{f7} ; save read point
`::send !{f7} ; go to read point
+m::send ^+{f7} ; clear read point

; Orginal SM shortcuts
~q:: ; focus to question field; smvim extract
~a:: ; focus to answer field; vim append
~e:: ; focus all fields; vim go forward
~^d:: ; dismiss; vim page down
~^j:: ; change interval; vim join lines
Return

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
	}
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