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
    if (!SM.Plan())
      return
    WinWait, Information ahk_class TMsgDialog,, 1.5
    if (!ErrorLevel)
      WinClose
    WinActivate, ahk_class TPlanDlg
    return
  }
  SM.CloseMsgDialog()
  if (!WinExist("ahk_class TPlanDlg")) {
    l := SM.IsLearning()
    if (l == 2) {
      SM.Reload()
    } else if (l == 1) {
      SM.GoHome()
    }
    if (!SM.Plan())
      return
    WinWait, ahk_class TPlanDlg,, 0
    if (ErrorLevel)
      return
  }
  WinActivate, ahk_class TPlanDlg
  SM.CloseMsgDialog()
  Send {Right}{Left}
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
  uiaBrowser := new UIA_Browser("A")
  Browser.RunInIE(Browser.ParseUrl(uiaBrowser.GetCurrentURL()))
  ; ShellRun("iexplore.exe " . Browser.ParseUrl(GetActiveBrowserURL()))  ; RIP old method
Return

^!t::  ; copy *t*itle
  Browser.GetInfo(false, false,,, false, false)
  SetToolTip("Copied " . Clipboard := Browser.Title), Browser.Clear()
return

^!l::  ; copy and parse *l*ink
  Browser.Clear()
  ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Esc}, A
  Browser.GetInfo(false)
  SetToolTip("Copied " . Browser.Url . "`n"
           . "Title: " . Browser.Title
           . (Browser.Source ? "`nSource: " . Browser.Source : "")
           . (Browser.Author ? "`nAuthor: " . Browser.Author : "")
           . (Browser.Date ? "`nDate: " . Browser.Date : "")
           . (Browser.TimeStamp ? "`nTime stamp: " . Browser.TimeStamp : ""))
  Clipboard := Browser.Url
return

