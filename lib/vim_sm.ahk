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

  ClickButtom() {
    if (this.IsEditingText()) {
      ControlGetFocus, CurrentFocus, ahk_class TElWind
      ControlGetPos,,,, Height, % CurrentFocus, ahk_class TElWind
      ControlClick, % CurrentFocus, ahk_class TElWind,,,, % "NA x1 y" . Height - 1
    } else {
      ControlGetPos, XCoord, YCoord, Width, Height, Internet Explorer_Server2, ahk_class TElWind  ; server2 because question field of items are server2
      if (XCoord) {  ; item
        ControlClick, Internet Explorer_Server2, ahk_class TElWind,,,, % "NA x1 y" . Height - 1
      } else {  ; topic
        ControlGetPos, XCoord, YCoord, Width, Height, Internet Explorer_Server1, ahk_class TElWind  ; article field in topics is server1
        if (XCoord) {  ; topic found
          ControlClick, Internet Explorer_Server1, ahk_class TElWind,,,, % "NA x1 y" . Height - 1
        } else {  ; no html field found
          ControlGetPos, XCoord, YCoord, Width, Height, TMemo1, ahk_class TElWind
          if (XCoord) {  ; question field of plain text item
            ControlClick, TMemo1, ahk_class TElWind,,,, % "NA x1 y" . Height - 1
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
    return (WinActive("ahk_class TElWind") && (CurrentFocus == "TBitBtn4" || CurrentFocus == "TBitBtn5" || CurrentFocus == "TBitBtn6" || CurrentFocus == "TBitBtn7" || CurrentFocus == "TBitBtn8" || CurrentFocus == "TBitBtn9"))
  }
  
  IsNavigatingPlan() {
    Return (WinActive("ahk_class TPlanDlg") && ControlGetFocus() == "TStringGrid1")
  }
  
  IsNavigatingTask() {
    Return (WinActive("ahk_class TTaskManager") && ControlGetFocus() == "TStringGrid1")
  }
  
  IsNavigatingContentWindow() {
    Return (WinActive("ahk_class TContents") && ControlGetFocus() == "TVirtualStringTree1")
  }
  
  SetPriority(min, max) {
    send !p
    Random, OutputVar, %min%, %max%
    SendInput {raw}%OutputVar%
    send {enter}
    this.Vim.State.SetNormal()
  }

  SetTaskValue(min, max) {
    send !v
    Random, OutputVar, %min%, %max%
    SendInput {raw}%OutputVar%
    send {tab}
    this.Vim.State.SetNormal()
  }

  MoveAboveRef(NoRestore:=false) {
    Send ^{End}^+{up}  ; if there are references this would select (or deselect in visual mode) them all
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
        Return True
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        Return False
      }
    }
  }

  WaitTextFocus(Timeout:=2000) {
    StartTime := A_TickCount
    Loop {
      if (this.IsEditingText()) {
        Return True
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        Return False
      }
    }
  }

  ; Wait until cloze/extract is finished
  ; sometimes it doesn't work, because the A_CaretX was never gone
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
    ControlGetText, CurrentText, TBitBtn3
    return (WinActive("ahk_class TElWind") && (CurrentText == "Next repetition" || CurrentText == "Show answer"))
  }

  PlayIfCertainCollection() {
    RegExMatch(WinGetText(), "(?<=LearnBar\r\n)(.*?)(?= \(SuperMemo 18: )", CollectionName)
    if (CollectionName = "passive" || CollectionName = "music") {
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

  SaveHTML() {
    if (this.IsEditingHTML())
      send {esc}
    send ^+{f6}  ; opens notepad
    WinWaitNotActive, ahk_class TElWind,, 5
    WinClose, ahk_class Notepad
    WinActivate, ahk_class TElWind
  }
}