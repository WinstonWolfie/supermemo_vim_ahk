#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
; Disable
^+j::
^m::
^k::
Return

; Remap
^+!j::send ^+j  ; shift position in outstanding queue
^+!m::send ^m  ; remember
^+!k::send ^k  ; hyperlink to element
Return