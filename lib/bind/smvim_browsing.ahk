; Hotkeys in this file are inspired by Vimium: https://github.com/philc/vimium

; g state on top to have higher priority
; putting those below would make gu stops working (u also triggers scroll up)

; Element window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() and !(Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() and (Vim.State.g)
g::Vim.Move.Move("g") ; 3gg goes to the 3rd line of entire text

s:: ; gs: go to source link
	clip_bak := Clipboardall
	Clipboard =
	send !{f10}fs ; show reference
	WinWaitActive, Information,, 0
	send p{esc} ; copy reference
	Vim.State.SetNormal()
	ClipWait 0.2
	sleep 20
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
+e:: ; K, gE: go up one *e*lement
	send !{pgup}
	Vim.State.SetMode()
Return

e:: ; J, ge: go down one *e*lement
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

; g state, for both browsing and editing
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") and (Vim.State.g)
c:: ; gc: go to next *c*omponent
	send ^t
	Vim.State.SetMode()
Return

+c:: ; gC: go to previous *c*omponent
	send !{f12}fl
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
+g::Vim.Move.Move("+g") ; 3G goes to the 3rd line on screen
{::Vim.Move.Move("{")
}::Vim.Move.Move("}")

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
+j::send !{pgdn} ; J, ge: go down one element
+k::send !{pgup} ; K, gE: go up one element

; Open windows
c::send !c ; open content window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) && !Vim.SM.IsEditingText()
b::send ^{space} ; open browser
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
o::send ^o ; favourites

+e::
	clip_bak := Clipboardall
	clipboard =
	send ^t!{f12}fc
	ClipWait 0.2
	sleep 20
	send {esc}
	run, %A_StartMenu%\Programs\Visual Studio Code\Visual Studio Code.lnk %Clipboard%
	clipboard := clip_bak
Return
	

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
~^d:: ; dismiss; vim scroll down
~^j:: ; change interval; vim join lines
~^f:: ; find; vim page down
~^v:: ; paste image; vim visual block
~^r:: ; replace; vim redo
~^+p:: ; element parameter; vim_ahk paste without format
Return

; Copy mode
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_ydc_y")) && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
y:: ; yy: copy current source url
	clip_bak := Clipboardall
	Clipboard =
	send !{f10}fs ; show reference
	WinWaitActive, Information,, 0
	send p{esc} ; copy reference
	Vim.State.SetNormal()
	ClipWait 0.2
	sleep 20
	if InStr(Clipboard, "Link:") {
		RegExMatch(Clipboard, "Link: \K.*", link)
		Clipboard := link
	}
	Vim.ToolTipFunc("Copied " . link)
Return

e:: ; ye: duplicate current element
	send !d
	Vim.State.SetNormal()
Return

; Plan/tasklist window
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingPlan()
s::ClickDPIAdjusted(253, 48) ; *s*witch plan
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingTask()
s::ClickDPIAdjusted(153, 52) ; *s*witch tasklist

; For incremental YouTube
; Need "Start" button on screen
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && (FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start.png", "n o32", x_coord, y_coord) || FindClick(A_ScriptDir . "\lib\bind\util\sm_yt_start_hover.png", "n o32", x_coord, y_coord))
m::
	CoordMode, Mouse, Screen
	click, %x_coord% %y_coord% ; click start (similar to mark read point)
Return

`::
	x_coord += 170
	CoordMode, Mouse, Screen
	click, %x_coord% %y_coord% ; click play (similar to go to read point)
Return

!m::
	x_coord += 195
	CoordMode, Mouse, Screen
	click, %x_coord% %y_coord% ; click reset (similar to clear read point)
Return

left:: ; left 5s
right:: ; right 5s
	x_coord += 110
	y_coord -= 60
	CoordMode, Mouse, Screen
	click, %x_coord% %y_coord%
	send {%A_ThisHotkey%}^{t 2} ; focus to notes
Return

!y:: ; focus to youtube video
	x_coord += 110
	y_coord -= 60
	CoordMode, Mouse, Screen
	click, %x_coord% %y_coord%
	Vim.State.SetMode("Insert") ; insert so youtube can read keys like j, l, etc
Return

!k:: ; pause
	x_coord += 110
	y_coord -= 60
	CoordMode, Mouse, Screen
	click, %x_coord% %y_coord%
	send k
	sleep 350
	FindClick(A_ScriptDir . "\lib\bind\util\yt_more_videos_right.png", "o64 x-10 y-60")
Return