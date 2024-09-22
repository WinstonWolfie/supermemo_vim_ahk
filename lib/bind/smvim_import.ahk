#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.State.Vim.Enabled && WinExist("ahk_class TElWind")
                           && ((hBrowser := WinActive("ahk_group Browser")) ; browser group (Chrome, Edge, Firefox)
                            || WinActive("ahk_exe ebook-viewer.exe")        ; Calibre (an epub viewer)
                            || WinActive("ahk_class SUMATRA_PDF_FRAME")     ; SumatraPDF
                            || WinActive("ahk_class AcrobatSDIWindow")      ; Acrobat
                            || WinActive("ahk_exe WINWORD.exe")             ; MS Word
                            || WinActive("ahk_exe WinDjView.exe")))         ; djvu viewer
!+d::  ; check duplicates in SM
  ToolTip := "selected text", Skip := false, Url := ""
  if (hBrowser) {
    uiaBrowser := new UIA_Browser("ahk_id " . hBrowser)
    if (IfContains(Url := uiaBrowser.GetCurrentUrl(), "youtube.com/watch,netflix.com/watch"))
      Text := Browser.ParseUrl(Url), Skip := true, ToolTip := "url"
  }
  if (!Skip && (!Text := Copy())) {
    if (hBrowser) {
      if (!Url) {
        SetToolTip("Url not found.")
        return
      }
      Text := Browser.ParseUrl(Url), ToolTip := "url"
    }
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

  if (!Copy(false)) {
    Clipboard := ClipSaved  ; might be used in InputBox below
    if ((ch := InputBox(, "Extract chapter/section:")) && !ErrorLevel) {
      ModifyScript := false
      if (hBrowser) {
        BrowserUrl := Browser.GetUrl()
        ret := SM.AskToSearchLink(BrowserUrl, SM.GetLink())
        if (ret == 0)
          return
        if (IfContains(BrowserUrl, "wikipedia.org")
         && (ch ~= "^sect: ")
         && (MsgBox(3,, "Modify script component?") = "Yes"))
          ModifyScript := true
      }
      if (!CtrlState)
        CurrEl := SM.GetElNumber()
      if (ShiftState) {
        Prio := SM.AskPrio(false)
        if (Prio == -1)
          return
      }
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
            if (IfIn(MsgBox(3,, "Continue?"), "No,Cancel")) {
              WinActivate, % wCurr
              WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID", "ahk_class TElWind")
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
      WinWaitActive, ahk_class TElWind
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
        SectInUrl := StrReplace(SectInUrl, " ", "_")
        NewScript := ControlGetText("TMemo1") . "#" . EncodeDecodeURI(SectInUrl)
        SM.EnterAndUpdate("TMemo1", NewScript)
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
      if (hBrowser)
        BrowserUrl := Browser.ParseUrl(GetClipLink(HTML))
      HTML := SM.CleanHTML(GetClipHTMLBody(HTML))
      if (hCalibre)
        HTML := StrReplace(HTML, "data-calibre-range-wrapper=""1""", "class=extract")
      WinClip.Clear()
      Clipboard := HTML
      ClipWait
    }
    if (!WinExist("ahk_group SM")) {
      a := CleanHTML ? "(in HTML)" : ""
      SetToolTip("SuperMemo is not open; the text you selected " . a . " is on your clipboard.")
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
      SetToolTip("Copied " . Clipboard)
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

  SM.EditFirstQuestion()
  if (Marker)
    SM.EmptyHTMLComp()
  WinWaitActive, ahk_class TElWind
  SM.WaitTextFocus()
  if (Marker)
    x := A_CaretX, y := A_CaretY
  Send ^{Home}
  if (Marker)
    WaitCaretMove(x, y)
  if (!CleanHTML) {
    Send ^v
    WinClip._waitClipReady()
  } else {
    SM.PasteHTML()
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
  SM.WaitExtractProcessing()
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
