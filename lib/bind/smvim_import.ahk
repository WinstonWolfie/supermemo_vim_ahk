#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.State.Vim.Enabled && WinExist("ahk_class TElWind")
                           && ((hBrowser := WinActive("ahk_group Browser")) ; browser group (Chrome, Edge, Firefox)
                            || WinActive("ahk_exe ebook-viewer.exe")        ; Calibre (an epub viewer)
                            || WinActive("ahk_class SUMATRA_PDF_FRAME")     ; SumatraPDF
                            || WinActive("ahk_class AcrobatSDIWindow")      ; Acrobat
                            || WinActive("ahk_exe WINWORD.exe")             ; MS Word
                            || WinActive("ahk_exe WinDjView.exe")))         ; djvu viewer
!+d::  ; check duplicates in SM
  ; In browser, if you select some text, this shortcut will search the selected text,
  ; otherwise it will search the current url
  ToolTip := "selected text", SkipCopy := false, Url := ""
  if (hBrowser) {
    uiaBrowser := new UIA_Browser("ahk_id " . hBrowser)
    Url := Browser.GetUrl()
    if (IfContains(Url, "youtube.com/watch,netflix.com/watch"))  ; Language Reactor extention could copy the subtitles
      Text := Url, SkipCopy := true, ToolTip := "url"
  }
  if (!SkipCopy && (!Text := Copy()) && hBrowser) {
    if (!Url) {
      SetToolTip("Url not found.")
      return
    }
    Text := Url, ToolTip := "url"
  }
  if (!Text) {
    SetToolTip("Text not found.")
    return
  }
  SetToolTip("Searching " . ToolTip . " in " . SM.GetCollName() . "...")
  SM.CheckDup(VimLastSearch := Text)
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

  if (Copy(false) = "") {  ; no text selected, extract empty element with title indicating the section
    Clipboard := ClipSaved  ; might be used in InputBox below
    if ((ch := InputBox(, "Extract chapter/section:")) && !ErrorLevel) {
      if (hBrowser) {
        BrowserUrl := Browser.GetUrl()
        ret := SM.AskToSearchLink(BrowserUrl, SM.GetLink())
        if (ret == 0)
          return
      }
      ; Add # to indicate section at the end of url
      ModifyScript := (hBrowser && IfContains(BrowserUrl, "wikipedia.org") && (ch ~= "^sect: "))

      if (!CtrlState)
        CurrEl := SM.GetElNumber()
      if (ShiftState) {
        Prio := SM.AskPrio(false)
        if (Prio == -1)
          return
      }

      SM.CloseMsgDialog()
      WinActivate, ahk_class TElWind
      if (ParentElNumber := SM.GetParentElNumber()) {
        SM.GoToEl(ParentElNumber)
        WinWaitActive, ahk_class TElWind
        SM.WaitFileLoad()
      }
      SM.OpenBrowser()
      WinWait, % "ahk_class TBrowser ahk_pid " . WinGet("PID", "ahk_class TElWind")
      BrowserTitle := WinWaitTitleRegEx("^Subset elements \(\d+ elements\)")

      if (!IfContains(BrowserTitle, "(1 elements)")) {
        Send ^f
        WinWaitActive, ahk_class TMyFindDlg
        ControlSetText, TEdit1, % ch
        Send {Enter}
        WinWaitActive, ahk_class TProgressBox,, 1
        if (!ErrorLevel)
          WinWaitClose

        ; Check duplicates
        StartTime := A_TickCount
        loop {
          if (WinActive("ahk_class TMsgDialog")) {  ; not found
            WinClose
            Break
          } else if (WinGetTitle("ahk_class TBrowser") ~= "^0 users of ") {
            Break
          } else if (WinGetTitle("ahk_class TBrowser") ~= "^[1-9]+ users of ") {
            m := MsgBox(3,, "Potential duplicate found. Continue?")
            WinActivate, % wCurr
            WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID", "ahk_class TElWind")
            if (IfIn(m, "No,Cancel")) {
              SM.ClearHighlight()
              if (!CtrlState) {
                SM.GoToEl(CurrEl,, true)
              } else {
                SM.ClickElWindSourceBtn()
              }
              return
            }
            SM.ClickElWindSourceBtn()
            SM.WaitFileLoad()
            Break
          } else if (A_TickCount - StartTime > 1500) {
            SM.ClearHighlight(), SetToolTip("Timed out.")
            if (!CtrlState) {
              SM.GoToEl(CurrEl,, true)
            } else {
              SM.ClickElWindSourceBtn()
            }
            return
          }
        }
      }

      WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID", "ahk_class TElWind")
      SM.Duplicate()
      SM.WaitFileLoad()
      SMTitle := WinWaitTitleRegEx("^Duplicate: ", "ahk_class TElWind")
      if (!SM.IsHTMLEmpty() && (MsgBox(3,, "Remove text?") = "Yes")) {
        SM.EmptyHTMLComp()
        WinWaitActive, ahk_class TElWind
      }

      if (ModifyScript) {
        SM.EditFirstQuestion()
        SM.WaitTextFocus()
        Send ^t{f9}
        pidSM := WinGet("PID")
        WinWait, % "ahk_class TScriptEditor ahk_pid " . pidSM,, 3
        if (!CtrlState)
          WinActivate, % wCurr
        if (ErrorLevel) {
          SetToolTip("Script component not found.")
          return
        }
        SectInUrl := RegExReplace(ch, "^sect: ")
        SectInUrl := StrReplace(SectInUrl, " ", "_")  ; SM script components can't have spaces in url parameter
        NewScript := ControlGetText("TMemo1") . "#" . SectInUrl
        SM.SetText("TMemo1", NewScript)
        UIA := UIA_Interface()
        el := UIA.ElementFromHandle(WinExist())
        el.WaitElementExist("ControlType=Button AND Name='OK'").Click()
        WinWait, % "ahk_class TMsgDialog ahk_pid " . pidSM
        ControlSend, ahk_parent, {text}n
        WinWait, % "ahk_class TInputDlg ahk_pid " . pidSM
        ControlSend, TMemo1, {Enter}
      }

      WinActivate, % CtrlState ? "ahk_class TElWind" : wCurr
      SM.SetTitle(RegExReplace(SMTitle, "^Duplicate: ") . " (" . ch . ")")
      if (ShiftState)
        SM.SetPrio(Prio)
      if (!CtrlState)
        SM.GoToEl(CurrEl,, true)
      SM.ClearHighlight()
    }
    return

  } else {
    if (CleanHTML := (hBrowser || hCalibre)) {
      if (hBrowser)
        PlainText := Clipboard
      ClipboardGet_HTML(HTML)
      if (hBrowser) {
        BrowserUrl := Browser.ParseUrl(Url := GetClipUrl(HTML))
        HTML := Browser.MarkToExtractClass(HTML)
      }
      HTML := SM.CleanHTML(GetClipHTMLBody(HTML),,, Url)
      if (hCalibre)
        HTML := RegExReplace(HTML, "data-calibre-range-wrapper=""\d+""", "class=extract")
      WinClip.Clear()
      Clipboard := HTML
      ClipWait
    }
    if (!WinExist("ahk_group SM")) {
      t := CleanHTML ? "(in HTML)" : ""
      SetToolTip("SuperMemo is not open; the text you selected " . t . " is on your clipboard.")
      return
    }
    if (ShiftState) {
      Prio := SM.AskPrio(false)
      if (Prio == -1)
        return
    }
    WinActivate, % wCurr
    if (hBrowser) {
      Browser.Highlight(, PlainText, BrowserUrl)
    } else if (hCalibre) {
      Send {text}q  ; need to enable this shortcut in settings
    } else if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
      Send {text}a
    } else if (WinActive("ahk_exe WINWORD.exe")) {
      Send ^!h
    } else if (WinActive("ahk_exe WinDjView.exe")) {
      Send ^h
      WinWaitActive, ahk_class #32770  ; create annotations
      ControlSend,, {Enter}
    } else if (WinActive("ahk_class AcrobatSDIWindow")) {
      Send {AppsKey}h
      Sleep 100
    }
  }
  SM.CloseMsgDialog()
  WinActivate, ahk_class TElWind  ; focus to element window

