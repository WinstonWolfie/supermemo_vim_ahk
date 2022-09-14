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
      ControlGetFocus, CurrentFocus, ahk_class TElWind
      ControlGetPos,,,, Height, % CurrentFocus, ahk_class TElWind
      ControlClick, % CurrentFocus, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
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
      ControlGetFocus, CurrentFocus, ahk_class TElWind
      ControlGetPos,,,, Height, % CurrentFocus, ahk_class TElWind
      ControlClick, % CurrentFocus, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
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
    ControlGetFocus, CurrentFocus
    return (WinActive("ahk_class TElWind") && (InStr(CurrentFocus, "Internet Explorer_Server") || InStr(CurrentFocus, "TMemo")))
  }

  IsGrading() {
    ControlGetFocus, CurrentFocus
    ; If SM is focusing on either 5 of the grading buttons or the cancel button
    return (WinActive("ahk_class TElWind")
         && (CurrentFocus == "TBitBtn4"
          || CurrentFocus == "TBitBtn5"
          || CurrentFocus == "TBitBtn6"
          || CurrentFocus == "TBitBtn7"
          || CurrentFocus == "TBitBtn8"
          || CurrentFocus == "TBitBtn9"))
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
      if (WinActive("ahk_class TProgressBox")) {
        continue
      } else if (WinActive("ahk_class TElWind") && !this.IsEditingText()) {
        return True
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        return False
      }
    }
  }

  WaitTextFocus(Timeout:=2000) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingText()) {
        return True
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        return False
      }
    }
  }

  ; Wait until cloze/extract is finished
  ; Sometimes it doesn't work, because the A_CaretX was never gone
  WaitProcessing(timeout:=5000) {
    StartTime := A_TickCount
    Loop {
      sleep 20
      if (!A_CaretX) {
        break
      } else if (TimeOut && A_TickCount - StartTime > TimeOut / 2) {
        Return False
      }
    }
    if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
      Return false
    Loop {
      sleep 20
      if (A_CaretX) {
        sleep 20  ; short sleep to improve robustness
        return true
      } else if (TimeOut && A_TickCount - StartTime > TimeOut / 2) {
        Return False
      }
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
    ControlGetText, CurrText, TBitBtn3
    return (WinActive("ahk_class TElWind")
         && (CurrText == "Next repetition" || CurrText == "Show answer"))
  }

  PlayIfCertainCollection() {
    if (this.IsPassiveCollection()) {
      StartTime := A_TickCount
      Loop {
        if (ControlGetText("TBitBtn3") == "Next repetition") {
          send ^{f10}
          break
        } else if (A_TickCount - StartTime > 100) {  ; timeout after 100ms
          return false
        }
      }
    } else if (CollectionName = "gaming") {
      ControlTextWait("TBitBtn3", "Next repetition")
      link := this.GetLinkFromElement()
      if (link)
        run % "msedge.exe " . link
    }
  }

  SaveHTML(pass:=false) {
    if (this.IsEditingHTML() && !pass)
      send {esc}
    send ^+{f6}  ; opens notepad
    WinWaitNotActive, ahk_class TElWind,, 5
    WinClose, ahk_class Notepad
    WinActivate, ahk_class TElWind
  }

  GetCollectionName() {
    RegExMatch(WinGetText("ahk_class TElWind"), "(?<=\r\n)(.*?)(?= \(SuperMemo)", CollectionName)
    return CollectionName
  }

  GetLinkFromElement() {
    global WinClip
    WinClip.Snap(ClipData)
    WinClip.Clear()
    send !{f10}tc  ; copy template
    ClipWait 1
    if (InStr(Clipboard, "Link:")) {
      RegExMatch(Clipboard, "(?<=#Link: <a href="").*(?="")", link)
      return link
    }
    WinClip.Restore(ClipData)
  }

  SetTitle(title) {
    send !t
    GroupAdd, SMAltT, ahk_class TChoicesDlg
    GroupAdd, SMAltT, ahk_class TTitleEdit
    WinWaitActive, ahk_group SMAltT,, 2
    if (WinActive("ahk_class TChoicesDlg")) {
      send {enter}
      WinWaitActive, ahk_class TTitleEdit,, 2
    }
    if (WinActive("ahk_class TTitleEdit")) {
      ControlSetText, TMemo1, % title
      ControlSend, TMemo1, {enter}, ahk_class TTitleEdit
    }
  }

  GetCurrConcept() {
    RegExMatch(WinGetText("ahk_class TElWind"), "(?<=\)\r\n)(.*?)($|\r\n)", ConceptName)
    return ConceptName
  }

  IsPassiveCollection() {
    CollectionName := this.GetCollectionName()
    return (CollectionName = "passive" || CollectionName = "music" || CollectionName = "bgm")
  }
}