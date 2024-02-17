#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
class VimSM {
  __New(Vim) {
    this.Vim := Vim
    this.CssClass := "cloze|extract|clozed|hint|note|ignore|headers|RefText"
                   . "|reference|highlight|tablelabel|anti-merge|uppercase"
                   . "|italic|bold|small-caps"
  }

  DoesTextExist(RestoreClip:=true) {
    if (ControlGet(,, "Internet Explorer_Server1", "ahk_class TElWind")
     || ControlGet(,, "TMemo1", "ahk_class TElWind")
     || ControlGet(,, "TRichEdit1", "ahk_class TElWind")) {
      return true
    } else {
      return IfContains(this.GetTemplCode(RestoreClip), "Type=Text", true)
    }
  }

  DoesHTMLExist() {
    return ControlGet(,, "Internet Explorer_Server1", "ahk_class TElWind")
  }

  ClickTop(Control:="") {
    if (Control) {
      ControlClick, % Control, ahk_class TElWind,,,, NA x1 y1
    } else if (this.IsEditingText()) {
      ControlClick, % ControlGetFocus("ahk_class TElWind"), ahk_class TElWind,,,, NA x1 y1
    } else {
      ; server2 because question field of items are server2
      if (ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind")) {  ; item
        ControlClick, Internet Explorer_Server2, ahk_class TElWind,,,, NA x1 y1
      } else {  ; topic
        ; Article field in topics is server1
        if (ControlGet(,, "Internet Explorer_Server1", "ahk_class TElWind")) {  ; topic found
          ControlClick, Internet Explorer_Server1, ahk_class TElWind,,,, NA x1 y1
        } else {  ; no html field found
          if (!this.Vim.SM.DoesTextExist())
            return false
          this.EditFirstQuestion(), this.WaitTextFocus()
          Control := ControlGetFocus("ahk_class TElWind")
          ControlGetPos,,,, Height, % Control, ahk_class TElWind
          ControlClick, % Control, ahk_class TElWind,,,, NA x1 y1
        }
      }
    }
    return true
  }

  ClickMid(Control:="") {
    if (Control) {
      ControlGetPos,,,, Height, % Control, ahk_class TElWind
      ControlClick, % Control, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
    } else if (this.IsEditingText()) {
      CurrFocus := ControlGetFocus("ahk_class TElWind")
      ControlGetPos,,,, Height, % CurrFocus, ahk_class TElWind
      ControlClick, % CurrFocus, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
    } else {
      ControlGetPos,,,, Height, Internet Explorer_Server2, ahk_class TElWind  ; server2 because question field of items are server2
      if (Height) {  ; item
        ControlClick, Internet Explorer_Server2, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
      } else {  ; topic
        ControlGetPos,,,, Height, Internet Explorer_Server1, ahk_class TElWind  ; article field in topics is server1
        if (Height) {  ; topic found
          ControlClick, Internet Explorer_Server1, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
        } else {  ; no html field found
          if (!this.Vim.SM.DoesTextExist())
            return false
          this.EditFirstQuestion(), this.WaitTextFocus()
          Control := ControlGetFocus("ahk_class TElWind")
          ControlGetPos,,,, Height, % Control, ahk_class TElWind
          ControlClick, % Control, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
        }
      }
    }
    return true
  }

  ClickBottom(Control:="") {
    if (Control) {
      ControlGetPos,,,, Height, % Control, ahk_class TElWind
      ControlClick, % Control, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
    } else if (this.IsEditingText()) {
      CurrFocus := ControlGetFocus("ahk_class TElWind")
      ControlGetPos,,,, Height, % CurrFocus, ahk_class TElWind
      ControlClick, % CurrFocus, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
    } else {
      ControlGetPos,,,, Height, Internet Explorer_Server2, ahk_class TElWind  ; server2 because question field of items are server2
      if (Height) {  ; item
        ControlClick, Internet Explorer_Server2, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
      } else {  ; topic
        ControlGetPos,,,, Height, Internet Explorer_Server1, ahk_class TElWind  ; article field in topics is server1
        if (Height) {  ; topic found
          ControlClick, Internet Explorer_Server1, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
        } else {  ; no html field found
          if (!this.Vim.SM.DoesTextExist())
            return false
          this.EditFirstQuestion(), this.WaitTextFocus()
          Control := ControlGetFocus("ahk_class TElWind")
          ControlGetPos,,,, Height, % Control, ahk_class TElWind
          ControlClick, % Control, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
        }
      }
    }
    return true
  }

  IsEditingHTML() {
    return (WinActive("ahk_class TElWind") && IfContains(ControlGetFocus(), "Internet Explorer_Server"))
  }

  IsEditingPlainText() {
    return (WinActive("ahk_class TElWind") && IfContains(ControlGetFocus(), "TMemo,TRichEdit"))
  }

  IsEditingText() {
    return (WinActive("ahk_class TElWind") && IfContains(ControlGetFocus(), "Internet Explorer_Server,TMemo,TRichEdit"))
  }

  IsBrowsing() {
    return (WinActive("ahk_class TElWind") && !this.IsEditingText())
  }

  IsBrowsingBG() {
    return (WinExist("ahk_class TElWind") && !IfContains(ControlGetFocus(), "Internet Explorer_Server,TMemo,TRichEdit"))
  }

  IsGrading() {
    CurrFocus := ControlGetFocus("A")
    ; If SM is focusing on either 5 of the grading buttons or the cancel button
    return (WinActive("ahk_class TElWind")
         && ((CurrFocus == "TBitBtn4")
          || (CurrFocus == "TBitBtn5")
          || (CurrFocus == "TBitBtn6")
          || (CurrFocus == "TBitBtn7")
          || (CurrFocus == "TBitBtn8")
          || (CurrFocus == "TBitBtn9")))
  }

  IsNavigatingPlan() {
    return (WinActive("ahk_class TPlanDlg") && (ControlGetFocus() == "TStringGrid1"))
  }

  IsNavigatingTask() {
    return (WinActive("ahk_class TTaskManager") && (ControlGetFocus() == "TStringGrid1"))
  }

  IsNavigatingContentWind() {
    return (WinActive("ahk_class TContents") && (ControlGetFocus() == "TVirtualStringTree1"))
  }

  IsNavigatingBrowser() {
    return (WinActive("ahk_class TBrowser") && (ControlGetFocus() == "TStringGrid1"))
  }

  SetRandPrio(min, max) {
    Prio := Random(min, max)
    global SMImportGuiHwnd
    if (WinActive("A") == SMImportGuiHwnd) {
      ControlFocus, Edit1
      ControlSetText, Edit1, % Prio
      Send {tab}
    } else if (WinActive("Priority ahk_class #32770")) {  ; input dialogue
      ControlSetText, Edit1, % Prio
    } else if (WinActive("ahk_class TPriorityDlg")) {  ; priority dialogue
      ControlSetText, TEdit5, % Prio
      ControlFocus, TEdit1
    } else if (WinExist("ahk_class TElWind")) {
      this.SetPrio(Prio)
    }
    this.Vim.State.SetNormal()
  }

