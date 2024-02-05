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

#f::ShellRun("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Everything 1.5a.lnk")
^#h::send ^#{left}
^#l::send ^#{right}
+#h::send +#{left}
+#l::send +#{right}

^+!p::
Plan:
  Vim.State.SetMode("Vim_Normal")
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
^!w::
  KeyWait Ctrl
  KeyWait Alt
  BrowserTitle := WinGetTitle("A")
  send ^w
  WinWaitTitleChange(BrowserTitle, "A", 200)
  send !{tab}  ; close tab and switch back
return

^!i::  ; open in *I*E
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  Vim.Browser.RunInIE(Vim.Browser.ParseUrl(uiaBrowser.GetCurrentURL()))
  ; ShellRun("iexplore.exe " . Vim.Browser.ParseUrl(GetActiveBrowserURL()))  ; RIP old method
Return

^!t::  ; copy title
  Vim.Browser.GetTitleSourceDate(false, false,,, false, false)
  ToolTip("Copied " . Clipboard := Vim.Browser.Title), Vim.Browser.Clear()
return

^!l::  ; copy link and parse *l*ink
  Vim.Browser.Clear()
  ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{esc}, A
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
    Goto RestoreClipReturn
  }
  TempClip := Clipboard, ClipboardGet_HTML(HTML)
  RegExMatch(HTML, "SourceURL:(.*)", v), url := v1
  if (IfContains(url, "larousse.fr")) {
    TempClip := Vim.SM.CleanHTML(HTML, true)
    RegExMatch(TempClip, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", TempClip)
    TempClip := RegExReplace(TempClip, "is)<\/?(mark|span)( .*?)?>")
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
  } else if (IfContains(url, "en.wiktionary.org/w")) {
    TempClip := RegExReplace(TempClip, "Synonyms?:", "syn:")
    TempClip := RegExReplace(TempClip, "Antonyms?:", "ant:")
  } else if (IfContains(url, "collinsdictionary.com")) {
    TempClip := StrReplace(TempClip, " `r`n", ", ")
    TempClip := StrReplace(TempClip, "Synonyms`r`n", "syn: ")
  } else if (IfContains(url, "thesaurus.com")) {
    TempClip := StrReplace(TempClip, "`r`n", ", ")
    TempClip := RegExReplace(TempClip, "SYNONYMS FOR, .*?, , ", "syn: ")
  }
  ToolTip("Copied:`n" . Clipboard := TempClip)
return

^!c::  ; copy and register references
  Vim.Browser.Clear(), WinClip.Snap(data)
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
  ClipSaved := ClipboardAll
  if (!Clipboard := Vim.Browser.GetVidtime(,, false)) {
    ToolTip("Not found.")
    Goto RestoreClipReturn
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
^+!b::
IWBPriorityAndConcept:
IWBNewTopic:
; Import current webpage to SuperMemo
; Incremental video: Import current YT video to SM
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

  CurrTitle := Vim.Browser.GetFullTitle("A")
  if (!CurrTitle || (CurrTitle = "new tab")) {
    ToolTip("Web page not found.")
    return
  }

  ClipSaved := ClipboardAll
  if (IWB := IfContains(A_ThisLabel, "IWB,^+!b")) {
    if (!HTMLText := Copy(false, true)) {
      ToolTip("Text not found.")
      Goto RestoreClipReturn
    }
  }

  Vim.Browser.Clear()
  if (IWB) {
    Vim.Browser.Url := Vim.Browser.ParseUrl(RetrieveUrlFromClip())
  } else {
    Vim.Browser.Url := Vim.Browser.GetParsedUrl()
  }
  if (!Vim.Browser.Url) {
    ToolTip("Url not found.")
    Goto RestoreClipReturn
  }

  ClickBrowserBtnFinished := false
  SetTimer, ClickBrowserBtn, -1
  wBrowser := "ahk_id " . WinActive("A")
  Vim.SM.CloseMsgWind()
  CollName := Vim.SM.GetCollName(), ConceptBefore := Vim.SM.GetCurrConcept()
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

  Prio := Concept := CloseTab := DLHTML := ResetVidTime := CheckDupForIWB := Tags := RefComment := ClipBeforeGui := UseOnlineProgress := OnlineEl := ""
  IsVidSite := Vim.Browser.IsVidSite()
  while (!ClickBrowserBtnFinished)
    Continue
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
    if (!IWB && !IsVidSite) {
      Gui, SMImport:Add, Checkbox, % "vOnlineEl " . check, Import as o&nline element
      DLList := "economist.com,investopedia.com,webmd.com,britannica.com"
      check := IfContains(Vim.Browser.Url, DLList) ? "checked" : ""
      Gui, SMImport:Add, Checkbox, % "vDLHTML " . check, Import fullpage &HTML
    }
    if (IWB)
      Gui, SMImport:Add, Checkbox, vCheckDupForIWB, Check &duplication
    if (IsVidSite) {
      Gui, SMImport:Add, Checkbox, vResetVidTime, &Reset time stamp
      if (IfContains(Vim.Browser.Url, "youtube.com/watch")) {
        check := (CollName = "bgm") ? "checked" : ""
        Gui, SMImport:Add, Checkbox, % "vUseOnlineProgress " . check, &Mark as use online progress
      }
    }
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
    Gui, Destroy
  }

  if (OnlineEl != 1)
    OnlineEl := Vim.SM.IsOnline(CollName, Concept)
  if (OnlineEl)  ; just in case user checks both of them
    DLHTML := false
  if (OnlineEl && IWB) {
    ret := true
    if (MsgBox(3,, "You chosed an online concept. Choose again?") = "yes") {
      Concept := InputBox("New Concept", "Enter a new concept.")
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

  CopyAll := (!HTMLText && !OnlineEl)
  if (DLHTML) {
    if (IfContains(Vim.Browser.Url, "file:///")) {
      Vim.Browser.Url := StrReplace(Vim.Browser.Url, "file:///")
      HTMLText := FileRead(EncodeDecodeURI(Vim.Browser.Url, false))
    } else {
      ToolTip("Attempting to download website...", true,,, 19)
      TempPath := A_Temp . "\" . GetCurrTimeForFileName() . ".htm"
      UrlDownloadToFile, % Vim.Browser.Url, % TempPath
      if (ErrorLevel) {
        ToolTip("Download failed.",,,, 18), CopyAll := true
      } else {
        HTMLText := FileReadAndDelete(TempPath)
        ; Fixing links
        RegExMatch(Vim.Browser.Url, "^https?:\/\/.*?\/", UrlHead)
        RegExMatch(Vim.Browser.Url, "^https?:\/\/", HTTP)
        HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K (href|src)=""\/\/(?=([^<>]+)?>)", " $2=""" . HTTP)
        HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K (href|src)=""\/(?=([^<>]+)?>)", " $2=""" . UrlHead)
        HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K (href|src)=""(?=#([^<>]+)?>)", " $2=""" . Vim.Browser.Url)
      }
      RemoveToolTip(19)
    }
  }

  if (CopyAll) {
    send {esc}
    CopyAll()
    ClipboardGet_HTML(HTMLText)
    RegExMatch(HTMLText, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", HTMLText)
  }
  if (!OnlineEl && !HTMLText) {
    ToolTip("Text not found.")
    Goto SMImportReturn
  }

  SkipDate := (OnlineEl && !IsVidSite)
  Vim.Browser.GetTitleSourceDate(false,, (CopyAll ? Clipboard : ""),, !SkipDate, !ResetVidTime)

  if (ResetVidTime)
    Vim.Browser.VidTime := "0:00"
  if (SkipDate)
    Vim.Browser.Date := ""

  SMPoundSymbHandled := Vim.SM.PoundSymbLinkToComment()
  if (Tags) {
    TagsComment := StrReplace(Trim(Tags), " ", "_")
    TagsComment := "#" . StrReplace(TagsComment, ";", " #")
    if (RefComment)
      TagsComment := " " . TagsComment 
    Vim.Browser.Comment := Trim(RefComment) . TagsComment . " " . Vim.Browser.Comment
  }

  SMCtrlNYT := (!OnlineEl && (IsVidSite = "yt"))
  if (OnlineEl) {
    add := ""
    if (Vim.Browser.VidTime && !IfIn(IsVidSite, "yt,1,2")) {
      add := "<SPAN class=Highlight>SMVim time stamp</SPAN>: " . Vim.Browser.VidTime
    } else if (UseOnlineProgress) {
      add := "<SPAN class=Highlight>SMVim: Use online video progress</SPAN>"
    }
    SetClipboardHTML(add . Vim.SM.MakeReference(true))
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
  if (Vim.Browser.VidTime)
    InfoToolTip .= "`nTime stamp: " . Vim.Browser.VidTime
  if (Vim.Browser.Comment)
    InfoToolTip .= "`nComment: " . Vim.Browser.Comment
  ToolTip(InfoToolTip, true,,, 17)

  if (Prio ~= "^\.")
    Prio := "0" . Prio
  Vim.SM.CloseMsgWind()

  ChangeBackConcept := ""
  if (Concept) {
    if (Skip := ((OnlineEl == 1) && !Vim.SM.IsOnline(-1, Concept))) {
      ChangeBackConcept := Concept
      Concept := "online"
    }
    if (Vim.SM.SetCurrConcept(Concept, ConceptBefore))
      WinWaitClose
    if (!Skip && (InStr(Vim.SM.GetCurrConcept(), Concept) != 1)) {
      WinActivate, ahk_class TElWind
      MB := MsgBox(3,, "Current concept doesn't seem like your entered concept. Continue?")
      if (IfIn(MB, "No,Cancel"))
        Goto SMImportReturn
    }
  }

  WinActivate, ahk_class TElWind
  if (SMCtrlNYT) {
    Gosub SMCtrlN
  } else {
    PrevSMTitle := WinGetTitle("ahk_class TElWind")
    Vim.SM.AltN()
    SMNewElementTitle := WinWaitTitleChange(PrevSMTitle, "ahk_class TElWind")
    if (!OnlineEl) {
      Vim.SM.PasteHTML()
      Vim.SM.ExitText()
      WinWaitTitleChange(SMNewElementTitle, "A")
    } else if (OnlineEl) {
      send {Ctrl Down}vt{Ctrl Up}{f9}{enter}  ; open script editor
      WinWaitActive, ahk_class TScriptEditor,, 3
      if (ErrorLevel) {
        ToolTip("Script component not found.")
        Goto SMImportReturn
      }
      Script := "url " . Vim.Browser.Url
      if (Vim.Browser.VidTime && IfIn(IsVidSite, "yt,1,2")) {
        Sec := Vim.Browser.GetSecFromTime(Vim.Browser.VidTime)
        if (IfContains(Vim.Browser.Url, "youtube.com")) {
          Script .= "&t=" . Sec . "s"
        } else if (IfContains(Vim.Browser.Url, "bilibili.com")) {
          Script .= (Script ~= "\?p=\d+") ? "&t=" . Sec : "?t=" . Sec
        }
      }
      ControlSetText, TMemo1, % Script
      send !o{esc 2}  ; close script editor
      WinWaitClose
      WinWaitActive, ahk_class TElWind
    }
  }
  SMNewTextTitle := WinGetTitle("ahk_class TElWind")

  ; Making sure the browser is shown for the maximum amount of time
  if (OnlineEl)
    WinActivate % wBrowser

  if (DupChecked)
    Vim.SM.ClearHighlight()

  if (OnlineEl)
    WinActivate % wBrowser

  if (!SMPoundSymbHandled)
    Vim.SM.HandleSM19PoundSymbUrl(Vim.Browser.Url)
  Vim.SM.Reload(, true)

  if (OnlineEl)
    WinActivate % wBrowser

  Vim.SM.WaitFileLoad()

  if (OnlineEl)
    WinActivate % wBrowser

  WinWaitTitle(SMNewTextTitle, "ahk_class TElWind")
  Vim.SM.SetElParam(IWB ? "" : Vim.Browser.Title, Prio, (SMCtrlNYT ? "YouTube" : ""), ChangeBackConcept ? ChangeBackConcept : "")
  if (ChangeBackConcept)
    Vim.SM.SetCurrConcept(ChangeBackConcept)

  if (Tags)
    Vim.SM.LinkConcepts(StrSplit(Tags, ";"))

  if (OnlineEl)
    WinActivate % wBrowser

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
    WinWaitNotActive, % wBrowser,, 0.1
    Vim.Caret.SwitchToSameWindow(wBrowser)
    if (!Esc)
      send {esc 2}
  } else if (IfIn(A_ThisLabel, "SMImportButtonImport,^!a")) {
    WinWaitNotActive, ahk_class TElWind,, 0.1
    Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
  }
  Vim.Browser.Clear(), Vim.State.SetMode("Vim_Normal")
  RemoveToolTip(17)  ; remove import info tooltip
  ; If closed gui but did not copy anything, restore clipboard
  ; If closed gui but copied something while the gui is open, do not restore clipboard
  if (!EscGui || (Clipboard == ClipBeforeGui))
    Clipboard := ClipSaved
  if (!Esc)
    ToolTip("Import completed.")
  HTMLText := ""
return

^+e::
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  ShellRun("msedge.exe " . uiaBrowser.GetCurrentUrl())
return

#if (Vim.State.Vim.Enabled && ((widBrowser := WinActive("ahk_group Browser")) ; browser group (Chrome, Edge, Firefox)
                            || WinActive("ahk_exe ebook-viewer.exe")        ; Calibre (an epub viewer)
                            || WinActive("ahk_class SUMATRA_PDF_FRAME")     ; SumatraPDF
                            || WinActive("ahk_class AcrobatSDIWindow")      ; Acrobat
                            || WinActive("ahk_exe WINWORD.exe")             ; MS Word
                            || WinActive("ahk_exe WinDjView.exe")))         ; djvu viewer
!+d::  ; check duplicates in SM
  if (!WinExist("ahk_class TElWind")) {
    ToolTip("Please open SuperMemo and try again.")
    return
  }
  ToolTip := "selected text", skip := false, url := ""
  if (widBrowser) {
    uiaBrowser := new UIA_Browser("ahk_id " . widBrowser)
    if (IfContains(url := uiaBrowser.GetCurrentUrl(), "youtube.com/watch,netflix.com/watch"))
      text := Vim.Browser.ParseUrl(url), skip := true, ToolTip := "url"
  }
  if (!skip && (!text := Copy())) {
    if (widBrowser) {
      if (!url) {
        ToolTip("Url not found.")
        return
      }
      text := Vim.Browser.ParseUrl(url), ToolTip := "url"
    }
  }
  if (!text) {
    ToolTip("Text not found.")
    return
  }
  ToolTip("Searching " . ToolTip . " in " . Vim.SM.GetCollName() . "...", true)
  if (Vim.SM.CheckDup(text))
    RemoveToolTip()
  VimLastSearch := text
return

; Browser / SumatraPDF / Calibre / MS Word to SuperMemo
^+!x::
^!x::
!+x::
!x::
  CtrlState := IfContains(A_ThisLabel, "^"), hWnd := WinActive("A")
  ClipSaved := ClipboardAll
  widBrowser := WinActive("ahk_group Browser")
  KeyWait Alt
  KeyWait Ctrl
  if (!Copy(false)) {
    ToolTip("Nothing is selected.")
    Goto RestoreClipReturn
  } else {
    if (CleanHTML := (widBrowser || WinActive("ahk_exe ebook-viewer.exe"))) {
      if (widBrowser)
        PlainText := Clipboard
      ClipboardGet_HTML(data)
      if (widBrowser) {
        RegExMatch(data, "SourceURL:(.*)", v)
        BrowserUrl := Vim.Browser.ParseUrl(v1)
      }
      RegExMatch(data, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", data)
      Clipboard := Vim.SM.CleanHTML(data)
    }
    if (!WinExist("ahk_group SM")) {
      a := CleanHTML ? "(in HTML)" : ""
      ToolTip("SuperMemo is not open; the text you selected " . a . " is on your clipboard.")
      return
    }
    if (Prio := IfContains(A_ThisLabel, "+")) {
      if ((!Prio := InputBox("Priority", "Enter extract priority.")) || ErrorLevel)
        return
      if (Prio ~= "^\.")
        Prio := "0" . Prio
    }
    WinActivate, % "ahk_id " . hWnd
    if (widBrowser) {
      Vim.Browser.Highlight(, PlainText, BrowserUrl)
    } else if (WinActive("ahk_exe ebook-viewer.exe")) {
      ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}q  ; need to enable this shortcut in settings
    } else if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
      ; ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}a
      send a
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
ExtractToSMAgain:
  auiaText := Vim.SM.GetHTMLAllText()
  RefLink := widBrowser ? Vim.SM.GetLinkFromHTMLAllText(auiaText) : ""
  Marker := Vim.SM.GetMarkerFromHTMLAllText(auiaText)
  if ((!Vim.SM.IsHTMLEmpty(auiaText) && !Marker)
   || (Marker && IfNotIn(Vim.SM.IsCompMarker(Marker), "read point,page number"))) {
    ret := true
    if (A_ThisLabel != "ExtractToSM") {
      MB := MsgBox(3,, "Go to source and try again? (press no to execute in current topic)")
      if (MB = "yes") {
        WinWaitActive, ahk_class TElWind
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        Goto ExtractToSM
      } else if (MB = "no") {
        WinWaitActive, ahk_class TElWind
        ret := false
      }
    }
    if (ret) {
      ToolTip("Copied " . Clipboard)
      return
    }
  }

  if (widBrowser && !Vim.SM.MatchLink(RefLink, BrowserUrl)) {
    if (Vim.SM.AskToSearchLinkOrStop(BrowserUrl, RefLink)) {
      ToolTip("Copied " . Clipboard)
      return
    }
    Goto ExtractToSMAgain
  }

  Vim.SM.EditFirstQuestion()
  if (Marker)
    Vim.SM.EmptyHTMLComp()
  WinWaitActive, ahk_class TElWind
  send ^{home}
  if (!CleanHTML) {
    send ^v
    while (DllCall("GetOpenClipboardWindow"))
      sleep 1
  } else {
    Vim.SM.PasteHTML()
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
  Vim.SM.EmptyHTMLComp()
  WinWaitActive, ahk_class TElWind
  if (Marker) {
    send ^{home}
    Marker := RegExReplace(Marker, "^(SMVim (.*?)):", "<SPAN class=Highlight>$1</SPAN>:")
    Clip(Marker,, false, "sm")
  }
  send ^+{f7}  ; clear read point
  Vim.SM.WaitTextExit()
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
  send ^+s  ; save
  send q  ; close tab
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
!p::AcrobatPagePaste := true

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

; Sync read point / page number
#if (Vim.State.Vim.Enabled
  && (WinActive("ahk_class SUMATRA_PDF_FRAME")
   || WinActive("ahk_exe ebook-viewer.exe")
   || (WinActive("ahk_group Browser") && !Vim.Browser.IsVidSite() && !Vim.SM.IsOnline(, -1))
   || WinActive("ahk_exe WinDjView.exe")
   || WinActive("ahk_class AcrobatSDIWindow"))
  && WinExist("ahk_class TElWind"))
!+s::
^!s::
^+!s::
  ClipSaved := ClipboardAll
  CloseWnd := IfContains(A_ThisLabel, "^")
  wBrowser := WinActive("ahk_group Browser")
  KeyWait Ctrl
  KeyWait Alt
  KeyWait Shift
  if ((wSumatra := WinActive("ahk_class SUMATRA_PDF_FRAME")) && IfContains(ControlGetFocus(), "Edit"))
    send {esc}
  if (wSumatra && (A_ThisLabel == "!+s"))
    send ^+s
  PageNumber := ""
  ReadPoint := RegExReplace(Trim(Copy(false), " `t`r`n"), "s)\r\n.*")
  if (wBrowser) {
    Critical
    if (BrowserUrl := RetrieveUrlFromClip()) {
      BrowserUrl := Vim.Browser.ParseUrl(BrowserUrl)
    } else {
      BrowserUrl := Vim.Browser.GetParsedUrl()
    }
    BrowserUrl := Vim.SM.HTMLUrl2SMRefUrl(BrowserUrl)
  }
  if (wSumatra || (wDJVU := WinActive("ahk_exe WinDjView.exe")) || WinActive("ahk_class AcrobatSDIWindow")) {
    if (!ReadPoint) {
      if (wAcrobat := WinActive("ahk_class AcrobatSDIWindow")) {
        PageNumber := GetAcrobatPageBtn().Value
      } else {
        PageNumber := ControlGetText("Edit1", "A")
      }
      if (!PageNumber) {
        ToolTip("No text selected and page number not found.")
        Goto RestoreClipReturn
      }
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
    if (!ReadPoint) {
      if (wBrowser)
        Goto BrowserSyncTime
      ToolTip("No text selected.")
      Goto RestoreClipReturn
    }
    if (CloseWnd) {
      if (wBrowser) {
        send ^w
      } else {  ; epub viewer
        WinClose, A
      }
    }
  }
  Vim.SM.CloseMsgWind()
  WinActivate, ahk_class TElWind

MarkInHTMLComp:
MarkInHTMLCompAgain:
  Vim.SM.EditFirstQuestion()
  auiaText := Vim.SM.GetHTMLAllText()
  RefLink := wBrowser ? Vim.SM.GetLinkFromHTMLAllText(auiaText) : ""
  OldText := Vim.SM.GetMarkerFromHTMLAllText(auiaText)
  if (ReadPoint) {
    NewText := "<SPAN class=Highlight>SMVim read point</SPAN>: " . ReadPoint
  } else if (PageNumber) {
    NewText := "<SPAN class=Highlight>SMVim page number</SPAN>: " . PageNumber
  }

  if ((!Vim.SM.IsHTMLEmpty(auiaText) && !OldText)
   || (OldText && IfNotIn(Vim.SM.IsCompMarker(OldText),"read point,page number"))) {
    ret := true
    if (A_ThisLabel != "MarkInHTMLComp") {
      MB := MsgBox(3,, "Go to source and try again? (press no to execute in current topic)")
      if (MB = "yes") {
        WinWaitActive, ahk_class TElWind
        Vim.SM.ClickElWindSourceBtn()
        Vim.SM.WaitFileLoad()
        Goto MarkInHTMLComp
      } else if (MB = "no") {
        WinWaitActive, ahk_class TElWind
        ret := false
      }
    }
    if (ret) {
      ToolTip("Copied " . Clipboard := NewText)
      return
    }
  }
  if (OldText == RegExReplace(NewText, "<.*?>")) {
    send {esc}
    Goto RestoreClipReturn
  }

  if (wBrowser && !Vim.SM.MatchLink(RefLink, BrowserUrl)) {
    if (Vim.SM.AskToSearchLinkOrStop(BrowserUrl, RefLink)) {
      ToolTip("Copied " . Clipboard := NewText)
      return
    }
    Goto MarkInHTMLCompAgain
  }

  if (OldText)
    Vim.SM.EmptyHTMLComp()
  WinWaitActive, ahk_class TElWind
  send ^{home}
  Clip(NewText,, false, "sm")
  send {esc}
  if (IfContains(A_ThisLabel, "^+!"))
    Vim.SM.Learn(false, true)
  Clipboard := ClipSaved
return

; IE
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe"))
; Open in default browser (in my case, Chrome); similar to default shortcut ^+e to open in ms edge
^+c::ShellRun(ControlGetText("Edit1", "A"))  ; browser url field
^+e::ShellRun("msedge.exe", ControlGetText("Edit1", "A"))
^!l::ToolTip("Copied " . Clipboard := ControlGetText("Edit1", "A"))
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
  } else if (A_ThisLabel == "!x") {
    PostMessage, 0x0111, 17011,,, A  ; export selected audio
    WinWaitActive, Export Selected Audio
  }
  FileName := RegExReplace(Vim.Browser.Title . GetTimeMSec(), "[^a-zA-Z0-9\\.\\-]", "_")
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
  Clipboard := Trim(Clipboard)
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
return

#if (Vim.State.Vim.Enabled && (hWnd := WinActive("ahk_exe HiborClient.exe")) && WinExist("ahk_class TElWind"))
^+!a::
^!a::  ; import
  ClipSaved := ClipboardAll
  if (!CopyAll())
    Goto RestoreClipReturn
  link := MatchHiborLink(Clipboard)
  title := MatchHiborTitle(Clipboard)
  RegExMatch(title, "^.*?(?=-)", source)
  title := StrReplace(title, source . "-",,, 1)
  RegExMatch(title, "\d{6}$", date)
  title := StrReplace(title, "-" . date,,, 1)
  MB := ""
  if (Vim.SM.CheckDup(link, false))
    MB := MsgBox(3,, "Continue import?")
  WinActivate % "ahk_id " . hWnd
  WinClose, ahk_class TBrowser
  if (IfIn(MB, "No,Cancel"))
    Goto HBImportReturn
  if (IfContains(A_ThisLabel, "+")) {
    Prio := InputBox("Priority", "Enter extract priority.")
    if (!(Prio >= 0) || ErrorLevel) {
      prio := ""
    } else if (Prio ~= "^\.") {
      Prio := "0" . Prio
    }
  }
  Clipboard := "#SuperMemo Reference:"
             . "`n#Title: " . title
             . "`n#Source: " . source
             . "`n#Date: " . date
             . "`n#Link: " . link
  WinActivate, ahk_class TElWind
  Vim.SM.CtrlN()
  Vim.SM.Reload()
  Vim.SM.SetElParam(title, prio)

HBImportReturn:
  Vim.SM.ClearHighlight()
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
  if (btn := el.FindFirstBy("ControlType=Text AND Name='Update All'")) {
    btn.Click()
  } else {
    aBtn := el.FindAllBy("ControlType=Text AND Name='network_check'")
    for i, v in aBtn
      v.ControlClick()
  }
return
