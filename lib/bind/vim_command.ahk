#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
; `;::Vim.State.SetMode("Command") ;(;)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command"))
w::Vim.State.SetMode("Command_w")
q::Vim.State.SetMode("Command_q")
h::
  send {F1}
  Vim.State.SetMode("Vim_Normal")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_w"))
Return::
  send ^s
  Vim.State.SetMode("Vim_Normal")
Return

q::
  send ^s^w
  Vim.State.SetMode("Insert")
Return

Space::  ; save as
  send !fa
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_q"))
Return::
  send ^w
  Vim.State.SetMode("Insert")
Return

; Commander, can be launched anywhere as long as vim_ahk is enabled
#If Vim.State.Vim.Enabled && !Vim.State.IsCurrentVimMode("Command")
^`;::
  Vim.ReleaseKey("ctrl")
  WinGet, hwnd, ID, A
  Gui, VimCommander:Add, Text,, &Command:
  ; list names are the same as subroutine name, just no space and no final parentheses
  list := "SM Plan||Window Spy|Regex101|Watch later (YT)|Search|Move mouse to caret|LaTeX|Wayback Machine|DeepL|YouGlish|Kill IE|Define (google)|YT History In IE|Wiktionary|Discord go live|Lexico|Copy current window's title|Copy as HTML|Forvo"
  if (Vim.State.IsCurrentVimMode("Vim_Normal")) {
    list .= ""
    CommanderMode = n
  } else if (Vim.State.StrIsInCurrentVimMode("Visual")) {
    if (Vim.SM.IsEditingText())
      list .= "|Cloze and Done!"
    CommanderMode = v
  }
  Gui, VimCommander:Add, Combobox, vCommand gAutoComplete, % list
  Gui, VimCommander:Add, Button, default, &Execute
  Gui, VimCommander:Show,, Vim Commander
Return

VimCommanderGuiEscape:
VimCommanderGuiClose:
  Gui, Destroy
return

VimCommanderButtonExecute:
  Gui, Submit
  Gui, Destroy
  if (command == "Cloze and Done!") {
    command := "ClozeAndDone"
  } else if (command == "Copy current window's title") {
    command := "CopyCurrentWinTitle"
  }
  else if (InStr("|" . list . "|", "|" . command . "|")) {
    command := RegExReplace(command, " |\(|\)")  ; removing parentheses and spaces
  } else {  ; command has to be in the list. If not, google the command
    run https://www.google.com/search?q=%command%  ; this could be a shorthand for searching
    Return
  }
  Vim.State.SetMode("Insert",,,,, true)
  WinActivate, ahk_id %hwnd%
  Gosub % command
Return

SMPlan:
  if (WinExist("ahk_class TPlanDlg")) {
    WinKill, ahk_class TMsgDialog
    WinActivate, ahk_class TPlanDlg
    Vim.State.SetMode("Vim_Normal")
    Return
  }
  if (!WinExist("ahk_group SuperMemo")) {
    run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SuperMemo\SuperMemo.lnk
    WinWaitActive, ahk_class TElWind,, 5
    if (ErrorLevel)
      Return
  }
  while (!WinExist("ahk_class TPlanDlg")) {
    WinKill, ahk_class TMsgDialog
    Controlsend, TBitBtn2, {ctrl down}p{ctrl up}, ahk_class TElWind
  }
  WinActivate, ahk_class TPlanDlg
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
  term := clip()
  Gui, YouGlish:Add, Text,, &Term:
  Gui, YouGlish:Add, Edit, vTerm, % term
  Gui, YouGlish:Add, Text,, &Language:
  list := "English||Spanish|French|Italian|Japanese|German|Russian|Greek|Hebrew|Arabic|Polish|Portuguese|Korean|Turkish|American Sign Language"
  Gui, YouGlish:Add, Combobox, vLanguage gAutoComplete, % list
  Gui, YouGlish:Add, Button, default, &Search
  Gui, YouGlish:Show,, YouGlish
Return

