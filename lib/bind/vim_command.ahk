#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
; `;::Vim.State.SetMode("Command") ;(;)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command"))
w::Vim.State.SetMode("Command_w")
q::Vim.State.SetMode("Command_q")
h::
  Send, {F1}
  Vim.State.SetMode("Vim_Normal")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_w"))
Return::
  Send, ^s
  Vim.State.SetMode("Vim_Normal")
Return

q::
  Send, ^s^w
  Vim.State.SetMode("Insert")
Return

Space::  ; save as
  Send, !fa
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_q"))
Return::
  Send, ^w
  Vim.State.SetMode("Insert")
Return

; Commander, can be launched anywhere as long as vim_ahk is enabled
#If Vim.State.Vim.Enabled && !Vim.State.IsCurrentVimMode("Command")
^`;::
  WinGet, hwnd, ID, A
  Gui, VimCommander:Add, Text,, &Command:
  ; list names are the same as subroutine name, just no space and no final parentheses
  list := "SM Plan||Window Spy|Regex101|Watch later (YT)|Search|Move mouse to caret|LaTeX|Wayback Machine|DeepL|YouGlish|Kill IE|Google define"
  if Vim.State.IsCurrentVimMode("Vim_Normal") {
    list .= 
    CommanderMode = n
  } else if Vim.State.StrIsInCurrentVimMode("Visual") {
    if Vim.SM.IsEditingText()
      list .= "|Cloze and Done!"
    list .= "|Convert to lowercase (= u)|Convert to uppercase (= U)|Invert case (= ~)"
    CommanderMode = v
  }
  Gui, VimCommander:Add, Combobox, vCommand gAutoComplete, %list%
  Gui, VimCommander:Add, Button, default, &Execute
  Gui, VimCommander:Show,, Vim Commander
  Vim.State.SetMode("Insert")
Return

VimCommanderGuiEscape:
VimCommanderGuiClose:
  Gui, Destroy
return

VimCommanderButtonExecute:
  Gui, Submit
  Gui, Destroy
  if (command == "Watch later (YT)")
    command := "WatchLaterYT"
  else if (command == "Cloze and Done!")
    command := "ClozeAndDone"
  else if InStr("|" . list . "|", "|" . command . "|") {
    command := RegExReplace(command, " \(.*")  ; removing parentheses
    command := StrReplace(command, " ")
  } else {  ; command has to be in the list. If not, google the command
    run https://www.google.com/search?q=%command%  ; this could be a shorthand for searching
    Return
  }
  WinActivate, ahk_id %hwnd%
  Gosub % command
Return

SMPlan:
  if WinExist("ahk_class TPlanDlg") {
    WinActivate
    Vim.State.SetMode("Vim_Normal")
    Return
  }
  if WinExist("ahk_group SuperMemo") {
    WinActivate, ahk_class TElWind
    WinWaitActive, ahk_class TElWind,, 0
  } else {
    run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SuperMemo\SuperMemo.lnk
    WinWaitActive, ahk_class TElWind,, 5
    if ErrorLevel
      Return
  }
  send ^{enter}  ; commander; seems to be a more reliable option than {alt}kp or ^p
  SendInput {raw}pl  ; open plan
  send {enter}
  Vim.State.SetMode("Vim_Normal")
Return

WindowSpy:
  run C:\Program Files\AutoHotkey\WindowSpy.ahk
Return

Regex101:
  run https://regex101.com/
Return

WatchLaterYT:
  run https://www.youtube.com/playlist?list=WL
Return

Search:
  SearchTerm := clip()
  if !SearchTerm {
    InputBox, SearchTerm, Google Search, Enter your search term.,, 192, 128
    if !SearchTerm || ErrorLevel
      return
  }
  run https://www.google.com/search?q=%SearchTerm%
Return

MoveMouseToCaret:
  MouseMove, % A_CaretX, % A_CaretY
  if A_CaretX
    Vim.ToolTip("Current caret position: " . A_CaretX . " " . A_CaretY)
  else
    Vim.ToolTip("Caret not found.")
Return

LaTeX:
  run https://latex.vimsky.com/
Return

WaybackMachine:
  url := clip()
  if !url {
    InputBox, url, Wayback Machine, Enter your URL.,, 192, 128
    if !url || ErrorLevel
      return
  }
  run https://web.archive.org/web/*/%url%
Return

DeepL:
  text := clip()
  if !text {
    InputBox, text, DeepL Translation, Enter your text.,, 192, 128
    if !text || ErrorLevel
      return
  }
  run https://www.deepl.com/en/translator#?/en/%text%
Return

YouGlish:
  text := clip()
  if !text {
    InputBox, text, DeepL Translation, Enter your text.,, 192, 128
    if !text || ErrorLevel
      return
  }
  InputBox, LangCode, YouGlish, Enter a language code., , 256, 128
  if ErrorLevel
    return
  if (LangCode = "en")
    run https://youglish.com/pronounce/%text%/english?
  else if (LangCode = "es")
    run https://youglish.com/pronounce/%text%/spanish?
  else if (LangCode = "fr")
    run https://youglish.com/pronounce/%text%/french?
  else if (LangCode = "it")
    run https://youglish.com/pronounce/%text%/italian?
  else if (LangCode = "ja")
    run https://youglish.com/pronounce/%text%/japanese?
  else if (LangCode = "de")
    run https://youglish.com/pronounce/%text%/german?
  else if (LangCode = "ru")
    run https://youglish.com/pronounce/%text%/russian?
  else if (LangCode = "el")
    run https://youglish.com/pronounce/%text%/greek?
  else if (LangCode = "he")
    run https://youglish.com/pronounce/%text%/hebrew?
  else if (LangCode = "ar")
    run https://youglish.com/pronounce/%text%/arabic?
  else if (LangCode = "pl")
    run https://youglish.com/pronounce/%text%/polish?
  else if (LangCode = "pt")
    run https://youglish.com/pronounce/%text%/portuguese?
  else if (LangCode = "ko")
    run https://youglish.com/pronounce/%text%/korean?
  else if (LangCode = "sv")
    run https://youglish.com/pronounce/%text%/swedish?
  else if (LangCode = "nl")
    run https://youglish.com/pronounce/%text%/dutch?
  else if (LangCode = "tr")
    run https://youglish.com/pronounce/%text%/turkish?
  else if (LangCode = "asl")
    run https://youglish.com/pronounce/%text%/signlanguage?
Return

KillIE:
  while WinExist("ahk_exe iexplore.exe")
    Process, Close, iexplore.exe
return

GoogleDefine:
  term := clip()
  if !term {
    InputBox, term, Google Define, Enter your search term.,, 192, 128
    if !term || ErrorLevel
      return
  }
  InputBox, LangCode, Google Define, Enter a language code., , 192, 128
  if ErrorLevel
    return
  run https://www.google.com/search?hl=en&q=define+%term%&forcedict=%term%&dictcorpus=%LangCode%&expnd=1
return

ClozeAndDone:
  send !z
  Vim.SM.WaitProcessing()
  if !ErrorLevel {
    send ^+{enter}
    WinWaitNotActive, ahk_class TElWind,, 0  ; "Do you want to remove all element contents from the collection?"
    send {enter}
    WinWaitNotActive, ahk_class TElWind,, 0  ; wait for "Delete element?"
    send {enter}
    Vim.State.SetNormal()
  }
Return
