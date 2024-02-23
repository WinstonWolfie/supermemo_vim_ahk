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
  Send ^v
return

LAlt & RAlt::  ; for laptop
  KeyWait LAlt
  KeyWait RAlt
  Send {AppsKey}
  if (Vim.IsVimGroup())
    Vim.State.SetMode("Insert")
return

#f::ShellRun("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Everything 1.5a.lnk")
^#h::Send ^#{Left}
^#l::Send ^#{Right}
+#h::Send +#{Left}
+#l::Send +#{Right}

^+!p::
Plan:
  Vim.State.SetMode("Vim_Normal")
  KeyWait Ctrl
  KeyWait Alt
  KeyWait Shift
  if (!WinExist("ahk_group SM")) {
    ShellRun("C:\SuperMemo\systems\all.kno")
    WinWait, ahk_class TElWind,, 3
    if (ErrorLevel)
      return
    WinActivate
    if (!Vim.SM.Plan())
      return
    WinWait, Information ahk_class TMsgDialog,, 1.5
    if (!ErrorLevel)
      WinClose
    WinActivate, ahk_class TPlanDlg
    return
  }
  Vim.SM.CloseMsgDialog()
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
  Vim.SM.CloseMsgDialog()
return

; Browsers
#if (Vim.State.Vim.Enabled && WinActive("ahk_group Browser"))
^!w::
  KeyWait Ctrl
  KeyWait Alt
  BrowserTitle := WinGetTitle("A")
  Send ^w
  WinWaitTitleChange(BrowserTitle, "A", 200)
  Send !{tab}  ; close tab and switch back
return

^!i::  ; open in *I*E
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  Vim.Browser.RunInIE(Vim.Browser.ParseUrl(uiaBrowser.GetCurrentURL()))
  ; ShellRun("iexplore.exe " . Vim.Browser.ParseUrl(GetActiveBrowserURL()))  ; RIP old method
Return

^!t::  ; copy *t*itle
  Vim.Browser.GetTitleSourceDate(false, false,,, false, false)
  Vim.State.SetToolTip("Copied " . Clipboard := Vim.Browser.Title), Vim.Browser.Clear()
return

^!l::  ; copy and parse *l*ink
  Vim.Browser.Clear()
  ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Esc}, A
  Vim.Browser.GetInfo(false)
  Vim.State.SetToolTip("Copied " . Vim.Browser.Url . "`n"
        . "Title: " . Vim.Browser.Title
        . (Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : "")
        . (Vim.Browser.Author ? "`nAuthor: " . Vim.Browser.Author : "")
        . (Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : "")
        . (Vim.Browser.TimeStamp ? "`nTime stamp: " . Vim.Browser.TimeStamp : ""))
  Clipboard := Vim.Browser.Url, guiaBrowser := ""
return

^!d::  ; parse word *d*efinitions
  ClipSaved := ClipboardAll
  if (!Copy(false)) {
    Vim.State.SetToolTip("Text not found.")
    Goto RestoreClipReturn
  }
  TempClip := Clipboard, ClipboardGet_HTML(HTML), Url := GetClipLink(HTML)
  if (IfContains(Url, "larousse.fr")) {
    TempClip := Vim.SM.CleanHTML(GetClipHTMLBody(HTML), true)
    TempClip := RegExReplace(TempClip, "is)<\/?(mark|span)( .*?)?>")
    TempClip := RegExReplace(TempClip, "( | )-( | )", ", ")
    TempClip := StrLower(SubStr(TempClip, 1, 1)) . SubStr(TempClip, 2)  ; make the first letter lower case
    SynPos := RegExMatch(TempClip, "( | ):( | )") + 2
    TempClip := RegExReplace(TempClip, "( | ):( | )", "<p>")
    Def := SubStr(TempClip, 1, SynPos)
    AfterDef := SubStr(TempClip, SynPos + 1)
    AfterDef := StrLower(SubStr(AfterDef, 1, 1)) . SubStr(AfterDef, 2)  ; make the first letter lower case
    TempClip := Def . AfterDef
    TempClip := StrReplace(TempClip, ".<p>", "<p>")
    TempClip := StrReplace(TempClip, "Synonymes :</p><p>", "syn: ")
    TempClip := StrReplace(TempClip, "Contraires :</p><p>", "ant: ")
  } else if (IfContains(Url, "google.com")) {
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
  } else if (IfContains(Url, "merriam-webster.com/thesaurus")) {
    TempClip := StrReplace(TempClip, "`r`n", ", ")
    TempClip := RegExReplace(TempClip, "Synonyms & Similar Words, , (Relevance, )?", "syn: ")
    TempClip := StrReplace(TempClip, ", Antonyms & Near Antonyms, , ", "`r`n`r`nant: ")
  } else if (IfContains(Url, "en.wiktionary.org/w")) {
    TempClip := RegExReplace(TempClip, "Synonyms?:", "syn:")
    TempClip := RegExReplace(TempClip, "Antonyms?:", "ant:")
  } else if (IfContains(Url, "collinsdictionary.com")) {
    TempClip := StrReplace(TempClip, " `r`n", ", ")
    TempClip := StrReplace(TempClip, "Synonyms`r`n", "syn: ")
  } else if (IfContains(Url, "thesaurus.com")) {
    TempClip := StrReplace(TempClip, "`r`n", ", ")
    TempClip := RegExReplace(TempClip, "SYNONYMS FOR, .*?, , ", "syn: ")
  }
  Vim.State.SetToolTip("Copied:`n" . Clipboard := TempClip)
return

^!c::  ; copy and register references
  Vim.Browser.Clear(), WinClip.Snap(data)
  if (!Copy(false))
    Vim.State.SetToolTip("No text selected."), WinClip.Restore(data)
  Vim.Browser.GetInfo()
  Vim.State.SetToolTip("Copied " . Clipboard . "`n"
        . "Link: " . Vim.Browser.Url . "`n"
        . "Title: " . Vim.Browser.Title
        . (Vim.Browser.Source ? "`nSource: " . Vim.Browser.Source : "")
        . (Vim.Browser.Author ? "`nAuthor: " . Vim.Browser.Author : "")
        . (Vim.Browser.Date ? "`nDate: " . Vim.Browser.Date : ""))
  guiaBrowser := ""
