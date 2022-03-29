class VimMove{
  __New(vim) {
    this.Vim := vim
    this.shift := 0
  }
  
  ExisitingSelection() {  ; only return true once in repeat
  if !this.existing_selection && (this.Vim.State.StrIsInCurrentVimMode("VisualFirst") || this.Vim.State.StrIsInCurrentVimMode("ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_") || this.Vim.State.StrIsInCurrentVimMode("Inner")) {
    this.existing_selection := true
    Return true
  }
  }

  MoveInitialize(key="") {
    this.shift := 0
  this.existing_selection := false
  
  ; Search keys
  if (key == "f" || key == "t" || key == "+f" || key == "+t" || key == "(" || key == ")" || key == "/" || key == "?") {
    this.search_occurrence := this.Vim.State.n ? this.Vim.State.n : 1
    this.ft_char := this.Vim.State.ft_char
  }
  
    if (this.Vim.State.StrIsInCurrentVimMode("Visual") or this.Vim.State.StrIsInCurrentVimMode("ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_")) {
      this.shift := 1
    ; Search keys
    if (key != "f" && key != "t" && key != "+f" && key != "+t" && key != "(" && key != ")" && key != "/" && key != "?")
    Send, {Shift Down}
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g") {
      Send, {Shift Up}{End}
      this.Home()
      Send, {Shift Down}
      this.Up()
      this.vim.state.setmode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g") {
      this.vim.state.setmode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g") {
      Send, {Shift Up}{right}{left}{Shift Down}
      this.Up()
      this.vim.state.setmode("Vim_VisualParagraph",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g") {
      this.vim.state.setmode("Vim_VisualParagraph",, -1)  ; -1 is needed for repeat to work
    }
  
    if (this.Vim.State.IsCurrentVimMode("Vim_VisualBlock") && WinActive("ahk_exe notepad++.exe")) {
      send {alt down}
    }

    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")) and (key == "k" or key == "^u" or key == "^b" or key == "g") {
      this.Vim.State.LineCopy := 1
      Send,{Shift Up}
      this.Home()
      this.Down()
      Send, {Shift Down}
      this.Up()
    }
  
    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")) and (key == "j" or key == "^d" or key == "^f" or key == "+g") {
      this.Vim.State.LineCopy := 1
      Send,{Shift Up}
      this.Home()
      Send, {Shift Down}
      this.Down()
    }
  }

  MoveFinalize() {
    Send,{Shift Up}
    ydc_y := false
    if (this.Vim.State.StrIsInCurrentVimMode("ydc_y")) {
      Clipboard :=
      Send, ^c
      ClipWait, 1
      this.Vim.State.SetMode("Vim_Normal")
      ydc_y := true
    }else if (this.Vim.State.StrIsInCurrentVimMode("ydc_d")) {
      Clipboard :=
      Send, ^x
      ClipWait, 1
      this.Vim.State.SetMode("Vim_Normal")
    }else if (this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
      Clipboard :=
      Send, ^x
      ClipWait, 1
      this.Vim.State.SetMode("Insert")
    }else if (this.Vim.State.StrIsInCurrentVimMode("ExtractStay")) {
      Gosub extract_stay
    }else if (this.Vim.State.StrIsInCurrentVimMode("ExtractPriority")) {
      send !+x
      this.Vim.State.SetMode("Vim_Normal")
    }else if (this.Vim.State.StrIsInCurrentVimMode("Extract")) {
      Send, !x
      this.Vim.State.SetMode("Vim_Normal")
    }else if (this.Vim.State.StrIsInCurrentVimMode("ClozeStay")) {
      Gosub cloze_stay
    }else if (this.Vim.State.StrIsInCurrentVimMode("ClozeHinter")) {
      Gosub cloze_hinter
    }else if (this.Vim.State.StrIsInCurrentVimMode("Cloze")) {
      Send, !z
      this.Vim.State.SetMode("Vim_Normal")
    }
    this.Vim.State.SetMode("", 0, 0)
    if (ydc_y) {
      Send, {Left}{Right}
    }
    ; Sometimes, when using `c`, the control key would be stuck down afterwards.
    ; This forces it to be up again afterwards.
    send {Ctrl Up}
  if !WinActive("ahk_exe iexplore.exe")
    send {alt up}
  if this.Vim.State.IsCurrentVimMode("Vim_VisualFirst")
    this.vim.state.setmode("Vim_VisualChar")
  }

  Home() {
    if WinActive("ahk_group VimDoubleHomeGroup") {
      Send, {Home}
    } else if WinActive("ahk_exe notepad++.exe")
    send {end}
    Send, {Home}
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

  Move(key="", repeat=false, NoInitialize=false, NoFinalize=false, ForceNoShift=false) {
    if (!repeat) && !NoInitialize {
      this.MoveInitialize(key)
    }

    ; Left/Right
    if (not this.Vim.State.StrIsInCurrentVimMode("Line")) && !this.Vim.State.StrIsInCurrentVimMode("Paragraph") {
      ; For some cases, need '+' directly to continue to select
      ; especially for cases using shift as original keys
      ; For now, caret does not work even add + directly

      ; 1 character
      if (key == "h") {
        if WinActive("ahk_group VimQdir") {
          Send, {BackSpace down}{BackSpace up}
        }
        else {
          Send, {Left}
        }
      }else if (key == "l") {
        if WinActive("ahk_group VimQdir") {
          Send, {Enter}
        }
        else {
          Send, {Right}
        }
      ; Home/End
      }else if (key == "0") {
        this.Home()
      }else if (key == "$") {
        if (this.shift == 1) && !ForceNoShift {
          Send, +{End}
        }else{
          Send, {End}
        }
      }else if (key == "^") {
        if (this.shift == 1) && !ForceNoShift {
          if WinActive("ahk_group VimCaretMove") {
            Send, +{Home}
            Send, +^{Right}
            Send, +^{Left}
          }else{
            Send, +{Home}
          }
        }else{
          if WinActive("ahk_group VimCaretMove") {
            this.Home()
            Send, ^{Right}
            Send, ^{Left}
          }else{
            this.Home()
      if WinActive("ahk_exe notepad++.exe")
        send {home}
          }
        }
      ; Words
      }else if (key == "w") {
        if (this.shift == 1) && !ForceNoShift {
          Send, +^{Right}
        }else{
          Send, ^{Right}
        }
      }else if (key == "e") {
    if this.Vim.State.g  ; ge
      if (this.shift == 1) && !ForceNoShift {
        Send, +^{Left}+{Left}
      }else{
        Send, ^{Left}{left}
      }
        else if (this.shift == 1) && !ForceNoShift {
      if this.ExisitingSelection() {
      Send, +^{Right}+{Left}
      } else
      Send, +^{Right}+^{Right}+{Left}
        }else{
          Send, ^{Right}^{Right}{Left}
        }
      }else if (key == "b") {
        if (this.shift == 1) && !ForceNoShift {
          Send, +^{Left}
        }else{
          Send, ^{Left}
        }
      }else if (key == "f") {  ; find forward
    if (this.shift == 1) && !ForceNoShift {
      StrBefore := ""
      if !this.ExisitingSelection()
        StrBefore := this.Vim.ParseLineBreaks(clip())
      send +{end}
      this.HandleHTMLSelection()
      StrAfter := this.Vim.ParseLineBreaks(clip())
      if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
        send +{right}+{end}
        this.HandleHTMLSelection()
        StrAfter := this.Vim.ParseLineBreaks(clip())
      }
      if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
        starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure detection_str is what's selected after
        detection_str := SubStr(StrAfter, starting_pos)  ; what's selected after +end
        pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)  ; find in what's selected after
        left := StrLen(detection_str) - pos  ; goes back
        this.Vim.ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift down below
        SendInput +{left %left%}
      } else if (StrLen(StrAfter) < StrLen(StrBefore)) {
        length := StrLen(StrBefore) - StrLen(StrAfter) - 1  ; - 1 to make sure detection_str is what's unselected after
        detection_str := SubStr(StrBefore, 1, length)  ; what's unselected after +end
        pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)  ; find in what's selected after
        if pos
          left := StrLen(detection_str) - pos + 2
        else
          left := StrLen(detection_str) + 1  ; nothing is found
        if (pos == 1) {
          this.search_occurrence += 1
          next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
          if next_occurrence
            left := StrLen(detection_str) - next_occurrence + 2
        }
        this.Vim.ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift down below
        SendInput +{left %left%}
      }
    }else{
      send +{end}
      detection_str := this.Vim.ParseLineBreaks(clip())
      if !detection_str {  ; end of line
        send {right}+{end}  ; to the next line
        detection_str := this.Vim.ParseLineBreaks(clip())
      } else if this.Vim.IsWhitespaceOnly(detection_str) {
        send {right 2}+{end}  ; to the next line
        detection_str := this.Vim.ParseLineBreaks(clip())
      }
      pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
      SendInput {left}{right %pos%}
    }
      }else if (key == "t") {
    if (this.shift == 1) && !ForceNoShift {
      StrBefore := ""
      if !this.ExisitingSelection()
        StrBefore := this.Vim.ParseLineBreaks(clip())
      send +{end}
      this.HandleHTMLSelection()
      StrAfter := this.Vim.ParseLineBreaks(clip())
      if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
        send +{right}+{end}
        this.HandleHTMLSelection()
        StrAfter := this.Vim.ParseLineBreaks(clip())
      }
      if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {  ; searching forward
        starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure detection_str is what's selected after
        detection_str := SubStr(StrAfter, starting_pos)  ; what's selected after +end
        pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)  ; find in what's selected after
        left := StrLen(detection_str) - pos
        if pos {
          left += 1
          if (pos == 1) {
            this.search_occurrence += 1
            next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
            if next_occurrence
              left := StrLen(detection_str) - next_occurrence + 1
          }
        }
        this.Vim.ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift down below
        SendInput +{left %left%}
      } else if (StrLen(StrAfter) < StrLen(StrBefore)) {
        length := StrLen(StrBefore) - StrLen(StrAfter) + 1  ; + 1 to make sure detection_str is what's selected after
        detection_str := SubStr(StrBefore, 1, length)
        pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
        if pos {
          left := StrLen(detection_str) - pos + 1
          if (pos == 2 || pos == 1) {
            this.search_occurrence += 1
            next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
            if (next_occurrence > 1)
              left := StrLen(detection_str) - next_occurrence + 1
            else
              left := StrLen(detection_str) - 1
          }
        } else
          left := StrLen(detection_str) - 1
        this.Vim.ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift down below
        SendInput +{left %left%}
      }
    }else{
      send +{end}
      detection_str := this.Vim.ParseLineBreaks(clip())
      if !detection_str {  ; end of line
        send {right}+{end}  ; to the next line
        detection_str := this.Vim.ParseLineBreaks(clip())
      } else if this.Vim.IsWhitespaceOnly(detection_str) {
        send {right 2}+{end}  ; to the next line
        detection_str := this.Vim.ParseLineBreaks(clip())
      }
      pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
      if pos {
        right := pos - 1
        if (pos == 1) {
          this.search_occurrence += 1
          next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
          if next_occurrence
            right := next_occurrence - 1
        }
      } else
        right := 0
      SendInput {left}{right %right%}
    }
      }else if (key == "+f") {
    if (this.shift == 1) && !ForceNoShift {
      StrBefore := ""
      if !this.ExisitingSelection()
        StrBefore := this.Vim.ParseLineBreaks(clip())
      send +{home}
      StrAfter := this.Vim.ParseLineBreaks(clip())
      if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
        send +{left}+{home}
        StrAfter := this.Vim.ParseLineBreaks(clip())
      }
      if !StrBefore || StrLen(StrAfter) > StrLen(StrBefore) {
        length := StrLen(StrAfter) - StrLen(StrBefore)
        detection_str := StrReverse(SubStr(StrAfter, 1, length))
        pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
        right := StrLen(detection_str) - pos
        this.Vim.ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift down below
        SendInput +{right %right%}
      } else if StrLen(StrAfter) < StrLen(StrBefore) {
        length := StrLen(StrBefore) - StrLen(StrAfter) + 1  ; + 1 to make sure detection_str is what's selected after
        detection_str := SubStr(StrReverse(StrBefore), 1, length)
        pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
        if pos
          right := StrLen(detection_str) - pos
        else
          right := StrLen(detection_str) - 1
        if (pos == 1) {
          this.search_occurrence += 1
          next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
          if next_occurrence
            right := StrLen(detection_str) - next_occurrence
        }
        this.Vim.ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift down below
        SendInput +{right %right%}
      }
    }else{
      send +{home}
      detection_str := this.Vim.ParseLineBreaks(clip())
      if !detection_str {  ; start of line
        send {left}+{home}
        detection_str := this.Vim.ParseLineBreaks(clip())
      }
      detection_str := StrReverse(detection_str)
      pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
      SendInput {right}{left %pos%}
    }
      }else if (key == "+t") {
    if (this.shift == 1) && !ForceNoShift {
      StrBefore := ""
      if !this.ExisitingSelection()
        StrBefore := this.Vim.ParseLineBreaks(clip())
      send +{home}
      StrAfter := this.Vim.ParseLineBreaks(clip())
      if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
        send +{left}+{home}
        StrAfter := this.Vim.ParseLineBreaks(clip())
      }
      if !StrBefore || (StrLen(StrAfter) > StrLen(StrBefore)) {
        length := StrLen(StrAfter) - StrLen(StrBefore)
        detection_str := StrReverse(SubStr(StrAfter, 1, length))
        pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
        right := StrLen(detection_str) - pos
        if pos {
          right += 1
          if (pos == 1) {
            this.search_occurrence += 1
            next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
            if next_occurrence
              right := StrLen(detection_str) - next_occurrence + 1
          }
        }
        this.Vim.ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift down below
        SendInput +{right %right%}
      } else if StrLen(StrAfter) < StrLen(StrBefore) {
        length := StrLen(StrBefore) - StrLen(StrAfter) + 1  ; + 1 to make sure detection_str is what's selected after
        detection_str := SubStr(StrReverse(StrBefore), 1, length)
        pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
        if pos {
          right := StrLen(detection_str) - pos + 1
          if (pos == 2 || pos == 1) {
            this.search_occurrence += 1
            next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
            if (pos == 1 && next_occurrence == 2) {  ; in instance like "see"
              this.search_occurrence += 1
              next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
              if next_occurrence
                right := StrLen(detection_str) - next_occurrence + 1
            } else if (next_occurrence > 1)
              right := StrLen(detection_str) - next_occurrence + 1
            else
              right := StrLen(detection_str) - 1
          }
        } else
          right := StrLen(detection_str) - 1
        this.Vim.ReleaseKey("shift")  ; keys that need shift (like "(") would mess up the shift down below
        SendInput +{right %right%}
      }
    }else{
      send +{home}
      detection_str := this.Vim.ParseLineBreaks(clip())
      if !detection_str {  ; start of line
        send {left}+{home}
        detection_str := this.Vim.ParseLineBreaks(clip())
      }
      detection_str := StrReverse(detection_str)
      pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
      if pos {
        left := pos - 1
        if (pos == 1) {
          this.search_occurrence += 1
          next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
          if next_occurrence
            left := next_occurrence - 1
        }
      } else
        left := 0
      SendInput {right}{left %left%}
    }
      }else if (key == ")") {  ; like "f" but search for ". "
    if (this.shift == 1) && !ForceNoShift {
      StrBefore := ""
      if !this.ExisitingSelection() {  ; determine caret position
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
        starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure detection_str is what's selected after
        detection_str := SubStr(StrAfter, starting_pos)  ; what's selected after +end
        pos := InStr(detection_str, ". ", true,, this.search_occurrence)  ; find in what's selected after
        left := StrLen(detection_str) - pos - 1  ; - 1 because ". "
        if !pos && (InStr(detection_str, ".", true,, this.search_occurrence) == Strlen(detection_str))  ; try to search if there's a last dot
          send +{right}  ; if there is a last dot, move to start of next paragraph
        else
          SendInput +{left %left%}
      } else if StrLen(StrAfter) < StrLen(StrBefore) {  ; search in selected text
        pos := InStr(StrBefore, ". ", true,, this.search_occurrence)
        right := pos
        if pos {
          right += 1
          if (pos == 1) {
            this.search_occurrence += 1
            next_occurrence := InStr(StrBefore, ". ", true,, this.search_occurrence)
            if next_occurrence
              right := pos + 1
          }
        }
        SendInput +{right %right%}
      }
        }else{
      this.SelectParagraphDown()
      detection_str := this.Vim.ParseLineBreaks(clip())
      if !detection_str || this.Vim.IsWhitespaceOnly(detection_str) {  ; end of paragraph
        send {right}
        this.SelectParagraphDown()  ; to the next line
        detection_str := this.Vim.ParseLineBreaks(clip())
        if !detection_str {  ; still end of paragraph
          send {right}
          this.SelectParagraphDown()  ; to the next line
          detection_str := this.Vim.ParseLineBreaks(clip())
        }
      }
      pos := InStr(detection_str, ". ", true,, this.search_occurrence)
      if pos {
        right := pos + 1
        SendInput {left}{right %right%}
      } else
        send {right}
        }
      }else if (key == "(") {  ; like "+t"
    if (this.shift == 1) && !ForceNoShift {
      StrBefore := ""
      if !this.ExisitingSelection() {  ; determine caret position
        StrBefore := this.Vim.ParseLineBreaks(clip())
        send +{right}
        StrAfter := this.Vim.ParseLineBreaks(clip())
        send +{left}
      }
      if (StrLen(StrAfter) > StrLen(StrBefore)) {  ; search in selected text
        detection_str := StrReverse(StrBefore)
        pos := InStr(detection_str, " .", true,, this.search_occurrence)
        left := pos - 2
        if pos {
          left += 1
          if (pos == 1) {
            this.search_occurrence += 1
            next_occurrence := InStr(detection_str, " .", true,, this.search_occurrence)
            if next_occurrence
              left := next_occurrence - 1
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
        detection_str := StrReverse(SubStr(StrAfter, 1, length))
        pos := InStr(detection_str, " .", true,, this.search_occurrence)
        right := StrLen(detection_str) - pos
        if pos {
          right += 1
          if (pos == 1) {
            this.search_occurrence += 1
            next_occurrence := InStr(detection_str, " .", true,, this.search_occurrence)
            if next_occurrence
              right := StrLen(detection_str) - next_occurrence + 1
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
        }else{
      this.SelectParagraphUp()
      detection_str := this.Vim.ParseLineBreaks(clip())
      if !detection_str {  ; start of line
        send {left}
        this.SelectParagraphUp()
        detection_str := this.Vim.ParseLineBreaks(clip())
      }
      detection_str := StrReverse(detection_str)
      pos := InStr(detection_str, " .", true,, this.search_occurrence)
      if pos {
        left := pos - 1
        if (pos == 1) {
          this.search_occurrence += 1
          next_occurrence := InStr(detection_str, " .", true,, this.search_occurrence)
          if next_occurrence
            left := next_occurrence - 1
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
      }else if (key == "/") {
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
    if !this.ExisitingSelection() {  ; determine caret position
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
      starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure detection_str is what's selected after
      detection_str := SubStr(StrAfter, starting_pos)
      pos := InStr(detection_str, UserInput, true,, this.search_occurrence)
      left := StrLen(detection_str) - pos
      if (pos == 1) {
        this.search_occurrence += 1
        next_occurrence := InStr(detection_str, UserInput, true,, this.search_occurrence)
        if next_occurrence
          left := StrLen(detection_str) - next_occurrence
      }
      SendInput +{left %left%}
    } else if (StrLen(StrAfter) < StrLen(StrBefore)) {
      pos := InStr(StrBefore, UserInput, true)
      pos -= pos ? 1 : 0
      SendInput +{right %pos%}
    }
      }else if (key == "?") {
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
    if !this.ExisitingSelection() {  ; determine caret position
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
      starting_pos := StrLen(StrBefore) + 1  ; + 1 to make sure detection_str is what's selected after
      detection_str := SubStr(StrReverse(StrAfter), starting_pos)
      pos := InStr(detection_str, StrReverse(UserInput), true,, this.search_occurrence)
      right := StrLen(detection_str) - pos - StrLen(UserInput) + 1
      SendInput +{right %right%}
    }
      }
    }
    ; Up/Down 1 character
    if (key == "j") {
      this.Down()
    }else if (key="k") {
      this.Up()
    ; Page Up/Down
    n := 10
    }else if (key == "^u") {
    this.Up(10)
    }else if (key == "^d") {
    this.Down(10)
    }else if (key == "^b") {
    Send, {PgUp}
    }else if (key == "^f") {
    Send, {PgDn}
    }else if (key == "g") {
    if (this.Vim.State.n > 0) {
    line := this.Vim.State.n - 1
    this.Vim.State.n := 0
    if WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText() {  ; browsing
      send ^t
      this.Vim.SM.WaitTextFocus()
    }
    SendInput ^{home}{down %line%}
    } else if this.Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText() {
    send ^t
    this.Vim.SM.WaitTextFocus()
    send ^{home}{esc}
    } else
    Send, ^{Home}
    }else if (key == "+g") {
    if (this.Vim.State.n > 0) {
    line := this.Vim.State.n - 1
    this.Vim.State.n := 0
    if this.Vim.SM.MouseMoveTop(true) {
      this.Vim.SM.WaitTextFocus()
      send {left}{home}
    } else if WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText() {  ; browsing and no scrollbar
      send ^t
      this.Vim.SM.WaitTextFocus()
      send ^{home}
    } else
      send ^{home}
    SendInput {down %line%}
    } else if this.Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText() {
    send ^t
    this.Vim.SM.WaitTextFocus()
    send ^{end}{esc}
    } else {
      if (this.shift == 1)
      Send, ^+{End}+{Home}
    else {
      Send, ^{End}
      if !WinActive("ahk_exe iexplore.exe")
        send {Home}
    }
    if this.Vim.SM.IsEditingHTML() {
      send ^+{up}  ; if there are references this would select (or deselect in visual mode) them all
      if (this.shift == 1)
        send +{down}  ; go down one line, if there are references this would include the #SuperMemo Reference
      if InStr(clip(), "#SuperMemo Reference:")
        if (this.shift == 1)
          send +{up 4}  ; select until start of last line
        else
          send {up 3}  ; go to start of last line
      else
        if (this.shift == 1)
          send ^+{end}+{home}
        else
          send ^{end}{home}
    }
    }
    }else if (key == "{") {
    if (this.Vim.State.n > 0) && WinActive("ahk_class TElWind") && !repeat {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
    paragraph := this.Vim.State.n - 1
    this.Vim.State.n := 0
    if !this.Vim.SM.IsEditingText() {
      send ^t
      this.Vim.SM.WaitTextFocus()
    }
    send ^{home}
    this.ParagraphDown(paragraph)
      } else if (this.shift == 1) && !ForceNoShift {
      this.SelectParagraphUp()
    }else{
      this.ParagraphUp()
    }
    }else if (key == "}") {
    if (this.Vim.State.n > 0) && WinActive("ahk_class TElWind") && !repeat {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
    paragraph := this.Vim.State.n - 1
    this.Vim.State.n := 0
    if this.Vim.SM.MouseMoveTop(true) {
      this.Vim.SM.WaitTextFocus()
      this.ParagraphUp()
    } else {
      if !this.Vim.SM.IsEditingText() {
        send ^t
        this.Vim.SM.WaitTextFocus()
      }
      send ^{home}
    }
    this.ParagraphDown(paragraph)
      } else if (this.shift == 1) && !ForceNoShift {
      this.SelectParagraphDown()
    }else{
      this.ParagraphDown()
    }
    }

    if (!repeat) && !NoFinalize {
      this.MoveFinalize()
    }
  }

  Repeat(key="") {
    this.MoveInitialize(key)
    if (this.Vim.State.n == 0) {
      this.Vim.State.n := 1
    }
  if (WinActive("ahk_class TContents") || WinActive("ahk_class TBrowser")) && (key = "j" || key = "k") && (this.Vim.State.n > 1)
    FindClick(A_ScriptDir . "\lib\bind\util\element_window_sync.png",, sync_off)
    Loop, % this.Vim.State.n {
      this.Move(key, true)
    }
  if sync_off {
    FindClick(A_ScriptDir . "\lib\bind\util\element_window_sync.png")
    sync_off =
  }
    this.MoveFinalize()
  }

  YDCMove() {
    this.Vim.State.LineCopy := 1
    this.Home()
    Send, {Shift Down}
    if (this.Vim.State.n == 0) {
      this.Vim.State.n := 1
    }
    this.Down(this.Vim.State.n - 1)
    Send, {End}
  if this.Vim.State.StrIsInCurrentVimMode("SMVim_") && this.Vim.SM.IsEditingHTML()
    send +{left}
    if not WinActive("ahk_group VimLBSelectGroup") {
      this.Move("l")
    }else{
      this.Move("")
    }
  }

  Inner(key="") {
    if (key == "w") {
      this.Move("b", true)
      this.Move("e", false)
    } else if (key == "s") {
    send {right}  ; so if at start of a sentence, select this sentence
    this.Move("(",,, true, true)
    ClipWait 1  ; make sure detection in ")" works
    this.Move(")",,, true)
    this.Vim.State.SetMode("",, 2)
    this.Repeat("h")
    } else if (key == "p") {
    this.ParagraphDown()
    this.ParagraphUp()
    this.SelectParagraphDown()
    this.HandleHTMLSelection()
    detection_str := this.Vim.ParseLineBreaks(clip())
    detection_str := StrReverse(detection_str)
    pos := RegExMatch(detection_str, "^((\s+)[.]|[.]|(\s+))", match)
    if StrLen(match) {
      this.Vim.State.SetMode("",, StrLen(match))
      this.Repeat("h")
    } else
      this.MoveFinalize()
  }
  }
}
