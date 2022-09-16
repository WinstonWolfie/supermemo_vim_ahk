class VimMove {
  __New(vim) {
    this.Vim := vim
    this.shift := 0
  }
  
  NoSelection() {
    if !this.ExistingSelection && (this.Vim.State.StrIsInCurrentVimMode("VisualFirst") || this.Vim.State.StrIsInCurrentVimMode("ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_") || this.Vim.State.StrIsInCurrentVimMode("Inner")) {
      this.ExistingSelection := true  ; so it only returns true once in repeat
      Return true
    }
  }

  MoveInitialize(key="") {
    this.shift := 0
    this.ExistingSelection := false
  
    ; Search keys
    if (key == "f" || key == "t" || key == "+f" || key == "+t" || key == "(" || key == ")" || key == "s" || key == "+s" || key == "/" || key == "?" || key == "e") {
      this.SearchOccurrence := this.Vim.State.n ? this.Vim.State.n : 1
      this.FtsChar := this.Vim.State.FtsChar
    }
    
    if (this.Vim.State.StrIsInCurrentVimMode("Visual") || this.Vim.State.StrIsInCurrentVimMode("ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_")) {
      this.shift := 1
      ; Search keys
      if (key != "f" && key != "t" && key != "+f" && key != "+t" && key != "(" && key != ")" && key != "s" && key != "+s" && key != "/" && key != "?" && key != "e")
        send {Shift Down}
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g") {
      send {Shift Up}{End}
      this.Home()
      send {Shift Down}
      this.Up()
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g") {
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g") {
      send {Shift Up}{right}{left}{Shift Down}
      this.Up()
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g") {
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }
  
    if (this.Vim.State.IsCurrentVimMode("Vim_VisualBlock") && WinActive("ahk_exe notepad++.exe")) {
      send {alt down}
    }

    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")) and (key == "k" or key == "^u" or key == "^b" or key == "g") {
      this.Vim.State.LineCopy := 1
      Send,{Shift Up}
      this.Home()
      this.Down()
      send {Shift Down}
      this.Up()
    }
  
    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")) and (key == "j" or key == "^d" or key == "^f" or key == "+g") {
      this.Vim.State.LineCopy := 1
      Send,{Shift Up}
      this.Home()
      send {Shift Down}
      this.Down()
    }
  }

  MoveFinalize() {
    Send {Shift Up}
    ydc_y := false
    this.Vim.State.FtsChar := ""
    if (this.Vim.State.StrIsInCurrentVimMode("ydc_y")) {
      Clipboard :=
      send ^c
      ClipWait, 1
      this.YdcClipSaved := Clipboard
      this.Vim.State.SetMode("Vim_Normal")
      ydc_y := true
    } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_d")) {
      Clipboard :=
      send ^x
      ClipWait, 1
      this.YdcClipSaved := Clipboard
      this.Vim.State.SetMode("Vim_Normal")
    } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
      Clipboard :=
      send ^x
      ClipWait, 1
      this.YdcClipSaved := Clipboard
      this.Vim.State.SetMode("Insert")
    } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_gu")) {
      Gosub ConvertToLowercase
    } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_g+u")) {
      Gosub ConvertToUppercase
    } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_g~")) {
      Gosub InvertCase
    } else if (this.Vim.State.StrIsInCurrentVimMode("ExtractStay")) {
      Gosub ExtractStay
    } else if (this.Vim.State.StrIsInCurrentVimMode("ExtractPriority")) {
      send !+x
      this.Vim.State.SetMode("Vim_Normal")
    } else if (this.Vim.State.StrIsInCurrentVimMode("Extract")) {
      send !x
      this.Vim.State.SetMode("Vim_Normal")
    } else if (this.Vim.State.StrIsInCurrentVimMode("ClozeStay")) {
      Gosub ClozeStay
    } else if (this.Vim.State.StrIsInCurrentVimMode("ClozeHinter")) {
      Gosub ClozeHinter
    } else if (this.Vim.State.StrIsInCurrentVimMode("Cloze")) {
      send !z
      this.Vim.State.SetMode("Vim_Normal")
    } else if (this.Vim.State.StrIsInCurrentVimMode("AltT")) {
      Send !t
      this.Vim.State.SetMode("Vim_Normal")
    } else if (this.Vim.State.StrIsInCurrentVimMode("AltQ")) {
      Send !q
      WinWaitActive, ahk_class TChoicesDlg
      send % this.KeyAfterSMAltQ
      send {enter}
      this.Vim.State.SetMode("Vim_Normal")
    }
    this.Vim.State.SetMode("", 0, 0)
    if (ydc_y) {
      send {Left}{Right}
    }
    ; Sometimes, when using `c`, the control key would be stuck down afterwards.
    ; This forces it to be up again afterwards.
    send {Ctrl Up}
    if !WinActive("ahk_exe iexplore.exe")
      send {alt up}
    if (this.Vim.State.IsCurrentVimMode("Vim_VisualFirst") || this.Vim.State.StrIsInCurrentVimMode("Inner"))
      this.vim.state.setmode("Vim_VisualChar")
  }

  Home() {
    if WinActive("ahk_group VimDoubleHomeGroup") {
      send {Home}
    } else if WinActive("ahk_exe notepad++.exe") {
      send {end}
    }
    send {Home}
  }

  Up(n:=1) {
    if this.Vim.State.StrIsInCurrentVimMode("Paragraph") && this.Vim.IsHTML()
      if (shift == 1)
        this.SelectParagraphUp(n)
      else
        this.ParagraphUp(n)
    else if WinActive("ahk_group VimCtrlUpDownGroup")
      Send ^{Up %n%}
    else
      Send {Up %n%}
  }

  Down(n:=1) {
    if this.Vim.State.StrIsInCurrentVimMode("Paragraph") && this.Vim.IsHTML()
      if (shift == 1)
        this.SelectParagraphDown(n)
      else
        this.ParagraphDown(n)
    else if WinActive("ahk_group VimCtrlUpDownGroup")
      Send ^{Down %n%}
    else
      Send {Down %n%}
  }

  ParagraphUp(n:=1) {
    if this.Vim.IsHTML()
      if this.Vim.SM.IsEditingHTML()
        send ^+{up %n%}{left}
      else
        send ^{up %n%}
    else {
      this.up(n)
      send {end}
      this.home()
    }
  }
  
  ParagraphDown(n:=1) {
    if this.Vim.IsHTML()
      send ^{down %n%}
    else {
      this.down(n)
      send {end}
      this.home()
    }
  }

  SelectParagraphUp(n:=1) {
    if this.Vim.IsHTML()
      send ^+{up %n%}
    else {
      n -= 1
      send +{up %n%}+{home}
    }
  }

  SelectParagraphDown(n:=1) {
    if this.Vim.IsHTML()
      send ^+{down %n%}
    else {
      n -= 1
      send +{down %n%}+{end}
    }
  }

  HandleHTMLSelection() {
    if this.Vim.IsHTML() {
      if this.Vim.SM.IsEditingHTML() {
        selection := clip()
        if InStr(selection, "--------------------------------------------------------------------------------")  ; <hr> tag
          send +{left}
        if InStr(selection, "`r`n")  ; do not include line break
          send +{left}
      } else
        send +{left}
    }
  }

  Move(key="", repeat:=false, NoInitialize:=false, NoFinalize:=false, ForceNoShift:=false) {
    if (!repeat && !NoInitialize)
      this.MoveInitialize(key)

    ; Left/Right
    if (not this.Vim.State.StrIsInCurrentVimMode("Line")) && !this.Vim.State.StrIsInCurrentVimMode("Paragraph") {
      ; For some cases, need '+' directly to continue to select
      ; especially for cases using shift as original keys
      ; For now, caret does not work even add + directly

      ; 1 character
      if (key == "h") {
        if WinActive("ahk_group VimQdir") {
          send {BackSpace down}{BackSpace up}
        } else if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
          ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
          if (XCoord) {
            SendMessage, 0x114, 0, 0, Internet Explorer_Server2, A ; scroll left
          } else {
            SendMessage, 0x114, 0, 0, Internet Explorer_Server1, A ; scroll left
          }
        } else {
          send {Left}
        }
      } else if (key == "l") {
        if WinActive("ahk_group VimQdir") {
          send {Enter}
        } else if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
          ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
          if (XCoord) {
            SendMessage, 0x114, 1, 0, Internet Explorer_Server2, A ; scroll right
          } else {
            SendMessage, 0x114, 1, 0, Internet Explorer_Server1, A ; scroll left
          }
        } else {
          send {Right}
        }
      ; Home/End
      } else if (key == "0") {
        this.Home()
      } else if (key == "$") {
        if (this.shift == 1) && !ForceNoShift {
          send +{End}
        } else {
          send {End}
        }
      } else if (key == "^") {
        if (this.shift == 1) && !ForceNoShift {
          if WinActive("ahk_group VimCaretMove") {
            send +{Home}
            send +^{Right}
            send +^{Left}
          } else {
            send +{Home}
          }
        } else {
          if WinActive("ahk_group VimCaretMove") {
            this.Home()
            send ^{Right}
            send ^{Left}
          } else {
            this.Home()
            if WinActive("ahk_exe notepad++.exe")
              send {home}
          }
        }
      } else if (key == "+") {
        if (this.shift == 1) && !ForceNoShift {
          send +{down}+{end}+{home}
        } else {
          send {down}{end}{home}
        }
      } else if (key == "-") {
        if (this.shift == 1) && !ForceNoShift {
          send +{up}+{end}+{home}
        } else {
          send {up}{end}{home}
        }
      ; Words
      } else if (key == "w") {
        if (this.shift == 1) && !ForceNoShift {
          send +^{Right}
        } else {
          send ^{Right}
        }
      } else if (key == "e") {
        if (this.Vim.State.g) {  ; ge
          if (this.shift == 1) && !ForceNoShift {
            StrBefore := ""
            if (!this.NoSelection()) {  ; determine caret position
              StrBefore := this.Vim.ParseLineBreaks(clip())
              send +{left}
              StrAfter := this.Vim.ParseLineBreaks(clip())
              send +{right}
            }
            if !StrBefore || StrLen(StrAfter) > StrLen(StrBefore) {
              send +{home}
              StrAfter := this.Vim.ParseLineBreaks(clip())
              if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
                send +{left}+{home}
                StrAfter := this.Vim.ParseLineBreaks(clip())
              }
              length := StrLen(StrAfter) - StrLen(StrBefore)
              DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
              pos := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
              right := StrLen(DetectionStr) - pos
              SendInput +{right %right%}
            } else if StrLen(StrAfter) < StrLen(StrBefore) {
              DetectionStr := StrReverse(StrBefore)
              pos := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
              if pos {
                left := pos - 1
                if (pos == 1) {
                  this.SearchOccurrence += 1
                  NextOccurrence := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
                  if NextOccurrence
                    left := NextOccurrence - 1
                }
                SendInput +{left %left%}
              }
            }
          } else {
            send +{home}
            DetectionStr := this.Vim.ParseLineBreaks(clip())
            if !DetectionStr {  ; start of line
              send {left}+{home}
              DetectionStr := this.Vim.ParseLineBreaks(clip())
            }
            DetectionStr := StrReverse(DetectionStr)
            pos := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
            SendInput {right}{left %pos%}
          }
        } else if (this.shift == 1) && !ForceNoShift {
          StrBefore := ""
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(clip())
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            send +{left}
          }
          if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
            send +{end}
            this.HandleHTMLSelection()
            StrAfter := this.Vim.ParseLineBreaks(clip())
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}+{end}
              this.HandleHTMLSelection()
              StrAfter := this.Vim.ParseLineBreaks(clip())
            }
            starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, starting_pos)  ; what's selected after +end
            pos := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
            left := StrLen(DetectionStr) - pos
            if pos {
              left += 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
                if NextOccurrence
                  left := StrLen(DetectionStr) - NextOccurrence + 1
              }
            }
            ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
            SendInput +{left %left%}
          } else if (StrLen(StrAfter) < StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
            if pos {
              right := pos - 2
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
                if (NextOccurrence > 1)
                  right := NextOccurrence - 2
                else
                  right := 0
              }
              ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
              SendInput +{right %right%}
            }
          }
        } else {
          send +{end}
          DetectionStr := this.Vim.ParseLineBreaks(clip())
          if !DetectionStr {  ; end of line
            send {right}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          } else if this.Vim.IsWhitespaceOnly(DetectionStr) {
            send {right 2}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          }
          pos := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
          if (pos) {
            right := pos - 1
            if (pos == 1) {
              this.SearchOccurrence += 1
              NextOccurrence := RegExMatch(DetectionStr, "^(?:[^A-Za-zÀ-ÖØ-öø-ÿ]*[A-Za-zÀ-ÖØ-öø-ÿ]*){" . this.SearchOccurrence . "}\K([^A-Za-zÀ-ÖØ-öø-ÿ]|$)")
              if NextOccurrence
                right := NextOccurrence - 1
            }
          } else {
            right := 0
          }
          SendInput {left}{right %right%}
        }
      } else if (key == "b") {
        if (this.shift == 1) && !ForceNoShift {
          send +^{Left}
        } else {
          send ^{Left}
        }
      } else if (key == "f") {  ; find forward
        if (this.shift == 1) && !ForceNoShift {
          StrBefore := ""
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(clip())
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            send +{left}
          }
          if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
            send +{end}
            this.HandleHTMLSelection()
            StrAfter := this.Vim.ParseLineBreaks(clip())
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}+{end}
              this.HandleHTMLSelection()
              StrAfter := this.Vim.ParseLineBreaks(clip())
            }
            starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, starting_pos)  ; what's selected after +end
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)  ; find in what's selected after
            left := StrLen(DetectionStr) - pos  ; goes back
            ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
            SendInput +{left %left%}
          } else if (StrLen(StrAfter) < StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)  ; find in what's selected after
            if pos {
              right := pos - 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                if NextOccurrence
                  right := NextOccurrence - 1
              }
              ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
              SendInput +{right %right%}
            }
          }
        } else {
          send +{end}
          DetectionStr := this.Vim.ParseLineBreaks(clip())
          if !DetectionStr {  ; end of line
            send {right}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          } else if this.Vim.IsWhitespaceOnly(DetectionStr) {
            send {right 2}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          }
          pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
          if (pos) {
            right := pos - 1
            if (pos == 1) {
              this.SearchOccurrence += 1
              NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
              if NextOccurrence
                right := NextOccurrence - 1
            }
          } else {
            right := 0
          }
          SendInput {left}{right %right%}
        }
      } else if (key == "t") {
        if (this.shift == 1) && !ForceNoShift {
          StrBefore := ""
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(clip())
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            send +{left}
          }
          if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
            send +{end}
            this.HandleHTMLSelection()
            StrAfter := this.Vim.ParseLineBreaks(clip())
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}+{end}
              this.HandleHTMLSelection()
              StrAfter := this.Vim.ParseLineBreaks(clip())
            }
            starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, starting_pos)  ; what's selected after +end
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)  ; find in what's selected after
            left := StrLen(DetectionStr) - pos
            if pos {
              left += 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                if NextOccurrence
                  left := StrLen(DetectionStr) - NextOccurrence + 1
              }
            }
            ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
            SendInput +{left %left%}
          } else if (StrLen(StrAfter) < StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            if pos {
              right := pos - 2
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                if (NextOccurrence > 1)
                  right := NextOccurrence - 2
                else
                  right := 0
              }
              ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
              SendInput +{right %right%}
            }
          }
        } else {
          send +{end}
          DetectionStr := this.Vim.ParseLineBreaks(clip())
          if !DetectionStr {  ; end of line
            send {right}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          } else if this.Vim.IsWhitespaceOnly(DetectionStr) {
            send {right 2}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          }
          pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
          if (pos) {
            right := pos - 2
            if (pos == 1 || pos == 2)  {
              this.SearchOccurrence += 1
              NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
              if NextOccurrence
                right := NextOccurrence - 2
            }
          } else {
            right := 0
          }
          SendInput {left}{right %right%}
        }
      } else if (key == "+f") {
        if (this.shift == 1) && !ForceNoShift {
          StrBefore := ""
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(clip())
            send +{left}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            send +{right}
          }
          if !StrBefore || StrLen(StrAfter) > StrLen(StrBefore) {
            send +{home}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              send +{left}+{home}
              StrAfter := this.Vim.ParseLineBreaks(clip())
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos
            ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
            SendInput +{right %right%}
          } else if StrLen(StrAfter) < StrLen(StrBefore) {
            DetectionStr := StrReverse(StrBefore)
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            if pos {
              left := pos - 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                if NextOccurrence
                  left := NextOccurrence - 1
              }
              ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
              SendInput +{left %left%}
            }
          }
        } else {
          send +{home}
          DetectionStr := this.Vim.ParseLineBreaks(clip())
          if !DetectionStr {  ; start of line
            send {left}+{home}
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
          SendInput {right}{left %pos%}
        }
      } else if (key == "+t") {
        if (this.shift == 1) && !ForceNoShift {
          StrBefore := ""
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(clip())
            send +{left}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            send +{right}
          }
          if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {
            send +{home}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              send +{left}+{home}
              StrAfter := this.Vim.ParseLineBreaks(clip())
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos
            if (pos) {
              right += 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                if (NextOccurrence)
                  right := StrLen(DetectionStr) - NextOccurrence + 1
              }
            }
            ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
            SendInput +{right %right%}
          } else if StrLen(StrAfter) < StrLen(StrBefore) {
            DetectionStr := StrReverse(StrBefore)
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            if pos {
              left := pos - 2
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                if (pos == 1 && NextOccurrence == 2) {  ; in instance like "see"
                  this.SearchOccurrence += 1
                  NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                  if NextOccurrence
                    left := NextOccurrence - 2
                } else if (NextOccurrence > 1) {
                  left := NextOccurrence - 2
                } else {
                  left := 0
                }
              }
              ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
              SendInput +{left %left%}
            }
          }
        } else {
          send +{home}
          DetectionStr := this.Vim.ParseLineBreaks(clip())
          if (!DetectionStr) {  ; start of line
            send {left}+{home}
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
          if (pos) {
            left := pos - 1
            if (pos == 1) {
              this.SearchOccurrence += 1
              NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
              if NextOccurrence
                left := NextOccurrence - 1
            }
          } else {
            left := 0
          }
          SendInput {right}{left %left%}
        }
      } else if (key == ")") {  ; like "f" but search for ". "
        if (this.shift == 1) && !ForceNoShift {
          StrBefore := ""
          if !this.NoSelection() {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(clip())
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            send +{left}
          }
          if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {
            this.SelectParagraphDown()
            this.HandleHTMLSelection()
            StrAfter := this.Vim.ParseLineBreaks(clip())
            if (StrLen(StrAfter) == StrLen(StrBefore) + 1) {  ; at end of paragraph
              send +{right}
              this.SelectParagraphDown()
              this.HandleHTMLSelection()
              StrAfter := this.Vim.ParseLineBreaks(clip())
            }
            starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, starting_pos)  ; what's selected after +end
            pos := InStr(DetectionStr, ". ", true,, this.SearchOccurrence)  ; find in what's selected after
            left := StrLen(DetectionStr) - pos - 1  ; - 1 because ". "
            if !pos && (InStr(DetectionStr, ".", true,, this.SearchOccurrence) == Strlen(DetectionStr))  ; try to search if there's a last dot
              send +{right}  ; if there is a last dot, move to start of next paragraph
            else
              SendInput +{left %left%}
          } else if StrLen(StrAfter) < StrLen(StrBefore) {  ; search in selected text
            pos := InStr(StrBefore, ". ", true,, this.SearchOccurrence)
            right := pos
            if pos {
              right += 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(StrBefore, ". ", true,, this.SearchOccurrence)
                if NextOccurrence
                  right := pos + 1
              }
            }
            SendInput +{right %right%}
          }
            } else {
          this.SelectParagraphDown()
          DetectionStr := this.Vim.ParseLineBreaks(clip())
          if !DetectionStr || this.Vim.IsWhitespaceOnly(DetectionStr) {  ; end of paragraph
            send {right}
            this.SelectParagraphDown()  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(clip())
            if !DetectionStr {  ; still end of paragraph
              send {right}
              this.SelectParagraphDown()  ; to the next line
              DetectionStr := this.Vim.ParseLineBreaks(clip())
            }
          }
          pos := InStr(DetectionStr, ". ", true,, this.SearchOccurrence)
          if pos {
            right := pos + 1
            SendInput {left}{right %right%}
          } else
            send {right}
        }
      } else if (key == "(") {  ; like "+t"
        if (this.shift == 1) && !ForceNoShift {
          StrBefore := ""
          if !this.NoSelection() {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(clip())
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            send +{left}
          }
          if (StrLen(StrAfter) > StrLen(StrBefore)) {  ; search in selected text
            DetectionStr := StrReverse(StrBefore)
            pos := InStr(DetectionStr, " .", true,, this.SearchOccurrence)
            left := pos - 2
            if pos {
              left += 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, " .", true,, this.SearchOccurrence)
                if NextOccurrence
                  left := NextOccurrence - 1
              }
            }
            SendInput +{left %left%}
          } else if (StrLen(StrAfter) < StrLen(StrBefore)) || !StrBefore {
            this.SelectParagraphUp()
            StrAfter := this.Vim.ParseLineBreaks(clip())
            if !StrAfter {  ; start of line
              send {left}
              this.SelectParagraphUp()
              StrAfter := this.Vim.ParseLineBreaks(clip())
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := InStr(DetectionStr, " .", true,, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos
            if pos {
              right += 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, " .", true,, this.SearchOccurrence)
                if NextOccurrence
                  right := StrLen(DetectionStr) - NextOccurrence + 1
                else
                  ret := true
              }
            } else
              ret := true
            if ret
              ret := false
            else
              SendInput +{right %right%}
          }
            } else {
          this.SelectParagraphUp()
          DetectionStr := this.Vim.ParseLineBreaks(clip())
          if !DetectionStr {  ; start of line
            send {left}
            this.SelectParagraphUp()
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := InStr(DetectionStr, " .", true,, this.SearchOccurrence)
          if pos {
            left := pos - 1
            if (pos == 1) {
              this.SearchOccurrence += 1
              NextOccurrence := InStr(DetectionStr, " .", true,, this.SearchOccurrence)
              if NextOccurrence
                left := NextOccurrence - 1
              else
                ret := true
            }
          } else
            ret := true
          if ret {
            send {left}
            ret := false
          } else
            SendInput {right}{left %left%}
        }
      } else if (key == "s") {
        if (this.shift == 1) && !ForceNoShift {
          StrBefore := ""
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(clip())
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            send +{left}
          }
          if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
            send +{end}
            this.HandleHTMLSelection()
            StrAfter := this.Vim.ParseLineBreaks(clip())
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}+{end}
              this.HandleHTMLSelection()
              StrAfter := this.Vim.ParseLineBreaks(clip())
            }
            starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, starting_pos)  ; what's selected after +end
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)  ; find in what's selected after
            left := StrLen(DetectionStr) - pos
            if pos {
              left += 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                if NextOccurrence
                  left := StrLen(DetectionStr) - NextOccurrence + 1
              }
            }
            ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
            SendInput +{left %left%}
          } else if (StrLen(StrAfter) < StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            if pos {
              right := pos - 2
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                if (NextOccurrence > 1)
                  right := NextOccurrence - 2
                else
                  right := 0
              }
              ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
              SendInput +{right %right%}
            }
          }
        } else {
          send +{end}
          DetectionStr := this.Vim.ParseLineBreaks(clip())
          if !DetectionStr {  ; end of line
            send {right}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          } else if this.Vim.IsWhitespaceOnly(DetectionStr) {
            send {right 2}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          }
          pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
          if pos {
            right := pos - 1
            if (pos == 1) {
              this.SearchOccurrence += 1
              NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
              if NextOccurrence
                right := NextOccurrence - 1
            }
          } else
            right := 0
          SendInput {left}{right %right%}
        }
      } else if (key == "+s") {
        this.FtsChar := StrReverse(this.FtsChar)
        if (this.shift == 1) && !ForceNoShift {
          StrBefore := ""
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(clip())
            send +{left}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            send +{right}
          }
          if !StrBefore || StrLen(StrAfter) > StrLen(StrBefore) {
            send +{home}
            StrAfter := this.Vim.ParseLineBreaks(clip())
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              send +{left}+{home}
              StrAfter := this.Vim.ParseLineBreaks(clip())
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos - 1
            ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
            SendInput +{right %right%}
          } else if (StrLen(StrAfter) < StrLen(StrBefore)) {
            DetectionStr := StrReverse(StrBefore)
            pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
            if pos {
              left := pos + 1
              if (pos == 1) {
                this.SearchOccurrence += 1
                NextOccurrence := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
                if NextOccurrence
                  left := NextOccurrence + 1
              }
              ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift below
              SendInput +{left %left%}
            }
          }
        } else {
          send +{home}
          DetectionStr := this.Vim.ParseLineBreaks(clip())
          if !DetectionStr {  ; start of line
            send {left}+{home}
            DetectionStr := this.Vim.ParseLineBreaks(clip())
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := InStr(DetectionStr, this.FtsChar, true,, this.SearchOccurrence)
          pos := pos ? pos + 1 : 0
          SendInput {right}{left %pos%}
        }
      } else if (key == "/") {
        WinGet, hwnd, ID, A
        InputBoxPrompt := " text until:`n(case sensitive)"
        InputBoxHeight := 144
          if this.Vim.State.StrIsInCurrentVimMode("Visual")
          InputBoxPrompt := "Select" . InputBoxPrompt
          else if this.Vim.State.StrIsInCurrentVimMode("ydc_y")
          InputBoxPrompt := "Copy" . InputBoxPrompt
          else if this.Vim.State.StrIsInCurrentVimMode("ydc_d")
          InputBoxPrompt := "Delete" . InputBoxPrompt
          else if this.Vim.State.StrIsInCurrentVimMode("ydc_c") {
          InputBoxPrompt := "Delete" . InputBoxPrompt . "`n(will enter insert mode)"
          InputBoxHeight := 160
        } else if this.Vim.State.StrIsInCurrentVimMode("Extract")
          InputBoxPrompt := "Extract" . InputBoxPrompt
          else if this.Vim.State.StrIsInCurrentVimMode("Cloze")
          InputBoxPrompt := "Cloze" . InputBoxPrompt
        InputBox, UserInput, Visual Search, % InputBoxPrompt,, 272, % InputBoxHeight,,,,, % this.LastSearch
        if ErrorLevel || !UserInput
          Return
        this.LastSearch := UserInput  ; register UserInput into LastSearch
        StrBefore := ""
        WinActivate, ahk_id %hwnd%
        if !this.NoSelection() {  ; determine caret position
          StrBefore := this.Vim.ParseLineBreaks(clip())
          send +{right}
          StrAfter := this.Vim.ParseLineBreaks(clip())
          send +{left}
        }
        if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {
          this.SelectParagraphDown()
          this.HandleHTMLSelection()
          StrAfter := this.Vim.ParseLineBreaks(clip())
          if (StrLen(StrAfter) == StrLen(StrBefore) + 1) {  ; at end of paragraph
            send +{right}
            this.SelectParagraphDown()
            this.HandleHTMLSelection()
            StrAfter := this.Vim.ParseLineBreaks(clip())
          }
          starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
          DetectionStr := SubStr(StrAfter, starting_pos)
          pos := InStr(DetectionStr, UserInput, true,, this.SearchOccurrence)
          left := StrLen(DetectionStr) - pos + 1
          if (pos == 1) {
            this.SearchOccurrence += 1
            NextOccurrence := InStr(DetectionStr, UserInput, true,, this.SearchOccurrence)
            if NextOccurrence
              left := StrLen(DetectionStr) - NextOccurrence + 1
          }
          SendInput +{left %left%}
        } else if (StrLen(StrAfter) < StrLen(StrBefore)) {
          pos := InStr(StrBefore, UserInput, true)
          pos -= pos ? 1 : 0
          SendInput +{right %pos%}
        }
      } else if (key == "?") {
        WinGet, hwnd, ID, A
        InputBoxPrompt := " text until:`n(case sensitive)"
        InputBoxHeight := 144
          if this.Vim.State.StrIsInCurrentVimMode("Visual")
          InputBoxPrompt := "Select" . InputBoxPrompt
          else if this.Vim.State.StrIsInCurrentVimMode("ydc_y")
          InputBoxPrompt := "Copy" . InputBoxPrompt
          else if this.Vim.State.StrIsInCurrentVimMode("ydc_d")
          InputBoxPrompt := "Delete" . InputBoxPrompt
          else if this.Vim.State.StrIsInCurrentVimMode("ydc_c") {
          InputBoxPrompt := "Delete" . InputBoxPrompt . "`n(will enter insert mode)"
          InputBoxHeight := 160
        } else if this.Vim.State.StrIsInCurrentVimMode("Extract")
          InputBoxPrompt := "Extract" . InputBoxPrompt
          else if this.Vim.State.StrIsInCurrentVimMode("Cloze")
          InputBoxPrompt := "Cloze" . InputBoxPrompt
        InputBox, UserInput, Visual Search, % InputBoxPrompt,, 272, % InputBoxHeight,,,,, % this.LastSearch
        if ErrorLevel || !UserInput
          Return
        this.LastSearch := UserInput  ; register UserInput into LastSearch
        StrBefore := ""
        WinActivate, ahk_id %hwnd%
        if !this.NoSelection() {  ; determine caret position
          StrBefore := this.Vim.ParseLineBreaks(clip())
          send +{right}
          StrAfter := this.Vim.ParseLineBreaks(clip())
          send +{left}
        }
        if (StrLen(StrAfter) > StrLen(StrBefore)) {
          pos := InStr(StrReverse(StrBefore), StrReverse(UserInput), true)
          pos += pos ? StrLen(UserInput) - 2 : 0
          SendInput +{left %pos%}
        } else if (StrLen(StrAfter) < StrLen(StrBefore)) || !StrBefore {
          this.SelectParagraphUp()
          StrAfter := this.Vim.ParseLineBreaks(clip())
          if !StrAfter {  ; start of line
            send {left}
            this.SelectParagraphUp()
            StrAfter := this.Vim.ParseLineBreaks(clip())
          }
          starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
          DetectionStr := SubStr(StrReverse(StrAfter), starting_pos)
          pos := InStr(DetectionStr, StrReverse(UserInput), true,, this.SearchOccurrence)
          right := StrLen(DetectionStr) - pos - StrLen(UserInput) + 1
          SendInput +{right %right%}
        }
      }
    }
    ; Up/Down 1 character
    if (key == "j") {
      if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
        if (XCoord) {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server2, A ; scroll down
        } else {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A ; scroll down
        }
      } else {
        this.Down()
      }
    } else if (key == "^e") {
      if (WinActive("ahk_exe WINWORD.exe")) {
        ReleaseKey("ctrl")
        send {WheelDown}{CtrlDown}
      } else {
        SendMessage, 0x0115, 1, 0, % ControlGetFocus(), A ; scroll down
      }
    } else if (key == "k") {
      if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
        if (XCoord) {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server2, A ; scroll up
        } else {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A ; scroll up
        }
      } else {
        this.Up()
      }
    } else if (key == "^y") {
      if (WinActive("ahk_exe WINWORD.exe")) {
        ReleaseKey("ctrl")
        send {WheelUp}{CtrlDown}
      } else {
        SendMessage, 0x0115, 0, 0, % ControlGetFocus(), A
      }
    ; Page Up/Down
    n := 10
    } else if (key == "^u") {
      if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
        if (XCoord) {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server2, A ; scroll up
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server2, A ; scroll up
        } else {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A ; scroll up
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A ; scroll up
        }
      } else {
        this.Up(10)
      }
    } else if (key == "^d") {
      if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
        if (XCoord) {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server2, A ; scroll down
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server2, A ; scroll down
        } else {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A ; scroll down
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A ; scroll down
        }
      } else {
        this.Down(10)
      }
    } else if (key == "^b") {
      send {PgUp}
    } else if (key == "^f") {
      send {PgDn}
    } else if (key == "g") {
      if (this.Vim.State.n > 0) {
        line := this.Vim.State.n - 1
        this.Vim.State.n := 0
        if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {  ; browsing
          send ^t
          this.Vim.SM.WaitTextFocus()
        } else if (WinActive("ahk_class TContents")) {
					ClickDPIAdjusted(295, 50)  ; ControlClickWinCoord() doesn't work well
        } else if (WinActive("ahk_class TBrowser")) {
					ClickDPIAdjusted(638, 46)
        }
        SendInput ^{home}{down %line%}
        if (WinActive("ahk_class TContents")) {
					ClickDPIAdjusted(295, 50)
        } else if (WinActive("ahk_class TBrowser")) {
					ClickDPIAdjusted(638, 46)
        }
      } else if (this.Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
        ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
        if (XCoord) {
          ControlSend, Internet Explorer_Server2, {home}
        } else {
          ControlSend, Internet Explorer_Server1, {home}
        }
      } else {
        send ^{Home}
      }
    } else if (key == "+g") {
        ReleaseKey("shift")
        if (this.Vim.State.n > 0) {
          line := this.Vim.State.n - 1
          this.Vim.State.n := 0
          if (WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {  ; browsing
            this.Vim.SM.ClickTop()
            this.Vim.SM.WaitTextFocus()
          } else if (this.Vim.SM.IsEditingText()) {
            this.Vim.SM.ClickTop()
          } else if (WinActive("ahk_class TContents")) {
            ClickDPIAdjusted(295, 50)
            send ^{home}
          } else if (WinActive("ahk_class TBrowser")) {
            ClickDPIAdjusted(638, 46)
            send ^{home}
          } else {
            send ^{home}
          }
          SendInput {down %line%}
          if (WinActive("ahk_class TContents")) {
            ClickDPIAdjusted(295, 50)
          } else if (WinActive("ahk_class TBrowser")) {
            ClickDPIAdjusted(638, 46)
          }
        } else if (this.Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()) {
          ControlGetPos, XCoord,,,, Internet Explorer_Server2, ahk_class TElWind
          if (XCoord) {
            ControlSend, Internet Explorer_Server2, {end}
          } else {
            ControlSend, Internet Explorer_Server1, {end}
          }
        } else {
          if (this.shift == 1) {
            send ^+{End}+{Home}
          } else {
            send ^{End}
            if (!WinActive("ahk_exe iexplore.exe") && !WinActive("ahk_class TContents"))
              send {Home}
          }
          if (this.Vim.SM.IsEditingHTML()) {
            send ^+{up}  ; if there are references this would select (or deselect in visual mode) them all
            if (this.shift == 1)
              send +{down}  ; go down one line, if there are references this would include the #SuperMemo Reference
            if (InStr(clip(), "#SuperMemo Reference:")) {
              if (this.shift == 1) {
                send +{up 4}  ; select until start of last line
              } else {
                send {up 3}  ; go to start of last line
              }
              if (this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
                send +{end}
            } else {
              if (this.shift == 1) {
                send ^+{end}
                if (!this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
                  send +{home}
              } else {
                send ^{end}
                if (!this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
                  send {home}
              }
            }
          }
        }
    } else if (key == "{") {
      if (this.Vim.State.n > 0 && WinActive("ahk_class TElWind") && !repeat) {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
        paragraph := this.Vim.State.n - 1
        this.Vim.State.n := 0
        if (!this.Vim.SM.IsEditingText()) {
          send ^t
          this.Vim.SM.WaitTextFocus()
        }
        send ^{home}
        this.ParagraphDown(paragraph)
      } else if (this.shift == 1 && !ForceNoShift) {
        this.SelectParagraphUp()
      } else {
        this.ParagraphUp()
      }
    } else if (key == "}") {
      if (this.Vim.State.n > 0 && WinActive("ahk_class TElWind") && !repeat) {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
        paragraph := this.Vim.State.n - 1
        this.Vim.State.n := 0
        ReleaseKey("shift")
        this.Vim.SM.ClickTop()
        this.Vim.SM.WaitTextFocus()
        this.ParagraphDown(paragraph)
      } else if (this.shift == 1 && !ForceNoShift) {
        this.SelectParagraphDown()
      } else {
        this.ParagraphDown()
      }
    }

    if (!repeat && !NoFinalize)
      this.MoveFinalize()
  }

  Repeat(key="") {
    this.MoveInitialize(key)
    if (this.Vim.State.n == 0) {
      this.Vim.State.n := 1
    }
    if (WinActive("ahk_class TContents")) && (key = "j" || key = "k") && (this.Vim.State.n > 1) {
      ControlClickWinCoord(295, 50)
    } else if (WinActive("ahk_class TBrowser")) && (key = "j" || key = "k") && (this.Vim.State.n > 1) {
			ControlClickWinCoord(638, 46)
		}
		Loop, % this.Vim.State.n {
			this.Move(key, true)
		}
    if (WinActive("ahk_class TContents")) && (key = "j" || key = "k") && (this.Vim.State.n > 1) {
      ControlClickWinCoord(295, 50)
    } else if (WinActive("ahk_class TBrowser")) && (key = "j" || key = "k") && (this.Vim.State.n > 1) {
			ControlClickWinCoord(638, 46)
		}
    this.MoveFinalize()
  }

  YDCMove() {
    this.Vim.State.LineCopy := 1
    this.Home()
    send {Shift Down}
    if (this.Vim.State.n == 0) {
      this.Vim.State.n := 1
    }
    this.Down(this.Vim.State.n - 1)
    if (WinActive("ahk_group VimLBSelectGroup") && this.Vim.State.n == 2)
      send {right}
    send {End}
    if (this.Vim.State.IsCurrentVimMode("Vim_ydc_c"))
      send {left}
    if (this.Vim.State.StrIsInCurrentVimMode("SMVim_") && this.Vim.SM.IsEditingHTML())
      send {left}
    if (!WinActive("ahk_group VimLBSelectGroup")) {
      this.Move("l")
    } else {
      this.Move("")
    }
  }

  Inner(key="") {
    if (key == "w") {
      send ^{right}^{left}
      this.Move("e")
    } else if (key == "s") {
      send {right}  ; so if at start of a sentence, select this sentence
      this.Move("(",,, true, true)
      this.Move(")",,, true)
      this.Vim.State.SetMode("",, 2)
      this.Repeat("h")
    } else if (key == "p") {
      this.ParagraphDown()
      this.ParagraphUp()
      this.SelectParagraphDown()
      this.HandleHTMLSelection()
      DetectionStr := this.Vim.ParseLineBreaks(clip())
      DetectionStr := StrReverse(DetectionStr)
      pos := RegExMatch(DetectionStr, "^((\s+)[.]|[.]|(\s+))", match)
      if (StrLen(match)) {
        this.Vim.State.SetMode("",, StrLen(match))
        this.Repeat("h")
      } else {
        this.MoveFinalize()
      }
    }
  }
}