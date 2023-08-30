#if (Vim.IsVimGroup() && Vim.SM.IsBrowsing())
; For Learn button
~enter::  ; enter up doesn't work
~space up::
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would add a {left}
  if (!Vim.SM.PlayIfCertainColl("", 3000))
    Vim.SM.EnterInsertIfSpelling()
Return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))  ; SuperMemo element window
~f4::  ; open tasklist
~!x::  ; extract
~!z::  ; cloze
~^+a::  ; web import
#if (Vim.IsVimGroup() && Vim.SM.IsBrowsing())  ; SuperMemo element window
; ~^+f6::  ; open source in Notepad
#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))  ; SuperMemo Plan window
~^s::  ; save
~^+a::  ; archive current plan
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would move the caret in some instances
return

#if (Vim.IsVimGroup() && !Vim.State.StrIsInCurrentVimMode("Visual,Command") && Vim.SM.IsEditingHTML())  ; SuperMemo element window
^l::Vim.SM.Learn(, true), Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert") && Vim.SM.IsEditingHTML())  ; SuperMemo element window
^p::Vim.SM.Plan(), Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && WinActive("ahk_class TContents"))
~enter::Vim.State.SetNormal()