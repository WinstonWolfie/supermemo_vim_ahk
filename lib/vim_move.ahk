class VimMove{
  __New(vim){
    this.Vim := vim
    this.shift := 0
  }

  MoveInitialize(key=""){
    this.shift := 0
	this.e := 0
	if (key == "f" || key == "t") {
		this.ft_occurrence := 1
		if this.Vim.State.n
			this.ft_occurrence := this.Vim.State.n
		this.ft_char := this.Vim.State.ft_char
	}
    if(this.Vim.State.StrIsInCurrentVimMode("Visual") or this.Vim.State.StrIsInCurrentVimMode("ydc") || this.Vim.State.StrIsInCurrentVimMode("SMVim_")){
      this.shift := 1
	  if (key != ")") && (key != "/") && (key != "f") && (key != "t")
		Send, {Shift Down}
    }

    if(this.Vim.State.IsCurrentVimMode("Vim_VisualFirst")) && (key != "e") {
      this.vim.state.setmode("Vim_VisualChar")
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

    if(this.Vim.State.IsCurrentVimMode("Vim_VisualBlock") && WinActive("ahk_exe notepad++.exe")){
      send {alt down}
      this.vim.state.setmode("Vim_VisualBlock")
    }

    if(this.Vim.State.IsCurrentVimMode("Vim_VisualBlockFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g"){
      Send, {Shift Up}{right}{left}{Shift Down}
      this.Up()
      this.vim.state.setmode("Vim_VisualBlock")
    }

    if(this.Vim.State.IsCurrentVimMode("Vim_VisualBlockFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g"){
      this.vim.state.setmode("Vim_VisualBlock")
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
	
	if (key == "e") && !this.Vim.State.IsCurrentVimMode("Vim_VisualChar")
		this.e := 1
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
	if !(this.Vim.State.IsCurrentVimMode("Vim_VisualBlock") && WinActive("ahk_exe notepad++.exe"))
		send {alt up}
	if (key == "e") && this.Vim.State.IsCurrentVimMode("Vim_VisualFirst")
		this.vim.state.setmode("Vim_VisualChar")
  }

  Home(){
    if WinActive("ahk_group VimDoubleHomeGroup"){
      Send, {Home}
    }
    Send, {Home}
  }

  Up(n=1){
    Loop, %n% {
	  if this.Vim.State.StrIsInCurrentVimMode("Block") {
		if WinActive("ahk_class TElWind")
			Send, +^{up}{left}
      } else if WinActive("ahk_group VimCtrlUpDownGroup"){
        Send ^{Up}
      } else {
        Send,{Up}
      }
    }
  }

  Down(n=1){
    Loop, %n% {
	  if this.Vim.State.StrIsInCurrentVimMode("Block") {
		if WinActive("ahk_class TElWind")
			Send, ^{down}
      } else if WinActive("ahk_group VimCtrlUpDownGroup"){
        Send ^{Down}
      } else {
        Send,{Down}
      }
    }
  }

  Move(key="", repeat=false){
    if(!repeat){
      this.MoveInitialize(key)
    }

    ; Left/Right
    if(not this.Vim.State.StrIsInCurrentVimMode("Line")) && !this.Vim.State.StrIsInCurrentVimMode("Block") {
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
        if(this.shift == 1){
          Send, +{End}
        }else{
          Send, {End}
        }
      }else if(key == "^"){
        if(this.shift == 1){
          if WinActive("ahk_group VimCaretMove"){
            this.Home()
            Send, ^{Right}
            Send, ^{Left}
          }else{
            this.Home()
          }
        }else{
          if WinActive("ahk_group VimCaretMove"){
            Send, +{Home}
            Send, +^{Right}
            Send, +^{Left}
          }else{
            Send, +{Home}
          }
        }
      ; Words
      }else if(key == "w"){
        if(this.shift == 1){
          Send, +^{Right}
        }else{
          Send, ^{Right}
        }
      }else if(key == "e"){
		if this.Vim.State.g ; ge
			if(this.shift == 1){
			  Send, +^{Left}+{Left}
			}else{
			  Send, ^{Left}{left}
			}
        else if(this.shift == 1){
		  if (this.e == 1) {
			Send, +^{Right}+{Left}
			this.e := 0
			if this.Vim.State.StrIsInCurrentVimMode("VisualFirst")
				this.Vim.State.SetMode("Vim_VisualChar")
		  } else
			Send, +^{Right}+^{Right}+{Left}
        }else{
          Send, ^{Right}^{Right}{Left}
        }
      }else if(key == "b"){
        if(this.shift == 1){
          Send, +^{Left}
        }else{
          Send, ^{Left}
        }
      }else if(key == "f"){
		if(this.shift == 1){
			starting_pos := StrLen(StrReplace(clip(), "`r")) + 1 ; +1 to make sure detection_str is what's selected after
			send +{end}+{left}
			detection_str := SubStr(StrReplace(clip(), "`r"), starting_pos)
			pos := InStr(detection_str, this.ft_char, true,, this.ft_occurrence)
			left := StrLen(detection_str) - pos
			SendInput +{left %left%}
		}else{
			send {right}+{end}+{left} ; go right one char in case current char = finding char
			pos := InStr(StrReplace(clip(), "`r"), this.ft_char, true,, this.ft_occurrence)
			SendInput {left}{right %pos%}
			if !pos
				send {left}
		}
      }else if(key == "t"){
		if(this.shift == 1){
			starting_pos := StrLen(StrReplace(clip(), "`r")) + 1 ; +1 to make sure detection_str is what's selected after
			send +{end}+{left}
			detection_str := SubStr(StrReplace(clip(), "`r"), starting_pos)
			pos := InStr(detection_str, this.ft_char, true,, this.ft_occurrence)
			left := StrLen(detection_str) - pos
			if pos {
				left += 1
				if (pos == 1) {
					this.ft_occurrence += 1
					next_occurrence := InStr(detection_str, this.ft_char, true,, this.ft_occurrence)
					if next_occurrence
						left := StrLen(detection_str) - next_occurrence + 1
				}
			}
			SendInput +{left %left%}
		}else{
			send {right}+{end}+{left} ; go right one char in case current char = finding char
			pos := InStr(StrReplace(clip(), "`r"), this.ft_char, true,, this.ft_occurrence)
			SendInput {left}{right %pos%}{left}
		}
      }else if(key == ")"){
		this.ft_occurrence := 1
		if this.Vim.State.n
			this.ft_occurrence := this.Vim.State.n
        if(this.shift == 1){
          starting_pos := StrLen(StrReplace(clip(), "`r")) + 1 ; +1 to make sure detection_str is what's selected after
		  if this.Vim.SM.IsEditingHTML()
			send ^+{down}+{left}
		  else
			send +{end}
		  send +{left}
		  detection_str := SubStr(StrReplace(clip(), "`r"), starting_pos)
		  pos := InStr(detection_str, ".", true,, this.ft_occurrence)
		  left := StrLen(detection_str) - pos
		  if pos {
			left += 1
			if (pos == 1) {
				this.ft_occurrence += 1
				next_this.ft_occurrence := InStr(detection_str, ".", true,, this.ft_occurrence)
				if next_this.ft_occurrence
					left := StrLen(detection_str) - next_this.ft_occurrence + 1
			}
		  }
		  SendInput +{left %left%}
        }else{
          send {right} ; go right one char in case current char = finding char
		  if this.Vim.SM.IsEditingHTML()
			send ^+{down}
		  else
			send +{end}
		  send +{left}
		  pos := InStr(StrReplace(clip(), "`r"), ".", true,, this.ft_occurrence)
		  SendInput {left}{right %pos%}{left}
        }
      }else if(key == "/"){
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
			user_input := last_search ; repeat last search
		else ; entered something
			last_search := user_input ; register user_input into last_search
		if !user_input ; still empty
			Return
		starting_pos := StrLen(StrReplace(clip(), "`r")) + 1 ; +1 to make sure detection_str is what's selected after
		if this.Vim.SM.IsEditingHTML()
			send ^+{down}+{left}
		else
			send +{end}
		send +{left}
		detection_str := SubStr(StrReplace(clip(), "`r"), starting_pos)
		pos := InStr(detection_str, user_input, true)
		left := StrLen(detection_str) - pos
		if pos {
			left += 1
			if (pos == 1) {
				next_this.ft_occurrence := InStr(detection_str, user_input, true,, 2)
				if next_this.ft_occurrence
					left := StrLen(detection_str) - next_this.ft_occurrence + 1
			}
		}
		SendInput +{left %left%}
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
	  if this.Vim.State.n > 0 {
	    line := this.Vim.State.n - 1
	    this.Vim.State.n := 0
		if WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText() ; browsing
			send ^t
		SendInput ^{home}{down %line%}
	  } else if this.Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText()
		send ^t^{home}{esc}
	  else
		Send, ^{Home}
    }else if(key == "+g"){
	  if this.Vim.State.n > 0 {
	    line := this.Vim.State.n - 1
	    this.Vim.State.n := 0
		if this.Vim.SM.MouseMoveTop(true)
			send {left}{home}
		else if WinActive("ahk_class TElWind") && !this.Vim.SM.IsEditingText() ; browsing and no scrollbar
			send ^t^{home}
		else
			send ^{home}
		SendInput {down %line%}
	  } else if this.Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX
		send ^t^{end}{esc}
	  else {
	    if (this.shift == 1)
			Send, ^+{End}+{Home}
		else
			Send, ^{End}{Home}
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
      if(this.shift == 1){
	    Send, +^{up}
	  }else{
	    if WinActive("ahk_class TElWind")
			Send, +^{up}{left}
		else
			Send, ^{up}
	  }
    }else if(key == "}"){
      if(this.shift == 1){
	    Send, +^{down}
	  }else{
	    Send, ^{down}
	  }
    }

    if(!repeat){
      this.MoveFinalize()
    }
  }

  Repeat(key=""){
    this.MoveInitialize(key)
    if(this.Vim.State.n == 0){
      this.Vim.State.n := 1
    }
	if (WinActive("ahk_class TContents") || WinActive("ahk_class TBrowser")) && (key = "j" || key = "k") && this.Vim.State.n > 1
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
    if not WinActive("ahk_group VimLBSelectGroup"){
      this.Move("l")
    }else{
      this.Move("")
    }
  }

  Inner(key=""){
    if(key == "w"){
      this.Move("b", true)
      this.Move("w", false)
    }
  }
}
			ft_char := this.ft_char
