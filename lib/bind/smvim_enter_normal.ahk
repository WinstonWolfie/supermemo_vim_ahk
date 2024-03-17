#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && SM.IsBrowsing())
; For Learn button
~Enter::  ; enter up doesn't work
~Space Up::
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would add a {Left}
  if (!SM.PlayIfOnlineColl())
    SM.VimEnterInsertIfSpelling()
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
  SM.PostMsg((WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") ? 179 : 181)  ; go neural
  Vim.State.SetMode("Vim_Normal"), SM.PlayIfOnlineColl(, 500)
return

!z::SM.Cloze(), Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && !Vim.State.StrIsInCurrentVimMode("Visual,Command") && WinActive("ahk_class TElWind"))  ; SuperMemo element window
^l::
  Vim.State.SetNormal()  ; this line goes first bc EnterInsert:=true in Learn() below
  SM.Learn(,, true)
return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Insert") && SM.IsEditingHTML())  ; SuperMemo element window
^p::SM.Plan(), Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && WinActive("ahk_class TContents"))
~Enter::Vim.State.SetNormal()

#if (Vim.IsVimGroup() && Vim.IsExceptionWnd())
~Enter::Vim.State.SetMode("Vim_Normal")
