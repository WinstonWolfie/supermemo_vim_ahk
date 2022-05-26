; Grading
; Inspired by MasterHowToLearn's SuperMemoVim
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsGrading()
; Conflict with focusing to answer
; a::
  ; send 1
  ; sleep 40
  ; send {space}  ; next item
  ; Vim.SM.EnterInsertIfSpelling()
; return  

s::
  send 2
  sleep 40
  send {space}  ; next item
  Vim.SM.EnterInsertIfSpelling()
return

d::
  send 3
  sleep 40
  send {space}  ; next item
  Vim.SM.EnterInsertIfSpelling()
return

f::
  send 4
  sleep 40
  send {space}  ; next item
  Vim.SM.EnterInsertIfSpelling()
return

g::
  send 5
  sleep 40
  send {space}  ; next item
  Vim.SM.EnterInsertIfSpelling()
return