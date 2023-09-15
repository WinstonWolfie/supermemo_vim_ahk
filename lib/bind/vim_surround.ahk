#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("ydc_y") && Vim.State.surround && !Vim.State.StrIsInCurrentVimMode("Inner,Outer") && !Vim.State.g)
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
    CurrKey := ")"
  } else if (CurrKey == "+b") {
    CurrKey := "}"
  } else if (CurrKey == "t") {
    CurrKey := "<"
  }
  if (!Vim.State.SurroundChangeEntered && Vim.State.StrIsInCurrentVimMode("Visual,ydc_y")) {
    if (!selection := Copy(false)) {
      ToolTip("Text not found.")
      Goto RestoreClipReturn
    }
    SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
    send {left}
    if (!VimSurround(CurrKey, SelectionLen,, true))
      return
  } else if (Vim.State.SurroundChangeEntered || ((c := Vim.State.StrIsInCurrentVimMode("ydc_c")) || Vim.State.StrIsInCurrentVimMode("ydc_d"))) {
    if (!Vim.State.SurroundChangeEntered) {
      Vim.State.SetMode("Vim_Visual")
      Vim.Move.Inner(CurrKey)
      if (!selection := Copy(false))
        Goto RestoreClipReturn
      SelectionLen := StrLen(Vim.ParseLineBreaks(selection))
      if (c) {
        Vim.State.SurroundChangeEntered := true
        return
      }
    }
    send {left}
    if (!VimSurround(CurrKey, SelectionLen, true, c))
      return
  }
  Vim.Move.LastSurround := true, Vim.Move.LastSurroundKey := CurrKey
  Vim.State.SetMode("Vim_Normal"), Clipboard := ClipSaved
return

VimSurround(CurrKey, SelectionLen, d:=false, c:=false) {
  global Vim
  tag := (CurrKey == "<") ? InputBox("vim-surround", "Enter tag") : ""
  if ((CurrKey == "<") && (!tag || ErrorLevel))
    return
  if (d)
    send {bs}
  if (tag && c) {
    send % "{text}<" . tag . ">"
  } else if (c) {
    send % "{text}" . key := Vim.Move.RevSurrKey(CurrKey)
    if (s := IfIn(CurrKey, "(,[,{"))
      send {space}
  }
  send % "{right " . SelectionLen . "}"
  if (d)
    send {del}
  if (tag && c) {
    send % "{text}</" . tag . ">"
  } else if (c) {
    key := Vim.Move.RevSurrKey(CurrKey, 2)
    if (s)
      send {space}
    send % "{text}" . key
  }
  return true
}
