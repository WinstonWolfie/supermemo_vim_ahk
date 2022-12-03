#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && WinActive("ahk_class TElWind"))
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
    if (!Vim.SM.IsEditingHTML()) {
      ToolTip("Text not found.")
      return
    }
  }
  send {esc}
  Vim.SM.WaitTextExit()
  HTMLPath := Vim.SM.GetFilePath()
  FileRead, HTML, % HTMLPath
  if (!HTML)
    return
  if (A_ThisLabel == "NukeHTML" && RegExMatch(HTML, "i)<.*?\K class=(extract|clozed?)(?=.*?>)")) {
    MsgBox, 4,, HTML has SM classes. Continue?
    IfMsgBox, no
      return
  }
  FileDelete % HTMLPath
  FileAppend, % Vim.HTML.Clean(HTML, (A_ThisLabel == "NukeHTML")), % HTMLPath
  Vim.SM.SaveHTML()
  Vim.SM.ClickMid()
  send {esc}
Return

l::  ; *l*ink concept
  send !{f10}cl
  ; Vim.SM.PostMsg(644, true)
  Vim.State.SetMode("Vim_Normal")
return

+l::  ; list links
  send !{f10}cs
  ; Vim.SM.PostMsg(652, true)
  Vim.State.SetMode("Vim_Normal")
return

w::  ; prepare *w*ikipedia articles in languages other than English
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.IsEditingPlainText())
    return
	send !g  ; in case it's learning
	send ^{f7}  ; save read point
  if (!Vim.SM.IsEditingHTML()) {
    send ^t
    Vim.SM.WaitTextFocus()
    if (!Vim.SM.IsEditingHTML())
      return
  }
  Vim.SM.SaveHTML()  ; making sure the html path is correct
  send {esc}
  Vim.SM.WaitTextExit()  ; making changes to the html file requires not editing html in SM
  TemplCode := Vim.SM.GetTemplCode()
  link := Vim.SM.GetLink(TemplCode)
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
  RegExMatch(Link, "(?<=https:\/\/).*?(?=\/wiki\/)", WikiLink)
  RegExMatch(TemplCode, "HTMFile=\K.*", FilePath)
  FileRead, HTML, % FilePath
  HTML := StrReplace(HTML, "en.wikipedia.org", WikiLink)
  FileDelete % FilePath
  FileAppend, % HTML, % FilePath
  Vim.SM.SaveHTML()
  if (WikiLink ~= "(zh|fr|la).wikipedia.org") {
    Vim.SM.WaitTextFocus()
    send ^{home}{end}+{home}!t  ; selecting first line
    WinWaitActive, ahk_class TChoicesDlg,, 2  ; sometimes it could take a really long time for the choice dialogue to pop up
    if (!ErrorLevel)
      send 2{enter}  ; makes selection title
  }
  Vim.SM.ClickMid()
  send {esc}
return

i::  ; learn outstanding *i*tems only
  Vim.State.SetMode("Vim_Normal")
  send !{home}{esc 4}  ; clear any hidden windows
  Vim.SM.PostMsg(202)  ; View - Outstanding
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox
  WinWaitActive, ahk_class TBrowser
  send {AppsKey}ci
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox
  WinWaitActive, ahk_class TBrowser
  send ^l
return

+i::  ; learn current element's outstanding child item
  Vim.State.SetMode("Vim_Normal")
  send ^{space}
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox
  WinWaitActive, ahk_class TBrowser
  send {AppsKey}ci
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox
  WinWaitActive, ahk_class TBrowser
  send {AppsKey}co
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox
  WinWaitActive, ahk_class TBrowser
  send ^s
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox
  WinWaitActive, ahk_class TBrowser
  send ^+l
return

o::  ; c*o*mpress images
  send ^{enter}^a  ; open commander
  send {text}co  ; Compress images
  send {enter}
  Vim.State.SetMode("Insert")
  Vim.State.BackToNormal := 1
return

s::  ; turn active language item to passive (*s*witch)
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.ExitText()
  if (ControlGetText("TBitBtn3") != "Learn")  ; if learning (on "next repitition")
    send {esc}
  hwnd := ControlGet(,, "Internet Explorer_Server2")
  send ^+s
  ControlWaitHwndChange("Internet Explorer_Server2", hwnd)
  send ^t
  Vim.SM.WaitTextFocus()
  CurrControl := ControlGetFocus()
  send ^{home}
  send {text}en:
  send {space}^t
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
  ClipSaved := ClipboardAll
  Vim.SM.ExitText()
  if (ControlGetText("TBitBtn3") != "Learn")  ; if learning (on "next repitition")
    send {esc}
  send q
  Vim.SM.WaitTextFocus()
  WinClip.Clear()
  if (Vim.SM.IsEditingHTML()) {
    send ^{home}^+{right 2}^x
  } else if (Vim.SM.IsEditingPlainText()) {
    send ^{home}^+{right}^x
  }
  ClipWait
  send {esc}
  Vim.SM.WaitTextExit()
  hwnd := ControlGet(,, "Internet Explorer_Server2")
  send ^+s
  ControlWaitHwndChange("Internet Explorer_Server2", hwnd)
  send ^t
  Vim.SM.WaitTextFocus()
  send ^v{left 2}{esc}
  Clipboard := ClipSaved
