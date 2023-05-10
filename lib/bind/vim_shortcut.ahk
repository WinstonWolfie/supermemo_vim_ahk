; Launch Settings
; #if (Vim.State.Vim.Enabled)
; ^!+c::Vim.Setting.ShowGui()

; Check Mode
; #if (Vim.IsVimGroup())
; ^!+c::Vim.State.CheckMode(4, Vim.State.Mode)

; Suspend/restart
; Every other shortcut is disabled when vim_ahk is disabled, save for this one
#if
^!+v::Vim.State.ToggleEnabled()

#if (Vim.State.Vim.Enabled)
; Shortcuts
^!r::reload

!+v::
  Clipboard := Clipboard
  send ^v
return

LAlt & RAlt::  ; for laptop
  KeyWait LAlt
  KeyWait RAlt
  send {AppsKey}
  if (Vim.IsVimGroup())
    Vim.State.SetMode("Insert")
return

#f::run D:\OneDrive\Miscellany\Programs\Everything\Everything64.exe
^#h::send ^#{left}
^#l::send ^#{right}

^+!p::
Plan:
  Vim.State.SetMode("Vim_Normal")
  KeyWait Alt
  KeyWait Ctrl
  KeyWait Shift
  if (!WinExist("ahk_group SuperMemo")) {
    run C:\SuperMemo\systems\all.kno
    WinWait, ahk_class TElWind,, 3
    if (ErrorLevel) {
      ReleaseModifierKeys()
      return
    }
    WinActivate
    Vim.SM.PostMsg(243)  ; Plan
    WinWait, ahk_class TMsgDialog,, 1.5
    if (!ErrorLevel) {
      WinClose
      WinWaitClose, ahk_class TMsgDialog
    }
    WinActivate, ahk_class TPlanDlg
    ReleaseModifierKeys()
    return
  }
  while (WinExist("ahk_class TMsgDialog"))
    WinClose
  if (!WinExist("ahk_class TPlanDlg")) {
    l := Vim.SM.IsLearning()
    if (l == 2) {
      Vim.SM.Reload()
    } else if (l == 1) {
      Vim.SM.GoToFirstEl()
    }
    Vim.SM.PostMsg(243)  ; Plan
    WinWait, ahk_class TPlanDlg,, 0
    if (ErrorLevel) {
      ReleaseModifierKeys()
      return
    }
  }
  WinActivate, ahk_class TPlanDlg
  send {right 2}{home}
return

; Browsers
#if (Vim.State.Vim.Enabled && WinActive("ahk_group Browser"))
^!w::send ^w!{tab}  ; close tab and switch back

^!i::  ; open in *I*E
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  Vim.Browser.RunInIE(Vim.Browser.ParseUrl(uiaBrowser.GetCurrentURL()))
  ; run % "iexplore.exe " . Vim.Browser.ParseUrl(GetActiveBrowserURL())  ; RIP old method
Return

^!t::  ; copy title
  Vim.Browser.Clear()
  Vim.Browser.GetTitleSourceDate(false, false)
  ToolTip("Copied " . Clipboard := Vim.Browser.Title), Vim.Browser.Clear()
return

^!l::  ; copy link and parse *l*ink if if's from YT
  Vim.Browser.Clear()
  guiaBrowser := new UIA_Browser(wBrowser := "ahk_id " . WinGet())
  ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{esc}, % wBrowser
  Vim.Browser.GetInfo(false)
  ToolTip("Copied " . Vim.Browser.Url . "`n"
        . "Title: " . Vim.Browser.Title
        . (Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : "")
        . (Vim.Browser.author ? "`nAuthor: " . Vim.Browser.author : "")
        . (Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : "")
        . (Vim.Browser.VidTime ? "`nTime stamp: " . Vim.Browser.VidTime : ""))
  Clipboard := Vim.Browser.Url, guiaBrowser := ""
  ReleaseModifierKeys()
return