return

^!m::  ; copy ti*m*e stamp
  ClipSaved := ClipboardAll
  if (!Clipboard := Vim.Browser.GetTimeStamp(,, false)) {
    Vim.State.SetToolTip("Not found.")
    Goto RestoreClipReturn
  }
  Vim.State.SetToolTip("Copied " . Clipboard), Vim.Browser.Clear()
return

~^f::
  if ((A_PriorHotkey != "~^f") || (A_TimeSincePriorHotkey > 400)) {
    KeyWait f
    return
  }
  Send ^v{Enter}
return

~^l::
  if ((A_PriorHotkey != "~^l") || (A_TimeSincePriorHotkey > 400)) {
    KeyWait l
    return
  }
  Send ^v
return

; Incremental web browsing
^+!b::
IWBPriorityAndConcept:
IWBNewTopic:
; Import current webpage to SuperMemo
; Incremental video: Import current YT video to SM
^+!a::
^!a::
  if (!WinExist("ahk_class TElWind")) {
    Vim.State.SetToolTip("Please open SuperMemo and try again.")
    return
  }
  if (WinExist("ahk_id " . SMImportGuiHwnd)) {
    WinActivate
    return
  }

  ClipSaved := ClipboardAll
  if (IWB := IfContains(A_ThisLabel, "IWB,^+!b")) {
    if (!HTMLText := Copy(false, true)) {
      Vim.State.SetToolTip("Text not found.")
      Goto RestoreClipReturn
    }
  }

  Vim.Browser.Clear()
  if (IWB) {
    Vim.Browser.Url := Vim.Browser.ParseUrl(RetrieveUrlFromClip())
  } else {
    Vim.Browser.Url := Vim.Browser.GetUrl()
  }
  if (!Vim.Browser.Url) {
    Vim.State.SetToolTip("Url not found.")
    Goto RestoreClipReturn
  }

  wBrowser := "ahk_id " . WinActive("A")
  Vim.Browser.FullTitle := Vim.Browser.GetFullTitle("A")
  IsVideoOrAudioSite := Vim.Browser.IsVideoOrAudioSite(Vim.Browser.FullTitle)
  ClickBrowserBtnFinished := false
  SetTimer, ClickBrowserBtn, -1

  Vim.SM.CloseMsgDialog()
  CollName := Vim.SM.GetCollName()
  ConceptBefore := Vim.SM.GetCurrConcept()
  OnlineEl := Vim.SM.IsOnline(CollName, -1)

  DupChecked := MB := false
  if (!IWB) {
    if (Vim.SM.CheckDup(Vim.Browser.Url, false))
      MB := MsgBox(3,, "Continue import?")
    DupChecked := true
  }
  WinClose, ahk_class TBrowser
  WinActivate % wBrowser
  if (IfIn(MB, "No,Cancel"))
    Goto SMImportReturn

  Prio := Concept := CloseTab := DLHTML := ResetVidTime := CheckDupForIWB := ""
  Tags := RefComment := ClipBeforeGui := UseOnlineProgress := ""
  while (!ClickBrowserBtnFinished)
    Continue
  DLList := "economist.com,investopedia.com,webmd.com,britannica.com,medium.com,wired.com"
  if (IfIn(A_ThisLabel, "^+!a,IWBPriorityAndConcept,^+!b")) {
    ClipBeforeGui := Clipboard
    SetDefaultKeyboard(0x0409)  ; English-US
    Gui, SMImport:Add, Text,, % "Current collection: " . CollName
    Gui, SMImport:Add, Text,, &Priority:
    Gui, SMImport:Add, Edit, vPrio w280
    Gui, SMImport:Add, Text,, Concept &group:  ; like in default import dialog
    ConceptList := "||Online|Sources|ToDo"
    if (IfIn(ConceptBefore, "Online,Sources,ToDo"))
      ConceptList := StrReplace(ConceptList, "|" . ConceptBefore)
    list := StrLower(ConceptBefore . ConceptList)
    Gui, SMImport:Add, ComboBox, vConcept gAutoComplete w280, % list
    Gui, SMImport:Add, Text,, &Tags (without # and use `; to separate):
    Gui, SMImport:Add, Edit, vTags w280
    Gui, SMImport:Add, Text,, Reference c&omment:
    Gui, SMImport:Add, Edit, vRefComment w280
    Gui, SMImport:Add, Checkbox, vCloseTab, &Close tab  ; like in default import dialog
    if (!IWB && !IsVideoOrAudioSite && !OnlineEl) {
      Gui, SMImport:Add, Checkbox, vOnlineEl, Import as o&nline element
      check := IfContains(Vim.Browser.Url, DLList) ? "checked" : ""
      Gui, SMImport:Add, Checkbox, % "vDLHTML " . check, Import fullpage &HTML
    }
    if (IWB)
      Gui, SMImport:Add, Checkbox, vCheckDupForIWB, Check &duplication
    if (IsVideoOrAudioSite || OnlineEl) {
      Gui, SMImport:Add, Checkbox, vResetVidTime, &Reset time stamp
      if (IfContains(Vim.Browser.Url, "youtube.com/watch")) {
        check := (CollName = "bgm") ? "checked" : ""
        Gui, SMImport:Add, Checkbox, % "vUseOnlineProgress " . check, &Mark as use online progress
      }
    }
    Gui, SMImport:Add, Button, default, &Import
    Gui, SMImport:Show,, SuperMemo Import
    Gui, SMImport:+HwndSMImportGuiHwnd
    return
  } else {
    DLHTML := IfContains(Vim.Browser.Url, DLList)
  }

SMImportButtonImport:
  if (A_ThisLabel == "SMImportButtonImport") {
    ; Without KeyWait Enter SwitchToSameWindow() below could fail???
    KeyWait Enter
    KeyWait I
    Gui, Submit
    Gui, Destroy
  }

  if (OnlineEl != 1)
    OnlineEl := Vim.SM.IsOnline(CollName, Concept)
  if (OnlineEl)  ; just in case user checks both of them
    DLHTML := false
  if (OnlineEl && IWB) {
    ret := true
    if (MsgBox(3,, "You chosed an online concept. Choose again?") = "Yes") {
      Concept := InputBox(, "Enter a new concept:")
      if (!ErrorLevel && !Vim.SM.IsOnline(-1, Concept))
        ret := false
    }
    if (ret)
      Goto SMImportReturn
  }

  Vim.Caret.SwitchToSameWindow(wBrowser)
  if (!IWB)  ; IWB copies text before
    HTMLText := (DLHTML || OnlineEl) ? "" : Copy(false, true)  ; do not copy if download html or online element is checked

  if (CheckDupForIWB) {
    MB := ""
    if (Vim.SM.CheckDup(Vim.Browser.Url, false))
      MB := MsgBox(3,, "Continue import?")
    DupChecked := true
    WinClose, ahk_class TBrowser
    WinActivate % wBrowser
    if (IfIn(MB, "No,Cancel"))
      Goto SMImportReturn
  }

  if (IWB)
    Vim.Browser.Highlight(CollName, Clipboard, Vim.Browser.Url)

  if (LocalFile := (Vim.Browser.Url ~= "^file:\/\/\/"))
    DLHTML := true
  SMCtrlNYT := (!OnlineEl && Vim.SM.IsCtrlNYT(Vim.Browser.Url))
  CopyAll := (!HTMLText && !OnlineEl && !DLHTML && !SMCtrlNYT)
  if (DLHTML) {
    if (LocalFile) {
      HTMLText := FileRead(EncodeDecodeURI(RegExReplace(Vim.Browser.Url, "^file:\/\/\/"), false))
      Vim.Browser.Url := RegExReplace(Vim.Browser.Url, "^file:\/\/\/", "file://")  ; SuperMemo converts file:/// to file://
    } else {
      Vim.State.SetToolTip("Attempting to download website...")
      TempPath := A_Temp . "\" . GetCurrTimeForFileName() . ".htm"
      UrlDownloadToFile, % Vim.Browser.Url, % TempPath
      if (ErrorLevel) {
        Vim.State.SetToolTip("Download failed."), CopyAll := true
      } else {
        HTMLText := FileReadAndDelete(TempPath)
        ; Fixing links
        RegExMatch(Vim.Browser.Url, "^https?:\/\/.*?\/", UrlHead)
        RegExMatch(Vim.Browser.Url, "^https?:\/\/", HTTP)
        HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K (href|src)=""\/\/(?=([^<>]+)?>)", " $2=""" . HTTP)
        HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K (href|src)=""\/(?=([^<>]+)?>)", " $2=""" . UrlHead)
        HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K (href|src)=""(?=#([^<>]+)?>)", " $2=""" . Vim.Browser.Url)
      }
    }
  }

  if (CopyAll) {
    CopyAll()
    HTMLText := GetClipHTMLBody()
  }
  if (!OnlineEl && !HTMLText && !SMCtrlNYT) {
    Vim.State.SetToolTip("Text not found.")
    Goto SMImportReturn
  }

  SkipDate := (OnlineEl && !IsVideoOrAudioSite && (OnlineEl != 2))
  Vim.Browser.GetTitleSourceDate(false,, (CopyAll ? Clipboard : ""),, !SkipDate, !ResetVidTime)

  if (ResetVidTime)
    Vim.Browser.TimeStamp := "0:00"
  if (SkipDate)
    Vim.Browser.Date := ""

  SMPoundSymbHandled := Vim.SM.PoundSymbLinkToComment()
  if (Tags || RefComment) {
    TagsComment := ""
    if (Tags) {
      TagsComment := StrReplace(Trim(Tags), " ", "_")
      TagsComment := "#" . StrReplace(TagsComment, ";", " #")
    }
    if (RefComment && TagsComment)
      TagsComment := " " . TagsComment 
    if (Vim.Browser.Comment)
      Vim.Browser.Comment := " " . Vim.Browser.Comment
    Vim.Browser.Comment := Trim(RefComment) . TagsComment . Vim.Browser.Comment
  }

  if (OnlineEl) {
    ScriptUrl := Vim.Browser.Url
    if (Vim.Browser.TimeStamp && (TimeStampedUrl := Vim.Browser.TimeStampToUrl(Vim.Browser.Url, Vim.Browser.TimeStamp)))
      ScriptUrl := TimeStampedUrl
    if (Vim.Browser.TimeStamp && !TimeStampedUrl) {
      SetClipboardHTML("<SPAN class=Highlight>SMVim time stamp</SPAN>: " . Vim.Browser.TimeStamp . Vim.SM.MakeReference(true))
    } else if (UseOnlineProgress) {
      SetClipboardHTML("<SPAN class=Highlight>SMVim: Use online video progress</SPAN>" . Vim.SM.MakeReference(true))
    } else {
      Clipboard := Vim.SM.MakeReference()
    }
  } else if (SMCtrlNYT) {
    Clipboard := Vim.Browser.Url
  } else {
    LineBreakList := "baike.baidu.com,m.shuaifox.com,khanacademy.org,mp.weixin.qq.com,webmd.com,proofwiki.org"
    LineBreak := IfContains(Vim.Browser.Url, LineBreakList)
    HTMLText := Vim.SM.CleanHTML(HTMLText,, LineBreak, Vim.Browser.Url)
    if (!IWB && !Vim.Browser.Date)
      Vim.Browser.Date := "Imported on " . GetDetailedTime()
    Clipboard := HTMLText . Vim.SM.MakeReference(true)
  }

  InfoToolTip := "Importing:`n"
               . "Url: " . Vim.Browser.Url . "`n"
               . "Title: " . Vim.Browser.Title
  if (Vim.Browser.Source)
    InfoToolTip .= "`nSource: " . Vim.Browser.Source
  if (Vim.Browser.Author)
    InfoToolTip .= "`nAuthor: " . Vim.Browser.Author
  if (Vim.Browser.Date)
    InfoToolTip .= "`nDate: " . Vim.Browser.Date
  if (Vim.Browser.TimeStamp)
    InfoToolTip .= "`nTime stamp: " . Vim.Browser.TimeStamp
  if (Vim.Browser.Comment)
    InfoToolTip .= "`nComment: " . Vim.Browser.Comment
  Vim.State.SetToolTip(InfoToolTip)

  if (Prio ~= "^\.")
    Prio := "0" . Prio
  Vim.SM.CloseMsgDialog()

  ChangeBackConcept := ""
  if (Concept) {
    if (Skip := ((OnlineEl == 1) && !Vim.SM.IsOnline(-1, Concept)))
      ChangeBackConcept := Concept, Concept := "online"
    if (Vim.SM.SetCurrConcept(Concept, ConceptBefore))
      WinWaitClose
    if (!Skip && (InStr(Vim.SM.GetCurrConcept(), Concept) != 1)) {
      WinActivate, ahk_class TElWind
      MB := MsgBox(3,, "Current concept doesn't seem like your entered concept. Continue?")
      if (IfIn(MB, "No,Cancel"))
        Goto SMImportReturn
    }
  }

  if (SMCtrlNYT) {
    Gosub SMCtrlN
  } else if (!OnlineEl) {
    PrevSMTitle := WinGetTitle("ahk_class TElWind")
    Vim.SM.AltN()
    Vim.SM.WaitTextFocus()
    TempTitle := WinWaitTitleChange(PrevSMTitle, "ahk_class TElWind")
    Vim.SM.PasteHTML()
    Vim.SM.ExitText()
    WinWaitTitleChange(TempTitle, "A")

  } else if (OnlineEl) {
    Vim.SM.CtrlN()
    Vim.SM.WaitFileLoad()
    Vim.SM.EditFirstQuestion()
    WinWaitActive, ahk_class TElWind
    pidSM := WinGet("PID")
    Send ^t{f9}{Enter}
    WinWait, % wScript := "ahk_class TScriptEditor ahk_pid " . pidSM,, 3
    WinActivate, % wBrowser
    if (ErrorLevel) {
      Vim.State.SetToolTip("Script component not found.")
      Goto SMImportReturn
    }

    ; ControlSetText to "rl" first than send one "u" is needed to update the editor,
    ; thus prompting it to ask to save on exiting
    ControlSetText, TMemo1, % "rl " . ScriptUrl
    ControlSend, TMemo1, {text}u
    ControlSend, TMemo1, {Esc}
    WinWait, % "ahk_class TMsgDialog ahk_pid " . pidSM
    ControlSend, ahk_parent, {Enter}
    WinWaitClose
    WinWaitClose, % wScript
  }

  ; All SM operations here are handled in the background
  Vim.SM.SetElParam(IWB ? "" : Vim.Browser.Title, Prio, (SMCtrlNYT ? "YouTube" : ""), ChangeBackConcept ? ChangeBackConcept : "")
  if (DupChecked)
    Vim.SM.ClearHighlight()
  if (!SMPoundSymbHandled)
    Vim.SM.HandleSM19PoundSymbUrl(Vim.Browser.Url)
  Vim.SM.Reload(, true)
  Vim.SM.WaitFileLoad()
  if (ChangeBackConcept)
    Vim.SM.SetCurrConcept(ChangeBackConcept)
  if (Tags)
    Vim.SM.LinkConcepts(StrSplit(Tags, ";"), OnlineEl ? wBrowser : "")

  if (CloseTab) {
    WinActivate % wBrowser  ; apparently needed for closing tab
    ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Ctrl Down}w{Ctrl Up}, % wBrowser
  }

