#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("ydc_y") && Vim.state.surround && !Vim.State.StrIsInCurrentVimMode("Inner,Outer") && !Vim.State.g)
s::Vim.Move.YDCMove(), Vim.State.SurroundChangeEntered := false
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_ydc") && !Vim.State.StrIsInCurrentVimMode("Inner,Outer") && !Vim.State.g)
s::
  Vim.State.SetMode("",, -1,,, 1), Vim.Move.LastMode := Vim.State.Mode, Vim.State.SurroundChangeEntered := false
  Vim.Move.SurroundKeyEntered := Vim.State.StrIsInCurrentVimMode("ydc_d,ydc_c") ? true : false
return

#if (Vim.IsVimGroup()
  && Vim.State.StrIsInCurrentVimMode("Visual,Vim_ydc")
  && !Vim.State.StrIsInCurrentVimMode("Inner,Outer")
  && ((Vim.State.surround && Vim.Move.SurroundKeyEntered) || Vim.State.SurroundChangeEntered))
VimSurround:
(::
)::
{::
}::
[::
]::
<::
>::
"::
'::
`::
$::
*::
_::
b::
+b::
t::
  ClipSaved := ClipboardAll
  CurrKey := (A_ThisLabel == "Surround") ? Vim.Move.LastSurroundKey : A_ThisHotkey
  if (CurrKey == "b") {
    CurrKey := "("
  } else if (CurrKey == "+b") {
    CurrKey := "{"
  } else if (CurrKey == "t") {
    CurrKey := "<"
  }
  if (!Vim.State.SurroundChangeEntered && Vim.State.StrIsInCurrentVimMode("Visual,ydc_y")) {
    if (!selection := copy(false))
      goto RestoreClipReturn
    SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
    send {left}
    key := Vim.Move.RevSurrKey(CurrKey)
    send % "{text}" . key
    send % "{right " . SelectionLen . "}"
    key := Vim.Move.RevSurrKey(CurrKey, 2)
    send % "{text}" . key
  } else if (Vim.State.SurroundChangeEntered || ((c := Vim.State.StrIsInCurrentVimMode("ydc_c")) || Vim.State.StrIsInCurrentVimMode("ydc_d"))) {
    if (!Vim.State.SurroundChangeEntered) {
      Vim.State.SetMode("Vim_Visual")
      Vim.Move.Inner(CurrKey)
      if (!selection := copy(false))
        goto RestoreClipReturn
      SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
      if (c) {
        Vim.State.SurroundChangeEntered := true
        return
      }
    }
    send {left}{bs}
    if (c)
      send % "{text}" . Vim.Move.RevSurrKey(CurrKey)
    send % "{right " . SelectionLen . "}{del}"
    if (c)
      send % "{text}" . Vim.Move.RevSurrKey(CurrKey, 2)
  }
  Vim.Move.LastSurround := true, Vim.Move.LastSurroundKey := CurrKey
  Vim.State.SetMode("Vim_Normal"), Clipboard := ClipSaved
return