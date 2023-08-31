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
  if (Vim.SM.IsEditingPlainText() || !Vim.SM.DoesHTMLExist()) {
    ToolTip("This script only works on HTML.")
    return
  }
	send ^{f7}  ; save read point
  if (!Vim.SM.IsEditingHTML()) {
    send ^t
    Vim.SM.WaitTextFocus()
    if (!Vim.SM.IsEditingHTML()) {
      ToolTip("HTML not found.")
      return
    }
  }
  if (!Vim.SM.SaveHTML(, 2500)) {
    ToolTip("Time out.")
    return
  }
  sleep 20  ; making sure the file path is updated
  if (!HTML := FileRead(HTMLPath := Vim.SM.GetFilePath())) {
    ToolTip("File not found.")
    return
  }
  if ((A_ThisLabel == "NukeHTML")
   && (HTML ~= "i)<.*?\K class=(" . Vim.SM.CssClass . ")(?=.*?>)")) {
    MsgBox, 3,, HTML has SM classes. Continue?
    if (IfMsgbox("No") || IfMsgbox("Cancel"))
      return
  }
  FileDelete % HTMLPath
  FileAppend, % Vim.HTML.Clean(HTML, (A_ThisLabel == "NukeHTML"),, Vim.SM.GetLink()), % HTMLPath
  Vim.SM.SaveHTML()
  Vim.SM.ClickMid()
  send {esc}
Return

l::  ; *l*ink concept
  Vim.SM.ElMenu()
  send cl
  Vim.State.SetMode("Vim_Normal")
return

SMListLinks:
+l::  ; list links
  Vim.SM.ElMenu()
  send cs
  Vim.State.SetMode("Vim_Normal")
return

w::  ; prepare *w*ikipedia articles in languages other than English
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.IsEditingPlainText())
    return
	send !g  ; in case it's learning
	send ^{f7}  ; save read point
  if (!Vim.SM.IsEditingHTML()) {
    Vim.SM.EditFirstQuestion()
    Vim.SM.WaitTextFocus()
    if (!Vim.SM.IsEditingHTML())
      return
  }
  Vim.SM.SaveHTML()  ; making sure the html path is correct
  send {esc}
  Vim.SM.WaitTextExit()  ; making changes to the html file requires not editing html in SM
  link := Vim.SM.GetLink(TemplCode := Vim.SM.GetTemplCode())
  if (link) {
    if (!IfContains(link, "wikipedia.org/wiki")) {
      ToolTip("Not Wikipedia!")
      return
    }
    if (IfContains(link, "en.wikipedia.org")) {
      ToolTip("English Wikipedia doesn't need to be prepared!")
      return
    }
  } else {
    ToolTip("No reference.")
    return
  }
  RegExMatch(Link, "(?<=https:\/\/).*?(?=\/wiki\/)", WikiLink)
  RegExMatch(TemplCode, "HTMFile=\K.*", FilePath)
  HTML := StrReplace(FileRead(FilePath), "en.wikipedia.org", WikiLink)
  FileDelete % FilePath
  FileAppend, % HTML, % FilePath
  Vim.SM.SaveHTML()
  if (WikiLink ~= "(zh|fr|la)\.wikipedia\.org") {
    Vim.SM.WaitTextFocus()
    send ^{home}{end}+{home}  ; selecting first line
    Vim.SM.AltT()
    WinWaitActive, ahk_class TChoicesDlg,, 2  ; sometimes it could take a really long time for the choice dialogue to pop up
    if (!ErrorLevel)
      send 2{enter}  ; makes selection title
  }
  Vim.SM.ClickMid()
  send {esc}
return

i::  ; learn outstanding *i*tems only
  Vim.State.SetMode("Vim_Normal"), Vim.SM.GoHome()
  WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID")
  if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
    Vim.SM.PostMsg(200)
  } else {
    Vim.SM.PostMsg(202)  ; View - Outstanding
  }
  Vim.SM.WaitBrowser()
  send {AppsKey}ci
  Vim.SM.WaitBrowser()
  wBrowser := WinGet(, "ahk_class TBrowser")
  sleep 200
  while (WinExist("ahk_id " . wBrowser)) {
    WinActivate
    send ^l
    sleep 200
  }
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
  if (Vim.SM.IsLearning() == 2)  ; if learning (on "next repitition")
    send {esc}
  send ^+s
  sleep 320
  Vim.SM.EditFirstQuestion()
  Vim.SM.WaitTextFocus()
  send ^{home}
  send {text}en:
  send {space}^t
  sleep 320
  if (Vim.SM.IsEditingHTML()) {
    send ^{home}^{del 2}
  } else if (Vim.SM.IsEditingPlainText()) {
    send ^{home}^+{right}{bs}
  }
  send {esc}
return

+s::
  Vim.State.SetMode("Vim_Normal"), Vim.SM.ExitText()
  if (ControlGetText("TBitBtn3") != "Learn")  ; if learning (on "next repitition")
    send {esc}
  Vim.SM.EditFirstQuestion()
  Vim.SM.WaitTextFocus(), WinClip.Clear()
  if (Vim.SM.IsEditingHTML()) {
    send ^{home}^+{right 2}
  } else if (Vim.SM.IsEditingPlainText()) {
    send ^{home}^+{right}
  }
  text := clip()
  send {bs}{esc}
  Vim.SM.WaitTextExit()
  send ^+s
  sleep 320
  Vim.SM.EditFirstQuestion()
  Vim.SM.WaitTextFocus()
  send % "{text}" . text
  send {left 2}{esc}
return

