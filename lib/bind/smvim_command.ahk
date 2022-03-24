#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command")) && WinActive("ahk_class TElWind")
c:: ; add new concept
	send {alt}er
	Vim.State.SetMode("Vim_Normal")
return

b:: ; remove all text *b*efore cursor
	send !\\
	WinWaitNotActive, ahk_class TElWind,, 0
	if !ErrorLevel
		send {enter}
	Vim.State.SetMode("Vim_Normal")
return

a:: ; remove all text *a*fter cursor
	send !.
	WinWaitNotActive, ahk_class TElWind,, 0
	if !ErrorLevel
		send {enter}
	Vim.State.SetMode("Vim_Normal")
return

f:: ; clean *f*ormat: using f6 (retaining tables)
	send {f6}
	WinWaitNotActive, ahk_class TElWind,, 0
	Vim.State.SetMode("Vim_Normal")
	if !ErrorLevel
		send ^arbs{enter}
return

l:: ; *l*ink concept
	send !{f10}cl
	Vim.State.SetMode("Vim_Normal")
return

+l:: ; list links
	send !{f10}cs
	Vim.State.SetMode("Vim_Normal")
return

w:: ; prepare *w*ikipedia articles in languages other than English
	Vim.State.SetMode("Vim_Normal")
	send ^t{esc} ; de-select all components
	clip_bak := Clipboardall
	Clipboard =
	send !{f10}fs ; show reference
	WinWaitActive, Information,, 0
	send p{esc} ; copy reference
	ClipWait 0.2
	sleep 20
	if !InStr(Clipboard, "wikipedia.org/wiki") {
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
	clip("en.wikipedia.org",, true) ; supermemo for some reason replaces the links for English wikipedia ones
	send {tab}
	clip(wiki_link,, true) ; so this script replaces them back
	send !a ; replace all
	send ^w ; close
	WinWaitActive, ahk_class #32770,, 0 ; do you want to save changes?
	if !ErrorLevel
		send {enter}
	if (wiki_link == "zh.wikipedia.org") {
		WinWaitActive, ahk_class TElWind,, 0
		send q
		Vim.SM.WaitTextFocus()
		send ^{home}{end}+{home}!t ; selecting first line
		WinWaitActive, ahk_class TChoicesDlg,, 2 ; sometimes it could take a really long time for the choice dialogue to pop up
		send 2{enter}{esc} ; makes selection title
	}
	Clipboard := clip_bak
return

i:: ; learn outstanding *i*tems only
	Vim.State.SetMode("Vim_Normal")
	send !{home}{esc 4} ; clear any hidden windows
	send !vo
	WinWaitActive, ahk_class TProgressBox,, 0
	if !ErrorLevel
		WinWaitNotActive, ahk_class TProgressBox,, 10
	WinWaitActive, ahk_class TBrowser,, 0
	send {AppsKey}ci
	WinWaitActive, ahk_class TProgressBox,, 0
	if !ErrorLevel
		WinWaitNotActive, ahk_class TProgressBox,, 10
	WinWaitActive, ahk_class TBrowser,, 0
	send ^l
return

r:: ; set *r*eference's link to what's in the clipboard
	Vim.State.SetMode("Vim_Normal")
	new_link := "#Link: " . Clipboard
	send !{f10}fe
	WinWaitActive, ahk_class TInputDlg,, 0
	send ^a^c
	ClipWait 0.2
	sleep 20 ; making sure copy works
	if InStr(Clipboard, "#Link: ")
		clip(RegExReplace(Clipboard, "(\n\K|^)#Link: .*", new_link))
	else {
		send ^{end}{enter}
		clip(new_link)
	}
	send !{enter}
	WinWaitActive, ahk_class TElWind,, 0
	if !ErrorLevel {
		send ^t{esc}q
		Vim.SM.WaitTextFocus()
		send ^{home}{esc} ; put caret in the start of question component and unfocus every component
	}
return

o:: ; c*o*mpress images
	send ^{enter}
	WinWaitActive, ahk_class TCommanderDlg,, 0
	SendInput {raw}co
	send {enter} ; Compress images
	Vim.State.SetMode("Vim_Normal")
return

s:: ; turn active language item to passive (*s*witch)
	Vim.State.SetMode("Vim_Normal")
	send ^t{esc} ; de-select every component
	ControlGetText, current_text, TBitBtn3
	if (current_text != "Learn") ; if learning (on "next repitition")
		send {esc}
	WinGetTitle, original_title, A
	send ^+s
	Vim.WinWaitTitleChange(original_title, 1)
	send q
	Vim.SM.WaitTextFocus()
	SendInput {raw}en:
	SendInput {space}{esc}a
	Vim.SM.WaitTextFocus()
	send ^{del 2}{esc}
return

p:: ; hyperlink to scri*p*t component
	Vim.State.SetMode("Vim_Normal")
	send !n ; new topic
	Vim.SM.WaitTextFocus()
	send ^v ; so the link is clickable
	send ^t{f9}{enter} ; opens script editor
	WinWaitActive, ahk_class TScriptEditor,, 0
	SendInput {raw}url
	send {space}^v ; paste the link
	send !o{esc} ; close script editor
return

m:: ; co*m*ment current element "audio"
	Vim.State.SetMode("Vim_Normal")
	ControlGetText, current_text, TBitBtn3
	if (current_text == "Next repetition") {
		continue_learning := true
	} else
		continue_learning := false
	send ^+p^a ; open element parameter and choose everything
	SendInput {raw}audio
	send {enter}
	if continue_learning {
		send {enter}
		continue_learning := false
	}
return

d:: ; learn all elements with the comment "au*d*io"
	Vim.State.SetMode("Vim_Normal")
	send !{home}{esc 4} ; escape potential hidden window
	send !soc ; open comment registry
	WinWaitActive, ahk_class TRegistryForm,, 0
	SendInput {raw}audio
	send !b ; browse all elements
	WinWaitActive, ahk_class TProgressBox,, 0
	if !ErrorLevel
		WinWaitNotActive, ahk_class TProgressBox,, 10
	WinWaitActive, ahk_class TBrowser,, 0
	send {AppsKey}co ; outstanding
	WinWaitActive, ahk_class TProgressBox,, 0
	if !ErrorLevel
		WinWaitNotActive, ahk_class TProgressBox,, 10
	WinWaitActive, ahk_class TBrowser,, 0
	send ^s ; sort
	WinWaitActive, ahk_class TProgressBox,, 0
	if !ErrorLevel
		WinWaitNotActive, ahk_class TProgressBox,, 10
	WinWaitActive, ahk_class TBrowser,, 0
	send ^l ; learn
	WinWaitActive, ahk_class TElWind,, 0
	loop {
		sleep 40
		ControlGetText, current_text, TBitBtn3
		if (current_text == "Next repetition") {
			send ^{f10}
			break
		}
		if (A_Index > 5)
			Break
	}
return

+p::
	send {alt}ep
	Vim.State.SetMode("Vim_Normal")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command")) && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents") || WinActive("ahk_class TBrowser"))
