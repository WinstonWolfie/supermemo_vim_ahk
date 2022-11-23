; making sure grading works (in case VimDisableUnused > 1)
#if (Vim.IsVimGroup() && Vim.SM.IsGrading())
; cannot use ~ here to send the key itself
0::
1::
2::
3::
4::
5::
  send % A_ThisHotkey
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsBrowsing() && !Vim.State.g && true)  ; true is needed here for not duplicating hotkeys
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
; Space::
  send % "{" . A_ThisHotkey . "}"
Return

~^d::  ; dismiss; vim scroll down
~^j::  ; change interval; vim join lines
~^f::  ; find; vim page down
~^v::  ; paste image; vim visual block
~^r::  ; replace; vim redo
~^+p::  ; element parameter; SMVim paste without format
~^p::  ; open Plan; SMVim go right and paste without format
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TBrowser"))
~^l::
Return

#if
