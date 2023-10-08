#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
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
      ToolTip("This script only works on HTML.")
      return
    }
  }
  if (!Vim.SM.SaveHTML(, 2500)) {
    ToolTip("Time out.")
    return
  }
  WinWaitActive, ahk_class TElWind  ; insurance
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
  Vim.SM.Reload()
  Vim.SM.WaitFileLoad()
  send {esc}
Return

l::  ; *l*ink concept
  send !{f10}cl
  Vim.State.SetMode("Vim_Normal")
return

SMListLinks:
+l::  ; list links
  send !{f10}cs
  Vim.State.SetMode("Vim_Normal")
return

w::  ; prepare *w*ikipedia articles in languages other than English
  Vim.State.SetMode("Vim_Normal")
  if (Vim.SM.IsEditingPlainText() || !Vim.SM.DoesHTMLExist())
    return
	send !g  ; in case it's learning
	send ^{f7}  ; save read point
  if (!Vim.SM.IsEditingHTML())
    Vim.SM.EditFirstQuestion(), Vim.SM.WaitTextFocus()
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
  WinClose, % w := "ahk_class TBrowser ahk_pid " . WinGet("PID", "A")
  if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
    Vim.SM.PostMsg(200)
  } else {
    Vim.SM.PostMsg(202)  ; View - Outstanding
  }
  Vim.SM.WaitBrowser()
  send {AppsKey}ci
  Vim.SM.WaitBrowser()
  wBrowser := WinExist(w)
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
  if (!Vim.SM.IsItem())
    return
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
  Vim.State.SetMode("Vim_Normal")
  if (!Vim.SM.IsItem())
    return
  Vim.SM.ExitText()
  if (ControlGetText("TBitBtn3", "A") != "Learn")  ; if learning (on "next repitition")
    send {esc}
  Vim.SM.EditFirstQuestion()
  Vim.SM.WaitTextFocus(), WinClip.Clear()
  if (Vim.SM.IsEditingHTML()) {
    send ^{home}^+{right 2}
  } else if (Vim.SM.IsEditingPlainText()) {
    send ^{home}^+{right}
  }
  text := Clip()
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
  Vim.Browser.Url := Clipboard
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
    if (A_ThisLabel != "SMHyperLinkToTopic")
      Clipboard := ClipSaved, Vim.Browser.Clear()
    return
  }
  script := "url " . Vim.Browser.Url
  if (Vim.Browser.VidTime && IfIn(Vim.Browser.IsVidSite(vim.browser.FullTitle), "1,2")) {
    sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime)
    if (IfContains(Vim.Browser.Url, "youtube.com")) {
      script .= "&t=" . sec . "s"
    } else if (IfContains(Vim.Browser.Url, "bilibili.com")) {
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

  if (Vim.Browser.Title)
    Vim.SM.SetTitle(Vim.Browser.Title)
  Clipboard := ClipSaved, Vim.Browser.Clear(), Vim.SM.Reload()
return

r::  ; set *r*eference's link to what's in the clipboard
  Vim.State.SetMode("Vim_Normal"), Vim.SM.ExitText()

SMSetLinkFromClipboard:
  ; Had to edit title first, in case of multiple references change
  if ((A_ThisLabel == "SMSetLinkFromClipboard") && Vim.Browser.Title)
    Vim.SM.SetTitle(Vim.Browser.Title)
  Vim.SM.EditRef()
  WinWaitActive, ahk_class TInputDlg
  Ref := "#Link: " . Clipboard . "`r`n" . ControlGetText("TMemo1")
  if (Vim.Browser.Title)
    Ref := "#Title: " . Vim.Browser.Title . "`r`n" . Ref
  if (Vim.Browser.Source)
    Ref := "#Source: " . Vim.Browser.Source . "`r`n" . Ref
  if (Vim.Browser.Author)
    Ref := "#Author: " . Vim.Browser.Author . "`r`n" . Ref
  if (Vim.Browser.Date)
    Ref := "#Date: " . Vim.Browser.Date . "`r`n" . Ref
  if (Vim.Browser.Comment)
    Ref := "#Comment: " . Vim.Browser.Comment . "`r`n" . Ref
  ControlSetText, TMemo1, % Ref
  ControlSend, TMemo1, {CtrlDown}{enter}{CtrlUp}  ; submit
  WinWaitClose
  if (Vim.SM.HandleSM19PoundSymbUrl(Clipboard) && (A_ThisLabel == "r"))
    Vim.SM.Reload(, true)
  if (A_ThisLabel == "r")
    Vim.SM.AskPrio()
return

m::
  Vim.State.SetMode("Vim_Normal"), Vim.SM.EditRef()
  WinWaitActive, ahk_class TInputDlg
  Ref := ControlGetText("TMemo1")
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
    Goto SMLearnChildActiveBrowser
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
  Vim.SM.PlayIfCertainColl(, 500)
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