^!d::  ; parse similar and opposite in google *d*efine
  ClipSaved := ClipboardAll
  if (!copy(false)) {
    ToolTip("Text not found.")
    goto RestoreClipReturn
  }
  TempClip := RegExReplace(Clipboard, "(Similar|Synonymes|Synonyms)(.*\r\n)?", "`r`nsyn: ")
  TempClip := RegExReplace(TempClip, "(Opposite|Opuesta).*\r\n", "`r`nant: ")
  TempClip := RegExReplace(TempClip, "(?![:]|(?<![^.])|(?<![^""]))\r\n(?!(syn:|ant:|\r\n))", ", ")
  TempClip := RegExReplace(TempClip, "\.\r\n", "`r`n")
  TempClip := RegExReplace(TempClip, "(\r\n\K""|""(\r\n)?(?=\r\n))", "`r`n")
  TempClip := RegExReplace(TempClip, """$(?!\r\n)")
  TempClip := StrLower(SubStr(TempClip, 1, 1)) . SubStr(TempClip, 2)  ; make the first letter lower case
  TempClip := StrReplace(TempClip, "Vulgar slang:", "vulgar slang: ")
  TempClip := StrReplace(TempClip, "Derogatory:", "derogatory: ")
  TempClip := StrReplace(TempClip, "Offensive:", "offensive: ")
  ToolTip("Copied:`n" . Clipboard := TempClip)
return

^!c::  ; copy and register references
  Vim.Browser.Clear()
  guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  ClipSaved := ClipboardAll
  if (!copy(false))
    ToolTip("No text selected."), Clipboard := ClipSaved
  Vim.Browser.GetInfo()
  ToolTip("Copied " . Clipboard . "`n"
        . "Link: " . Vim.Browser.Url . "`n"
        . "Title: " . Vim.Browser.Title
        . (Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : "")
        . (Vim.Browser.author ? "`nAuthor: " . Vim.Browser.author : "")
        . (Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : ""))
  guiaBrowser := ""
return

^!m::  ; copy ti*m*e stamp
  send {esc}
  ClipSaved := ClipboardAll
  if (!Clipboard := Vim.Browser.GetVidtime(,, false)) {
    ToolTip("Not found.")
    goto RestoreClipReturn
  }
  ToolTip("Copied " . Clipboard), Vim.Browser.Clear()
return

~^f::
  if ((A_PriorHotkey != "~^f") || (A_TimeSincePriorHotkey > 400)) {
    KeyWait f
    return
  }
  send ^v
return

~^l::
  if ((A_PriorHotkey != "~^l") || (A_TimeSincePriorHotkey > 400)) {
    KeyWait l
    return
  }
  send ^v
return

; Incremental web browsing
; +!x::
; !x::
IWBPriorityAndConcept:
IWBNewTopic:
; Incremental video: Import current YT video to SM
; Import current webpage to SuperMemo
^+!a::
^!a::
  if (!WinExist("ahk_class TElWind")) {
    ToolTip("Please open SuperMemo and try again.")
    return
  }
  if (WinExist("ahk_id " . ImportGuiHwnd)) {
    WinActivate
    return
  }
  if (Vim.Browser.GetFullTitle() = "new tab") {
    ToolTip("Web page not found.")
    return
  }
  Vim.Browser.Clear(), guiaBrowser := new UIA_Browser("ahk_id " . WinGet())
  if (!Vim.Browser.Url := Vim.Browser.GetParsedUrl()) {
    ToolTip("Url not found.")
    return
  }
  PressBrowserBtnDone := false
  SetTimer, PressBrowserBtn, -1
  if (WinExist("ahk_class TMsgDialog"))
    WinClose
  ClipSaved := ClipboardAll
  IWB := IfContains(A_ThisLabel, "x,IWB")
  Passive := Vim.SM.IsPassive(CollName := Vim.SM.GetCollName()
                            , ConceptBefore := Vim.SM.GetCurrConcept())
  if (!IWB && Vim.SM.CheckDup(Vim.Browser.Url, false))
    MsgBox, 4,, Continue import?
  WinClose, ahk_class TBrowser
  WinActivate % "ahk_id " . guiaBrowser.BrowserId
  IfMsgBox, no
    goto ImportReturn
  while (!PressBrowserBtnDone)
    continue
  KeyWait alt

  Prio := Concept := CloseTab := DownloadHTML := ResetVidTime := ""
  Vim.Browser.FullTitle := Vim.Browser.GetFullTitle()
  if (IfContains(A_ThisLabel, "+,Prio")) {
    sleep -1
    SetDefaultKeyboard(0x0409)  ; English-US
    Gui, SMImport:Add, Text,, % "Current collection: " . CollName
    Gui, SMImport:Add, Text,, &Priority:
    Gui, SMImport:Add, Edit, vPrio w196
    Gui, SMImport:Add, Text,, &Concept:
    list := ConceptBefore . "||Online|Sources|ToDo"
    Gui, SMImport:Add, Combobox, vConcept gAutoComplete w196, % list
    Gui, SMImport:Add, Checkbox, % "vCloseTab " . (IWB ? "" : "checked"), Close &tab
    if (!IWB)
      Gui, SMImport:Add, Checkbox, vDownloadHTML, Import fullpage &HTML
    if (bVidSite := Vim.Browser.IsVidSite(Vim.Browser.FullTitle))
      Gui, SMImport:Add, Checkbox, vResetVidTime, &Reset time stamp
    Gui, SMImport:Add, Button, default, &Import
    Gui, SMImport:Show,, SuperMemo Import
    Gui, SMImport:+HwndImportGuiHwnd
    return
  }

SMImportButtonImport:
  CurrTime := FormatTime(, "yyyy-MM-dd HH:mm:ss:" . A_MSec)
  if (A_ThisLabel == "SMImportButtonImport") {
    ; Without KeyWait Enter SwitchToSameWindow() below could fail???
    KeyWait enter
    KeyWait alt
    Gui submit
    if (Passive != 2)
      Passive := (IfIn(Concept, "online,sources")) ? true : false
    Gui destroy
    Vim.Caret.SwitchToSameWindow("ahk_id " . guiaBrowser.BrowserId)
  }

  ; VarSetCapacity(HTMLText, "40960000")  ; ~40 MB
  HTMLText := (DownloadHTML || Passive) ? "" : copy(false, true)
  if (IWB) {
    if (!HTMLText) {
      ToolTip("Text not found.")
      goto ImportReturn
    }
    Vim.Browser.Highlight()
  }
  Online := (Passive || (!HTMLText && bVidSite))
  if (FullPage := (DownloadHTML || (!HTMLText && !Online))) {
    ; DownloadHTMLList := "webmd.com,nytimes.com"
    ; if (DownloadHTML || IfContains(Vim.Browser.Url, DownloadHTMLList)) {
    if (DownloadHTML) {
      ToolTip("Attempting to download website...", true)

      ; Using UrlDownloadToFile
      TempPath := A_Temp . "\" . StrReplace(CurrTime, ":") . ".htm"
      UrlDownloadToFile, % Vim.Browser.Url, % TempPath
      HTMLText := FileRead(TempPath)
      FileDelete, % TempPath

      ; Using ComObj  ; not reliable?
      ; whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
      ; whr.Open("GET", Vim.Browser.Url, true)
      ; whr.Send()
      ; ; Using 'true' above and the call below allows the script to remain responsive.
      ; whr.WaitForResponse()
      ; HTMLText := whr.ResponseText

      ; Fixing links
      RegExMatch(Vim.Browser.Url, "^https?:\/\/.*?\/", UrlHead)
      HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K href=""\/(?=([^<>]+)?>)", " href=""" . UrlHead)

      WinClip.Clear(), RemoveToolTip()
      ; So that Clipboard is not sent into GetTitleSourceDate() below
    } else {
      send {esc}
      CopyAll()
      Vim.HTML.ClipboardGet_HTML(clipped)
      RegExMatch(clipped, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", HTMLText)
    }
    if (!HTMLText) {
      ToolTip("Text not found.")
      goto ImportReturn
    }
  }
  Vim.Browser.GetTitleSourceDate(false,, (FullPage ? Clipboard : ""))
  if (ResetVidTime)
    Vim.Browser.VidTime := "0:00"

  WinClip.Clear()
  if (Online && Passive) {
    Vim.SM.RefToClipForTopic()
  } else if (Online) {
    Clipboard := Vim.Browser.Url
  } else {
    LineBreakList := "baike.baidu.com,m.shuaifox.com,khanacademy.org,mp.weixin.qq.com,webmd.com"
    LineBreak := IfContains(Vim.Browser.Url, LineBreakList)
    HTMLText := Vim.HTML.Clean(HTMLText, true, LineBreak)
    if (!IWB && !vim.browser.date)
      vim.browser.date := "Imported on " . CurrTime
    Clipboard := HTMLText . "<br>" . Vim.SM.MakeReference(true)
  }
  ClipWait

  InfoToolTip := "Importing:`n"
               . "Url: " . Vim.Browser.url . "`n"
               . "Title: " . Vim.Browser.Title
  if (Vim.Browser.Source)
    InfoToolTip .= "`nSource: " . Vim.Browser.Source
  if (Vim.Browser.Author)
    InfoToolTip .= "`nAuthor: " . Vim.Browser.Author
  if (Vim.Browser.Date)
    InfoToolTip .= "`nDate: " . Vim.Browser.Date
  if (Vim.Browser.VidTime)
    InfoToolTip .= "`nTime stamp: " . Vim.Browser.VidTime
  ToolTip(InfoToolTip, true)

  if (Prio ~= "^\.")
    Prio := "0" . Prio
  WinActivate, ahk_class TElWind

  if (Concept) {
    Vim.SM.ChangeDefaultConcept(Concept,, ConceptBefore)
    WinWaitClose, ahk_class TRegistryForm
    WinWaitActive, ahk_class TElWind
    if (InStr(Vim.SM.GetCurrConcept(), Concept) != 1) {
      MsgBox, 4,, Current concept doesn't seem like your entered concept. Continue?
      IfMsgBox, no
        goto ImportReturn
    }
  }

  if (Online && !Passive) {
    gosub SMCtrlN
  } else {
    Vim.SM.AltN()
    Vim.SM.WaitTextFocus()
    if (!Online) {
      send {AppsKey}xp  ; Paste HTML
      WinClip._waitClipReady()
      WinWaitActive, ahk_class TElWind
    } else if (Passive) {
      gosub SMHyperLinkToTopic
      KeyWait Esc
      if (ErrorLevel)
        goto ImportReturn
    }
  }
  ; Process above contains references (in text). For this reason, element title
  ; has to be set later; otherwise, references that have the same titles will
  ; be merged.

  if (vim.browser.title && !IWB && (Prio == "")) {
    Vim.SM.SetTitle(Vim.Browser.title)
  } else if ((IWB || !vim.browser.title) && (Prio >= 0)) {
    Vim.SM.SetPrio(Prio, true)  ; WinWait=true in case priority get sent into other windows
  } else if (vim.browser.title && (Prio >= 0)) {
    Vim.SM.SetElParam(vim.browser.title, Prio)
  }

  Vim.SM.Reload(, true)
  if (CloseTab) {
    TabCount := ObjCount(oTabs := guiaBrowser.GetAllTabs())
    if (TabCount == 1) {
      guiaBrowser.NewTab(), guiaBrowser.CloseTab(oTabs[1]), Passive := false
    } else {
      guiaBrowser.CloseTab()
      if ((TabCount == 2)
       && ((oTabs[1].CurrentName = "new tab") || oTabs[2].CurrentName = "new tab"))
        Passive := false
    }
  }

