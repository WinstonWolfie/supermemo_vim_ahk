; Grading
Grading() {
	ControlGetFocus, current_focus, ahk_class TElWind
	; if focused on either 5 of the grading buttons or the cancel button
	return (current_focus = "TBitBtn4" || current_focus = "TBitBtn5" || current_focus = "TBitBtn6" || current_focus = "TBitBtn7" || current_focus = "TBitBtn8" || current_focus = "TBitBtn9")
}

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Grading()
a::
    send 1
    sleep 40
    send {space} ; next item
return	

s::
	send 2
	sleep 40
	send {space} ; next item
return

d::
	send 3
	sleep 40
	send {space} ; next item
return

f::
    send 4
    sleep 40
    send {space} ; next item
return

g::
    send 5
    sleep 40
    send {space} ; next item
return