  SetPrio(Prio, WinWait:=false, ForceBG:=false) {
    if (WinActive("ahk_class TElWind") && !ForceBG) {
      Send !p  ; open priority window
      if (!WinWait) {
        Send % Prio . "{enter}"
      } else {
        WinWaitActive, ahk_class TPriorityDlg
        ControlSetText, TEdit5, % Prio
        ControlSend, TEdit5, {enter}
      }
    } else if (WinExist("ahk_class TElWind") || ForceBG) {
      Send {Alt Down}
      PostMessage, 0x0104, 0x50, 1<<29  ; P key
      PostMessage, 0x0105, 0x50, 1<<29
      Send {Alt Up}
      WinWait, % "ahk_class TPriorityDlg ahk_pid " . WinGet("PID", "ahk_class TElWind")
      ControlSetText, TEdit5, % Prio
      while (WinExist())
        ControlSend, TEdit5, {enter}
    }
  }

  SetRandTaskVal(min, max) {
    ControlSetText, TEdit8, % random(min, max), A
    ControlFocus, TEdit7, A
    this.Vim.State.SetMode("Insert")
  }

  MoveAboveRef(RestoreClip:=true) {
    Send ^{end}^+{up}  ; if there are references this would select (or deselect in visual mode) them all
    if (IfContains(Copy(RestoreClip), "#SuperMemo Reference:")) {
      Send {up 2}
    } else {
      Send ^{end}
    }
  }

  MoveToLast(RestoreClip:=true) {
    Send ^{end}^+{up}  ; if there are references this would select (or deselect in visual mode) them all
    if (InStr(Copy(RestoreClip), "#SuperMemo Reference:")) {
      Send {up}{left}
    } else {
      Send ^{end}
    }
  }

  ExitText(ReturnToComp:=false, Timeout:=0) {
    this.ActivateElWind(), ret := 1
    if (this.IsEditingText()) {
      if (this.HasTwoComp()) {
        this.PrevComp()
        if (ReturnToComp)
          Send ^t
        ret := 2
      }
      Send {Esc}
      if (!this.WaitTextExit(Timeout))
        return 0
    }
    return ret
  }