+p::
p::  ; hyperlink to scri*p*t component
  Vim.State.SetMode("Vim_Normal")
  ClipSaved := ClipboardAll
  Vim.Browser.url := Clipboard
  WinClip.Clear()
  Vim.SM.RefToClipForTopic(CollName)
  ClipWait
  Vim.SM.AltN()
  Vim.SM.WaitFileLoad()

SMHyperLinkToTopic:
  send {CtrlDown}vt{CtrlUp}{f9}{enter}  ; opens script editor
  WinWaitActive, ahk_class TScriptEditor,, 1.5
  if (ErrorLevel) {
    ToolTip("No script component found.")
    if (A_ThisLabel != "SMHyperLinkToTopic") {
      Clipboard := ClipSaved
      Vim.Browser.Clear()
    }
    return
  }
  script := "url " . vim.browser.url
  if (Vim.Browser.VidTime && IfIn(Vim.Browser.IsVidSite(vim.browser.FullTitle), "1,2")) {
    sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime)
    if (IfContains(Vim.Browser.url, "youtube.com")) {
      script .= "&t=" . sec . "s"
    } else if (IfContains(Vim.Browser.url, "bilibili.com")) {
      script .= (script ~= "\?p=\d+") ? "&t=" . sec : "?t=" . sec
    }
    if (A_ThisLabel != "SMHyperLinkToTopic")
      ToolTip("Time stamp in script component set as " . sec . "s")
  }
  ControlSetText, TMemo1, % script, A
  send !o{esc 2}  ; close script editor
  WinWaitActive, ahk_class TElWind  ; without this SetTitle() may fail
  if (Vim.Browser.VidTime && (Vim.Browser.IsVidSite(vim.browser.FullTitle) == 3))
    Vim.Browser.Title := Vim.Browser.VidTime . " | " . Vim.Browser.Title
  if (A_ThisLabel == "SMHyperLinkToTopic")
    return

  if (Vim.Browser.title)
    Vim.SM.SetTitle(Vim.browser.title)
  Clipboard := ClipSaved
  Vim.Browser.Clear()
  Vim.SM.Reload()
return

r::  ; set *r*eference's link to what's in the clipboard
  Vim.State.SetMode("Vim_Normal"), Vim.SM.ExitText()

SMSetLinkFromClipboard:
  ; Had to edit title first, in case of multiple references change
  if (Vim.Browser.title)
    Vim.SM.SetTitle(Vim.Browser.title)
  Vim.SM.EditRef()
  WinWait, ahk_class TInputDlg
  Ref := RegExReplace(ControlGetText("TMemo1", "ahk_class TInputDlg")
                    , "#Link: .*|$", "`r`n#Link: " . Clipboard,, 1)
  if (Vim.Browser.title)
    Ref := RegExReplace(Ref, "#Title: .*|$", "`r`n#Title: " . Vim.Browser.title,, 1)
  if (Vim.Browser.Source)
    Ref := RegExReplace(Ref, "#Source: .*|$", "`r`n#Source: " . Vim.Browser.Source,, 1)
  if (Vim.Browser.author)
    Ref := RegExReplace(Ref, "#Author: .*|$", "`r`n#Author: " . Vim.Browser.author,, 1)
  if (Vim.Browser.Date)
    Ref := RegExReplace(Ref, "#Date: .*|$", "`r`n#Date: " . Vim.Browser.Date,, 1)
  if (Vim.Browser.Comment)
    Ref := RegExReplace(Ref, "#Comment: .*|$", "`r`n#Comment: " . Vim.Browser.Comment,, 1)
  ControlSetText, TMemo1, % Ref
  ControlSend, TMemo1, {CtrlDown}{enter}{CtrlUp}  ; submit
  WinWaitClose
  if ((A_ThisHotkey == "r") && !Vim.SM.AskPrio())
    return
return

m::
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.EditRef()
  WinWait, ahk_class TInputDlg
  Ref := ControlGetText("TMemo1", "ahk_class TInputDlg")
  if (Ref ~= "#Comment: .*#audio") {
    ControlSend, TMemo1, {esc}, ahk_class TInputDlg
    return
  }
  Ref := RegExReplace(Ref, "#Comment:(.*)|$", "`r`n#Comment:$1 #audio ",, 1)
  ControlSetText, TMemo1, % Ref, ahk_class TInputDlg
  ControlSend, TMemo1, {CtrlDown}{enter}{CtrlUp}, ahk_class TInputDlg  ; submit
return

d::
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.CtrlF("#audio"))
    goto SMLearnChildActiveBrowser
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")))
+i::  ; learn current element's outstanding child item
  Vim.State.SetMode("Vim_Normal")
  send ^{space}
  Vim.SM.WaitBrowser()
  send {AppsKey}ci
  Vim.SM.WaitBrowser()
  send {AppsKey}co
  Vim.SM.WaitBrowser()
  send ^s
  Vim.SM.WaitBrowser()
  send ^l
return

SMLearnChild:
c::  ; learn child
  Vim.State.SetMode("Vim_Normal")
  send ^{space}
  Vim.SM.WaitBrowser()

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && WinActive("ahk_class TBrowser"))
c::
SMLearnChildActiveBrowser:
  Vim.State.SetMode("Vim_Normal")
  send {AppsKey}co
  Vim.SM.WaitBrowser()
  send ^s
  Vim.SM.WaitBrowser()
  send ^l
  WinWaitActive, ahk_class TElWind
  Vim.SM.PlayIfCertainColl("", 500)
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")))
+c::  ; add new concept
  WinActivate, ahk_class TElWind
  if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
    Vim.SM.PostMsg(125)
  } else {
    Vim.SM.PostMsg(126)
  }
  Vim.State.SetMode("Insert")
return