SMImportGuiEscape:
SMImportGuiClose:
SMImportReturn:
  EscGui := IfContains(A_ThisLabel, "SMImportGui")
  if (Esc := IfContains(A_ThisLabel, "SMImportGui,SMImportReturn")) {
    if (EscGui)
      Gui, Destroy
    if (DupChecked)
      Vim.SM.ClearHighlight()
  }
  if (OnlineEl || Esc) {
    WinActivate, % wBrowser
    if (!Esc && !IfIn(IsVideoOrAudioSite, "2,3"))
      Send {Esc 2}
  }
  Vim.Browser.Clear(), Vim.State.SetMode("Vim_Normal")
  ; If closed GUI but did not copy anything, restore clipboard
  ; If closed GUI but copied something while the GUI is open, do not restore clipboard
  if (!EscGui || (Clipboard == ClipBeforeGui))
    Clipboard := ClipSaved
  if (!Esc)
    Vim.State.SetToolTip("Import completed.")
  HTMLText := ""
return

^+e::
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  ShellRun("msedge.exe " . uiaBrowser.GetCurrentUrl())
return

#if (Vim.State.Vim.Enabled && ((hBrowser := WinActive("ahk_group Browser")) ; browser group (Chrome, Edge, Firefox)
                            || WinActive("ahk_exe ebook-viewer.exe")        ; Calibre (an epub viewer)
                            || WinActive("ahk_class SUMATRA_PDF_FRAME")     ; SumatraPDF
                            || WinActive("ahk_class AcrobatSDIWindow")      ; Acrobat
                            || WinActive("ahk_exe WINWORD.exe")             ; MS Word
                            || WinActive("ahk_exe WinDjView.exe")))         ; djvu viewer
