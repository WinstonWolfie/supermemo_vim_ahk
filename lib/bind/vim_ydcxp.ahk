#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.IsNavigating() && !Vim.SM.IsBrowsing())
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0,,, -1)
d::Vim.State.SetMode("Vim_ydc_d", 0, -1, 0,,, -1)
c::Vim.State.SetMode("Vim_ydc_c", 0, -1, 0,,, -1)
+y::
  Vim.State.SetMode("Vim_ydc_y", 0, 0, 1,,, -1)
  if (WinActive("ahk_group VimDoubleHomeGroup"))
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
  Vim.State.SetMode("Vim_ydc_d", 0, 0, 0,,, -1)
  if (!WinActive("ahk_group VimLBSelectGroup")) {
    Vim.Move.Move("$")
  } else {
    send {shift down}{End}{Left}
    Vim.Move.Move("")
  }
Return

+c::
  Vim.State.SetMode("Vim_ydc_c",0,0,0,,, -1)
  if (!WinActive("ahk_group VimLBSelectGroup")) {
    Vim.Move.Move("$")
  } else {
    send {shift down}{End}{Left}
    Vim.Move.Move("")
  }
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_y") && !Vim.IsNavigating() && !Vim.SM.IsBrowsing())
y::
  Vim.Move.YDCMove()
  send {Left}{Home}
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_d") && !Vim.IsNavigating() && !Vim.SM.IsBrowsing())
d::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_ydc_c") && !Vim.IsNavigating() && !Vim.SM.IsBrowsing())
c::Vim.Move.YDCMove()

; Paste
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_Normal") && !Vim.IsNavigating() && !Vim.SM.IsBrowsing())
^p::
p::
  if (IfContains(A_ThisHotkey, "^"))
    Clipboard := Clipboard
  if ((Vim.State.LineCopy == 1) && (Vim.Move.YdcClipSaved == Clipboard)) {
    send {End}{Enter}^v{Home}
  } else {
    send {Right}^v{Left}
  }
  KeyWait, p  ; To avoid repeat, somehow it calls <C-p>, print...
Return

^+p::
+p::
  if (IfContains(A_ThisHotkey, "^"))
    Clipboard := Clipboard
  if ((Vim.State.LineCopy == 1) && (Vim.Move.YdcClipSaved == Clipboard)) {
    send {Up}{End}{Enter}^v{Home}
  } else {
    send ^v
  }
  KeyWait, p
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && Vim.State.g && !Vim.IsNavigating() && !Vim.SM.IsBrowsing())
u::Vim.State.SetMode("Vim_gu", 0, -1, 0)
+u::Vim.State.SetMode("Vim_gU", 0, -1, 0)
~::Vim.State.SetMode("Vim_g~", 0, -1, 0)

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_gu") && !Vim.IsNavigating() && !Vim.SM.IsBrowsing())
u::Vim.Move.YDCMove()
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_gU") && !Vim.IsNavigating() && !Vim.SM.IsBrowsing())
+u::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_g~") && !Vim.IsNavigating() && !Vim.SM.IsBrowsing())
~::
  KeyWait Shift
  Vim.Move.YDCMove()
return