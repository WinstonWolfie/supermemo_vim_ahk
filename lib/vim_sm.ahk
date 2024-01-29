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
          ControlGetPos,,,, Height, % control, ahk_class TElWind
          ControlClick, % control, ahk_class TElWind,,,, NA x1 y1
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
          ControlGetPos,,,, Height, % control, ahk_class TElWind
          ControlClick, % control, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
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
          ControlGetPos,,,, Height, % control, ahk_class TElWind
          ControlClick, % control, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
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
    return (WinExist("ahk_class TElWind") && !IfContains(ControlGetFocus("ahk_class TElWind"), "Internet Explorer_Server,TMemo,TRichEdit"))
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
    return (WinActive("ahk_class TPlanDlg") && (ControlGetFocus("A") == "TStringGrid1"))
  }

  IsNavigatingTask() {
    return (WinActive("ahk_class TTaskManager") && (ControlGetFocus("A") == "TStringGrid1"))
  }

  IsNavigatingContentWindow() {
    return (WinActive("ahk_class TContents") && (ControlGetFocus("A") == "TVirtualStringTree1"))
  }

  IsNavigatingBrowser() {
    return (WinActive("ahk_class TBrowser") && (ControlGetFocus("A") == "TStringGrid1"))
  }

  SetRandPrio(min, max) {
    Prio := Random(min, max)
    global ImportGuiHwnd
    if (WinActive("A") == ImportGuiHwnd) {
      ControlFocus, Edit1
      ControlSetText, Edit1, % Prio
      send {tab}
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
      send !p  ; open priority window
      if (!WinWait) {
        send % Prio . "{enter}"
      } else {
        WinWaitActive, ahk_class TPriorityDlg
        ControlSetText, TEdit5, % Prio
        ControlSend, TEdit5, {enter}
      }
    } else if (WinExist("ahk_class TElWind") || ForceBG) {
      send {Alt Down}
      PostMessage, 0x0104, 0x50, 1<<29,, ahk_class TElWind  ; P key
      PostMessage, 0x0105, 0x50, 1<<29,, ahk_class TElWind
      send {Alt Up}
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
    send ^{end}^+{up}  ; if there are references this would select (or deselect in visual mode) them all
    if (IfContains(Copy(RestoreClip), "#SuperMemo Reference:")) {
      send {up 2}
    } else {
      send ^{end}
    }
  }

  MoveToLast(RestoreClip:=true) {
    send ^{end}^+{up}  ; if there are references this would select (or deselect in visual mode) them all
    if (InStr(Copy(RestoreClip), "#SuperMemo Reference:")) {
      send {up}{left}
    } else {
      send ^{end}
    }
  }

  ExitText(ReturnToComp:=false, Timeout:=0) {
    this.ActivateElWind(), ret := 1
    if (this.IsEditingText()) {
      if (this.HasTwoComp()) {
        send !{f12}fl
        if (ReturnToComp)
          send ^t
        ret := 2
      }
      send {esc}
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
      } else if (this.IsVimNavWind() || (Timeout && (A_TickCount - StartTime > Timeout))) {
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
    this.PrepareStatBar(1)
    StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        Break
      } else if (A_CaretX && this.WaitFileLoad(-1, "|Please wait", false)) {  ; prevent looping forever
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepareStatBar(2)
        return 0
      }
    }
    if (WinActive("ahk_class TMsgDialog")) {  ; warning on trying to cloze on items
      this.PrepareStatBar(2)
      return -1
    }
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(Timeout, "|Please wait", false)
        sleep 200
        this.PrepareStatBar(2)
        return 1
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepareStatBar(2)
        Return 0
      }
    }
  }

  WaitExtractProcessing(Timeout:=0) {
    this.PrepareStatBar(1)
    StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        Break
      } else if (A_CaretX && this.WaitFileLoad(-1, "|Loading file", false)) {  ; prevent looping forever
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepareStatBar(2)
        return false
      }
    }
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(Timeout, "|Loading file", false)
        sleep 200
        this.PrepareStatBar(2)
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepareStatBar(2)
        Return false
      }
    }
  }

  EnterInsertIfSpelling(Timeout:=500) {
    StartTime := A_TickCount
    loop {
      sleep 100
      if (IfContains(ControlGetFocus("ahk_class TElWind"), "TMemo")) {
        this.Vim.State.SetMode("Insert")
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        Break
      }
    }
  }

  IsLearning() {
    CurrText := ControlGetText("TBitBtn3", "ahk_class TElWind")
    if (CurrText == "Next repetition") {
      return 2
    } else if (CurrText == "Show answer") {
      return 1
    }
  }

  PlayIfPassiveColl(CollName:="", Timeout:=0) {
    CollName := CollName ? CollName : this.GetCollName()
    if (CollName ~= "i)^(bgm|piano)$")
      return
    if (this.IsPassive(CollName, -1)) {
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
    RegExMatch(TemplCode, "(?<=#Link: <a href="").*?(?="")", ret)
    if (res)
      Clipboard := ClipSaved
    return ret
  }

  GetLinkInComment(TemplCode:="", RestoreClip:=true) {
    if (res := (RestoreClip && !TemplCode)) {
      ClipSaved := ClipboardAll
      global WinClip
      WinClip.Clear()
    }
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode(false)
    RegExMatch(TemplCode, "(?<=#Comment: ).*?(?=<\/FONT><\/SuperMemoReference>)", Comment)
    DoesTextContainUrl(Comment, v)
    if (res)
      Clipboard := ClipSaved
    return v
  }

  GetFilePath(RestoreClip:=true) {
    this.ActivateElWind()
    return Copy(RestoreClip,, "!{f12}fc")
  }

  LoopForFilePath(RestoreClip:=true, MaxLoop:=5) {
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
    SMCurrTitle := WinGetTitle("ahk_class TElWind")
    if (SMCurrTitle == title)
      return true
    Timeout := Timeout ? Timeout / 1000 : Timeout
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
  }

  GetCurrConcept() {
    return ControlGetText("TEdit1", "ahk_class TElWind")
  }

  IsPassive(CollName:="", CurrConcept:="") {
    CollName := CollName ? CollName : this.GetCollName()
    if (IfIn(CollName, "passive,singing,piano,calligraphy,drawing,bgm,music"))
      return 2
    CurrConcept := CurrConcept ? CurrConcept : this.GetCurrConcept()
    if (IfIn(CurrConcept, "Online,Source"))
      return 1
  }

  PostMsg(Msg) {
    wSMElWind := "ahk_class TElWind"
    WinGet, paSMTitles, List, ahk_class TElWind
    loop % paSMTitles {
      pidSM := WinGet("PID", "ahk_id " . hWnd := paSMTitles%A_Index%)
      if (WinExist("ahk_class TProgressBox ahk_pid " . pidSM)) {
        Continue
      } else {
        WindFound := true, wSMElWind := "ahk_id " . hWnd
        Break
      }
    }
    if (!WindFound) {
      MsgBox, 3,, SuperMemo is processing something. Do you want to launch a new window?
      if (IfMsgbox("Yes")) {
        ShellRun("C:\SuperMemo\sm19.exe")
        WinWaitActive, ahk_class TElWind
      } else {
        return
      }
    }
    PostMessage, 0x0111, % Msg,,, % wSMElWind
    return true
  }

  GetTemplCode(RestoreClip:=true, wSMElWind:="") {
    this.ActivateElWind(wSMElWind)
    return Copy(RestoreClip,, this.IsEditingText() ? "!{f10}tc" : "^c")
  }

  PrepareStatBar(step, x:=0, y:=0) {
    static
    RestoreStatBar := false
    if (step == 1) {
      if (!WinGetText("ahk_class TStatBar"))
        this.PostMsg(313), RestoreStatBar := true
      PrevCoordModeMouse := A_CoordModeMouse
      CoordMode, Mouse, Screen
      MouseGetPos, xSaved, ySaved
      MouseMove, % x, % y, 0
    } else if (step == 2) {
      MouseMove, xSaved, ySaved, 0
      CoordMode, Mouse, % PrevCoordModeMouse
      if (RestoreStatBar)
        this.PostMsg(313)
    }
  }

  WaitFileLoad(Timeout:=0, add:="", PrepareStatBar:=true) {  ; used for reloading or waiting for an element to load
    ; Move mouse because this function requires status bar text detection
    if (PrepareStatBar)
      this.PrepareStatBar(1)
    match := "^(\s+)?(Priority|Int|Downloading|\(\d+ item\(s\)" . add . ")"
    if (Timeout == -1) {
      ret := (WinGetText("ahk_class TStatBar") ~= match)
    } else {
      StartTime := A_TickCount
      loop {
        while (WinExist("ahk_class Internet Explorer_TridentDlgFrame"))  ; sometimes could happen on YT videos
          WinClose
        if (WinGetText("ahk_class TStatBar") ~= match) {
          ret := true
          Break
        } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
          ret := false
          Break
        }
      }
    }
    if (PrepareStatBar)
      this.PrepareStatBar(2)
    return ret
  }

  Learn(CtrlL:=true, EnterInsert:=false, AutoPlay:=false) {
    this.ActivateElWind()
    if (CtrlL) {
      if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
        this.PostMsg(178)
      } else {
        this.PostMsg(180)
      }
    } else if (ControlGetText("TBitBtn2", "ahk_class TElWind") == "Learn") {
      ControlSend, TBitBtn2, {enter}, ahk_class TElWind
    } else if (IfIn(ControlGetText("TBitBtn3", "ahk_class TElWind"), "Learn,Show answer,Next repetition", true)) {
      ControlSend, TBitBtn3, {enter}, ahk_class TElWind
    }
    if (EnterInsert)
      this.EnterInsertIfSpelling()
    if (AutoPlay)
      this.PlayIfPassiveColl()
  }

  Reload(Timeout:=0, ForceBG:=false) {
    if (!ForceBG && WinActive("ahk_class TElWind")) {
      Critical
      this.GoHome()
      this.WaitFileLoad(Timeout)
      this.GoBack()
    } else if (WinExist("ahk_class TElWind")) {
      send {Alt Down}
      PostMessage, 0x0104, 0x24, 1<<29,, ahk_class TElWind  ; home key
      PostMessage, 0x0105, 0x24, 1<<29,, ahk_class TElWind
      this.WaitFileLoad(Timeout)
      PostMessage, 0x0104, 0x25, 1<<29,, ahk_class TElWind  ; left arrow key
      PostMessage, 0x0105, 0x25, 1<<29,, ahk_class TElWind
      send {Alt Up}
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
    if (!Title && !(Prio >= 0) && !Template && !Group) {
      return
    } else if (Title && (Prio >= 0) && !Template && !Group) {
      this.SetPrio(Prio,, true)
      this.SetTitle(Title)
      return
    } else if (Title && !(Prio >= 0) && !Template && !Group) {
      this.SetTitle(Title)
      return
    } else if (!Title && (Prio >= 0) && !Template && !Group) {
      this.SetPrio(Prio,, true)
      return
    }
    if (!WinExist(w := "ahk_class TElParamDlg ahk_pid " . WinGet("PID", "ahk_class TElWind"))) {
      ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Shift Down}{Ctrl Down}p{Ctrl Up}{Shift Up}, ahk_class TElWind
      WinWait, % w,, 1.5
      if (ErrorLevel) {
        ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Shift Down}{Ctrl Down}p{Ctrl Up}{Shift Up}, ahk_class TElWind
        WinWait, % w,, 1.5
        if (ErrorLevel)
          return
      }
    }
    if (Template && (ControlGetText("Edit1") != Template)) {
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
    if (Group && (ControlGetText("Edit2") != Group)) {
      ControlSetText, Edit2, % SubStr(Group, 2)
      ControlSend, Edit2, % "{text}" . SubStr(Group, 1, 1)
    }
    if (Submit) {
      ControlFocus, TMemo1  ; needed, otherwise the window won't close sometimes
      while (WinExist(w))
        ControlSend, TMemo1, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{enter}
    }
  }

  IsVimNavWind() {
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

  CheckDup(text, ClearHighlight:=true) {  ; try to find duplicates
    pidSM := WinGet("PID", "ahk_class TElWind")
    while (WinExist("ahk_class TMsgDialog ahk_pid " . pidSM)
        || WinExist("ahk_class TBrowser ahk_pid " . pidSM))
      WinClose
    ContLearn := this.IsLearning(), text := LTrim(text)
    text := RegExReplace(text, "^file:\/\/\/")  ; SuperMemo converts file:/// to file://
    if (IsUrl(text))
      text := this.HTMLUrl2SMRefUrl(text)
    ret := this.CtrlF(text, ClearHighlight, "No duplicates found.")
    if ((ContLearn == 1) && this.LastCtrlFNotFound)
      this.Learn()
    return ret
  }

  HTMLUrl2SMRefUrl(url) {
    ; Can't just encode URI, Chinese characters will also be encoded
    ; For some reason, SuperMemo only encodes some part of the url
    ; Probably because of SuperMemo uses a lower version of IE?
    url := StrReplace(url, "%20", " ")
    url := StrReplace(url, "%21", "!")
    url := StrReplace(url, "%22", """")
    url := StrReplace(url, "%23", "#")
    url := StrReplace(url, "%24", "$")
    url := StrReplace(url, "%25", "%")
    url := StrReplace(url, "%26", "&")
    url := StrReplace(url, "%27", "'")
    url := StrReplace(url, "%28", "(")
    url := StrReplace(url, "%29", ")")
    url := StrReplace(url, "%2A", "*")
    url := StrReplace(url, "%2B", "+")
    url := StrReplace(url, "%2C", ",")
    url := StrReplace(url, "%2D", "-")
    url := StrReplace(url, "%2E", ".")
    url := StrReplace(url, "%2F", "/")
    url := StrReplace(url, "%3A", ":")
    url := StrReplace(url, "%3B", ";")
    url := StrReplace(url, "%3C", "<")
    url := StrReplace(url, "%3D", "=")
    url := StrReplace(url, "%3E", ">")
    url := StrReplace(url, "%3F", "?")
    url := StrReplace(url, "%40", "@")
    url := StrReplace(url, "%5B", "[")
    url := StrReplace(url, "%5C", "\")
    url := StrReplace(url, "%5D", "]")
    url := StrReplace(url, "%5E", "^")
    url := StrReplace(url, "%5F", "_")
    url := StrReplace(url, "%60", "`")
    url := StrReplace(url, "%7B", "{")
    url := StrReplace(url, "%7C", "|")
    url := StrReplace(url, "%7D", "}")
    url := StrReplace(url, "%7E", "~")
    if (IfContains(url, "youtube.com/watch?v="))  ; sm19 deletes www from www.youtube.com
      url := StrReplace(url, "www.")
    return url
  }

  CtrlF(text, ClearHighlight:=true, ToolTip:="Not found.") {
    this.LastCtrlFNotFound := false
    if (!WinExist("ahk_class TElWind"))
      return
    this.CloseMsgWind()
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      ret := this.PostMsg(143)
    } else {
      ret := this.PostMsg(144)
    }
    if (!ret)
      return false
    WinWait, % "ahk_class TMyFindDlg ahk_pid " . pidSM := WinGet("PID", "ahk_class TElWind")
    ControlSetText, TEdit1, % text
    ControlFocus, TEdit1
    ControlSend, TEdit1, {enter}
    GroupAdd, SMCtrlF, ahk_class TMsgDialog
    GroupAdd, SMCtrlF, ahk_class TBrowser
    WinWait, % "ahk_group SMCtrlF ahk_pid " . pidSM
    if (ret := (WinGetClass() == "TBrowser")) {  ; window from the last WinWait
      if (ClearHighlight)
        this.ClearHighlight()
      WinActivate, % "ahk_class TBrowser ahk_pid " . pidSM
    } else if (WinGetClass() == "TMsgDialog") {
      this.LastCtrlFNotFound := true
      WinClose
      ToolTip(ToolTip,, -3000)
      if (ClearHighlight)
        this.ClearHighlight()
    }
    return ret
  }

  ClearHighlight() {
    return this.Command("h")
  }

  Command(text) {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      ret := this.PostMsg(238)
    } else {
      ret := this.PostMsg(240)
    }
    if (!ret)
      return false
    WinWait, % "ahk_class TCommanderDlg ahk_pid " . pidSM := WinGet("PID", "ahk_class TElWind")
    if (text) {
      ControlSetText, TEdit2, % text
      ControlTextWait("TEdit2", text, "")
    }
    while (WinExist("ahk_class TCommanderDlg ahk_pid " . pidSM)) {
      ControlClick, TButton4,,,,, NA
      if (WinExist("ahk_class #32770 ahk_pid " . pidSM))
        ControlSend,, {esc}
    }
    return true
  }

  MakeReference(html:=false) {
    Break := html ? "<br>" : "`n"
    text := "#SuperMemo Reference:"
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
          ToolTip("F3 window cannot be launched.")
          return false
        }
      }
      return true
    } else if (step == 2) {
      send ^{enter}  ; open commander; convienently, if a "not found" window pops up, this would close it
      WinWait, % "ahk_class TMyFindDlg ahk_pid " . WinGet("PID", "ahk_class TElWind"),, 0.3  ; sometimes TMyFindDlg will still pop up
      GroupAdd, SMF3, ahk_class TMyFindDlg
      GroupAdd, SMF3, ahk_class TCommanderDlg
      WinWaitActive, ahk_group SMF3
      if (WinGetClass() == "TMyFindDlg") {  ; ^enter closed "not found" window
        WinClose
        this.ClearHighlight()
        send {esc}
        this.Vim.State.SetNormal(), ToolTip("Text not found.")
        return false
      } else if (WinGetClass() == "TCommanderDlg") {  ; ^enter opened commander
        send {text}h  ; clear highlight
        send {enter}
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
      send !{home}
    } else if (ForceBG || WinExist("ahk_class TElWind")) {
      send {Alt Down}
      PostMessage, 0x0104, 0x24, 1<<29  ; home key
      PostMessage, 0x0105, 0x24, 1<<29
      send {Alt Up}
    }
  }

  GoBack(ForceBG:=false) {
    if (!ForceBG && WinActive("ahk_class TElWind")) {
      send !{left}
    } else if (ForceBG || WinExist("ahk_class TElWind")) {
      send {Alt Down}
      PostMessage, 0x0104, 0x25, 1<<29  ; left arrow key
      PostMessage, 0x0105, 0x25, 1<<29
      send {Alt Up}
    }
  }

  AutoPlay() {
    ToolTip := "Running: `n`nTitle: " . WinGetTitle("ahk_class TElWind")
    Marker := this.GetMarkerFromHTMLAllText(this.GetHTMLAllText())
    if (Marker ~= "^SMVim(?!:)")
      ToolTip .= "`n" . StrUpper(SubStr(Marker, 7, 1)) . SubStr(Marker, 8)
    ToolTip(ToolTip,, -5000, "center")
    if (WinGetTitle("ahk_class TElWind") == "Netflix") {
      ShellRun(this.GetLink())
    } else if (Marker == "SMVim: Use online video progress") {
      Gosub SearchLinkInYT
    } else {
      send ^{f10}
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

  RunLink(url, RunInIE:=false) {
    if (RegExMatch(url, "SuperMemoElementNo=\(\K\d+", v)) {  ; goes to a SuperMemo element
      send % "^g" . v . "{enter}"
    } else {
      if (RunInIE) {
        this.Vim.Browser.RunInIE(url)
      } else {
        if ((url ~= "file:\/\/") && (url ~= "#.*"))
          v := url, url := RegExReplace(url, "#.*")
        try ShellRun(url)
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
    this.ActivateElWind()
    send !{f10}fe
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
    send {Ctrl Down}ttq{Ctrl Up}
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
    send % "^j" . Random(min, max) . "{enter 2}"
    this.Vim.State.SetNormal()
  }

  ActivateElWind(wSMElWind:="") {
    wSMElWind := wSMElWind ? wSMElWind : "ahk_class TElWind"
    if (!WinActive(wSMElWind))
      WinActivate, % wSMElWind
  }

  RefToClipForTopic(UseOnlineProgress:=false) {
    if (UseOnlineProgress)
      add := "<SPAN class=Highlight>SMVim</SPAN>: Use online video progress<br>"
    Clipboard := add . this.MakeReference(true)
  }

  DoesHTMLContainText(byref link) {
    this.ActivateElWind()
    UIA := UIA_Interface(), hCtrl := ControlGet(,, "Internet Explorer_Server1", "A")
    el := UIA.ElementFromHandle(hCtrl)
    text := el.FindFirstByType("text")
    link := el.FindFirstByType("Hyperlink").Value
    return !(text.Name == "#SuperMemo Reference:")
  }

  IsEmptyTopic(byref link) {
    return (!this.HasTwoComp() && this.DoesTextExist() && !this.DoesHTMLContainText(link))
  }

  AskPrio() {
    this.ActivateElWind()
    if ((!Prio := InputBox("Priority", "Enter priority.")) || ErrorLevel)
      return
    if (Prio) {
      if (Prio ~= "^\.")
        Prio := "0" . Prio
      this.SetPrio(Prio,, true)
      return true
    }
  }

  CloseMsgWind() {
    while (WinExist("ahk_class TMsgDialog ahk_pid " . WinGet("PID", "ahk_class TElWind")))
      WinClose
  }

  OpenNotepad(Timeout:=0) {
    this.ExitText(true, Timeout)
    send ^+{f6}
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
    UIA := UIA_Interface()
    el := UIA.ElementFromHandle(WinActive("A"))
    el.FindFirstBy("ControlType=TabItem AND Name='Edit'").ControlClick()
    el.WaitElementExist("ControlType=ToolBar AND Name='Format'").FindByPath(n).ControlClick()
    el.FindFirstBy("ControlType=TabItem AND Name='Learn'").ControlClick()
    this.Vim.Caret.SwitchToSameWindow()
  }

  PasteHTML(SleepInterval:=1) {
    this.ActivateElWind()
    send {AppsKey}xp  ; Paste HTML
    while (DllCall("GetOpenClipboardWindow"))
      sleep % SleepInterval
    WinWaitNotActive, ahk_class TElWind,, 0.3
    WinWaitActive, ahk_class TElWind
  }

  HandleSM19PoundSymbUrl(url) {
    if ((WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") && IfContains(url, "#")) {
      pidSM := WinGet("PID", "ahk_class TElWind")
      this.PostMsg(154), ShortUrl := RegExReplace(url, "#.*")
      WinWait, % "ahk_class TRegistryForm ahk_pid " . pidSM
      ControlSetText, Edit1, % SubStr(ShortUrl, 2)
      ControlSend, Edit1, % "{text}" . SubStr(ShortUrl, 1, 1)
      Acc_Get("Object", "4.5.4.6.4").accDoDefaultAction()
      WinWait, % "ahk_class TInputDlg ahk_pid " . pidSM
      if (ControlGetText("TMemo1") == ShortUrl)
        ControlSetText, TMemo1, % url
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
    loop {
      send !{f12}kd  ; delete registry link
      WinWaitActive, ahk_class TMsgDialog,, 0.2
      if (!ErrorLevel) {
        send {enter}
        WinWaitClose
        Break
      }
    }
  }

  OpenBrowser() {
    ; Sometimes a bug makes that you can't use ^space to open browser in content window
    ; After a while, I found out it's due to my Chinese input method
    SetDefaultKeyboard(0x0409)  ; English-US
    send ^{space}  ; open browser
  }

  MatchLink(SMLink, url) {
    url := this.HTMLUrl2SMRefUrl(url)
    if (IfContains(url, "britannica.com")) {
      return IfContains(url, SMLink)
    } else {
      return (SMLink == url)
    }
  }

  GetHTMLMarker() {
    return this.GetMarkerFromHTMLAllText(this.GetHTMLAllText())
  }

  GetHTMLAllText() {
    this.ActivateElWind()
    UIA := UIA_Interface(), hCtrl := ControlGet(,, "Internet Explorer_Server1", "A")
    return UIA.ElementFromHandle(hCtrl).FindAllByType("text")
  }

  GetLinkFromHTMLAllText(auiaText) {
    for i, v in auiaText {
      if (v.Name == "#Link: ") {
        return v.FindByPath("+1").Name
      }
    }
  }

  GetMarkerFromHTMLAllText(auiaText) {
    for i, v in auiaText {
      if ((A_Index == 1) && (v.Name ~= "^SMVim .*")) {
        Marker := v.Name
        Continue
      } else if ((A_Index == 2) && Marker) {
        Marker .= v.Name
        Break
      } else {
        return
      }
    }
    return Marker
  }

  IsCompMarker(text) {
    if (RegExMatch(text, "^SMVim (.*?):", v)) {
      return v1
    } else {
      return false
    }
  }

  ListLinks() {
    this.ActivateElWind()
    send !{f10}cs
  }

  LinkConcept(Concept:="") {
    this.ActivateElWind()
    send !{f10}cl
    if (Concept) {
      WinWaitActive, ahk_class TRegistryForm
      ControlSend, Edit1, % "{text}" . Concept
      ControlSend, Edit1, {enter}
    }
  }

  Cloze() {
    this.ActivateElWind()
    send !z
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
}