SMImportGuiEscape:
SMImportGuiClose:
ImportReturn:
  if (esc := IfContains(A_ThisLabel, "SMImportGui"))
    Gui destroy
  Vim.SM.ClearHighlight()
  if (Passive || esc) {
    WinWaitNotActive % "ahk_id " . guiaBrowser.BrowserId,, 0.1  ; needed, otherwise ClearHighlight() might focus to SM
    WinActivate % "ahk_id " . guiaBrowser.BrowserId
  } else if (IfIn(A_ThisLabel, "SMImportButtonImport,^!a")) {
    sleep -1
    ReleaseModifierKeys()  ; sometimes SM would focus to context menu (i.e. pressed alt once)
    sleep -1
    WinWaitNotActive, ahk_class TElWind,, 0.1
    Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
  }
  Vim.Browser.Clear(), Vim.State.SetMode("Vim_Normal"), RemoveToolTip()
  if (!esc)
    Clipboard := ClipSaved
return

^+e::
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  run % "msedge.exe " . uiaBrowser.GetCurrentUrl()
return

#if (Vim.State.Vim.Enabled && ((wBrowser := WinActive("ahk_group Browser")) ; browser group (Chrome, Edge, Firefox)
                            || WinActive("ahk_exe ebook-viewer.exe")        ; Calibre (an epub viewer)
                            || WinActive("ahk_class SUMATRA_PDF_FRAME")     ; SumatraPDF
                            || WinActive("ahk_exe WINWORD.exe")             ; MS Word
                            || WinActive("ahk_exe WinDjView.exe")))         ; djvu viewer
