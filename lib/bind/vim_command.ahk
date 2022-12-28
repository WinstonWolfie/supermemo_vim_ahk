#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
; `;::Vim.State.SetMode("Command") ;(;)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command"))
w::Vim.State.SetMode("Command_w")
q::Vim.State.SetMode("Command_q")
h::
  send {F1}
  Vim.State.SetMode("Vim_Normal")
Return
CapsLock & m::
bs::Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command_w"))
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

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command_q"))
Return::
  send ^w
  Vim.State.SetMode("Insert")
Return

; Commander, can be launched anywhere as long as the script is enabled
#if (Vim.State.Vim.Enabled && !Vim.State.IsCurrentVimMode("Command"))
^`;::
  if (WinExist("ahk_id " . CommanderHwnd)) {
    WinActivate
    return
  }
  hwnd := WinGet()
  gui, VimCommander:Add, Text,, &Command:

  list := "SM Plan||Window Spy|Regex101|Watch later (YT)|Search"
        . "|Search clipboard|Z-Library|YT|Open script settings"
        . "|Move mouse to caret|LaTeX|Wayback Machine|DeepL|YouGlish|Kill IE"
        . "|Define (Google)|YT History In IE|Wiktionary|Bilibili"
        . "|Copy current window's title|Copy current window's position"
        . "|Copy as HTML|Forvo|Pin current window at top|Sci-Hub"
        . "|Acc Viewer|Translate (Google)|Clear clipboard|Forcellini|RAE"
        . "|Show selection as html|Oxford Advanced Learner's Dictionary"
        . "|Alatius: a Latin macronizer|UIA Viewer|Libgen"
        . "|Register clipboard to Vim.Browser.VidTime|Image (Google)"

  if (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) {
    list .= "|Set current element as concept hook"
          . "|Memorise children of current element"
    if (WinActive("ahk_class TElWind")) {
      if (Vim.SM.IsPassive("", -1))
        list .= "|Reformat script component"
      list .= "|Nuke HTML|Reformat vocab|Import first file"
      if (Vim.SM.IsEditingText())
        list .= "|Cloze and Done!"
    }
  } else if (WinActive("ahk_class TBrowser")) {
    list .= "|Memorise current browser|Set browser position"
          . "|Mass replace registry"
  } else if (WinActive("ahk_group Browser")) {
    list .= "|Incremental web browsing: New topic"
          . "|Incremental web browsing: New topic with priority and concept"
  }

  gui, VimCommander:Add, Combobox, vCommand gAutoComplete w256, % list
  gui, VimCommander:Add, Button, default, &Execute
  gui, VimCommander:Show,, Vim Commander
  gui, VimCommander:+HwndCommanderHwnd
Return

VimCommanderGuiEscape:
VimCommanderGuiClose:
  gui destroy
return

VimCommanderButtonExecute:
  gui submit
  gui destroy
  if (IfContains("|" . list . "|", "|" . command . "|")) {
    command := RegExReplace(command, "\W")
  } else {
    if (command ~= "^https?:\/\/") {
      run % command
    } else {
      run % "https://www.google.com/search?q=" . command
    }
    return
  }
  Vim.State.SetMode("Insert")
  WinActivate % "ahk_id " . hwnd
  goto % command
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
  if (!GoogleSearch := Trim(Copy())) {
    InputBox, GoogleSearch, Google Search, Enter your search term.,, 192, 128
    if (!GoogleSearch)
      return
  }
  if (GoogleSearch ~= "^https?:\/\/") {
    run % GoogleSearch
  } else {
    run % "https://www.google.com/search?q=" . GoogleSearch
  }
return

