#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && WinActive("ahk_class TElWind"))
+c::  ; add new concept
  send {alt}er
  Vim.State.SetMode("Vim_Normal")
return

b::  ; remove all text *b*efore cursor
  send !\\
  WinWaitNotActive, ahk_class TElWind,, 0
  if (!ErrorLevel)
    send {enter}
  Vim.State.SetMode("Vim_Normal")
return

a::  ; remove all text *a*fter cursor
  send !.
  WinWaitNotActive, ahk_class TElWind,, 0
  if (!ErrorLevel)
    send {enter}
  Vim.State.SetMode("Vim_Normal")
return

f::  ; clean *f*ormat: using f6 (retaining tables)
  Vim.State.SetMode("Vim_Normal")
  send {f6}^arbs{enter}
return

; "Transcribed" from this quicker script:
; https://getquicker.net/Sharedaction?code=859bda04-fe78-4385-1b37-08d88a0dba1c
SMCleanHTML:
+f::  ; clean format directly in html source
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.IsLearning()) {
    ContinueLearning := true
  } else {
    ContinueLearning := false
  }
  ; save read point
	send !g^{f7}  ; !g in case it's learning
  if (Vim.SM.IsEditingPlainText())
    Return
  if (!Vim.SM.IsEditingHTML()) {
    send ^t
    Vim.SM.WaitTextFocus()
    if (!Vim.SM.IsEditingHTML())
      Return
  }
  send {esc}
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  Vim.SM.WaitTextExit()
  WinWaitActive, ahk_class TElWind,, 0  ; sometimes, if a processing box appears, the next line may not be sent
  send !{f12}fc  ; copy file path
  ClipWait, LongCopy ? 0.6 : 0.2, True
  HTMLPath := Clipboard
  FileRead, HTML, % HTMLPath
  if (!HTML) {
    WinClip.Restore(ClipData)
    Return
  }
  NewHTML := Vim.HTML.Clean(HTML)
  FileDelete % HTMLPath
  FileAppend, % NewHTML, % HTMLPath
  Vim.SM.SaveHTML()
  Vim.SM.ClickMid()
  send {esc}
  if (ContinueLearning)
    ControlSend, TBitBtn2, {enter}
  WinClip.Restore(ClipData)
Return

l::  ; *l*ink concept
  send !{f10}cl
  Vim.State.SetMode("Vim_Normal")
return

+l::  ; list links
  send !{f10}cs
  Vim.State.SetMode("Vim_Normal")
return

w::  ; prepare *w*ikipedia articles in languages other than English
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.IsEditingPlainText())
    return
  ; save read point
	send !g^{f7}  ; !g in case it's learning
  if (!Vim.SM.IsEditingHTML()) {
    send ^t
    Vim.SM.WaitTextFocus()
    if (!Vim.SM.IsEditingHTML())
      return
  }
  Vim.SM.SaveHTML()  ; making sure the html path is correct
  send {esc}
  Vim.SM.WaitTextExit()  ; making changes to the html file requires not editing html in SM
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send !{f10}tc  ; copy template
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (InStr(Clipboard, "Link:")) {
    RegExMatch(Clipboard, "(?<=#Link: <a href="").*(?="")", Link)  ; RegExMatch cannot store into clipboard
    if (!InStr(Link, "wikipedia.org/wiki")) {
      Vim.ToolTip("Not Wikipedia!")
      WinClip.Restore(ClipData)
      return
    }
    if (InStr(Link, "en.wikipedia.org")) {
      Vim.ToolTip("English Wikipedia doesn't need to be prepared!")
      WinClip.Restore(ClipData)
      return
    }
  } else {
    Vim.ToolTip("No reference.")
    WinClip.Restore(ClipData)
    return
  }
  RegExMatch(Link, "(?<=https:\/\/)(.*?)(?=\/wiki\/)", WikiLink)
  RegExMatch(clipboard, "HTMFile=\K.*", FilePath)
  FileRead, HTML, % FilePath
  HTML := StrReplace(HTML, "en.wikipedia.org", WikiLink)
  FileDelete % FilePath
  FileAppend, % HTML, % FilePath
  Vim.SM.SaveHTML()
  if (WikiLink == "zh.wikipedia.org" || WikiLink == "fr.wikipedia.org" || WikiLink == "la.wikipedia.org") {
    Vim.SM.WaitTextFocus()
    send ^{home}{end}+{home}!t  ; selecting first line
    WinWaitActive, ahk_class TChoicesDlg,, 2  ; sometimes it could take a really long time for the choice dialogue to pop up
    if (!ErrorLevel)
      send 2{enter}  ; makes selection title
    send {esc}
  } else {
    Vim.SM.ClickMid()
    send {esc}
  }
  WinClip.Restore(ClipData)