!+d::  ; check duplicates in SM
  KeyWait Alt
  if (!WinExist("ahk_class TElWind")) {
    ToolTip("Please open SuperMemo and try again."), ReleaseModifierKeys()
    return
  }
  vToolTip := "selected text", skip := false, url := ""
  if (wBrowser) {
    uiaBrowser := new UIA_Browser("ahk_id " . wBrowser)
    if (IfContains(url := uiaBrowser.GetCurrentUrl(), "youtube.com/watch"))
      text := Vim.Browser.ParseUrl(url), skip := true, vToolTip := "url"
  }
  if (!skip && (!text := copy())) {
    if (wBrowser) {
      if (!url) {
        ToolTip("Url not found."), ReleaseModifierKeys()
        return
      }
      text := Vim.Browser.ParseUrl(url), vToolTip := "url"
    }
  }
  if (!text) {
    ToolTip("Text not found."), ReleaseModifierKeys()
    return
  }
  ToolTip("Searching " . vToolTip . " in " . Vim.SM.GetCollName() . "...", true)
  if (Vim.SM.CheckDup(text))
    RemoveToolTip()
  ReleaseModifierKeys()
return

; SumatraPDF/Calibre/MS Word to SuperMemo
^+!x::
^!x::
!+x::
!x::
  CtrlState := IfContains(A_ThisHotkey, "^")
  ClipSaved := ClipboardAll
  KeyWait Alt
  KeyWait Ctrl
  KeyWait Shift
  if (!copy(false)) {
    ToolTip("Nothing is selected.")
    goto RestoreClipReturn
  } else {
    if (!WinExist("ahk_group SuperMemo")) {
      ToolTip("SuperMemo is not open; the text you selected is on your clipboard.")
      return
    }
    hWnd := WinGet()
    if (Prio := IfContains(A_ThisHotkey, "+")) {
      if ((!Prio := InputBox("Priority", "Enter extract priority.")) || ErrorLevel)
        return
      if (Prio ~= "^\.")
        Prio := "0" . Prio
      WinWaitActive, % "ahk_id " . hWnd
    }
    if (CleanHTML := WinActive("ahk_group Browser")) {
      Vim.Browser.Highlight()
    } else if (CleanHTML := WinActive("ahk_exe ebook-viewer.exe")) {
      ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}q, % "ahk_id " . hWnd  ; need to enable this shortcut in settings
    } else if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
      ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}a, % "ahk_id " . hWnd
    } else if (WinActive("ahk_exe WINWORD.exe")) {
      send ^!h
    } else if (WinActive("ahk_exe WinDjView.exe")) {
      send ^h
      WinWaitActive, ahk_class #32770  ; create annotations
      send {enter}
    }
  }
  extract := ClipboardAll
  WinActivate, ahk_class TElWind  ; focus to element window