return

+p::
p::  ; hyperlink to scri*p*t component
  Vim.State.SetMode("Vim_Normal")
  ClipSaved := ClipboardAll
  Vim.Browser.url := Clipboard
  WinClip.Clear()
  add := (Vim.SM.GetCollName() = "bgm") ? Vim.Browser.Url . "`n" : ""
  Clipboard := add . Vim.SM.MakeReference()
  ClipWait

SMHyperLinkToTopic:
  Vim.SM.PostMsg(98)  ; = !n
  Vim.SM.WaitFileLoad()
  send ^v
  send ^t{f9}{enter}  ; opens script editor
  WinWaitActive, ahk_class TScriptEditor,, 1
  if (ErrorLevel) {
    ToolTip("No script component found.")
    return
  }
  script := "url " . vim.browser.url
  if (Vim.Browser.VidTime) {
    sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime)
    if (InStr(Vim.Browser.url, "youtube.com")) {
      script .= "&t=" . sec . "s"
    } else if (InStr(Vim.Browser.url, "bilibili.com")) {
      script .= "?&t=" . sec
    }
    ToolTip("Time stamp in script component set as " . sec . "s")
  }
  ControlSetText, TMemo1, % script
  send !o{esc 2}  ; close script editor
  WinWaitActive, ahk_class TElWind  ; without this SetTitle() may fail
  if (A_ThisLabel == "SMHyperLinkToTopic")
    return
  if (Vim.Browser.title)
    Vim.SM.SetTitle(Vim.browser.title)
  Clipboard := ClipSaved
  Vim.Browser.Clear()
  Vim.SM.Reload()
return

r::  ; set *r*eference's link to what's in the clipboard
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.IsEditingText())
    send {right}  ; so no text is selected
SMSetLinkFromClipboard:
  if (Vim.Browser.title)
    Vim.SM.SetTitle(Vim.Browser.title)
  ; Vim.SM.PostMsg(961, true)
  ; Somehow PostMessage doesn't work reliably here???
  send !{f10}fe  ; open registry editor
  WinWait, ahk_class TInputDlg
  ControlGetText, Ref, TMemo1, ahk_class TInputDlg
  Ref := RegExReplace(Ref, "(#Link: .*|$)", "`r`n#Link: " . Clipboard,, 1)
  if (Vim.Browser.title)
    Ref := RegExReplace(Ref, "(#Title: .*|$)", "`r`n#Title: " . Vim.Browser.title,, 1)
  if (Vim.Browser.Source)
    Ref := RegExReplace(Ref, "(#Source: .*|$)", "`r`n#Source: " . Vim.Browser.Source,, 1)
  if (Vim.Browser.Date)
    Ref := RegExReplace(Ref, "(#Date: .*|$)", "`r`n#Date: " . Vim.Browser.Date,, 1)
  if (Vim.Browser.Comment)
    Ref := RegExReplace(Ref, "(#Comment: .*|$)", "`r`n#Comment: " . Vim.Browser.Comment,, 1)
  ControlSetText, TMemo1, % Ref, ahk_class TInputDlg
  ControlSend, TMemo1, {ctrl down}{enter}{ctrl up}, ahk_class TInputDlg  ; submit
  if (A_ThisHotkey == "r")
    Vim.Browser.Clear()
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")))
SMLearnChild:
c::  ; learn child
  Vim.State.SetMode("Vim_Normal")
  send ^{space}
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox
  WinWaitActive, ahk_class TBrowser
  send {AppsKey}co
  WinWaitActive, ahk_class TProgressBox,, 1
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox
  WinWaitActive, ahk_class TBrowser
  send ^s
  WinWaitActive, ahk_class TProgressBox,, 1
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox
  WinWaitActive, ahk_class TBrowser
  send ^l
  WinWaitActive, ahk_class TElWind
  Vim.SM.PlayIfCertainColl("", 500)
return

+c::  ; add new concept
  WinActivate, ahk_class TElWind
  Vim.SM.PostMsg(126)
  Vim.State.SetMode("Insert")
return