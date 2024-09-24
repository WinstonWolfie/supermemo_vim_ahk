#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
class VimState {
  __New(vim) {
    this.Vim := vim

    ; CheckModeValue does not get set for compiled scripts.
    ;@Ahk2Exe-IgnoreBegin
    this.CheckModeValue := false
    ;@Ahk2Exe-IgnoreEnd
    this.PossibleVimModes := ["", "Vim_Normal", "Insert", "Replace"
    , "Vim_ydc_y" , "Vim_ydc_yInner", "Vim_ydc_c", "Vim_ydc_cInner"
    , "Vim_ydc_d" , "Vim_ydc_dInner" , "Vim_VisualLine", "Vim_VisualFirst"
    , "Vim_VisualFirstInner", "Vim_VisualChar", "Vim_VisualLineFirst"
    , "Vim_VisualCharInner", "Command" , "Command_w", "Command_q"
    , "Z", "r_once", "r_repeat", "SMVim_Cloze", "SMVim_ClozeInner"
    , "SMVim_ClozeStay", "SMVim_ClozeStayInner", "SMVim_ClozeHinter"
    , "SMVim_ClozeHinterInner", "SMVim_Extract", "SMVim_ExtractInner"
    , "SMVim_ExtractStay", "SMVim_ExtractStayInner", "Vim_VisualBlock"
    , "Vim_VisualParagraph", "Vim_VisualParagraphFirst", "SMVim_ExtractPriority"
    , "SMVim_ExtractPriorityInner", "Insert_Unicode", "SMVim_AltT", "SMVim_AltQ"]

    this.Mode := "Vim_Normal"  ; the default mode when vim_ahk opens
    this.g := 0
    this.n := 0
    this.LineCopy := 0
    this.LastIME := 0
    this.fts := ""
    this.Surround := 0
    this.Leader := 0

    this.StatusCheckObj := ObjBindMethod(this, "StatusCheck")
  }

  CheckMode(verbose=1, Mode="", g=0, n=0, LineCopy=-1, fts="", Force=0) {
    if (Force == 0) and ((verbose <= 1) or ((Mode == "") and (g == 0) and (n == 0) and (LineCopy == -1))) {
      Return
    } else if (verbose == 2) {
      SetToolTip(this.Mode)
    } else if (verbose == 3) {
      SetToolTip(this.Mode "`r`ng=" this.g "`r`nn=" this.n "`r`nLineCopy=" this.LineCopy "`r`nfts=" this.fts "`r`nSurround=" this.Surround "`r`nLeader=" this.Leader)
    }
    if (verbose >= 4) {
      Msgbox, , Vim Ahk, % "Mode: " this.Mode "`nVim_g: " this.g "`nVim_n: " this.n "`nVimLineCopy: " this.LineCopy "`r`nfts:" this.fts
    }
  }

  FullStatus() {
    this.CheckMode(4, , , , 1)
  }

  SetMode(Mode:="", g:=0, n:=0, LineCopy:=-1, fts:="", Surround:=0, Leader:=0) {
    PrevMode := this.Mode
    this.CheckValidMode(Mode)
    if (Mode != "") {
      this.Mode := Mode
      if ((PrevMode == "SMPlanDragging") && this.IsCurrentVimMode("Vim_Normal"))
        this.HandlePlanDraggingSetNormal()
      global SM
      if (this.IsCurrentVimMode("Insert") && SM.IsNavigatingPlan() && !GetKeyState("Alt", "P"))
        Send {f2}^a
      if (this.IsCurrentVimMode("Insert") && this.Vim.Conf["VimRestoreIME"]["val"] == 1)
        VIM_IME_SET(this.LastIME)
      this.Vim.Icon.SetIcon(this.Mode, this.Vim.Conf["VimIconCheckInterval"]["val"])
      if ((PrevMode != mode) && A_CaretX)
        this.Vim.Caret.SetCaret(this.Mode)
    }
    if (g != -1)
      this.g := g
    if (n != -1)
      this.n := n
    if (LineCopy != -1)
      this.LineCopy := LineCopy
    this.fts := fts
    if (Surround != -1)
      this.Surround := Surround
    if (Leader != -1)
      this.Leader := Leader
    this.CheckMode(this.Vim.Conf["VimVerbose"]["val"], Mode, g, n, LineCopy, fts)
  }

  SetNormal() {
    this.LastIME := VIM_IME_Get()
    if (this.LastIME) {
      if (VIM_IME_GetConverting()) {
        Send {Esc}
        Return
      } else {
        VIM_IME_SET()
      }
    }

    global SM
    if (A_CaretX && !this.Vim.IsNavigating()
     || (SM.IsEditingText() && (A_ThisHotkey != "CapsLock") && (A_ThisHotkey != "Esc"))) {  ; exiting text should not trigger this section
      if (this.StrIsInCurrentVimMode("Visual,ydc") && !this.StrIsInCurrentVimMode("VisualFirst")) {
        Send {Right}
        if (WinActive("ahk_group VimCursorSameAfterSelect"))
          Send {Left}
      } else if (this.StrIsInCurrentVimMode("Insert")) {
        Send {Left}
      }
    }

    this.SetMode("Vim_Normal")
  }

  SetInner() {
    this.SetMode(this.Mode "Inner",,,,, -1)
  }

  SetOuter() {
    this.SetMode(this.Mode "Outer",,,,, -1)
  }

