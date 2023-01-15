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

  list := "Plan||WindowSpy|Regex101|Google|YT|ScriptSettings|MoveMouseToCaret"
        . "|LaTeX|WaybackMachine|DeepL|YouGlish|KillIE|DefineGoogle|Wiktionary"
        . "|Bilibili|CopyCurrentTitle|CopyHTML|Forvo|Sci-Hub|AccViewer"
        . "|TranslateGoogle|ClearClipboard|Forcellini|RAE|OALD"
        . "|AlatiusLatinMacronizer|UIAViewer|Libgen|ImageGoogle|WatchLaterYT"

  if (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) {
    list := "SetConceptHook|MemoriseChildren|" . list
    if (WinActive("ahk_class TElWind")) {
      if (Vim.SM.IsPassive(, -1))
        list := "ReformatScriptComponent|SearchLinkInYT|" . list
      list := "NukeHTML|ReformatVocab|ImportFirstFile|" . list
      if (Vim.SM.IsEditingText())
        list := "ClozeAndDone!|" . list
    }
  } else if (WinActive("ahk_class TBrowser")) {
    list := "MemoriseCurrentBrowser|SetBrowserPosition|MassReplaceRegistry|" . list
  } else if (WinActive("ahk_group Browser")) {
    list := "IWBNewTopic|IWBPriorityAndConcept|" . list
  }

  gui, VimCommander:Add, Combobox, vCommand gAutoComplete w144, % list
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
      command := EncodeDecodeURI(command)
      run % "https://www.google.com/search?q=" . command
    }
    return
  }
  Vim.State.SetMode("Insert")
  WinActivate % "ahk_id " . hwnd
  goto % command
return

FindSearch(title, prompt, text:="") {
  if (!Default := trim(copy()))
      Default := text ? text : Clipboard
  v := InputBox(title, prompt,,,,,,,, Default)
  if (ErrorLevel)
    return
  return v
}

WindowSpy:
  run C:\Program Files\AutoHotkey\WindowSpy.ahk
return

Regex101:
  run https://regex101.com/
return

Google:
  if (!GoogleSearch := FindSearch("Google Search", "Enter your search."))
    return
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
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  if (!url := FindSearch("Wayback Machine", "Enter your URL.", uiaBrowser.GetCurrentURL()))
    return
  run % "https://web.archive.org/web/*/" . url
return

DeepL:
  if (!text := FindSearch("DeepL Translate", "Enter your text."))
    return
  run % "https://www.deepl.com/en/translator#?/en/" . text
Return

YouGlish:
  term := trim(Copy())
  gui, YouGlish:Add, Text,, &Term:
  gui, YouGlish:Add, Edit, vTerm w136 r1 -WantReturn, % term
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
  gui, GoogleDefine:Add, Edit, vTerm w136 r1 -WantReturn, % term
  gui, GoogleDefine:Add, Text,, &Language Code:
  list := "en||es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr"
  gui, GoogleDefine:Add, Combobox, vLangCode gAutoComplete, % list
  gui, GoogleDefine:Add, Button, default, &Search
  gui, GoogleDefine:Show,, Google Define
  SetDefaultKeyboard(0x0409)  ; English-US
Return

GoogleDefineGuiEscape:
GoogleDefineGuiClose:
  gui destroy
return

