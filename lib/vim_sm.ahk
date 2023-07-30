class VimSM {
  __New(Vim) {
    this.Vim := Vim
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
          this.EditFirstQuestion()
          if (!this.WaitTextFocus(1000))
            return false
          control := ControlGetFocus("ahk_class TElWind")
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
          this.EditFirstQuestion()
          if (!this.WaitTextFocus(1000))
            return false
          control := ControlGetFocus("ahk_class TElWind")
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
          this.EditFirstQuestion()
          if (!this.WaitTextFocus(1000))
            return false
          control := ControlGetFocus("ahk_class TElWind")
          ControlGetPos,,,, Height, % control, ahk_class TElWind
          ControlClick, % control, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
        }
      }
    }
    return true
  }

  IsEditingHTML() {
    return (WinActive("ahk_class TElWind") && IfContains(ControlGetFocus("A"), "Internet Explorer_Server"))
  }

  IsEditingPlainText() {
    return (WinActive("ahk_class TElWind") && IfContains(ControlGetFocus("A"), "TMemo,TRichEdit"))
  }

  IsEditingText() {
    return (WinActive("ahk_class TElWind") && IfContains(ControlGetFocus("A"), "Internet Explorer_Server,TMemo,TRichEdit"))
  }

  IsBrowsing() {
    return (WinActive("ahk_class TElWind") && !this.IsEditingText())
  }

  IsGrading() {
    CurrFocus := ControlGetFocus("A")
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
    return (WinActive("ahk_class TPlanDlg") && ControlGetFocus("A") == "TStringGrid1")
  }
 
  IsNavigatingTask() {
    return (WinActive("ahk_class TTaskManager") && ControlGetFocus("A") == "TStringGrid1")
  }

  IsNavigatingContentWindow() {
    return (WinActive("ahk_class TContents") && ControlGetFocus("A") == "TVirtualStringTree1")
  }

  IsNavigatingBrowser() {
    return (WinActive("ahk_class TBrowser") && ControlGetFocus("A") == "TStringGrid1")
  }

  SetRandPrio(min, max) {
    Prio := Random(min, max)
    global ImportGuiHwnd
    if (WinGet() == ImportGuiHwnd) {
      ControlFocus, Edit1, A
      ControlSetText, Edit1, % Prio, A
      send {tab}
    } else if (WinActive("Priority ahk_class #32770 ahk_exe AutoHotkey.exe")) {  ; input dialogue
      ControlSetText, Edit1, % Prio, A
    } else if (WinActive("ahk_class TPriorityDlg")) {  ; priority dialogue
      ControlSetText, TEdit5, % Prio, A
      ControlFocus, TEdit1, A
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
        ControlSetText, TEdit5, % Prio, ahk_class TPriorityDlg
        ControlSend, TEdit5, {enter}, ahk_class TPriorityDlg
      }
    } else if (WinExist("ahk_class TElWind") || ForceBG) {
      send {AltDown}
      PostMessage, 0x0104, 0x50, 1<<29,, ahk_class TElWind  ; P key
      PostMessage, 0x0105, 0x50, 1<<29,, ahk_class TElWind
      send {AltUp}
      WinWait, ahk_class TPriorityDlg
      ControlSetText, TEdit5, % Prio, ahk_class TPriorityDlg
      ControlSend, TEdit5, {enter}, ahk_class TPriorityDlg
    }
  }

  SetRandTaskVal(min, max) {
    ControlSetText, TEdit8, % random(min, max), A
    ControlFocus, TEdit7, A
    this.Vim.State.SetMode("Insert")
  }

  MoveAboveRef(RestoreClip:=true) {
    send ^{end}^+{up}  ; if there are references this would select (or deselect in visual mode) them all
    if (IfContains(copy(RestoreClip,, 1), "#SuperMemo Reference:")) {
      send {up 2}
    } else {
      send ^{end}
    }
  }

  ExitText(ReturnToComp:=false, timeout:=0) {
    ret := 1
    if (this.IsEditingText()) {
      if (this.IsItem()) {
        send ^t
        if (ReturnToComp)
          send !{f12}fl
        ret := 2
      }
      send {esc}
      if (!this.WaitTextExit(timeout))
        return 0
    }
    return ret
  }

  WaitTextExit(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (WinActive("ahk_class TElWind") && !this.IsEditingText()) {
        return true
      ; Choices because reference could update
      } else if (this.IsChangeRefWind() || (TimeOut && (A_TickCount - StartTime > TimeOut))) {
        return false
      }
    }
  }

  WaitTextFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingText()) {
        return true
      } else if (TimeOut && (A_TickCount - StartTime > TimeOut)) {
        return false
      }
    }
  }

  WaitHTMLFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingHTML()) {
        return true
      } else if (TimeOut && (A_TickCount - StartTime > TimeOut)) {
        return false
      }
    }
  }

  WaitClozeProcessing(timeout:=0) {
    this.MoveMouse(1)
    StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        break
      } else if (A_CaretX && this.WaitFileLoad(-1, "|Please wait", false)) {  ; prevent looping forever
        break
      } else if (TimeOut && (A_TickCount - StartTime > TimeOut)) {
        this.MoveMouse(2)
        return 0
      }
    }
    if (WinActive("ahk_class TMsgDialog")) {  ; warning on trying to cloze on items
      this.MoveMouse(2)
      return -1
    }
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(timeout, "|Please wait", false)
        sleep 200
        this.MoveMouse(2)
        return 1
      } else if (TimeOut && (A_TickCount - StartTime > TimeOut)) {
        this.MoveMouse(2)
        Return 0
      }
    }
  }

  WaitExtractProcessing(timeout:=0) {
    this.MoveMouse(1)
    StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        break
      } else if (A_CaretX && this.WaitFileLoad(-1, "|Loading file", false)) {  ; prevent looping forever
        break
      } else if (TimeOut && (A_TickCount - StartTime > TimeOut)) {
        this.MoveMouse(2)
        return false
      }
    }
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(timeout, "|Loading file", false)
        sleep 200
        this.MoveMouse(2)
        return true
      } else if (TimeOut && (A_TickCount - StartTime > TimeOut)) {
        this.MoveMouse(2)
        Return false
      }
    }
  }

  EnterInsertIfSpelling(timeout:=500) {
    StartTime := A_TickCount
    loop {
      sleep 100
      if (IfContains(ControlGetFocus("ahk_class TElWind"), "TMemo")) {
        this.Vim.State.SetMode("Insert")
        break
      } else if (TimeOut && (A_TickCount - StartTime > TimeOut)) {
        break
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

  PlayIfCertainColl(CollName:="", timeout:=0) {
    CollName := CollName ? CollName : this.GetCollName()
    if (CollName = "bgm")
      return
    if (this.IsPassive(CollName, -1)) {
      StartTime := A_TickCount
      if (ControlTextWait("TBitBtn3", "Next repetition", "ahk_class TElWind",,,, timeout)) {
        WinActivate, ahk_class TElWind
        this.AutoPlay()
        return true
      } else {
        return false
      }
    }
  }

  SaveHTML(SendEsc:=true, timeout:=0) {
    if (SendEsc && this.IsEditingHTML())
      this.ExitText(true, timeout)
    send ^+{f6}  ; opens notepad
    ; if (ReturnPath) {
    ;   WinWaitActive, ahk_class Notepad,, % timeout ? timeout / 1000 : ""
    ;   for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name='notepad.exe'")
    ;     ret := RegExReplace(process.CommandLine, """.*?"" ")
    ; } else {
      WinWaitNotActive, ahk_class TElWind,, % timeout ? timeout / 1000 : ""
      if (!ErrorLevel)
        ret := true
    ; }
    WinClose, ahk_class Notepad
    WinActivate, ahk_class TElWind
    return ret
  }

  GetCollName(text:="") {
    text := text ? text : WinGetText("ahk_class TElWind")
    RegExMatch(text, "m)^.+?(?= \(SuperMemo)", CollName)
    return CollName
  }

  GetCollPath(text:="") {
    text := text ? text : WinGetText("ahk_class TElWind")
    RegExMatch(text, "m)\(SuperMemo \d+: \K.+(?=\)$)", CollPath)
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

  GetFilePath(RestoreClip:=true) {
    this.ActivateElWind()
    global WinClip
    if (RestoreClip)
      ClipSaved := ClipboardAll
    WinClip.Clear()
    send !{f12}fc
    ClipWait
    path := Clipboard
    if (RestoreClip)
      Clipboard := ClipSaved
    return path
  }

  SetTitle(title:="", timeout:="") {
    if (WinGetTitle("ahk_class TElWind") == title)
      return true
    this.AltT()
    GroupAdd, SMAltT, ahk_class TChoicesDlg
    GroupAdd, SMAltT, ahk_class TTitleEdit
    WinWait, ahk_group SMAltT,, % timeout
    if (WinExist("ahk_class TChoicesDlg")) {
      if (!title)
        ControlFocus, TGroupButton2, ahk_class TChoicesDlg
      while (WinExist("ahk_class TChoicesDlg"))
        ControlClick, TBitBtn2, ahk_class TChoicesDlg,,,, NA
      if (title)
        WinWait, ahk_class TTitleEdit, % timeout
    }
    if (WinExist("ahk_class TTitleEdit")) {
      if (title)
        ControlSetText, TMemo1, % title, ahk_class TTitleEdit
      ControlSend, TMemo1, {enter}, ahk_class TTitleEdit
    }
  }

  GetCurrConcept() {
    return ControlGetText("TEdit1", "ahk_class TElWind")
  }

  IsPassive(CollName:="", CurrConcept:="") {
    CollName := CollName ? CollName : this.GetCollName()
    if CollName in passive,singing,piano,calligraphy,drawing,bgm,music
      return 2
    CurrConcept := CurrConcept ? CurrConcept : this.GetCurrConcept()
    if (CurrConcept == "Online")
      return 1
  }

  PostMsg(msg) {
    PostMessage, 0x0111, % msg,,, ahk_class TElWind
  }

  GetTemplCode(RestoreClip:=true) {
    this.ActivateElWind()
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global WinClip
    WinClip.Clear()
    send % this.IsBrowsing() ? "^c" : "!{f10}tc"
    ClipWait
    code := Clipboard
    if (RestoreClip)
      Clipboard := ClipSaved
    return code
  }

  MoveMouse(step, x:=0, y:=0) {
    static
    if (step == 1) {
      PrevCoordModeMouse := A_CoordModeMouse
      CoordMode, Mouse, Screen
      MouseGetPos, xSaved, ySaved
      MouseMove, % x, % y, 0
    } else if (step == 2) {
      MouseMove, xSaved, ySaved, 0
      CoordMode, Mouse, % PrevCoordModeMouse
    }
  }

  WaitFileLoad(timeout:=0, add:="", MoveMouse:=true) {  ; used for reloading or waiting for an element to load
    ; Move mouse because this function requires status bar text detection
    if (MoveMouse)
      this.MoveMouse(1)
    if (!WinGetText("ahk_class TStatBar"))
      this.PostMsg(313), StatBar := 0
    match := "^(\s+)?(Priority|Int|Downloading|\(\d+ item\(s\)" . add . ")"
    if (timeout == -1) {
      ret := (WinGetText("ahk_class TStatBar") ~= match)
    } else {
      StartTime := A_TickCount
      loop {
        while (WinExist("ahk_class Internet Explorer_TridentDlgFrame"))  ; sometimes could happen on YT videos
          WinClose
        if (WinGetText("ahk_class TStatBar") ~= match) {
          ret := true
          break
        } else if (timeout && (A_TickCount - StartTime > timeout)) {
          ret := false
          break
        }
      }
    }
    if (StatBar == 0)
      this.PostMsg(313)
    if (MoveMouse)
      this.MoveMouse(2)
    return ret
  }

  Learn(CtrlL:=true, EnterInsert:=false, AutoPlay:=false) {
    if (CtrlL) {
      this.PostMsg(180)
    } else if (ControlGetText("TBitBtn2", "ahk_class TElWind") == "Learn") {
      ControlSend, TBitBtn2, {enter}, ahk_class TElWind
    } else if (IfIn(ControlGetText("TBitBtn3", "ahk_class TElWind"), "Learn,Show answer,Next repetition", true)) {
      ControlSend, TBitBtn3, {enter}, ahk_class TElWind
    }
    if (EnterInsert)
      this.EnterInsertIfSpelling()
    if (AutoPlay)
      this.PlayIfCertainColl()
  }

  Reload(timeout:=0, ForceBackground:=false) {
    if (!ForceBackground && WinActive("ahk_class TElWind")) {
      send !{home}
      this.WaitFileLoad(timeout)
      send !{left}
    } else if (WinExist("ahk_class TElWind")) {
      send {AltDown}
      PostMessage, 0x0104, 0x24, 1<<29,, ahk_class TElWind  ; home key
      PostMessage, 0x0105, 0x24, 1<<29,, ahk_class TElWind
      this.WaitFileLoad(timeout)
      PostMessage, 0x0104, 0x25, 1<<29,, ahk_class TElWind  ; left arrow key
      PostMessage, 0x0105, 0x25, 1<<29,, ahk_class TElWind
      send {AltUp}
    }
  }

  IsCssClass(text) {
    if text in cloze,extract,clozed,hint,note,ignore,headers,RefText,reference,highlight,SearchHighlight,TableLabel,AntiMerge
      return true
  }

  ChangeDefaultConcept(concept:="", send:=0, CurrConcept:="", check:=true) {
    ; No need for changing if entered concept = current concept
    if (concept && check) {
      CurrConcept := CurrConcept ? CurrConcept : this.GetCurrConcept()
      if (CurrConcept = concept)
        return false
    }
    UIA := UIA_Interface()
    el := UIA.ElementFromHandle(WinExist("ahk_class TElWind"))
    pos := el.FindFirstBy("ControlType=Button AND Name='DefaultConceptBtn'").GetCurrentPos("screen")
    ControlClickScreen(pos.x, pos.y, "ahk_class TElWind")
    if (concept) {
      WinWait, ahk_class TRegistryForm
      ; send = 1 means must send
      ; send = -1 means must not send
      ; send = 0 means let string length decide
      ; ControlSend is faster when string length smaller than 20
      if ((send == 1) || ((send != -1) && (StrLen(concept) <= 20))) {
        ControlSend, Edit1, % "{text}" . concept, ahk_class TRegistryForm
      } else {
        ControlSetText, Edit1, % SubStr(concept, 2), ahk_class TRegistryForm
        ; Needed for updating the template; without {text},
        ; the first letter would not be in the correct case;
        ; which makes ControlTextWait() cannot pass
        ControlSend, Edit1, % "{text}" . SubStr(concept, 1, 1), ahk_class TRegistryForm
        ControlTextWait("Edit1", concept, "ahk_class TRegistryForm")
      }
      ControlSend, Edit1, {enter}, ahk_class TRegistryForm
      return true
    }
  }

  ClickElWindSourceBtn() {
    UIA := UIA_Interface()
    el := UIA.ElementFromHandle(WinExist("ahk_class TElWind"))
    pos := el.FindFirstBy("ControlType=Button AND Name='ReferenceBtn'").GetCurrentPos("screen")
    ControlClickScreen(pos.x, pos.y, "ahk_class TElWind")
  }

  ClickBrowserSourceButton() {
    ControlClickWinCoordDPIAdjusted(294, 45, "ahk_class TBrowser")
  }

  SetElParam(title:="", Prio:="", template:="", Submit:=true) {
    if (!title && !(prio >= 0) && !template) {
      return
    } else if (title && (prio >= 0) && !template) {
      this.SetPrio(prio,, true)
      this.SetTitle(title)
      return
    } else if (title && !(prio >= 0) && !template) {
      this.SetTitle(title)
      return
    } else if (!title && (prio >= 0) && !template) {
      this.SetPrio(prio,, true)
      return
    }
    if (!WinExist(w := "ahk_class TElParamDlg ahk_pid " . WinGet("PID", "ahk_class TElWind"))) {
      ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}, ahk_class TElWind
      ControlSend, ahk_parent, {shift down}{CtrlDown}p{CtrlUp}{shift up}, ahk_class TElWind
      WinWait, % w,, 0
      if (ErrorLevel) {
        ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}, ahk_class TElWind
        ControlSend, ahk_parent, {shift down}{CtrlDown}p{CtrlUp}{shift up}, ahk_class TElWind
        WinWait, % w,, 0
        if (ErrorLevel)
          return
      }
    }
    if (template) {
      ControlSetText, Edit1, % SubStr(template, 2), ahk_class TElParamDlg
      ControlSend, Edit1, % "{text}" . SubStr(template, 1, 1), ahk_class TElParamDlg
      this.WaitFileLoad()
    }
    if (title) {
      ControlSetText, TEdit2, % SubStr(title, 2), ahk_class TElParamDlg
      ControlSend, TEdit2, % "{text}" . SubStr(title, 1, 1), ahk_class TElParamDlg
    }
    if (Prio >= 0) {
      ControlSetText, TEdit1, % SubStr(Prio, 2), ahk_class TElParamDlg
      ControlSend, TEdit1, % "{text}" . SubStr(Prio, 1, 1), ahk_class TElParamDlg
    }
    if (Submit) {
      ControlFocus, TMemo1, ahk_class TElParamDlg  ; needed, otherwise the window won't close sometimes
      while (WinExist(w))
        ControlSend, TMemo1, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{enter}, ahk_class TElParamDlg
    }
  }

  IsChangeRefWind() {
    if (WinActive("ahk_class TChoicesDlg")) {
      return ((ControlGetText("TGroupButton1") == "Cancel (i.e. restore the old version of references)")
           && (ControlGetText("TGroupButton2") == "Combine old and new references for this element")
           && (ControlGetText("TGroupButton3") == "Change references in all elements produced from the original article")
           && (ControlGetText("TGroupButton4") == "Change only the references of the currently displayed element"))
    }
  }

  CheckDup(text, ClearHighlight:=true) {  ; try to find duplicates
    ContLearn := this.IsLearning()
    text := LTrim(text)
    text := RegExReplace(text, "^file:\/\/\/")  ; SuperMemo converts file:/// to file://
    ; Can't just encode URI, Chinese characters will be encoded
    ; For some reason, SuperMemo only encodes some part of the url
    if (IsUrl(text))
      text := StrReplace(text, "%20", " "), text := StrReplace(text, "%3F", "?"), text := StrReplace(text, "%27", "'"), text := StrReplace(text, "%21", "!")
    ret := this.CtrlF(text, ClearHighlight, "No duplicates found.")
    if ((ContLearn == 1) && !ret)
      this.Learn()
    return ret
  }

  CtrlF(text, ClearHighlight:=true, ToolTip:="Not found.") {
    while (WinExist("ahk_class TBrowser") || WinExist("ahk_class TMsgDialog"))
      WinClose
    this.PostMsg(144)
    WinWait, ahk_class TMyFindDlg
    ControlSetText, TEdit1, % text, ahk_class TMyFindDlg
    ControlFocus, TEdit1, ahk_class TMyFindDlg
    ControlSend, TEdit1, {enter}, ahk_class TMyFindDlg
    GroupAdd, SMCtrlF, ahk_class TMsgDialog
    GroupAdd, SMCtrlF, ahk_class TBrowser
    WinWait, ahk_group SMCtrlF
    if (ret := WinExist("ahk_class TBrowser")) {
      if (ClearHighlight)
        this.ClearHighlight()
      WinActivate, ahk_class TBrowser
    } else if (WinExist("ahk_class TMsgDialog")) {
      while (WinExist("ahk_class TMsgDialog"))
        WinClose
      ToolTip(ToolTip,, -3000)
      if (ClearHighlight)
        this.ClearHighlight()
    }
    return ret
  }

  ClearHighlight(OpenCommander:=true) {
    this.Command("h", OpenCommander)
  }

  Command(text, OpenCommander:=true) {
    if (OpenCommander)
      this.PostMsg(240)  ; open commander
    WinWait, ahk_class TCommanderDlg
    if (text) {
      ControlSetText, TEdit2, % text, ahk_class TCommanderDlg
      ControlTextWait("TEdit2", text, "ahk_class TCommanderDlg")
    }
    while (WinExist(w := "ahk_class TCommanderDlg ahk_pid " . WinGet("PID", "ahk_class TElWind")))
      ControlClick, TButton4, % w,,,, NA
  }

  MakeReference(html:=false) {
    break := html ? "<br>" : "`n"
    text := "#SuperMemo Reference:"
    if (this.Vim.Browser.url)
      text .= break . "#Link: " . this.Vim.Browser.url
    if (this.Vim.Browser.title)
      text .= break . "#Title: " . this.Vim.Browser.title
    if (this.Vim.Browser.source)
      text .= break . "#Source: " . this.Vim.Browser.source
    if (this.Vim.Browser.author)
      text .= break . "#Author: " . this.Vim.Browser.author
    if (this.Vim.Browser.date)
      text .= break . "#Date: " . this.Vim.Browser.date
    if (this.Vim.Browser.comment)
      text .= break . "#Comment: " . this.Vim.Browser.comment
    return text
  }

  HandleF3(step) {
    if (step == 1) {
      send {f3}
      WinWaitActive, ahk_class TMyFindDlg,, 1
      if (ErrorLevel) {  ; SM goes to the next found without opening find dialogue
        this.ClearHighlight()  ; clears highlight so it opens find dialogue
        ControlSend,, {f3}, ahk_class TElWind
        WinWaitActive, ahk_class TMyFindDlg,, 3.5
        if (ErrorLevel) {
          ToolTip("F3 window cannot be launched.")
          return false
        }
      }
      return true
    } else if (step == 2) {
      send ^{enter}  ; open commander; convienently, if a "not found" window pops up, this would close it
      GroupAdd, SMF3, ahk_class TMyFindDlg
      GroupAdd, SMF3, ahk_class TCommanderDlg
      WinWaitActive, ahk_group SMF3
      if (WinGetClass("") == "TMyFindDlg") {  ; ^enter closed "not found" window
        WinClose
        this.ClearHighlight()
        send {esc}
        this.Vim.State.SetNormal()
        ToolTip("Text not found.")
        return false
      }
      this.ClearHighlight(false)
      WinClose, ahk_class TMyFindDlg
      sleep -1
      this.Vim.Caret.SwitchToSameWindow("ahk_class TElWind")
      return true
    }
  }

  GoToTopIfLearning(LearningState:=0) {
    if ((!LearningState && this.IsLearning())
     || (LearningState && (this.IsLearning() == LearningState)))
      this.GoToFirstEl()
  }

  GoToFirstEl() {
    if (WinActive("ahk_class TElWind")) {
      send !{home}
    } else if (WinExist("ahk_class TElWind")) {
      send {AltDown}
      PostMessage, 0x0104, 0x24, 1<<29,, ahk_class TElWind  ; home key
      PostMessage, 0x0105, 0x24, 1<<29,, ahk_class TElWind
      send {AltUp}
    }
  }

  AutoPlay() {
    ToolTip(WinGetTitle("ahk_class TElWind"),, -4000, "center")
    send ^{f10}
  }

  AltT() {
    this.PostMsg(116)
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
        try run % url
        catch
          return false
        if (v) {
          WinWaitActive, ahk_group Browser
          uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
          uiaBrowser.SetUrl(v, true)
        }
      }
    }
    return true
  }

  EditFirstQuestion() {
    this.PostMsg(118)
  }

  EditFirstAnswer() {
    this.PostMsg(119)
  }

  EditAll() {
    this.PostMsg(120)
  }

  EditRef() {
    this.ActivateElWind()
    send !{f10}fe
  }

  GoBack() {
    if (WinActive("ahk_class TElWind")) {
      send !{left}
    } else if (WinExist("ahk_class TElWind")) {
      send {AltDown}
      PostMessage, 0x0104, 0x25, 1<<29,, ahk_class TElWind  ; left arrow key
      PostMessage, 0x0105, 0x25, 1<<29,, ahk_class TElWind
      send {AltUp}
    }
  }

  AltN() {
    this.PostMsg(98)
  }

  CtrlN() {
    this.PostMsg(96)
  }

  AltA() {
    this.PostMsg(95)
  }

  WaitBrowser(timeout:=1) {
    WinWaitActive, ahk_class TProgressBox,, % timeout
    if (!ErrorLevel)
      WinWaitNotActive, ahk_class TProgressBox
    WinWaitActive, ahk_class TBrowser
  }

  InvokeFileBrowser() {
    if (!WinActive("ahk_class TElWind"))
      WinActivate
    send {CtrlDown}ttq{CtrlUp}
    GroupAdd, SMCtrlQ, ahk_class TFileBrowser
    GroupAdd, SMCtrlQ, ahk_class TMsgDialog
    WinWaitActive, ahk_group SMCtrlQ
    while (!WinActive("ahk_class TFileBrowser")) {
      while (WinActive("ahk_class TMsgDialog"))
        send {text}n  ; Directory not found; Create?
      WinWaitActive, ahk_group SMCtrlQ
    }
  }

  SpamQ(SpamInterval:=20, timeout:=0) {
    loop {
      this.EditFirstQuestion()
      if (SpamInterval && this.WaitTextFocus(SpamInterval)) {
        return true
      } else if (!SpamInterval && this.IsEditingText()) {
        return true
      } else if (TimeOut && (A_TickCount - StartTime > TimeOut)) {
        return false
      }
    }
  }

  IsItem() {
    return ((ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind") && ControlGet(,, "Internet Explorer_Server1", "ahk_class TElWind"))
         || (ControlGet(,, "TMemo2", "ahk_class TElWind") && ControlGet(,, "TMemo1", "ahk_class TElWind")))
  }

  RandCtrlJ(min, max) {
    send % "^j" . Random(min, max) . "{enter 2}"
    this.Vim.State.SetNormal()
  }

  ActivateElWind() {
    if (!WinActive("ahk_class TElWind"))
      WinActivate
  }

  RefToClipForTopic() {
    global CollName
    if (!IfContains(this.Vim.Browser.Url, "youtube.com/playlist"))
      add := (CollName = "bgm") ? this.Vim.Browser.Url . "`n" : ""
    Clipboard := add . this.MakeReference()
  }
}