ExtractToSM:
  if (Vim.SM.IsEditingPlainText()) {
    ToolTip("This script requires HTML component to work.")
    goto RestoreClipReturn
  }
  Vim.SM.EditFirstQuestion()
  if (!Vim.SM.WaitTextFocus(1500)) {
    ToolTip("No HTML component found; the text you selected is on your clipboard.")
    goto RestoreClipReturn
  }
  if (Vim.SM.IsEditingPlainText()) {
    ToolTip("This script requires HTML component to work.")
    goto RestoreClipReturn
  }
  send ^{home}^+{down}  ; go to top and select first paragraph below
  if (ret := (copy(false) ~= "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])")) {
    send {left}
    if (A_ThisLabel != "ExtractToSM") {
      MsgBox, 3,, Go to source and try again? (press no to paste in current topic)
      if (IfMsgbox("yes")) {
        WinWaitActive, ahk_class TElWind
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        goto ExtractToSM
      } else if (IfMsgBox("no")) {
        WinWaitActive, ahk_class TElWind
        Vim.SM.EditFirstQuestion()
        ret := !Vim.SM.WaitTextFocus(1500)
      }
    }
    if (ret) {
      ToolTip("Please make sure current element is an empty HTML topic. Your extract is now on your clipboard.")
      Clipboard := extract
      return
    }
  }
  send {left}

  if (!CleanHTML) {
    clip(extract,, false)
  } else {
    WinClip.Clear()
    Clipboard := extract
    ClipWait
    Vim.HTML.ClipboardGet_HTML(data)
    RegExMatch(data, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", data)
    WinClip.Clear()
    Clipboard := Vim.HTML.Clean(data, true)
    ClipWait
    send {AppsKey}xp  ; paste HTML
    WinClip._waitClipReady()
    WinWaitActive, ahk_class TElWind
  }
  send ^+{home}  ; select everything
  if (Prio) {
    send !+x
    WinWaitActive, ahk_class TPriorityDlg
    ControlSetText, TEdit5, % Prio, A
    send {enter}
  } else {
    send !x  ; extract
  }
  Vim.SM.WaitExtractProcessing()
  x := A_CaretX, y := A_CaretY
  send {down}
  WaitCaretMove(x, y)
  send !\\
  WinWaitNotActive, ahk_class TElWind
  send {enter}
  WinWaitClose, ahk_class TMsgDialog
  send {esc}
  if (CtrlState) {
    send !{left}
  } else {
    WinActivate % "ahk_id " . hWnd
  }
  Clipboard := ClipSaved
return

; SumatraPDF
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && !Vim.State.IsCurrentVimMode("Z") && !ControlGetFocus())
+z::Vim.State.SetMode("Z")
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && Vim.State.IsCurrentVimMode("Z") && !ControlGetFocus())
+z::  ; exit and save annotations
  ControlSend,, q, ahk_class SUMATRA_PDF_FRAME
  WinActivate, ahk_class TElWind
  WinWait, Unsaved annotations,, 0
  if (!ErrorLevel) {
    ControlClick, Button1,,,,, NA
    WinActivate, ahk_class TElWind
  }
  Vim.State.SetMode("Vim_Normal")