SearchClipboard:
  GoogleSearch := RegExReplace(Clipboard, "(^\s*|\s*$)")
  if (GoogleSearch ~= "^https?:\/\/") {
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
  if (!url := Trim(Copy())) {
    InputBox, url, Wayback Machine, Enter your URL.,, 192, 128
    if (!url)
      return
  }
  run % "https://web.archive.org/web/*/" . url
return

DeepL:
  if (!text := Trim(Copy())) {
    InputBox, text, DeepL Translate, Enter your text.,, 192, 128
    if (!text)
      return
  }
  run % "https://www.deepl.com/en/translator#?/en/" . text
Return

YouGlish:
  term := trim(Copy())
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
  StringLower, language, language
  run % "https://youglish.com/pronounce/" . term . "/" . language . "?"
Return

KillIE:
  while (WinExist("ahk_exe iexplore.exe"))
    process, close, iexplore.exe
return

DefineGoogle:
  term := trim(Copy())
  gui, GoogleDefine:Add, Text,, &Term:
  gui, GoogleDefine:Add, Edit, vTerm, % term
  gui, GoogleDefine:Add, Text,, &Language Code:
  list := "en||es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr"
  gui, GoogleDefine:Add, Combobox, vLangCode gAutoComplete, % list
  gui, GoogleDefine:Add, Button, default, &Search
  gui, GoogleDefine:Show,, Google Define
  SetDefaultKeyboard(0x0409)  ; english-US	
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
    run % "https://www.google.com/search?q=define:" . term
  }
return

ClozeAndDone:
  if (!Copy())
    return
  send !z
  if (Vim.SM.WaitClozeProcessing() == -1)  ; warning on trying to cloze on items
    return
  send ^+{enter}
  WinWaitNotActive, ahk_class TElWind  ; "Do you want to remove all element contents from the collection?"
  send {enter}
  WinWaitNotActive, ahk_class TElWind  ; wait for "Delete element?"
  send {enter}
  Vim.State.SetNormal()
return

YTHistoryInIE:
  ; run iexplore.exe https://www.youtube.com/feed/history  ; RIP IE
  Vim.Browser.RunInIE("https://www.youtube.com/feed/history")
return

Wiktionary:
  term := trim(Copy())
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
  if (language == "Latin") {
    term := RegExReplace(term, "ā", "a")
    term := RegExReplace(term, "ē", "e")
    term := RegExReplace(term, "ī", "i")
    term := RegExReplace(term, "ū", "u")
    term := RegExReplace(term, "ō", "o")
  }
  run % "https://en.wiktionary.org/wiki/" . term . "#" . language
return

CopyCurrentWindowsTitle:
  Clipboard := WinGetTitle()
  ToolTip("Copied " . WinGetTitle())
return

CopyAsHTML:
  ClipSaved := ClipboardAll
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (!Clipboard) {
    Clipboard := ClipSaved
    return
  }
  if (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", data)
    Clipboard := data
  }
  ToolTip("Copied`n`n" . data)
return

