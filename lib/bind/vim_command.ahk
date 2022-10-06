#if Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
; `;::Vim.State.SetMode("Command") ;(;)
#if Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command"))
w::Vim.State.SetMode("Command_w")
q::Vim.State.SetMode("Command_q")
h::
  send {F1}
  Vim.State.SetMode("Vim_Normal")
Return

#if Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_w"))
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

#if Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_q"))
Return::
  send ^w
  Vim.State.SetMode("Insert")
Return

; Commander, can be launched anywhere as long as the script is enabled
#if (Vim.State.Vim.Enabled && !Vim.State.IsCurrentVimMode("Command"))
^`;::
  KeyWait ctrl
  WinGet, hwnd, ID, A
  gui, VimCommander:Add, Text,, &Command:

  list := "SM Plan||Window Spy|Regex101|Watch later (YT)|Search"
        . "|Move mouse to caret|LaTeX|Wayback Machine|DeepL|YouGlish|Kill IE"
        . "|Define (Google)|YT History In IE|Wiktionary|Discord go live"
        . "|Copy current window's title|Copy current window's position"
        . "|Copy as HTML|Forvo|Pin current window at top|Sci-Hub"
        . "|Acc Viewer|Translate (Google)|Clear clipboard|Forcellini|RAE"
        . "|Show selection as html|Oxford Advanced Learner's Dictionary"
        . "|Alatius: a Latin macronizer|UIA Viewer|YouTube"

  if (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) {
    list .= "|Set current element as concept hook|Memorise children of current element"
    if (WinActive("ahk_class TElWind"))
      list .= "|Nuke HTML"
    if (Vim.SM.IsEditingText())
      list .= "|Cloze and Done!"
  } else if (WinActive("ahk_class TBrowser")) {
    list .= "|Memorise current browser|Set browser position"
          . "|Mass replace registry"
  }
  if (WinExist("ahk_class TElWind") && Vim.SM.DoesCollNeedScrComp()) {
    list .= "|Reformat script component"
  }
  gui, VimCommander:Add, Combobox, vCommand gAutoComplete w256, % list
  gui, VimCommander:Add, Button, default, &Execute
  gui, VimCommander:Show,, Vim Commander
Return

VimCommanderGuiEscape:
VimCommanderGuiClose:
  gui destroy
return

VimCommanderButtonExecute:
  gui submit
  gui destroy
  if (InStr("|" . list . "|", "|" . command . "|")) {
    command := RegExReplace(command, "\W")
  } else {
    run % "https://www.google.com/search?q=" . command
    return
  }
  Vim.State.SetMode("Insert",,,,, true)
  WinActivate % "ahk_id " . hwnd
  gosub % command
return

WindowSpy:
  run C:\Program Files\AutoHotkey\WindowSpy.ahk
return

Regex101:
  run https://regex101.com/
return

WatchLaterYT:
  run https://www.youtube.com/playlist?list=WL
return

Search:
  GoogleSearch := clip()
  if (!GoogleSearch) {
    InputBox, GoogleSearch, Google Search, Enter your search term.,, 192, 128
    if (!GoogleSearch || ErrorLevel)
      return
  }
  GoogleSearch := RegExReplace(GoogleSearch, "(^\s*|\s*$)")
  if (RegExMatch(GoogleSearch, "^https?:\/\/")) {
    run % GoogleSearch
  } else {
    run % "https://www.google.com/search?q=" . GoogleSearch
  }
return

MoveMouseToCaret:
  MouseMove, A_CaretX, A_CaretY
  if (A_CaretX) {
    ToolTip("Current caret position: " . A_CaretX . " " . A_CaretY)
  } else {
    ToolTip("Caret not found.")
  }
return

LaTeX:
  run https://latex.vimsky.com/
return

WaybackMachine:
  url := clip()
  if (!url) {
    InputBox, url, Wayback Machine, Enter your URL.,, 192, 128
    if (!url || ErrorLevel)
      return
  }
  run % "https://web.archive.org/web/*/" . url