return

#if (Vim.State.Vim.Enabled
  && ((WinActive("ahk_class SUMATRA_PDF_FRAME") && !ControlGetFocus())
   || (WinActive("ahk_exe WinDjView.exe") && (ControlGetFocus() != "Edit1"))))
!p::ControlFocus, Edit1, A  ; focus to page number field so you can enter a number
^!f::
  if (!selection := Copy())
    return
  ControlSetText, Edit2, % selection, A
  ControlFocus, Edit2, A
  send {enter 2}^a
return

#if (Vim.State.Vim.Enabled
  && (WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe WinDjView.exe"))
  && (ControlGetFocus() == "Edit1"))
!p::
  ControlSetText, Edit1, % Clipboard, A
  send {enter}
return

#if (Vim.State.Vim.Enabled
  && ((pdf := WinActive("ahk_class SUMATRA_PDF_FRAME")) || WinActive("ahk_exe WinDjView.exe"))
  && (page := ControlGetText("Edit1")))
^!p::
  if (pdf && !RegExMatch(page, "\d+"))
    RegExMatch(WinGetText(), " \((\d+)", v), page := v1
  Clipboard := "p" . page, ToolTip("Copied p" . page)
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && (ControlGetFocus() == "Edit2"))
^f::
  ControlSetText, Edit2, % Clipboard, A
  send {enter}
return

^!f::send {enter}^a

#if (Vim.State.Vim.Enabled && WinActive("ahk_class #32770 ahk_exe WinDjView.exe"))  ; find window
^f::
  ControlSetText, Edit1, % Clipboard, A
  send {enter}
return

; Syncing page number / marker
#if (Vim.State.Vim.Enabled
  && !Vim.SM.IsPassive(, -1)  ; current concept doesn't matter
  && (WinActive("ahk_class SUMATRA_PDF_FRAME")
   || WinActive("ahk_exe ebook-viewer.exe")
   || WinActive("ahk_group Browser")
   || WinActive("ahk_exe WinDjView.exe"))
  && WinExist("ahk_class TElWind"))
!+s::
^!s::
^+!s::
  ClipSaved := ClipboardAll
  CloseWnd := IfContains(A_ThisHotkey, "^")
  KeyWait Alt
  KeyWait Ctrl
  KeyWait Shift
  if (WinActive("ahk_class SUMATRA_PDF_FRAME") && IfContains(ControlGetFocus(), "Edit"))
    send {esc}
  marker := trim(copy(false), " `t`r`n")
  if ((wPdf := WinActive("ahk_class SUMATRA_PDF_FRAME")) || WinActive("ahk_exe WinDjView.exe")) {
    if (!marker && (page := ControlGetText("Edit1"))) {
      if (wPdf && !RegExMatch(page, "\d+"))
        RegExMatch(WinGetText(), " \((\d+)", v), page := v1
      marker := "p" . page
    }
    if (!marker) {
      ToolTip("No text selected and page number not found.")
      goto RestoreClipReturn
    }
    if (CloseWnd) {
      if (wPdf) {
        send {text}q
        WinWait, Unsaved annotations,, 0
        if (!ErrorLevel)
          ControlClick, Button1,,,,, NA
      } else {  ; djvu
        send ^w
        WinWaitTitle("WinDjView")
        WinClose, A
      }
    }
  } else {
    if (!marker) {
      if (WinActive("ahk_group Browser"))
        goto BrowserSyncTime
      ToolTip("No text selected.")
      goto RestoreClipReturn
    }
    if (CloseWnd) {
      if (b := WinActive("ahk_group Browser")) {
        send ^w
      } else {  ; epub viewer
        WinClose, A
      }
    }
  }
  WinActivate, ahk_class TElWind

