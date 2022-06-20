#If Vim.IsVimGroup() && !WinActive("ahk_class TPlanDlg") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
; in Plan window pressing enter simply goes to the next field; no need to go back to normal
; in element window pressing enter to learn goes to normal
~enter::
#If Vim.IsVimGroup() && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText()
~space up::  ; for Learn button
  WinGetText, visible_text, ahk_class TElWind
  RegExMatch(visible_text, "(?<=LearnBar\r\n)(.*?)(?= \(SuperMemo 18: )", collection_name)
  if (collection_name = "passive" || collection_name = "music") {
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
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would add a {left}
  Vim.SM.EnterInsertIfSpelling()
Return

#If Vim.IsVimGroup() and WinActive("ahk_class TElWind")  ; SuperMemo element window
~f4::  ; open tasklist
~!x::  ; extract
~!z::  ; cloze
~^+a::  ; web import
~^f4::  ; my DeepL shortcut
#If Vim.IsVimGroup() and WinActive("ahk_class TPlanDlg")  ; SuperMemo Plan window
~^s::  ; save
~^+a::  ; archive current plan
  Vim.State.SetMode("Vim_Normal")  ; SetNormal() would move the caret in some instances
return

#If (Vim.IsVimGroup() && Vim.SM.IsEditingHTML() && !Vim.State.StrIsInCurrentVimMode("Visual") && !Vim.State.StrIsInCurrentVimMode("Command"))  ; SuperMemo element window
^l::  ; learn
  Controlsend, TBitBtn2, {ctrl down}l{ctrl up}, ahk_class TElWind
  Vim.State.SetMode("Vim_Normal")
  Vim.SM.EnterInsertIfSpelling()
Return

^p::  ; open Plan window
  Controlsend, TBitBtn2, {ctrl down}p{ctrl up}, ahk_class TElWind
  Vim.State.SetMode("Vim_Normal")
Return
