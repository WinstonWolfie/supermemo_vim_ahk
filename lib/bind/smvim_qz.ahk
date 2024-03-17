#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Editing text only
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingText())
q::Vim.State.SetMode("SMVim_Extract", 0, -1, 0,,, -1)
z::Vim.State.SetMode("SMVim_Cloze", 0, -1, 0,,, -1)
^q::Vim.State.SetMode("SMVim_ExtractStay", 0, -1, 0,,, -1)
^z::Vim.State.SetMode("SMVim_ClozeStay", 0, -1, 0,,, -1)
+q::Vim.State.SetMode("SMVim_ExtractPriority", 0, -1, 0,,, -1)
+z::
^+z::
  Vim.State.SetMode("SMVim_ClozeHinter", 0, -1, 0,,, -1)
  ClozeHinterCtrlState := IfContains(A_ThisLabel, "^")
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingText() && ((ClozeNoBracketCtrlState := GetKeyState("ctrl")) || true))
CapsLock & z::Vim.State.SetMode("SMVim_ClozeNoBracket", 0, -1, 0,,, -1)

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingHTML())
^h::Vim.State.SetMode("SMVim_ParseHTML", 0, -1, 0,,, -1)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMVim_ParseHTML") && SM.IsEditingHTML())
^h::Vim.Move.YDCMove()

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingText() && Vim.State.g)
!t::Vim.State.SetMode("SMVim_AltT", 0, -1, 0,,, -1)
!q::Vim.State.SetMode("SMAltQ_Command", 0, -1, 0,,, -1)

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMVim_AltT") && SM.IsEditingText())
!t::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_Extract") && SM.IsEditingText())
q::
^q::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_Cloze") && SM.IsEditingText())
z::
^z::
+z::
^+z::
  KeyWait Shift
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMVim_ClozeNoBracket") && SM.IsEditingText() && ((ClozeNoBracketCtrlState := GetKeyState("ctrl")) || true))
CapsLock & z::Vim.Move.YDCMove()

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMAltQ_Command") && SM.IsEditingText())
!q::SMAltQYdcMove := true

a::
b::
c::
d::
e::
f::
g::
h::
i::
j::
k::
l::
m::
n::
o::
p::
q::
r::
s::
t::
u::
v::
w::
x::
y::
z::
+a::
+b::
+c::
+d::
+e::
+f::
+g::
+h::
+i::
+j::
+k::
+l::
+m::
+n::
+o::
+p::
+q::
+r::
+s::
+t::
+u::
+v::
+w::
+x::
+y::
+z::
0::
1::
2::
3::
4::
5::
6::
7::
8::
9::
`::
~::
!::
?::
@::
#::
$::
%::
^::
&::
*::
(::
)::
-::
_::
=::
+::
[::
{::
]::
}::
/::
\::
|::
:::
`;::
'::
"::
,::
<::
.::
>::
Space::
  Vim.Move.KeyAfterSMAltQ := A_ThisLabel
  if (SMAltQYdcMove) {
    Vim.Move.YDCMove(), SMAltQYdcMove := false
  } else {
    Vim.State.SetMode("SMVim_AltQ", 0, -1, 0)
  }
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && SM.IsEditingHTML() && Vim.State.g)
!a::Goto SMParseHTMLGUI
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_GAltA") && SM.IsEditingHTML())
!a::Vim.Move.YDCMove()
