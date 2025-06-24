#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && WinActive("ahk_class TElWind"))
b::  ; remove all text *b*efore cursor
  Send !\\
  WinWaitNotActive, ahk_class TElWind,, 0
  if (!ErrorLevel)
    Send {Enter}
  Vim.State.SetMode("Vim_Normal")
return

a::  ; remove all text *a*fter cursor
  Send !.
  WinWaitNotActive, ahk_class TElWind,, 0
  if (!ErrorLevel)
    Send {Enter}
  Vim.State.SetMode("Vim_Normal")
return

f::  ; clean *f*ormat: using f6 (retaining tables)
  Vim.State.SetMode("Vim_Normal")
  Send {f6}^arbs{Enter}
return

NukeHTML:
+f::  ; clean format directly in html source
  Vim.State.SetMode("Vim_Normal")
  if (SM.IsEditingPlainText() || !SM.DoesHTMLExist()) {
    SetToolTip("This script only works on HTML.")
    return
  }
	Send ^{f7}  ; save read point
  if (!SM.IsEditingHTML()) {
    Send ^t
    SM.WaitTextFocus()
    if (!SM.IsEditingHTML()) {
      SetToolTip("This script only works on HTML.")
      return
    }
  }
  SM.SaveHTML(30)
  WinWaitActive, ahk_class TElWind
  if (!HTML := FileRead(HTMLPath := SM.GetFilePath())) {
    SetToolTip("File not found.")
    return
  }
  if ((A_ThisLabel == "NukeHTML")
   && (HTML ~= "i)<.*?\K class=(" . SM.CssClass . ")(?=.*?>)")) {
    if (IfIn(MsgBox(3,, "HTML has SM classes. Continue?"), "No,Cancel")) {
      HTML := ""
      return
    }
  }
  FileDelete % HTMLPath
  FileAppend, % SM.CleanHTML(HTML, (A_ThisLabel == "NukeHTML"),, SM.GetLink()), % HTMLPath
  SM.RefreshHTML()
  SetToolTip("HTML cleaned."), HTML := ""
Return

+l::SM.LinkConcept(), Vim.State.SetMode("Vim_Normal")
l::SM.ListLinks(), Vim.State.SetMode("Vim_Normal")

o::  ; c*o*mpress images
  Send ^{Enter}^a  ; open commander
  Send {text}co  ; Compress images
  Send {Enter}
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1
return

r::  ; set *r*eference's link to what's in the clipboard
  Vim.State.SetMode("Vim_Normal"), SM.ExitText()

SMSetLinkFromClipboard:
  ; Had to edit title first, in case of multiple references change
  if ((SM.IsOnline(, -1) || !SM.IsItem()) && Browser.Title)
    SM.SetTitle(Browser.Title)
  SM.EditRef()
  WinWait, % "ahk_class TInputDlg ahk_pid " . WinGet("PID", "ahk_class TElWind")
  if (A_ThisLabel == "r")
    Browser.Url := Clipboard
  SMPoundSymbHandled := SM.PoundSymbLinkToComment()
  Ref := ControlGetText("TMemo1")
  if (Browser.Url)
    Ref := "#Link: " . Browser.Url . "`r`n" . Ref
  if (Browser.Title)
    Ref := "#Title: " . Browser.Title . "`r`n" . Ref
  if (Browser.Source)
    Ref := "#Source: " . Browser.Source . "`r`n" . Ref
  if (Browser.Author)
    Ref := "#Author: " . Browser.Author . "`r`n" . Ref
  if (Browser.Date)
    Ref := "#Date: " . Browser.Date . "`r`n" . Ref
  if (Browser.Comment)
    Ref := "#Comment: " . Browser.Comment . "`r`n" . Ref
  ControlSetText, TMemo1, % Ref
  ControlSend, TMemo1, {Ctrl Down}{Enter}{Ctrl Up}  ; submit
  WinWaitClose
  if (!SMPoundSymbHandled && SM.HandleSM19PoundSymbUrl(Browser.Url) && (A_ThisLabel == "r"))
    SM.Reload()
  Browser.Clear()
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")))
+i::  ; learn current element's outstanding child item
  Vim.State.SetMode("Vim_Normal")
  KeyWait Shift
  SM.OpenBrowser()
  SM.WaitBrowser()
  Send {AppsKey}ci
  SM.WaitBrowser()
  Send {AppsKey}co
  SM.WaitBrowser()
  Send ^s
  SM.WaitFileLoad()
  Send ^l
return

i::  ; learn outstanding *i*tems only
  Vim.State.SetMode("Vim_Normal"), SM.GoHome()
  WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID", "A")
  if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
    SM.PostMsg(200)
  } else {
    SM.PostMsg(202)  ; View - Outstanding
  }
  SM.WaitBrowser()
  Send {AppsKey}ci
  SM.WaitBrowser()
  Send ^l
return

SMNeuralReviewChildren:
n::  ; neural review children
  Vim.State.SetMode("Vim_Normal")
  SM.OpenBrowser()
  SM.WaitBrowser()
  Send {AppsKey}g
  WinWaitActive, ahk_class TElWind
  SM.PlayIfOnlineColl()
return

SMLearnChildren:
c::  ; learn children
  Vim.State.SetMode("Vim_Normal")
  SM.OpenBrowser()
  SM.WaitBrowser()

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && WinActive("ahk_class TBrowser"))
c::
SMLearnChildrenActiveBrowser:
  Vim.State.SetMode("Vim_Normal")
  Send {AppsKey}co
  SM.WaitBrowser()
  Send ^s
  SM.WaitFileLoad()
  Send ^l
  WinWaitActive, ahk_class TElWind
  SM.PlayIfOnlineColl()
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")))
+c::  ; add new concept
  WinActivate, ahk_class TElWind
  if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
    SM.PostMsg(125)
  } else {
    SM.PostMsg(126)
  }
  Vim.State.SetMode("Insert")
return