  WaitTextExit(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (WinActive("ahk_class TElWind") && this.IsBrowsing()) {
        return true
      ; Choices because reference could update
      } else if (this.IsVimNavWnd() || (Timeout && (A_TickCount - StartTime > Timeout))) {
        return false
      }
    }
  }

  WaitTextFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingText()) {
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        return false
      }
    }
  }

  WaitHTMLFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingHTML()) {
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        return false
      }
    }
  }

  WaitPlainTextFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingPlainText()) {
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        return false
      }
    }
  }

  WaitClozeProcessing(Timeout:=0) {
    this.PrepStatBar(1)
    StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        Break
      } else if (A_CaretX && this.WaitFileLoad(-1, false)) {  ; prevent looping forever
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepStatBar(2)
        return 0
      }
    }
    if (WinActive("ahk_class TMsgDialog")) {  ; warning on trying to cloze on items
      this.PrepStatBar(2)
      return -1
    }
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(Timeout, false)
        Sleep 200
        this.PrepStatBar(2)
        return 1
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepStatBar(2)
        Return 0
      }
    }
  }

  WaitExtractProcessing(Timeout:=0) {
    this.PrepStatBar(1)
    StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        Break
      } else if (A_CaretX && this.WaitFileLoad(-1, false, "|Loading file")) {  ; prevent looping forever
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepStatBar(2)
        return false
      }
    }
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(Timeout, false, "|Loading file")
        Sleep 200
        this.PrepStatBar(2)
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepStatBar(2)
        Return false
      }
    }
  }

  EnterInsertIfSpelling(Timeout:=500) {
    StartTime := A_TickCount
    loop {
      Sleep 100
      if (IfContains(ControlGetFocus("ahk_class TElWind"), "TMemo")) {
        this.Vim.State.SetMode("Insert")
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        Break
      }
    }
  }

  IsLearning(wSMElWind:="ahk_class TElWind") {
    CurrText := ControlGetText("TBitBtn3", wSMElWind)
    if (CurrText == "Next repetition") {
      return 2
    } else if (CurrText == "Show answer") {
      return 1
    }
  }

  PlayIfOnlineColl(CollName:="", Timeout:=0) {
    CollName := CollName ? CollName : this.GetCollName()
    if (CollName ~= "i)^(bgm|piano)$")
      return
    if (this.IsOnline(CollName, -1)) {
      StartTime := A_TickCount
      if (ControlTextWait("TBitBtn3", "Next repetition", "ahk_class TElWind",,,, Timeout)) {
        WinActivate, ahk_class TElWind
        this.AutoPlay()
        return true
      } else {
        return false
      }
    }
  }

  SaveHTML(Timeout:="") {
    Timeout := Timeout ? Timeout / 1000 : Timeout
    this.OpenNotepad(Timeout)
    WinWaitActive, ahk_exe Notepad.exe,, % Timeout
    WinActivate
    ControlSend,, {Ctrl Down}w{Ctrl Up}
    WinClose
    WinActivate, ahk_class TElWind
    WinWaitActive, ahk_class TElWind
    return !ErrorLevel
  }

  GetCollName(text:="") {
    text := text ? text : WinGetText("ahk_class TElWind")
    RegExMatch(text, "m)^.+?(?= \(SuperMemo)", CollName)
    return CollName
  }

  GetCollPath(text:="") {
    text := text ? text : WinGetText("ahk_class TElWind")
    RegExMatch(text, "m)\(SuperMemo .*?: \K.+(?=\)$)", CollPath)
    return CollPath
  }

  GetLink(TemplCode:="", RestoreClip:=true) {
    if (res := (RestoreClip && !TemplCode)) {
      ClipSaved := ClipboardAll
      global WinClip
      WinClip.Clear()
    }
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode(false)
    RegExMatch(TemplCode, "(?<=#Link: <a href="").*?(?="")", Link)
    if (res)
      Clipboard := ClipSaved
    return Link
  }

  GetLinksInComment(TemplCode:="", RestoreClip:=true) {
    if (res := (RestoreClip && !TemplCode)) {
      ClipSaved := ClipboardAll
      global WinClip
      WinClip.Clear()
    }
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode(false)
    RegExMatch(TemplCode, "(?<=#Comment: ).*?(?=<\/FONT><\/SuperMemoReference>)", Comment)
    Links := GetAllLinks(Comment)
    if (res)
      Clipboard := ClipSaved
    return Links
  }

  GetFilePath(RestoreClip:=true) {
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global WinClip
    LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
    this.PostMsg(987, true)
    ClipWait, % LongCopy ? 0.6 : 0.2, True
    TemplCode := Clipboard
    if (RestoreClip)  ; for scripts that restore clipboard at the end
      Clipboard := ClipSaved
    return TemplCode
  }

  LoopForFilePath(RestoreClip:=true, MaxLoop:=8) {
    if (RestoreClip)
      ClipSaved := ClipboardAll
    loop {
      if (FilePath := this.GetFilePath(false))
        Break
      if (A_Index > MaxLoop)
        return
    }
    if (RestoreClip)
      Clipboard := ClipSaved
    return FilePath
  }

  SetTitle(title:="", Timeout:="") {
    if (WinGetTitle("ahk_class TElWind") == title)
      return true
    Timeout := Timeout ? Timeout / 1000 : Timeout
    BlockInput, On
    this.AltT()
    GroupAdd, SMAltT, ahk_class TChoicesDlg
    GroupAdd, SMAltT, ahk_class TTitleEdit
    WinWait, % "ahk_group SMAltT ahk_pid " . pidSM := WinGet("PID", "ahk_class TElWind"),, % Timeout
    if (WinGetClass() == "TChoicesDlg") {
      if (!title)
        ControlFocus, TGroupButton2
      while (WinExist("ahk_class TChoicesDlg ahk_pid " . pidSM))
        ControlClick, TBitBtn2,,,,, NA
      if (title)
        WinWait, % "ahk_class TTitleEdit ahk_pid " . pidSM, % Timeout
    }
    if (WinGetClass() == "TTitleEdit") {
      if (title)
        ControlSetText, TMemo1, % title
      ControlSend, TMemo1, {enter}
    }
    BlockInput, Off
  }

  GetCurrConcept() {
    return ControlGetText("TEdit1", "ahk_class TElWind")
  }

  IsOnline(CollName:="", CurrConcept:="") {
    CollName := CollName ? CollName : this.GetCollName()
    ; Online collections
    if (IfIn(CollName, "passive,singing,piano,calligraphy,drawing,bgm,music"))
      return 2
    CurrConcept := CurrConcept ? CurrConcept : this.GetCurrConcept()
    ; Online concepts
    if (IfIn(CurrConcept, "Online,Sources"))
      return 1
  }

  PostMsg(Msg, ContextMenu:=false, wSMElWind:="ahk_class TElWind") {
    if (ContextMenu) {
      DHW := A_DetectHiddenWindows
      DetectHiddenWindows, On
    }

    if (wSMElWind == "ahk_class TElWind") {
      wPost := "ahk_class TElWind"
      WinGet, pahSMElWind, List, ahk_class TElWind
      loop % pahSMElWind {
        pidSM := WinGet("PID", "ahk_id " . hWnd := pahSMElWind%A_Index%)
        if (WinExist("ahk_class TProgressBox ahk_pid " . pidSM)) {
          Continue
        } else {
          WndFound := true, wPost := "ahk_id " . hWnd
          Break
        }
      }
    } else {
      pidSM := WinGet("PID", wSMElWind)
      wPost := "ahk_class TElWind ahk_pid " . pidSM, WndFound := true
    }

    if (!WndFound) {
      if (MsgBox(3,, "SuperMemo is processing something. Do you want to launch a new window?") = "yes") {
        ShellRun("C:\SuperMemo\sm19.exe")
        WinWaitActive, ahk_class TElWind
      } else {
        if (ContextMenu)
          DetectHiddenWindows, % DHW
        return
      }
    }

    if (ContextMenu) {  ; https://zhuanlan.zhihu.com/p/412553730
      WinGet, paContextMenuID, List, ahk_class TPUtilWindow
      loop % paContextMenuID {
        hWnd := paContextMenuID%A_Index%
        wPost := "ahk_id " . hWnd
        if (WinGet("PID", wPost) == pidSM)
          PostMessage, 0x0111, % Msg,,, % wPost
      }
    } else {
      PostMessage, 0x0111, % Msg,,, % wPost
    }
    if (ContextMenu)
      DetectHiddenWindows, % DHW
    return true
  }

  GetTemplCode(RestoreClip:=true, wSMElWind:="ahk_class TElWind") {
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global WinClip
    LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
    this.PostMsg(691, true, wSMElWind)
    ClipWait, % LongCopy ? 0.6 : 0.2, True
    TemplCode := Clipboard
    if (RestoreClip)
      Clipboard := ClipSaved
    return TemplCode
  }

  PrepStatBar(step) {
    static
    if (step == 1) {
      if (!WinGetText("ahk_class TStatBar"))
        this.PostMsg(313), RestoreStatBar := true
      if (WinActive("ahk_class TElWind")) {
        RestoreMouse := true, CMM := A_CoordModeMouse
        CoordMode, Mouse, Screen
        MouseGetPos, xSaved, ySaved
        MouseMove, 0, 0, 0
      }
    } else if (step == 2) {
      if (RestoreMouse) {
        RestoreMouse := false
        MouseMove, xSaved, ySaved, 0
        CoordMode, Mouse, % CMM
      }
      if (RestoreStatBar)
        this.PostMsg(313), RestoreStatBar := false
    }
  }

  WaitFileLoad(Timeout:=0, PrepStatBar:=true, Add:="") {  ; used for reloading or waiting for an element to load
    if (PrepStatBar)
      this.PrepStatBar(1)
    Match := "^(\s+)?(Priority|Int|Downloading|\(\d+ item\(s\)|Please wait" . Add . ")"
    if (Timeout == -1) {
      ret := (WinGetText("ahk_class TStatBar") ~= Match)
    } else {
      StartTime := A_TickCount
      loop {
        while (WinExist("ahk_class Internet Explorer_TridentDlgFrame ahk_pid " . WinGet("PID", "ahk_class TElWind")))  ; sometimes could happen in YT videos
          WinClose
        if (WinGetText("ahk_class TStatBar") ~= Match) {
          ret := true
          Break
        } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
          ret := false
          Break
        }
      }
    }
    if (PrepStatBar)
      this.PrepStatBar(2)
    return ret
  }

  WaitStatBar(Text, PrepStatBar:=true, Timeout:=0) {
    if (PrepStatBar)
      this.PrepStatBar(1)
    StartTime := A_TickCount
    loop {
      while (WinExist("ahk_class Internet Explorer_TridentDlgFrame ahk_pid " . WinGet("PID", "ahk_class TElWind")))  ; sometimes could happen in YT videos
        WinClose
      if (WinGetText("ahk_class TStatBar") ~= Text) {
        ret := true
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        ret := false
        Break
      }
    }
    if (PrepStatBar)
      this.PrepStatBar(2)
    return ret
  }

  Learn(CtrlL:=true, EnterInsert:=false, AutoPlay:=false, wSMElWind:="ahk_class TElWind") {
    this.ActivateElWind(wSMElWind)
    Btn2Text := ControlGetText("TBitBtn2", wSMElWind)
    Btn3Text := ControlGetText("TBitBtn3", wSMElWind)
    if (CtrlL) {
      if (WinGet("ProcessName", wSMElWind) == "sm19.exe") {
        this.PostMsg(178,, wSMElWind)
      } else {
        this.PostMsg(180,, wSMElWind)
      }
    } else if (Btn2Text == "Learn") {
      ControlClick, TBitBtn2, % wSMElWind,,,, NA
    } else if (Btn3Text == "Learn") {
      ControlClick, TBitBtn3, % wSMElWind,,,, NA
    } else if (Btn3Text == "Next repetition") {
      ControlClick, TBitBtn3, % wSMElWind,,,, NA
    }
    if (EnterInsert)
      this.ActivateElWind(wSMElWind), this.EnterInsertIfSpelling()
    if (AutoPlay)
      this.ActivateElWind(wSMElWind), this.PlayIfOnlineColl()
  }

  Reload(Timeout:=0, ForceBG:=false) {
    Critical
    if (!ForceBG && WinActive("ahk_class TElWind")) {
      this.GoHome()
      this.WaitFileLoad(Timeout)
      this.GoBack()
    } else if (WinExist("ahk_class TElWind")) {
      Send {Alt Down}
      PostMessage, 0x0104, 0x24, 1<<29,, ahk_class TElWind  ; home key
      PostMessage, 0x0105, 0x24, 1<<29,, ahk_class TElWind
      this.WaitFileLoad(Timeout)
      PostMessage, 0x0104, 0x25, 1<<29,, ahk_class TElWind  ; left arrow key
      PostMessage, 0x0105, 0x25, 1<<29,, ahk_class TElWind
      Send {Alt Up}
    }
  }

  IsCssClass(text) {
    return (text ~= this.CssClass)
  }

  SetCurrConcept(Concept:="", CurrConcept:="") {
    ; No need for changing if entered concept = current concept
    if (Concept) {
      CurrConcept := CurrConcept ? CurrConcept : this.GetCurrConcept()
      if (CurrConcept = Concept)
        return false
    }
    UIA := UIA_Interface()
    el := UIA.ElementFromHandle(WinExist("ahk_class TElWind"))
    ; Just using ControlClick() cannot operate in background
    pos := el.FindFirstBy("ControlType=Button AND Name='DefaultConceptBtn'").GetCurrentPos("screen")
    ControlClickScreen(pos.x, pos.y, "ahk_class TElWind")
    if (Concept) {
      WinWait, % "ahk_class TRegistryForm ahk_pid " . WinGet("PID", "ahk_class TElWind")
      ControlSend, Edit1, % "{text}" . Concept
      ControlSend, Edit1, {enter}
      return true
    }
  }

  ClickElWindSourceBtn() {
    UIA := UIA_Interface()
    el := UIA.ElementFromHandle(WinExist("ahk_class TElWind"))
    ; Just using ControlClick() cannot operate in background
    pos := el.FindFirstBy("ControlType=Button AND Name='ReferenceBtn'").GetCurrentPos("screen")
    ControlClickScreen(pos.x, pos.y, "ahk_class TElWind")
  }

  ClickBrowserSourceButton() {
    ControlClickWinCoordDPIAdjusted(294, 45, "ahk_class TBrowser")
  }

  SetElParam(Title:="", Prio:="", Template:="", Group:="", Submit:=true) {
    Critical
    if (!Title && !(Prio >= 0) && !Template && !Group) {
      return
    } else if (Title && !(Prio >= 0) && !Template && !Group) {
      this.SetTitle(Title)
      return
    } else if (!Title && (Prio >= 0) && !Template && !Group) {
      this.SetPrio(Prio,, true)
      return
    }
    pidSM := WinGet("PID", "ahk_class TElWind")
    while (!WinExist(w := "ahk_class TElParamDlg ahk_pid " . pidSM)) {
      this.PostMsg(706, true)
      WinWait, % w,, 0.7
      if (!ErrorLevel)
        Break
    }
    if (Template && !(ControlGetText("Edit1") = Template)) {
      ControlSetText, Edit1, % SubStr(Template, 2)
      ControlSend, Edit1, % "{text}" . SubStr(Template, 1, 1)
      this.WaitFileLoad()
    }
    if (Title && (ControlGetText("TEdit2") != Title)) {
      ControlSetText, TEdit2, % SubStr(Title, 2)
      ControlSend, TEdit2, % "{text}" . SubStr(Title, 1, 1)
    }
    if ((Prio >= 0) && (ControlGetText("TEdit1") != Prio)) {
      ControlSetText, TEdit1, % SubStr(Prio, 2)
      ControlSend, TEdit1, % "{text}" . SubStr(Prio, 1, 1)
    }
    if (Group && !(ControlGetText("Edit2") = Group)) {
      ControlSetText, Edit2, % SubStr(Group, 2)
      ControlSend, Edit2, % "{text}" . SubStr(Group, 1, 1)
    }
    if (Submit) {
      ControlFocus, TMemo1  ; needed, otherwise the window won't close sometimes
      while (WinExist(w))
        ControlSend, TMemo1, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{enter}
    }
  }

  IsVimNavWnd() {
    if (WinActive("ahk_class TChoicesDlg")) {
      return ((ControlGetText("TGroupButton1") == "Cancel (i.e. restore the old version of references)")
           && (ControlGetText("TGroupButton2") == "Combine old and new references for this element")
           && (ControlGetText("TGroupButton3") == "Change references in all elements produced from the original article")
           && (ControlGetText("TGroupButton4") == "Change only the references of the currently displayed element"))
          || ((ControlGetText("TGroupButton5") == "Go to the root element of the concept")
           && (ControlGetText("TGroupButton4") == "Transfer the current element to the concept")
           && (ControlGetText("TGroupButton3") == "View the last child of the root")
           && (ControlGetText("TGroupButton2") == "Review the elements in the concept")
           && (ControlGetText("TGroupButton1") == "Cancel"))
    }
  }

  CheckDup(text, ClearHighlight:=true, wSMElWind:="ahk_class TElWind", ToolTip:="No duplicates found.") {  ; try to find duplicates
    pidSM := WinGet("PID", wSMElWind)
    while (WinExist("ahk_class TMsgDialog ahk_pid " . pidSM)
        || WinExist("ahk_class TBrowser ahk_pid " . pidSM))
      WinClose
    ContLearn := this.IsLearning(wSMElWind)
    text := LTrim(text)  ; LTrim() is necessary bc SuperMemo LITERALLY MODIFIES the html
    text := RegExReplace(text, "^file:\/\/\/", "file://")  ; SuperMemo converts file:/// to file://
    if (IsUrl(text))
      text := this.HTMLUrl2SMRefUrl(text)
    ret := this.CtrlF(text, ClearHighlight, ToolTip, wSMElWind)
    if ((ContLearn == 1) && this.LastCtrlFNotFound)
      this.Learn(wSMElWind)
    return ret
  }

  HTMLUrl2SMRefUrl(Url) {
    ; Can't just encode URI, Chinese characters will also be encoded
    ; For some reason, SuperMemo only encodes some part of the url
    ; Probably because of SuperMemo uses a lower version of IE?
    Url := StrReplace(Url, "%20", " ")
    Url := StrReplace(Url, "%21", "!")
    Url := StrReplace(Url, "%22", """")
    Url := StrReplace(Url, "%23", "#")
    Url := StrReplace(Url, "%24", "$")
    Url := StrReplace(Url, "%25", "%")
    Url := StrReplace(Url, "%26", "&")
    Url := StrReplace(Url, "%27", "'")
    Url := StrReplace(Url, "%28", "(")
    Url := StrReplace(Url, "%29", ")")
    Url := StrReplace(Url, "%2A", "*")
    Url := StrReplace(Url, "%2B", "+")
    Url := StrReplace(Url, "%2C", ",")
    Url := StrReplace(Url, "%2D", "-")
    Url := StrReplace(Url, "%2E", ".")
    Url := StrReplace(Url, "%2F", "/")
    Url := StrReplace(Url, "%3A", ":")
    Url := StrReplace(Url, "%3B", ";")
    Url := StrReplace(Url, "%3C", "<")
    Url := StrReplace(Url, "%3D", "=")
    Url := StrReplace(Url, "%3E", ">")
    Url := StrReplace(Url, "%3F", "?")
    Url := StrReplace(Url, "%40", "@")
    Url := StrReplace(Url, "%5B", "[")
    Url := StrReplace(Url, "%5C", "\")
    Url := StrReplace(Url, "%5D", "]")
    Url := StrReplace(Url, "%5E", "^")
    Url := StrReplace(Url, "%5F", "_")
    Url := StrReplace(Url, "%60", "`")
    Url := StrReplace(Url, "%7B", "{")
    Url := StrReplace(Url, "%7C", "|")
    Url := StrReplace(Url, "%7D", "}")
    Url := StrReplace(Url, "%7E", "~")
    if (IfContains(Url, "youtube.com/watch?v="))  ; sm19 deletes www from www.youtube.com
      Url := StrReplace(Url, "www.")
    return Url
  }

  CtrlF(text, ClearHighlight:=true, ToolTip:="Not found.", wSMElWind:="ahk_class TElWind") {
    this.LastCtrlFNotFound := false
    if (!WinExist("ahk_class TElWind"))
      return
    this.CloseMsgDialog(wSMElWind)
    if (WinGet("ProcessName", wSMElWind) == "sm19.exe") {
      ret := this.PostMsg(143,, wSMElWind)
    } else {
      ret := this.PostMsg(144,, wSMElWind)
    }
    if (!ret)
      return false
    WinWait, % "ahk_class TMyFindDlg ahk_pid " . pidSM := WinGet("PID", wSMElWind)
    ControlSetText, TEdit1, % text
    ControlFocus, TEdit1
    ControlSend, TEdit1, {enter}
    GroupAdd, SMCtrlF, ahk_class TMsgDialog
    GroupAdd, SMCtrlF, ahk_class TBrowser
    WinWait, % "ahk_group SMCtrlF ahk_pid " . pidSM
    if (ret := (WinGetClass() == "TBrowser")) {  ; window from the last WinWait
      if (ClearHighlight)
        this.ClearHighlight(wSMElWind)
      WinActivate, % "ahk_class TBrowser ahk_pid " . pidSM
    } else if (WinGetClass() == "TMsgDialog") {
      this.LastCtrlFNotFound := true
      WinClose
      this.Vim.State.SetToolTip(ToolTip)
      if (ClearHighlight)
        this.ClearHighlight(wSMElWind)
    }
    return ret
  }

  ClearHighlight(wSMElWind:="ahk_class TElWind") {
    return this.Command("h", wSMElWind)
  }

  Command(text, wSMElWind:="ahk_class TElWind") {
    if (WinGet("ProcessName", wSMElWind) == "sm19.exe") {
      ret := this.PostMsg(238,, wSMElWind)
    } else {
      ret := this.PostMsg(240,, wSMElWind)
    }
    if (!ret)
      return false
    WinWait, % "ahk_class TCommanderDlg ahk_pid " . pidSM := WinGet("PID", wSMElWind)
    if (text) {
      ControlSetText, TEdit2, % text
      ControlTextWait("TEdit2", text, "")
    }
    while (WinExist("ahk_class TCommanderDlg ahk_pid " . pidSM)) {
      ControlClick, TButton4,,,,, NA
      if (WinExist("ahk_class #32770 ahk_pid " . pidSM))
        ControlSend,, {Esc}
    }
    return true
  }

  MakeReference(html:=false) {
    Break := html ? "<br>" : "`n"
    text := Break . "#SuperMemo Reference:"
    if (this.Vim.Browser.Url)
      text .= Break . "#Link: " . this.HTMLUrl2SMRefUrl(this.Vim.Browser.Url)
    if (this.Vim.Browser.Title)
      text .= Break . "#Title: " . this.Vim.Browser.Title
    if (this.Vim.Browser.Source)
      text .= Break . "#Source: " . this.Vim.Browser.Source
    if (this.Vim.Browser.Author)
      text .= Break . "#Author: " . this.Vim.Browser.Author
    if (this.Vim.Browser.Date)
      text .= Break . "#Date: " . this.Vim.Browser.Date
    if (this.Vim.Browser.Comment)
      text .= Break . "#Comment: " . this.Vim.Browser.Comment
    return text
  }

  HandleF3(step) {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      msg := 145
    } else {
      msg := 146
    }
    if (step == 1) {
      this.PostMsg(msg)  ; f3
      WinWaitActive, ahk_class TMyFindDlg,, 0.7
      if (ErrorLevel) {  ; SM goes to the next found without opening find dialogue
        this.ClearHighlight()  ; clears highlight so it opens find dialogue
        this.PostMsg(msg)
        WinWaitActive, ahk_class TMyFindDlg,, 3.5
        if (ErrorLevel) {
          this.Vim.State.SetToolTip("F3 window cannot be launched.")
          return false
        }
      }
      return true
    } else if (step == 2) {
      Send ^{enter}  ; open commander; convienently, if a "not found" window pops up, this would close it
      WinWait, % "ahk_class TMyFindDlg ahk_pid " . WinGet("PID", "ahk_class TElWind"),, 0.3  ; sometimes TMyFindDlg will still pop up
      GroupAdd, SMF3, ahk_class TMyFindDlg
      GroupAdd, SMF3, ahk_class TCommanderDlg
      WinWaitActive, ahk_group SMF3
      if (WinGetClass() == "TMyFindDlg") {  ; ^enter closed "not found" window
        WinClose
        this.ClearHighlight()
        Send {Esc}
        this.Vim.State.SetNormal(), this.Vim.State.SetToolTip("Text not found.")
        return false
      } else if (WinGetClass() == "TCommanderDlg") {  ; ^enter opened commander
        Send {text}h  ; clear highlight
        Send {enter}
        WinWaitNotActive
        this.PostMsg(msg)
        WinWaitActive, ahk_class TMyFindDlg
        WinClose
        WinWaitNotActive, ahk_class TElWind,, 0.1
        this.Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
        return true
      }
    }
  }

  GoToTopIfLearning(LearningState:=0) {
    if ((!LearningState && this.IsLearning())
     || (LearningState && (this.IsLearning() == LearningState)))
      this.GoHome()
  }

  GoHome(ForceBG:=false) {
    if (!ForceBG && WinActive("ahk_class TElWind")) {
      Send !{home}
    } else if (ForceBG || WinExist("ahk_class TElWind")) {
      Send {Alt Down}
      PostMessage, 0x0104, 0x24, 1<<29  ; home key
      PostMessage, 0x0105, 0x24, 1<<29
      Send {Alt Up}
    }
  }

  GoBack(ForceBG:=false) {
    if (!ForceBG && WinActive("ahk_class TElWind")) {
      Send !{left}
    } else if (ForceBG || WinExist("ahk_class TElWind")) {
      Send {Alt Down}
      PostMessage, 0x0104, 0x25, 1<<29  ; left arrow key
      PostMessage, 0x0105, 0x25, 1<<29
      Send {Alt Up}
    }
  }

  AutoPlay() {
    this.ActivateElWind(), this.Vim.State.SetToolTip("Running...")
    Marker := this.GetMarkerFromTextArray(auiaText := this.GetTextArray())
    if (WinGetTitle("ahk_class TElWind") == "Netflix") {
      ShellRun(this.GetLinkFromTextArray(auiaText))
    } else if (Marker == "SMVim: Use online video progress") {
      Gosub SearchLinkInYT
    } else {
      Send ^{f10}
      WinWaitActive, ahk_class TMsgDialog,, 0
      if (!ErrorLevel)
        Send {text}y 
    }
    SMTitle := WinGetTitle("ahk_class TElWind")
    ToolTip := "Running: `n`nTitle: " . SMTitle
    if (Marker ~= "^SMVim(?!:)") {
      ToolTip .= "`n" . StrUpper(SubStr(Marker, 7, 1)) . SubStr(Marker, 8)
      Str := SubStr(Marker, 7)
      RegExMatch(Str, "^.*?(?=:)", MarkerName)
      RegExMatch(Str, "(?<=: ).*$", MarkerContent)
    }
    if (!Marker) {
      TemplCode := this.GetTemplCode()
      if (!IfContains(TemplCode, "Type=Script,Type=Binary", true)) {
        this.Vim.State.SetToolTip("Script or binary component not found.")
        return False
      }
    }
    WinWaitNotActive, ahk_class TElWind,, 10
    hReader := WinActive("A")
    if (MarkerName = "read point") {
      if (WinActive("ahk_group Browser")) {
        uiaBrowser := new UIA_Browser("ahk_id " . hReader)
        uiaBrowser.WaitPageLoad(,, 0)
      }
      t := "Do you want to search read point?"
         . "`n`nTitle: " . SMTitle
         . "`nRead point: " . MarkerContent
      if (MsgBox(3,, t) = "yes") {
        if (WinActive("ahk_class SUMATRA_PDF_FRAME")) {
          ControlFocus, Edit2
          ControlSetText, Edit2, % MarkerContent
          Send {enter}
        } else {
          ClipSaved := ClipboardAll
          Clipboard := MarkerContent
          WinWaitActive, % "ahk_id " . hReader
          Send ^f
          Sleep 100
          if (Calibre := WinActive("ahk_exe ebook-viewer.exe"))
            Sleep 100
          Send ^v
          global WinClip
          WinClip._waitClipReady()
          Send {enter}
          if (Calibre)
            Send {enter}
          Clipboard := ClipSaved
        }
      }
    } else if (MarkerName = "page mark") {
      if (MsgBox(3,, "Do you want to go to page mark?") = "yes") {
        WinWaitActive, % "ahk_id " . hReader
        if (WinActive("ahk_class SUMATRA_PDF_FRAME") || WinActive("ahk_exe WinDjView.exe")) {
          ControlFocus, Edit1
          ControlSetText, Edit1, % MarkerContent
          Send {enter}
        }
      }
    } else {
      this.Vim.State.SetToolTip(ToolTip)
    }
  }

  AltT() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      ret := this.PostMsg(115)
    } else {
      ret := this.PostMsg(116)
    }
    return ret
  }

  RunLink(Url, RunInIE:=false) {
    if (RegExMatch(Url, "SuperMemoElementNo=\(\K\d+", v)) {  ; goes to a SuperMemo element
      this.GoToEl(v)
    } else {
      if (RunInIE) {
        this.Vim.Browser.RunInIE(Url)
      } else {
        if ((Url ~= "file:\/\/") && (Url ~= "#.*"))
          v := Url, Url := RegExReplace(Url, "#.*")
        try ShellRun(Url)
        catch
          return false
        if (v) {
          WinWaitActive, ahk_group Browser
          uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
          uiaBrowser.SetUrl(v, true)
        }
      }
    }
    return true
  }

  EditFirstQuestion() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(117)
    } else {
      this.PostMsg(118)
    }
  }

  EditFirstAnswer() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(118)
    } else {
      this.PostMsg(119)
    }
  }

  EditAll() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(119)
    } else {
      this.PostMsg(120)
    }
  }

  EditRef() {
    ; this.ActivateElWind()
    ; Send !{f10}fe
    this.PostMsg(658, true)
  }

  AltA() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(93)
    } else {
      this.PostMsg(95)
    }
  }

  CtrlN() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(94)
    } else {
      this.PostMsg(96)
    }
  }

  AltN() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(96)
    } else {
      this.PostMsg(98)
    }
  }

  WaitBrowser(Timeout:=1) {
    WinWaitActive, ahk_class TProgressBox,, % Timeout
    if (!ErrorLevel)
      WinWaitClose
    WinWaitActive, ahk_class TBrowser
  }

  InvokeFileBrowser() {
    this.ActivateElWind()
    Send {Ctrl Down}ttq{Ctrl Up}
    GroupAdd, SMCtrlQ, ahk_class TFileBrowser
    GroupAdd, SMCtrlQ, ahk_class TMsgDialog
    WinWaitActive, ahk_group SMCtrlQ
    while (!WinActive("ahk_class TFileBrowser")) {
      while (WinActive("ahk_class TMsgDialog"))
        WinClose  ; Directory not found; Create?
      WinWaitActive, ahk_group SMCtrlQ
    }
  }

  SpamQ(SpamInterval:=100, Timeout:=0) {
    loop {
      this.EditFirstQuestion()
      if (SpamInterval && this.WaitTextFocus(SpamInterval)) {
        return true
      } else if (!SpamInterval && this.IsEditingText()) {
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        return false
      }
    }
  }

  HasTwoComp() {
    return ((ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind") && ControlGet(,, "Internet Explorer_Server1", "ahk_class TElWind"))
         || (ControlGet(,, "TMemo2", "ahk_class TElWind") && ControlGet(,, "TMemo1", "ahk_class TElWind")))
  }

  RandCtrlJ(min, max) {
    Send % "^j" . Random(min, max) . "{enter 2}"
    this.Vim.State.SetNormal()
  }

  ActivateElWind(wSMElWind:="ahk_class TElWind") {
    if (!WinActive(wSMElWind))
      WinActivate, % wSMElWind
  }

  AskPrio(SetPrio:=true) {
    if ((!Prio := InputBox("Priority", "Enter priority:")) || ErrorLevel)
      return
    if (Prio >= 0) {
      if (Prio ~= "^\.")
        Prio := "0" . Prio
      if (SetPrio)
        this.SetPrio(Prio,, true)
      return Prio
    }
  }

  CloseMsgDialog(wSMElWind:="ahk_class TElWind") {
    pidSM := WinGet("PID", wSMElWind)
    while (WinExist("ahk_class TMsgDialog ahk_pid " . pidSM))
      WinClose
  }

  OpenNotepad(Timeout:=0) {
    this.ExitText(true, Timeout)
    Send ^+{f6}
}

  Plan() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      ret := this.PostMsg(241)
    } else {
      ret := this.PostMsg(243)
    }
    return ret
  }

  IsItem(TemplCode:="") {
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode()
    return InStr(TemplCode, "`r`nType=Item`r`n", true)
  }

  FileBrowserSetPath(path, enter:=false) {
    if (!WinActive("ahk_class TFileBrowser"))
      return false
    RegexMatch(path, "^(.):", v), drive := v1
    t := ControlGetText("TDriveComboBox1")
    if !(t ~= "i)^" . v) {
      ControlSend, TDriveComboBox1, % drive
      ControlTextWaitChange("TDriveComboBox1", t)
    }
    ControlSetText, TEdit1, % path
    ControlTextWait("TEdit1", path)
    if (enter)
      ControlClick, TButton2,,,,, NA
  }

  EditBar(n) {
    this.ActivateElWind()
    UIA := UIA_Interface(), el := UIA.ElementFromHandle(WinActive("A"))
    el.FindFirstBy("ControlType=TabItem AND Name='Edit'").ControlClick()
    el.WaitElementExist("ControlType=ToolBar AND Name='Format'").FindByPath(n).ControlClick()
    el.FindFirstBy("ControlType=TabItem AND Name='Learn'").ControlClick()
    this.Vim.Caret.SwitchToSameWindow()
  }

  PasteHTML(SleepInterval:=1) {
    ; this.ActivateElWind()
    ; Send {AppsKey}xp  ; Paste HTML
    this.PostMsg(843, true)
    while (DllCall("GetOpenClipboardWindow"))
      Sleep % SleepInterval
    WinWait, % "ahk_class TProgressBox ahk_pid " . WinGet("PID", "ahk_class TElWind"),, 0.3
    if (!ErrorLevel)
      WinWaitClose
    ; WinWaitNotActive, ahk_class TElWind,, 0.3
    ; WinWaitActive, ahk_class TElWind
  }

  HandleSM19PoundSymbUrl(Url) {
    if ((WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") && IfContains(Url, "#")) {
      pidSM := WinGet("PID", "ahk_class TElWind")
      this.PostMsg(154), ShortUrl := RegExReplace(Url, "#.*")
      WinWait, % "ahk_class TRegistryForm ahk_pid " . pidSM
      ControlSetText, Edit1, % SubStr(ShortUrl, 2)
      ControlSend, Edit1, % "{text}" . SubStr(ShortUrl, 1, 1)
      this.RegAltR()
      WinWait, % "ahk_class TInputDlg ahk_pid " . pidSM
      if (ControlGetText("TMemo1") == ShortUrl)
        ControlSetText, TMemo1, % Url
      ControlSend, TMemo1, {Ctrl Down}{enter}{Ctrl Up}  ; submit
      WinWaitClose
      WinWait, % "ahk_class TChoicesDlg ahk_pid " . pidSM,, 0.3
      if (!ErrorLevel) {
        ControlFocus, TGroupButton3
        ControlClick, TBitBtn2,,,,, NA
        WinWaitClose
        WinWait, % "ahk_class TChoicesDlg ahk_pid " . pidSM
        ControlFocus, TGroupButton2
        ControlClick, TBitBtn2,,,,, NA
        WinWaitClose
      }
      WinClose, % "ahk_class TRegistryForm ahk_pid " . pidSM
      return true
    }
  }

  GetElNumber(TemplCode:="", RestoreClip:=true) {
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode(RestoreClip)
    RegExMatch(TemplCode, "Begin Element #(\d+)", v)
    return v1
  }

  PoundSymbLinkToComment() {
    if ((WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") && IfContains(this.Vim.Browser.Url, "#")) {
      PoundSymbCommentList := "workflowy.com"
      if (IfContains(this.Vim.Browser.Url, PoundSymbCommentList)) {
        this.Vim.Browser.Comment := this.Vim.Browser.Url
        return true
      }
    }
  }

  EmptyHTMLComp() {
    ; this.ActivateElWind()
    loop {
      ; Send !{f12}kd  ; delete registry link
      this.PostMsg(935, true)
      WinWait, % "ahk_class TMsgDialog ahk_pid " . WinGet("PID", "ahk_class TElWind"),, 0.2
      if (!ErrorLevel) {
        ControlSend, ahk_parent, {Enter}
        WinWaitClose
        Break
      }
    }
  }

  OpenBrowser() {
    ; Sometimes a bug makes that you can't use ^space to open browser in content window
    ; After a while, I found out it's due to my Chinese input method
    ; SetDefaultKeyboard(0x0409)  ; English-US
    ; Send ^{space}  ; open browser
    if (WinActive("ahk_class TElWind")) {
      this.PostMsg(719, true)
    } else if (WinActive("ahk_class TContents")) {
      ControlSend, ahk_parent, {Ctrl Down}{Space}{Ctrl Up}
    }
  }

  MatchLink(SMLink, Url) {
    Url := this.HTMLUrl2SMRefUrl(Url)
    if (IfContains(Url, "britannica.com")) {
      return IfContains(Url, SMLink)
    } else {
      return (SMLink == Url)
    }
  }

  GetTextArray() {
    this.ActivateElWind()
    UIA := UIA_Interface()
    el := UIA.ElementFromHandle(ControlGet(,, "Internet Explorer_Server1", "A"))
    if (!Ref := el.FindFirstByName("#SuperMemo Reference:"))  ; item
      el := UIA.ElementFromHandle(ControlGet(,, "Internet Explorer_Server2", "A"))
    return el.FindAllByType("text")
  }

  GetLinkFromTextArray(auiaText:="") {
    auiaText := IsObject(auiaText) ? auiaText : this.GetTextArray()
    for i, v in auiaText {
      if (v.Name == "#Link: ")
        return v.FindByPath("+1").Name
    }
  }

  GetMarkerFromTextArray(auiaText:="") {
    auiaText := IsObject(auiaText) ? auiaText : this.GetTextArray()
    for i, v in auiaText {
      if ((i == 1) && (v.Name == "#SuperMemo Reference:")) {  ; empty
        return
      } else if ((i == 1) && (v.Name ~= "^SMVim .*")) {
        Marker := v.Name
        Continue
      } else if ((i == 1) && (v.Name == "SMVim: Use online video progress")) {
        return v.Name
      } else if ((i == 2) && Marker) {
        Marker .= v.Name
        Break
      } else {
        return
      }
    }
    return Marker
  }

  IsHTMLEmpty(auiaText:="") {
    auiaText := IsObject(auiaText) ? auiaText : this.GetTextArray()
    for i, v in auiaText {
      if ((i == 1) && (v.Name == "#SuperMemo Reference:")) {
        return true
      } else {
        return false
      }
    }
  }

  GetParentElNumber(auiaText:="") {
    auiaText := IsObject(auiaText) ? auiaText : this.GetTextArray()
    for i, v in auiaText {
      if (v.Name == "#Article: ")
        return v.FindByPath("+1").Name
    }
  }

  IsCompMarker(text) {
    if (RegExMatch(text, "^SMVim (.*?):", v)) {
      return v1
    } else {
      return false
    }
  }

  ListLinks() {
    ; this.ActivateElWind()
    ; Send !{f10}cs
    this.PostMsg(650, true)
  }

  LinkConcept(Concept:="", ForegroundWnd:="") {
    ; this.ActivateElWind()
    ; Send !{f10}cl
    this.PostMsg(642, true)
    if (ForegroundWnd)
      WinActivate % ForegroundWnd
    pidSM := WinGet("PID", "ahk_class TElWind")
    if (Concept) {
      WinWait, % "ahk_class TRegistryForm ahk_pid " . pidSM
      w := "ahk_id " . WinExist()
      ControlSend, Edit1, % "{text}" . Concept
      this.RegAltR()
      WinWait, % "ahk_class TInputDlg ahk_pid " . pidSM
      CurrConcept := ControlGetText("TMemo1")
      WinClose
      if (InStr(CurrConcept, Concept) != 1) {
        WinActivate, % w
        MB := MsgBox(3,, "Current concept doesn't seem like your entered concept. Continue?")
        if (IfIn(MB, "No,Cancel")) {
          WinClose, % w
          return
        }
      }
      ControlSend, Edit1, {enter}, % w
      WinWaitClose, % w
      return true
    }
  }

  Cloze() {
    this.ActivateElWind()
    Send !z
    this.WaitForChangingRef()
  }

  WaitForChangingRef() {
    WinWaitActive, ahk_class TChoicesDlg,, 0.3
    if (!ErrorLevel) {
      WinClose
      loop 3 {
        WinWaitActive, ahk_class TChoicesDlg,, 1.5
        if (!ErrorLevel)
          WinClose
      }
    }
  }

  AskToSearchLink(BrowserUrl, SMUrl, wSMElWind:="ahk_class TElWind") {  ; return false if user wants to stop
    t := "Link in SM reference is not the same as in the browser. Continue?"
       . "`n(press no to execute a search)"
       . "`nBrowser url: " . BrowserUrl
       . "`n       SM url: " . SMUrl
    MB := MsgBox(3,, t), Cont := true
    if (MB = "no") {
      if (this.CheckDup(BrowserUrl,, wSMElWind, "Link not found in collection.")) {
        MB := MsgBox(3,, "Found. Continue?")
        WinClose, ahk_class TBrowser
        if (MB = "yes") {
          WinWaitActive, ahk_class TElWind
        } else {
          Cont := false
        }
      } else {
        Cont := false
      }
    } else if (MB = "cancel") {
      Cont := false
    }
    return Cont
  }

  CleanHTML(str, nuke:=false, LineBreak:=false, Url:="") {
    ; zzz in case you used f6 in SuperMemo to remove format before,
    ; which disables the tag by adding zzz (eg, <FONT> -> <ZZZFONT>)

    ; All attributes removal detects for <> surrounding
    ; however, sometimes if a text attribute is used, and it has HTML tag
    ; style and others removal might not be working
    ; Example: https://www.scientificamerican.com/article/can-newborn-neurons-prevent-addiction/
    ; This will likely not be fixed

    RegExMatch(str, r := "i)^<strong><font color=""?blue""?>.*? : <\/font><\/strong>", SMSplit)
    if (SMSplit)
      str := RegExReplace(str, r, SMSplitPlaceHolder := GetDetailedTime())

    if (nuke) {
      ; Classes
      str := RegExReplace(str, "is)<[^>]+\K\sclass="".*?""(?=([^>]+)?>)")
      str := RegExReplace(str, "is)<[^>]+\K\sclass=[^ >]+(?=([^>]+)?>)")
    }

    if (LineBreak)
      str := RegExReplace(str, "i)<(BR|(\/)?DIV)", "<$2P")

    if (IfContains(Url, "economist.com"))
      str := StrReplace(str, "<small", "<small class=uppercase")
      ; str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+font-family: var\(--ds-type-system-.*?-smallcaps\))(?=[^>]+>)", " class=uppercase ")

    ; Ilya Frank
    ; str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+COLOR: green)(?=[^>]+>)", " class=ilya-frank-translation ")

    ; Converts font-style to tags
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+font-style: italic)(?=[^>]+>)", " class=italic ")
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+font-weight: bold)(?=[^>]+>)", " class=bold ")
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+text-decoration: underline)(?=[^>]+>)", " class=underline ")

    ; For Dummies books
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?class=zcheltitalic(?=([^>]+)?>)", " class=italic")

    ; Styles and fonts
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?style="".*?""(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?style='.*?'(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?style=[^>]+(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<\/?(zzz)?(font|form)([^>]+)?>")

    ; SuperMemo uses IE7; svg was introduced in IE9
    str := RegExReplace(str, "is)<\/?(svg|path)([^>]+)?>")
    str := StrReplace(str, "https://wikimedia.org/api/rest_v1/media/math/render/svg/", "https://wikimedia.org/api/rest_v1/media/math/render/png/")

    ; Scripts
    str := RegExReplace(str, "is)<(zzz)?iframe([^>]+)?>.*?<\/(zzz)?iframe>")
    str := RegExReplace(str, "is)<(zzz)?button([^>]+)?>.*?<\/(zzz)?button>")
    str := RegExReplace(str, "is)<(zzz)?script([^>]+)?>.*?<\/(zzz)?script>")
    str := RegExReplace(str, "is)<(zzz)?input([^>]+)?>")
    str := RegExReplace(str, "is)<[^>]+\K\s(bgcolor|onerror|onload|onclick|onmouseover|onmouseout)="".*?""(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(bgcolor|onerror|onload|onclick|onmouseover|onmouseout)=[^ >]+(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(onmouseover|onmouseout)=[^;]+;(?=([^>]+)?>)")

    ; Remove empty paragraphs
    str := RegExReplace(str, "is)<p([^>]+)?>(&nbsp;|\s| )+<\/p>")
    str := RegExReplace(str, "is)<div([^>]+)?>(&nbsp;|\s| )+<\/div>")

    v := 1
    while (v)  ; remove <div></div>
      str := RegExReplace(str, "is)<div([^>]+)?>(\n+)?<\/div>",, v)

    if (SMSplit)
      str := StrReplace(str, SMSplitPlaceHolder, SMSplit)

    return str
  }

  LinkConcepts(aTags, ForegroundWnd:="") {
    loop % aTags.MaxIndex()
      this.LinkConcept(aTags[A_Index], ForegroundWnd)
  }

  RegAltR(WinTitle:="") {
    Acc_Get("Object", "4.5.4.6.4",, WinTitle).accDoDefaultAction()
  }

  PrevComp() {
    this.ActivateElWind()
    Send !{f12}fl
    ; this.PostMsg(992, true)
  }

  DetachTemplate() {
    this.ActivateElWind()
    Send !{f10}td
    ; this.PostMsg(682, true)
  }

  LinkContents() {
    ; this.ActivateElWind()
    ; Send !{f10}ci
    this.PostMsg(647, true)
  }

  ViewFile() {
    this.ActivateElWind()
    Send !{f12}fv
    ; this.PostMsg(982, true)
  }

  RegMember() {
    ; this.ActivateElWind()
    ; Send !{f12}kr
    this.PostMsg(923, true)
  }

  GoToEl(ElNumber, WinWait:=false) {
    this.ActivateElWind()
    Send ^g
    if (!WinWait) {
      Send % "{text}" . ElNumber
      Send {enter}
    } else {
      WinWaitActive, ahk_class TInputDlg
      ControlSetText, TMemo1, % ElNumber
      ControlSend, TMemo1, {Enter}
    }
  }
}
