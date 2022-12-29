#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("ydc_y") && Vim.state.surround && !Vim.State.StrIsInCurrentVimMode("Inner") && !Vim.State.StrIsInCurrentVimMode("Outer") && !Vim.State.g)
s::Vim.Move.YDCMove()
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_ydc") && !Vim.State.StrIsInCurrentVimMode("Inner") && !Vim.State.StrIsInCurrentVimMode("Outer") && !Vim.State.g)
s::Vim.State.SetMode("",, -1,,, 1)

#if (Vim.IsVimGroup()
  && (Vim.State.StrIsInCurrentVimMode("Visual") || Vim.State.StrIsInCurrentVimMode("Vim_ydc"))
  && !Vim.State.StrIsInCurrentVimMode("Inner")
  && !Vim.State.StrIsInCurrentVimMode("Outer")
  && (Vim.State.surround || ChangeEntered))
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
  ClipSaved := ClipboardAll
  KeyWait shift
  if (!ChangeEntered && (Vim.State.StrIsInCurrentVimMode("Visual") || Vim.State.StrIsInCurrentVimMode("ydc_y"))) {
    selection := copy(false)
    if (!selection)
      goto RestoreClipReturn
    SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
    send {left}
    key := Vim.Move.RevSurrKey(A_ThisHotkey)
    send % "{text}" . key
    send % "{right " . SelectionLen . "}"
    key := Vim.Move.RevSurrKey(A_ThisHotkey, 2)
    send % "{text}" . key
  } else if (ChangeEntered || ((c := Vim.State.StrIsInCurrentVimMode("ydc_c")) || Vim.State.StrIsInCurrentVimMode("ydc_d"))) {
    if (!ChangeEntered) {
      Vim.State.SetMode("Vim_Visual")
      Vim.Move.Inner(A_ThisHotkey)
      selection := copy(false)
      if (!selection)
        goto RestoreClipReturn
      SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
      if (c) {
        ChangeEntered := true
        return
      }
    }
    ChangeEntered := false
    send {left}{bs}
    if (c) {
      key := Vim.Move.RevSurrKey(A_ThisHotkey)
      send % "{text}" . key
    }
    send % "{right " . SelectionLen . "}"
    send {del}
    if (c) {
      key := Vim.Move.RevSurrKey(A_ThisHotkey, 2)
      send % "{text}" . key
    }
  }
  Vim.State.SetMode("Vim_Normal")
  Clipboard := ClipSaved
return