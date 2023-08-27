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
  CurrHotkey := (A_ThisHotkey = "space") ? " " : A_ThisHotkey
  if (StrLen(CurrHotkey) > 1) {
    if (IfContains(CurrHotkey, "+"))
      CurrHotkey := StrUpper(StrReplace(CurrHotkey, "+"))
    CurrHotkey := StrReplace(CurrHotkey, "~")
  }
  if (IfContains(Vim.State.fts, "s")) {
    if (!Vim.State.FtsChar) {
      Vim.State.FtsChar := CurrHotkey
      return
    } else {
      Vim.State.LastFtsChar := Vim.State.FtsChar .= CurrHotkey
    }
  } else {
    Vim.State.LastFtsChar := Vim.State.FtsChar := CurrHotkey
  }
  Vim.Move.Move(Vim.State.LastFts := Vim.State.fts)
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.g)
s::Vim.State.SetMode("",, -1,, "s", -1)
+s::Vim.State.SetMode("",, -1,, "+s", -1)

#if (Vim.IsVimGroup()
  && Vim.State.StrIsInCurrentVimMode("Visual,Cloze")
  && !Vim.State.StrIsInCurrentVimMode("Inner,Outer")
  && !Vim.State.g)
s::Vim.State.SetMode("",, -1,, "s", -1)
!s::Vim.State.SetMode("",, -1,, "+s", -1)

#if (Vim.IsVimGroup()
  && Vim.State.StrIsInCurrentVimMode("Vim_")
  && !Vim.State.StrIsInCurrentVimMode("Visual,Cloze,Inner,Outer")
  && !Vim.State.IsCurrentVimMode("Vim_Normal")
  && !Vim.State.g)
z::Vim.State.SetMode("",, -1,, "s", -1, -1)
+z::Vim.State.SetMode("",, -1,, "+s", -1, -1)

#if (Vim.IsVimGroup()
  && Vim.State.StrIsInCurrentVimMode("Vim_")
  && !Vim.State.StrIsInCurrentVimMode("Inner,Outer")
  && !Vim.State.g
  && !(Vim.State.Surround && !Vim.State.StrIsInCurrentVimMode("ydc_y"))
  && !Vim.State.SurroundChangeEntered)
f::Vim.State.SetMode("",, -1,, "f", -1, -1)
+f::Vim.State.SetMode("",, -1,, "+f", -1, -1)
t::Vim.State.SetMode("",, -1,, "t", -1, -1)
+t::Vim.State.SetMode("",, -1,, "+t", -1, -1)
`;::Vim.State.FtsChar := Vim.State.LastFtsChar, Vim.Move.Move(Vim.State.LastFts)

,::
  Vim.State.FtsChar := Vim.State.LastFtsChar
  if (IfContains(Vim.State.LastFts, "+")) {
    FtsReversed := StrReplace(Vim.State.LastFts, "+")
  } else {
    FtsReversed := "+" . Vim.State.LastFts
  }
  Vim.Move.Move(FtsReversed)
Return