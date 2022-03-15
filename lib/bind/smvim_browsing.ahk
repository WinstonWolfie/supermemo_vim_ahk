; Hotkeys in this file are inspired by Vimium: https://github.com/philc/vimium

; g state on top to have higher priority
; putting those below would make gu stops working (u also triggers scroll up)

; Element window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() and !(Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() and (Vim.State.g)
g::Vim.Move.Move("g")

f:: ; gf: go to next component
	send ^t
	Vim.State.SetMode()
Return

+f:: ; gF: go to previous component
	send !{f12}fl
	Vim.State.SetMode()
Return

s:: ; gs: go to source link
	send !{f10}fs
	WinWaitActive, Information
	if ErrorLevel
		return
	clip_bak := Clipboardall
	send p{esc}
	Vim.State.SetMode()
	ClipWait 1
	if InStr(Clipboard, "Link:") {
		RegExMatch(Clipboard, "Link: \K.*", link)
		Clipboard := clip_bak ; restore clipboard here in case Run doesn't work
		run % link
	} else {
		Vim.ToolTipFunc("No link found.")
		Clipboard := clip_bak
	}
Return

; Element/content window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) && !Vim.SM.IsEditingText() and (Vim.State.g)
+t:: ; K, gT: go up one element
	send !{pgup}
	Vim.State.SetMode()
Return

t:: ; J, gt: go down one element
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

; Element window / browser
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TBrowser")) && !Vim.SM.IsEditingText() and (Vim.State.g)
+u:: ; gU: click source button
	if WinActive("ahk_class TElWind")
		FindClick(A_ScriptDir . "\lib\bind\util\source_element_window.png")
	else
		FindClick(A_ScriptDir . "\lib\bind\util\source_browser.png")
	Vim.State.SetMode()
Return

; Need scrolling bar present
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() && Vim.SM.MouseMoveTop()
; Scrolling
h::send {WheelLeft}
j::send {WheelDown}
k::send {WheelUp}
l::send {WheelRight}
d::send {WheelDown 2}
u::send {WheelUp 2}

; "Browsing" mode
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
+g::Vim.Move.Move("+g")

; OG Vim commands
i::Vim.State.SetMode("Insert")
:::Vim.State.SetMode("Command") ;(:)

; Browser-like actions
r::send !{home}!{left} ; reload
t::send !n ; create new element
x::send {del} ; delete element/component
+x::send ^+{enter} ; done!
p::send ^{f10} ; replay auto-play
+p::send ^{t 2}{f9} ; play video in default system player / edit script component

; Element navigation
+h::send !{left} ; go back in history
+l::send !{right} ; go forward in history
+j::send !{pgdn} ; J, gt: go down one element
+k::send !{pgup} ; K, gT: go up one element

; Open windows
c::send !c ; open content window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) && !Vim.SM.IsEditingText()
b::send ^{space} ; open browser
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
o::send ^o ; favourites

f:: ; click on html component
	if Vim.SM.MouseMoveTop(true)
		send {left}{home}
	else
		send q^{home}
Return

; Orginal SM shortcuts
~q:: ; focus to question field; smvim extract
~a:: ; focus to answer field; vim append
~e:: ; focus all fields; vim go forward
~^d:: ; dismiss; vim page down
~^j:: ; change interval; vim join lines
~^f:: ; find
~^v:: ; paste image
Return

; Copy mode
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_ydc_y")) && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
y:: ; yy: copy current source url
	send !{f10}fs
	WinWaitActive, Information
	if ErrorLevel
		return
	send p{esc}
	Vim.State.SetNormal()
	ClipWait 1
	if InStr(Clipboard, "Link:") {
		RegExMatch(Clipboard, "Link: \K.*", link)
		Clipboard := link
	}
Return

t:: ; yt: duplicate current element
	send !d
	Vim.State.SetNormal()
Return

; Plan/tasklist window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TPlanDlg") || WinActive("ahk_class TTaskManager")) && !A_CaretX
s:: ; *s*witch
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