  HandleEsc() {
    global Vim, VimEscNormal, SMVimSendEscInsert, VimSendEscNormal, VimLongEscNormal
    Caps := (A_ThisHotkey = "CapsLock") ? true : false
    Esc := (A_ThisHotkey = "Esc") ? true : false
    global SM
    if (SM.IsEditingText() && Caps)
      SM.ClickMid()
    if (!VimEscNormal) {
      Send {Esc}
      Return
    }
    ; keyWait waits for Esc to be released. If it didn't detect a release
    ; within the time limit, ErrorLevel is set to 1.
    KeyWait, Esc, T0.5
    LongPress := ErrorLevel
    both := (VimLongEscNormal && LongPress)
    neither := !(VimLongEscNormal || LongPress)
    SetNormal := (both || neither)
    ; In SuperMemo you can use Esc to both escape and enter normal mode
    if ((!SetNormal || (VimSendEscNormal && this.IsCurrentVimMode("Vim_Normal"))) || (WinActive("ahk_group SM") && SMVimSendEscInsert))
      Send {Esc}
    if (SetNormal || (WinActive("ahk_group SM") && SMVimSendEscInsert))
      this.SetNormal()
    ; Have to ensure the key has been released, otherwise this will get
    ; triggered again.
    if (LongPress && Esc)
      KeyWait Esc
  }

  HandlePlanDraggingSetNormal() {
    global XCoordSaved, YCoordSaved, IniXCoord, IniYCoord, SMPlanDraggingPut
    if (SMPlanDraggingPut) {
      SMPlanDraggingPut := false
    } else {
      MouseGetPos, XCoord, YCoord
      MouseMove, IniXCoord, IniYCoord  ; speed can't be 0 otherwise returning won't work reliably
      click up
      MouseGetPos, x, y
      ControlClickWinCoord(x, y)  ; to uncheck the "fix"
      MouseMove, XCoordSaved, YCoordSaved, 0
    }
  }

  HandleCtrlBracket() {
    global Vim, VimCtrlBracketNormal, VimSendCtrlBracketNormal, VimLongCtrlBracketNormal, VimCtrlBracketToEsc
    if (!VimCtrlBracketNormal) {
      Send ^[
      Return
    }
    KeyWait, [, T0.5
    LongPress := ErrorLevel
    both := (VimLongCtrlBracketNormal && LongPress)
    neither := !(VimLongCtrlBracketNormal || LongPress)
    SetNormal := (both || neither)
    if (VimCtrlBracketToEsc)
      Send {Esc}
    if (!SetNormal || (VimSendCtrlBracketNormal && this.IsCurrentVimMode("Vim_Normal"))) {
      Send ^[
    }
    if (SetNormal) {
      this.SetNormal()
    }
    if (LongPress) {
      KeyWait [
    }
  }

  IsCurrentVimMode(mode) {
    this.CheckValidMode(mode)
    Return IfIn(this.mode, mode, true)
  }

  StrIsInCurrentVimMode(mode) {
    this.CheckValidMode(mode, false)
    Return IfContains(this.Mode, mode, true)
  }

  CheckValidMode(mode, fullMatch=true) {
    if (this.CheckModeValue == false) {
      Return
    }
    try {
      InOrBlank:= (not fullMatch) ? "in " : ""
      if not this.HasValue(this.PossibleVimModes, mode, fullMatch) {
        throw Exception("Invalid mode specified",-2,
        (Join
  "'" Mode "' is not " InOrBlank " a valid mode as defined by the VimPossibleVimModes
   array at the top of vim_state.ahk. This may be a typo.
   Fix this error by using an existing mode,
   or adding your mode to the array.")
        )
      }
    } catch e {
      MsgBox % "Warning: " e.Message "`n" e.Extra "`n`n Called in " e.What " at line " e.Line
    }
  }

  HasValue(haystack, needle, fullMatch=true) {
    if (!isObject(haystack)) {
      return false
    } else if (haystack.Length() == 0) {
      return false
    }
    for index, value in haystack{
      if fullMatch{
        if (value == needle) {
          return true
        }
      } else {
        if (inStr(value, needle)) {
          return true
        }
      }
    }
    return false
  }

  ; Update icon/mode indicator
  StatusCheck() {
    if (this.Vim.IsVimGroup() || this.Vim.State.IsCurrentVimMode("Insert_Unicode")) {
      this.Vim.Icon.SetIcon(this.Mode, this.Vim.Conf["VimIconCheckInterval"]["val"])
    } else {
      this.Vim.Icon.SetIcon("Disabled", this.Vim.Conf["VimIconCheckInterval"]["val"])
    }
  }

  SetStatusCheck() {
    check := this.StatusCheckObj
    if (this.Vim.Conf["VimIconCheckInterval"]["val"] > 0) {
      SetTimer, % check, % this.Vim.Conf["VimIconCheckInterval"]["val"]
    } else {
      this.Vim.Icon.SetIcon("", 0)
      SetTimer, % check, Off
    }
  }

  ToggleEnabled() {
    if (this.Vim.Enabled) {
      this.Vim.Enabled := False, SetToolTip("SMVim disabled.")
    } else {
      this.Vim.Enabled := True, SetToolTip("SMVim enabled.")
    }
  }

  GetN() {
    n := this.n ? this.n : 1, this.n := 0
    return n
  }
}
