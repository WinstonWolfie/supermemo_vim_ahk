; making sure grading works (in case VimDisableUnused > 1)
#If Vim.IsVimGroup() && IsSMGrading()
; cannot use ~ here to send the key itself
0::
1::
2::
3::
4::
5::
	send % A_ThisHotkey
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX and (Vim.Conf["VimDisableUnused"]["val"] == 2)
a::
b::
c::
d::
e::
; f:: ; find
; g:: ; g state
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
; +g::
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
; 0:: ; repeat
; 1::
; 2::
; 3::
; 4::
; 5::
; 6::
; 7::
; 8::
; 9::
`::
~::
!::
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
\::
|::
; ::: ; command mode
; `;::
'::
"::
,::
<::
.::
>::
Space::
Return

#If Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !A_CaretX and (Vim.Conf["VimDisableUnused"]["val"] == 3)
*a::
*b::
*c::
*d::
*e::
; *f::
; *g::
*h::
*i::
*j::
*k::
*l::
*m::
*n::
*o::
*p::
*q::
*r::
*s::
*t::
*u::
*v::
*w::
*x::
*y::
*z::
; 0::
; 1::
; 2::
; 3::
; 4::
; 5::
; 6::
; 7::
; 8::
; 9::
`::
~::
!::
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
\::
|::
; :::
; `;::
'::
"::
,::
<::
.::
>::
Space::
Return

#If
