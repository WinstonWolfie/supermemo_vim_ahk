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
    Vim.State.SetToolTip("This script only works on HTML.")
    return
  }
	send ^{f7}  ; save read point
  if (!Vim.SM.IsEditingHTML()) {
    send ^t
    Vim.SM.WaitTextFocus()
    if (!Vim.SM.IsEditingHTML()) {
      Vim.State.SetToolTip("This script only works on HTML.")
      return
    }
  }
  if (!Vim.SM.SaveHTML(3000)) {
    Vim.State.SetToolTip("Time out.")
    return
  }
  WinWaitActive, ahk_class TElWind  ; insurance
  if (!HTML := FileRead(HTMLPath := Vim.SM.GetFilePath())) {
    Vim.State.SetToolTip("File not found.")
    return
  }
  if ((A_ThisLabel == "NukeHTML")
   && (HTML ~= "i)<.*?\K class=(" . Vim.SM.CssClass . ")(?=.*?>)")) {
    if (IfIn(MsgBox(3,, "HTML has SM classes. Continue?"), "No,Cancel")) {
      HTML := ""
      return
    }
  }
  FileDelete % HTMLPath
  FileAppend, % Vim.SM.CleanHTML(HTML, (A_ThisLabel == "NukeHTML"),, Vim.SM.GetLink()), % HTMLPath
  Vim.SM.Reload()
  Vim.SM.WaitFileLoad()
  send {Esc}
  Vim.State.SetToolTip("HTML cleaned."), HTML := ""
Return

+l::Vim.SM.LinkConcept(), Vim.State.SetMode("Vim_Normal")
l::Vim.SM.ListLinks(), Vim.State.SetMode("Vim_Normal")

o::  ; c*o*mpress images
  send ^{enter}^a  ; open commander
  send {text}co  ; Compress images
  send {enter}
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1
return

s::  ; turn active language item to passive (*s*witch)
  Vim.State.SetMode("Vim_Normal")
  if (!Vim.SM.IsItem())
    return
  Vim.SM.ExitText()
  if (Vim.SM.IsLearning() == 2)  ; if learning (on "next repitition")
    send {Esc}
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
    send ^{home}^+{right}{BS}
  }
  send {Esc}
return

+s::
  Vim.State.SetMode("Vim_Normal")
  if (!Vim.SM.IsItem())
    return
  Vim.SM.ExitText()
  if (ControlGetText("TBitBtn3", "A") != "Learn")  ; if learning (on "next repitition")
    send {Esc}
  Vim.SM.EditFirstQuestion()
  Vim.SM.WaitTextFocus(), WinClip.Clear()
  if (Vim.SM.IsEditingHTML()) {
    send ^{home}^+{right 2}
  } else if (Vim.SM.IsEditingPlainText()) {
    send ^{home}^+{right}
  }
  text := Clip()
  send {BS}{Esc}
  Vim.SM.WaitTextExit()
  send ^+s
  sleep 320
  Vim.SM.EditFirstQuestion()
  Vim.SM.WaitTextFocus()
  send % "{text}" . text
  send {left 2}{Esc}
return

r::  ; set *r*eference's link to what's in the clipboard
  Vim.State.SetMode("Vim_Normal"), Vim.SM.ExitText()

SMSetLinkFromClipboard:
  ; Had to edit title first, in case of multiple references change
  if ((Vim.SM.IsOnline(, -1) || !Vim.SM.IsItem()) && Vim.Browser.Title)
    Vim.SM.SetTitle(Vim.Browser.Title)
  Vim.SM.EditRef()
  WinWaitActive, ahk_class TInputDlg
  Vim.Browser.Url := Clipboard
  SMPoundSymbHandled := Vim.SM.PoundSymbLinkToComment()
  Ref := "#Link: " . Vim.Browser.Url . "`n" . ControlGetText("TMemo1")
  if (Vim.Browser.Title)
    Ref := "#Title: " . Vim.Browser.Title . "`n" . Ref
  if (Vim.Browser.Source)
    Ref := "#Source: " . Vim.Browser.Source . "`n" . Ref
  if (Vim.Browser.Author)
    Ref := "#Author: " . Vim.Browser.Author . "`n" . Ref
  if (Vim.Browser.Date)
    Ref := "#Date: " . Vim.Browser.Date . "`n" . Ref
  if (Vim.Browser.Comment)
    Ref := "#Comment: " . Vim.Browser.Comment . "`n" . Ref
  ControlSetText, TMemo1, % Ref
  ControlSend, TMemo1, {Ctrl Down}{enter}{Ctrl Up}  ; submit
  WinWaitClose
  if (!SMPoundSymbHandled && Vim.SM.HandleSM19PoundSymbUrl(Vim.Browser.Url) && (A_ThisLabel == "r"))
    Vim.SM.Reload(, true)
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")))
+i::  ; learn current element's outstanding child item
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.OpenBrowser()
  Vim.SM.WaitBrowser()
  send {AppsKey}ci
  Vim.SM.WaitBrowser()
  send {AppsKey}co
  Vim.SM.WaitBrowser()
  send ^s
  Vim.SM.WaitBrowser()
  send ^l
return

i::  ; learn outstanding *i*tems only
  Vim.State.SetMode("Vim_Normal"), Vim.SM.GoHome()
  WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID", "A")
  if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
    Vim.SM.PostMsg(200)
  } else {
    Vim.SM.PostMsg(202)  ; View - Outstanding
  }
  Vim.SM.WaitBrowser()
  send {AppsKey}ci
  Vim.SM.WaitBrowser()
  send ^l
return

SMLearnChild:
c::  ; learn child
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.OpenBrowser()
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
  Vim.SM.PlayIfPassiveColl(, 500)
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