ExtractToSM:
ExtractToSMAgain:
  auiaText := RefLink := Marker := ""
  if (HTMLExist := SM.WaitHTMLExist(1500)) {
    auiaText := SM.GetUIAArray()
    RefLink := hBrowser ? SM.GetLinkFromUIAArray(auiaText) : ""
    Marker := SM.GetMarkerFromUIAArray(auiaText)
  }

  if (hBrowser) {
    ret := SM.AskToSearchLink(BrowserUrl, RefLink)
    if (ret == 0) {
      SetToolTip("Copied text.")
      return
    } else if (ret == -1) {
      Goto ExtractToSMAgain
    }
  }

  ret := SM.CanMarkOrExtract(HTMLExist, auiaText, Marker, A_ThisLabel, "ExtractToSM")
  if (ret == -1) {
    Goto ExtractToSM
  } else if (ret == 0) {
    return
  }

  SM.SpamQ()
  if (Marker) {
    SM.EmptyHTMLComp()
    WinWaitActive, ahk_class TElWind
    SM.WaitTextFocus()
    x := A_CaretX, y := A_CaretY
  }
  Send ^{Home}
  if (Marker)
    WaitCaretMove(x, y)
  x := A_CaretX, y := A_CaretY
  if (!CleanHTML) {
    Send ^v
    WinClip._waitClipReady()
  } else {
    SM.PasteHTML(false)
  }
  WaitCaretMove(x, y, 700)  ; insure PasteHTML is finished
  Send ^+{Home}  ; select everything
  if (Prio) {
    Send !+x
    WinWaitActive, ahk_class TPriorityDlg
    ControlSetText, TEdit5, % Prio
    Send {Enter}
  } else {
    Send !x  ; extract
  }
  SM.WaitExtractProcessing()
  SM.SaveHTML()
  SM.EmptyHTMLComp()
  WinWaitActive, ahk_class TElWind
  if (Marker) {
    SM.WaitTextFocus()
    x := A_CaretX, y := A_CaretY
    Send ^{Home}
    WaitCaretMove(x, y)
    Marker := RegExReplace(Marker, "^(SMVim (.*?)):", "<SPAN class=Highlight>$1</SPAN>:")
    Clip(Marker,, false, "sm")
  }
  Send ^+{f7}  ; clear read point
  SM.WaitTextExit()
  if (CtrlState) {
    SM.GoBack()
  } else {
    WinActivate % wCurr
  }
  Clipboard := ClipSaved
