; Inner mode
#If (Vim.IsVimGroup()
     && !Vim.State.StrIsInCurrentVimMode("Inner")
     && (Vim.State.StrIsInCurrentVimMode("Vim_ydc")
         || Vim.State.IsCurrentVimMode("Vim_VisualChar")
         || Vim.State.IsCurrentVimMode("Vim_VisualFirst")
         || Vim.State.StrIsInCurrentVimMode("SMVim_")))
i::Vim.State.SetInner()

#If (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Inner"))
w::Vim.Move.Inner("w")
s::Vim.Move.Inner("s")
p::Vim.Move.Inner("p")

; gg
#If (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && !Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#If (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && Vim.State.g)
g::Vim.Move.Move("g")

#If (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_"))
; 1 character
h::Vim.Move.Repeat("h")
j::Vim.Move.Repeat("j")
k::Vim.Move.Repeat("k")
l::Vim.Move.Repeat("l")
; Home/End
0::Vim.Move.Move("0")
$::Vim.Move.Move("$")
^::Vim.Move.Move("^")
+::Vim.Move.Move("+")
-::Vim.Move.Move("-")
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
; Sentence
(::
)::
  KeyWait Shift  ; cannot use ReleaseKey("shift"), shift will still get stuck
  Vim.Move.Move(A_ThisHotkey)
Return

; Search
#If Vim.IsVimGroup() && (Vim.State.StrIsInCurrentVimMode("Vim_")) && !(Vim.State.StrIsInCurrentVimMode("Vim_Normal"))
/::Vim.Move.Move("/")
?::Vim.Move.Move("?")

#If