return

i::  ; learn outstanding *i*tems only
  Vim.State.SetMode("Vim_Normal")
  SetDefaultKeyboard(0x0409)  ; english-US	
  send !{home}{esc 4}  ; clear any hidden windows
  send !vo
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}ci
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send ^l
return

+i::  ; learn current element's outstanding child item
  Vim.State.SetMode("Vim_Normal")
  SetDefaultKeyboard(0x0409)  ; english-US	
  send ^{space}
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}ci
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}co
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send ^s
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send ^+l
return

SMSetLinkFromClipboard:
r::  ; set *r*eference's link to what's in the clipboard
  Vim.State.SetMode("Vim_Normal")
  WinClip.Snap(ClipData)
  NewLink := "`n#Link: " . Clipboard . "`n"
  send !{f10}fe
  WinWaitActive, ahk_class TInputDlg,, 0
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^a^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (InStr(Clipboard, "#Link")) {
    NewRef := RegExReplace(Clipboard, "#Link: .*", NewLink)
  } else {
    NewRef := Clipboard . NewLink
  }
  if (BrowserSource) {
    NewSource := "`n#Source: " . BrowserSource . "`n"
    if (InStr(NewRef, "#Source")) {
      NewRef := RegExReplace(NewRef, "#Source: .*", NewSource)
    } else {
      NewRef .= NewSource
    }
  }
  if (BrowserDate) {
    NewDate := "`n#Date: " . BrowserDate . "`n"
    if (InStr(NewRef, "#Date")) {
      NewRef := RegExReplace(NewRef, "#Date: .*", BrowserDate)
    } else {
      NewRef .= NewDate
    }
  }
  clip(NewRef,, true)
  send !{enter}
  WinWaitActive, ahk_class TElWind,, 0
  if (BrowserTitle && WinActive("ahk_class TElWind")) {
    if (!Vim.SM.IsEditingText())
      send q
    Vim.SM.WaitTextFocus()
    send ^{end}{enter}
    clip(BrowserTitle,, true)
    MouseGetPos, XCoord, YCoord
    send +{home}
    WaitCaretMove(XCoord, YCoord)
    send !t  ; set title
		WinWaitNotActive, ahk_class TElWind,, 0.25  ; could appear a loading bar
		if (!ErrorLevel)
			WinWaitActive, ahk_class TElWind,, 5
  }
  WinClip.Restore(ClipData)
  BrowserTitle := BrowserSource := BrowserDate := ""
return

o::  ; c*o*mpress images
  send ^{enter}
  SendInput {raw}co  ; Compress images
  send {enter}
  Vim.State.SetMode("Vim_Normal")
return

s::  ; turn active language item to passive (*s*witch)
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.DeselectAllComponents()
  if (ControlGetText("TBitBtn3") != "Learn")  ; if learning (on "next repitition")
    send {esc}
  WinGetActiveTitle, CurrentTitle
  send ^+s
  WinWaitTitleChange(CurrentTitle, 500)
  send q
  Vim.SM.WaitTextFocus(500)
  ControlGetFocus, CurrentControl, A
  send ^{home}en:{space}^t
  ControlWaitNotFocus(CurrentControl)
  if (Vim.SM.IsEditingHTML()) {
    send ^{home}^{del 2}
  } else if (Vim.SM.IsEditingPlainText()) {
    send ^{home}^{del}
  }
  send {esc}
return

+s::
  ReleaseKey("shift")
  Vim.State.SetMode("Vim_Normal")
  WinClip.Snap(ClipData)
  Vim.SM.DeselectAllComponents()
  if (ControlGetText("TBitBtn3") != "Learn")  ; if learning (on "next repitition")
    send {esc}
  send q
  Vim.SM.WaitTextFocus(500)
  if (Vim.SM.IsEditingHTML()) {
    send ^{home}^+{right 2}^x
  } else if (Vim.SM.IsEditingPlainText()) {
    send ^{home}^+{right}^x
  }
  send {esc}
  Vim.SM.WaitTextExit()
  WinGetActiveTitle, CurrentTitle
  send ^+s
  WinWaitTitleChange(CurrentTitle, 500)
  send q
  Vim.SM.WaitTextFocus(500)
  send ^v{left 2}{esc}
  WinClip.Restore(ClipData)