MarkInSMTitle:
  Vim.SM.EditFirstQuestion()
  if (!Vim.SM.WaitTextFocus(1500)) {
    ToolTip("No text component.")
    goto RestoreClipReturn
  }
  send ^{home}^+{down}  ; go to top and select first paragraph below
  if (ret := (copy(false) ~= "(?=.*[^\S])(?=[^-])(?=.*[^\r\n])")) {
    send {left}
    if (A_ThisLabel != "MarkInSMTitle") {
      MsgBox, 3,, Go to source and try again? (press no to execute in current topic)
      if (IfMsgbox("yes")) {
        WinWaitActive, ahk_class TElWind
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        goto MarkInSMTitle
      } else if (IfMsgBox("no")) {
        WinWaitActive, ahk_class TElWind
        Vim.SM.EditFirstQuestion()
        ret := !Vim.SM.WaitTextFocus(1500)
      }
    }
    if (ret) {
      ToolTip("No source element found or source element isn't empty. Your mark is now on your clipboard.")
      Clipboard := marker
      return
    }
  }
  send {left}{esc}
  Vim.SM.WaitTextExit()
  SMTitle := RegExReplace(WinGetTitle("ahk_class TElWind"), "^Duplicate: ")
  Vim.SM.SetTitle(RegExReplace(SMTitle, "((^.+ \| )|^)", marker . " | "))
  if (IfContains(A_ThisHotkey, "^+!"))
    Vim.SM.Learn(, true)
  Clipboard := ClipSaved
return

; IE
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe"))
; Open in default browser (in my case, Chrome); similar to default shortcut ^+e to open in ms edge
^+c::run % ControlGetText("Edit1")  ; browser url field
^+e::run % "msedge.exe " . ControlGetText("Edit1")
^!l::ToolTip("Copied " . Clipboard := ControlGetText("Edit1"))
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe msedge.exe"))
^+c::
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  run % uiaBrowser.GetCurrentUrl()
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class wxWindowNR") && WinExist("ahk_class TElWind"))  ; audacity.exe
^!x::
!x::
  CurrTime := FormatTime(, "yyyy-MM-dd HH:mm:ss:" . A_MSec)
  KeyWait Alt
  KeyWait Ctrl
  if (A_ThisHotkey == "^!x") {
    send ^a
    PostMessage, 0x0111, 17200,,, A  ; truncate silence
    WinWaitActive, Truncate Silence
    ; Settings for truncate complete silence
    ControlSetText, Edit1, -80, A
    ControlSetText, Edit2, 0.001, A
    ControlSetText, Edit3, 0, A
    send {enter}
    WinWaitNotActive, Truncate Silence
    WinWaitActive, ahk_class wxWindowNR  ; audacity main window
    send ^+e  ; save
    WinWaitActive, Export Audio
  } else if (A_ThisHotkey == "!x") {
    PostMessage, 0x0111, 17011,,, A  ; export selected audio
    WinWaitActive, Export Selected Audio
  }
  FileName := RegExReplace(Vim.Browser.title . CurrTime, "[^a-zA-Z0-9\\.\\-]", "_")
  TempPath := A_Temp . "\" . FileName . ".mp3"
  Control, Choose, 3, ComboBox3, A  ; choose mp3 from file type
  ControlSetText, Edit1, % TempPath, A
  send {enter}
  WinWaitActive, Warning,, 0
  if (!ErrorLevel) {
    send {enter}
    WinWaitClose
  }
  send ^a{bs}
  WinActivate, ahk_class TElWind
  Vim.SM.AltA()
  Vim.SM.WaitFileLoad()
  QuestionFieldName := ControlGetFocus()
  if (Vim.Browser.title) {
    send % "{text}" . Vim.SM.MakeReference()
  } else {
    send {text}Listening comprehension:
  }
  Vim.SM.InvokeFileBrowser()
  ControlSend, TDriveComboBox1, c, A
  ControlSetText, TEdit1, % TempPath, A
  ControlSend, TEdit1, {enter}, A
  WinWaitActive, ahk_class TInputDlg
  if (Vim.Browser.title) {
    ControlSetText, TMemo1, % Vim.Browser.title . " (excerpt)", A
  } else {
    ControlSetText, TMemo1, listening comprehension_, A
  }
  send {enter}
  WinWaitActive, ahk_class TMsgDialog
  send {text}n
  WinWaitClose
  WinWaitActive, ahk_class TMsgDialog
  send {text}y  ; delete temp file
  WinWaitClose
  if (Vim.Browser.Title)
    Vim.SM.SetTitle(Vim.Browser.Title)
  CurrFocus := ControlGetFocus("ahk_class TElWind")
  WinActivate, ahk_class TElWind
  send !{f12}fl  ; previous component
  ControlWaitNotFocus(CurrFocus, "ahk_class TElWind")
  send +{Ins}  ; paste: text or image
  aClipFormat := WinClip.GetFormats()
  if (aClipFormat[aClipFormat.MinIndex()].name == "CF_DIB") {  ; image
    WinWaitActive, ahk_class TMsgDialog
    send {enter}
    WinWaitClose
    send {enter}
  }
  Vim.SM.Reload()
  Vim.SM.WaitFileLoad()
  Vim.SM.EditFirstAnswer()
  Vim.Browser.Clear()
