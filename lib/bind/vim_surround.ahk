#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("ydc_y") && Vim.state.surround && !Vim.State.StrIsInCurrentVimMode("Inner") && !Vim.State.StrIsInCurrentVimMode("Outer") && !Vim.State.g)
s::Vim.Move.YDCMove()
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_ydc") && !Vim.State.StrIsInCurrentVimMode("Inner") && !Vim.State.StrIsInCurrentVimMode("Outer") && !Vim.State.g)
s::
  Vim.State.SetMode("",, -1,,, 1)
  Vim.Move.LastMode := Vim.State.Mode
return

#if (Vim.IsVimGroup()
  && (Vim.State.StrIsInCurrentVimMode("Visual") || Vim.State.StrIsInCurrentVimMode("Vim_ydc"))
  && !Vim.State.StrIsInCurrentVimMode("Inner")
  && !Vim.State.StrIsInCurrentVimMode("Outer")
  && (Vim.State.surround || ChangeEntered))
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
  ClipSaved := ClipboardAll
  KeyWait shift
  CurrKey := (A_ThisLabel == "Surround") ? Vim.Move.LastSurroundKey : A_ThisHotkey
  if (!ChangeEntered && (Vim.State.StrIsInCurrentVimMode("Visual") || Vim.State.StrIsInCurrentVimMode("ydc_y"))) {
    if (!selection := copy(false))
      goto RestoreClipReturn
    SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
    send {left}
    key := Vim.Move.RevSurrKey(CurrKey)
    send % "{text}" . key
    send % "{right " . SelectionLen . "}"
    key := Vim.Move.RevSurrKey(CurrKey, 2)
    send % "{text}" . key
  } else if (ChangeEntered || ((c := Vim.State.StrIsInCurrentVimMode("ydc_c")) || Vim.State.StrIsInCurrentVimMode("ydc_d"))) {
    if (!ChangeEntered) {
      Vim.State.SetMode("Vim_Visual")
      Vim.Move.Inner(CurrKey)
      if (!selection := copy(false))
        goto RestoreClipReturn
      SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
      if (c) {
        ChangeEntered := true
        return
      }
    }
    ChangeEntered := false
    send {left}{bs}
    if (c)
      send % "{text}" . Vim.Move.RevSurrKey(CurrKey)
    send % "{right " . SelectionLen . "}"
    send {del}
    if (c)
      send % "{text}" . Vim.Move.RevSurrKey(CurrKey, 2)
  }
  Vim.Move.LastSurround := true, Vim.Move.LastSurroundKey := CurrKey
  Vim.State.SetMode("Vim_Normal")
  Clipboard := ClipSaved
return