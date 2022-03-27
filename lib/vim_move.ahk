class VimMove{
  __New(vim){
    this.Vim := vim
    this.shift := 0
  }
  
  ExisitingSelection() { ; only return true once in repeat
	if !this.existing_selection && (this.Vim.State.StrIsInCurrentVimMode("VisualFirst") || this.Vim.State.StrIsInCurrentVimMode("ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_") || this.Vim.State.StrIsInCurrentVimMode("Inner")) {
		this.existing_selection := true
		Return true
	}
  }

  MoveInitialize(key=""){
    this.shift := 0
	this.existing_selection := false
	
	; Search keys
	if (key == "f" || key == "t" || key == "+f" || key == "+t" || key == "(" || key == ")" || key == "/" || key == "?") {
		this.search_occurrence := this.Vim.State.n ? this.Vim.State.n : 1
		this.ft_char := this.Vim.State.ft_char
	}
	
    if(this.Vim.State.StrIsInCurrentVimMode("Visual") or this.Vim.State.StrIsInCurrentVimMode("ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_")){
      this.shift := 1
	  ; Search keys
	  if (key != "f" && key != "t" && key != "+f" && key != "+t" && key != "(" && key != ")" && key != "/" && key != "?")
		Send, {Shift Down}
    }

    if(this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g"){
      Send, {Shift Up}{End}
      this.Home()
      Send, {Shift Down}
      this.Up()
      this.vim.state.setmode("Vim_VisualLine")
    }

    if(this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g"){
      this.vim.state.setmode("Vim_VisualLine")
    }

    if(this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g"){
      Send, {Shift Up}{right}{left}{Shift Down}
      this.Up()
      this.vim.state.setmode("Vim_VisualParagraph")
    }

    if(this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g"){
      this.vim.state.setmode("Vim_VisualParagraph")
    }
	
    if(this.Vim.State.IsCurrentVimMode("Vim_VisualBlock") && WinActive("ahk_exe notepad++.exe")){
      send {alt down}
    }

    if(this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")) and (key == "k" or key == "^u" or key == "^b" or key == "g"){
      this.Vim.State.LineCopy := 1
      Send,{Shift Up}
      this.Home()
      this.Down()
      Send, {Shift Down}
      this.Up()
    }
	
    if(this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")) and (key == "j" or key == "^d" or key == "^f" or key == "+g"){
      this.Vim.State.LineCopy := 1
      Send,{Shift Up}
      this.Home()
      Send, {Shift Down}
      this.Down()
    }
  }

  MoveFinalize(){
    Send,{Shift Up}
    ydc_y := false
    if(this.Vim.State.StrIsInCurrentVimMode("ydc_y")){
      Clipboard :=
      Send, ^c
      ClipWait, 1
      this.Vim.State.SetMode("Vim_Normal")
      ydc_y := true
    }else if(this.Vim.State.StrIsInCurrentVimMode("ydc_d")){
      Clipboard :=
      Send, ^x
      ClipWait, 1
      this.Vim.State.SetMode("Vim_Normal")
    }else if(this.Vim.State.StrIsInCurrentVimMode("ydc_c")){
      Clipboard :=
      Send, ^x
      ClipWait, 1
      this.Vim.State.SetMode("Insert")
    }else if(this.Vim.State.StrIsInCurrentVimMode("ExtractStay")){
      Gosub extract_stay
    }else if(this.Vim.State.StrIsInCurrentVimMode("ExtractPriority")){
      send !+x
      this.Vim.State.SetMode("Vim_Normal")
    }else if(this.Vim.State.StrIsInCurrentVimMode("Extract")){
      Send, !x
      this.Vim.State.SetMode("Vim_Normal")
    }else if(this.Vim.State.StrIsInCurrentVimMode("ClozeStay")){
      Gosub cloze_stay
    }else if(this.Vim.State.StrIsInCurrentVimMode("ClozeHinter")){
      Gosub cloze_hinter
    }else if(this.Vim.State.StrIsInCurrentVimMode("Cloze")){
      Send, !z
      this.Vim.State.SetMode("Vim_Normal")
    }
    this.Vim.State.SetMode("", 0, 0)
    if(ydc_y){
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

  Home(){
    if WinActive("ahk_group VimDoubleHomeGroup"){
      Send, {Home}
    } else if WinActive("ahk_exe notepad++.exe")
		send {end}
    Send, {Home}
  }

  Up(n=1){
    Loop, %n% {
	  if this.Vim.State.StrIsInCurrentVimMode("Paragraph") && this.Vim.IsHTML() {
		if (shift == 1)
			this.SelectParagraphUp()
		else
			this.ParagraphUp()
      } else if WinActive("ahk_group VimCtrlUpDownGroup"){
        Send ^{Up}
      } else {
        Send,{Up}
      }
    }
  }

  Down(n=1){
    Loop, %n% {
	  if this.Vim.State.StrIsInCurrentVimMode("Paragraph") && this.Vim.IsHTML() {
		if (shift == 1)
			this.SelectParagraphDown()
		else
			this.ParagraphDown()
      } else if WinActive("ahk_group VimCtrlUpDownGroup"){
        Send ^{Down}
      } else {
        Send,{Down}
      }
    }
  }
  
  ParagraphUp(n:=1) {
    Loop, %n% {
		if this.Vim.IsHTML()
			if this.Vim.SM.IsEditingHTML()
				send ^+{up}{left}
			else
				send ^{up}
		else {
			this.up()
			send {end}
			this.home()
		}
	}
  }
  
  ParagraphDown(n:=1) {
    Loop, %n% {
		if this.Vim.IsHTML()
			send ^{down}
		else {
			send {end}{right}
			this.home()
		}
	}
  }
  
  SelectParagraphUp(n:=1) {
    Loop, %n% {
		if this.Vim.IsHTML()
			send ^+{up}
		else
			send +{left}+{home}
	}
  }
  
  SelectParagraphDown(n:=1) {
    Loop, %n% {
		if this.Vim.IsHTML()
			send ^+{down}
		else
			send +{right}+{end}
	}
  }
  
  HandleHTMLSelection() {
	if this.Vim.IsHTML() {
		if this.Vim.SM.IsEditingHTML() {
			selection := clip()
			if InStr(selection, "--------------------------------------------------------------------------------") ; <hr> tag
				send +{left}
			if InStr(selection, "`r`n") ; do not include line break
				send +{left}
		} else
			send +{left}
	}
  }

  Move(key="", repeat=false, NoInitialize=false, NoFinalize=false, ForceNoShift=false){
    if(!repeat) && !NoInitialize {
      this.MoveInitialize(key)
    }

    ; Left/Right
    if(not this.Vim.State.StrIsInCurrentVimMode("Line")) && !this.Vim.State.StrIsInCurrentVimMode("Paragraph") {
      ; For some cases, need '+' directly to continue to select
      ; especially for cases using shift as original keys
      ; For now, caret does not work even add + directly

      ; 1 character
      if(key == "h"){
        if WinActive("ahk_group VimQdir"){
          Send, {BackSpace down}{BackSpace up}
        }
        else {
          Send, {Left}
        }
      }else if(key == "l"){
        if WinActive("ahk_group VimQdir"){
          Send, {Enter}
        }
        else {
          Send, {Right}
        }
      ; Home/End
      }else if(key == "0"){
        this.Home()
      }else if(key == "$"){
        if(this.shift == 1) && !ForceNoShift {
          Send, +{End}
        }else{
          Send, {End}
        }
      }else if(key == "^"){
        if(this.shift == 1) && !ForceNoShift {
          if WinActive("ahk_group VimCaretMove"){
            Send, +{Home}
            Send, +^{Right}
            Send, +^{Left}
          }else{
            Send, +{Home}
          }
        }else{
          if WinActive("ahk_group VimCaretMove"){
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
      }else if(key == "w"){
        if(this.shift == 1) && !ForceNoShift {
          Send, +^{Right}
        }else{
          Send, ^{Right}
        }
      }else if(key == "e"){
		if this.Vim.State.g ; ge
			if(this.shift == 1) && !ForceNoShift {
			  Send, +^{Left}+{Left}
			}else{
			  Send, ^{Left}{left}
			}
        else if(this.shift == 1) && !ForceNoShift {
		  if this.ExisitingSelection() {
			Send, +^{Right}+{Left}
		  } else
			Send, +^{Right}+^{Right}+{Left}
        }else{
          Send, ^{Right}^{Right}{Left}
        }
      }else if(key == "b"){
        if(this.shift == 1) && !ForceNoShift {
          Send, +^{Left}
        }else{
          Send, ^{Left}
        }
      }else if(key == "f"){ ; find forward
		if(this.shift == 1) && !ForceNoShift {
			str_before := ""
			if !this.ExisitingSelection()
				str_before := this.Vim.ParseLineBreaks(clip())
			send +{end}
			this.HandleHTMLSelection()
			str_after := this.Vim.ParseLineBreaks(clip())
			if (StrLen(str_after) == StrLen(str_before)) { ; caret at end of line
				send +{right}+{end}
				this.HandleHTMLSelection()
				str_after := this.Vim.ParseLineBreaks(clip())
			}
			if !str_before || (StrLen(str_after) > StrLen(str_before)) { ; searching forward
				starting_pos := StrLen(str_before) + 1 ; + 1 to make sure detection_str is what's selected after
				detection_str := SubStr(str_after, starting_pos) ; what's selected after +end
				pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence) ; find in what's selected after
				left := StrLen(detection_str) - pos ; goes back
				SendInput +{left %left%}
			} else if (StrLen(str_after) < StrLen(str_before)) {
				length := StrLen(str_before) - StrLen(str_after) - 1 ; - 1 to make sure detection_str is what's unselected after
				detection_str := SubStr(str_before, 1, length) ; what's unselected after +end
				pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence) ; find in what's selected after
				if pos
					left := StrLen(detection_str) - pos + 2
				else
					left := StrLen(detection_str) + 1 ; nothing is found
				if (pos == 1) {
					this.search_occurrence += 1
					next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
					if next_occurrence
						left := StrLen(detection_str) - next_occurrence + 2
				}
				SendInput +{left %left%}
			}
		}else{
			send +{end}
			detection_str := this.Vim.ParseLineBreaks(clip())
			if !detection_str { ; end of line
				send {right}+{end} ; to the next line
				detection_str := this.Vim.ParseLineBreaks(clip())
			} else if this.Vim.IsWhitespaceOnly(detection_str) {
				send {right 2}+{end} ; to the next line
				detection_str := this.Vim.ParseLineBreaks(clip())
			}
			pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
			SendInput {left}{right %pos%}
		}
      }else if(key == "t"){
		if(this.shift == 1) && !ForceNoShift {
			str_before := ""
			if !this.ExisitingSelection()
				str_before := this.Vim.ParseLineBreaks(clip())
			send +{end}
			this.HandleHTMLSelection()
			str_after := this.Vim.ParseLineBreaks(clip())
			if (StrLen(str_after) == StrLen(str_before)) { ; caret at end of line
				send +{right}+{end}
				this.HandleHTMLSelection()
				str_after := this.Vim.ParseLineBreaks(clip())
			}
			if !str_before || (StrLen(str_after) > StrLen(str_before)) { ; searching forward
				starting_pos := StrLen(str_before) + 1 ; + 1 to make sure detection_str is what's selected after
				detection_str := SubStr(str_after, starting_pos) ; what's selected after +end
				pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence) ; find in what's selected after
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
				SendInput +{left %left%}
			} else if (StrLen(str_after) < StrLen(str_before)) {
				length := StrLen(str_before) - StrLen(str_after) + 1 ; + 1 to make sure detection_str is what's selected after
				detection_str := SubStr(str_before, 1, length)
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
				SendInput +{left %left%}
			}
		}else{
			send +{end}
			detection_str := this.Vim.ParseLineBreaks(clip())
			if !detection_str { ; end of line
				send {right}+{end} ; to the next line
				detection_str := this.Vim.ParseLineBreaks(clip())
			} else if this.Vim.IsWhitespaceOnly(detection_str) {
				send {right 2}+{end} ; to the next line
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
      }else if(key == "+f"){
		if(this.shift == 1) && !ForceNoShift {
			str_before := ""
			if !this.ExisitingSelection()
				str_before := this.Vim.ParseLineBreaks(clip())
			send +{home}
			str_after := this.Vim.ParseLineBreaks(clip())
			if (StrLen(str_after) == StrLen(str_before)) { ; caret at start of line
				send +{left}+{home}
				str_after := this.Vim.ParseLineBreaks(clip())
			}
			if !str_before || StrLen(str_after) > StrLen(str_before) {
				length := StrLen(str_after) - StrLen(str_before)
				detection_str := StrReverse(SubStr(str_after, 1, length))
				pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
				right := StrLen(detection_str) - pos
				SendInput +{right %right%}
			} else if StrLen(str_after) < StrLen(str_before) {
				length := StrLen(str_before) - StrLen(str_after) + 1 ; + 1 to make sure detection_str is what's selected after
				detection_str := SubStr(StrReverse(str_before), 1, length)
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
				SendInput +{right %right%}
			}
		}else{
			send +{home}
			detection_str := this.Vim.ParseLineBreaks(clip())
			if !detection_str { ; start of line
				send {left}+{home}
				detection_str := this.Vim.ParseLineBreaks(clip())
			}
			detection_str := StrReverse(detection_str)
			pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
			SendInput {right}{left %pos%}
		}
      }else if(key == "+t"){
		if(this.shift == 1) && !ForceNoShift {
			str_before := ""
			if !this.ExisitingSelection()
				str_before := this.Vim.ParseLineBreaks(clip())
			send +{home}
			str_after := this.Vim.ParseLineBreaks(clip())
			if (StrLen(str_after) == StrLen(str_before)) { ; caret at start of line
				send +{left}+{home}
				str_after := this.Vim.ParseLineBreaks(clip())
			}
			if !str_before || (StrLen(str_after) > StrLen(str_before)) {
				length := StrLen(str_after) - StrLen(str_before)
				detection_str := StrReverse(SubStr(str_after, 1, length))
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
				SendInput +{right %right%}
			} else if StrLen(str_after) < StrLen(str_before) {
				length := StrLen(str_before) - StrLen(str_after) + 1 ; + 1 to make sure detection_str is what's selected after
				detection_str := SubStr(StrReverse(str_before), 1, length)
				pos := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
				if pos {
					right := StrLen(detection_str) - pos + 1
					if (pos == 2 || pos == 1) {
						this.search_occurrence += 1
						next_occurrence := InStr(detection_str, this.ft_char, true,, this.search_occurrence)
						if (pos == 1 && next_occurrence == 2) { ; in instance like "see"
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
				SendInput +{right %right%}
			}
		}else{
			send +{home}
			detection_str := this.Vim.ParseLineBreaks(clip())
			if !detection_str { ; start of line
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
      }else if(key == ")"){ ; like "f" but search for ". "
		if(this.shift == 1) && !ForceNoShift {
			str_before := ""
			if !this.ExisitingSelection() { ; determine caret position
				str_before := this.Vim.ParseLineBreaks(clip())
				send +{right}
				str_after := this.Vim.ParseLineBreaks(clip())
				send +{left}
			}
			if !str_before || (StrLen(str_after) > StrLen(str_before)) {
				this.SelectParagraphDown()
				this.HandleHTMLSelection()
				str_after := this.Vim.ParseLineBreaks(clip())
				if (StrLen(str_after) == StrLen(str_before) + 1) { ; at end of paragraph
					send +{right}
					this.SelectParagraphDown()
					this.HandleHTMLSelection()
					str_after := this.Vim.ParseLineBreaks(clip())
				}
				starting_pos := StrLen(str_before) + 1 ; + 1 to make sure detection_str is what's selected after
				detection_str := SubStr(str_after, starting_pos) ; what's selected after +end
				pos := InStr(detection_str, ". ", true,, this.search_occurrence) ; find in what's selected after
				left := StrLen(detection_str) - pos - 1 ; - 1 because ". "
				if !pos && (InStr(detection_str, ".", true,, this.search_occurrence) == Strlen(detection_str)) ; try to search if there's a last dot
					left := 0 ; if there is a last dot, don't move back
				SendInput +{left %left%}
			} else if StrLen(str_after) < StrLen(str_before) { ; search in selected text
				pos := InStr(str_before, ". ", true,, this.search_occurrence)
				right := pos
				if pos {
					right += 1
					if (pos == 1) {
						this.search_occurrence += 1
						next_occurrence := InStr(str_before, ". ", true,, this.search_occurrence)
						if next_occurrence
							right := pos + 1
					}
				}
				SendInput +{right %right%}
			}
        }else{
			this.SelectParagraphDown()
			detection_str := this.Vim.ParseLineBreaks(clip())
			if !detection_str || this.Vim.IsWhitespaceOnly(detection_str) { ; end of paragraph
				send {right}
				this.SelectParagraphDown() ; to the next line
				detection_str := this.Vim.ParseLineBreaks(clip())
				if !detection_str { ; still end of paragraph
					send {right}
					this.SelectParagraphDown() ; to the next line
					detection_str := this.Vim.ParseLineBreaks(clip())
				}
			}
			pos := InStr(detection_str, ". ", true,, this.search_occurrence)
			right := pos ? pos + 1 : 0
			SendInput {left}{right %right%}
        }
      }else if(key == "("){ ; like "+t"
		if(this.shift == 1) && !ForceNoShift {
			str_before := ""
			if !this.ExisitingSelection() { ; determine caret position
				str_before := this.Vim.ParseLineBreaks(clip())
				send +{right}
				str_after := this.Vim.ParseLineBreaks(clip())
				send +{left}
			}
			if (StrLen(str_after) > StrLen(str_before)) { ; search in selected text
				detection_str := StrReverse(str_before)
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
			} else if (StrLen(str_after) < StrLen(str_before)) || !str_before {
				this.SelectParagraphUp()
				str_after := this.Vim.ParseLineBreaks(clip())
				if !str_after { ; start of line
					send {left}
					this.SelectParagraphUp()
					str_after := this.Vim.ParseLineBreaks(clip())
				}
				length := StrLen(str_after) - StrLen(str_before)
				detection_str := StrReverse(SubStr(str_after, 1, length))
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
			if !detection_str { ; start of line
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
      }else if(key == "/"){
		WinGet, hwnd, ID, A
	    if this.Vim.State.StrIsInCurrentVimMode("Visual")
			InputBox, user_input, Visual Search, Select text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
	    else if this.Vim.State.StrIsInCurrentVimMode("ydc_y")
			InputBox, user_input, Visual Search, Copy text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
	    else if this.Vim.State.StrIsInCurrentVimMode("ydc_d")
			InputBox, user_input, Visual Search, Delete text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
	    else if this.Vim.State.StrIsInCurrentVimMode("ydc_c")
			InputBox, user_input, Visual Search, Delete text until:`n(enter nothing to repeat the last search)`n(case sensitive)`n(will enter insert mode),, 272, 176
	    else if this.Vim.State.StrIsInCurrentVimMode("Extract")
			InputBox, user_input, Visual Search, Extract text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
	    else if this.Vim.State.StrIsInCurrentVimMode("Cloze")
			InputBox, user_input, Visual Search, Cloze text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
		if ErrorLevel
			Return
		if !user_input ; entered nothing
			user_input := this.last_search ; repeat last search
		else ; entered something
			this.last_search := user_input ; register user_input into last_search
		if !user_input ; still empty
			Return
		str_before := ""
		WinActivate, ahk_id %hwnd%
		if !this.ExisitingSelection() { ; determine caret position
			str_before := this.Vim.ParseLineBreaks(clip())
			send +{right}
			str_after := this.Vim.ParseLineBreaks(clip())
			send +{left}
		}
		if !str_before || (StrLen(str_after) > StrLen(str_before)) {
			this.SelectParagraphDown()
			this.HandleHTMLSelection()
			str_after := this.Vim.ParseLineBreaks(clip())
			if (StrLen(str_after) == StrLen(str_before) + 1) { ; at end of paragraph
				send +{right}
				this.SelectParagraphDown()
				this.HandleHTMLSelection()
				str_after := this.Vim.ParseLineBreaks(clip())
			}
			starting_pos := StrLen(str_before) + 1 ; + 1 to make sure detection_str is what's selected after
			detection_str := SubStr(str_after, starting_pos)
			pos := InStr(detection_str, user_input, true,, this.search_occurrence)
			left := StrLen(detection_str) - pos
			if (pos == 1) {
				this.search_occurrence += 1
				next_occurrence := InStr(detection_str, user_input, true,, this.search_occurrence)
				if next_occurrence
					left := StrLen(detection_str) - next_occurrence
			}
			SendInput +{left %left%}
		} else if (StrLen(str_after) < StrLen(str_before)) {
			pos := InStr(str_before, user_input, true)
			pos -= pos ? 1 : 0
			SendInput +{right %pos%}
		}
      }else if(key == "?"){
		WinGet, hwnd, ID, A
	    if this.Vim.State.StrIsInCurrentVimMode("Visual")
			InputBox, user_input, Visual Search, Select text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
	    else if this.Vim.State.StrIsInCurrentVimMode("ydc_y")
			InputBox, user_input, Visual Search, Copy text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
	    else if this.Vim.State.StrIsInCurrentVimMode("ydc_d")
			InputBox, user_input, Visual Search, Delete text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
	    else if this.Vim.State.StrIsInCurrentVimMode("ydc_c")
			InputBox, user_input, Visual Search, Delete text until:`n(enter nothing to repeat the last search)`n(case sensitive)`n(will enter insert mode),, 272, 176
	    else if this.Vim.State.StrIsInCurrentVimMode("Extract")
			InputBox, user_input, Visual Search, Extract text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
	    else if this.Vim.State.StrIsInCurrentVimMode("Cloze")
			InputBox, user_input, Visual Search, Cloze text until:`n(enter nothing to repeat the last search)`n(case sensitive),, 272, 160
		if ErrorLevel
			Return
		if !user_input ; entered nothing
			user_input := this.last_search ; repeat last search
		else ; entered something
			this.last_search := user_input ; register user_input into last_search
		if !user_input ; still empty
			Return
		str_before := ""
		WinActivate, ahk_id %hwnd%
		if !this.ExisitingSelection() { ; determine caret position
			str_before := this.Vim.ParseLineBreaks(clip())
			send +{right}
			str_after := this.Vim.ParseLineBreaks(clip())
			send +{left}
		}
		if (StrLen(str_after) > StrLen(str_before)) {
			pos := InStr(StrReverse(str_before), StrReverse(user_input), true)
			pos += pos ? StrLen(user_input) - 2 : 0
			SendInput +{left %pos%}
		} else if (StrLen(str_after) < StrLen(str_before)) || !str_before {
			this.SelectParagraphUp()
			str_after := this.Vim.ParseLineBreaks(clip())
			if !str_after { ; start of line
				send {left}
				this.SelectParagraphUp()
				str_after := this.Vim.ParseLineBreaks(clip())
			}
			starting_pos := StrLen(str_before) + 1 ; + 1 to make sure detection_str is what's selected after
			detection_str := SubStr(StrReverse(str_after), starting_pos)
			pos := InStr(detection_str, StrReverse(user_input), true,, this.search_occurrence)
			right := StrLen(detection_str) - pos - StrLen(user_input) + 1
			SendInput +{right %right%}
		}
      }
    }
    ; Up/Down 1 character
    if(key == "j"){
      this.Down()
    }else if(key="k"){
      this.Up()
    ; Page Up/Down
    n := 10
    }else if(key == "^u"){
	  this.Up(10)
    }else if(key == "^d"){
	  this.Down(10)
    }else if(key == "^b"){
	  Send, {PgUp}
    }else if(key == "^f"){
	  Send, {PgDn}
    }else if(key == "g"){
	  if (this.Vim.State.n > 0) {
		line := this.Vim.State.n - 1
		this.Vim.State.n := 0
		if WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText() { ; browsing
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
    }else if(key == "+g"){
	  if (this.Vim.State.n > 0) {
		line := this.Vim.State.n - 1
		this.Vim.State.n := 0
		if this.Vim.SM.MouseMoveTop(true) {
			this.Vim.SM.WaitTextFocus()
			send {left}{home}
		} else if WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText() { ; browsing and no scrollbar
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
			send ^+{up} ; if there are references this would select (or deselect in visual mode) them all
			if (this.shift == 1)
				send +{down} ; go down one line, if there are references this would include the #SuperMemo Reference
			if InStr(clip(), "#SuperMemo Reference:")
				if (this.shift == 1)
					send +{up 4} ; select until start of last line
				else
					send {up 3} ; go to start of last line
			else
				if (this.shift == 1)
				  send ^+{end}+{home}
				else
				  send ^{end}{home}
		}
	  }
    }else if(key == "{"){
	  if (this.Vim.State.n > 0) && WinActive("ahk_class TElWind") && !repeat {
		paragraph := this.Vim.State.n - 1
		this.Vim.State.n := 0
		if !this.Vim.SM.IsEditingText() {
			send ^t
			this.Vim.SM.WaitTextFocus()
		}
		send ^{home}
		this.ParagraphDown(paragraph)
      } else if(this.shift == 1) && !ForceNoShift {
	    this.SelectParagraphUp()
	  }else{
	    this.ParagraphUp()
	  }
    }else if(key == "}"){
	  if (this.Vim.State.n > 0) && WinActive("ahk_class TElWind") && !repeat {
		paragraph := this.Vim.State.n - 1
		this.Vim.State.n := 0
		if this.Vim.SM.MouseMoveTop(true)
			this.Vim.SM.WaitTextFocus()
		else {
			if !this.Vim.SM.IsEditingText() {
				send ^t
				this.Vim.SM.WaitTextFocus()
			}
			send ^{home}
		}
		this.ParagraphDown(paragraph)
      } else if(this.shift == 1) && !ForceNoShift {
	    this.SelectParagraphDown()
	  }else{
	    this.ParagraphDown()
	  }
    }

    if(!repeat) && !NoFinalize {
      this.MoveFinalize()
    }
  }

  Repeat(key=""){
    this.MoveInitialize(key)
    if(this.Vim.State.n == 0){
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

  YDCMove(){
    this.Vim.State.LineCopy := 1
    this.Home()
    Send, {Shift Down}
    if(this.Vim.State.n == 0){
      this.Vim.State.n := 1
    }
    this.Down(this.Vim.State.n - 1)
    Send, {End}
	if this.Vim.State.StrIsInCurrentVimMode("SMVim_") && this.Vim.SM.IsEditingHTML()
		send +{left}
    if not WinActive("ahk_group VimLBSelectGroup"){
      this.Move("l")
    }else{
      this.Move("")
    }
  }

  Inner(key=""){
    if(key == "w"){
      this.Move("b", true)
      this.Move("e", false)
    } else if (key == "s") {
		send {right} ; so if at start of a sentence, select this sentence
		this.Move("(",,, true, true)
		ClipWait 1 ; make sure detection in ")" works
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