!+d::  ; check duplicates in SM
  if (!WinExist("ahk_class TElWind")) {
    Vim.State.SetToolTip("Please open SuperMemo and try again.")
    return
  }
  ToolTip := "selected text", Skip := false, Url := ""
  if (hBrowser) {
    uiaBrowser := new UIA_Browser("ahk_id " . hBrowser)
    if (IfContains(Url := uiaBrowser.GetCurrentUrl(), "youtube.com/watch,netflix.com/watch"))
      Text := Vim.Browser.ParseUrl(Url), Skip := true, ToolTip := "url"
  }
  if (!Skip && (!Text := Copy())) {
    if (hBrowser) {
      if (!Url) {
        Vim.State.SetToolTip("Url not found.")
        return
      }
      Text := Vim.Browser.ParseUrl(Url), ToolTip := "url"
    }
  }
  if (!Text) {
    Vim.State.SetToolTip("Text not found.")
    return
  }
  Vim.State.SetToolTip("Searching " . ToolTip . " in " . Vim.SM.GetCollName() . "...")
  Vim.SM.CheckDup(Text)
  VimLastSearch := Text
return

; Browser / SumatraPDF / Calibre / MS Word to SuperMemo
^+!x::
^!x::
!+x::
!x::
  CtrlState := IfContains(A_ThisLabel, "^")
  ShiftState := IfContains(A_ThisLabel, "+")
  hWnd := WinActive("A"), Prio := "", wCurr := "ahk_id " . hWnd
  ClipSaved := ClipboardAll
  hBrowser := WinActive("ahk_group Browser")
  hCalibre := WinActive("ahk_exe ebook-viewer.exe")
  KeyWait Alt
  KeyWait Ctrl
  KeyWait Shift

  if (!Copy(false)) {
    Clipboard := ClipSaved  ; might be used in InputBox below
    if ((ch := InputBox(, "Extract chapter/section:")) && !ErrorLevel) {
      if (!CtrlState)
        CurrEl := Vim.SM.GetElNumber()
      if (ShiftState)
        Prio := Vim.SM.AskPrio(false)
      WinActivate, ahk_class TElWind
      if (ParentElNumber := Vim.SM.GetParentElNumber()) {
        Vim.SM.GoToEl(ParentElNumber)
        WinWaitActive, ahk_class TElWind
        Vim.SM.WaitFileLoad()
      }
      Vim.SM.OpenBrowser()
      WinWaitActive, ahk_class TBrowser
      Send ^f
      WinWaitActive, ahk_class TMyFindDlg
      ControlSetText, TEdit1, % ch
      Send {Enter}
      WinWaitActive, ahk_class TProgressBox,, 1
      if (!ErrorLevel)
        WinWaitClose

      StartTime := A_TickCount
      loop {
        if (WinActive("ahk_class TMsgDialog")) {  ; not found
          WinClose
          Break
        } else if (WinGetTitle("ahk_class TBrowser") ~= "^0 users of ") {
          Break
        } else if (WinGetTitle("ahk_class TBrowser") ~= "^[1-9]+ users of ") {
          if (IfIn(MsgBox(3,, "Continue?"), "No,Cancel")) {
            WinClose, ahk_class TBrowser
            Vim.SM.ClickElWindSourceBtn()
            Vim.SM.ClearHighlight()
            return
          }
          Vim.SM.ClickElWindSourceBtn()
          Vim.SM.WaitFileLoad()
          Break
        } else if (A_TickCount - StartTime > 1500) {
          Vim.SM.ClearHighlight(), Vim.State.SetToolTip("Timed out.")
          return
        }
      }

      WinClose, ahk_class TBrowser
      WinWaitActive, ahk_class TElWind
      Vim.SM.Duplicate()
      Vim.SM.WaitFileLoad()
      SMTitle := WinWaitTitleRegEx("^Duplicate: ", "ahk_class TElWind")
      if (!Vim.SM.IsHTMLEmpty() && (MsgBox(3,, "Remove text?") = "Yes"))
        Vim.SM.EmptyHTMLComp()
      if (!CtrlState)
        WinActivate, % wCurr
      Vim.SM.SetTitle(RegExReplace(SMTitle, "^Duplicate: ") . " (" . ch . ")")
      if (ShiftState)
        Vim.SM.SetPrio(Prio,, true)
      if (!CtrlState)
        Vim.SM.GoToEl(CurrEl,, true)
      Vim.SM.ClearHighlight()
    }
    return

  } else {
    if (CleanHTML := (hBrowser || hCalibre)) {
      if (hBrowser)
        PlainText := Clipboard
      ClipboardGet_HTML(HTML)
      if (hBrowser)
        BrowserUrl := Vim.Browser.ParseUrl(GetClipLink(HTML))
      HTML := Vim.SM.CleanHTML(GetClipHTMLBody(HTML))
      if (hCalibre)
        HTML := StrReplace(HTML, "data-calibre-range-wrapper=""1""", "class=extract")
      Clipboard := HTML
    }
    if (!WinExist("ahk_group SM")) {
      a := CleanHTML ? "(in HTML)" : ""
      Vim.State.SetToolTip("SuperMemo is not open; the text you selected " . a . " is on your clipboard.")
      return
    }
    if (ShiftState)
      Prio := Vim.SM.AskPrio(false)
    WinActivate, % wCurr
    if (hBrowser) {
      Vim.Browser.Highlight(, PlainText, BrowserUrl)
    } else if (hCalibre) {
      ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}q, % "ahk_id " . hCalibre  ; need to enable this shortcut in settings
    } else if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
      Send a
    } else if (WinActive("ahk_exe WINWORD.exe")) {
      Send ^!h
    } else if (WinActive("ahk_exe WinDjView.exe")) {
      Send ^h
      WinWaitActive, ahk_class #32770  ; create annotations
      Send {Enter}
    } else if (WinActive("ahk_class AcrobatSDIWindow")) {
      Send {AppsKey}h
      Sleep 100
    }
  }
  Vim.SM.CloseMsgDialog()
  WinActivate, ahk_class TElWind  ; focus to element window

