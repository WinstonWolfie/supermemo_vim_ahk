#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
class VimMove {
  __New(vim) {
    this.Vim := vim
    this.shift := 0
    this.hr := "--------------------------------------------------------------------------------"  ; <hr> tag
    this.SurroundKeys := ",$,*,_"
    this.InnerKeys := "(,),{,},[,],<,>,"",',=,«,»,“,”,``" . this.SurroundKeys
    this.WordBoundChars := "\wÀ-ÖØ-öø-ÿα-ωΑ-ΩœāēīōūίϊΐόάέύϋΰήώΊΪΌΆΈΎΫΉΏᾼᾳῌῃῼῳἈἀᾈᾀἘἐἨἠᾘᾐἸἰὈὀὐὨὠᾨᾠἉἁᾉᾁἙἑἩἡᾙᾑἹἱὉὁὙὑὩὡᾩᾡἊἂᾊᾂἚἒἪἢᾚᾒἺἲὊὂὒὪὢᾪᾢἋἃᾋᾃἛἓἫἣᾛᾓἻἳὋὃὛὓὫὣᾫᾣἌἄᾌᾄἜἔἬἤᾜᾔἼἴὌὄὔὬὤᾬᾤἍἅᾍᾅἝἕἭἥᾝᾕἽἵὍὅὝὕὭὥᾭᾥἎἆᾎᾆἮἦᾞᾖἾἶὖὮὦᾮᾦἏἇᾏᾇἯἧᾟᾗἿἷὟὗὯὧᾯᾧᾺὰᾲῈὲῊὴῂῚὶῸὸῪὺῺὼῲᾶᾷῆῇῖῦῶῷᾴῄῴῗῧῒῢΐΰᾸᾰῘῐῨῠᾹᾱῙῑῩῡόίύᾰ́άέ"
  }
  
  NoSelection() {
    if (!this.ExistingSelection && this.Vim.State.StrIsInCurrentVimMode("VisualFirst,ydc,SMVim_,Inner"))
      Return this.ExistingSelection := true  ; so it only returns true once in repeat
  }

  IsSearchKey(key) {
    return (IfIn(key, "f,t,+f,+t,(,),s,+s,/,?,e,gn")
         || ((key == "+g") && this.Vim.SM.IsEditingHTML()))
  }

  IsReplace() {
    return (this.Vim.State.StrIsInCurrentVimMode("ydc_c,SMVim_") || this.Vim.State.surround)
  }
  
  RestoreCopy() {
    return !this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")
  }

  RestoreClipLater() {
    return this.Vim.State.StrIsInCurrentVimMode("Vim_g")
  }

  IsMotionOnly() {
    return (this.Vim.State.IsCurrentVimMode("Vim_Normal") || this.Vim.State.StrIsInCurrentVimMode("Vim_Visual"))
  }

  IsActionKey(key) {
    return IfIn(key, "x,+x")
  }

  RegForDot(key) {
    if (this.ReggedForDot := ((!this.IsMotionOnly() || this.IsActionKey(key)) && !((A_ThisHotkey == ".") && !this.Vim.State.fts))) {
      this.LastInOrOut := this.LastRepeat := this.LastSurround := this.LastSurroundKey := this.LastLineCopy := ""
      this.LastKey := key, this.LastN := this.Vim.State.n, this.LastMode := this.Vim.State.Mode
      this.LastFtsChar := this.Vim.State.FtsChar ? this.Vim.State.FtsChar : ""
    }
  }

  MoveInitialize(key:="", RestoreClip:=true) {
    this.shift := this.ExistingSelection := this.clipped := 0
    this.RegForDot(key)

    if (this.IsSearchKey(key)) {
      this.SearchOccurrence := this.Vim.State.n ? this.Vim.State.n : 1
      this.FtsChar := this.Vim.State.FtsChar
      if (RestoreClip && this.RestoreCopy()) {
        global ClipSaved
        ClipSaved := ClipboardAll
        this.clipped := true
      }
    }
    
    if (this.Vim.State.StrIsInCurrentVimMode("Visual,ydc,SMVim_,Vim_g")) {
      this.shift := 1
      if (!this.IsSearchKey(key) && !this.IsActionKey(key))
        send {shift down}
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst") && IfIn(key, "k,^u,^b,g")) {
      send {shift up}{right}{shift down}
      this.Zero()
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst") && IfIn(key, "j,^d,^f,+g"))
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst") && IfIn(key, "k,^u,^b,g")) {
      send {shift up}{right}{left}{shift down}
      this.Up()
      this.Vim.State.SetMode("Vim_VisualParagraph",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst") && IfIn(key, "j,^d,^f,+g"))
      this.Vim.State.SetMode("Vim_VisualParagraph",, -1)  ; -1 is needed for repeat to work
  
    if (this.Vim.State.IsCurrentVimMode("Vim_VisualBlock") && WinActive("ahk_exe notepad++.exe"))
      send {AltDown}

    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc,SMVim_") && IfIn(key, "k,^u,^b,g")) {
      this.Vim.State.LineCopy := 1
      send {shift up}
      this.Zero()
      this.Down()
      send {shift down}
      this.Up()
    }
  
    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc,SMVim_") && IfIn(key, "j,^d,^f,+g")) {
      this.Vim.State.LineCopy := 1
      send {shift up}
      this.Zero()
      send {shift down}
      this.Down()
    }

    if (IfIn(key, "x,+x") && !this.Vim.IsNavigating())
      this.Vim.State.SetMode("Vim_ydc_d", 0, -1, 0,,, -1)  ; LineCopy must be 0
  }