^!d::  ; parse word *d*efinitions
  ClipSaved := ClipboardAll
  if (!Copy(false)) {
    SetToolTip("Text not found.")
    Clipboard := ClipSaved
    return
  }
  TempClip := Clipboard, ClipboardGet_HTML(HTML), Url := GetClipLink(HTML)
  if (IfContains(Url, "larousse.fr")) {
    TempClip := SM.CleanHTML(GetClipHTMLBody(HTML), true)
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
  SetToolTip("Copied:`n" . Clipboard := TempClip)
return

^!c::  ; copy and register references
  Browser.Clear(), WinClip.Snap(data)
  if (!Copy(false))
    SetToolTip("No text selected."), WinClip.Restore(data)
  Browser.GetInfo()
  SetToolTip("Copied " . Clipboard . "`n"
           . "Link: " . Browser.Url . "`n"
           . "Title: " . Browser.Title
           . (Browser.Source ? "`nSource: " . Browser.Source : "")
           . (Browser.Author ? "`nAuthor: " . Browser.Author : "")
           . (Browser.Date ? "`nDate: " . Browser.Date : ""))
return

^!m::  ; copy ti*m*e stamp
  ClipSaved := ClipboardAll
  if (!Clipboard := Browser.GetTimeStamp(,, false)) {
    SetToolTip("Not found.")
    Clipboard := ClipSaved
    return
  }
  SetToolTip("Copied " . Clipboard), Browser.Clear()
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
    SetToolTip("Please open SuperMemo and try again.")
    return
  }
  if (WinExist("ahk_id " . SMImportGuiHwnd)) {
    WinActivate
    return
  }

  ClipSaved := ClipboardAll
  if (IWB := IfContains(A_ThisLabel, "IWB,^+!b")) {
    if (!HTMLText := Copy(false, true)) {
      SetToolTip("Text not found.")
      Clipboard := ClipSaved
      return
    }
  }

  Browser.Clear()
  if (IWB) {
    Browser.Url := Browser.ParseUrl(RetrieveUrlFromClip())
  } else {
    Browser.Url := Browser.GetUrl()
  }
  if (!Browser.Url) {
    SetToolTip("Url not found.")
    Clipboard := ClipSaved
    return
  }

  wBrowser := "ahk_id " . WinActive("A")
  Browser.FullTitle := Browser.GetFullTitle("A")
  IsVideoOrAudioSite := Browser.IsVideoOrAudioSite(Browser.FullTitle)

  SM.CloseMsgDialog()
  CollName := SM.GetCollName()
  OnlineEl := SM.IsOnline(CollName, -1)

  DupChecked := MB := false
  if (!IWB) {
    if (SM.CheckDup(Browser.Url, false))
      MB := MsgBox(3,, "Continue import?")
    DupChecked := true
  }
  WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID", "ahk_class TElWind")
  WinActivate % wBrowser
  if (IfIn(MB, "No,Cancel"))
    Goto SMImportReturn

  Prio := Concept := CloseTab := DLHTML := ResetTimeStamp := CheckDupForIWB := ""
  Tags := RefComment := ClipBeforeGui := UseOnlineProgress := ""
  DLList := "economist.com,investopedia.com,webmd.com,britannica.com,medium.com,wired.com,greenhornfinancefootnote.blogspot.com"
  if (IfIn(A_ThisLabel, "^+!a,IWBPriorityAndConcept,^+!b")) {
    ClipBeforeGui := Clipboard
    SetDefaultKeyboard(0x0409)  ; English-US
    Gui, SMImport:Add, Text,, % "Current collection: " . CollName
    Gui, SMImport:Add, Text,, &Priority:
    Gui, SMImport:Add, Edit, vPrio w280
    Gui, SMImport:Add, Text,, Concept &group:  ; like in default import dialog
    ConceptList := "||Online|Sources|ToDo"
    if (IfIn(CurrConcept := SM.GetDefaultConcept(), "Online,Sources,ToDo"))
      ConceptList := StrReplace(ConceptList, "|" . CurrConcept)
    list := StrLower(CurrConcept . ConceptList)
    Gui, SMImport:Add, ComboBox, vConcept gAutoComplete w280, % list
    Gui, SMImport:Add, Text,, &Tags (without # and use `; to separate):
    Gui, SMImport:Add, Edit, vTags w280
    Gui, SMImport:Add, Text,, Reference c&omment:
    Gui, SMImport:Add, Edit, vRefComment w280
    Gui, SMImport:Add, Checkbox, vCloseTab, &Close tab  ; like in default import dialog
    if (!IWB && !OnlineEl)
      Gui, SMImport:Add, Checkbox, vOnlineEl, Import as o&nline element
    if (!IWB && !IsVideoOrAudioSite && !OnlineEl) {
      check := IfContains(Browser.Url, DLList) ? "checked" : ""
      Gui, SMImport:Add, Checkbox, % "vDLHTML " . check, Import fullpage &HTML
    }
    if (IWB)
      Gui, SMImport:Add, Checkbox, vCheckDupForIWB, Check &duplication
    if (IsVideoOrAudioSite || OnlineEl) {
      Gui, SMImport:Add, Checkbox, vResetTimeStamp, &Reset time stamp
      if (IfContains(Browser.Url, "youtube.com/watch")) {
        check := (CollName = "bgm") ? "checked" : ""
        Gui, SMImport:Add, Checkbox, % "vUseOnlineProgress " . check, &Mark as use online progress
      }
    }
    Gui, SMImport:Add, Button, default, &Import
    Gui, SMImport:Show,, SuperMemo Import
    Gui, SMImport:+HwndSMImportGuiHwnd
    return
  } else {
    DLHTML := IfContains(Browser.Url, DLList)
  }

SMImportButtonImport:
  if (A_ThisLabel == "SMImportButtonImport") {
    ; Without KeyWait Enter SwitchToSameWindow() below could fail???
    KeyWait Enter
    KeyWait I
    Gui, Submit
    Gui, Destroy
    if (Clipboard != ClipBeforeGui)
      ClipSaved := ClipboardAll
  }

  if (OnlineEl != 1)
    OnlineEl := SM.IsOnline(CollName, Concept)
  if (OnlineEl)  ; just in case user checks both of them
    DLHTML := false
  if (OnlineEl && IWB) {
    ret := true
    if (MsgBox(3,, "You chosed an online concept. Choose again?") = "Yes") {
      Concept := InputBox(, "Enter a new concept:")
      if (!ErrorLevel && !SM.IsOnline(-1, Concept))
        ret := false
    }
    if (ret)
      Goto SMImportReturn
  }

  SwitchToSameWindow(wBrowser)
  if (!IWB)  ; IWB copies text before
    HTMLText := (DLHTML || OnlineEl) ? "" : Copy(false, true)  ; do not copy if download html or online element is checked

  if (CheckDupForIWB) {
    MB := ""
    if (SM.CheckDup(Browser.Url, false))
      MB := MsgBox(3,, "Continue import?")
    DupChecked := true
    WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID", "ahk_class TElWind")
    WinActivate % wBrowser
    if (IfIn(MB, "No,Cancel"))
      Goto SMImportReturn
  }

  if (IWB)
    Browser.Highlight(CollName, Clipboard, Browser.Url)

  if (LocalFile := (Browser.Url ~= "^file:\/\/\/"))
    DLHTML := true
  SMCtrlNYT := (!OnlineEl && SM.IsCtrlNYT(Browser.Url))
  CopyAll := (!HTMLText && !OnlineEl && !DLHTML && !SMCtrlNYT)
  if (DLHTML) {
    if (LocalFile) {
      HTMLText := FileRead(EncodeDecodeURI(RegExReplace(Browser.Url, "^file:\/\/\/"), false))
      Browser.Url := RegExReplace(Browser.Url, "^file:\/\/\/", "file://")  ; SuperMemo converts file:/// to file://
    } else {
      SetToolTip("Attempting to download website...")
      if (!HTMLText := GetSiteHTML(Browser.Url)) {
        SetToolTip("Download failed."), CopyAll := true, DLHTML := false
      } else {
        ; Fixing links
        RegExMatch(Browser.Url, "^https?:\/\/.*?\/", UrlHead)
        RegExMatch(Browser.Url, "^https?:\/\/", HTTP)
        HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K (href|src)=""\/\/(?=([^<>]+)?>)", " $2=""" . HTTP)
        HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K (href|src)=""\/(?=([^<>]+)?>)", " $2=""" . UrlHead)
        HTMLText := RegExReplace(HTMLText, "is)<([^<>]+)?\K (href|src)=""(?=#([^<>]+)?>)", " $2=""" . Browser.Url)
      }
    }
  }

  if (CopyAll) {
    CopyAll()
    HTMLText := GetClipHTMLBody()
  }
  if (!OnlineEl && !HTMLText && !SMCtrlNYT) {
    SetToolTip("Text not found.")
    Goto SMImportReturn
  }

  SkipDate := (OnlineEl && !IsVideoOrAudioSite && (OnlineEl != 2))
  Browser.GetInfo(false,, (CopyAll ? Clipboard : ""),, !SkipDate, !ResetTimeStamp, (DLHTML ? HTMLText : ""))

  if (ResetTimeStamp)
    Browser.TimeStamp := "0:00"
  if (SkipDate)
    Browser.Date := ""

  SMPoundSymbHandled := SM.PoundSymbLinkToComment()
  if (Tags || RefComment) {
    TagsComment := ""
    if (Tags) {
      TagsComment := StrReplace(Trim(Tags), " ", "_")
      TagsComment := "#" . StrReplace(TagsComment, ";", " #")
    }
    if (RefComment && TagsComment)
      TagsComment := " " . TagsComment 
    if (Browser.Comment)
      Browser.Comment := " " . Browser.Comment
    Browser.Comment := Trim(RefComment) . TagsComment . Browser.Comment
  }

  WinClip.Clear()
  if (OnlineEl) {
    ScriptUrl := Browser.Url
    if (Browser.TimeStamp && (TimeStampedUrl := Browser.TimeStampToUrl(Browser.Url, Browser.TimeStamp)))
      ScriptUrl := TimeStampedUrl
    if (Browser.TimeStamp && !TimeStampedUrl) {
      Clipboard := "<SPAN class=Highlight>SMVim time stamp</SPAN>: " . Browser.TimeStamp . SM.MakeReference(true)
    } else if (UseOnlineProgress) {
      Clipboard := "<SPAN class=Highlight>SMVim: Use online video progress</SPAN>" . SM.MakeReference(true)
    } else {
      Clipboard := SM.MakeReference(true)
    }
  } else if (SMCtrlNYT) {
    Clipboard := Browser.Url
  } else {
    LineBreakList := "baike.baidu.com,m.shuaifox.com,khanacademy.org,mp.weixin.qq.com,webmd.com,proofwiki.org,greenhornfinancefootnote.blogspot.com"
    LineBreak := IfContains(Browser.Url, LineBreakList)
    HTMLText := SM.CleanHTML(HTMLText,, LineBreak, Browser.Url)
    if (!IWB && !Browser.Date)
      Browser.Date := "Imported on " . GetDetailedTime()
    Clipboard := HTMLText . SM.MakeReference(true)
  }
  ClipWait

  InfoToolTip := "Importing:`n`n"
               . "Url: " . Browser.Url . "`n"
               . "Title: " . Browser.Title
  if (Browser.Source)
    InfoToolTip .= "`nSource: " . Browser.Source
  if (Browser.Author)
    InfoToolTip .= "`nAuthor: " . Browser.Author
  if (Browser.Date)
    InfoToolTip .= "`nDate: " . Browser.Date
  if (Browser.TimeStamp)
    InfoToolTip .= "`nTime stamp: " . Browser.TimeStamp
  if (Browser.Comment)
    InfoToolTip .= "`nComment: " . Browser.Comment
  SetToolTip(InfoToolTip)

  if (Prio ~= "^\.")
    Prio := "0" . Prio
  SM.CloseMsgDialog()

  ChangeBackConcept := ""
  if (Concept) {
    if ((OnlineEl == 1) && !SM.IsOnline(-1, Concept))
      ChangeBackConcept := Concept, Concept := "Online"
    if (!ret := SM.SetDefaultConcept(Concept,, ChangeBackConcept))
      Goto SMImportReturn
    if (ChangeBackConcept && ret)
      ChangeBackConcept := ret
  }

  if (SMCtrlNYT) {
    Gosub SMCtrlN
  } else {
    PrevSMTitle := WinGetTitle("ahk_class TElWind")
    SM.AltN()
    WinActivate, ahk_class TElWind
    SM.WaitTextFocus()
    TempTitle := WinWaitTitleChange(PrevSMTitle, "ahk_class TElWind")
    SM.PasteHTML()

    if (!OnlineEl) {
      SM.ExitText()
      WinWaitTitleChange(TempTitle, "A")

    } else if (OnlineEl) {
      Critical
      pidSM := WinGet("PID", "ahk_class TElWind")
      Send ^t{f9}{Enter}
      WinWait, % wScript := "ahk_class TScriptEditor ahk_pid " . pidSM,, 3
      WinActivate, % wBrowser
      if (ErrorLevel) {
        SetToolTip("Script component not found.")
        Goto SMImportReturn
      }

      ; ControlSetText to "rl" first than send one "u" is needed to update the editor,
      ; thus prompting it to ask to save on exiting
      ControlSetText, TMemo1, % "rl " . ScriptUrl, % wScript
      ControlSend, TMemo1, {text}u, % wScript
      ControlSend, TMemo1, {Esc}, % wScript
      WinWait, % "ahk_class TMsgDialog ahk_pid " . pidSM
      ControlSend, ahk_parent, {Enter}
      WinWaitClose
      WinWaitClose, % wScript
    }
  }

  ; All SM operations here are handled in the background
  SM.SetElParam((IWB ? "" : Browser.Title), Prio, (SMCtrlNYT ? "YouTube" : ""), (ChangeBackConcept ? ChangeBackConcept : ""))
  if (DupChecked)
    SM.ClearHighlight()
  if (!SMPoundSymbHandled)
    SM.HandleSM19PoundSymbUrl(Browser.Url)
  SM.Reload()
  SM.WaitFileLoad()
  if (ChangeBackConcept)
    SM.SetDefaultConcept(ChangeBackConcept)
  if (Tags)
    SM.LinkConcepts(StrSplit(Tags, ";"),, wBrowser)
  SM.CloseMsgDialog()

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
      SM.ClearHighlight()
  }
  if (OnlineEl || Esc) {
    Browser.ActivateBrowser(wBrowser)
  } else {
    SM.ActivateElWind()
  }
  Browser.Clear(), Vim.State.SetMode("Vim_Normal")
  ; If closed GUI but did not copy anything, restore clipboard
  ; If closed GUI but copied something while the GUI is open, do not restore clipboard
  if (!EscGui || (Clipboard == ClipBeforeGui))
    Clipboard := ClipSaved
  if (!Esc)
    SetToolTip("Import completed.")
  HTMLText := ""  ; empty memory