ExtractToSM:
ExtractToSMAgain:
  auiaText := Vim.SM.GetTextArray()
  RefLink := hBrowser ? Vim.SM.GetLinkFromTextArray(auiaText) : ""
  Marker := Vim.SM.GetMarkerFromTextArray(auiaText)
  if ((!Vim.SM.IsHTMLEmpty(auiaText) && !Marker)
   || (Marker && IfNotIn(Vim.SM.IsCompMarker(Marker), "read point,page mark"))) {
    if ((A_ThisLabel != "ExtractToSM")
     && (ParentElNumber := Vim.SM.GetParentElNumber(auiaText))) {
      MB := MsgBox(3,, "Go to source and try again? (press no to execute in current topic)")
      WinWaitActive, ahk_class TElWind
      if (IfIn(MB, "yes,no")) {
        if (MB = "Yes")
          Vim.SM.GoToEl(ParentElNumber)
        Vim.SM.WaitFileLoad()
        Goto ExtractToSM
      }
    }
    Vim.State.SetToolTip("Copied " . Clipboard)
    return
  }

  if (hBrowser) {
    ret := Vim.SM.AskToSearchLink(BrowserUrl, RefLink)
    if (ret == 0) {
      Vim.State.SetToolTip("Copied " . Clipboard)
      return
    } else if (ret == -1) {
      Goto ExtractToSMAgain
    }
  }

  Vim.SM.EditFirstQuestion()
  if (Marker)
    Vim.SM.EmptyHTMLComp()
  WinWaitActive, ahk_class TElWind
  Send ^{Home}
  if (!CleanHTML) {
    Send ^v
    while (DllCall("GetOpenClipboardWindow"))
      Sleep 20
  } else {
    Vim.SM.PasteHTML()
  }
  Send ^+{Home}  ; select everything
  if (Prio) {
    Send !+x
    WinWaitActive, ahk_class TPriorityDlg
    ControlSetText, TEdit5, % Prio
    Send {Enter}
  } else {
    Send !x  ; extract
  }
  Vim.SM.WaitExtractProcessing()
  Vim.SM.EmptyHTMLComp()
  WinWaitActive, ahk_class TElWind
  if (Marker) {
    Vim.SM.WaitTextFocus()
    Send ^{Home}
    Marker := RegExReplace(Marker, "^(SMVim (.*?)):", "<SPAN class=Highlight>$1</SPAN>:")
    Clip(Marker,, false, "sm")
  }
  Send ^+{f7}  ; clear read point
  Vim.SM.WaitTextExit()
  if (CtrlState) {
    Vim.SM.GoBack()
  } else {
    WinActivate % wCurr
  }
  Clipboard := ClipSaved
