class VimSM {
  __New(Vim) {
    this.Vim := Vim
  }

  ClickTop() {
    if (this.IsEditingText()) {
      ControlClick, % ControlGetFocus(), ahk_class TElWind,,,, NA x1 y1
    } else {
      ControlGetPos, XCoord, YCoord, Width, Height, Internet Explorer_Server2, ahk_class TElWind  ; server2 because question field of items are server2
      if (XCoord) {  ; item
        ControlClick, Internet Explorer_Server2, ahk_class TElWind,,,, NA x1 y1
      } else {  ; topic
        ControlGetPos, XCoord, YCoord, Width, Height, Internet Explorer_Server1, ahk_class TElWind  ; article field in topics is server1
        if (XCoord) {  ; topic found
          ControlClick, Internet Explorer_Server1, ahk_class TElWind,,,, NA x1 y1
        } else {  ; no html field found
          ControlGetPos, XCoord, YCoord, Width, Height, TMemo1, ahk_class TElWind
          if (XCoord) {  ; question field of plain text item
            ControlClick, TMemo1, ahk_class TElWind,,,, NA x1 y1
          } else {  ; no text
            return false
          }
        }
      }
    }
  }

  ClickMid() {
    if (this.IsEditingText()) {
      ControlGetFocus, CurrFocus, ahk_class TElWind
      ControlGetPos,,,, Height, % CurrFocus, ahk_class TElWind
      ControlClick, % CurrFocus, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
    } else {
      ControlGetPos, XCoord, YCoord, Width, Height, Internet Explorer_Server2, ahk_class TElWind  ; server2 because question field of items are server2
      if (XCoord) {  ; item
        ControlClick, Internet Explorer_Server2, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
      } else {  ; topic
        ControlGetPos, XCoord, YCoord, Width, Height, Internet Explorer_Server1, ahk_class TElWind  ; article field in topics is server1
        if (XCoord) {  ; topic found
          ControlClick, Internet Explorer_Server1, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
        } else {  ; no html field found
          ControlGetPos, XCoord, YCoord, Width, Height, TMemo1, ahk_class TElWind
          if (XCoord) {  ; question field of plain text item
            ControlClick, TMemo1, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
          } else {  ; no text
            return false
          }
        }
      }
    }
  }

  ClickBottom() {
    if (this.IsEditingText()) {
      ControlGetFocus, CurrFocus, ahk_class TElWind
      ControlGetPos,,,, Height, % CurrFocus, ahk_class TElWind
      ControlClick, % CurrFocus, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
    } else {
      ControlGetPos, XCoord, YCoord, Width, Height, Internet Explorer_Server2, ahk_class TElWind  ; server2 because question field of items are server2
      if (XCoord) {  ; item
        ControlClick, Internet Explorer_Server2, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
      } else {  ; topic
        ControlGetPos, XCoord, YCoord, Width, Height, Internet Explorer_Server1, ahk_class TElWind  ; article field in topics is server1
        if (XCoord) {  ; topic found
          ControlClick, Internet Explorer_Server1, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
        } else {  ; no html field found
          ControlGetPos, XCoord, YCoord, Width, Height, TMemo1, ahk_class TElWind
          if (XCoord) {  ; question field of plain text item
            ControlClick, TMemo1, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
          } else {  ; no text
            return false
          }
        }
      }
    }
  }

  IsEditingHTML() {
    return (WinActive("ahk_class TElWind") && InStr(ControlGetFocus(), "Internet Explorer_Server"))
  }

  IsEditingPlainText() {
    return (WinActive("ahk_class TElWind") && InStr(ControlGetFocus(), "TMemo"))
  }

  IsEditingText() {
    ControlGetFocus, CurrFocus
    return (WinActive("ahk_class TElWind") && (InStr(CurrFocus, "Internet Explorer_Server") || InStr(CurrFocus, "TMemo")))
  }

  IsGrading() {
    ControlGetFocus, CurrFocus
    ; If SM is focusing on either 5 of the grading buttons or the cancel button
    return (WinActive("ahk_class TElWind")
         && (CurrFocus == "TBitBtn4"
          || CurrFocus == "TBitBtn5"
          || CurrFocus == "TBitBtn6"
          || CurrFocus == "TBitBtn7"
          || CurrFocus == "TBitBtn8"
          || CurrFocus == "TBitBtn9"))
  }
  
  IsNavigatingPlan() {
    return (WinActive("ahk_class TPlanDlg") && ControlGetFocus() == "TStringGrid1")
  }
  
  IsNavigatingTask() {
    return (WinActive("ahk_class TTaskManager") && ControlGetFocus() == "TStringGrid1")
  }

  IsNavigatingContentWindow() {
    return (WinActive("ahk_class TContents") && ControlGetFocus() == "TVirtualStringTree1")
  }

  IsNavigatingBrowser() {
    return (WinActive("ahk_class TBrowser") && ControlGetFocus() == "TStringGrid1")
  }