Forvo:
  if (!term := Trim(Copy())) {
    InputBox, term, Lexico, Enter your search term.,, 192, 128
    if (!term)
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
  if (!text := Trim(Copy())) {
    InputBox, text, Google Translate, Enter your text.,, 192, 128
    if (!text)
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
  if (!term := Trim(Copy())) {
    InputBox, term, Forcellini, Enter your search term.,, 192, 128
    if (!term)
      return
  }
  run % "http://lexica.linguax.com/forc2.php?searchedLG=" . term
return

RAE:
  if (!term := Trim(Copy())) {
    InputBox, term, RAE, Enter your search term.,, 192, 128
    if (!term)
      return
  }
  run % "https://dle.rae.es/" . term . "?m=form"
return

ShowSelectionAsHTML:
  ClipSaved := ClipboardAll
  LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", data)
    MsgBox, 4,, % "Copy?`n`n" . data
    IfMsgBox, yes, {
      Clipboard := data
      return
    }
  }
  Clipboard := ClipSaved
return

OxfordAdvancedLearnersDictionary:
  if (!term := Trim(Copy())) {
    InputBox, term, Oxford Advanced Learner's Dictionary, Enter your search term.,, 192, 128
    if (!term)
      return
  }
  run % "https://www.oxfordlearnersdictionaries.com/definition/english/" . term . "?q=" . term
return

AlatiusALatinMacronizer:
  if (!Latin := Trim(Copy())) {
    InputBox, Latin, Alatius: a Latin macronizer, Enter your Latin sentences.,, 192, 128
    if (!Latin)
      return
  }
  run https://alatius.com/macronizer/
  WinWaitActive, ahk_group Browser
  guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  guiaBrowser.WaitPageLoad()
  guiaBrowser.WaitElementExist("ControlType=Edit AND FrameworkId=Chrome").SetValue(Latin)
  ; while (!accText := Acc_Get("Object", "4.1.1.2.2.2.1.4.1.1",, "ahk_id " . WinGet()))
  ;   sleep 40
  ; accText.accValue(0) := Latin
  guiaBrowser.WaitElementExist("ControlType=Button AND Name='Submit'").Click()
  guiaBrowser := ""
return

SetBrowserPosition:
  WinMove, ahk_class TBrowser,, 0, 0, 846, 1026
return

; Personal: Reformat my old incremental video topics
ReformatScriptComponent:
  ClipSaved := ClipboardAll
  WinWaitActive, ahk_class TElWind
  KeyWait alt
  KeyWait enter
  if (ContLearn := Vim.SM.IsLearning())
    send !g
  Vim.SM.ExitText()
  WinClip.Clear()
  send ^a^x
  ClipWait 0.6
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
      WinWaitActive, ahk_class TScriptEditor
      ControlSetText, TMemo1, % ControlGetText("TMemo1") . YTTime
      send !o{esc}  ; close script editor
    }
  } else {
    Vim.Browser.comment := RegExReplace(ScriptArray[2], "(^\s*|\s*$)")
  }
  WinClip.Clear()
  Clipboard := Vim.Browser.url
  ClipWait
  gosub SMSetLinkFromClipboard
  send {esc}
  if (ContLearn)
    send {enter}
  Clipboard := ClipSaved
  Vim.Browser.Clear()
  Vim.State.SetMode("Vim_Normal")
return

CopyCurrentWindowsPosition:
  WinGetPos, x, y, w, h, A
  WinClip.Clear()
  Clipboard := "x = " . x . " y = " . y . " w = " . w . " h = " . h
  ClipWait
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
  if (!text := Trim(Copy())) {
    InputBox, text, Sci-Hub, Enter your search.,, 192, 128
    if (!text)
      return
  }
  if (RegExMatch(text, "https:\/\/doi\.org\/([^ ]+)", v)) {
    run % "https://sci-hub.hkvisa.net/" . v1
    return
  ; https://www.crossref.org/blog/dois-and-matching-regular-expressions/
  } else if (RegExMatch(text, "i)10.\d{4,9}/[-._;()/:A-Z0-9]+", v)) {
    run % "https://sci-hub.hkvisa.net/" . v
    return
  }
  run https://sci-hub.hkvisa.net/
  WinWaitActive, ahk_group Browser
  guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  guiaBrowser.WaitPageLoad()
  el := guiaBrowser.WaitElementExist("ControlType=Edit AND Name='enter URL, PMID / DOI or search string'")
  ValuePattern := el.GetCurrentPatternAs("Value")
  ValuePattern.SetValue(text)
  guiaBrowser.WaitElementExist("ControlType=Text AND Name='open'").Click()
  guiaBrowser := ""
return

YT:
  if (!text := Trim(Copy())) {
    InputBox, text, YouTube, Enter your search.,, 192, 128
    if (!text)
      return
  }
  run % "https://www.youtube.com/results?search_query=" . text
return