return

; SumatraPDF
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && !Vim.State.IsCurrentVimMode("Z") && !ControlGetFocus("A"))
+z::Vim.State.SetMode("Z")
#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && Vim.State.IsCurrentVimMode("Z") && !ControlGetFocus("A"))
+z::  ; exit and save annotations
  Send ^+s  ; save
  Send {text}q  ; close tab
  Vim.State.SetMode("Vim_Normal")
return

+q::  ; exit and discard changes
  Send {text}q
  WinWaitActive, Unsaved annotations ahk_class #32770,, 0
  if (!ErrorLevel)
    Send !d
  Vim.State.SetMode("Vim_Normal")
return

#if (Vim.State.Vim.Enabled
  && ((WinActive("ahk_class SUMATRA_PDF_FRAME") && !ControlGetFocus("A"))
   || (WinActive("ahk_exe WinDjView.exe") && (ControlGetFocus("A") != "Edit1"))))
!p::ControlFocus, Edit1, A  ; focus to page number field so you can enter a number
^!f::
  if (!Selection := Copy())
    return
  ControlSetText, Edit2, % Selection, A
  ControlFocus, Edit2, A
  Send {Enter 2}^a
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class AcrobatSDIWindow") && (v := A_TickCount - CurrTimeAcrobatPage) && (v <= 400))
!p::AcrobatPagePaste := true

#if (Vim.State.Vim.Enabled && WinActive("ahk_class AcrobatSDIWindow"))
!p::
  AcrobatPagePaste := false, CurrTimeAcrobatPage := A_TickCount
  GetAcrobatPageBtn().ControlClick()
  Sleep 100
  if (AcrobatPagePaste) {
    Send ^a
    Send % "{text}" . Clipboard
    Send {Enter}
  }
return

#if (Vim.State.Vim.Enabled
  && (WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe WinDjView.exe"))
  && (ControlGetFocus("A") == "Edit1"))
!p::
  ControlSetText, Edit1, % Clipboard, A
  Send {Enter}
return

#if (Vim.State.Vim.Enabled
  && ((pdf := WinActive("ahk_class SUMATRA_PDF_FRAME")) || WinActive("ahk_exe WinDjView.exe"))
  && (page := ControlGetText("Edit1", "A")))
^!p::Clipboard := "p" . page, Vim.State.SetToolTip("Copied p" . page)

#if (Vim.State.Vim.Enabled && WinActive("ahk_class SUMATRA_PDF_FRAME") && (ControlGetFocus("A") == "Edit2"))
^f::
  ControlSetText, Edit2, % Clipboard, A
  Send {Enter}
return

^!f::Send {Enter}^a

#if (Vim.State.Vim.Enabled && WinActive("ahk_class #32770 ahk_exe WinDjView.exe"))  ; find window
^f::
  ControlSetText, Edit1, % Clipboard, A
  Send {Enter}
return

; Sync read point / page number
#if (Vim.State.Vim.Enabled
  && (WinActive("ahk_class SUMATRA_PDF_FRAME")
   || WinActive("ahk_exe ebook-viewer.exe")
   || (WinActive("ahk_group Browser") && !Vim.Browser.IsVideoOrAudioSite() && !Vim.SM.IsOnline(, -1))
   || WinActive("ahk_exe WinDjView.exe")
   || WinActive("ahk_class AcrobatSDIWindow"))
  && WinExist("ahk_class TElWind"))
