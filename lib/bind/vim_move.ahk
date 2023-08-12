; Inner mode
#if (Vim.IsVimGroup()
  && !Vim.State.StrIsInCurrentVimMode("Inner")
  && !Vim.State.StrIsInCurrentVimMode("Outer")
  && (Vim.State.StrIsInCurrentVimMode("Vim_ydc")
   || Vim.State.IsCurrentVimMode("Vim_VisualChar")
   || Vim.State.IsCurrentVimMode("Vim_VisualFirst")
   || Vim.State.StrIsInCurrentVimMode("SMVim_")
   || Vim.State.StrIsInCurrentVimMode("Vim_g")))
i::Vim.State.SetInner()
a::Vim.State.SetOuter()

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Inner"))
w::
s::
p::
(::
)::
{::
}::
[::
]::
<::
>::
'::Vim.Move.Inner(A_ThisHotkey)
t::Vim.Move.Inner("<")
"::Vim.Move.Inner("""")

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Outer"))
w::
s::
p::
(::
)::
{::
}::
[::
]::
<::
>::
'::Vim.Move.Outer(A_ThisHotkey)
t::Vim.Move.Outer("<")
"::Vim.Move.Outer("""")

; gg
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && !Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && Vim.State.g)
g::Vim.Move.Move("g")
_::Vim.Move.Move("$")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && GetKeyState("j", "P") && Vim.SM.IsEditingText())
k::send {up}{esc}
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && GetKeyState("k", "P") && Vim.SM.IsEditingText())
j::send {down}{esc}

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_"))
; 1 character
h::Vim.Move.Repeat("h")
j::Vim.Move.Repeat("j")
k::Vim.Move.Repeat("k")
l::Vim.Move.Repeat("l")
; Home/End
0::Vim.Move.Move("0")
$::Vim.Move.Move("$")
^::Vim.Move.Move("^")
+::Vim.Move.Repeat("+")
-::Vim.Move.Repeat("-")
; Words
w::Vim.Move.Repeat("w")
e::Vim.Move.Move("e")
b::Vim.Move.Repeat("b")
; Page Up/Down
^u::Vim.Move.Repeat("^u")
^d::Vim.Move.Repeat("^d")
^b::Vim.Move.Repeat("^b")
^f::Vim.Move.Repeat("^f")
; G
+g::Vim.Move.Move("+g")
; Paragraph up/down
{::Vim.Move.Repeat("{")
}::Vim.Move.Repeat("}")
; Other motions
x::Vim.Move.Repeat("x")
+x::Vim.Move.Repeat("+x")
; Sentence
(::
)::
  Vim.Move.Move(A_ThisHotkey)
Return

'::Vim.State.SetMode("",, -1,,, -1, 1)  ; leader key

; Search
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && !Vim.State.StrIsInCurrentVimMode("Vim_Normal"))
/::Vim.Move.Move("/")
?::Vim.Move.Move("?")