; Personal: Reformat my old vocabulary items
ReformatVocab:
  Vim.State.SetMode("Vim_Normal")
  ClipSaved := ClipboardAll
  if (!Vim.SM.IsEditingHTML()) {
    send q
    if (!Vim.SM.WaitTextFocus(1000))
      return
  }
  send ^a
  if (!data := copy(false, true)) {
    Clipboard := ClipboardAll
    return
  }
  data := StrLower(SubStr(data, 1, 1)) . SubStr(data, 2)  ; make the first letter lower case
  data := RegExReplace(data, "(\.<BR>""|\. <BR>(\r\n<P><\/P>)?\r\n<P>‘)", "<P>")
  data := RegExReplace(data, "(""|\.?’)", "</P>")
  data := StrReplace(data, "<P></P>")
  SynPos := RegExMatch(data, "<(P|BR)>(Similar|Synonyms)")
  def := SubStr(data, 1, SynPos - 1)
  SynAndAnt := SubStr(data, SynPos)
  SynAndAnt := StrReplace(SynAndAnt, "; ", ", ")
  SynAndAnt := RegExReplace(SynAndAnt, "(<BR>)?((Similar:?)<BR>|Synonyms ?(\r\n)?(<\/P>\r\n<P>|<BR>))", "<P>syn: ")
  SynAndAnt := RegExReplace(SynAndAnt, "(Opposite:?|Opuesta)<BR>", "ant: ")
  WinClip.Paste(def . SynAndAnt,, false)
  send ^a^+1
  Clipboard := ClipSaved
return

ZLibrary:
  if (!search := Trim(Copy())) {
    InputBox, search, Z-Library, Enter your search.,, 192, 128
    if (!search)
      return
  }
  run https://z-lib.org/
  WinWaitActive, ahk_group Browser
  guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  guiaBrowser.WaitPageLoad()
  url := guiaBrowser.WaitElementExist("ControlType=Hyperlink AND Name='Books'").CurrentValue
  guiaBrowser.SetURL(url . "s/" . EncodeDecodeURI(search) . "?", true)
  guiaBrowser := ""
return

ImportFirstFile:
  Vim.State.SetMode("Vim_Normal")
  send ^+p
  WinWaitActive, ahk_class TElParamDlg
  send !t
  send {text}b  ; my template for pdf/epub file is binary
  send {enter 2}
  WinWaitActive, ahk_class TElWind
  send {CtrlDown}ttq{CtrlUp}
  GroupAdd, SMCtrlQ, ahk_class TFileBrowser
  GroupAdd, SMCtrlQ, ahk_class TMsgDialog
  WinWaitActive, ahk_group SMCtrlQ
  while (!WinActive("ahk_class TFileBrowser")) {
    while (WinActive("ahk_class TMsgDialog"))
      send n  ; Directory not found; Create?
    WinWaitActive, ahk_group SMCtrlQ
  }
  send {right}
  MsgBox, 3,, Do you want to also delete the file?
  IfMsgBox Cancel
    return
  WinActivate, ahk_class TFileBrowser
  send {enter}
  WinWaitActive, ahk_class TInputDlg
  send {enter}
  WinWaitActive, ahk_class TMsgDialog
  IfMsgBox, yes, {
    send n  ; not keeping the file in original position
    WinWaitNotActive, ahk_class TMsgDialog,, 0
    WinWaitActive, ahk_class TMsgDialog
  }
  send y  ; confirm to delete the file / confirm to keep the file
  WinWaitActive, ahk_class TElWind
  Vim.SM.Reload()
return

OpenScriptSettings:
  Vim.Setting.ShowGui()
return

RegisterClipboardToVimBrowserVidTime:
  Vim.Browser.VidTime := Clipboard
  ToolTip("Vim.Browser.VidTime = " . Vim.Browser.VidTime)
return

Bilibili:
  if (!search := Trim(Copy())) {
    InputBox, search, Bilibili, Enter your search.,, 192, 128
    if (!search)
      return
  }
  run % "https://search.bilibili.com/all?keyword=" . search
return

Libgen:
  if (!search := Trim(Copy())) {
    InputBox, search, Library Genesis, Enter your search.,, 192, 128
    if (!search)
      return
  }
  run % "http://libgen.is/search.php?req=" . search . "&lg_topic=libgen&open=0&view=simple&res=25&phrase=1&column=def"
return

ImageGoogle:
  if (!search := Trim(Copy())) {
    InputBox, search, Image (Google), Enter your search.,, 192, 128
    if (!search)
      return
  }
  run % "https://www.google.com/search?hl=en&tbm=isch&q=" . search
return