!+s::
^!s::
^+!s::
  ClipSaved := ClipboardAll
  CloseWnd := IfContains(A_ThisLabel, "^")
  hBrowser := WinActive("ahk_group Browser")
  KeyWait Ctrl
  KeyWait Alt
  KeyWait Shift
  if ((hSumatra := WinActive("ahk_class SUMATRA_PDF_FRAME")) && IfContains(ControlGetFocus(), "Edit"))
    Send {Esc}
  if (hSumatra && (A_ThisLabel == "!+s"))
    Send ^+s
  PageNumber := ""
  ReadPoint := RegExReplace(Trim(Copy(false), " `t`r`n"), "s)\r\n.*")

  if (hBrowser && (!BrowserUrl := Vim.Browser.ParseUrl(RetrieveUrlFromClip())))
    BrowserUrl := Vim.Browser.GetUrl()

  if (hSumatra || (hDJVU := WinActive("ahk_exe WinDjView.exe")) || WinActive("ahk_class AcrobatSDIWindow")) {
    if (!ReadPoint) {
      if (hAcrobat := WinActive("ahk_class AcrobatSDIWindow")) {
        PageNumber := GetAcrobatPageBtn().Value
      } else {
        PageNumber := ControlGetText("Edit1", "A")
      }
      if (!PageNumber) {
        Vim.State.SetToolTip("No text selected and page number not found.")
        Goto RestoreClipReturn
      }
    }
    if (CloseWnd) {
      if (hSumatra) {
        Send {text}q
        WinWait, Unsaved annotations,, 0
        if (!ErrorLevel)
          ControlClick, Button1,,,,, NA
      } else if (hDJVU) {
        Send ^w
        WinWaitTitle("WinDjView", "A", 1500)
        WinClose, % "ahk_id " . hDJVU
      } else if (hAcrobat) {
        Send {Ctrl Down}sw{Ctrl Up}
        WinWaitTitle("Adobe Acrobat Pro DC (32-bit)", "A", 1500)
        WinClose, % "ahk_id " . hAcrobat
      }
    }

  } else {
    if (!ReadPoint) {
      if (hBrowser)
        Goto BrowserSyncTime
      Vim.State.SetToolTip("No text selected.")
      Goto RestoreClipReturn
    }
    if (CloseWnd) {
      if (hBrowser) {
        Send ^w
      } else {
        WinClose, A
      }
    }
  }

  Vim.SM.CloseMsgDialog()
  WinActivate, ahk_class TElWind

MarkInHTMLComp:
MarkInHTMLCompAgain:
  Vim.SM.EditFirstQuestion()
  auiaText := Vim.SM.GetTextArray()
  RefLink := hBrowser ? Vim.SM.GetLinkFromTextArray(auiaText) : ""
  OldText := Vim.SM.GetMarkerFromTextArray(auiaText)
  if (ReadPoint) {
    NewText := "<SPAN class=Highlight>SMVim read point</SPAN>: " . ReadPoint
  } else if (PageNumber) {
    NewText := "<SPAN class=Highlight>SMVim page mark</SPAN>: " . PageNumber
  }

  if ((!Vim.SM.IsHTMLEmpty(auiaText) && !OldText)
   || (OldText && IfNotIn(Vim.SM.IsCompMarker(OldText),"read point,page mark"))) {
    if ((A_ThisLabel != "MarkInHTMLComp")
     && (ParentElNumber := Vim.SM.GetParentElNumber(auiaText))) {
      MB := MsgBox(3,, "Go to source and try again? (press no to execute in current topic)")
      WinWaitActive, ahk_class TElWind
      if (IfIn(MB, "yes,no")) {
        if (MB = "Yes")
          Vim.SM.GoToEl(ParentElNumber)
        Vim.SM.WaitFileLoad()
        Goto MarkInHTMLComp
      }
    }
    Vim.State.SetToolTip("Copied " . Clipboard := NewText)
    return
  }

  if (hBrowser) {
    ret := Vim.SM.AskToSearchLink(BrowserUrl, RefLink)
    if (ret == 0) {
      Vim.State.SetToolTip("Copied " . Clipboard := NewText)
      return
    } else if (ret == -1) {
      Goto MarkInHTMLCompAgain
    }
  }

  if (OldText == RegExReplace(NewText, "<.*?>")) {
    Send {Esc}
    Goto RestoreClipReturn
  }

  if (OldText)
    Vim.SM.EmptyHTMLComp()
  WinWaitActive, ahk_class TElWind
  Vim.SM.WaitTextFocus()
  Send ^{Home}
  Clip(NewText,, false, "sm")
  Send {Esc}
  if (IfContains(A_ThisLabel, "^+!"))
    Vim.SM.Learn(false,, true)
  Clipboard := ClipSaved
return

