#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Grading
; Inspired by MasterHowToLearn's SuperMemoVim
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsGrading())
; Conflict with focusing to answer
; a::
s::
d::
f::
g::
  if (A_ThisHotkey == "s") {
    send 2
  } else if (A_ThisHotkey == "d") {
    send 3
  } else if (A_ThisHotkey == "f") {
    send 4
  } else if (A_ThisHotkey == "g") {
    send 5
  }
  ControlTextWait("TBitBtn3", "Next repetition", "A")
  ControlSend, TBitBtn3, {enter}, A
  Vim.SM.EnterInsertIfSpelling()
return