return

^+e::
  uiaBrowser := new UIA_Browser("A")
  ShellRun("msedge.exe " . uiaBrowser.GetCurrentUrl())
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
^!p::Clipboard := "p" . page, SetToolTip("Copied p" . page)

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
   || (WinActive("ahk_group Browser") && !Browser.IsVideoOrAudioSite() && !SM.IsOnline(, -1))
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

  if (hBrowser && (!BrowserUrl := Browser.ParseUrl(RetrieveUrlFromClip())))
    BrowserUrl := Browser.GetUrl()

  if (hSumatra || (hDJVU := WinActive("ahk_exe WinDjView.exe")) || WinActive("ahk_class AcrobatSDIWindow")) {
    if (!ReadPoint) {
      if (hAcrobat := WinActive("ahk_class AcrobatSDIWindow")) {
        PageNumber := GetAcrobatPageBtn().Value
      } else {
        PageNumber := ControlGetText("Edit1", "A")
      }
      if (!PageNumber) {
        SetToolTip("No text selected and page number not found.")
        Clipboard := ClipSaved
        return
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
      SetToolTip("No text selected.")
      Clipboard := ClipSaved
      return
    }
    if (CloseWnd) {
      if (hBrowser) {
        Send ^w
      } else {
        WinClose, A
      }
    }
  }

  SM.CloseMsgDialog()
  WinActivate, ahk_class TElWind

MarkInHTMLComp:
MarkInHTMLCompAgain:
  SM.EditFirstQuestion()
  auiaText := RefLink := OldText := ""
  if (HTMLExist := SM.WaitHTMLExist(1500)) {
    auiaText := SM.GetTextArray()
    RefLink := hBrowser ? SM.GetLinkFromTextArray(auiaText) : ""
    OldText := SM.GetMarkerFromTextArray(auiaText)
  }
  if (ReadPoint) {
    NewText := "<SPAN class=Highlight>SMVim read point</SPAN>: " . ReadPoint
  } else if (PageNumber) {
    NewText := "<SPAN class=Highlight>SMVim page mark</SPAN>: " . PageNumber
  }

  if (hBrowser) {
    ret := SM.AskToSearchLink(BrowserUrl, RefLink)
    if (ret == 0) {
      SetToolTip("Copied " . Clipboard := NewText)
      return
    } else if (ret == -1) {
      Goto MarkInHTMLCompAgain
    }
  }

  ret := SM.CanMarkOrExtract(HTMLExist, auiaText, OldText, A_ThisLabel, "MarkInHTMLComp", NewText)
  if (ret == -1) {
    Goto MarkInHTMLComp
  } else if (ret == 0) {
    Clipboard := NewText
    return
  }

  if (OldText == RegExReplace(NewText, "<.*?>")) {
    Send {Esc}
    Clipboard := ClipSaved
    return
  }

  if (OldText)
    SM.EmptyHTMLComp()
  WinWaitActive, ahk_class TElWind
  SM.WaitTextFocus()
  if (OldText)
    x := A_CaretX, y := A_CaretY
  Send ^{Home}
  if (OldText)
    WaitCaretMove(x, y)
  Clip(NewText,, false, "sm")
  Send {Esc}
  if (IfContains(A_ThisLabel, "^+!"))
    SM.Learn(false,, true)
  Clipboard := ClipSaved
return

; IE
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe iexplore.exe"))
; Open in default browser (in my case, Chrome); similar to default shortcut ^+e to open in ms edge
^+c::ShellRun(ControlGetText("Edit1", "A"))  ; browser url field
^+e::ShellRun("msedge.exe", ControlGetText("Edit1", "A"))
^!l::SetToolTip("Copied " . Clipboard := ControlGetText("Edit1", "A"))
#if (Vim.State.Vim.Enabled && WinActive("ahk_exe msedge.exe"))
^+c::
  uiaBrowser := new UIA_Browser("A")
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
  FileName := RegExReplace(Browser.Title . GetTimeMSec(), "[^a-zA-Z0-9\\.\\-]", "_")
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
  SM.CloseMsgDialog()
  WinActivate, ahk_class TElWind
  SM.AltA()
  SM.WaitFileLoad()
  if (Browser.Title) {
    Send % "{text}" . SM.MakeReference()
  } else {
    Send {text}Listening comprehension:
  }
  Send {Ctrl Down}ttq{Ctrl Up}
  SM.WaitFileBrowser()
  SM.FileBrowserSetPath(TempPath, true)
  WinWaitActive, ahk_class TInputDlg
  if (Browser.Title) {
    ControlSetText, TMemo1, % Browser.Title . " (excerpt)", A
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
  if (Browser.Title)
    SM.SetTitle(Browser.Title)
  CurrFocus := ControlGetFocus("ahk_class TElWind")
  WinActivate, ahk_class TElWind
  SM.PrevComp()
  ControlWaitNotFocus(CurrFocus, "ahk_class TElWind")
  Send +{Ins}  ; paste: text or image
  aClipFormat := WinClip.GetFormats()
  if (aClipFormat[aClipFormat.MinIndex()].Name == "CF_DIB") {  ; image
    WinWaitActive, ahk_class TMsgDialog
    Send {Enter}
    WinWaitClose
    Send {Enter}
  }
  SM.Reload()
  SM.WaitFileLoad()
  SM.EditFirstAnswer()
  Browser.Clear()
Return

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe ebook-viewer.exe"))
~^f::
  if ((A_PriorHotkey != "~^f") || (A_TimeSincePriorHotkey > 400)) {
    KeyWait f
    return
  }
  Sleep 400
  Send ^v
  WinClip._waitClipReady()
  Send {Enter 2}
return

#if (Vim.State.Vim.Enabled && WinActive("ahk_exe HiborClient.exe"))
!+d::  ; check duplicates
  ClipSaved := ClipboardAll
  if (CopyAll())
    SM.CheckDup(MatchHiborLink(Clipboard))
  Clipboard := ClipSaved
return

#if (Vim.State.Vim.Enabled && (hWnd := WinActive("ahk_exe HiborClient.exe")) && WinExist("ahk_class TElWind"))
^+!a::
^!a::  ; import
  ClipSaved := ClipboardAll
  if (!CopyAll()) {
    Clipboard := ClipSaved
    return
  }
  Link := MatchHiborLink(Clipboard)
  Title := MatchHiborTitle(Clipboard)
  RegExMatch(Title, "^.*?(?=-)", Source)
  Title := StrReplace(Title, Source . "-",,, 1)
  RegExMatch(Title, "\d{6}$", Date)
  Title := StrReplace(Title, "-" . Date,,, 1)
  MB := ""
  if (SM.CheckDup(Link, false))
    MB := MsgBox(3,, "Continue import?")
  WinActivate % "ahk_id " . hWnd
  WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID", "ahk_class TElWind")
  if (IfIn(MB, "No,Cancel"))
    Goto HBImportReturn
  Prio := IfContains(A_ThisLabel, "+") ? SM.AskPrio(false) : ""
  if (Prio == -1)
    Goto HBImportReturn
  WinClip.Clear()
  Clipboard := "#SuperMemo Reference:"
             . "`n#Title: " . Title
             . "`n#Source: " . Source
             . "`n#Date: " . Date
             . "`n#Link: " . Link
  ClipWait
  WinActivate, ahk_class TElWind
  SM.CtrlN()
  SM.SetElParam(Title, Prio)

HBImportReturn:
  SM.ClearHighlight()
  WinWaitNotActive, ahk_class TElWind,, 0.1
  SwitchToSameWindow("ahk_class TElWind")
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
