#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && (Vim.State.StrIsInCurrentVimMode("Vim_") || Vim.State.IsCurrentVimMode("SMPlanDragging")) && !Vim.SM.IsGrading())
1::
2::
3::
4::
5::
6::
7::
8::
9::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && (Vim.State.n > 0) && !Vim.SM.IsGrading())
; 0 is used as {Home} for Vim.State.n=0
0::Vim.State.SetMode("", -1, Vim.State.n*10 + A_ThisLabel,,, -1, -1)