; IE
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe"))
; Open in default browser (in my case, Chrome); similar to default shortcut ^+e to open in ms edge
^+c::ShellRun(ControlGetText("Edit1", "A"))  ; browser url field
^+e::ShellRun("msedge.exe", ControlGetText("Edit1", "A"))
^!l::Vim.State.SetToolTip("Copied " . Clipboard := ControlGetText("Edit1", "A"))
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe msedge.exe"))
^+c::
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  ShellRun(uiaBrowser.GetCurrentUrl())
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class wxWindowNR") && WinExist("ahk_class TElWind"))  ; audacity.exe
^!x::
!x::
  if (A_ThisLabel == "^!x") {
    KeyWait Ctrl
    KeyWait Alt
    Send ^a
    PostMessage, 0x0111, 17216,,, A  ; truncate silence
    WinWaitActive, Truncate Silence
    ; Settings for truncate complete silence
    ControlSetText, Edit1, -80
    ControlSetText, Edit2, 0.001
    ControlSetText, Edit3, 0
    Send {Enter}
    WinWaitNotActive, Truncate Silence
    WinWaitActive, ahk_class wxWindowNR  ; audacity main window
    Send ^+e  ; save
    WinWaitActive, Export Audio
  } else if (A_ThisLabel == "!x") {
    PostMessage, 0x0111, 17011,,, A  ; export selected audio
    WinWaitActive, Export Selected Audio
  }
  FileName := RegExReplace(Vim.Browser.Title . GetTimeMSec(), "[^a-zA-Z0-9\\.\\-]", "_")
  TempPath := A_Temp . "\" . FileName . ".mp3"
  Control, Choose, 3, ComboBox3  ; choose mp3 from file type
  ControlSetText, Edit1, % TempPath
  Send {Enter}
  WinWaitActive, Warning,, 0
  if (!ErrorLevel) {
    Send {Enter}
    WinWaitClose
  }
  Send ^a{BS}
  Vim.SM.CloseMsgDialog()
  WinActivate, ahk_class TElWind
  Vim.SM.AltA()
  Vim.SM.WaitFileLoad()
  QuestionFieldName := ControlGetFocus("A")
  if (Vim.Browser.Title) {
    Send % "{text}" . Vim.SM.MakeReference()
  } else {
    Send {text}Listening comprehension:
  }
  Vim.SM.InvokeFileBrowser()
  Vim.SM.FileBrowserSetPath(TempPath, true)
  WinWaitActive, ahk_class TInputDlg
  if (Vim.Browser.Title) {
    ControlSetText, TMemo1, % Vim.Browser.Title . " (excerpt)", A
  } else {
    ControlSetText, TMemo1, listening comprehension_, A
  }
  Send {Enter}
  WinWaitActive, ahk_class TMsgDialog
  Send {text}n
  WinWaitClose
  WinWaitActive, ahk_class TMsgDialog
  Send {text}y  ; delete temp file
  WinWaitClose
  if (Vim.Browser.Title)
    Vim.SM.SetTitle(Vim.Browser.Title)
  CurrFocus := ControlGetFocus("ahk_class TElWind")
  WinActivate, ahk_class TElWind
  Vim.SM.PrevComp()
  ControlWaitNotFocus(CurrFocus, "ahk_class TElWind")
  Send +{Ins}  ; paste: text or image
  aClipFormat := WinClip.GetFormats()
  if (aClipFormat[aClipFormat.MinIndex()].name == "CF_DIB") {  ; image
    WinWaitActive, ahk_class TMsgDialog
    Send {Enter}
    WinWaitClose
    Send {Enter}
  }
  Vim.SM.Reload()
  Vim.SM.WaitFileLoad()
  Vim.SM.EditFirstAnswer()
  Vim.Browser.Clear()
Return

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe ebook-viewer.exe"))
~^f::
  Clipboard := Trim(Clipboard)
  if ((A_PriorHotkey != "~^f") || (A_TimeSincePriorHotkey > 400)) {
    KeyWait f
    return
  }
  Send ^v
  WinClip._waitClipReady()
  Send {Enter 2}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe HiborClient.exe"))
!+d::  ; check duplicates
  ClipSaved := ClipboardAll
  if (CopyAll())
    Vim.SM.CheckDup(MatchHiborLink(Clipboard))
  Clipboard := ClipSaved
return

#if (Vim.State.Vim.Enabled && (hWnd := WinActive("ahk_exe HiborClient.exe")) && WinExist("ahk_class TElWind"))
^+!a::
^!a::  ; import
  ClipSaved := ClipboardAll
  if (!CopyAll())
    Goto RestoreClipReturn
  Link := MatchHiborLink(Clipboard)
  Title := MatchHiborTitle(Clipboard)
  RegExMatch(Title, "^.*?(?=-)", Source)
  Title := StrReplace(Title, Source . "-",,, 1)
  RegExMatch(Title, "\d{6}$", Date)
  Title := StrReplace(Title, "-" . Date,,, 1)
  MB := ""
  if (Vim.SM.CheckDup(Link, false))
    MB := MsgBox(3,, "Continue import?")
  WinActivate % "ahk_id " . hWnd
  WinClose, ahk_class TBrowser
  if (IfIn(MB, "No,Cancel"))
    Goto HBImportReturn
  Prio := IfContains(A_ThisLabel, "+") ? Vim.SM.AskPrio(false) : ""
  Clipboard := "#SuperMemo Reference:"
             . "`n#Title: " . Title
             . "`n#Source: " . Source
             . "`n#Date: " . Date
             . "`n#Link: " . Link
  WinActivate, ahk_class TElWind
  Vim.SM.CtrlN()
  Vim.SM.SetElParam(Title, Prio)

HBImportReturn:
  Vim.SM.ClearHighlight()
  WinWaitNotActive, ahk_class TElWind,, 0.1
  Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
  Clipboard := ClipSaved
return

MatchHiborTitle(Text) {
  RegExMatch(Text, "s)意见反馈\r\n(研究报告：)?\K.*?(?=\r\n)", v)
  return v
}

MatchHiborLink(Text) {
  RegExMatch(Text, "s)推荐给朋友:\r\n\K.*?(?=  )", v)
  return v
}

#if (Vim.State.Vim.Enabled && (hWnd := WinActive("ahk_exe Clash for Windows.exe")))
!t::  ; test latency
  UIA := UIA_Interface(), el := UIA.ElementFromHandle(hWnd)
  if (btn := el.FindFirstBy("ControlType=Text AND Name='Update All'")) {
    btn.Click()
  } else {
    aBtn := el.FindAllBy("ControlType=Text AND Name='network_check'")
    for i, v in aBtn
      v.ControlClick()
  }
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_class mpv") && !Vim.State.IsCurrentVimMode("Z"))
+z::Vim.State.SetMode("Z")
#if (Vim.State.Vim.Enabled && WinActive("ahk_class mpv") && Vim.State.IsCurrentVimMode("Z"))
+z::
  Send +q
  Vim.State.SetMode("Vim_Normal")
return

+q::
  Send q
  Vim.State.SetMode("Vim_Normal")
return