  SetPriority(min, max) {
    if (WinActive("SuperMemo Import") && WinActive("ahk_class AutoHotkeyGUI")) {
      ControlSetText, Edit1, % random(min, max)
      ControlFocus Edit2
    } else if (WinActive("Priority") && WinActive("ahk_class #32770")) {  ; input dialogue
      ControlSetText, Edit1, % random(min, max)
    } else if (WinActive("ahk_class TPriorityDlg")) {  ; priority dialogue
      ControlSetText, TEdit5, % random(min, max)
    } else if (WinActive("ahk_group SuperMemo")) {
      send !p  ; open priority window
      send % random(min, max) . "{enter}"
      this.Vim.State.SetNormal()
    }
  }

  SetTaskValue(min, max) {
    ControlSetText, TEdit8, % random(min, max)
    ControlFocus, TEdit7
    this.Vim.State.SetNormal()
  }

  MoveAboveRef(NoRestore:=false) {
    send ^{end}^+{up}  ; if there are references this would select (or deselect in visual mode) them all
    if (InStr(clip("",, NoRestore), "#SuperMemo Reference:")) {
      send {up 2}
    } else {
      send ^{end}
    }
  }

  WaitTextExit(Timeout:=2000) {
    StartTime := A_TickCount
    Loop {
      if (WinActive("ahk_class TElWind") && !this.IsEditingText()) {
        return true
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        return false
      }
    }
  }

