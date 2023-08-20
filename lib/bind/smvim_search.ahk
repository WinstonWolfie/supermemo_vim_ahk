CapsLock & alt::return  ; so you can press CapsLock first and alt without triggering context menu
#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && !Vim.State.fts && WinActive("ahk_class TElWind"))
?::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind"))
!/::  ; followed by a cloze
^!/::  ; followed by a cloze and stays in clozed item
+!/::  ; followed by a cloze hinter
^+!/::  ; also cloze hinter but stays in clozed item
/::  ; better search
  ShiftState := IfContains(A_ThisHotkey, "+,?")
  AltState := IfContains(A_ThisHotkey, "!")  ; followed by a cloze
  CtrlState := IfContains(A_ThisHotkey, "^")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (AltState := GetKeyState("alt")) && (ShiftState := GetKeyState("shift")))
CapsLock & /::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (ShiftState := GetKeyState("shift")))
CapsLock & /::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (AltState := GetKeyState("alt")))
CapsLock & /::
  CapsState := IfContains(A_ThisHotkey, "CapsLock"), ReleaseModifierKeys()
  KeyWait Alt
  BlockInput, on
  if (!Vim.SM.IsEditingText()) {
    Vim.SM.EditFirstQuestion()
    Vim.SM.WaitTextFocus()  ; make sure CurrFocus is updated    
    if (Vim.SM.IsEditingHTML())
      sleep 50  ; short sleep so the element window won't try to regain focus
    if (!Vim.SM.IsEditingText()) {  ; still found no text
      ToolTip("Text not found.")
      Vim.State.SetNormal()
      BlockInput, off
      return
    }
  } 
  if (Vim.State.StrIsInCurrentVimMode("Visual")) {
    send {right}
    Vim.State.SetNormal()
  }
  CurrFocus := ControlGetFocus("ahk_class TElWind")
  if (AltState) {
    Gui, Search:Add, Text,, &Find text:`n(your search result will be clozed)
  } else if (ShiftState) {
    Gui, Search:Add, Text,, &Find text:`n(will go to visual mode after the search)
  } else {
    Gui, Search:Add, Text,, &Find text:
  }
  Gui, Search:Add, Edit, vUserInput w196 r1 -WantReturn, % VimLastSearch
  Gui, Search:Add, CheckBox, vWholeWord, Match &whole word only
  if (AltState) {
    Gui, Search:Add, CheckBox, % "vCtrlState " . (CtrlState ? "checked" : ""), &Stay in clozed item
    Gui, Search:Add, CheckBox, % "vShiftState " . (ShiftState ? "checked" : ""), Cloze &hinter
  }
  Gui, Search:Add, Button, default, &Find
  BlockInput, off
  Gui, Search:Show,, Search
return

SearchGuiEscape:
SearchGuiClose:
  Gui destroy
return

SearchButtonFind:
  Gui submit
  Gui destroy
  if (UserInput == "")
    Return
  VimLastSearch := UserInput  ; register UserInput into VimLastSearch
  ; Previously, UserInput is stored in Vim.Move.LastSearch, but it turned out this would add 000... in floating numbers
  ; ie, 3.8 would become 3.80000
  WinActivate, ahk_class TElWind

SMSearch:
SMSearchAgain:
  if (IfContains(CurrFocus, "TMemo")) {
    send ^+{end}
    if (A_ThisLabel != "SMSearchAgain") {
      if (Vim.State.n)
        Vim.State.n--
      n := Vim.State.n ? Vim.State.n : 0, Vim.State.n := 0
    }
    if (WholeWord) {
      match := "s)(\b(" . UserInput . ")\b.*?){" . n . "}\K\b" . UserInput . "\b"
    } else {
      match := "s)((" . UserInput . ").*?){" . n . "}\K" . UserInput
    }
    pos := RegExMatch(selection := Vim.ParseLineBreaks(Copy()), match)
    if (pos == 1) {
      if (WholeWord) {
        match := "s)(\b(" . UserInput . ")\b.*?){" . n + 1 . "}\K\b" . UserInput . "\b"
      } else {
        match := "s)(" . UserInput . ".*?){" . n + 1 . "}\K" . UserInput
      }
      pos := RegExMatch(selection, match)
    }
    if (pos) {
      send % "{left}{right " . pos-- . "}"
      if (ShiftState || AltState) {
        send % "+{right " . StrLen(UserInput) . "}"
        if (ShiftState) {
          Vim.State.SetMode("Vim_Visual")
        } else if (AltState) {
          send !z
        }
      }
    } else {
      send {left}
      if (A_ThisLabel != "SMSearchAgain") {
        send ^{home}
        ToolTip("Search started from the beginning.")
        goto SMSearchAgain
      }
      ToolTip("Not found."), Vim.State.SetNormal()
      Return
    }
  } else if (IfContains(CurrFocus, "Internet Explorer_Server")) {
    if (!Vim.SM.HandleF3(1))
      return
    ; Left spaces need to be trimmed otherwise SM might eat the spaces in text
    ControlSetText, TEdit1, % LTrim(UserInput), ahk_class TMyFindDlg
    if (WholeWord)
      Control, Check,, TCheckBox2, ahk_class TMyFindDlg  ; match whole word
    Control, Check,, TCheckBox1, ahk_class TMyFindDlg  ; match case
    send {enter}
    if (Vim.State.n)
      send % "{f3 " . Vim.State.GetN() - 1 . "}"
    WinWaitNotActive, ahk_class TMyFindDlg
    if (ShiftState && !AltState) {
      Vim.State.SetMode("Vim_Visual")
    } else if (!AltState) {  ; all modifier keys are not pressed
      send {left}  ; put caret on left of searched text
    }
    if (!Vim.SM.HandleF3(2))
      return
    if (AltState && !CtrlState && !ShiftState && !CapsState) {
      send !z
    } else if (AltState && ShiftState) {
      ClozeHinterCtrlState := CtrlState
      gosub ClozeHinter
    } else if (AltState && CapsState) {
      ClozeHinterCtrlState := CtrlState
      gosub ClozeNoBracket
    } else if (AltState && CtrlState) {
      gosub ClozeStay
    }
  }
return