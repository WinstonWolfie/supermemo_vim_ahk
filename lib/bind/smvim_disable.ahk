#If Vim.IsVimGroup() and WinActive("ahk_class TElWind")
; Disable
^+j::
^m::
Return

; Remap
^+!j::send ^+j ; shift position in outstanding queue
^+!m::send ^m ; remember
^+!k::send ^k ; hyperlink to element
Return