return

DeepL:
  text := clip()
  if (!text) {
    InputBox, text, DeepL Translate, Enter your text.,, 192, 128
    if (!text || ErrorLevel)
      return
  }
  run % "https://www.deepl.com/en/translator#?/en/" . text
Return

YouGlish:
  term := clip()
  gui, YouGlish:Add, Text,, &Term:
  gui, YouGlish:Add, Edit, vTerm, % term
  gui, YouGlish:Add, Text,, &Language:
  list := "English||Spanish|French|Italian|Japanese|German|Russian|Greek|Hebrew"
        . "|Arabic|Polish|Portuguese|Korean|Turkish|American Sign Language"
  gui, YouGlish:Add, Combobox, vLanguage gAutoComplete, % list
  gui, YouGlish:Add, Button, default, &Search
  gui, YouGlish:Show,, YouGlish
Return

YouGlishGuiEscape:
YouGlishGuiClose:
  gui destroy
return

YouGlishButtonSearch:
  gui submit
  gui destroy
  if (language == "American Sign Language")
    language := "signlanguage"
  run % "https://youglish.com/pronounce/" . term . "/" . language . "?"
Return

KillIE:
  while (WinExist("ahk_exe iexplore.exe"))
    process, close, iexplore.exe
return

DefineGoogle:
  term := clip()
  gui, GoogleDefine:Add, Text,, &Term:
  gui, GoogleDefine:Add, Edit, vTerm, % term
  gui, GoogleDefine:Add, Text,, &Language Code:
  list := "es||en|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr"
  gui, GoogleDefine:Add, Combobox, vLangCode gAutoComplete, % list
  gui, GoogleDefine:Add, Button, default, &Search
  gui, GoogleDefine:Show,, Google Define
Return

GoogleDefineGuiEscape:
GoogleDefineGuiClose:
  gui destroy
return

GoogleDefineButtonSearch:
  gui submit
  gui destroy
  if (LangCode) {
    run % "https://www.google.com/search?hl=" . LangCode . "&q=define+" . term
        . "&forcedict=" . term . "&dictcorpus=" . LangCode . "&expnd=1"
  } else {
    run % "https://www.google.com/search?q=define+" . term
  }
return

ClozeAndDone:
  if (!clip())
    return
  send !z
  Vim.SM.WaitProcessing()
  if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
    return
  send ^+{enter}
  WinWaitNotActive, ahk_class TElWind,, 0  ; "Do you want to remove all element contents from the Coll?"
  send {enter}
  WinWaitNotActive, ahk_class TElWind,, 0  ; wait for "Delete element?"
  send {enter}
  Vim.State.SetNormal()
return

YTHistoryInIE:
  ; run iexplore.exe https://www.youtube.com/feed/history  ; RIP IE
  Vim.Browser.RunInIE("https://www.youtube.com/feed/history")
return

Wiktionary:
  term := clip()
  gui, Wiktionary:Add, Text,, &Term:
  gui, Wiktionary:Add, Edit, vTerm, % term
  gui, Wiktionary:Add, Text,, &Language:
  list := "Spanish||English|French|Italian|Japanese|German|Russian|Greek|Hebrew"
        . "|Arabic|Polish|Portuguese|Korean|Turkish|Latin|Ancient Greek|Chinese"
  gui, Wiktionary:Add, Combobox, vLanguage gAutoComplete, % list
  gui, Wiktionary:Add, Button, default, &Search
  gui, Wiktionary:Show,, Wiktionary
return

WiktionaryGuiEscape:
WiktionaryGuiClose:
  gui destroy
return

WiktionaryButtonSearch:
  gui submit
  gui destroy
  if (language == "Ancient Greek")
    language := "Ancient_Greek"
  run % "https://en.wiktionary.org/wiki/" . term . "#" . language
return