; Priority script, made by Naess and modified by Guillem
; Details: https://www.youtube.com/watch?v=OwV5HPKMrbg
; Picture explaination: https://raw.githubusercontent.com/rajlego/supermemo-ahk/main/naess%20priorities%2010-25-2020.png
!0::
Numpad0::
NumpadIns::
	Vim.SM.SetPriority(0.00,3.6076)
return

!1::
Numpad1::
NumpadEnd::
	Vim.SM.SetPriority(3.6077,8.4131)
return

!2::
Numpad2::
NumpadDown::
	Vim.SM.SetPriority(8.4132,18.4917)
return

!3::
Numpad3::
NumpadPgdn::
	Vim.SM.SetPriority(18.4918,28.0885)
return

!4::
Numpad4::
NumpadLeft::
	Vim.SM.SetPriority(28.0886,37.2103)
return

!5::
Numpad5::
NumpadClear::
	Vim.SM.SetPriority(37.2104,46.24)
return

!6::
Numpad6::
NumpadRight::
	Vim.SM.SetPriority(46.25,57.7575)
return

!7::
Numpad7::
NumpadHome::
	Vim.SM.SetPriority(57.7576,70.5578)
return

!8::
Numpad8::
NumpadUp::
	Vim.SM.SetPriority(70.5579,90.2474)
return

!9::
Numpad9::
NumpadPgup::
	Vim.SM.SetPriority(90.2474,99.99)
return