  MoveFinalize() {
    Send {shift up}
    this.Vim.State.FtsChar := ""
    if (this.clipped) {
      Clipped := "Clipped"
      if (!this.RestoreClipLater()) {
        global ClipSaved
        Clipboard := ClipSaved
      }
    }
    global WinClip
    if (this.Vim.State.Surround)
      this.SurroundKeyEntered := true
    if (!this.Vim.State.surround || !this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")) {
      if (ydc_y := this.Vim.State.StrIsInCurrentVimMode("ydc_y")) {
        this.YdcClipSaved := copy(false), this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_d")) {
        if (!this.vim.state.leader) {
          this.YdcClipSaved := copy(false,,, "^x")
        } else {
          send {bs}
        }
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
        if (!this.vim.state.leader) {
          this.YdcClipSaved := copy(false,,, "^x")
        } else {
          send {bs}
        }
        this.Vim.State.SetMode("Insert")
      } else if (this.Vim.State.StrIsInCurrentVimMode("Vim_gu")) {
        gosub % "ConvertToLowercase" . Clipped
      } else if (this.Vim.State.StrIsInCurrentVimMode("Vim_gU")) {
        gosub % "ConvertToUppercase" . Clipped
      } else if (this.Vim.State.StrIsInCurrentVimMode("Vim_g~")) {
        gosub % "InvertCase" . Clipped
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
      } else if (this.Vim.State.StrIsInCurrentVimMode("ClozeNoBracket")) {
        Gosub ClozeNoBracket
      } else if (this.Vim.State.StrIsInCurrentVimMode("Cloze")) {
        send !z
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("AltT")) {
        sleep 20
        this.Vim.SM.AltT(), this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("AltQ")) {
        sleep 20
        Send !q
        WinWaitActive, ahk_class TChoicesDlg
        send % this.KeyAfterSMAltQ . "{enter}"
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("GAltA")) {
        Gosub SMParseHTML
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ParseHTML")) {
        send ^+1
        this.Vim.State.SetMode("Vim_Normal")
      }
    }
    this.Vim.State.SetMode("", 0, 0,,, -1)
    if (ydc_y)
      send {Left}
    ; Sometimes, when using `c`, the control key would be stuck down afterwards.
    ; This forces it to be up again afterwards.
    send {CtrlUp}
    if (!WinActive("ahk_exe iexplore.exe") && !WinActive("ahk_exe Notepad.exe") && GetKeyState("Alt", "P"))
      send {AltUp}
    if (this.Vim.State.IsCurrentVimMode("Vim_VisualFirst") || this.Vim.State.StrIsInCurrentVimMode("Inner,Outer"))
      this.vim.state.setmode("Vim_VisualChar",,,,, -1)
  }

  Zero() {
    if (this.Vim.SM.IsBrowsing()) {
      if (ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind")) {
        SendMessage, 0x114, 2, 0, Internet Explorer_Server2, A  ; scroll all the way to left
      } else {
        SendMessage, 0x114, 2, 0, Internet Explorer_Server1, A  ; scroll all the way to left
      }
      return
    }
    if (WinActive("ahk_group VimDoubleHomeGroup")) {
      send {Home}
    } else if (WinActive("ahk_exe notepad++.exe")) {
      send {end}
    }
    send {Home}
  }

  Up(n:=1) {
    if (this.Vim.State.StrIsInCurrentVimMode("Paragraph") && this.Vim.IsHTML()) {
      if (shift == 1) {
        this.SelectParagraphUp(n)
      } else {
        this.ParagraphUp(n)
      }
    } else if (WinActive("ahk_group VimCtrlUpUpGroup")) {
      send % "^{Up " . n . "}"
    } else {
      send % "{Up " . n . "}"
    }
  }

  Down(n:=1) {
    if (this.Vim.State.StrIsInCurrentVimMode("Paragraph") && this.Vim.IsHTML()) {
      if (shift == 1) {
        this.SelectParagraphDown(n)
      } else {
        this.ParagraphDown(n)
      }
    } else if (WinActive("ahk_group VimCtrlUpDownGroup")) {
      send % "^{down " . n . "}"
    } else {
      send % "{down " . n . "}"
    }
  }

  ParagraphUp(n:=1) {
    if (this.Vim.IsHTML()) {
      if (this.Vim.SM.IsEditingHTML()) {
        send % "^+{up " . n . "}{left}"
      } else {
        send % "^{up " . n . "}"
      }
    } else {
      this.up(n)
      send {end}
      this.Zero()
    }
  }

  ParagraphDown(n:=1) {
    if (this.Vim.IsHTML()) {
      send % "^{Down " . n . "}"
    } else {
      this.Down(n)
      send {end}
      this.Zero()
    }
  }

  SelectParagraphUp(n:=1, detection:=false) {
    if (this.Vim.IsHTML()) {
      send % "^+{up " . n . "}"
    } else if (this.Vim.SM.IsEditingPlainText() && detection) {
      send ^+{home}
    } else {
      n--
      send % "+{up " . n . "}+{home}"
    }
  }

  SelectParagraphDown(n:=1, detection:=false) {
    if (this.Vim.IsHTML()) {
      send % "^+{down " . n . "}"
    } else if (this.Vim.SM.IsEditingPlainText() && detection) {
      send ^+{end}
    } else {
      n--
      send % "+{down " . n . "}+{end}"
    }
  }

