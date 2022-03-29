; Grading
; Inspired by MasterHowToLearn's SuperMemoVim
#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsGrading()
a::
    send 1
    sleep 40
    send {space}  ; next item
return  

s::
  send 2
  sleep 40
  send {space}  ; next item
return

d::
  send 3
  sleep 40
  send {space}  ; next item
return

f::
    send 4
    sleep 40
    send {space}  ; next item
return

g::
    send 5
    sleep 40
    send {space}  ; next item
return