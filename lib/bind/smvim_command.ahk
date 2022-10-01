#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && WinActive("ahk_class TElWind"))
+c::  ; add new concept
  Vim.SM.PostMsg(126)
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

NukeHTML:
+f::  ; clean format directly in html source
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.IsEditingPlainText())
    return
	send ^{f7}  ; save read point
  if (!Vim.SM.IsEditingHTML()) {
    send ^t
    Vim.SM.WaitTextFocus()
    if (!Vim.SM.IsEditingHTML())
      return
  }
  send {esc}
  Vim.SM.WaitTextExit()
  HTMLPath := Vim.SM.GetFilePath()
  FileRead, HTML, % HTMLPath
  if (!HTML)
    return
  FileDelete % HTMLPath
  FileAppend, % Vim.HTML.Clean(HTML, (A_ThisLabel == "NukeHTML")), % HTMLPath
  Vim.SM.SaveHTML()
  Vim.SM.ClickMid()
  send {esc}
Return

l::  ; *l*ink concept
  Vim.SM.PostMsg(644, true)
  Vim.State.SetMode("Vim_Normal")
return

+l::  ; list links
  Vim.SM.PostMsg(652, true)
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
  link := Vim.SM.GetLink()
  if (link) {
    if (!InStr(Link, "wikipedia.org/wiki")) {
      ToolTip("Not Wikipedia!")
      return
    }
    if (InStr(Link, "en.wikipedia.org")) {
      ToolTip("English Wikipedia doesn't need to be prepared!")
      return
    }
  } else {
    ToolTip("No reference.")
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
  send !{home}{esc 4}  ; clear any hidden windows
  Vim.SM.PostMsg(202)  ; View - Outstanding
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}
  send {text}ci
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send ^l
return

+i::  ; learn current element's outstanding child item
  Vim.State.SetMode("Vim_Normal")
  send ^{space}
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}
  send {text}ci
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}
  send {text}co
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

o::  ; c*o*mpress images
  send ^{enter}  ; open commander
  send {text}co  ; Compress images
  send {enter}
  Vim.State.SetMode("Vim_Normal")
return

s::  ; turn active language item to passive (*s*witch)
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.DeselectAllComponents()
  if (ControlGetText("TBitBtn3") != "Learn")  ; if learning (on "next repitition")
    send {esc}
  WinGetActiveTitle, CurrTitle
  send ^+s
  WinWaitTitleChange(CurrTitle, 1000)
  sleep 1000  ; for unknown reason this large amount of delay would work, not otherwise
  send q
  Vim.SM.WaitTextFocus(1000)
  ControlGetFocus, CurrControl
  send ^{home}en:{space}^t
  ControlWaitNotFocus(CurrControl)
  if (Vim.SM.IsEditingHTML()) {
    send ^{home}^{del 2}
  } else if (Vim.SM.IsEditingPlainText()) {
    send ^{home}^{del}
  }
  send {esc}
return

+s::
  KeyWait shift
  Vim.State.SetMode("Vim_Normal")
  WinClip.Snap(ClipData)
  Vim.SM.DeselectAllComponents()
  if (ControlGetText("TBitBtn3") != "Learn")  ; if learning (on "next repitition")
    send {esc}
  send q
  Vim.SM.WaitTextFocus(1000)
  if (Vim.SM.IsEditingHTML()) {
    send ^{home}^+{right 2}^x
  } else if (Vim.SM.IsEditingPlainText()) {
    send ^{home}^+{right}^x
  }
  send {esc}
  Vim.SM.WaitTextExit()
  WinGetActiveTitle, CurrTitle
  send ^+s
  WinWaitTitleChange(CurrTitle, 1000)
  send q
  Vim.SM.WaitTextFocus(1000)
  send ^v{left 2}{esc}
  WinClip.Restore(ClipData)
return

p::  ; hyperlink to scri*p*t component
  Vim.State.SetMode("Vim_Normal")
SMHyperLinkToTopic:
  send !n  ; new topic
  if (!Vim.SM.WaitTextFocus())
    return
  gosub SMSetLinkFromClipboard
  if (Vim.SM.IsPassiveCollection()) {
    send ^t{f9}{enter}  ; opens script editor
    WinWaitActive, ahk_class TScriptEditor,, 0
    script := "url " . Clipboard
    sec := ""
    if (Vim.Browser.VidTime && Vim.SM.GetCollectionName() != "music") {
      sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime)
      if (InStr(Vim.Browser.url, "youtube.com")) {
        script .= "&t=" . sec . "s"
      } else if (InStr(Vim.Browser.url, "bilibili.com")) {
        script .= "?&t=" . sec
      }
    }
    ControlSetText, TMemo1, % script
    send !o{esc 2}  ; close script editor
    ToolTip("Time stamp in script component set as " . sec . "s")
  }
  Vim.Browser.Clear()
return

r::  ; set *r*eference's link to what's in the clipboard
  Vim.State.SetMode("Vim_Normal")
SMSetLinkFromClipboard:
  ; Vim.SM.PostMsg(961, true)
  ; Somehow PostMessage doesn't work reliably here
  send !{f10}fe  ; open registry editor
  WinWaitActive, ahk_class TInputDlg,, 3
  ControlGetText, OldRef, TMemo1
  NewLink := "#Link: " . Clipboard
  if (InStr(OldRef, "#Link")) {
    NewRef := RegExReplace(OldRef, "#Link: .*", NewLink)
  } else {
    NewRef := OldRef . "`r`n" . NewLink
  }
  if (Vim.Browser.title) {
    NewTitle := "#Title: " . Vim.Browser.title
    if (InStr(NewRef, "#Title")) {
      NewRef := RegExReplace(NewRef, "#Title: .*", NewTitle)
    } else {
      NewRef .= "`r`n" . NewTitle
    }
  }
  if (Vim.Browser.source) {
    NewSource := "#Source: " . Vim.Browser.source
    if (InStr(NewRef, "#Source")) {
      NewRef := RegExReplace(NewRef, "#Source: .*", NewSource)
    } else {
      NewRef .= "`r`n" . NewSource
    }
  }
  if (Vim.Browser.date) {
    NewDate := "#Date: " . Vim.Browser.date
    if (InStr(NewRef, "#Date")) {
      NewRef := RegExReplace(NewRef, "#Date: .*", NewDate)
    } else {
      NewRef .= "`r`n" . NewDate
    }
  }
  NewRef := StrReplace(NewRef, "#Comment: References will be downloaded in a separate thread")
  if (Vim.Browser.comment) {
    NewComment := "#Comment: " . Vim.Browser.comment
    if (InStr(NewRef, "#Comment")) {
      NewRef := RegExReplace(NewRef, "#Comment: .*$", Vim.Browser.comment)
    } else {
      NewRef .= "`r`n" . NewComment
    }
  }
  ControlSetText, TMemo1, % NewRef
  send !{enter}
  WinWaitActive, ahk_class TElWind,, 1
  if (Vim.Browser.title && WinActive("ahk_class TElWind"))
    Vim.SM.SetTitle(Vim.Browser.title)
  if (A_ThisLabel != "SMSetLinkFromClipboard")
    Vim.Browser.Clear()
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
    || Vim.SM.IsLearning()  ; so you can just press numpads when you finished grading
    || (WinActive("SuperMemo Import") && WinActive("ahk_class AutoHotkeyGUI"))
    || (WinActive("Priority") && WinActive("ahk_class #32770"))
    || (WinActive("ahk_class TPriorityDlg")))
; Priority script, originally made by Naess and modified by Guillem
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