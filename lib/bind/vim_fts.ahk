#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Vim_")) && Vim.State.fts
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
  CurrentHotkey := A_ThisHotkey
  if (CurrentHotkey = "space")
    CurrentHotkey := " "
  if (StrLen(CurrentHotkey) > 1) {
    if (InStr(CurrentHotkey, "+")) {
      CurrentHotkey := StrReplace(CurrentHotkey, "+")
      StringUpper, CurrentHotkey, CurrentHotkey
    }
    if (InStr(CurrentHotkey, "~"))
      CurrentHotkey := StrReplace(CurrentHotkey, "~")
  }
  if (InStr(Vim.State.fts, "s")) {
    if (!Vim.State.fts_char) {
      Vim.State.fts_char := CurrentHotkey
      Return
    } else {
      Vim.State.last_fts_char := Vim.State.fts_char .= CurrentHotkey
    }
  } else {
    Vim.State.last_fts_char := Vim.State.fts_char := CurrentHotkey
  }
  Vim.State.last_fts := Vim.State.fts
  Vim.Move.Move(Vim.State.fts)
Return

#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Vim_"))
f::Vim.State.SetMode("",, -1,, "f")
+f::Vim.State.SetMode("",, -1,, "+f")
t::Vim.State.SetMode("",, -1,, "t")
+t::Vim.State.SetMode("",, -1,, "+t")
s::Vim.State.SetMode("",, -1,, "s")
+s::Vim.State.SetMode("",, -1,, "+s")
`;::
  Vim.State.fts_char := Vim.State.last_fts_char
  Vim.Move.Move(Vim.State.last_fts)
Return

,::
  Vim.State.fts_char := Vim.State.last_fts_char
  if InStr(Vim.State.last_fts, "+") {
    fts_reversed := StrReplace(Vim.State.last_fts, "+")
  } else {
    fts_reversed := "+" . Vim.State.last_ft
  }
  Vim.Move.Move(fts_reversed)
Return