#if (WinActive("ahk_exe Discord.exe"))
^!l::
#if
DiscordGoLive:
  if (FindClick(A_ScriptDir . "\lib\bind\util\discord_screen_share.png", "r")
   || FindClick(A_ScriptDir . "\lib\bind\util\discord_screen_share_alt.png", "r")) {
    sleep 800
    send {tab 2}{enter}
    sleep 400
    send {tab}{enter}
    sleep 400
    send +{tab 2}{enter}
  }
return

CopyCurrentWindowsTitle:
  Clipboard := WinGetTitle()
  ToolTip("Copied " . Clipboard)
return

CopyAsHTML:
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (!Clipboard) {
    WinClip.Restore(ClipData)
    return
  }
  if (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", data)
    Clipboard := data
  }
  ToolTip("Copied`n`n" . data)
return

Forvo:
  term := clip()
  if (!term) {
    InputBox, term, Lexico, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run % "http://forvo.com/search/" . term . "/"
return

PinCurrentWindowAtTop:
  Winset, AlwaysOnTop,, A
return

SetCurrentElementAsConceptHook:
  if (WinActive("ahk_class TElWind")) {
    send !c
    WinWaitActive, ahk_class TContents,, 0
  }
  if (ControlGetFocus() == "TVTEdit1")
    send {enter}
  ControlFocusWait("TVirtualStringTree1")
  send {AppsKey}ce
  WinWaitActive, ahk_class TMsgDialog,, 1  ; either asking for confirmation or "no change"
  if (!ErrorLevel)
    send {enter}
  ControlSend, TVirtualStringTree1, {esc}, ahk_class TContents
  ToolTip("Hook set.")
  Vim.State.SetMode("Vim_Normal")
Return

AccViewer:
  run % A_ScriptDir . "\lib\util\AccViewer Source.ahk"
return

UIAViewer:
  run % A_ScriptDir . "\lib\util\UIAViewer.ahk"
return

TranslateGoogle:
  text := clip()
  if (!text) {
    InputBox, text, Google Translate, Enter your text.,, 192, 128
    if (!text || ErrorLevel)
      return
  }
  run % "https://translate.google.com/?sl=auto&tl=en&text=" . text . "&op=translate"
return

ClearClipboard:
  run % ComSpec . " /c echo off | clip"
return

MemoriseChildrenOfCurrentElement:
  send ^{space}
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  gosub MemoriseCurrentBrowser
return

MemoriseCurrentBrowser:
  send {AppsKey}cn  ; find pending elements
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}ple  ; remember
return

