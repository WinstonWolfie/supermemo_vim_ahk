#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
f::Vim.State.SetMode("ft_f",, -1)
t::Vim.State.SetMode("ft_t",, -1)

#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Visual")) && !Vim.State.StrIsInCurrentVimMode("ft_")
f::Vim.State.SetMode("ft_fVisual",, -1)
t::Vim.State.SetMode("ft_tVisual",, -1)

ft:
#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("ft_f") || Vim.State.StrIsInCurrentVimMode("ft_t"))
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
	occurrence := 1
	if Vim.State.n
		occurrence := Vim.State.n
	if (repeat_ft = 1) {
		repeat_ft =
		finding_char := last_finding_char
		Vim.State.SetMode(last_ft)
	} else {
		finding_char := A_ThisHotkey
		if InStr(finding_char, "+") {
			finding_char := StrReplace(finding_char, "+")
			StringUpper, finding_char, finding_char
		}
		if InStr(finding_char, "~")
			finding_char := StrReplace(finding_char, "~")
	}
	if Vim.State.StrIsInCurrentVimMode("Visual") {
		starting_pos := StrLen(clip()) + 1 ; +1 to make sure detection_str is what's selected after send +{end}+{left}
		send +{end}+{left}
		detection_str := SubStr(clip(), starting_pos)
		pos := InStr(detection_str, finding_char, true,, occurrence)
		left := StrLen(detection_str) - pos
		if Vim.State.StrIsInCurrentVimMode("ft_t") {
			left += 1
			if (pos == 1) {
				occurrence += 1
				left := StrLen(detection_str) - InStr(detection_str, finding_char, true,, occurrence)
			}
		}
		SendInput +{left %left%}
		last_ft := Vim.State.Mode
		Vim.State.SetMode("Vim_VisualChar")
	} else {
		send {right}+{end}+{left} ; go right one char in case current char = finding char
		pos := InStr(clip(), finding_char, true,, occurrence)
		SendInput {left}{right %pos%}
		if Vim.State.StrIsInCurrentVimMode("ft_t") || (Vim.State.StrIsInCurrentVimMode("ft_f") && !pos)
			send {left}
		last_ft := Vim.State.Mode
		Vim.State.SetNormal()
	}
	last_finding_char := finding_char
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && last_finding_char
`;::
	repeat_ft = 1
	Gosub ft
Return