YouGlishGuiEscape:
YouGlishGuiClose:
  Gui, Destroy
return

YouGlishButtonSearch:
  Gui, Submit
  Gui, Destroy
  if (language == "American Sign Language")
    language := "signlanguage"
  run https://youglish.com/pronounce/%term%/%language%?
Return

KillIE:
  while WinExist("ahk_exe iexplore.exe")
    Process, Close, iexplore.exe
return

DefineGoogle:
  term := clip()
  Gui, GoogleDefine:Add, Text,, &Term:
  Gui, GoogleDefine:Add, Edit, vTerm, % term
  Gui, GoogleDefine:Add, Text,, &Language Code:
  list := "es||en|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr"
  Gui, GoogleDefine:Add, Combobox, vLangCode gAutoComplete, % list
  Gui, GoogleDefine:Add, Button, default, &Search
  Gui, GoogleDefine:Show,, Google Define
Return

GoogleDefineGuiEscape:
GoogleDefineGuiClose:
  Gui, Destroy
return

GoogleDefineButtonSearch:
  Gui, Submit
  Gui, Destroy
  if (LangCode) {
    run https://www.google.com/search?hl=%LangCode%&q=define+%term%&forcedict=%term%&dictcorpus=%LangCode%&expnd=1
  } else {
    run https://www.google.com/search?q=define+%term%
  }
return

ClozeAndDone:
  send !z
  Vim.SM.WaitProcessing()
  if (!ErrorLevel) {
    send ^+{enter}
    WinWaitNotActive, ahk_class TElWind,, 0  ; "Do you want to remove all element contents from the collection?"
    send {enter}
    WinWaitNotActive, ahk_class TElWind,, 0  ; wait for "Delete element?"
    send {enter}
    Vim.State.SetNormal()
  }
Return

YTHistoryInIE:
  run iexplore.exe https://www.youtube.com/feed/history
Return

Wiktionary:
  term := clip()
  if (!term) {
    Gui, Wiktionary:Add, Text,, &Term:
    Gui, Wiktionary:Add, Edit, vTerm
  }
  Gui, Wiktionary:Add, Text,, &Language:
  list := "Spanish||English|French|Italian|Japanese|German|Russian|Greek|Hebrew|Arabic|Polish|Portuguese|Korean|Turkish"
  Gui, Wiktionary:Add, Combobox, vLanguage gAutoComplete, % list
  Gui, Wiktionary:Add, Button, default, &Search
  Gui, Wiktionary:Show,, Wiktionary
Return

WiktionaryGuiEscape:
WiktionaryGuiClose:
  Gui, Destroy
return

WiktionaryButtonSearch:
  Gui, Submit
  Gui, Destroy
  run https://en.wiktionary.org/wiki/%term%#%language%
return

DiscordGoLive:
  if (FindClick(A_ScriptDir . "\lib\bind\util\discord_screen_share.png") || FindClick(A_ScriptDir . "\lib\bind\util\discord_screen_share_alt.png")) {
    sleep 1000
    send {tab 2}{enter}
    sleep 500
    send {tab}{enter}
    sleep 500
    send +{tab 2}{enter}
  }
return

Lexico:
  term := clip()
  if (!term) {
    InputBox, term, Lexico, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run https://www.lexico.com/definition/%term%?s=t
return

CopyCurrentWinTitle:
  Clipboard := WinGetTitle("A")
  Vim.ToolTip("Copied " . Clipboard)
return

CopyAsHTML:
  ClipSaved := ClipboardAll
  Clipboard := ""
  send ^c
  clipwait 0.6
  if (ErrorLevel) {
    Clipboard := ClipSaved
    Return
  }
  if Vim.HTML.ClipboardGet_HTML(data) {
    RegExMatch(data, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", data)
    Clipboard := data
    ClipWait 0.6
  }
  Vim.ToolTip("Copied " . Clipboard)
Return

Forvo:
  term := clip()
  if (!term) {
    InputBox, term, Lexico, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run http://forvo.com/search/%term%/
Return