Forcellini:
  term := clip()
  if (!term) {
    InputBox, term, Forcellini, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run % "http://lexica.linguax.com/forc2.php?searchedLG=" . term
return

RAE:
  term := clip()
  if (!term) {
    InputBox, term, RAE, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run % "https://dle.rae.es/" . term . "?m=form"
return

ShowSelectionAsHTML:
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", data)
    MsgBox, 4,, % "Copy?`n`n" . data
    IfMsgBox, yes, {
      Clipboard := data
      return
    }
  }
  WinClip.Restore(ClipData)
return

OxfordAdvancedLearnersDictionary:
  term := clip()
  if (!term) {
    InputBox, term, Oxford Advanced Learner's Dictionary, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run % "https://www.oxfordlearnersdictionaries.com/definition/english/" . term . "?q=" . term
return

AlatiusALatinMacronizer:
  Latin := clip()
  if (!Latin) {
    InputBox, Latin, Alatius: a Latin macronizer, Enter your Latin sentences,, 192, 128
    if (!Latin || ErrorLevel)
      return
  }
  run https://alatius.com/macronizer/
  WinWaitActive, ahk_group Browsers,, 10
  cUIA := new UIA_Browser("ahk_exe " . WinGet("ProcessName")) ; Initialize UIA_Browser, which also initializes UIA_Interface
  cUIA.WaitPageLoad()
  send {tab 2}
  clip(Latin)
  send {tab}{enter}
return

SetBrowserPosition:
  WinMove, ahk_class TBrowser,, 0, 0, 846, 1026
return

ReformatScriptComponent:
  WinClip.Snap(ClipData)
  if (ContinueLearning := Vim.SM.IsLearning())
    send !g
  Vim.SM.DeselectAllComponents()
  CollName := Vim.SM.GetCollName()
  if (Vim.SM.IsPassiveColl(CollName)) {
    WinClip.Clear()
    send ^a^x
    ClipWait 1
    ScriptArray := StrSplit(Clipboard, "`n`r")
    Vim.Browser.url := RegExReplace(ScriptArray[1], "(^\s*|\s*$)")
    Vim.Browser.title := WinGetTitle()
    if (InStr(Vim.Browser.url, "youtube.com")) {
      Vim.Browser.VidTime := RegExReplace(ScriptArray[2], "(^\s*|\s*$)")
      YTTime := ""
      if (ScriptArray[2])
        YTTime := "&t=" . Vim.Browser.GetSecFromTime(Vim.Browser.VidTime) . "s"
      Vim.Browser.source := "YouTube"
      if (YTTime) {
        send ^t{f9}  ; opens script editor
        WinWaitActive, ahk_class TScriptEditor,, 0
        ControlSetText, TMemo1, % ControlGetText("TMemo1") . YTTime
        send !o{esc}  ; close script editor
      }
    } else {
      Vim.Browser.comment := RegExReplace(ScriptArray[2], "(^\s*|\s*$)")
    }
    Clipboard := Vim.Browser.url
    ClipWait 10
    ; Somehow PostMessage doesn't work reliably here
    gosub SMSetLinkFromClipboard
    send {esc}
  } else if (Vim.SM.IsProblemSolvingColl(CollName)) {
    send ^+p!ts{enter 2}
    Clipboard := Vim.SM.GetLink(true)
    ClipWait 10
    send ^t
    gosub SMHyperLinkToCurrTopic
  }
  if (ContinueLearning)
    send {enter}
  WinClip.Restore(ClipData)
  Vim.Browser.Clear()
  Vim.State.SetMode("Vim_Normal")
return

CopyCurrentWindowsPosition:
  WinGetPos, x, y, w, h, A
  Clipboard := "x = " . x . " y = " . y . " w = " . w . " h = " . h
  ClipWait 10
  ToolTip("Copied " . Clipboard)
return

MassReplaceRegistry:
  find := ""
  replacement := ""
  if (!find && !replacement)
    return
  loop {
    WinActivate, ahk_class TElWind
    Vim.SM.WaitFileLoad()
    send !{f10}fe  ; open registry editor
    WinWaitActive, ahk_class TInputDlg,, 3
    ControlGetText, ref, TMemo1
    if (InStr(ref, find)) {
      ControlSetText, TMemo1, % StrReplace(ref, find, replacement)
    } else {
      return
    }
    send !{enter}
    WinWaitActive, ahk_class TChoicesDlg,, 0
    if (!ErrorLevel)
      send {down}{enter}
    WinActivate, ahk_class TBrowser
    WinGetTitle, ElementTitle, ahk_class TElWind
    send {down}
  }
return

SciHub:
  text := clip()
  if (!text) {
    InputBox, text, Sci-Hub, Enter your search,, 192, 128
    if (!text || ErrorLevel)
      return
  }
  run https://sci-hub.hkvisa.net/
  WinWaitActive, ahk_group Browsers,, 10
  cUIA := new UIA_Browser("ahk_exe " . WinGet("ProcessName")) ; Initialize UIA_Browser, which also initializes UIA_Interface
  cUIA.WaitPageLoad()
  send {tab}+{tab}
  clip(text)
  send {enter}
return

YouTube:
  text := clip()
  if (!text) {
    InputBox, text, YouTube, Enter your search,, 192, 128
    if (!text || ErrorLevel)
      return
  }
  run % "https://www.youtube.com/results?search_query=" . text
return