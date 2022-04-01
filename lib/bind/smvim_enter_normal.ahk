#If Vim.IsVimGroup() && !WinActive("ahk_class TPlanDlg") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
; in Plan window pressing enter simply goes to the next field; no need to go back to normal
; in element window pressing enter to learn goes to normal
~enter::
#If Vim.IsVimGroup() && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
~space up::  ; for Learn button
  WinGetText, visible_text, ahk_class TElWind
  RegExMatch(visible_text, "(?<=LearnBar\r\n)(.*?)(?= \(SuperMemo 18: )", collection_name)
  if (collection_name = "passive") {
    loop {
      sleep 40
      ControlGetText, current_text, TBitBtn3
      if (current_text == "Next repetition") {
        send ^{f10}
        break
      }
      if (A_Index > 5)
        Break
    }
  }
#If Vim.IsVimGroup() and WinActive("ahk_class TElWind")  ; SuperMemo element window
~f4::  ; open tasklist
~!x::  ; extract
~!z::  ; cloze
~^+a::  ; web import
#If Vim.IsVimGroup() and WinActive("ahk_class TPlanDlg")  ; SuperMemo Plan window
~^s::  ; save
~^+a::  ; archive current plan
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would move the caret in some instances
return

#If Vim.IsVimGroup() and WinActive("ahk_class TElWind") && !Vim.State.StrIsInCurrentVimMode("Visual") && !Vim.State.StrIsInCurrentVimMode("Command")  ; SuperMemo element window
^l::  ; learn
  Vim.ReleaseKey("ctrl")
  send {alt}ll
  Vim.State.SetMode("Vim_Normal")
Return

^p::  ; open Plan window
  Vim.ReleaseKey("ctrl")
  send {alt}kp
  Vim.State.SetMode("Vim_Normal")
Return
