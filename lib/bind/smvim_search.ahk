#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
CapsLock & alt::return  ; so you can press CapsLock first and alt without triggering context menu
#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && !Vim.State.fts && WinActive("ahk_class TElWind"))
?::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind"))
!/::  ; followed by a cloze
^!/::  ; followed by a cloze and stays in clozed item
+!/::  ; followed by a cloze hinter
^+!/::  ; also cloze hinter but stays in clozed item
/::  ; better search
  ShiftState := IfContains(A_ThisLabel, "+,?")
  AltState := IfContains(A_ThisLabel, "!")  ; followed by a cloze
  CtrlState := IfContains(A_ThisLabel, "^")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (AltState := GetKeyState("alt")) && (ShiftState := GetKeyState("shift")))
CapsLock & /::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (ShiftState := GetKeyState("shift")))
CapsLock & /::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (AltState := GetKeyState("alt")))
CapsLock & /::
  if (!SM.DoesTextExist()) {
    SetToolTip("Text not found.")
    return
  }
  CapsState := IfContains(A_ThisLabel, "CapsLock")
  KeyWait Alt
  BlockInput, On
  if (SM.IsBrowsing())
    SM.EditFirstQuestion(), SM.WaitTextFocus()
  if (Vim.State.StrIsInCurrentVimMode("Visual")) {
    Send {Right}
    Vim.State.SetNormal()
  }
  CurrFocus := ControlGetFocus("ahk_class TElWind")
  if (AltState) {
    Gui, Search:Add, Text,, Find te&xt:`n(your search result will be clozed)
  } else if (ShiftState) {
    Gui, Search:Add, Text,, Find te&xt:`n(will go to visual mode after the search)
  } else {
    Gui, Search:Add, Text,, Find te&xt:
  }
  Gui, Search:Add, Edit, vUserInput w196 r1 -WantReturn, % VimLastSearch
  Gui, Search:Add, CheckBox, vWholeWord, Match &whole word only
  if (AltState) {
    Gui, Search:Add, CheckBox, % "vCtrlState " . (CtrlState ? "checked" : ""), &Stay in clozed item
    Gui, Search:Add, CheckBox, % "vShiftState " . (ShiftState ? "checked" : ""), Cloze &hinter
  }
  Gui, Search:Add, Button, default, &Find
  BlockInput, Off
  Gui, Search:Show,, Search
return

SearchGuiEscape:
SearchGuiClose:
  Gui, Destroy
return

SearchButtonFind:
  Gui, Submit
  Gui, Destroy
  if (UserInput == "")
    Return
  VimLastSearch := UserInput := Trim(UserInput)
  ; Previously, UserInput is stored in Vim.Move.LastSearch, but it turned out this would add 000... in floating numbers
  ; ie, 3.8 would become 3.80000
  WinActivate, ahk_class TElWind

SMSearch:
SMSearchAgain:
  if (IfContains(CurrFocus, "TMemo")) {
    Send ^+{End}
    if (A_ThisLabel != "SMSearchAgain") {
      if (Vim.State.n)
        Vim.State.n--
      n := Vim.State.n ? Vim.State.n : 0, Vim.State.n := 0
    }
    if (WholeWord) {
      Match := "s)(\b(" . UserInput . ")\b.*?){" . n . "}\K\b" . UserInput . "\b"
    } else {
      Match := "s)((" . UserInput . ").*?){" . n . "}\K" . UserInput
    }
    pos := RegExMatch(Selection := ParseLineBreaks(Copy()), Match)
    if (pos == 1) {
      if (WholeWord) {
        Match := "s)(\b(" . UserInput . ")\b.*?){" . n + 1 . "}\K\b" . UserInput . "\b"
      } else {
        Match := "s)(" . UserInput . ".*?){" . n + 1 . "}\K" . UserInput
      }
      pos := RegExMatch(Selection, Match)
    }
    if (pos) {
      Send % "{Left}{Right " . pos - 1 . "}"
      if (ShiftState || AltState) {
        Send % "+{Right " . StrLen(UserInput) . "}"
        if (ShiftState) {
          Vim.State.SetMode("Vim_Visual")
        } else if (AltState) {
          SM.Cloze()
        }
      }
    } else {
      Send {Left}
      if (A_ThisLabel != "SMSearchAgain") {
        Send ^{Home}
        SetToolTip("Search started from the beginning.")
        Goto SMSearchAgain
      }
      SetToolTip("Not found."), Vim.State.SetNormal()
      Return
    }
  } else if (IfContains(CurrFocus, "Internet Explorer_Server")) {
    if (!SM.HandleF3(1))
      return
    ; Left spaces need to be trimmed otherwise SM might eat the spaces in text
    ControlSetText, TEdit1, % LTrim(UserInput), ahk_class TMyFindDlg
    if (WholeWord)
      Control, Check,, TCheckBox2, ahk_class TMyFindDlg  ; match whole word
    Control, Check,, TCheckBox1, ahk_class TMyFindDlg  ; match case
    Send {Enter}
    if (Vim.State.n)
      Send % "{f3 " . Vim.State.GetN() - 1 . "}"
    WinWaitNotActive, ahk_class TMyFindDlg
    if (ShiftState && !AltState) {
      Vim.State.SetMode("Vim_Visual")
    } else if (!AltState) {  ; all modifier keys are not pressed
      Send {Left}  ; put caret on left of searched text
    }
    if (!SM.HandleF3(2))
      return
    if (AltState && !CtrlState && !ShiftState && !CapsState) {
      SM.Cloze()
    } else if (AltState && ShiftState) {
      ClozeHinterCtrlState := CtrlState, InitText := UserInput
      Gosub SMClozeHinter
    } else if (AltState && CapsState) {
      ClozeHinterCtrlState := CtrlState
      Gosub SMClozeNoBracket
    } else if (AltState && CtrlState) {
      Gosub SMClozeStay
    }
  }
return