return

p::  ; hyperlink to scri*p*t component
  CollectionName := Vim.SM.GetCollectionName()
  send !n  ; new topic
  if (!Vim.SM.WaitTextFocus(5000))
    return
  if (CollectionName = "passive" || CollectionName = "music" || CollectionName = "bgm") {
    Vim.State.SetMode("Vim_Normal")
    send ^v  ; so the link is clickable
    send ^t{f9}{enter}  ; opens script editor
    send url{space}^v  ; paste the link
    send !o{esc}  ; close script editor
    if (BrowserTitle)
      Vim.SM.SetTitle(BrowserTitle)
    BrowserTitle := BrowserSource := BrowserDate := BrowserUrl := ""
  } else if (CollectionName = "gaming") {
    gosub SMSetLinkFromClipboard
    Vim.State.SetMode("Insert")
    send ^{home}
  } else {  ; for now everything else is treated like standard topics and links
    gosub SMSetLinkFromClipboard
    Vim.State.SetMode("Insert")
    send ^{home}
  }
return

m::  ; co*m*ment current element "audio"
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.IsLearning()) {
    ContinueLearning := true
  } else {
    ContinueLearning := false
  }
  send ^+p^a  ; open element parameter and choose everything
  SendInput {raw}audio
  send {enter}
  if (ContinueLearning)
    send {enter}
return

d::  ; learn all elements with the comment "au*d*io"
  Vim.State.SetMode("Vim_Normal")
  send !{home}{esc 4}  ; escape potential hidden window
  send !soc  ; open comment registry
  WinWaitActive, ahk_class TRegistryForm,, 0
  SendInput {raw}audio
  send !b  ; browse all elements
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}co  ; outstanding
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send ^s  ; sort
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send ^l  ; learn
  WinWaitActive, ahk_class TElWind,, 0
  loop {
    sleep 40
    if (Vim.SM.IsLearning()) {
      send ^{f10}
      Return
    }
    if (A_Index > 5)
      Return
  }
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")))
c::  ; learn child
  Vim.State.SetMode("Vim_Normal")
  send ^{space}
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}co
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel) {
    WinWaitNotActive, ahk_class TProgressBox,, 10
  } else {
    sleep 300
  }
  WinWaitActive, ahk_class TBrowser,, 0
  send ^s
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send ^l
  WinWaitActive, ahk_class TElWind,, 1
  Vim.SM.PlayIfCertainCollection()
return

#if ((Vim.IsVimGroup()
      && Vim.State.IsCurrentVimMode("Command")
      && (WinActive("ahk_class TElWind")
          || WinActive("ahk_class TContents")
          || WinActive("ahk_class TBrowser")))
     || Vim.SM.IsLearning())  ; so you can just press numpads when you finished grading
; Priority script, made by Naess and modified by Guillem
; Details: https://www.youtube.com/watch?v=OwV5HPKMrbg
; Picture explaination: https://raw.githubusercontent.com/rajlego/supermemo-ahk/main/naess%20priorities%2010-25-2020.png
!0::
Numpad0::
NumpadIns::Vim.SM.SetPriority(0.00,3.6076)

!1::
Numpad1::
NumpadEnd::Vim.SM.SetPriority(3.6077,8.4131)

!2::
Numpad2::
NumpadDown::Vim.SM.SetPriority(8.4132,18.4917)

!3::
Numpad3::
NumpadPgdn::Vim.SM.SetPriority(18.4918,28.0885)

!4::
Numpad4::
NumpadLeft::Vim.SM.SetPriority(28.0886,37.2103)

!5::
Numpad5::
NumpadClear::Vim.SM.SetPriority(37.2104,46.24)

!6::
Numpad6::
NumpadRight::Vim.SM.SetPriority(46.25,57.7575)

!7::
Numpad7::
NumpadHome::Vim.SM.SetPriority(57.7576,70.5578)

!8::
Numpad8::
NumpadUp::Vim.SM.SetPriority(70.5579,90.2474)
  
!9::
Numpad9::
NumpadPgup::Vim.SM.SetPriority(90.2474,99.99)