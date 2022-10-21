class VimSM {
  __New(Vim) {
    this.Vim := Vim
    ; this.ClearUp := ObjBindMethod(this, "ClearUp")
  }

  ClickTop() {
    if (this.IsEditingText()) {
      ControlClick, % ControlGetFocus(), ahk_class TElWind,,,, NA x1 y1
    } else {
      ; server2 because question field of items are server2
      if (ControlGet("",, "Internet Explorer_Server2", "ahk_class TElWind")) {  ; item
        ControlClick, Internet Explorer_Server2, ahk_class TElWind,,,, NA x1 y1
      } else {  ; topic
        ; Article field in topics is server1
        if (ControlGet("",, "Internet Explorer_Server1", "ahk_class TElWind")) {  ; topic found
          ControlClick, Internet Explorer_Server1, ahk_class TElWind,,,, NA x1 y1
        } else {  ; no html field found
          if (ControlGet("",, "TMemo1", "ahk_class TElWind")) {  ; plain text item
            ControlClick, TMemo1, ahk_class TElWind,,,, NA x1 y1
          } else {  ; no text
            send q
            return false
          }
        }
      }
    }
  }

  ClickMid() {
    if (this.IsEditingText()) {
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
          ControlGetPos,,,, Height, TMemo1, ahk_class TElWind
          if (Height) {  ; plain text item
            ControlClick, TMemo1, ahk_class TElWind,,,, % "NA x1 y" . Height / 2
          } else {  ; no text
            send q
            return false
          }
        }
      }
    }
  }

  ClickBottom() {
    if (this.IsEditingText()) {
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
          ControlGetPos,,,, Height, TMemo1, ahk_class TElWind
          if (Height) {  ; plain text item
            ControlClick, TMemo1, ahk_class TElWind,,,, % "NA x1 y" . Height - 2
          } else {  ; no text
            send q
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
    CurrFocus := ControlGetFocus()
    return (WinActive("ahk_class TElWind") && (InStr(CurrFocus, "Internet Explorer_Server") || InStr(CurrFocus, "TMemo")))
  }

  IsGrading() {
    CurrFocus := ControlGetFocus()
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
    } else {
      send {alt down}
      PostMessage, 0x0104, 0x50, 1<<29,, ahk_class TElWind  ; P key
      PostMessage, 0x0105, 0x50, 1<<29,, ahk_class TElWind
      send {alt up}
      WinWait, ahk_class TPriorityDlg
      ControlSetText, TEdit5, % random(min, max), ahk_class TPriorityDlg
      ControlSend, TEdit5, {enter}, ahk_class TPriorityDlg
    }
  }

  SetTaskValue(min, max) {
    ControlSetText, TEdit8, % random(min, max)
    ControlFocus, TEdit7
    this.Vim.State.SetNormal()
  }

  MoveAboveRef(RestoreClip:=true) {
    send ^{end}^+{up}  ; if there are references this would select (or deselect in visual mode) them all
    if (InStr(clip("",, RestoreClip,,, 1), "#SuperMemo Reference:")) {
      send {up 2}
    } else {
      send ^{end}
    }
  }

  DeselectAllComponents(timeout:=0) {
    if (this.IsEditingText()) {
      send ^t{esc}
      this.WaitTextExit(timeout)
    }
  }

  WaitTextExit(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (WinActive("ahk_class TElWind") && !this.IsEditingText()) {
        return true
      ; Choices because reference could update
      } else if (this.IsChangeRefWind() || (TimeOut && A_TickCount - StartTime > TimeOut)) {
        return false
      }
    }
  }

  WaitTextFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingText()) {
        return true
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        return false
      }
    }
  }

  WaitHTMLFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingHTML()) {
        return true
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        return false
      }
    }
  }

  WaitClozeProcessing(timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        break
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        return 0
      }
    }
    if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
      return -1
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(timeout, "|Please wait")
        return 1
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        Return 0
      }
    }
  }

  WaitExtractProcessing(timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        break
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        return false
      }
    }
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(timeout, "|Loading file")
        return true
      } else if (TimeOut && A_TickCount - StartTime > TimeOut) {
        Return false
      }
    }
  }

  EnterInsertIfSpelling() {
    loop {
      sleep 100
      if (InStr(ControlGetFocus("ahk_class TElWind"), "TMemo")) {
        this.Vim.State.SetMode("Insert")
        break
      } else if (A_Index > 5) {  ; timeout after 0.5s
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
    if (this.IsPassiveColl(CollName)) {
      StartTime := A_TickCount
      if (ControlTextWait("TBitBtn3", "Next repetition", "ahk_class TElWind",,,, timeout)) {
        ToolTip("Autoplay",, -1000)
        WinActivate, ahk_class TElWind
        send ^{f10}
        return true
      } else {
        return false
      }
    }
  }

  SaveHTML(PassSend:=false, ReturnPath:=false) {
    if (!PassSend && this.IsEditingHTML()) {
      send {esc}
      Vim.SM.WaitTextExit()
    }
    send ^+{f6}  ; opens notepad
    if (ReturnPath) {
      WinWaitActive, ahk_class Notepad,, 0
      for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name='notepad.exe'")
        path := RegExReplace(process.CommandLine, """.*?"" ")
    } else {
      WinWaitNotActive, ahk_class TElWind,, 5
    }
    WinClose, ahk_class Notepad
    WinActivate, ahk_class TElWind
    return path
  }

  GetCollName(text:="") {
    text := text ? text : WinGetText("ahk_class TElWind")
    RegExMatch(text, "m)^.*?(?= \(SuperMemo)", CollName)
    return CollName
  }

  GetCollPath(text:="") {
    text := text ? text : WinGetText("ahk_class TElWind")
    RegExMatch(text, "m)\(SuperMemo [0-9]+: \K.*(?=\)$)", CollPath)
    return CollPath
  }

  GetLink(TemplCode:="", RestoreClip:=true) {
    global WinClip
    if (RestoreClip && !TemplCode)
      ClipSaved := ClipboardAll
    WinClip.Clear()
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode(false)
    if (InStr(TemplCode, "Link:")) {
      RegExMatch(TemplCode, "(?<=#Link: <a href="").*?(?="")", link)
      if (RestoreClip && !TemplCode)
        Clipboard := ClipSaved
      return link
    } else {
      if (RestoreClip && !TemplCode)
        Clipboard := ClipSaved
    }
  }

  GetFilePath(RestoreClip:=true) {
    global WinClip
    if (RestoreClip)
      ClipSaved := ClipboardAll
    WinClip.Clear()
    send !{f12}fc
    ; this.PostMsg(987, true)  ; not reliable???
    ClipWait
    path := Clipboard
    if (RestoreClip)
      Clipboard := ClipSaved
    return path
  }

  SetTitle(title:="") {
    if (WinGetTitle("ahk_class TElWind") != title) {
      this.PostMsg(116)  ; edit title
      GroupAdd, SMAltT, ahk_class TChoicesDlg
      GroupAdd, SMAltT, ahk_class TTitleEdit
      WinWait, ahk_group SMAltT
      if (WinExist("ahk_class TChoicesDlg")) {
        if (!title)
          ControlFocus, TGroupButton2, ahk_class TChoicesDlg
        ; ControlSend, TBitBtn2, {enter}, ahk_class TChoicesDlg  ; doesn't work if alt is pressed down
        ControlClick, TBitBtn2, ahk_class TChoicesDlg,,,, NA
        if (title)
          WinWait, ahk_class TTitleEdit
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
    RegExMatch(CurrText, "m)(?<=\)\r\n).*$", ConceptName)
    return ConceptName
  }

  IsPassiveColl(CollName:="") {
    CollName := CollName ? CollName : this.GetCollName()
    return (IfIn(CollName, "passive,singing,piano,calligraphy,drawing,bgm,music"))
  }

  PostMsg(msg, ContextMenu:=false) {
    if (!ContextMenu) {
      PostMessage, 0x0111, % msg,,, ahk_class TElWind
    } else {
      if (WinActive("ahk_exe sm18.exe")) {
        WinClass := "ahk_pid " . WinGet("PID")
      } else {
        WinClass := "ahk_exe sm18.exe"
      }
      PrevDetectHiddenWind := A_DetectHiddenWindows
      DetectHiddenWindows, on
      WinGet, ContextMenuID, list, % "ahk_class TPUtilWindow " . WinClass
      PostMessage, 0x0111, % msg,,, % "ahk_id " . ContextMenuID5
      DetectHiddenWindows, % PrevDetectHiddenWind
    }
  }

  GetTemplCode(RestoreClip:=true) {
    global WinClip
    if (RestoreClip)
      ClipSaved := ClipboardAll
    WinClip.Clear()
    send !{f10}tc
    ; this.PostMsg(693, true)  ; not reliable???
    ClipWait
    code := Clipboard
    if (RestoreClip)
      Clipboard := ClipSaved
    return code
  }

  WaitFileLoad(timeout:=0, add:="") {  ; used for reloading or waiting for an element to load
    ; Move mouse because this function requires status bar text detection
    PrevCoordModeMouse := A_CoordModeMouse
    CoordMode, Mouse, Screen
    MouseGetPos, x, y
    MouseMove, 0, 0, 0
    StartTime := A_TickCount
    StatText := WinGetText("ahk_class TStatBar")
    ControlTextWaitChange("ahk_class TStatBar", StatText,,,,, timeout)
    match := "^(\s+)?(Priority|Int|Downloading|\([0-9]+ item\(s\)" . add . ")"
    loop {
      if (RegExMatch(WinGetText("ahk_class TStatBar"), match)) {
        ret := true
        break
      } else if (timeout && A_TickCount - StartTime > timeout) {
        ret := false
        break
      }
    }
    MouseMove, x, y, 0
    CoordMode, Mouse, % PrevCoordModeMouse
    return ret
  }

  Learn() {
    if (ControlGetText("TBitBtn2") == "Learn") {
      ControlSend, TBitBtn2, {enter}, ahk_class TElWind
    } else if (IfIn(ControlGetText("TBitBtn3"), "Learn,Show answer,Next repetition", true)) {
      ControlSend, TBitBtn3, {enter}, ahk_class TElWind
    }
  }

  Reload(timeout:=0, method:=0) {
    if (!method) {
      send !{home}
      this.WaitFileLoad(timeout)
      send !{left}
    } else {
      send {alt down}
      PostMessage, 0x0104, 0x24, 1<<29,, ahk_class TElWind  ; home key
      PostMessage, 0x0105, 0x24, 1<<29,, ahk_class TElWind
      this.WaitFileLoad(timeout)
      PostMessage, 0x0104, 0x25, 1<<29,, ahk_class TElWind  ; left arrow key
      PostMessage, 0x0105, 0x25, 1<<29,, ahk_class TElWind
      send {alt up}
    }
  }

  IsCssClass(text) {
    if text in cloze,extract,clozed,hint,note,ignore,headers,RefText,reference,highlight,SearchHighlight,TableLabel,AntiMerge
      return true
  }

  ChangeDefaultConcept(concept:="") {
    ControlClickWinCoord(723, 57, "ahk_class TElWind")
    ; ControlClickDPIAdjusted(716, 14, "TToolBar2", "ahk_class TElWind")  ; not reliable because sometimes it could be TToolBar3???
    if (concept) {
      WinWait, ahk_class TRegistryForm
      ControlSetText, Edit1, % SubStr(concept, 2), ahk_class TRegistryForm
      ; Needed for updating the template; without {text},
      ; the first letter would not be in the correct case;
      ; which makes ControlTextWait() cannot pass
      ControlSend, Edit1, % "{text}" . SubStr(concept, 1, 1), ahk_class TRegistryForm
      ControlTextWait("Edit1", concept, "ahk_class TRegistryForm")
      ControlSend, Edit1, {enter}, ahk_class TRegistryForm
    }
  }

  ClickElWindSourceBtn() {
    ControlClickWinCoord(555, 57, "ahk_class TElWind")
    ; ControlClickDPIAdjusted(548, 14, "TToolBar2", "ahk_class TElWind")
  }

  ClickBrowserSourceButton() {
    ControlClickWinCoord(294, 45, "ahk_class TBrowser")
  }

  SetElParam(title:="", prio:="", template:="", method:=0) {
    if (method) {
      ; Sometimes doesn't work
      ControlSend,, {ctrl down}{shift down}p{ctrl up}{shift up}, ahk_class TElWind
    } else {
      WinActivate, ahk_class TElWind
      send ^+p
    }
    WinWait, ahk_class TElParamDlg
    if (title) {
      ControlSetText, TEdit2, % SubStr(title, 2), ahk_class TElParamDlg
      ControlSend, TEdit2, % "{text}" . SubStr(title, 1, 1), ahk_class TElParamDlg
    }
    if (prio) {
      ControlSetText, TEdit1, % SubStr(prio, 2), ahk_class TElParamDlg
      ControlSend, TEdit1, % "{text}" . SubStr(prio, 1, 1), ahk_class TElParamDlg
    }
    if (template) {
      ControlSetText, Edit1, % SubStr(template, 2), ahk_class TElParamDlg
      ControlSend, Edit1, % "{text}" . SubStr(template, 1, 1), ahk_class TElParamDlg
    }
    while (WinExist("ahk_class TElParamDlg"))
      ControlSend, TEdit2, {enter}, ahk_class TElParamDlg
  }

  IsChangeRefWind() {
    if (WinActive("ahk_class TChoicesDlg")) {
      ; When you change the reference of an element that shares the reference with other elements
      ; no shortcuts there, so movement keys are used for up/down navigation
      ; if more windows are found without shortcuts in the future, they will be all added here
      return (ControlGetText("TGroupButton1") == "Cancel (i.e. restore the old version of references)"
           || ControlGetText("TGroupButton2") == "Combine old and new references for this element"
           || ControlGetText("TGroupButton3") == "Change references in all elements produced from the original article"
           || ControlGetText("TGroupButton4") == "Change only the references of the currently displayed element")
    }
  }

  CheckDup(text, ClearHighlight:=true) {  ; try to find duplicates
    ; ControlSend,, {ctrl down}f{ctrl up}, ahk_class TElWind
    while (WinExist("ahk_class TBrowser") || WinExist("ahk_class TMsgDialog"))
      WinClose
    ; if (this.GetCollName() == this.LastCheckDupColl && this.LastCheckText == text)
    ;   return this.LastCheckResult
    this.PostMsg(144)
    WinWait, ahk_class TMyFindDlg
    ControlSetText, TEdit1, % text, ahk_class TMyFindDlg
    ControlSend,, {enter}, ahk_class TMyFindDlg
    GroupAdd, SMCtrlF, ahk_class TMsgDialog
    GroupAdd, SMCtrlF, ahk_class TBrowser
    WinWait, ahk_group SMCtrlF
    if (WinExist("ahk_class TMsgDialog")) {
      while (WinExist("ahk_class TMsgDialog"))
        WinClose
      ToolTip("No duplicates found.",, -3000)
      if (ClearHighlight)
        this.ClearHighlight()
    } else if (WinExist("ahk_class TBrowser")) {
      WinActivate
      if (ClearHighlight)
        this.ClearHighlight()
      WinActivate, ahk_class TBrowser
      ret := true
    }
    ; this.LastCheckDupColl := this.GetCollName()
    ; this.LastCheckText := text
    ; this.LastCheckResult := ret
    return ret
  }

  ClearHighlight() {
    ; ControlSend,, {ctrl down}{enter}{ctrl up}, ahk_class TElWind
    this.PostMsg(240)
    WinWait, ahk_class TCommanderDlg
    ControlSetText, TEdit2, h, ahk_class TCommanderDlg  ; Highlight: Clear
    ; ControlSend, TButton4, {enter}, ahk_class TCommanderDlg  ; doesn't close sometimes?
    ControlTextWaitChange("TEdit2",, "ahk_class TCommanderDlg")
    ControlClick, TButton4, ahk_class TCommanderDlg,,,, NA
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
    if (this.Vim.Browser.date)
      text .= break . "#Date: " . this.Vim.Browser.date
    if (this.Vim.Browser.comment)
      text .= break . "#Comment: " . this.Vim.Browser.comment
    return text
  }

  ParseUrl(url) {  ; for checking duplicates
    ; This is the function that works. Enc_Uri() does not
    ; (2nd parameter) Encode in case there are Chinese characters in URL
    ; (3rd parameter) component := false because "/" doesn't need to be encoded
    url := EncodeDecodeURI(this.Vim.Browser.ParseUrl(url),, false)
    url := StrReplace(url, "%253A", ":")  ; ":" appears in url of SuperMemo references
    return url
  }

  ClearUp() {
    this.ClearHighlight()
    WinClose, ahk_class TBrowser
  }

  HandleF3(step) {
    if (step == 1) {
      send {f3}
      WinWaitActive, ahk_class TMyFindDlg,, 0
      if (ErrorLevel) {  ; SM goes to the next found without opening find dialogue
        send {esc}
        this.ClearHighlight()  ; clears highlight so it opens find dialogue
        send {f3}
        WinWaitActive, ahk_class TMyFindDlg,, 0  ; still not opened somhow
        if (ErrorLevel) {
          ToolTip("Not found.")
          return false
        }
      }
      return true
    } else if (step == 2) {
      send ^{enter}  ; open commander; convienently, if a "not found" window pops up, this would close it
      GroupAdd, SMF3, ahk_class TMyFindDlg
      GroupAdd, SMF3, ahk_class TCommanderDlg
      WinWaitActive, ahk_group SMF3
      if (WinActive("ahk_class TMyFindDlg")) {  ; ^enter closed "not found" window
        WinClose
        this.ClearHighlight()
        send {esc}
        this.Vim.State.SetNormal()
        ToolTip("Not found.")
        return false
      }
      ControlSetText, TEdit2, h  ; Highlight: Clear
      send {enter}
      if (WinExist("ahk_class TMyFindDlg"))  ; clears search box window
        WinClose
      return true
    }
  }
}