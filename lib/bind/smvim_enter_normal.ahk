#if (Vim.IsVimGroup() && !WinActive("ahk_class TPlanDlg") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
; in Plan window pressing enter simply goes to the next field; no need to go back to normal
; in element window pressing enter to learn goes to normal
~enter::
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
~space up::  ; for Learn button
  Vim.SM.PlayIfCertainCollection()
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would add a {left}
  Vim.SM.EnterInsertIfSpelling()
Return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))  ; SuperMemo element window
~f4::  ; open tasklist
~!x::  ; extract
~!z::  ; cloze
~^+a::  ; web import
#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))  ; SuperMemo Plan window
~^s::  ; save
~^+a::  ; archive current plan
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would move the caret in some instances
return

#if (Vim.IsVimGroup() && !Vim.State.StrIsInCurrentVimMode("Visual") && !Vim.State.StrIsInCurrentVimMode("Command") && Vim.SM.IsEditingHTML())  ; SuperMemo element window
^l::  ; learn
  Vim.SM.PostMsg(180)  ; learn
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.EnterInsertIfSpelling()
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert") && Vim.SM.IsEditingHTML())  ; SuperMemo element window
^p::
  Vim.SM.PostMsg(243)  ; plan
  Vim.State.SetMode("Vim_Normal")
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TContents"))
~enter::Vim.State.SetNormal()