GoogleDefineButtonSearch:
  gui submit
  gui destroy
  if (LangCode) {
    run % "https://www.google.com/search?hl=" . LangCode . "&q=" . term
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

; YTHistoryInIE:
;   ; run iexplore.exe https://www.youtube.com/feed/history  ; RIP IE
;   Vim.Browser.RunInIE("https://www.youtube.com/feed/history")
; return

Wiktionary:
  term := trim(Copy())
  gui, Wiktionary:Add, Text,, &Term:
  gui, Wiktionary:Add, Edit, vTerm w136 r1 -WantReturn, % term
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

CopyCurrentTitle:
  Clipboard := WinGetTitle()
  ToolTip("Copied " . WinGetTitle())
return

CopyHTML:
  ClipSaved := ClipboardAll
  if (!Clipboard := copy(false, true))
    goto RestoreClipReturn
  ToolTip("Copying successful.")
return

Forvo:
  if (!term := FindSearch("Forvo", "Enter your search term."))
    return
  run % "http://forvo.com/search/" . term . "/"
return

SetConceptHook:
  if (WinActive("ahk_class TElWind")) {
    send !c
    WinWaitActive, ahk_class TContents
  }
  if (ControlGetFocus() == "TVTEdit1")
    send {enter}
  ControlFocusWait("TVirtualStringTree1")
  send {AppsKey}ce
  WinWaitActive, ahk_class TMsgDialog  ; either asking for confirmation or "no change"
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
  if (!text := FindSearch("Google Translate", "Enter your text."))
    return
  run % "https://translate.google.com/?sl=auto&tl=en&text=" . text . "&op=translate"
return

ClearClipboard:
  run % ComSpec . " /c echo off | clip"
return

MemoriseChildren:
  send ^{space}
  Vim.SM.WaitBrowser()
  gosub MemoriseCurrentBrowser
return

MemoriseCurrentBrowser:
  send {AppsKey}cn  ; find pending elements
  Vim.SM.WaitBrowser()
  send {AppsKey}ple  ; remember
return

Forcellini:
  if (!term := FindSearch("Forcellini", "Enter your search term."))
    return
  run % "http://lexica.linguax.com/forc2.php?searchedLG=" . term
return

RAE:
  if (!term := FindSearch("RAE", "Enter your search term."))
    return
  run % "https://dle.rae.es/" . term . "?m=form"
return

OALD:
  if (!term := FindSearch("Oxford Advanced Learner's Dictionary", "Enter your search term."))
    return
  run % "https://www.oxfordlearnersdictionaries.com/definition/english/" . term . "?q=" . term
return

AlatiusLatinMacronizer:
  if (!Latin := FindSearch("Alatius: a Latin macronizer", "Enter your Latin sentences."))
    return
  run https://alatius.com/macronizer/
  WinWaitActive, ahk_group Browser
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  uiaBrowser.WaitPageLoad()
  uiaBrowser.WaitElementExist("ControlType=Edit AND FrameworkId=Chrome").SetValue(Latin)
  uiaBrowser.WaitElementExist("ControlType=Button AND Name='Submit'").Click()
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

; CopyCurrentWindowsPosition:
;   WinGetPos, x, y, w, h, A
;   WinClip.Clear()
;   Clipboard := "x = " . x . " y = " . y . " w = " . w . " h = " . h
;   ClipWait
;   ToolTip("Copied " . Clipboard)
; return

MassReplaceRegistry:
  find := ""
  replacement := ""
  if (!find && !replacement)
    return
  loop {
    WinActivate, ahk_class TElWind
    Vim.SM.WaitFileLoad()
    Vim.SM.EditRef()
    WinWaitActive, ahk_class TInputDlg
    ControlGetText, ref, TMemo1
    if (IfContains(ref, find)) {
      ControlSetText, TMemo1, % StrReplace(ref, find, replacement)
    } else {
      return
    }
    send !{enter}
    WinWaitActive, ahk_class TChoicesDlg,, 0
    if (!ErrorLevel)
      send {down}{enter}
    WinActivate, ahk_class TBrowser
    send {down}
  }
return

SciHub:
  if (!text := FindSearch("Sci-Hub", "Enter your search."))
    return
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
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  uiaBrowser.WaitPageLoad()
  el := uiaBrowser.WaitElementExist("ControlType=Edit AND Name='enter URL, PMID / DOI or search string'")
  ValuePattern := el.GetCurrentPatternAs("Value")
  ValuePattern.SetValue(text)
  uiaBrowser.WaitElementExist("ControlType=Text AND Name='open'").Click()
return

YT:
  if (!text := FindSearch("YouTube", "Enter your search."))
    return
  run % "https://www.youtube.com/results?search_query=" . text
return

; Personal: Reformat my old vocabulary items
ReformatVocab:
  Vim.State.SetMode("Vim_Normal")
  ClipSaved := ClipboardAll
  Vim.SM.EditFirstQuestion()
  if (!Vim.SM.WaitTextFocus(1000))
    return
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

; ZLibrary:
;   if (!search := Trim(Copy())) {
;     InputBox, search, Z-Library, Enter your search.,, 192, 128
;     if (!search)
;       return
;   }
;   run https://z-lib.org/
;   WinWaitActive, ahk_group Browser
;   uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
;   uiaBrowser.WaitPageLoad()
;   url := uiaBrowser.WaitElementExist("ControlType=Hyperlink AND Name='Books'").CurrentValue
;   uiaBrowser.SetURL(url . "s/" . EncodeDecodeURI(search) . "?", true)
; return

ImportFirstFile:
  Vim.State.SetMode("Vim_Normal")
  send ^+p
  WinWaitActive, ahk_class TElParamDlg
  send !t
  send {text}b  ; my template for pdf/epub file is binary
  send {enter 2}
  WinWaitActive, ahk_class TElWind
  Vim.SM.InvokeFileBrowser()
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
    send {text}n  ; not keeping the file in original position
    WinWaitClose
    WinWaitActive, ahk_class TMsgDialog
  }
  send {text}y  ; confirm to delete the file / confirm to keep the file
  WinWaitActive, ahk_class TElWind
  Vim.SM.Reload()
return

ScriptSettings:
  Vim.Setting.ShowGui()
return

Bilibili:
  if (!search := FindSearch("Bilibili", "Enter your search."))
    return
  run % "https://search.bilibili.com/all?keyword=" . search
return

Libgen:
  if (!search := FindSearch("Library Genesis", "Enter your search."))
    return
  run % "http://libgen.is/search.php?req=" . search . "&lg_topic=libgen&open=0&view=simple&res=25&phrase=1&column=def"
return

ImageGoogle:
  if (!search := FindSearch("Image (Google)", "Enter your search."))
    return
  run % "https://www.google.com/search?hl=en&tbm=isch&q=" . search
return

SearchLinkInYT:
  if (!link := Vim.SM.GetLink()) {
    vim.sm.EditFirstQuestion()
    vim.sm.WaitTextFocus()
    send ^{home}+{right}
    RegExMatch(copy(, true), "(<A((.|\r\n)*)href="")\K[^""]+", link)
    send {esc}
  }
  if (link) {
    run % "https://www.youtube.com/results?search_query=" . link
    WinWaitActive, ahk_group Browser
    uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
    uiaBrowser.WaitPageLoad()
    uiaBrowser.WaitElementExist("ControlType=Text AND Name='Filters'")  ; wait till page is fully loaded
    auiaLinks := uiaBrowser.FindAllByType("Hyperlink")
    for i, v in auiaLinks {
      if (IfContains(v.CurrentValue, link)) {
        v.click()
        return
      }
    }
  }
  ToolTip("Not found.")
return

WatchLaterYT:
  run https://www.youtube.com/playlist?list=WL
return