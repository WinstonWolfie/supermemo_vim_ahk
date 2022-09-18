; Editing text only
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText())
^q::Vim.State.SetMode("SMVim_ExtractStay", 0, -1, 0)
^z::Vim.State.SetMode("SMVim_ClozeStay", 0, -1, 0)
q::Vim.State.SetMode("SMVim_Extract", 0, -1, 0)
z::Vim.State.SetMode("SMVim_Cloze", 0, -1, 0)
+q::Vim.State.SetMode("SMVim_ExtractPriority", 0, -1, 0)
+z::
^+z::
  Vim.State.SetMode("SMVim_ClozeHinter", 0, -1, 0)
  ClozeHinterCtrlState := InStr(A_ThisHotkey, "^")
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText() && Vim.State.g)
!t::Vim.State.SetMode("SMVim_AltT", 0, -1, 0)
!q::Vim.State.SetMode("SMAltQ_Command", 0, -1, 0)

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_Extract") && Vim.SM.IsEditingText())
q::
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("SMVim_Cloze") && Vim.SM.IsEditingText())
z::
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMVim_AltT") && Vim.SM.IsEditingText())
!t::Vim.Move.YDCMove()
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("SMAltQ_Command") && Vim.SM.IsEditingText())
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
space::
  KeyWait shift
  Vim.Move.KeyAfterSMAltQ := A_ThisHotkey
  if (SMAltQYdcMove) {
    SMAltQYdcMove := false
    Vim.Move.YDCMove()
  } else {
    Vim.State.SetMode("SMVim_AltQ", 0, -1, 0)
  }
return