  WaitTextFocus(Timeout:=2000) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingText()) {
        return true
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        return false
      }
    }
  }

  WaitHTMLFocus(Timeout:=2000) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingHTML()) {
        return true
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        return false
      }
    }
  }

  ; Wait until cloze/extract is finished
  ; Sometimes it doesn't work, because the A_CaretX was never gone
  WaitProcessing(timeout:=5000) {
    StartTime := A_TickCount
    Loop {
      if (!A_CaretX) {
        break
      } else if (TimeOut && A_TickCount - StartTime > TimeOut / 2) {
        Return False
      }
      sleep 10
    }
    if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
      Return false
    Loop {
      if (A_CaretX) {
        sleep 70  ; to improve robustness
        return true
      } else if (TimeOut && A_TickCount - StartTime > TimeOut / 2) {
        Return False
      }
      sleep 10
    }
  }

  DeselectAllComponents(timeout:=1000) {
    StartTime := A_TickCount
    if (!InStr(ControlGetFocus("ahk_class TElWind"), "TBitBtn")) {
      send ^t{esc}
      Loop {
        if (InStr(ControlGetFocus("ahk_class TElWind"), "TBitBtn")) {
          return true
        } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
          Return False
        }
      }
    }
  }

  EnterInsertIfSpelling() {
    loop {
      sleep 100
      if (InStr(ControlGetFocus(), "TMemo")) {
        this.Vim.State.SetMode("Insert")
        break
      } else if (A_Index > 5) {  ; timeout after 0.5s
        break
      }
    }
  }

  IsLearning() {
    if (ControlGetFocus() == "TBitBtn3") {
      ControlGetText, CurrText, TBitBtn3
      if (WinActive("ahk_class TElWind")) {
        if (CurrText == "Next repetition") {
          return 2
        } else if (CurrText == "Show answer") {
          return 1
        }
      }
    }
  }

  PlayIfCertainColl() {
    if (this.IsPassiveColl()) {
      StartTime := A_TickCount
      Loop {
        if (ControlGetText("TBitBtn3") == "Next repetition") {
          send ^{f10}
          break
        } else if (A_TickCount - StartTime > 100) {  ; timeout after 100ms
          return false
        }
      }
    }
  }

  SaveHTML(pass:=false) {
    if (this.IsEditingHTML() && !pass) {
      send {esc}
      Vim.SM.WaitTextExit()
    }
    send ^+{f6}  ; opens notepad
    WinWaitNotActive, ahk_class TElWind,, 5
    WinClose, ahk_class Notepad
    WinActivate, ahk_class TElWind
  }

  GetCollName(text:="") {
    text := text ? text : WinGetText("ahk_class TElWind")
    RegExMatch(text, "(?<=\r\n).*(?= \(SuperMemo)", CollName)
    return CollName
  }

  GetCollPath(text:="") {
    text := text ? text : WinGetText("ahk_class TElWind")
    RegExMatch(text, "\(SuperMemo [0-9]+: \K.*(?=\)\r\n)", CollPath)
    return CollPath
  }

  GetLink(NoRestore:=false) {
    global WinClip
    if (!NoRestore)
      WinClip.Snap(ClipData)
    WinClip.Clear()
    code := this.GetTemplateCode(NoRestore)
    if (InStr(code, "Link:")) {
      RegExMatch(code, "(?<=#Link: <a href="").*(?="")", link)
      if (!NoRestore)
        WinClip.Restore(ClipData)
      return link
    } else {
      WinClip.Restore(ClipData)
    }
  }

  GetFilePath(NoRestore:=false) {
    global WinClip
    if (!NoRestore)
      WinClip.Snap(ClipData)
    WinClip.Clear()
    send !{f12}fc
    ; this.PostMsg(987, true)  ; not stable
    ClipWait 1
    path := Clipboard
    if (!NoRestore)
      WinClip.Restore(ClipData)
    return path
  }

  SetTitle(title:="") {
    if (WinGetTitle("ahk_class TElWind") != title) {
      this.PostMsg(116)  ; edit title
      GroupAdd, SMAltT, ahk_class TChoicesDlg
      GroupAdd, SMAltT, ahk_class TTitleEdit
      WinWait, ahk_group SMAltT,, 3
      if (WinExist("ahk_class TChoicesDlg")) {
        if (title) {
          send := "{enter}"
        } else {
          send := "f{enter}"
        }
        ControlSend, TGroupButton3, % send, ahk_class TChoicesDlg
        WinWait, ahk_class TTitleEdit,, 3
      }
      if (WinExist("ahk_class TTitleEdit")) {
        if (title)
          ControlSetText, TMemo1, % title
        ControlSend, TMemo1, {enter}, ahk_class TTitleEdit
      }
    }
  }

  GetCurrConcept(CurrText:="") {
    CurrText := CurrText ? CurrText : WinGetText("ahk_class TElWind")
    RegExMatch(CurrText, "(?<=\)\r\n)(.*?)($|\r\n)", ConceptName)
    return ConceptName
  }

  IsPassiveColl(CollName:="") {
    CollName := CollName ? CollName : this.GetCollName()
    return (IfIn(CollName, "passive,singing,piano,calligraphy,drawing,bgm"))
  }

  IsProblemSolvingColl(CollName:="") {
    CollName := CollName ? CollName : this.GetCollName()
    return (IfIn(CollName, "immigration"))
  }

  DoesCollNeedScrComp(CollName:="") {
    CollName := CollName ? CollName : this.GetCollName()
    return (this.IsPassiveColl(CollName) || this.IsProblemSolvingColl(CollName))
  }

  PostMsg(msg, ContextMenu:=false) {
    if (!ContextMenu) {
      PostMessage, 0x0111, % msg,,, ahk_class TElWind
    } else {
      WinGet, ActivePID, PID, A
      if (ActivePID && WinGet("ProcessName") == "sm18.exe") {
        PrevDetectHiddenWindows := A_DetectHiddenWindows
        DetectHiddenWindows on
        WinGet, ContextMenuID, list, % "ahk_class TPUtilWindow ahk_pid " . ActivePID
        PostMessage, 0x0111, % msg,,, % "ahk_id " . ContextMenuID5
        DetectHiddenWindows % PrevDetectHiddenWindows
      }
    }
  }

  GetTemplateCode(NoRestore:=false) {
    global WinClip
    if (!NoRestore)
      WinClip.Snap(ClipData)
    WinClip.Clear()
    send !{f10}tc
    ; this.PostMsg(693, true)  ; not stable
    ClipWait 1
    code := Clipboard
    if (!NoRestore)
      WinClip.Restore(ClipData)
    return code
  }

  WaitFileLoad(timeout:=100) {  ; used for reloading or waiting for an element to load
    StartTime := A_TickCount
    StatText := WinGetText("ahk_class TStatBar")
    ControlTextWaitChange("ahk_class TStatBar", StatText,,,,, timeout / 2)
    match := "^(\s+)?(Priority|Int|Downloading|\([0-9]+ item\(s\))"
    loop {
      if (RegExMatch(WinGetText("ahk_class TStatBar"), match)) {
        return true
      } else if (timeout && A_TickCount - StartTime > timeout) {
        return false
      }
    }
  }

  Learn() {
    if (ControlGetText("TBitBtn2") == "Learn") {
      ControlSend, TBitBtn2, {enter}, ahk_class TElWind
    } else if (IfIn(ControlGetText("TBitBtn3"), "Learn,Show answer,Next repetition", true)) {
      ControlSend, TBitBtn3, {enter}, ahk_class TElWind
    }
  }

  Reload() {
    send !{home}
    this.WaitFileLoad()
    send !{left}
  }

  IsCssClass(text) {
    if (IfIn(text, "cloze,extract,clozed,hint,note,ignore,headers,refText,reference,highlight,searchHighlight,tableLabel,fuck_lexicon"))
      return true
  }

  ChangeDefaultConcept(concept:="") {
    WinActivate, ahk_class TElWind
    WinWaitActive, ahk_class TElWind,, 0
    ControlClickWinCoord(723, 57)
    if (concept) {
      WinWaitActive, ahk_class TRegistryForm,, 3
      ControlSetText, Edit1, % SubStr(concept, 2)
      send % SubStr(concept, 1, 1) . "{enter}"  ; needed for updating the template
      WinWaitActive, ahk_class TElWind,, 5
    }
  }

  ClickElWindSourceBtn() {
    WinActivate, ahk_class TElWind
    WinWaitActive, ahk_class TElWind,, 0
    ControlClickWinCoord(555, 57)
  }

  ClickBrowserSourceButton() {
    WinActivate, ahk_class TBrowser
    WinWaitActive, ahk_class TBrowser,, 0
    ControlClickWinCoord(294, 45)
  }
}