return

#if (Vim.State.Vim.Enabled)
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
  if (IWB) {  ; at this point IWB already has content in clip
    Browser.Url := Browser.ParseUrl(GetClipUrl())
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
    ; list := StrLower(CurrConcept . ConceptList)  ; could produce undesired results; commented for now
    list := CurrConcept . ConceptList
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
  ImportCloseTab := CloseTab  ; a global variable for functions to detect, set to empty at the end
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
  if (!IWB) {  ; IWB copies text before
    HTMLText := (DLHTML || OnlineEl) ? "" : Copy(false, true)  ; do not copy if download html or online element is checked
  } else if (IWB) {
    HTMLText := Browser.MarkToExtractClass(HTMLText)
  }

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
    LineBreakList := "baike.baidu.com,m.shuaifox.com,khanacademy.org,mp.weixin.qq.com,"
                   . "webmd.com,proofwiki.org,greenhornfinancefootnote.blogspot.com,cjfearnley.com,"
                   . "oeis.org"
    LineBreak := IfContains(Browser.Url, LineBreakList)
    HTMLText := SM.CleanHTML(HTMLText,, LineBreak, Browser.Url)
    if (!IWB && !Browser.Date)
      Browser.Date := "Imported on " . GetDetailedTime()
    Clipboard := HTMLText . SM.MakeReference(true)
  }
  ClipWait

  ; Shorten YT url for sm19
  RefUrl := Browser.Url
  RefUrl := StrReplace(RefUrl, "https://www.youtube.com/watch?v=", "https://youtube.com/watch?v=")

  InfoToolTip := "Importing:`n`n"
               . "Url: " . RefUrl . "`n"
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
  if (OnlineEl)
    WinActivate, % wBrowser

  if (!SMPoundSymbHandled)
    SM.HandleSM19PoundSymbUrl(Browser.Url)
  ; SM.Reload()
  ; SM.WaitFileLoad()

  if (ChangeBackConcept)
    SM.SetDefaultConcept(ChangeBackConcept)

  if (Tags)
    SM.LinkConcepts(StrSplit(Tags, ";"),, wBrowser)

  SM.CloseMsgDialog()

  if (CloseTab)
    guiaBrowser.CloseTab()

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
    WinActivate, % wBrowser
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
  ImportCloseTab := ""  ; global variable
return
