#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
`;::Vim.State.SetMode("Command") ;(;)
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
  Send, ^s
  Send, !{F4}
  Vim.State.SetMode("Insert")
Return

Space::
  Send, !fa
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_q"))
Return::
  Send, !{F4}
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command")) && WinActive("ahk_class TElWind")
c:: ; add new concept
	send {alt}er
	Vim.State.SetMode("Vim_Normal")
return

b:: ; remove all text *b*efore cursor
	send !\\
	WinWaitActive, ahk_class TMsgDialog,, 0
	if !ErrorLevel
		send {enter}
	Vim.State.SetMode("Vim_Normal")
return

a:: ; remove all text *a*fter cursor
	send !.
	WinWaitActive, ahk_class TMsgDialog,, 0
	if !ErrorLevel
		send {enter}
	Vim.State.SetMode("Vim_Normal")
return

f:: ; clean *f*ormat: using f6 (retaining tables)
	send {f6}^arbs{enter}
	Vim.State.SetMode("Vim_Normal")
return

l:: ; *l*ink concept
	send !{f10}cl
	Vim.State.SetMode("Vim_Normal")
return

w:: ; prepare *w*ikipedia articles in languages other than English
	Vim.State.SetMode("Vim_Normal")
	send ^t{esc} ; de-select all components
	clipSave := Clipboardall
	Clipboard =
	send !{f10}fs ; show reference
	WinWaitActive, ahk_class TMsgDialog,, 0
	send p{esc} ; copy reference
	if InStr(Clipboard, "wikipedia.org/wiki") {
		MsgBox, Not wikipedia!
		return
	}
	if InStr(Clipboard, "en.wikipedia.org") {
		MsgBox, English wikipedia doesn't need to be prepared!
		return
	}
	RegExMatch(Clipboard, "(?<=Link: https:\/\/)(.*?)(?=\/wiki\/)", wiki_link)
	send ^+{f6}
	WinWaitActive, ahk_class Notepad,, 2
	if ErrorLevel
		return
	send ^h ; replace
	WinWaitActive, Replace,, 0
	clip("en.wikipedia.org") ; supermemo for some reason replaces the links for English wikipedia ones
	send {tab}
	clip(wiki_link) ; so this script replaces them back
	send !a ; replace all
	send ^w ; close
	WinWaitActive, ahk_class #32770,, 0 ; do you want to save changes?
	if !ErrorLevel
		send {enter}
	if (wiki_link = "zh.wikipedia.org") {
		WinWaitActive, ahk_class TElWind,, 0
		send q
		sleep 200
		send ^{home}{end}+{home}!t ; selecting first line
		WinWaitActive, ahk_class TChoicesDlg,, 2
		send 2{enter}{esc} ; makes selection title
	}
	Clipboard := clipSave
return

i:: ; learn outstanding *i*tems only
	Vim.State.SetMode("Vim_Normal")
	WinActivate ahk_class TElWind
	send !{home}
	sleep 100
	send {esc 4}{alt}vo
	sleep 1200
	send {AppsKey}ci
	sleep 1000
	send ^l
return

r:: ; set *r*eference's link to what's in the clipboard
	Vim.State.SetMode("Vim_Normal")
	new_link = #Link: %Clipboard%
	send !{f10}fe
	WinWaitActive, ahk_class TInputDlg,, 0
	send ^a^c
	ClipWait 1
	sleep 100 ; making sure copy works
	if InStr(Clipboard, "#Link: ")
		clip(RegExReplace(Clipboard, "(\n\K|^)#Link: .*", new_link))
	else {
		send ^{end}{enter}
		clip(new_link)
	}
	send !{enter}
	WinWaitActive, ahk_class TELWind,, 0
	if !ErrorLevel {
		send ^t{esc}q
		sleep 100
		send ^{home}{esc} ; put caret in the start of question component and unfocus every component
	}
return

o:: ; c*o*mpress images
	send ^{enter}
	WinWaitActive, ahk_class TCommanderDlg,, 0
	send co{enter} ; Compress images
	Vim.State.SetMode("Vim_Normal")
return

s:: ; turn active language item to passive (*s*witch)
	Vim.State.SetMode("Vim_Normal")
	send ^t{esc} ; de-select every component
	ControlGetText, current_text, TBitBtn3
	if (current_text != "Learn") ; if learning (on the stage of "next repitition")
		send {esc}
	send ^+s
	sleep 450 ; delay to make sure the switch works; also to update the title
	send q
	sleep 10
	send en:{space}{tab}
	sleep 150
	send ^{del 2}{esc}
return

p:: ; hyperlink to scri*p*t component
	Vim.State.SetMode("Vim_Normal")
	send !{home} ; go to root element
	sleep 100
	send !{f10}u ; uncheck autoplay
	send !n ; new topic
	; send ^+m ; disable if default topic template is script
	; sleep 100
	; SendInput {raw}script
	; send {enter}
	sleep 460 ; some delay to avoid autoplay
	send {ctrl down}v{ctrl up} ; so the link is clickable
	sleep 20
	send ^t{f9}{enter} ; opens script editor
	sleep 20
	send url{space} ; paste the link
	send ^v
	send !o{esc} ; close script editor
	send !{f10}u ; check
return

m:: ; co*m*ment current element "audio"
Vim.State.SetMode("Vim_Normal")
	ControlGetText, currentText, TBitBtn3
	if (currentText = "Next repetition") {
		continue_learning = 1
		send !{f10}u
	} else
		continue_learning = 0
	send ^+p^a ; open element parameter and choose everything
	SendInput {raw}audio
	send {enter}
	if (continue_learning = 1) {
		continue_learning = 0
		send {enter}
		sleep 500
		send !{f10}u
	}
return

d:: ; learn all elements with the comment "au*d*io"
	Vim.State.SetMode("Vim_Normal")
	send !{home}
	sleep 100
	send !{f10}u ; uncheck autoplay
	send {esc 4} ; escape potential hidden window
	send {alt}soc ; open comment registry
	sleep 500
	SendInput {raw}audio
	send !b ; browse all elements
	sleep 1000
	send {AppsKey}co ; outstanding
	sleep 500
	send ^s ; sort
	sleep 500
	send ^l ; learn
	sleep 500
	send !{f10}u ; check autoplay
	send ^{f10} ; play
return