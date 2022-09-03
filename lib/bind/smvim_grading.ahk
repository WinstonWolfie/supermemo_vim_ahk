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
  StartTime := A_TickCount
  Loop {
    if (ControlGetText("TBitBtn3") == "Next repetition") {
      ControlSend, TBitBtn3, {enter}
    } else if (A_TickCount - StartTime > 100) {  ; timeout after 100ms
      return
    }
  }
  Vim.SM.EnterInsertIfSpelling()
return