  Move(key="", repeat:=false, initialize:=true, finalize:=true, ForceShiftRelease:=false, RestoreClip:=true) {
    if (!repeat && initialize)
      this.MoveInitialize(key, RestoreClip)
    if (ForceShiftRelease)
      this.shift := 0

    ; Left/Right
    if (!this.Vim.State.StrIsInCurrentVimMode("Line,Paragraph")) {
      ; For some cases, need '+' directly to continue to select
      ; especially for cases using shift as original keys
      ; For now, caret does not work even add + directly

      ; 1 character
      if (key == "h") {
        if (WinActive("ahk_group VimQdir")) {
          send {BackSpace down}{BackSpace up}
        } else if (this.Vim.SM.IsBrowsing()) {
          if (ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind")) {
            SendMessage, 0x114, 0, 0, Internet Explorer_Server2, A  ; scroll left
          } else {
            SendMessage, 0x114, 0, 0, Internet Explorer_Server1, A  ; scroll left
          }
        } else {
          send {Left}
        }
      } else if (key == "l") {
        if (WinActive("ahk_group VimQdir")) {
          send {Enter}
        } else if (this.Vim.SM.IsBrowsing()) {
          if (ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind")) {
            SendMessage, 0x114, 1, 0, Internet Explorer_Server2, A  ; scroll right
          } else {
            SendMessage, 0x114, 1, 0, Internet Explorer_Server1, A  ; scroll right
          }
        } else {
          send {Right}
        }
      ; Home/End
      } else if (key == "0") {
        this.Zero()
      } else if (key == "$") {
        if (this.Vim.SM.IsBrowsing()) {
          if (ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind")) {
            SendMessage, 0x114, 3, 0, Internet Explorer_Server2, A  ; scroll all the way to right
          } else {
            SendMessage, 0x114, 3, 0, Internet Explorer_Server1, A  ; scroll all the way to right
          }
        } else if (this.shift == 1) {
          send +{End}
        } else {
          send {End}
        }
      } else if (key == "^") {
        if (this.shift == 1) {
          if (WinActive("ahk_group VimCaretMove")) {
            send +{Home}
            send +^{Right}
            send +^{Left}
          } else {
            send +{Home}
          }
        } else {
          if (WinActive("ahk_group VimCaretMove")) {
            send {home}
            send ^{Right}
            send ^{Left}
          } else {
            send {home}
            if (WinActive("ahk_exe notepad++.exe"))
              send {home}
          }
        }
      } else if (key == "+") {
        if (this.shift == 1) {
          send +{down}+{end}+{home}
        } else {
          send {down}{end}{home}
        }
      } else if (key == "-") {
        if (this.shift == 1) {
          send +{up}+{end}+{home}
        } else {
          send {up}{end}{home}
        }
      ; Words
      } else if (key == "w") {
        if (this.shift == 1) {
          send +^{Right}
        } else {
          send ^{Right}
        }
      } else if (key == "e") {
        if (this.Vim.State.g) {  ; ge
          if (this.shift == 1) {
            if (!this.NoSelection()) {  ; determine caret position
              StrBefore := this.Vim.ParseLineBreaks(copy(false))
              send +{left}
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
              send +{right}
            }
            if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
              this.SelectParagraphUp(, true)
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
              if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
                send +{left}
                this.SelectParagraphUp(, true)
                StrAfter := this.Vim.ParseLineBreaks(copy(false))
              }
              length := StrLen(StrAfter) - StrLen(StrBefore)
              DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
              pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence - 1, true)
              if (pos) {
                right := StrLen(DetectionStr) - pos
                if (pos == 1) {
                  this.SearchOccurrence++
                  NextOccurrence := this.FindWordBoundary(DetectionStr, this.SearchOccurrence - 1, true)
                  if (NextOccurrence)
                    right := StrLen(DetectionStr) - NextOccurrence
                }
              }
              send % "+{right " . right . "}"
            } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
              DetectionStr := StrReverse(StrBefore)
              pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence, true)
              if (pos) {
                left := pos
                if (pos == 1) {
                  this.SearchOccurrence++
                  NextOccurrence := this.FindWordBoundary(DetectionStr, this.SearchOccurrence, true)
                  if (NextOccurrence)
                    left := NextOccurrence
                }
                if (StrLen(StrAfter) == StrLen(StrBefore))
                  left++
                send % "+{left " . left . "}"
              }
            }
          } else {
            this.SelectParagraphUp(, true)
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
            if (!DetectionStr) {  ; start of line
              send {left}
              this.SelectParagraphUp(, true)
              DetectionStr := this.Vim.ParseLineBreaks(copy(false))
            }
            DetectionStr := StrReverse(DetectionStr)
            pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence - 1, true)
            send % "{right}{left " . pos . "}"
          }
        } else if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {  ; searching forward
            this.SelectParagraphDown(, true)
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}
              this.SelectParagraphDown(, true)
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)
            pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
            if (pos)
              send % "{left}+{right " . pos + StrLen(StrBefore) . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
            if (pos) {
              right := pos
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
                if (NextOccurrence)
                  right := NextOccurrence
              }
              KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{right " . right . "}"
            }
          }
        } else {
          this.SelectParagraphDown(, true)
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr) {
            send {right}
            this.SelectParagraphDown(, true)
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else if (IsWhitespaceOnly(DetectionStr)) {
            send {right 2}
            this.SelectParagraphDown(, true)
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
          if (pos) {
            right := pos
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence
            }
          } else {
            right := 0
          }
          send % "{left}{right " . right . "}"
        }
      } else if (key == "b") {
        if (this.shift == 1) {
          send +^{Left}
        } else {
          send ^{Left}
        }
      } else if (key == "f") {  ; find forward
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {  ; searching forward
            send +{end}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}+{end}
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            pos += StrLen(StrBefore)
            send % "{left}+{right " . pos . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              right := pos - 1
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence)
                  right := NextOccurrence - 1
              }
              KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{right " . right . "}"
            }
          }
        } else {
          send +{end}
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if !DetectionStr {  ; end of line
            send {right}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else if (IsWhitespaceOnly(DetectionStr)) {
            send {right 2}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          if (pos) {
            right := pos - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence - 1
            }
          } else {
            right := 0
          }
          send % "{left}{right " . right . "}"
        }
      } else if (key == "t") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {  ; searching forward
            send +{end}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}+{end}
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := pos + StrLen(StrBefore) - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence + StrLen(StrBefore) - 1
            }
            send % "{left}+{right " . right . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              right := pos - 2
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence > 1) {
                  right := NextOccurrence - 2
                } else {
                  right := 0
                }
              }
              KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{right " . right . "}"
            }
          }
        } else {
          send +{end}
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if !DetectionStr {  ; end of line
            send {right}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else if (IsWhitespaceOnly(DetectionStr)) {
            send {right 2}+{end}  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          if (pos) {
            right := pos - 2
            if (pos == 1 || pos == 2)  {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence - 2
            }
          } else {
            right := 0
          }
          send % "{left}{right " . right . "}"
        }
      } else if (key == "+f") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
            send +{home}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              send +{left}+{home}
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos
            KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
            send % "+{right " . right . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrReverse(StrBefore)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              left := pos - 1
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence)
                  left := NextOccurrence - 1
              }
              if (StrLen(StrAfter) == StrLen(StrBefore))
                left++
              KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{left " . left . "}"
            }
          }
        } else {
          send +{home}
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if !DetectionStr {  ; start of line
            send {left}+{home}
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          send % "{right}{left " . pos . "}"
        }
      } else if (key == "+t") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
            send +{home}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              send +{left}+{home}
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos
            if (pos) {
              right++
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence)
                  right := StrLen(DetectionStr) - NextOccurrence + 1
              }
            }
            KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
            send % "+{right " . right . "}"
          } else if StrLen(StrAfter) <= StrLen(StrBefore) {
            DetectionStr := StrReverse(StrBefore)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              left := pos - 2
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (pos == 1 && NextOccurrence == 2) {  ; in instance like "see"
                  this.SearchOccurrence++
                  NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                  if (NextOccurrence)
                    left := NextOccurrence - 2
                } else if (NextOccurrence > 1) {
                  left := NextOccurrence - 2
                } else {
                  left := 0
                }
              }
              if (StrLen(StrAfter) == StrLen(StrBefore))
                left++
              KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{left " . left . "}"
            }
          }
        } else {
          send +{home}
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr) {  ; start of line
            send {left}+{home}
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          if (pos) {
            left := pos - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                left := NextOccurrence - 1
            }
          } else {
            left := 0
          }
          send % "{right}{left " . left . "}"
        }
      } else if (key == ")") {  ; like "f" but search for ". "
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
            this.SelectParagraphDown(, true)
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore) + 1) {  ; at end of paragraph
              send +{right}
              this.SelectParagraphDown(, true)
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)
            pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
            if (pos) {
              right := pos + 1 + StrLen(StrBefore)
              if (StrLen(DetectionStr) == pos + 2)  ; found at end of paragraph
                right++
              send % "{left}+{right " . right . "}"
            } else {
              send +{left}
            }
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {  ; search in selected text
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
            right := pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
            if (pos) {
              right++
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
                if (NextOccurrence)
                  right := pos + 1
              }
            }
            send % "+{right " . right . "}"
          }
        } else {
          this.SelectParagraphDown(, true)
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr || IsWhitespaceOnly(DetectionStr)) {  ; end of paragraph
            send {right}
            this.SelectParagraphDown(, true)  ; to the next line
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
            if (!DetectionStr) {  ; still end of paragraph
              send {right}
              this.SelectParagraphDown(, true)  ; to the next line
              DetectionStr := this.Vim.ParseLineBreaks(copy(false))
            }
          }
          pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
          if (pos) {
            right := pos + 1
            if (StrLen(DetectionStr) == pos + 2)  ; found at end of paragraph
              right++
            send % "{left}{right " . right . "}"
          } else {
            send {right}
          }
        }
      } else if (key == "(") {  ; like "+t"
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (StrLen(StrAfter) > StrLen(StrBefore)) {  ; search in selected text
            DetectionStr := StrReverse(StrBefore)
            pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
            left := pos - 2
            if (pos) {
              left++
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
                if (NextOccurrence)
                  left := NextOccurrence - 1
              }
            }
            send % "+{left " . left . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore) || !StrBefore) {
            this.SelectParagraphUp(, true)
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (!StrAfter) {  ; start of line
              send {left}
              this.SelectParagraphUp(, true)
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
            right := StrLen(DetectionStr) - pos
            if (pos) {
              right++
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
                if (NextOccurrence) {
                  right := StrLen(DetectionStr) - NextOccurrence + 1
                } else {
                  ret := true
                }
              }
            } else {
              ret := true
            }
            if (!ret)
              send % "+{right " . right . "}"
          }
        } else {
          this.SelectParagraphUp(, true)
          DetectionStr := copy(false)
          if (DetectionStr ~= "\r\n$") {  ; start of paragraph
            send {right}{left}
            this.SelectParagraphUp(, true)
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else {
            DetectionStr := this.vim.ParseLineBreaks(DetectionStr)
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
          if (pos) {
            left := pos - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence, true)
              if (NextOccurrence) {
                left := NextOccurrence - 1
              } else {
                ret := true
              }
            }
          } else {
            ret := true
          }
          if (ret) {
            send {left}
          } else {
            send % "{right}{left " . left . "}"
          }
        }
      } else if (key == "s") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {  ; searching forward
            this.SelectParagraphDown(, true)
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              send +{right}
              this.SelectParagraphDown(, true)
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := pos + StrLen(StrBefore) - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence + StrLen(StrBefore) - 1
            }
            send % "{left}+{right " . right . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              right := pos - 1
              if (pos == 2 || pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence > 1) {
                  right := NextOccurrence - 1
                } else {
                  right := 0
                }
              }
              KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{right " . right . "}"
            }
          }
        } else {
          this.SelectParagraphDown(, true)
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr) {
            send {right}
            this.SelectParagraphDown(, true)
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          } else if (IsWhitespaceOnly(DetectionStr)) {
            send {right 2}
            this.SelectParagraphDown(, true)
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          if (pos) {
            right := pos - 1
            if (pos == 1) {
              this.SearchOccurrence++
              NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
              if (NextOccurrence)
                right := NextOccurrence - 1
            }
          } else {
            right := 0
          }
          send % "{left}{right " . right . "}"
        }
      } else if (key == "+s") {
        this.FtsChar := StrReverse(this.FtsChar)
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := this.Vim.ParseLineBreaks(copy(false))
            send +{left}
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            send +{right}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
            this.SelectParagraphUp(, true)
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              send +{left}
              this.SelectParagraphUp(, true)
              StrAfter := this.Vim.ParseLineBreaks(copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos - 1
            KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
            send % "+{right " . right . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrReverse(StrBefore)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              left := pos + 2
              if (pos == 1) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence)
                  left := NextOccurrence + 2
              }
              KeyWait Shift  ; keys that need shift (like "(") would mess up the shift below
              send % "+{left " . left . "}"
            }
          }
        } else {
          this.SelectParagraphUp(, true)
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          if (!DetectionStr) {  ; start of line
            send {left}
            this.SelectParagraphUp(, true)
            DetectionStr := this.Vim.ParseLineBreaks(copy(false))
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          pos := pos ? pos + 1 : 0
          send % "{right}{left " . pos . "}"
        }
      } else if (key == "/") {
        hWnd := WinActive("A")
        InputBoxPrompt := " text until:`n(case sensitive)"
        InputBoxHeight := 144
        if (this.Vim.State.StrIsInCurrentVimMode("Visual")) {
          InputBoxPrompt := "Select" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_y")) {
          InputBoxPrompt := "Copy" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_d")) {
          InputBoxPrompt := "Delete" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
          InputBoxPrompt := "Delete" . InputBoxPrompt . "`n(will enter insert mode)"
          InputBoxHeight := 160
        } else if (this.Vim.State.StrIsInCurrentVimMode("Extract")) {
          InputBoxPrompt := "Extract" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("Cloze")) {
          InputBoxPrompt := "Cloze" . InputBoxPrompt
        }
        InputBox, UserInput, Visual Search, % InputBoxPrompt,, 272, % InputBoxHeight,,,,, % this.LastSearch
        if (!UserInput || ErrorLevel)
          return
        this.LastSearch := UserInput  ; register UserInput into LastSearch
        WinActivate % "ahk_id " . hWnd
        if (!this.NoSelection()) {  ; determine caret position
          StrBefore := this.Vim.ParseLineBreaks(copy(false))
          send +{right}
          StrAfter := this.Vim.ParseLineBreaks(copy(false))
          send +{left}
        }
        if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
          this.SelectParagraphDown(, true)
          StrAfter := this.Vim.ParseLineBreaks(copy(false))
          if (StrLen(StrAfter) == StrLen(StrBefore) + 1) {  ; at end of paragraph
            send +{right}
            this.SelectParagraphDown(, true)
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
          }
          StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
          DetectionStr := SubStr(StrAfter, StartPos)
          pos := InStr(DetectionStr, UserInput, true,, this.SearchOccurrence)
          left := StrLen(DetectionStr) - pos + 1
          if (pos == 1) {
            this.SearchOccurrence++
            NextOccurrence := InStr(DetectionStr, UserInput, true,, this.SearchOccurrence)
            if (NextOccurrence)
              left := StrLen(DetectionStr) - NextOccurrence + 1
          }
          send % "+{left " . left . "}"
        } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
          pos := InStr(StrBefore, UserInput, true)
          pos -= pos ? 1 : 0
          send % "+{right " . pos . "}"
        }
      } else if (key == "?") {
        hWnd := WinActive("A")
        InputBoxPrompt := " text until:`n(case sensitive)"
        InputBoxHeight := 144
        if (this.Vim.State.StrIsInCurrentVimMode("Visual")) {
          InputBoxPrompt := "Select" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_y")) {
          InputBoxPrompt := "Copy" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_d")) {
          InputBoxPrompt := "Delete" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
          InputBoxPrompt := "Delete" . InputBoxPrompt . "`n(will enter insert mode)"
          InputBoxHeight := 160
        } else if (this.Vim.State.StrIsInCurrentVimMode("Extract")) {
          InputBoxPrompt := "Extract" . InputBoxPrompt
        } else if (this.Vim.State.StrIsInCurrentVimMode("Cloze")) {
          InputBoxPrompt := "Cloze" . InputBoxPrompt
        }
        InputBox, UserInput, Visual Search, % InputBoxPrompt,, 272, % InputBoxHeight,,,,, % this.LastSearch
        if (!UserInput || ErrorLevel)
          return
        this.LastSearch := UserInput  ; register UserInput into LastSearch
        WinActivate % "ahk_id " . hWnd
        if (!this.NoSelection()) {  ; determine caret position
          StrBefore := this.Vim.ParseLineBreaks(copy(false))
          send +{right}
          StrAfter := this.Vim.ParseLineBreaks(copy(false))
          send +{left}
        }
        if (StrLen(StrAfter) > StrLen(StrBefore)) {
          pos := InStr(StrReverse(StrBefore), StrReverse(UserInput), true)
          pos += pos ? StrLen(UserInput) - 2 : 0
          send % "+{left " . pos . "}"
        } else if (StrLen(StrAfter) <= StrLen(StrBefore)) || !StrBefore {
          this.SelectParagraphUp(, true)
          StrAfter := this.Vim.ParseLineBreaks(copy(false))
          if (!StrAfter) {  ; start of line
            send {left}
            this.SelectParagraphUp(, true)
            StrAfter := this.Vim.ParseLineBreaks(copy(false))
          }
          StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
          DetectionStr := SubStr(StrReverse(StrAfter), StartPos)
          pos := InStr(DetectionStr, StrReverse(UserInput), true,, this.SearchOccurrence)
          right := StrLen(DetectionStr) - pos - StrLen(UserInput) + 1
          send % "+{right " . right . "}"
        }
      } else if (key == "x") {
        if (this.Vim.IsNavigating()) {
          send {del}
        } else if (this.shift != 1) {
          send +{right}
        }
      } else if (key == "+x") {
        if (this.Vim.IsNavigating()) {
          send {bs}
        } else if (this.shift != 1) {
          send +{left}
        }
      }
    }
    ; Up/Down 1 character
    if (key == "j") {
      if (this.Vim.SM.IsBrowsing()) {
        if (ControlGet(,, "Internet Explorer_Server2", "A")) {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server2, A  ; scroll down
        } else {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A  ; scroll down
        }
      } else {
        this.Down()
      }
    } else if (key == "^e") {
      if (WinActive("ahk_group VimForceScroll")) {
        ; if (c := A_CaretX)
        ;   this.Vim.SM.PrepareStatBar(1, A_CaretX, A_CaretY)
        send {CtrlUp}{WheelDown}
        ; if (c)
        ;   this.Vim.SM.PrepareStatBar(2)
      } else {
        SendMessage, 0x0115, 1, 0, % ControlGetFocus("A"), A  ; scroll down
      }
    } else if (key == "k") {
      if (this.Vim.SM.IsBrowsing()) {
        if (ControlGet(,, "Internet Explorer_Server2", "A")) {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server2, A  ; scroll up
        } else {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A  ; scroll up
        }
      } else {
        this.Up()
      }
    } else if (key == "^y") {
      if (WinActive("ahk_group VimForceScroll")) {
        ; if (c := A_CaretX)
        ;   this.Vim.SM.PrepareStatBar(1, A_CaretX, A_CaretY)
        send {CtrlUp}{WheelUp}
        ; if (c)
        ;   this.Vim.SM.PrepareStatBar(2)
      } else {
        SendMessage, 0x0115, 0, 0, % ControlGetFocus("A"), A  ; scroll up
      }
    ; Page Up/Down
    } else if (key == "^u") {
      if (this.Vim.SM.IsBrowsing()) {
        if (ControlGet(,, "Internet Explorer_Server2", "A")) {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server2, A  ; scroll up
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server2, A  ; scroll up
        } else {
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A  ; scroll up
          SendMessage, 0x0115, 0, 0, Internet Explorer_Server1, A  ; scroll up
        }
      } else {
        this.Up(10)
      }
    } else if (key == "^d") {
      if (this.Vim.SM.IsBrowsing()) {
        if (ControlGet(,, "Internet Explorer_Server2", "A")) {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server2, A  ; scroll down
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server2, A  ; scroll down
        } else {
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A  ; scroll down
          SendMessage, 0x0115, 1, 0, Internet Explorer_Server1, A  ; scroll down
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
        if (this.Vim.SM.IsBrowsing()) {
          send ^t
          this.Vim.SM.WaitTextFocus()
        } else {
          this.HandleClickBtn()
        }
        send % "^{home}{down " . this.Vim.State.n - 1 . "}"
        this.Vim.State.n := 0, this.HandleClickBtn()
      } else if (this.Vim.State.IsCurrentVimMode("Vim_Normal") && this.Vim.SM.IsBrowsing()) {
        if (ControlGet(,, "Internet Explorer_Server2", "A")) {
          SendMessage, 0x115, 6, 0, Internet Explorer_Server2, A  ; scroll to top
        } else {
          SendMessage, 0x115, 6, 0, Internet Explorer_Server1, A  ; scroll to top
        }
      } else {
        send ^{Home}
      }
    } else if (key == "+g") {
        if (this.Vim.State.n > 0) {
          KeyWait Shift
          if (this.Vim.SM.IsBrowsing()) {
            this.Vim.SM.ClickTop()
            this.Vim.SM.WaitTextFocus()
          } else if (this.Vim.SM.IsEditingText()) {
            this.Vim.SM.ClickTop()
          } else {
            this.HandleClickBtn()
            send ^{home}
          }
          send % "{down " . this.Vim.State.n - 1 . "}"
          this.Vim.State.n := 0, this.HandleClickBtn()
        } else if (this.Vim.State.IsCurrentVimMode("Vim_Normal") && this.Vim.SM.IsBrowsing()) {
          if (ControlGet(,, "Internet Explorer_Server2", "A")) {
            SendMessage, 0x115, 7, 0, Internet Explorer_Server2, A  ; scroll to bottom
          } else {
            SendMessage, 0x115, 7, 0, Internet Explorer_Server1, A  ; scroll to bottom
          }
        } else {
          if (this.shift == 1) {
            send ^+{End}
            if (!this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
              send +{home}
          } else {
            send ^{End}
            if (this.Vim.SM.IsNavigatingPlan() || !this.vim.IsNavigating())
              send {Home}
          }
          if (this.Vim.SM.IsEditingHTML()) {
            send ^+{up}  ; if there are references this would select (or deselect in visual mode) them all
            if (this.shift == 1)
              send +{down}  ; go down one line, if there are references this would include the #SuperMemo Reference
            KeyWait Shift
            if (IfContains(copy(false,, 1), "#SuperMemo Reference:")) {
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
                send ^{end}{home}
              }
            }
          }
        }
    } else if (key == "{") {
      if ((this.Vim.State.n > 0) && WinActive("ahk_class TElWind") && !repeat) {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
        KeyWait Shift
        if (!this.Vim.SM.IsEditingText()) {
          send ^t
          this.Vim.SM.WaitTextFocus()
        }
        send ^{home}
        this.ParagraphDown(this.Vim.State.GetN() - 1)
      } else if (this.shift == 1) {
        this.SelectParagraphUp()
      } else {
        this.ParagraphUp()
      }
    } else if (key == "}") {
      if ((this.Vim.State.n > 0) && WinActive("ahk_class TElWind") && !repeat) {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
        KeyWait Shift
        this.Vim.SM.ClickTop()
        this.Vim.SM.WaitTextFocus()
        this.ParagraphDown(this.Vim.State.GetN() - 1)
      } else if (this.shift == 1) {
        this.SelectParagraphDown()
      } else {
        this.ParagraphDown()
      }
    } else if (key == "gn") {
      global VimLastSearch
      global CapsState := CtrlState := AltState := ""
      global ShiftState := true
      if (!this.Vim.State.StrIsInCurrentVimMode("Vim_Visual"))
        PrevMode := this.Vim.State.Mode
      Gosub SMSearch
      if (!this.Vim.State.StrIsInCurrentVimMode("Vim_Visual"))
        this.Vim.State.SetMode(PrevMode)
    }

    if (!repeat && finalize)
      this.MoveFinalize()
  }

  Repeat(key:="", initialize:=true, finalize:=true) {
    if (initialize)
      this.MoveInitialize(key)
    if (this.ReggedForDot)
      this.LastRepeat := true
    if (this.Vim.State.n == 0)
      this.Vim.State.n := 1
    if (IfIn(key, "j,k") && (this.Vim.State.n > 1))
      this.HandleClickBtn(), navigate := true
    loop % this.Vim.State.n
      this.Move(key, true)
    if (navigate)
      this.HandleClickBtn()
    if (finalize)
      this.MoveFinalize()
  }

  YDCMove() {
    this.Vim.State.LineCopy := 1
    this.Zero()
    send {shift down}
    if (this.Vim.State.n == 0)
      this.Vim.State.n := 1
    this.Down(this.Vim.State.n - 1)
    if (WinActive("ahk_group VimLBSelectGroup") && (this.Vim.State.n == 2))
      send {right}
    send {End}
    if (this.IsReplace())
      send {left}
    if (!WinActive("ahk_group VimLBSelectGroup")) {
      this.Move("l")
    } else {
      this.Move("")
    }
    this.LastLineCopy := true
  }

  Inner(key:="") {
    global WinClip
    RestoreClip := Vim.State.StrIsInCurrentVimMode("Vim_ydc") ? false : true
    if (key == "w") {
      send ^{right}^{left}
      this.Move("e",,, false), finalize := true
    } else if (key == "s") {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      send +{right}
      if (copy(false) ~= "`n") {
        send {left}
      } else {
        send {right}
      }
      this.Move("(",,, false, true, false)
      this.Move(")",,, false,, false)
      if (!this.v)  ; end of paragraph
        this.FindSentenceEnd(this.Vim.ParseLineBreaks(copy(false)))
      n := StrLen(this.v)
      if (RestoreClip)
        Clipboard := ClipSaved
      if (n)
        send % "+{left " . n . "}"
      finalize := true
    } else if (key == "p") {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      this.ParagraphDown()
      this.ParagraphUp()
      this.SelectParagraphDown()
      selection := copy(false)
      if (this.Vim.SM.IsEditingHTML()) {
        send +{left}
        if (IfContains(selection, this.hr))
          send +{left}
        selection := ""
      }
      DetectionStr := this.Vim.ParseLineBreaks(selection ? selection : copy(false))
      DetectionStr := StrReverse(DetectionStr)
      RegExMatch(DetectionStr, "^(\s+)?((\]\d+\[)+)?(\.|。)", v), n := StrLen(v)
      if (RestoreClip)
        Clipboard := ClipSaved
      if (n) {
        send % "+{left " . n . "}"
      } else {
        send +{left}+{right}  ; refresh caret
      }
      finalize := true
    } else if (IfIn(key, this.InnerKeys)) {
      this.RegForDot(key)
      if (RestoreClip)
        ClipSaved := ClipboardAll
      KeyWait Shift
      send +{right}
      if (copy(false) ~= "`n") {
        send {left}
      } else {
        send {right}
      }
      this.SelectParagraphUp(, true)
      DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      if (!DetectionStr) {  ; start of paragraph
        send {left}
        this.SelectParagraphUp(, true)
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      }
      DetectionStr := StrReverse(DetectionStr)
      key := this.RevSurrKey(key)
      if (AltKey := this.GetAltKey(key)) {
        pos := RegExMatch(DetectionStr, AltKey)
      } else {
        pos := InStr(DetectionStr, key)
      }
      left := pos ? pos - 1 : 0
      send % "{right}{left " . left . "}"
      if (!pos) {
        send {left}
      } else {
        this.SelectParagraphDown(, true)
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
        if (!DetectionStr) {  ; end of paragraph
          send {right}  ; to the next paragraph
          this.SelectParagraphDown(, true)
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
        } else if (IsWhitespaceOnly(DetectionStr)) {
          send {right 2}  ; to the next paragraph
          this.SelectParagraphDown(, true)
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
        }
        key := this.RevSurrKey(key, 2)
        if (AltKey := this.GetAltKey(key)) {
          pos := RegExMatch(DetectionStr, AltKey)
        } else {
          pos := InStr(DetectionStr, key)
        }
        pos := pos ? pos - 1 : 0
        send % "{left}+{right " . pos . "}"
      }
      if (RestoreClip)
        Clipboard := ClipSaved
      finalize := true
    }
    this.RegForDot(key), this.LastInOrOut := "Inner"
    if (finalize)
      this.MoveFinalize()
  }

  Outer(key:="") {
    global WinClip
    RestoreClip := Vim.State.StrIsInCurrentVimMode("Vim_ydc") ? false : true
    if (key == "w") {
      send ^{right}^{left}^+{right}
      finalize := true
    } else if (key == "s") {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      send +{right}
      if (copy(false) ~= "`n") {
        send {left}
      } else {
        send {right}
      }
      this.Move("(",,, false, true, false)
      this.Move(")",,, false,, false)
      if (RestoreClip)
        Clipboard := ClipSaved
      if (this.IsReplace()) {
        if (this.v)
          n := StrLen(RegExReplace(this.v, "\.\K(\[.*?\])+")) - 1
        send % "+{left " . n . "}"  ; so that "dap" would delete an entire paragraph, whereas "cap" would empty the paragraph
      }
      finalize := true
    } else if (key == "p") {
      this.Vim.State.LineCopy := 1
      this.ParagraphDown()
      this.ParagraphUp()
      this.SelectParagraphDown()
      if (this.IsReplace())
        send +{left}  ; so that "dap" would delete an entire paragraph, whereas "cap" would empty the paragraph
      finalize := true
    } else if (IfIn(key, this.InnerKeys)) {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      KeyWait Shift
      send +{right}
      if (copy(false) ~= "`n") {
        send {left}
      } else {
        send {right}
      }
      this.SelectParagraphUp(, true)
      DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      if (!DetectionStr) {  ; start of paragraph
        send {left}
        this.SelectParagraphUp(, true)
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
      }
      DetectionStr := StrReverse(DetectionStr)
      key := this.RevSurrKey(key)
      if (AltKey := this.GetAltKey(key)) {
        pos := RegExMatch(DetectionStr, AltKey)
        key := SubStr(DetectionStr, pos, 1)
      } else {
        pos := InStr(DetectionStr, key)
      }
      send % "{right}{left " . pos . "}"
      if (pos) {
        this.SelectParagraphDown(, true)
        DetectionStr := this.Vim.ParseLineBreaks(copy(false))
        if (!DetectionStr) {  ; end of paragraph
          send {right}  ; to the next paragraph
          this.SelectParagraphDown(, true)
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
        } else if (IsWhitespaceOnly(DetectionStr)) {
          send {right 2}  ; to the next paragraph
          this.SelectParagraphDown(, true)
          DetectionStr := this.Vim.ParseLineBreaks(copy(false))
        }
        key := this.RevSurrKey(key, 2)
        pos := InStr(DetectionStr, key,, 2)
        send % "{left}+{right " . pos . "}"
      }
      if (RestoreClip)
        Clipboard := ClipSaved
      finalize := true
    }
    this.RegForDot(key), this.LastInOrOut := "Outer"
    if (finalize)
      this.MoveFinalize()
  }

  RevSurrKey(key, step:=1) {
    if (step == 1) {
      key := (key == ")") ? "(" : key
      key := (key == "）") ? "（" : key
      key := (key == "}") ? "{" : key
      key := (key == "]") ? "[" : key
      key := (key == ">") ? "<" : key
      key := (key == "»") ? "«" : key
      key := (key == "”") ? "“" : key
    } else if (step == 2) {
      key := (key == "(") ? ")" : key
      key := (key == "（") ? "）" : key
      key := (key == "{") ? "}" : key
      key := (key == "[") ? "]" : key
      key := (key == "<") ? ">" : key
      key := (key == "«") ? "»" : key
      key := (key == "“") ? "”" : key
    }
    return key
  }

  FindPos(DetectionStr, text, Occurrence:=1) {
    if (StrLen(text) == 2) {  ; vim-sneak search
      AltText1 := this.GetAltKey(text1 := SubStr(text, 1, 1))
      AltText2 := this.GetAltKey(text2 := SubStr(text, 2, 1))
      if (regex := (AltText1 || AltText2)) {
        AltText1 := AltText1 ? AltText1 : text1
        AltText2 := AltText2 ? AltText2 : text2
        AltText1 := (IsRegExChar(AltText1)) ? "\" . AltText1 : AltText1
        AltText2 := (IsRegExChar(AltText2)) ? "\" . AltText2 : AltText2
        AltText := "(" . AltText1 . ")(" . AltText2 . ")"
      }
    }
    if (regex || (AltText := this.GetAltKey(text))) {
      pos := RegExMatch(DetectionStr, "s)((" . AltText . ").*?){" . Occurrence - 1 . "}\K(" . AltText . ")")
    } else {
      pos := InStr(DetectionStr, text, true,, Occurrence)
    }
    return pos
  }

  FindSentenceEnd(DetectionStr, Occurrence:=1, reversed:=false) {
    if (pos := RegExMatch(DetectionStr, "s)(([。？！][^。？！]).*?){" . Occurrence - 1 . "}\K[。？！][^。？！]", v)) {
      pos := (pos > 1) ? pos - 1 : 1
      if (reversed) {
        if (pos == 1) {
          pos := RegExMatch(DetectionStr, "s)(([。？！][^。？！]).*?){" . Occurrence . "}\K[。？！][^。？！]", v)
        } else {
          pos++
        }
      }
      this.v := v
      return pos
    }
    if (!reversed) {
      pos := RegExMatch(DetectionStr, "s)((\.|!|\?)((\[.*?\])+\s|[^" . this.WordBoundChars . ",.\]]+).*?){" . Occurrence - 1 . "}\K(\.|!|\?)((\[.*?\])+\s|[^" . this.WordBoundChars . ",.\]]+)", v)
      if (pos)
        pos += StrLen(v) - 2
      this.v := v
      this.DetectionStr := DetectionStr
    } else {
      pos := RegExMatch(DetectionStr, "s)((\s(\].*?\[)+|[^" . this.WordBoundChars . ",.\[]+)(\.|!|\?).*?){" . Occurrence - 1 . "}\K(\s(\].*?\[)+|[^" . this.WordBoundChars . ",.\[]+)(\.|!|\?)")
    }
    return pos
  }

  FindWordBoundary(DetectionStr, Occurrence:=1, reversed:=false) {
    ; Can't use \b for word boundary. Somehow, the letter "ó" counts as word boundary,
    ; so words like cicatrización wouldn't correctly match
    if (!reversed) {
      pos := RegExMatch(DetectionStr, "s)(([" . this.WordBoundChars . "][^" . this.WordBoundChars . "]).*?){" . Occurrence - 1 . "}\K[" . this.WordBoundChars . "][^" . this.WordBoundChars . "]")
    } else {
      pos := RegExMatch(DetectionStr, "s)(([^" . this.WordBoundChars . "][" . this.WordBoundChars . "]).*?){" . Occurrence . "}\K[^" . this.WordBoundChars . "][" . this.WordBoundChars . "]")
    }
    return pos
  }

  HandleClickBtn() {
    if (WinActive("ahk_class TContents")) {
      ClickDPIAdjusted(295, 50)
    } else if (WinActive("ahk_class TBrowser")) {
      ClickDPIAdjusted(638, 46)
    }
  }

  GetAltKey(key) {  ; return is regex compatible
    if (key == """") {
      ret := """|“|”|«|»"
    } else if (key == "'") {
      ret := "'|‘|’"
    } else if (key == "(") {
      ret := "\(|（"
    } else if (key == ")") {
      ret := "\)|）"
    } else if (key == ".") {
      ret := "\.|。"
    } else if (key == ",") {
      ret := ",|，"
    } else if (key == ":") {
      ret := ":|："
    } else if (key == ";") {
      ret := ";|；"
    } else if (key == "?") {
      ret := "\?|？"
    } else if (key == "!") {
      ret := "!|！"
    } else if (key == "[") {
      ret := "\[|【"
    } else if (key == "]") {
      ret := "\]|】"
    } else if (key == "-") {
      ret := "-|—|–"
    }
    return ret
  }
}
