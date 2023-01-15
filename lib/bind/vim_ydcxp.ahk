#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal"))
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0,,,-1)
d::Vim.State.SetMode("Vim_ydc_d", 0, -1, 0,,,-1)
c::Vim.State.SetMode("Vim_ydc_c", 0, -1, 0,,,-1)
+y::
  Vim.State.SetMode("Vim_ydc_y", 0, 0, 1)
  ; Sleep, 150  ; Need to wait (For variable change?)
  if WinActive("ahk_group VimDoubleHomeGroup")
    send {Home}
  send {Home}+{End}
  if (!WinActive("ahk_group VimLBSelectGroup")) {
    Vim.Move.Move("l")
  } else {
    Vim.Move.Move("")
  }
  send {Left}{Home}
Return

+d::
  Vim.State.SetMode("Vim_ydc_d", 0, 0, 0)
  if (!WinActive("ahk_group VimLBSelectGroup")) {
    Vim.Move.Move("$")
  } else {
    send {Shift Down}{End}{Left}
    Vim.Move.Move("")
  }
Return

+c::
  Vim.State.SetMode("Vim_ydc_c",0,0,0)
  if (!WinActive("ahk_group VimLBSelectGroup")) {
    Vim.Move.Move("$")
  } else {
    send {Shift Down}{End}{Left}
    Vim.Move.Move("")
  }
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_y"))
y::
  Vim.Move.YDCMove()
  send {Left}{Home}
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_d"))
d::Vim.Move.YDCMove()

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_c"))
c::Vim.Move.YDCMove()

; Paste
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_Normal") && !Vim.SM.IsNavigatingContentWindow())
^p::
p::
  ;i:=0
  ;;send {p Up}
  ;Loop {
  ;  if !GetKeyState("p", "P") {
  ;    break
  ;  }
  ;  if (Vim.State.LineCopy == 1) {
  ;    send {End}{Enter}^v{BS}{Home}
  ;  } else {
  ;    send {Right}
  ;    send ^v
  ;    ;Sleep, 1000
  ;    send ^{Left}
  ;  }
  ;  ;TrayTip,i,%i%,
  ;  if (i == 0) {
  ;    Sleep, 500
  ;  } else if (i > 100) {
  ;    Msgbox, , Vim Ahk, Stop at 100!!!
  ;    break
  ;  } else {
  ;    Sleep, 0
  ;  }
  ;  i+=1
  ;  break
  ;}
  if (IfContains(A_ThisHotkey, "^"))
    Clipboard := Clipboard
  if ((Vim.State.LineCopy == 1) && (Vim.Move.YdcClipSaved == Clipboard)) {
    ; if WinActive("ahk_group VimNoLBCopyGroup") {
    ;   send {End}{Enter}^v{Home}
    ; } else {
    ;   send {End}{Enter}^v{BS}{Home}
      send {End}{Enter}^v{Home}
    ; }
  } else {
    send {Right}
    send ^v
    ;Sleep, 1000
    send {Left}
    ;;send ^{Left}
  }
  KeyWait, p  ; To avoid repeat, somehow it calls <C-p>, print...
Return

^+p::
+p::
  if (IfContains(A_ThisHotkey, "^"))
    Clipboard := Clipboard
  if ((Vim.State.LineCopy == 1) && (Vim.Move.YdcClipSaved == Clipboard)) {
    ; send {Up}{End}{Enter}^v{BS}{Home}
    send {Up}{End}{Enter}^v{Home}
  } else {
    send ^v
    ;Send,^{Left}
  }
  KeyWait, p
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && Vim.State.g)
u::Vim.State.SetMode("Vim_gu", 0, -1, 0)
+u::Vim.State.SetMode("Vim_gU", 0, -1, 0)
~::Vim.State.SetMode("Vim_g~", 0, -1, 0)

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_gu"))
u::Vim.Move.YDCMove()
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_gU"))
+u::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_g~"))
~::
  KeyWait Shift
  Vim.Move.YDCMove()
return