Return

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe ebook-viewer.exe"))
~^f::
  if ((A_PriorHotkey != "~^f") || (A_TimeSincePriorHotkey > 400)) {
    KeyWait f
    return
  }
  send ^v
  WinClip._waitClipReady()
  send {enter}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe HiborClient.exe"))
!+d::  ; check duplicates
  ClipSaved := ClipboardAll
  if (CopyAll())
    Vim.SM.CheckDup(MatchHiborLink(Clipboard))
  Clipboard := ClipSaved
  ReleaseModifierKeys()
return

#if (Vim.State.Vim.Enabled && (hwnd := WinActive("ahk_exe HiborClient.exe")) && WinExist("ahk_class TElWind"))
^+!a::
^!a::  ; import
  ClipSaved := ClipboardAll
  KeyWait Alt
  KeyWait Ctrl
  KeyWait Shift
  if (!CopyAll())
    goto RestoreClipReturn
  link := MatchHiborLink(Clipboard)
  title := MatchHiborTitle(Clipboard)
  RegExMatch(title, "^.*?(?=-)", source)
  title := StrReplace(title, source . "-",,, 1)
  RegExMatch(title, "\d{6}$", date)
  title := StrReplace(title, "-" . date,,, 1)
  if (Vim.SM.CheckDup(link, false))
    MsgBox, 4,, Continue import?
  WinActivate % "ahk_id " . hwnd
  WinClose, ahk_class TBrowser
  IfMsgBox no
    goto HBImportReturn
  if (Prio := IfContains(A_ThisHotkey, "+")) {
    if ((!Prio := InputBox("Priority", "Enter extract priority.")) || ErrorLevel)
      return
    if (Prio ~= "^\.")
      Prio := "0" . Prio
  }
  WinClip.Clear()
  Clipboard := "#SuperMemo Reference:"
             . "`n#Title: " . title
             . "`n#Source: " . source
             . "`n#Date: " . date
             . "`n#Link: " . link
  ClipWait
  WinActivate, ahk_class TElWind
  Vim.SM.CtrlN()
  if (title && !prio) {
    Vim.SM.SetTitle(title)
  } else if (title && prio) {
    Vim.SM.SetElParam(title, prio)
  }
  Vim.SM.Reload(, true)

HBImportReturn:
  Vim.SM.ClearHighlight()
  sleep -1
  ReleaseModifierKeys()  ; sometimes SM would focus to context menu (i.e. pressed alt once)
  sleep -1
  WinWaitNotActive, ahk_class TElWind,, 0.1
  Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
  Clipboard := ClipSaved
return

MatchHiborTitle(text) {
  RegExMatch(text, "s)意见反馈\r\n(研究报告：)?\K.*?(?=\r\n)", v)
  return v
}

MatchHiborLink(text) {
  RegExMatch(text, "s)推荐给朋友:\r\n\K.*?(?=  )", v)
  return v
}

#if (Vim.State.Vim.Enabled && (hWnd := WinActive("ahk_exe Discord.exe")))
^!l::  ; go live
  if (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.3.1.2.1.1.2.1.1.2.1.6",, "ahk_id " . hWnd))
    return
  accBtn.accDoDefaultAction(0)
  while (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.4.2.1.1.2.2.1.1.3",, "ahk_id " . hWnd))
    sleep 40
  accBtn.accDoDefaultAction(0)
  while (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.4.2.1.1.2.2.1.2.1.1",, "ahk_id " . hWnd))
    sleep 40
  accBtn.accDoDefaultAction(0)
  while (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.4.2.1.1.2.2.1.13.1",, "ahk_id " . hWnd))
    sleep 40
  accBtn.accDoDefaultAction(0)
  while (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.4.2.1.1.2.3.1",, "ahk_id " . hWnd))
    sleep 40
  accBtn.accDoDefaultAction(0)
return

#if (Vim.State.Vim.Enabled && (hWnd := WinActive("ahk_exe Clash for Windows.exe")))
!t::  ; test latency
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(hWnd)
  if (!btn := el.FindFirstBy("ControlType=Text AND Name='network_check'"))
    btn := el.FindFirstBy("ControlType=Text AND Name='Update All'")
  btn.click()
return