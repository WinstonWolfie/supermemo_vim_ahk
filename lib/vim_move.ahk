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
      return this.ExistingSelection := true  ; so it only returns true once in repeat
  }

  IsSearchKey(key) {
    global SM
    return (IfIn(key, "f,t,+f,+t,(,),s,+s,/,?,e,gn")
         || ((key == "+g") && SM.IsEditingHTML()))
  }

  IsReplace() {
    return (this.Vim.State.StrIsInCurrentVimMode("ydc_c,SMVim_") || this.Vim.State.Surround)
  }
  
  IsRestoreClipMode() {
    return !this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")
  }

  IsRestoreClipLaterMode() {
    return this.Vim.State.StrIsInCurrentVimMode("Vim_g")
  }

  IsMotionOnly() {
    return (this.Vim.State.IsCurrentVimMode("Vim_Normal") || this.Vim.State.StrIsInCurrentVimMode("Vim_Visual"))
  }

  IsNormalKey(key) {  ; keys that act rather like normal mode
    return IfIn(key, "x,+x")
  }

  RegForDot(key) {
    if (this.ReggedForDot := ((!this.IsMotionOnly() || this.IsNormalKey(key)) && !((A_ThisLabel == ".") && !this.Vim.State.fts))) {
      this.LastInOrOut := this.LastRepeat := this.LastSurround := this.LastSurroundKey := this.LastLineCopy := ""
      this.LastKey := key, this.LastN := this.Vim.State.n, this.LastMode := this.Vim.State.Mode
      this.LastFtsChar := this.Vim.State.FtsChar ? this.Vim.State.FtsChar : ""
    }
  }

  MoveInitialize(key:="", RestoreClip:=true) {
    this.shift := this.ExistingSelection := this.Clipped := 0
    this.RegForDot(key)

    if (this.IsSearchKey(key)) {
      this.SearchOccurrence := this.Vim.State.n ? this.Vim.State.n : 1
      this.FtsChar := this.Vim.State.FtsChar
      if (RestoreClip && this.IsRestoreClipMode()) {
        global ClipSaved
        ClipSaved := ClipboardAll
        this.Clipped := true
      }
      KeyWait Shift
    }
    
    if (this.Vim.State.StrIsInCurrentVimMode("Visual,ydc,SMVim_,Vim_g")) {
      this.shift := 1
      if (!this.IsSearchKey(key) && !this.IsNormalKey(key))
        Send {Shift Down}
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst") && IfIn(key, "k,^u,^b,g")) {
      Send {Shift Up}{Right}{Shift Down}
      this.Zero()
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualLineFirst") && IfIn(key, "j,^d,^f,+g"))
      this.Vim.State.SetMode("Vim_VisualLine",, -1)  ; -1 is needed for repeat to work

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst") && IfIn(key, "k,^u,^b,g")) {
      Send {Shift Up}{Right}{Left}{Shift Down}
      this.Up()
      this.Vim.State.SetMode("Vim_VisualParagraph",, -1)  ; -1 is needed for repeat to work
    }

    if (this.Vim.State.IsCurrentVimMode("Vim_VisualParagraphFirst") && IfIn(key, "j,^d,^f,+g"))
      this.Vim.State.SetMode("Vim_VisualParagraph",, -1)  ; -1 is needed for repeat to work
  
    if (this.Vim.State.IsCurrentVimMode("Vim_VisualBlock") && WinActive("ahk_exe notepad++.exe"))
      Send {Alt Down}

    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc,SMVim_") && IfIn(key, "k,^u,^b,g")) {
      this.Vim.State.LineCopy := 1
      Send {Shift Up}
      this.Zero()
      this.Down()
      Send {Shift Down}
      this.Up()
    }
  
    if (this.Vim.State.StrIsInCurrentVimMode("Vim_ydc,SMVim_") && IfIn(key, "j,^d,^f,+g")) {
      this.Vim.State.LineCopy := 1
      Send {Shift Up}
      this.Zero()
      Send {Shift Down}
      this.Down()
    }

    if (this.IsNormalKey(key) && !this.Vim.IsNavigating())
      this.Vim.State.SetMode("Vim_ydc_d", 0, -1, 0,,, -1)  ; LineCopy must be 0
  }

  MoveFinalize() {
    global SM
    this.Vim.State.FtsChar := ""
    if (this.Clipped) {
      Clipped := "Clipped"
      if (!this.IsRestoreClipLaterMode()) {
        global ClipSaved
        Clipboard := ClipSaved
      }
    }
    if (this.Vim.State.Surround)
      this.SurroundKeyEntered := true
    Send {Shift Up}
    KeyWait Shift
    if (!this.Vim.State.Surround || !this.Vim.State.StrIsInCurrentVimMode("Vim_ydc")) {
      if (ydc_y := this.Vim.State.StrIsInCurrentVimMode("ydc_y")) {
        this.YdcClipSaved := Copy(false), this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_d")) {
        if (!this.Vim.State.Leader) {
          this.YdcClipSaved := Copy(false,, "^x")
        } else {
          Send {BS}
        }
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ydc_c")) {
        if (!this.Vim.State.Leader) {
          this.YdcClipSaved := Copy(false,, "^x")
        } else {
          Send {BS}
        }
        this.Vim.State.SetMode("Insert")
      } else if (this.Vim.State.StrIsInCurrentVimMode("Vim_gu")) {
        Gosub % "ConvertToLowercase" . Clipped
      } else if (this.Vim.State.StrIsInCurrentVimMode("Vim_gU")) {
        Gosub % "ConvertToUppercase" . Clipped
      } else if (this.Vim.State.StrIsInCurrentVimMode("Vim_g~")) {
        Gosub % "InvertCase" . Clipped
      } else if (this.Vim.State.StrIsInCurrentVimMode("ExtractStay")) {
        Gosub ExtractStay
      } else if (this.Vim.State.StrIsInCurrentVimMode("ExtractPriority")) {
        Send !+x
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("Extract")) {
        Send !x
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ClozeStay")) {
        Gosub SMClozeStay
      } else if (this.Vim.State.StrIsInCurrentVimMode("ClozeHinter")) {
        global InitText := ""
        Gosub SMClozeHinter
      } else if (this.Vim.State.StrIsInCurrentVimMode("ClozeNoBracket")) {
        Gosub SMClozeNoBracket
      } else if (this.Vim.State.StrIsInCurrentVimMode("Cloze")) {
        SM.Cloze()
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("AltT")) {
        SM.AltT(), this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("AltQ")) {
        Send !q
        WinWaitActive, ahk_class TChoicesDlg
        Send % this.KeyAfterSMAltQ . "{Enter}"
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("GAltA")) {
        Gosub SMParseHTML
        this.Vim.State.SetMode("Vim_Normal")
      } else if (this.Vim.State.StrIsInCurrentVimMode("ParseHTML")) {
        Send ^+1
        this.Vim.State.SetMode("Vim_Normal")
      }
    }
    this.Vim.State.SetMode("", 0, 0,,, -1)
    if (ydc_y)
      Send {Left}
    ; Sometimes, when using `c`, the control key would be stuck down afterwards.
    ; This forces it to be up again afterwards.
    Send {LCtrl Up}{RCtrl Up}
    if (!WinActive("ahk_exe iexplore.exe") && !WinActive("ahk_exe Notepad.exe") && GetKeyState("Alt", "P"))
      Send {Alt Up}
    if (this.Vim.State.IsCurrentVimMode("Vim_VisualFirst") || this.Vim.State.StrIsInCurrentVimMode("Inner,Outer"))
      this.Vim.State.SetMode("Vim_VisualChar",,,,, -1)
  }

  Zero() {
    global SM
    if (SM.IsBrowsing()) {
      if (ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind")) {
        SendMessage, 0x114, 2, 0, Internet Explorer_Server2, A  ; scroll all the way to left
      } else {
        SendMessage, 0x114, 2, 0, Internet Explorer_Server1, A  ; scroll all the way to left
      }
      return
    }
    if (WinActive("ahk_group VimDoubleHomeGroup")) {
      Send {Home}
    } else if (WinActive("ahk_exe notepad++.exe")) {
      Send {End}
    }
    Send {Home}
  }

  Up(n:=1) {
    if (this.Vim.State.StrIsInCurrentVimMode("Paragraph") && this.Vim.IsHTML()) {
      if (shift == 1) {
        this.SelectParagraphUp(n)
      } else {
        this.ParagraphUp(n)
      }
    } else if (WinActive("ahk_group VimCtrlUpUpGroup")) {
      Send % "^{Up " . n . "}"
    } else {
      Send % "{Up " . n . "}"
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
      Send % "^{Down " . n . "}"
    } else {
      Send % "{Down " . n . "}"
    }
  }

  ParagraphUp(n:=1) {
    if (this.Vim.IsHTML()) {
      global SM
      if (SM.IsEditingHTML()) {
        Send % "^+{Up " . n . "}{Left}"
      } else {
        Send % "^{Up " . n . "}"
      }
    } else {
      this.up(n)
      Send {End}
      this.Zero()
    }
  }

  ParagraphDown(n:=1) {
    if (this.Vim.IsHTML()) {
      Send % "^{Down " . n . "}"
    } else {
      this.Down(n)
      Send {End}
      this.Zero()
    }
  }

  SelectParagraphUp(n:=1, detection:=false) {
    global SM
    if (this.Vim.IsHTML()) {
      Send % "^+{Up " . n . "}"
    } else if (SM.IsEditingPlainText() && detection) {
      Send ^+{Home}
    } else {
      Send % "+{Up " . n - 1 . "}+{Home}"
    }
  }

  SelectParagraphDown(n:=1, detection:=false) {
    global SM
    if (this.Vim.IsHTML()) {
      Send % "^+{Down " . n . "}"
    } else if (SM.IsEditingPlainText() && detection) {
      Send ^+{End}
    } else {
      Send % "+{Down " . n - 1 . "}+{End}"
    }
  }

  Move(key="", Repeat:=false, Init:=true, Final:=true, ForceShiftRelease:=false, RestoreClip:=true) {
    if (!Repeat && Init)
      this.MoveInitialize(key, RestoreClip)
    if (ForceShiftRelease)
      this.shift := 0
    global SM

    ; Left/Right
    ; if (!this.Vim.State.StrIsInCurrentVimMode("Line,Paragraph")) {
    if (true) {  ; sometimes lines are not accurate, this allows minor adjusts
      ; For some cases, need '+' directly to continue to select
      ; especially for cases using shift as original keys
      ; For now, caret does not work even add + directly

      ; 1 character
      if (key == "h") {
        if (WinActive("ahk_group VimQdir")) {
          Send {BackSpace down}{BackSpace up}
        } else if (SM.IsBrowsing()) {
          if (ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind")) {
            SendMessage, 0x114, 0, 0, Internet Explorer_Server2, A  ; scroll left
          } else {
            SendMessage, 0x114, 0, 0, Internet Explorer_Server1, A  ; scroll left
          }
        } else {
          Send {Left}
        }
      } else if (key == "l") {
        if (WinActive("ahk_group VimQdir")) {
          Send {Enter}
        } else if (SM.IsBrowsing()) {
          if (ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind")) {
            SendMessage, 0x114, 1, 0, Internet Explorer_Server2, A  ; scroll right
          } else {
            SendMessage, 0x114, 1, 0, Internet Explorer_Server1, A  ; scroll right
          }
        } else {
          Send {Right}
        }
      ; Home/End
      } else if (key == "0") {
        this.Zero()
      } else if (key == "$") {
        if (SM.IsBrowsing()) {
          if (ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind")) {
            SendMessage, 0x114, 3, 0, Internet Explorer_Server2, A  ; scroll all the way to right
          } else {
            SendMessage, 0x114, 3, 0, Internet Explorer_Server1, A  ; scroll all the way to right
          }
        } else if (this.shift == 1) {
          Send +{End}
        } else {
          Send {End}
        }
      } else if (key == "^") {
        if (this.shift == 1) {
          if (WinActive("ahk_group VimCaretMove")) {
            Send +{Home}
            Send +^{Right}
            Send +^{Left}
          } else {
            Send +{Home}
          }
        } else {
          if (WinActive("ahk_group VimCaretMove")) {
            Send {Home}
            Send ^{Right}
            Send ^{Left}
          } else {
            Send {Home}
            if (WinActive("ahk_exe notepad++.exe"))
              Send {Home}
          }
        }
      } else if (key == "+") {
        if (this.shift == 1) {
          Send +{Down}+{End}+{Home}
        } else {
          Send {Down}{End}{Home}
        }
      } else if (key == "-") {
        if (this.shift == 1) {
          Send +{Up}+{End}+{Home}
        } else {
          Send {Up}{End}{Home}
        }
      ; Words
      } else if (key == "w") {
        if (this.shift == 1) {
          Send +^{Right}
        } else {
          Send ^{Right}
        }
      } else if (key == "e") {
        if (this.Vim.State.g) {  ; ge
          if (this.shift == 1) {
            if (!this.NoSelection()) {  ; determine caret position
              StrBefore := ParseLineBreaks(Copy(false))
              Send +{Left}
              StrAfter := ParseLineBreaks(Copy(false))
              Send +{Right}
            }
            if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
              this.SelectParagraphUp(, true)
              StrAfter := ParseLineBreaks(Copy(false))
              if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
                Send +{Left}
                this.SelectParagraphUp(, true)
                StrAfter := ParseLineBreaks(Copy(false))
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
              Send % "+{Right " . right . "}"
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
                Send % "+{Left " . left . "}"
              }
            }
          } else {
            this.SelectParagraphUp(, true)
            DetectionStr := ParseLineBreaks(Copy(false))
            if (!DetectionStr) {  ; start of line
              Send {Left}
              this.SelectParagraphUp(, true)
              DetectionStr := ParseLineBreaks(Copy(false))
            }
            DetectionStr := StrReverse(DetectionStr)
            pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence - 1, true)
            Send % "{Right}{Left " . pos . "}"
          }
        } else if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := ParseLineBreaks(Copy(false))
            Send +{Right}
            StrAfter := ParseLineBreaks(Copy(false))
            Send +{Left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {  ; searching forward
            this.SelectParagraphDown(, true)
            StrAfter := ParseLineBreaks(Copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              Send +{Right}
              this.SelectParagraphDown(, true)
              StrAfter := ParseLineBreaks(Copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)
            pos := this.FindWordBoundary(DetectionStr, this.SearchOccurrence)
            if (pos)
              Send % "{Left}+{Right " . pos + StrLen(StrBefore) . "}"
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
              Send % "+{Right " . right . "}"
            }
          }
        } else {
          this.SelectParagraphDown(, true)
          DetectionStr := ParseLineBreaks(Copy(false))
          if (!DetectionStr) {
            Send {Right}
            this.SelectParagraphDown(, true)
            DetectionStr := ParseLineBreaks(Copy(false))
          } else if (IsWhitespaceOnly(DetectionStr)) {
            Send {Right 2}
            this.SelectParagraphDown(, true)
            DetectionStr := ParseLineBreaks(Copy(false))
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
          Send % "{Left}{Right " . right . "}"
        }
      } else if (key == "b") {
        if (this.shift == 1) {
          Send +^{Left}
        } else {
          Send ^{Left}
        }
      } else if (key == "f") {  ; find forward
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := ParseLineBreaks(Copy(false))
            Send +{Right}
            StrAfter := ParseLineBreaks(Copy(false))
            Send +{Left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {  ; searching forward
            Send +{End}
            StrAfter := ParseLineBreaks(Copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              Send +{Right}+{End}
              StrAfter := ParseLineBreaks(Copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            pos += StrLen(StrBefore)
            Send % "{Left}+{Right " . pos . "}"
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
              Send % "+{Right " . right . "}"
            }
          }
        } else {
          Send +{End}
          DetectionStr := ParseLineBreaks(Copy(false))
          if !DetectionStr {  ; end of line
            Send {Right}+{End}  ; to the next line
            DetectionStr := ParseLineBreaks(Copy(false))
          } else if (IsWhitespaceOnly(DetectionStr)) {
            Send {Right 2}+{End}  ; to the next line
            DetectionStr := ParseLineBreaks(Copy(false))
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
          Send % "{Left}{Right " . right . "}"
        }
      } else if (key == "t") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := ParseLineBreaks(Copy(false))
            Send +{Right}
            StrAfter := ParseLineBreaks(Copy(false))
            Send +{Left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {  ; searching forward
            Send +{End}
            StrAfter := ParseLineBreaks(Copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              Send +{Right}+{End}
              StrAfter := ParseLineBreaks(Copy(false))
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
            Send % "{Left}+{Right " . right . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              right := pos - 2
              if ((pos == 2) || (pos == 1)) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence > 1) {
                  right := NextOccurrence - 2
                } else {
                  right := 0
                }
              }
              Send % "+{Right " . right . "}"
            }
          }
        } else {
          Send +{End}
          DetectionStr := ParseLineBreaks(Copy(false))
          if !DetectionStr {  ; end of line
            Send {Right}+{End}  ; to the next line
            DetectionStr := ParseLineBreaks(Copy(false))
          } else if (IsWhitespaceOnly(DetectionStr)) {
            Send {Right 2}+{End}  ; to the next line
            DetectionStr := ParseLineBreaks(Copy(false))
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
          Send % "{Left}{Right " . right . "}"
        }
      } else if (key == "+f") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := ParseLineBreaks(Copy(false))
            Send +{Left}
            StrAfter := ParseLineBreaks(Copy(false))
            Send +{Right}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
            Send +{Home}
            StrAfter := ParseLineBreaks(Copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              Send +{Left}+{Home}
              StrAfter := ParseLineBreaks(Copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos
            Send % "+{Right " . right . "}"
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
              Send % "+{Left " . left . "}"
            }
          }
        } else {
          Send +{Home}
          DetectionStr := ParseLineBreaks(Copy(false))
          if !DetectionStr {  ; start of line
            Send {Left}+{Home}
            DetectionStr := ParseLineBreaks(Copy(false))
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          Send % "{Right}{Left " . pos . "}"
        }
      } else if (key == "+t") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := ParseLineBreaks(Copy(false))
            Send +{Left}
            StrAfter := ParseLineBreaks(Copy(false))
            Send +{Right}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
            Send +{Home}
            StrAfter := ParseLineBreaks(Copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              Send +{Left}+{Home}
              StrAfter := ParseLineBreaks(Copy(false))
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
            Send % "+{Right " . right . "}"
          } else if StrLen(StrAfter) <= StrLen(StrBefore) {
            DetectionStr := StrReverse(StrBefore)
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              left := pos - 2
              if ((pos == 2) || (pos == 1)) {
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
              Send % "+{Left " . left . "}"
            }
          }
        } else {
          Send +{Home}
          DetectionStr := ParseLineBreaks(Copy(false))
          if (!DetectionStr) {  ; start of line
            Send {Left}+{Home}
            DetectionStr := ParseLineBreaks(Copy(false))
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
          Send % "{Right}{Left " . left . "}"
        }
      } else if (key == ")") {  ; like "f" but search for ". "
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := ParseLineBreaks(Copy(false))
            Send +{Right}
            StrAfter := ParseLineBreaks(Copy(false))
            Send +{Left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
            this.SelectParagraphDown(, true)
            StrAfter := ParseLineBreaks(Copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore) + 1) {  ; at end of paragraph
              Send +{Right}
              this.SelectParagraphDown(, true)
              StrAfter := ParseLineBreaks(Copy(false))
            }
            StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
            DetectionStr := SubStr(StrAfter, StartPos)
            pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
            if (pos) {
              right := pos + 1 + StrLen(StrBefore)
              if (StrLen(DetectionStr) == pos + 2)  ; found at end of paragraph
                right++
              Send % "{Left}+{Right " . right . "}"
            } else {
              Send +{Left}
            }
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {  ; search in selected text
            DetectionStr := ParseLineBreaks(Copy(false))
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
            Send % "+{Right " . right . "}"
          }
        } else {
          this.SelectParagraphDown(, true)
          DetectionStr := ParseLineBreaks(Copy(false))
          if (!DetectionStr || IsWhitespaceOnly(DetectionStr)) {  ; end of paragraph
            Send {Right}
            this.SelectParagraphDown(, true)  ; to the next line
            DetectionStr := ParseLineBreaks(Copy(false))
            if (!DetectionStr) {  ; still end of paragraph
              Send {Right}
              this.SelectParagraphDown(, true)  ; to the next line
              DetectionStr := ParseLineBreaks(Copy(false))
            }
          }
          pos := this.FindSentenceEnd(DetectionStr, this.SearchOccurrence)
          if (pos) {
            right := pos + 1
            if (StrLen(DetectionStr) == pos + 2)  ; found at end of paragraph
              right++
            Send % "{Left}{Right " . right . "}"
          } else {
            Send {Right}
          }
        }
      } else if (key == "(") {  ; like "+t"
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := ParseLineBreaks(Copy(false))
            Send +{Right}
            StrAfter := ParseLineBreaks(Copy(false))
            Send +{Left}
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
            Send % "+{Left " . left . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore) || !StrBefore) {
            this.SelectParagraphUp(, true)
            StrAfter := ParseLineBreaks(Copy(false))
            if (!StrAfter) {  ; start of line
              Send {Left}
              this.SelectParagraphUp(, true)
              StrAfter := ParseLineBreaks(Copy(false))
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
              Send % "+{Right " . right . "}"
          }
        } else {
          this.SelectParagraphUp(, true)
          DetectionStr := Copy(false)
          if (DetectionStr ~= "\r\n$") {  ; start of paragraph
            Send {Right}{Left}
            this.SelectParagraphUp(, true)
            DetectionStr := ParseLineBreaks(Copy(false))
          } else {
            DetectionStr := ParseLineBreaks(DetectionStr)
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
            Send {Left}
          } else {
            Send % "{Right}{Left " . left . "}"
          }
        }
      } else if (key == "s") {
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := ParseLineBreaks(Copy(false))
            Send +{Right}
            StrAfter := ParseLineBreaks(Copy(false))
            Send +{Left}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {  ; searching forward
            this.SelectParagraphDown(, true)
            StrAfter := ParseLineBreaks(Copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at end of line
              Send +{Right}
              this.SelectParagraphDown(, true)
              StrAfter := ParseLineBreaks(Copy(false))
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
            Send {LShift Up}{RShift Up}
            Send % "{Left}+{Right " . right . "}"
          } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
            DetectionStr := StrBefore
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            if (pos) {
              right := pos - 1
              if ((pos == 2) || (pos == 1)) {
                this.SearchOccurrence++
                NextOccurrence := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
                if (NextOccurrence > 1) {
                  right := NextOccurrence - 1
                } else {
                  right := 0
                }
              }
              Send % "+{Right " . right . "}"
            }
          }
        } else {
          this.SelectParagraphDown(, true)
          DetectionStr := ParseLineBreaks(Copy(false))
          if (!DetectionStr) {
            Send {Right}
            this.SelectParagraphDown(, true)
            DetectionStr := ParseLineBreaks(Copy(false))
          } else if (IsWhitespaceOnly(DetectionStr)) {
            Send {Right 2}
            this.SelectParagraphDown(, true)
            DetectionStr := ParseLineBreaks(Copy(false))
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
          Send % "{Left}{Right " . right . "}"
        }
      } else if (key == "+s") {
        this.FtsChar := StrReverse(this.FtsChar)
        if (this.shift == 1) {
          if (!this.NoSelection()) {  ; determine caret position
            StrBefore := ParseLineBreaks(Copy(false))
            Send +{Left}
            StrAfter := ParseLineBreaks(Copy(false))
            Send +{Right}
          }
          if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
            this.SelectParagraphUp(, true)
            StrAfter := ParseLineBreaks(Copy(false))
            if (StrLen(StrAfter) == StrLen(StrBefore)) {  ; caret at start of line
              Send +{Left}
              this.SelectParagraphUp(, true)
              StrAfter := ParseLineBreaks(Copy(false))
            }
            length := StrLen(StrAfter) - StrLen(StrBefore)
            DetectionStr := StrReverse(SubStr(StrAfter, 1, length))
            pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
            right := StrLen(DetectionStr) - pos - 1
            Send % "+{Right " . right . "}"
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
              Send % "+{Left " . left . "}"
            }
          }
        } else {
          this.SelectParagraphUp(, true)
          DetectionStr := ParseLineBreaks(Copy(false))
          if (!DetectionStr) {  ; start of line
            Send {Left}
            this.SelectParagraphUp(, true)
            DetectionStr := ParseLineBreaks(Copy(false))
          }
          DetectionStr := StrReverse(DetectionStr)
          pos := this.FindPos(DetectionStr, this.FtsChar, this.SearchOccurrence)
          pos := pos ? pos + 1 : 0
          Send % "{Right}{Left " . pos . "}"
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
          StrBefore := ParseLineBreaks(Copy(false))
          Send +{Right}
          StrAfter := ParseLineBreaks(Copy(false))
          Send +{Left}
        }
        if (!StrBefore || (StrLen(StrAfter) > StrLen(StrBefore))) {
          this.SelectParagraphDown(, true)
          StrAfter := ParseLineBreaks(Copy(false))
          if (StrLen(StrAfter) == StrLen(StrBefore) + 1) {  ; at end of paragraph
            Send +{Right}
            this.SelectParagraphDown(, true)
            StrAfter := ParseLineBreaks(Copy(false))
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
          Send % "+{Left " . left . "}"
        } else if (StrLen(StrAfter) <= StrLen(StrBefore)) {
          pos := InStr(StrBefore, UserInput, true)
          pos -= pos ? 1 : 0
          Send % "+{Right " . pos . "}"
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
          StrBefore := ParseLineBreaks(Copy(false))
          Send +{Right}
          StrAfter := ParseLineBreaks(Copy(false))
          Send +{Left}
        }
        if (StrLen(StrAfter) > StrLen(StrBefore)) {
          pos := InStr(StrReverse(StrBefore), StrReverse(UserInput), true)
          pos += pos ? StrLen(UserInput) - 2 : 0
          Send % "+{Left " . pos . "}"
        } else if (StrLen(StrAfter) <= StrLen(StrBefore)) || !StrBefore {
          this.SelectParagraphUp(, true)
          StrAfter := ParseLineBreaks(Copy(false))
          if (!StrAfter) {  ; start of line
            Send {Left}
            this.SelectParagraphUp(, true)
            StrAfter := ParseLineBreaks(Copy(false))
          }
          StartPos := StrLen(StrBefore) + 1  ; + 1 to make sure DetectionStr is what's selected after
          DetectionStr := SubStr(StrReverse(StrAfter), StartPos)
          pos := InStr(DetectionStr, StrReverse(UserInput), true,, this.SearchOccurrence)
          right := StrLen(DetectionStr) - pos - StrLen(UserInput) + 1
          Send % "+{Right " . right . "}"
        }
      } else if (key == "x") {
        if (this.Vim.IsNavigating()) {
          Send {Del}
        } else if (this.shift != 1) {
          Send +{Right}
        }
      } else if (key == "+x") {
        if (this.Vim.IsNavigating()) {
          Send {BS}
        } else if (this.shift != 1) {
          Send +{Left}
        }
      }
    }
    ; Up/Down 1 character
    if (key == "j") {
      if (SM.IsBrowsing()) {
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
        Send {Ctrl Up}{WheelDown}
      } else {
        SendMessage, 0x0115, 1, 0, % ControlGetFocus("A"), A  ; scroll down
      }
    } else if (key == "k") {
      if (SM.IsBrowsing()) {
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
        Send {Ctrl Up}{WheelUp}
      } else {
        SendMessage, 0x0115, 0, 0, % ControlGetFocus("A"), A  ; scroll up
      }
    ; Page Up/Down
    } else if (key == "^u") {
      if (SM.IsBrowsing()) {
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
      if (SM.IsBrowsing()) {
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
      Send {PgUp}
    } else if (key == "^f") {
      Send {PgDn}
    } else if (key == "g") {
      if (this.Vim.State.n > 0) {
        if (SM.IsBrowsing() && SM.DoesTextExist()) {
          Send ^t
          SM.WaitTextFocus()
        } else {
          this.HandleClickBtn()
        }
        Send % "^{Home}{Down " . this.Vim.State.n - 1 . "}"
        this.Vim.State.n := 0, this.HandleClickBtn()
      } else if (this.Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsBrowsing()) {
        if (ControlGet(,, "Internet Explorer_Server2", "A")) {
          SendMessage, 0x115, 6, 0, Internet Explorer_Server2, A  ; scroll to top
        } else if (ControlGet(,, "Internet Explorer_Server1", "A")) {
          SendMessage, 0x115, 6, 0, Internet Explorer_Server1, A  ; scroll to top
        } else {
          Send ^{Home}
        }
      } else {
        Send ^{Home}
      }
    } else if (key == "+g") {
        if (this.Vim.State.n > 0) {
          if (SM.IsBrowsing() && SM.DoesTextExist()) {
            SM.ClickTop()
            SM.WaitTextFocus()
          } else if (SM.IsEditingText()) {
            SM.ClickTop()
          } else {
            this.HandleClickBtn()
            Send ^{Home}
          }
          Send % "{Down " . this.Vim.State.n - 1 . "}"
          this.Vim.State.n := 0, this.HandleClickBtn()
        } else if (this.Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsBrowsing()) {
          if (ControlGet(,, "Internet Explorer_Server2", "A")) {
            SendMessage, 0x115, 7, 0, Internet Explorer_Server2, A  ; scroll to bottom
          } else if (ControlGet(,, "Internet Explorer_Server1", "A")) {
            SendMessage, 0x115, 7, 0, Internet Explorer_Server1, A  ; scroll to bottom
          } else {
            Send ^{End}
          }
        } else {
          if (this.shift == 1) {
            Send ^+{End}
            if (!this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
              Send +{Home}
          } else {
            Send ^{End}
            if (SM.IsNavigatingPlan() || !this.Vim.IsNavigating())
              Send {Home}
          }
          if (SM.IsEditingHTML()) {
            Send ^+{Up}  ; if there are references this would select (or deselect in visual mode) them all
            if (this.shift == 1)
              Send +{Down}  ; go down one line, if there are references this would include the #SuperMemo Reference
            if (IfContains(Copy(false), "#SuperMemo Reference:")) {
              if (this.shift == 1) {
                Send +{Up 4}  ; select until start of last line
              } else {
                Send {Up 3}  ; go to start of last line
              }
              if (this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
                Send +{End}
            } else {
              if (this.shift == 1) {
                Send ^+{End}
                if (!this.Vim.State.StrIsInCurrentVimMode("VisualLine"))
                  Send +{Home}
              } else {
                Send ^{End}{Home}
              }
            }
          }
        }
    } else if (key == "{") {
      if ((this.Vim.State.n > 0) && WinActive("ahk_class TElWind") && !Repeat && SM.DoesTextExist()) {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
        KeyWait Shift
        if (!SM.IsEditingText()) {
          Send ^t
          SM.WaitTextFocus()
        }
        Send ^{Home}
        this.ParagraphDown(this.Vim.State.GetN() - 1)
      } else if (this.shift == 1) {
        this.SelectParagraphUp()
      } else {
        this.ParagraphUp()
      }
    } else if (key == "}") {
      if ((this.Vim.State.n > 0) && WinActive("ahk_class TElWind") && !Repeat && SM.DoesTextExist()) {  ; this can only be invoked by Vim.Move.Move and not Vim.Move.Repeat
        KeyWait Shift
        SM.ClickTop()
        SM.WaitTextFocus()
        this.ParagraphDown(this.Vim.State.GetN() - 1)
      } else if (this.shift == 1) {
        this.SelectParagraphDown()
      } else {
        this.ParagraphDown()
      }
    } else if (key == "gn") {
      global VimLastSearch
      global CapsState := CtrlState := AltState := ""
      global ShiftState := true  ; makes SMSearch stays in visual mode
      if (!n := this.Vim.State.IsCurrentVimMode("Vim_Normal"))
        PrevMode := this.Vim.State.Mode
      Gosub SMSearch
      if (!n)
        this.Vim.State.SetMode(PrevMode)
    }

    if (!Repeat && Final)
      this.MoveFinalize()
  }

  Repeat(key:="", Init:=true, Final:=true) {
    if (Init)
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
    if (Final)
      this.MoveFinalize()
  }

  YDCMove() {
    this.Vim.State.LineCopy := 1
    this.Zero()
    Send {Shift Down}
    if (this.Vim.State.n == 0)
      this.Vim.State.n := 1
    this.Down(this.Vim.State.n - 1)
    if (WinActive("ahk_group VimLBSelectGroup") && (this.Vim.State.n == 2))
      Send {Right}
    Send {End}
    if (this.IsReplace())
      Send {Left}
    if (!WinActive("ahk_group VimLBSelectGroup") && !WinActive("ahk_group VimShiftDownLindEnd")) {
      this.Move("l")
    } else {
      this.Move("")
    }
    this.LastLineCopy := true
  }

  Inner(key:="") {
    global WinClip, SM
    RestoreClip := Vim.State.StrIsInCurrentVimMode("Vim_ydc") ? false : true
    KeyWait Shift
    if (key == "w") {
      Send ^{Right}^{Left}
      this.Move("e",,, false), Final := true
    } else if (key == "s") {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      Send +{Right}
      if (Copy(false) ~= "`n") {
        Send {Left}
      } else {
        Send {Right}
      }
      this.Move("(",,, false, true, false)
      this.Move(")",,, false,, false)
      if (!this.v)  ; end of paragraph
        this.FindSentenceEnd(ParseLineBreaks(Copy(false)))
      n := StrLen(this.v)
      if (RestoreClip)
        Clipboard := ClipSaved
      if (n)
        Send % "+{Left " . n . "}"
      Final := true
    } else if (key == "p") {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      this.ParagraphDown()
      this.ParagraphUp()
      this.SelectParagraphDown()
      Selection := Copy(false)
      if (SM.IsEditingHTML()) {
        Send +{Left}
        if (IfContains(Selection, this.hr))
          Send +{Left}
        Selection := ""
      }
      DetectionStr := ParseLineBreaks(Selection ? Selection : Copy(false))
      DetectionStr := StrReverse(DetectionStr)
      RegExMatch(DetectionStr, "^(\s+)?((\]\d+\[)+)?(\.|。)", v), n := StrLen(v)
      if (RestoreClip)
        Clipboard := ClipSaved
      if (n) {
        Send % "+{Left " . n . "}"
      } else {
        Send +{Left}+{Right}  ; refresh caret
      }
      Final := true
    } else if (IfIn(key, this.InnerKeys)) {
      this.RegForDot(key)
      if (RestoreClip)
        ClipSaved := ClipboardAll
      Send {LShift Up}{RShift Up}
      Send +{Right}
      if (Copy(false) ~= "`n") {
        Send {Left}
      } else {
        Send {Right}
      }
      this.SelectParagraphUp(, true)
      DetectionStr := ParseLineBreaks(Copy(false))
      if (!DetectionStr) {  ; start of paragraph
        Send {Left}
        this.SelectParagraphUp(, true)
        DetectionStr := ParseLineBreaks(Copy(false))
      }
      DetectionStr := StrReverse(DetectionStr)
      key := this.RevSurrKey(key)
      if (AltKey := this.GetAltKey(key)) {
        pos := RegExMatch(DetectionStr, AltKey)
      } else {
        pos := InStr(DetectionStr, key)
      }
      left := pos ? pos - 1 : 0
      Send % "{Right}{Left " . left . "}"
      if (!pos) {
        Send {Left}
      } else {
        this.SelectParagraphDown(, true)
        DetectionStr := ParseLineBreaks(Copy(false))
        if (!DetectionStr) {  ; end of paragraph
          Send {Right}  ; to the next paragraph
          this.SelectParagraphDown(, true)
          DetectionStr := ParseLineBreaks(Copy(false))
        } else if (IsWhitespaceOnly(DetectionStr)) {
          Send {Right 2}  ; to the next paragraph
          this.SelectParagraphDown(, true)
          DetectionStr := ParseLineBreaks(Copy(false))
        }
        key := this.RevSurrKey(key, 2)
        if (AltKey := this.GetAltKey(key)) {
          pos := RegExMatch(DetectionStr, AltKey)
        } else {
          pos := InStr(DetectionStr, key)
        }
        pos := pos ? pos - 1 : 0
        Send % "{Left}+{Right " . pos . "}"
      }
      if (RestoreClip)
        Clipboard := ClipSaved
      Final := true
    }
    this.RegForDot(key), this.LastInOrOut := "Inner"
    if (Final)
      this.MoveFinalize()
  }

  Outer(key:="") {
    global WinClip
    RestoreClip := Vim.State.StrIsInCurrentVimMode("Vim_ydc") ? false : true
    KeyWait Shift
    if (key == "w") {
      Send ^{Right}^{Left}^+{Right}
      Final := true
    } else if (key == "s") {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      Send +{Right}
      if (Copy(false) ~= "`n") {
        Send {Left}
      } else {
        Send {Right}
      }
      this.Move("(",,, false, true, false)
      this.Move(")",,, false,, false)
      if (RestoreClip)
        Clipboard := ClipSaved
      if (this.IsReplace()) {
        if (this.v)
          n := StrLen(RegExReplace(this.v, "\.\K(\[.*?\])+")) - 1
        Send % "+{Left " . n . "}"  ; so that `dap` would delete an entire paragraph, whereas `cap` would empty the paragraph
      }
      Final := true
    } else if (key == "p") {
      this.Vim.State.LineCopy := 1
      this.ParagraphDown()
      this.ParagraphUp()
      this.SelectParagraphDown()
      if (this.IsReplace())
        Send +{Left}  ; so that `dap` would delete an entire paragraph, whereas `cap` would empty the paragraph
      Final := true
    } else if (IfIn(key, this.InnerKeys)) {
      if (RestoreClip)
        ClipSaved := ClipboardAll
      Send {LShift Up}{RShift Up}
      Send +{Right}
      if (Copy(false) ~= "`n") {
        Send {Left}
      } else {
        Send {Right}
      }
      this.SelectParagraphUp(, true)
      DetectionStr := ParseLineBreaks(Copy(false))
      if (!DetectionStr) {  ; start of paragraph
        Send {Left}
        this.SelectParagraphUp(, true)
        DetectionStr := ParseLineBreaks(Copy(false))
      }
      DetectionStr := StrReverse(DetectionStr)
      key := this.RevSurrKey(key)
      if (AltKey := this.GetAltKey(key)) {
        pos := RegExMatch(DetectionStr, AltKey)
        key := SubStr(DetectionStr, pos, 1)
      } else {
        pos := InStr(DetectionStr, key)
      }
      Send % "{Right}{Left " . pos . "}"
      if (pos) {
        this.SelectParagraphDown(, true)
        DetectionStr := ParseLineBreaks(Copy(false))
        if (!DetectionStr) {  ; end of paragraph
          Send {Right}  ; to the next paragraph
          this.SelectParagraphDown(, true)
          DetectionStr := ParseLineBreaks(Copy(false))
        } else if (IsWhitespaceOnly(DetectionStr)) {
          Send {Right 2}  ; to the next paragraph
          this.SelectParagraphDown(, true)
          DetectionStr := ParseLineBreaks(Copy(false))
        }
        key := this.RevSurrKey(key, 2)
        pos := InStr(DetectionStr, key,, 2)
        Send % "{Left}+{Right " . pos . "}"
      }
      if (RestoreClip)
        Clipboard := ClipSaved
      Final := true
    }
    this.RegForDot(key), this.LastInOrOut := "Outer"
    if (Final)
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

  FindPos(DetectionStr, Text, Occurrence:=1) {
    if (StrLen(Text) == 2) {  ; vim-sneak search
      AltText1 := this.GetAltKey(Text1 := SubStr(Text, 1, 1))
      AltText2 := this.GetAltKey(Text2 := SubStr(Text, 2, 1))
      if (regex := (AltText1 || AltText2)) {
        AltText1 := AltText1 ? AltText1 : text1
        AltText2 := AltText2 ? AltText2 : text2
        AltText1 := (IsRegExChar(AltText1)) ? "\" . AltText1 : AltText1
        AltText2 := (IsRegExChar(AltText2)) ? "\" . AltText2 : AltText2
        AltText := "(" . AltText1 . ")(" . AltText2 . ")"
      }
    }
    if (regex || (AltText := this.GetAltKey(Text))) {
      pos := RegExMatch(DetectionStr, "s)((" . AltText . ").*?){" . Occurrence - 1 . "}\K(" . AltText . ")")
    } else {
      pos := InStr(DetectionStr, Text, true,, Occurrence)
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
      pos := RegExMatch(DetectionStr, "s)((\.|!|\?)((\[.*?\])+\s|\d+​\s|[^" . this.WordBoundChars . ",.\]]+).*?){" . Occurrence - 1 . "}\K(\.|!|\?)((\[.*?\])+\s|\d+​\s|[^" . this.WordBoundChars . ",.\]]+)", v)
      if (pos)
        pos += StrLen(v) - 2
      this.v := v
      this.DetectionStr := DetectionStr
    } else {
      pos := RegExMatch(DetectionStr, "s)((\d+​\s|\s(\].*?\[)+|[^" . this.WordBoundChars . ",.\[]+)(\.|!|\?).*?){" . Occurrence - 1 . "}\K(\d+​\s|\s(\].*?\[)+|[^" . this.WordBoundChars . ",.\[]+)(\.|!|\?)")
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
    ; This button is not clickable in sm using UIA/ACC for some reason
    if (WinActive("ahk_class TContents")) {
      ClickDPIAdjusted(295, 50)
    } else if (WinActive("ahk_class TBrowser")) {
      ClickDPIAdjusted(660, 46)  ; btn pos changed in sm19.05
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
