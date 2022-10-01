#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && Vim.State.fts)
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
  CurrHotkey := A_ThisHotkey
  if (CurrHotkey = "space")
    CurrHotkey := " "
  if (StrLen(CurrHotkey) > 1) {
    if (InStr(CurrHotkey, "+")) {
      CurrHotkey := StrReplace(CurrHotkey, "+")
      StringUpper, CurrHotkey, CurrHotkey
    }
    if (InStr(CurrHotkey, "~"))
      CurrHotkey := StrReplace(CurrHotkey, "~")
  }
  if (InStr(Vim.State.fts, "s")) {
    if (!Vim.State.FtsChar) {
      Vim.State.FtsChar := CurrHotkey
      Return
    } else {
      Vim.State.LastFtsChar := Vim.State.FtsChar .= CurrHotkey
    }
  } else {
    Vim.State.LastFtsChar := Vim.State.FtsChar := CurrHotkey
  }
  Vim.State.LastFts := Vim.State.fts
  Vim.Move.Move(Vim.State.fts)
Return

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && !Vim.State.g && !Vim.State.StrIsInCurrentVimMode("Inner"))
f::Vim.State.SetMode("",, -1,, "f")
+f::Vim.State.SetMode("",, -1,, "+f")
t::Vim.State.SetMode("",, -1,, "t")
+t::Vim.State.SetMode("",, -1,, "+t")
s::Vim.State.SetMode("",, -1,, "s")
+s::Vim.State.SetMode("",, -1,, "+s")
`;::
  Vim.State.FtsChar := Vim.State.LastFtsChar
  Vim.Move.Move(Vim.State.LastFts)
Return

,::
  Vim.State.FtsChar := Vim.State.LastFtsChar
  if InStr(Vim.State.LastFts, "+") {
    FtsReversed := StrReplace(Vim.State.LastFts, "+")
  } else {
    FtsReversed := "+" . Vim.State.LastFts
  }
  Vim.Move.Move(FtsReversed)
Return