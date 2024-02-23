#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && Vim.SM.IsBrowsing())
; For Learn button
~Enter::  ; enter up doesn't work
~space up::
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would add a {Left}
  if (!Vim.SM.PlayIfOnlineColl(, 3000))
    Vim.SM.EnterInsertIfSpelling()
Return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))  ; SuperMemo element window
~f4::  ; open tasklist
~!x::  ; extract
~^+a::  ; web import
#if (Vim.IsVimGroup() && WinActive("ahk_class TPlanDlg"))  ; SuperMemo Plan window
~^s::  ; save
~^+a::  ; archive current plan
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would move the caret in some instances
return

#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))  ; SuperMemo element window
^f2::
  Vim.SM.PostMsg((WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") ? 179 : 181)  ; go neural
  Vim.State.SetMode("Vim_Normal"), Vim.SM.PlayIfOnlineColl(, 500)
return

!z::Vim.SM.Cloze(), Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && !Vim.State.StrIsInCurrentVimMode("Visual,Command") && WinActive("ahk_class TElWind"))  ; SuperMemo element window
^l::Vim.SM.Learn(,, true), Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert") && Vim.SM.IsEditingHTML())  ; SuperMemo element window
^p::Vim.SM.Plan(), Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && WinActive("ahk_class TContents"))
~Enter::Vim.State.SetNormal()

#if (Vim.IsVimGroup() && Vim.IsExceptionWnd())
~Enter::Vim.State.SetMode("Vim_Normal")
