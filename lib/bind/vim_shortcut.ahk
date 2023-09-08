#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
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

#f::run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Everything 1.5a.lnk
^#h::send ^#{left}
^#l::send ^#{right}
+#h::send +#{left}
+#l::send +#{right}

^+!p::
Plan:
  Vim.State.SetMode("Vim_Normal"), ReleaseModifierKeys()
  if (!WinExist("ahk_group SuperMemo")) {
    run C:\SuperMemo\systems\all.kno
    WinWait, ahk_class TElWind,, 3
    if (ErrorLevel)
      return
    WinActivate
    if (!Vim.SM.Plan())
      return
    WinWait, ahk_class TMsgDialog,, 1.5
    if (!ErrorLevel) {
      WinClose
      WinWaitClose, ahk_class TMsgDialog
    }
    WinActivate, ahk_class TPlanDlg
    return
  }
  Vim.SM.CloseMsgWind()
  if (!WinExist("ahk_class TPlanDlg")) {
    l := Vim.SM.IsLearning()
    if (l == 2) {
      Vim.SM.Reload()
    } else if (l == 1) {
      Vim.SM.GoHome()
    }
    if (!Vim.SM.Plan())
      return
    WinWait, ahk_class TPlanDlg,, 0
    if (ErrorLevel)
      return
  }
  WinActivate, ahk_class TPlanDlg
  send {right 2}{home}
return

; Browsers
#if (Vim.State.Vim.Enabled && WinActive("ahk_group Browser"))
^!w::send ^w!{tab}  ; close tab and switch back

^!i::  ; open in *I*E
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
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
  guiaBrowser := new UIA_Browser(wBrowser := "ahk_id " . WinActive("A"))
  ReleaseModifierKeys()
  ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{esc}, % wBrowser
  Vim.Browser.GetInfo(false)
  ToolTip("Copied " . Vim.Browser.Url . "`n"
        . "Title: " . Vim.Browser.Title
        . (Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : "")
        . (Vim.Browser.Author ? "`nAuthor: " . Vim.Browser.Author : "")
        . (Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : "")
        . (Vim.Browser.VidTime ? "`nTime stamp: " . Vim.Browser.VidTime : ""))
  Clipboard := Vim.Browser.Url, guiaBrowser := ""
return

^!d::  ; parse word definitions
  ClipSaved := ClipboardAll
  if (!Copy(false)) {
    ToolTip("Text not found.")
    goto RestoreClipReturn
  }
  TempClip := Clipboard, Vim.HTML.ClipboardGet_HTML(HTML)
  RegExMatch(HTML, "SourceURL:(.*)", v), url := v1
  if (IfContains(url, "larousse.fr")) {
    TempClip := Vim.HTML.Clean(HTML, true)
    RegExMatch(TempClip, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", TempClip)
    TempClip := RegExReplace(TempClip, "is)<\/?(zzz)?(mark|span)( .*?)?>")
    TempClip := RegExReplace(TempClip, "( | )-( | )", ", ")
    TempClip := StrLower(SubStr(TempClip, 1, 1)) . SubStr(TempClip, 2)  ; make the first letter lower case
    SynPos := RegExMatch(TempClip, "( | ):( | )") + 2
    TempClip := RegExReplace(TempClip, "( | ):( | )", "<p>")
    def := SubStr(TempClip, 1, SynPos)
    AfterDef := SubStr(TempClip, SynPos + 1)
    AfterDef := StrLower(SubStr(AfterDef, 1, 1)) . SubStr(AfterDef, 2)  ; make the first letter lower case
    TempClip := def . AfterDef
    TempClip := StrReplace(TempClip, ".<p>", "<p>")
    TempClip := StrReplace(TempClip, "Synonymes :</p><p>", "syn: ")
    TempClip := StrReplace(TempClip, "Contraires :</p><p>", "ant: ")
  } else if (IfContains(url, "google.com")) {
    TempClip := RegExReplace(TempClip, "(Similar|Synonymes|Synonyms)(.*\r\n)?", "`r`nsyn: ")
    TempClip := RegExReplace(TempClip, "(Opposite|Opuesta).*\r\n", "`r`nant: ")
    TempClip := RegExReplace(TempClip, "(?![:]|(?<![^.])|(?<![^""]))\r\n(?!(syn:|ant:|\r\n))", ", ")
    TempClip := RegExReplace(TempClip, "\.\r\n", "`r`n")
    TempClip := RegExReplace(TempClip, "(\r\n\K""|""(\r\n)?(?=\r\n))", "`r`n")
    TempClip := RegExReplace(TempClip, """$(?!\r\n)")
    TempClip := StrLower(SubStr(TempClip, 1, 1)) . SubStr(TempClip, 2)  ; make the first letter lower case
    TempClip := StrReplace(TempClip, "Vulgar slang:", "vulgar slang: ")
    TempClip := StrReplace(TempClip, "Derogatory:", "derogatory: ")
    TempClip := StrReplace(TempClip, "Offensive:", "offensive: ")
  } else if (IfContains(url, "merriam-webster.com/thesaurus")) {
    TempClip := StrReplace(TempClip, "`r`n", ", ")
    TempClip := RegExReplace(TempClip, "Synonyms & Similar Words, , (Relevance, )?", "syn: ")
    TempClip := StrReplace(TempClip, ", Antonyms & Near Antonyms, , ", "`r`n`r`nant: ")
  } else if (IfContains(url, "en.wiktionary.org/wiki")) {
    TempClip := RegExReplace(TempClip, "Synonyms?:", "syn:")
    TempClip := RegExReplace(TempClip, "Antonyms?:", "ant:")
  } else if (IfContains(url, "collinsdictionary.com")) {
    pos := InStr(TempClip, "`r`n")
    TempClip := SubStr(TempClip, 1, pos) . "`r`n" . StrLower(SubStr(TempClip, pos + 2, 1)) . SubStr(TempClip, pos + 3)
    TempClip := StrReplace(TempClip, ".`r`n", "`r`n`r`n")
    TempClip := StrReplace(TempClip, "Synonyms`r`n", "syn: ")
    TempClip := StrReplace(TempClip, " `r`n", ", ")
  }
  ToolTip("Copied:`n" . Clipboard := TempClip)
return

^!c::  ; copy and register references
  Vim.Browser.Clear()
  guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  WinClip.Snap(data)
  if (!Copy(false))
    ToolTip("No text selected."), WinClip.Restore(data)
  Vim.Browser.GetInfo()
  ToolTip("Copied " . Clipboard . "`n"
        . "Link: " . Vim.Browser.Url . "`n"
        . "Title: " . Vim.Browser.Title
        . (Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : "")
        . (Vim.Browser.Author ? "`nAuthor: " . Vim.Browser.Author : "")
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
  Vim.Browser.Clear(), guiaBrowser := new UIA_Browser("ahk_id " . WinActive("A"))
  if (!Vim.Browser.Url := Vim.Browser.GetParsedUrl()) {
    ToolTip("Url not found.")
    return
  }
  SetTimer, PressBrowserBtn, -1
  Vim.SM.CloseMsgWind()
  ClipSaved := ClipboardAll
  IWB := IfContains(A_ThisLabel, "x,IWB")
  Passive := Vim.SM.IsPassive(CollName := Vim.SM.GetCollName()
                            , ConceptBefore := Vim.SM.GetCurrConcept())
  if (!IWB && Vim.SM.CheckDup(Vim.Browser.Url, false))
    MsgBox, 3,, Continue import?
  WinClose, ahk_class TBrowser
  WinActivate % "ahk_id " . guiaBrowser.BrowserId
  if (IfMsgbox("No") || IfMsgbox("Cancel"))
    goto ImportReturn
  Prio := Concept := CloseTab := DownloadHTML := ResetVidTime := ""
  Vim.Browser.FullTitle := Vim.Browser.GetFullTitle()
  if (IfContains(A_ThisLabel, "+,Prio")) {
    SetDefaultKeyboard(0x0409)  ; English-US
    Gui, SMImport:Add, Text,, % "Current collection: " . CollName
    Gui, SMImport:Add, Text,, &Priority:
    Gui, SMImport:Add, Edit, vPrio w196
    Gui, SMImport:Add, Text,, Concept &group:  ; like in default import dialog
    list := ConceptBefore . "||Online|Sources|ToDo"
    Gui, SMImport:Add, Combobox, vConcept gAutoComplete w196, % list
    Gui, SMImport:Add, Checkbox, vCloseTab, &Close tab  ; like in default import dialog
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
  if (A_ThisLabel == "SMImportButtonImport") {
    ; Without KeyWait Enter SwitchToSameWindow() below could fail???
    KeyWait Enter
    KeyWait I
    Gui, Submit
    if (Passive != 2)
      Passive := (IfIn(Concept, "online,sources")) ? true : false
    Gui, Destroy
    Vim.Caret.SwitchToSameWindow("ahk_id " . guiaBrowser.BrowserId)
  }

  HTMLText := (DownloadHTML || Passive) ? "" : Copy(false, true)
  if (IWB) {
    if (!HTMLText) {
      ToolTip("Text not found.")
      goto ImportReturn
    }
    Vim.Browser.Highlight(CollName, Clipboard)  ; clipboard contains HTML format but is in plain-text
  }
  Online := (Passive || (!HTMLText && bVidSite))
  if (FullPage := (DownloadHTML || (!HTMLText && !Online))) {
    if (DownloadHTML) {
      ToolTip("Attempting to download website...", true)

      ; Using UrlDownloadToFile
      TempPath := A_Temp . "\" . StrReplace(GetTimeMSec(), ":") . ".htm"
      UrlDownloadToFile, % Vim.Browser.Url, % TempPath
      HTMLText := FileRead(TempPath)
      FileDelete, % TempPath

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
  if (Passive == 1)
    Vim.Browser.Date := ""

  WinClip.Clear()
  if (Online && Passive) {
    Vim.SM.RefToClipForTopic(CollName)
  } else if (Online) {
    Clipboard := Vim.Browser.Url
  } else {
    LineBreakList := "baike.baidu.com,m.shuaifox.com,khanacademy.org,mp.weixin.qq.com,webmd.com"
    LineBreak := IfContains(Vim.Browser.Url, LineBreakList)
    HTMLText := Vim.HTML.Clean(HTMLText,, LineBreak, Vim.Browser.Url)
    if (!IWB && !Vim.Browser.Date)
      Vim.Browser.Date := "Imported on " . GetDetailedTime()
    Clipboard := HTMLText . "<br>" . Vim.SM.MakeReference(true)
  }
  ClipWait

  InfoToolTip := "Importing:`n"
               . "Url: " . Vim.Browser.Url . "`n"
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
  Vim.SM.CloseMsgWind()

  if (Concept) {
    Vim.SM.ChangeDefaultConcept(Concept,, ConceptBefore)
    WinWaitClose, ahk_class TRegistryForm
    if (InStr(Vim.SM.GetCurrConcept(), Concept) != 1) {
      WinActivate, ahk_class TElWind
      MsgBox, 3,, Current concept doesn't seem like your entered concept. Continue?
      if (IfMsgbox("No") || IfMsgbox("Cancel"))
        goto ImportReturn
    }
  }

  WinActivate, ahk_class TElWind
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

  ; Making sure the browser is shown for the maximum amount of time
  if (Passive || esc)
    WinActivate % "ahk_id " . guiaBrowser.BrowserId
  Vim.SM.ClearHighlight()
  if (Passive || esc)
    WinActivate % "ahk_id " . guiaBrowser.BrowserId
  Vim.SM.Reload(, true)
  if (Passive || esc)
    WinActivate % "ahk_id " . guiaBrowser.BrowserId
  Vim.SM.WaitFileLoad()
  if (Passive || esc)
    WinActivate % "ahk_id " . guiaBrowser.BrowserId
  Vim.Browser.Title := IWB ? "" : Vim.Browser.Title
  Vim.SM.SetElParam(Vim.Browser.Title, Prio)
  if (Passive || esc)
    WinActivate % "ahk_id " . guiaBrowser.BrowserId

  if (CloseTab) {
    WinActivate % "ahk_id " . guiaBrowser.BrowserId  ; apparently needed for closing tab
    if (IWB)
      sleep 200
    TabCount := ObjCount(oTabs := guiaBrowser.GetAllTabs())
    ControlReleaseModifierKeys("ahk_parent", "ahk_id " . guiaBrowser.BrowserId)
    if (TabCount == 1) {
      ; guiaBrowser.NewTab(), guiaBrowser.CloseTab(oTabs[1]), Passive := false
      ControlSend, ahk_parent, {CtrlDown}t{tab}w{CtrlUp}, % "ahk_id " . guiaBrowser.BrowserId
      Passive := false
    } else {
      ; guiaBrowser.CloseTab()
      ControlSend, ahk_parent, {CtrlDown}w{CtrlUp}, % "ahk_id " . guiaBrowser.BrowserId
      if ((TabCount == 2) && ((oTabs[1].CurrentName = "new tab") || oTabs[2].CurrentName = "new tab"))
        Passive := false
    }
  }

SMImportGuiEscape:
SMImportGuiClose:
ImportReturn:
  if (esc := IfContains(A_ThisLabel, "SMImportGui,ImportReturn")) {
    Gui, Destroy
    Vim.SM.ClearHighlight()
  }
  if (Passive || esc) {
    WinWaitNotActive, % "ahk_id " . guiaBrowser.BrowserId,, 0.1
    Vim.Caret.SwitchToSameWindow("ahk_id " . guiaBrowser.BrowserId)
    send {esc 2}
  } else if (IfIn(A_ThisLabel, "SMImportButtonImport,^!a")) {
    WinWaitNotActive, ahk_class TElWind,, 0.1
    Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
  }
  Vim.Browser.Clear(), Vim.State.SetMode("Vim_Normal")
  if (!esc) {
    Clipboard := ClipSaved, ToolTip("Import completed.")
  } else {
    RemoveToolTip()
  }
return

^+e::
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  run % "msedge.exe " . uiaBrowser.GetCurrentUrl()
return

#if (Vim.State.Vim.Enabled && ((wBrowser := WinActive("ahk_group Browser")) ; browser group (Chrome, Edge, Firefox)
                            || WinActive("ahk_exe ebook-viewer.exe")        ; Calibre (an epub viewer)
                            || WinActive("ahk_class SUMATRA_PDF_FRAME")     ; SumatraPDF
                            || WinActive("ahk_class AcrobatSDIWindow")      ; Acrobat
                            || WinActive("ahk_exe WINWORD.exe")             ; MS Word
                            || WinActive("ahk_exe WinDjView.exe")))         ; djvu viewer
!+d::  ; check duplicates in SM
  ReleaseModifierKeys()
  if (!WinExist("ahk_class TElWind")) {
    ToolTip("Please open SuperMemo and try again.")
    return
  }
  vToolTip := "selected text", skip := false, url := ""
  if (wBrowser) {
    uiaBrowser := new UIA_Browser("ahk_id " . wBrowser)
    if (IfContains(url := uiaBrowser.GetCurrentUrl(), "youtube.com/watch"))
      text := Vim.Browser.ParseUrl(url), skip := true, vToolTip := "url"
  }
  if (!skip && (!text := Copy())) {
    if (wBrowser) {
      if (!url) {
        ToolTip("Url not found.")
        return
      }
      text := Vim.Browser.ParseUrl(url), vToolTip := "url"
    }
  }
  if (!text) {
    ToolTip("Text not found.")
    return
  }
  ToolTip("Searching " . vToolTip . " in " . Vim.SM.GetCollName() . "...", true)
  if (Vim.SM.CheckDup(text))
    RemoveToolTip()
  VimLastSearch := text
return

; Browser / SumatraPDF / Calibre / MS Word to SuperMemo
^+!x::
^!x::
!+x::
!x::
  CtrlState := IfContains(A_ThisHotkey, "^"), hWnd := WinActive("A")
  ClipSaved := ClipboardAll
  if (!Copy(false)) {
    ToolTip("Nothing is selected.")
    goto RestoreClipReturn
  } else {
    if (CleanHTML := (WinActive("ahk_group Browser") || WinActive("ahk_exe ebook-viewer.exe"))) {
      PlainText := Clipboard
      Vim.HTML.ClipboardGet_HTML(data)
      RegExMatch(data, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", data)
      WinClip.Clear()
      Clipboard := Vim.HTML.Clean(data)
      ClipWait
    }
    if (!WinExist("ahk_group SuperMemo")) {
      a := CleanHTML ? " (in HTML)" : ""
      ToolTip("SuperMemo is not open; the text you selected" . a . " is on your clipboard.")
      return
    }
    if (Prio := IfContains(A_ThisHotkey, "+")) {
      if ((!Prio := InputBox("Priority", "Enter extract priority.")) || ErrorLevel)
        return
      if (Prio ~= "^\.")
        Prio := "0" . Prio
    }
    WinActivate, % "ahk_id " . hWnd
    if (WinActive("ahk_group Browser")) {
      Vim.Browser.Highlight(, PlainText)
    } else if (WinActive("ahk_exe ebook-viewer.exe")) {
      ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}q  ; need to enable this shortcut in settings
    } else if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
      ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}a
    } else if (WinActive("ahk_exe WINWORD.exe")) {
      send ^!h
    } else if (WinActive("ahk_exe WinDjView.exe")) {
      send ^h
      WinWaitActive, ahk_class #32770  ; create annotations
      send {enter}
    } else if (WinActive("ahk_class AcrobatSDIWindow")) {
      send {AppsKey}h
      sleep 100
    }
  }
  Vim.SM.CloseMsgWind()
  WinActivate, ahk_class TElWind  ; focus to element window

ExtractToSM:
  if (ret := !Vim.SM.IsEmptyTopic()) {
    if (A_ThisLabel != "ExtractToSM") {
      MsgBox, 3,, Go to source and try again? (press no to paste in current topic)
      if (IfMsgbox("yes")) {
        WinWaitActive, ahk_class TElWind
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        goto ExtractToSM
      } else if (IfMsgBox("no")) {
        WinWaitActive, ahk_class TElWind
        ret := false
      }
    }
    if (ret) {
      ToolTip("Please make sure current element is an empty HTML topic. Your extract is now on your clipboard.")
      return
    }
  }
  Vim.SM.EditFirstQuestion()
  Vim.SM.WaitTextFocus(1500)
  send ^{home}

  if (!CleanHTML) {
    send ^v
  } else {
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

  ; Delete text via Delete before cursor
  ; x := A_CaretX, y := A_CaretY
  ; send {down}
  ; WaitCaretMove(x, y)
  ; send !\\

  loop {
    Vim.SM.CompMenu()
    send kd  ; delete registry link
    WinWaitActive, ahk_class TMsgDialog,, 0.1
    if (!ErrorLevel) {
      send {enter}
      WinWaitClose
      break
    }
  }
  Vim.SM.ActivateElWind()
  send ^+{f7}  ; clear read point
  if (CtrlState) {
    Vim.SM.GoBack()
  } else {
    WinActivate % "ahk_id " . hWnd
  }
  Clipboard := ClipSaved
return

; SumatraPDF
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && !Vim.State.IsCurrentVimMode("Z") && !ControlGetFocus("A"))
+z::Vim.State.SetMode("Z")
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && Vim.State.IsCurrentVimMode("Z") && !ControlGetFocus("A"))
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
  && ((WinActive("ahk_class SUMATRA_PDF_FRAME") && !ControlGetFocus("A"))
   || (WinActive("ahk_exe WinDjView.exe") && (ControlGetFocus("A") != "Edit1"))))
!p::ControlFocus, Edit1, A  ; focus to page number field so you can enter a number
^!f::
  if (!selection := Copy())
    return
  ControlSetText, Edit2, % selection, A
  ControlFocus, Edit2, A
  send {enter 2}^a
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class AcrobatSDIWindow") && (v := A_TickCount - CurrTimeAcrobatPage) && (v <= 400))
!p:: AcrobatPagePaste := true

#if (Vim.State.Vim.Enabled && WinActive("ahk_class AcrobatSDIWindow"))
!p::  ; focus to page number field so you can enter a number
  AcrobatPagePaste := false, CurrTimeAcrobatPage := A_TickCount
  GetAcrobatPageBtn().ControlClick()
  sleep 100
  if (AcrobatPagePaste) {
    send ^a
    send % Clipboard
    send {enter}
  }
return

#if (Vim.State.Vim.Enabled
  && (WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe WinDjView.exe"))
  && (ControlGetFocus("A") == "Edit1"))
!p::
  ControlSetText, Edit1, % Clipboard, A
  send {enter}
return

#if (Vim.State.Vim.Enabled
  && ((pdf := WinActive("ahk_class SUMATRA_PDF_FRAME")) || WinActive("ahk_exe WinDjView.exe"))
  && (page := ControlGetText("Edit1", "A")))
^!p::Clipboard := "p" . page, ToolTip("Copied p" . page)

#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && (ControlGetFocus("A") == "Edit2"))
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
  && (WinActive("ahk_class SUMATRA_PDF_FRAME")
   || WinActive("ahk_exe ebook-viewer.exe")
   || (WinActive("ahk_group Browser") && !Vim.Browser.IsVidSite() && !Vim.SM.IsPassive(, -1))
   || WinActive("ahk_exe WinDjView.exe")
   || WinActive("ahk_class AcrobatSDIWindow"))
  && WinExist("ahk_class TElWind"))
!+s::
^!s::
^+!s::
  ClipSaved := ClipboardAll
  CloseWnd := IfContains(A_ThisHotkey, "^"), ReleaseModifierKeys()
  if ((wSumatra := WinActive("ahk_class SUMATRA_PDF_FRAME")) && IfContains(ControlGetFocus("A"), "Edit"))
    send {esc}
  marker := trim(Copy(false), " `t`r`n")
  if (wSumatra || (wDJVU := WinActive("ahk_exe WinDjView.exe")) || (wAcrobat := WinActive("ahk_class AcrobatSDIWindow"))) {
    if (wAcrobat)
      marker := "p" . GetAcrobatPageBtn().Value
    if (!wAcrobat && !marker && (page := ControlGetText("Edit1", "A")))
      marker := "p" . page
    if (!marker) {
      ToolTip("No text selected and page number not found.")
      goto RestoreClipReturn
    }
    if (CloseWnd) {
      if (wSumatra) {
        send {text}q
        WinWait, Unsaved annotations,, 0
        if (!ErrorLevel)
          ControlClick, Button1,,,,, NA
      } else if (wDJVU) {
        send ^w
        WinWaitTitle("WinDjView", 1500, "A")
        WinClose, % "ahk_id " . wDJVUj
      } else if (wAcrobat) {
        send ^s^w
        WinWaitTitle("Adobe Acrobat Pro DC (32-bit)", 1500, "A")
        WinClose, % "ahk_id " . wAcrobat
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
      if (WinActive("ahk_group Browser")) {
        ControlReleaseModifierKeys("ahk_parent", "ahk_id " . guiaBrowser.BrowserId)
        ControlSend, ahk_parent, {CtrlDown}w{CtrlUp}, % "ahk_id " . guiaBrowser.BrowserId
      } else {  ; epub viewer
        WinClose, A
      }
    }
  }
  Vim.SM.CloseMsgWind()
  WinActivate, ahk_class TElWind

MarkInSMTitle:
  SMTitle := RegExReplace(ElWindTitle := WinGetTitle("ahk_class TElWind"), "^Duplicate: ")
  NewTitle := RegExReplace(SMTitle, "((^.+ \| )|^)", marker . " | ")
  if (ElWindTitle == NewTitle) {
    ToolTip("No need to change current title.")
    return
  }
  if (ret := !Vim.SM.IsEmptyTopic()) {
    if (A_ThisLabel != "MarkInSMTitle") {
      MsgBox, 3,, Go to source and try again? (press no to execute in current topic)
      if (IfMsgbox("yes")) {
        WinWaitActive, ahk_class TElWind
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        goto MarkInSMTitle
      } else if (IfMsgBox("no")) {
        WinWaitActive, ahk_class TElWind
        ret := false
      }
    }
    if (ret) {
      ToolTip("No source element found or source element isn't empty. Your mark is now on your clipboard.")
      Clipboard := marker
      return
    }
  }
  Vim.SM.SetTitle(NewTitle)
  if (IfContains(A_ThisHotkey, "^+!"))
    Vim.SM.Learn(false, true)
  Clipboard := ClipSaved
return

; IE
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe"))
; Open in default browser (in my case, Chrome); similar to default shortcut ^+e to open in ms edge
^+c::run % ControlGetText("Edit1", "A")  ; browser url field
^+e::run % "msedge.exe " . ControlGetText("Edit1", "A")
^!l::ToolTip("Copied " . Clipboard := ControlGetText("Edit1", "A"))
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe msedge.exe"))
^+c::
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  run % uiaBrowser.GetCurrentUrl()
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class wxWindowNR") && WinExist("ahk_class TElWind"))  ; audacity.exe
^!x::
!x::
  CurrTime := GetTimeMSec(), ReleaseModifierKeys()
  if (A_ThisHotkey == "^!x") {
    send ^a
    PostMessage, 0x0111, 17216,,, A  ; truncate silence
    WinWaitActive, Truncate Silence
    ; Settings for truncate complete silence
    ControlSetText, Edit1, -80
    ControlSetText, Edit2, 0.001
    ControlSetText, Edit3, 0
    send {enter}
    WinWaitNotActive, Truncate Silence
    WinWaitActive, ahk_class wxWindowNR  ; audacity main window
    send ^+e  ; save
    WinWaitActive, Export Audio
  } else if (A_ThisHotkey == "!x") {
    PostMessage, 0x0111, 17011,,, A  ; export selected audio
    WinWaitActive, Export Selected Audio
  }
  FileName := RegExReplace(Vim.Browser.Title . CurrTime, "[^a-zA-Z0-9\\.\\-]", "_")
  TempPath := A_Temp . "\" . FileName . ".mp3"
  Control, Choose, 3, ComboBox3  ; choose mp3 from file type
  ControlSetText, Edit1, % TempPath
  send {enter}
  WinWaitActive, Warning,, 0
  if (!ErrorLevel) {
    send {enter}
    WinWaitClose
  }
  send ^a{bs}
  Vim.SM.CloseMsgWind()
  WinActivate, ahk_class TElWind
  Vim.SM.AltA()
  Vim.SM.WaitFileLoad()
  QuestionFieldName := ControlGetFocus("A")
  if (Vim.Browser.Title) {
    send % "{text}" . Vim.SM.MakeReference()
  } else {
    send {text}Listening comprehension:
  }
  Vim.SM.InvokeFileBrowser()
  Vim.SM.FileBrowserSetPath(TempPath, true)
  WinWaitActive, ahk_class TInputDlg
  if (Vim.Browser.Title) {
    ControlSetText, TMemo1, % Vim.Browser.Title . " (excerpt)", A
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
  this.CompMenu()
  send fl  ; previous component
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
  ReleaseModifierKeys()
  if (CopyAll())
    Vim.SM.CheckDup(MatchHiborLink(Clipboard))
  Clipboard := ClipSaved
return

#if (Vim.State.Vim.Enabled && (hWnd := WinActive("ahk_exe HiborClient.exe")) && WinExist("ahk_class TElWind"))
^+!a::
^!a::  ; import
  ClipSaved := ClipboardAll
  ReleaseModifierKeys()
  if (!CopyAll())
    goto RestoreClipReturn
  link := MatchHiborLink(Clipboard)
  title := MatchHiborTitle(Clipboard)
  RegExMatch(title, "^.*?(?=-)", source)
  title := StrReplace(title, source . "-",,, 1)
  RegExMatch(title, "\d{6}$", date)
  title := StrReplace(title, "-" . date,,, 1)
  if (Vim.SM.CheckDup(link, false))
    MsgBox, 3,, Continue import?
  WinActivate % "ahk_id " . hWnd
  WinClose, ahk_class TBrowser
  if (IfMsgbox("No") || IfMsgbox("Cancel"))
    goto HBImportReturn
  if (IfContains(A_ThisHotkey, "+")) {
    Prio := InputBox("Priority", "Enter extract priority.")
    if (!(Prio >= 0) || ErrorLevel) {
      prio := ""
    } else if (Prio ~= "^\.") {
      Prio := "0" . Prio
    }
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
  Vim.SM.Reload()
  Vim.SM.SetElParam(title, prio)

HBImportReturn:
  Vim.SM.ClearHighlight()
  WinWaitNotActive, ahk_class TElWind,, 0.1
  Vim.Caret.SwitchToSameWindow("ahk_class TElWind"), Clipboard := ClipSaved
return

MatchHiborTitle(text) {
  RegExMatch(text, "s)意见反馈\r\n(研究报告：)?\K.*?(?=\r\n)", v)
  return v
}

MatchHiborLink(text) {
  RegExMatch(text, "s)推荐给朋友:\r\n\K.*?(?=  )", v)
  return v
}

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe Discord.exe"))
^!l::  ; go live
  if (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.3.1.2.1.1.2.1.1.2.1.6",, "A"))
    return
  accBtn.accDoDefaultAction(0)
  while (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.4.2.1.1.2.2.1.1.3",, "A"))
    sleep 40
  accBtn.accDoDefaultAction(0)
  while (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.4.2.1.1.2.2.1.2.1.1",, "A"))
    sleep 40
  accBtn.accDoDefaultAction(0)
  while (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.4.2.1.1.2.2.1.13.1",, "A"))
    sleep 40
  accBtn.accDoDefaultAction(0)
  while (!accBtn := Acc_Get("Object", "4.1.1.1.1.1.2.1.2.4.2.1.1.2.3.1",, "A"))
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
