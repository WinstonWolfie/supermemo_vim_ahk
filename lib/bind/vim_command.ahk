#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
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
  hWnd := WinActive("A")
  Gui, VimCommander:Add, Text,, &Command:

  list := "Plan||Wiktionary|WebSearch|YT|ScriptSettings|MoveMouseToCaret"
        . "|WaybackMachine|DefineGoogle|YouGlish|KillOutlook|DeepL"
        . "|WindowSpy|BingChat|CopyTitle|CopyHTML|Forvo|SciHub|AccViewer"
        . "|TranslateGoogle|ClearClipboard|Forcellini|RAE|OALD"
        . "|AlatiusLatinMacronizer|UIAViewer|Libgen|ImageGoogle|WatchLaterYT"
        . "|CopyWindowPosition|ZLibrary|GetInfoFromContextMenu|GenerateTimeString"
        . "|Bilibili|AlwaysOnTop|Larousse|GraecoLatinum|Linguee"
        . "|MerriamWebster|WordSense|RestartOneDrive|RestartICloudDrive|KillIE"
        . "|CalculateTodaysPassRate|PerplexityAI"

  if (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) {
    list := "SetConceptHook|MemoriseChildren|" . list
    if (WinActive("ahk_class TElWind")) {
      list := "NukeHTML|ReformatVocab|ImportFile|EditReference|LinkToPreviousElement|OpenInAcrobat|" . list
      if (Vim.SM.IsPassive(, -1))
        list := "ReformatScriptComponent|SearchLinkInYT|" . list
      if (Vim.SM.IsEditingText())
        list := "ClozeAndDone!|" . list
      if (Vim.SM.IsEditingHTML())
        list := "MakeHTMLUnique|" . list
    }
  } else if (WinActive("ahk_class TBrowser")) {  ; SuperMemo browser
    list := "MemoriseCurrentBrowser|SetBrowserPosition|MassReplaceRef|" . list
  } else if (WinActive("ahk_group Browser")) {  ; web browsers
    list := "IWBPriorityAndConcept|IWBNewTopic|" . list
  } else if (WinActive("ahk_class TPlanDlg")) {  ; SuperMemo Plan window
    list := "SetPlanPosition|" . list
  } else if (WinActive("ahk_class TRegistryForm")) {  ; SuperMemo Registry window
    list := "MassReplaceReg|" . list
  } else if (WinActive("Google Drive error list ahk_exe GoogleDriveFS.exe")) {  ; Google Drive errors
    list := "RetryAllSyncErrors|" . list
  }

  Gui, VimCommander:Add, Combobox, vCommand gAutoComplete w144, % list
  Gui, VimCommander:Add, Button, default, &Execute
  Gui, VimCommander:Show,, Vim Commander
  Gui, VimCommander:+HwndCommanderHwnd
Return

VimCommanderGuiEscape:
VimCommanderGuiClose:
  Gui, Destroy
return

VimCommanderButtonExecute:
  Gui, Submit
  Gui, Destroy
  if (IfContains("|" . list . "|", "|" . command . "|")) {
    Vim.State.SetMode("Insert")
    WinActivate % "ahk_id " . hWnd
    goto % RegExReplace(command, "\W")
  } else {
    if (IsUrl(command)) {
      run % command
    } else {
      run % "https://www.google.com/search?q=" . EncodeDecodeURI(command)
    }
  }
return

FindSearch(title, prompt, text:="") {
  if (!Default := trim(Copy()))
    Default := text ? text : Clipboard
  ret := InputBox(title, prompt,,,,,,,, Default)
  ; If the user closed the input box without submitting, return nothing
  return ErrorLevel ? "" : ret
}

WindowSpy:
  run C:\Program Files\AutoHotkey\WindowSpy.ahk
return

WebSearch:
  search := trim(Copy())
  Gui, WebSearch:Add, Text,, &Search:
  Gui, WebSearch:Add, Edit, vSearch w136 r1 -WantReturn, % search
  Gui, WebSearch:Add, Text,, &Language Code:
  list := "en||es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr"
  Gui, WebSearch:Add, Combobox, vLangCode gAutoComplete w136, % list
  Gui, WebSearch:Add, Button, default, &Search
  Gui, WebSearch:Show,, Google Define
  SetDefaultKeyboard(0x0409)  ; English-US
Return

WebSearchGuiEscape:
WebSearchGuiClose:
  Gui, Destroy
return

WebSearchButtonSearch:
  Gui, Submit
  Gui, Destroy
  if (IsUrl(search)) {
    run % search
  } else {
    run % "https://www.google.com/search?hl=" . LangCode . "&q=" . EncodeDecodeURI(search)
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

WaybackMachine:
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  if (url := FindSearch("Wayback Machine", "URL:", uiaBrowser.GetCurrentURL()))
    run % "https://web.archive.org/web/*/" . url
return

DeepL:
  if (text := FindSearch("DeepL Translate", "Text:"))
    run % "https://www.deepl.com/en/translator#?/en/" . text
Return

YouGlish:
  search := trim(Copy())
  Gui, YouGlish:Add, Text,, &Search:
  Gui, YouGlish:Add, Edit, vSearch w136 r1 -WantReturn, % search
  Gui, YouGlish:Add, Text,, &Language:
  list := "English||Spanish|French|Italian|Japanese|German|Russian|Greek|Hebrew"
        . "|Arabic|Polish|Portuguese|Korean|Turkish|American Sign Language|Dutch"
  Gui, YouGlish:Add, Combobox, vLanguage gAutoComplete w136, % list
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
  run % "https://youglish.com/pronounce/" . search . "/" . StrLower(language)
Return

KillIE:
  while (WinExist("ahk_exe iexplore.exe"))
    process, close, iexplore.exe
return

DefineGoogle:
  search := trim(Copy())
  Gui, GoogleDefine:Add, Text,, &Search:
  Gui, GoogleDefine:Add, Edit, vSearch w136 r1 -WantReturn, % search
  Gui, GoogleDefine:Add, Text,, &Language Code:
  list := "en||es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr"
  Gui, GoogleDefine:Add, Combobox, vLangCode gAutoComplete w136, % list
  Gui, GoogleDefine:Add, Button, default, &Search
  Gui, GoogleDefine:Show,, Google Define
  SetDefaultKeyboard(0x0409)  ; English-US
Return

GoogleDefineGuiEscape:
GoogleDefineGuiClose:
  Gui, Destroy
return

GoogleDefineButtonSearch:
  Gui, Submit
  Gui, Destroy
  if (LangCode) {
    define := "define", add := ""
    if (LangCode = "fr") {
      define := "définis"
    } else if (LangCode = "it") {
      define := "definisci"
    } else if (LangCode = "en") {
      LangCode := "en-uk", add := "&gl=gb"
    }
    run % "https://www.google.com/search?hl=" . LangCode . "&q=" . define . " "
        . search . "&forcedict=" . search . "&dictcorpus=" . LangCode . "&expnd=1" . add
  } else {
    run % "https://www.google.com/search?q=define " . search
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

Wiktionary:
  search := trim(Copy())
  Gui, Wiktionary:Add, Text,, &Search:
  Gui, Wiktionary:Add, Edit, vSearch w136 r1 -WantReturn, % search
  Gui, Wiktionary:Add, Text,, &Language:
  list := "Spanish||English|French|Italian|Japanese|German|Russian|Greek|Hebrew"
        . "|Arabic|Polish|Portuguese|Korean|Turkish|Latin|Ancient Greek|Chinese"
  Gui, Wiktionary:Add, Combobox, vLanguage gAutoComplete w136, % list
  Gui, Wiktionary:Add, Button, default, &Search
  Gui, Wiktionary:Show,, Wiktionary
return

WiktionaryGuiEscape:
WiktionaryGuiClose:
  Gui, Destroy
return

WiktionaryButtonSearch:
  Gui, Submit
  Gui, Destroy
  if (language == "Ancient Greek")
    language := "Ancient_Greek"
  if (language == "Latin") {
    search := StrReplace(search, "ā", "a")
    search := StrReplace(search, "ē", "e")
    search := StrReplace(search, "ī", "i")
    search := StrReplace(search, "ū", "u")
    search := StrReplace(search, "ō", "o")
  }
  run % "https://en.wiktionary.org/wiki/" . search . "#" . language
return

CopyTitle:
  ToolTip("Copied " . Clipboard := WinGetTitle("A"))
return

CopyHTML:
  ClipSaved := ClipboardAll
  if (!Clipboard := Copy(false, true))
    goto RestoreClipReturn
  ToolTip("Copying successful.")
return

Forvo:
  if (search := FindSearch("Forvo", "Word/phrase:"))
    run % "http://forvo.com/search/" . search . "/"
return

SetConceptHook:
  if (WinActive("ahk_class TElWind")) {
    send !c
    WinWaitActive, ahk_class TContents
  }
  if (ControlGetFocus("A") == "TVTEdit1")
    send {enter}
  ControlFocusWait("TVirtualStringTree1", "A")
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
  if (text := FindSearch("Google Translate", "Text:"))
    run % "https://translate.google.com/?sl=auto&tl=en&text=" . text . "&op=translate"
return

ClearClipboard:
  run % ComSpec . " /c echo off | clip"
return

MemoriseChildren:
  send ^{space}
  Vim.SM.WaitBrowser()
  goto MemoriseCurrentBrowser
return

MemoriseCurrentBrowser:
  send {AppsKey}cn  ; find pending elements
  Vim.SM.WaitBrowser()
  send {AppsKey}ple  ; remember
return

Forcellini:
  if (word := FindSearch("Forcellini", "Word:"))
    run % "http://lexica.linguax.com/forc2.php?searchedLG=" . word
return

RAE:
  if (word := FindSearch("RAE", "Word:"))
    run % "https://dle.rae.es/" . word . "?m=form"
return

OALD:
  if (word := FindSearch("Oxford Advanced Learner's Dictionary", "Word:"))
    run % "https://www.oxfordlearnersdictionaries.com/definition/english/" . word . "?q=" . word
return

AlatiusLatinMacronizer:
  if (!Latin := FindSearch("Alatius: a Latin macronizer", "Latin:"))
    return
  run https://alatius.com/macronizer/
  WinWaitActive, ahk_group Browser
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  uiaBrowser.WaitPageLoad()
  uiaBrowser.WaitElementExist("ControlType=Edit AND FrameworkId=Chrome").SetValue(Latin)
  uiaBrowser.WaitElementExist("ControlType=Button AND Name='Submit'").Click()
return

SetBrowserPosition:
  WinMove, ahk_class TBrowser,, 0, 0, 846, 680
return

; Personal: reformat my old incremental video topics
ReformatScriptComponent:
  ClipSaved := ClipboardAll
  WinWaitActive, ahk_class TElWind
  if (ContLearn := Vim.SM.IsLearning())
    send !g
  Vim.SM.ExitText()
  WinClip.Clear()
  send ^a^x
  ClipWait
  aOriginalText := StrSplit(Clipboard, "`n`r")
  Vim.Browser.Url := trim(aOriginalText[1], " `r`n"), Vim.Browser.Title := WinGetTitle("A")
  Vim.Browser.VidTime := trim(aOriginalText[2], " `r`n")
  if (IfContains(Vim.Browser.Url, "youtube.com")) {
    YTTime := Vim.Browser.VidTime ? "&t=" . Vim.Browser.GetSecFromTime(Vim.Browser.VidTime) . "s" : ""
    Vim.Browser.Source := "YouTube"
    if (YTTime) {
      send ^t{f9}  ; opens script editor
      WinWaitActive, ahk_class TScriptEditor
      ControlSetText, TMemo1, % ControlGetText("TMemo1", "A") . YTTime, A
      send !o{esc}  ; close script editor
    }
  } else {
    Vim.Browser.Title := Vim.Browser.VidTime . " | " . Vim.Browser.Title
  }
  WinClip.Clear()
  Clipboard := Vim.Browser.Url
  ClipWait
  gosub SMSetLinkFromClipboard
  send {esc}
  if (ContLearn)
    Vim.SM.Learn()
  Clipboard := ClipSaved
  Vim.Browser.Clear(), Vim.State.SetMode("Vim_Normal")
return

CopyWindowPosition:
  WinGetPos, x, y, w, h, A
  ToolTip("Copied " . Clipboard := "Window's position: x = " . x . " y = " . y . " w = " . w . " h = " . h)
return

MassReplaceRef:
  find := ""
  replacement := ""
  if (!find && !replacement)
    return
  loop {
    WinActivate, ahk_class TElWind
    Vim.SM.WaitFileLoad()
    Vim.SM.EditRef()
    WinWaitActive, ahk_class TInputDlg
    if (IfContains(ref := ControlGetText("TMemo1", "A"), find)) {
      ControlSetText, TMemo1, % StrReplace(ref, find, replacement), A
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
  if (!text := FindSearch("Sci-Hub", "Search:"))
    return
  if (RegExMatch(text, "https:\/\/doi\.org\/([^ ]+)", v)) {
    run % "https://sci-hub.hkvisa.net/" . v1
  ; https://www.crossref.org/blog/dois-and-matching-regular-expressions/
  } else if (RegExMatch(text, "i)10.\d{4,9}/[-._;()/:A-Z0-9]+", v)) {
    run % "https://sci-hub.hkvisa.net/" . v
  } else {
    run https://sci-hub.hkvisa.net/
    WinWaitActive, ahk_group Browser
    uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
    uiaBrowser.WaitPageLoad()
    el := uiaBrowser.WaitElementExist("ControlType=Edit AND Name='enter URL, PMID / DOI or search string'")
    el.GetCurrentPatternAs("Value").SetValue(text)
    uiaBrowser.WaitElementExist("ControlType=Text AND Name='open'").Click()
  }
return

YT:
  if (text := FindSearch("YouTube", "Search:"))
    run % "https://www.youtube.com/results?search_query=" . EncodeDecodeURI(text)
return

; Personal: reformat my old vocabulary items
ReformatVocab:
  Vim.State.SetMode("Vim_Normal")
  ClipSaved := ClipboardAll
  Vim.SM.EditFirstQuestion()
  if (!Vim.SM.WaitTextFocus(1000))
    return
  send ^a
  if (!data := Copy(false, true))
    goto RestoreClipReturn
  data := StrLower(SubStr(data, 1, 1)) . SubStr(data, 2)  ; make the first letter lower case
  data := RegExReplace(data, "(\.<BR>""|\. ?<BR>(\r\n<P><\/P>)?\r\n<P>‘)", "<P>")
  data := RegExReplace(data, "(""|\.?’)", "</P>")
  data := StrReplace(data, "<P></P>")
  SynPos := RegExMatch(data, "<(P|BR)>(Similar|Synonyms)")
  def := SubStr(data, 1, SynPos - 1)
  SynAndAnt := SubStr(data, SynPos)
  SynAndAnt := StrReplace(SynAndAnt, "; ", ", ")
  SynAndAnt := RegExReplace(SynAndAnt, "(<BR>)?(\n)?((Similar:?)<BR>|Synonyms ?(\r\n)?(<\/P>\r\n<P>|<BR>))", "<P>syn: ")
  SynAndAnt := RegExReplace(SynAndAnt, "(Opposite:?|Opuesta)<BR>", "ant: ")
  WinClip.Paste(def . SynAndAnt,, false)
  send ^a^+1
  Clipboard := ClipSaved
return

ZLibrary:
  if (!text := FindSearch("Z-Library", "Search:"))
    return
  ; RIP z-lib
  ; run https://z-lib.org/
  run % "https://lib-rc5t5df46yl4ghwlnyuzt52y.mountain.pm/s/?q=" . text

  ; Telegram
  ; run https://web.telegram.org/z/#1788460589

  ; WinWaitActive, ahk_group Browser
  ; uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  ; uiaBrowser.WaitPageLoad()

  ; RIP z-lib
  ; url := uiaBrowser.WaitElementExist("ControlType=Hyperlink AND Name='Books'").CurrentValue
  ; uiaBrowser.SetURL(url . "s/" . EncodeDecodeURI(search) . "?", true)

  ; Telegram
  ; uiaBrowser.WaitElementExist("ControlType=Edit AND Name='Message' AND AutomationId='editable-message-text'") ; SetValue(text) doesn't work
  ; send {tab}
  ; send % "{text}" . text
  ; if (uiaBrowser.WaitElementNotExist("ControlType=Text AND Name='waiting for network|updating'",, "regex",, 2000)) {
  ;   uiaBrowser.FindFirstBy("ControlType=Button AND Name='Send Message'").Click()
  ; } else {
  ;   ToolTip("Timed out.")
  ; }
return

ImportFile:
  Vim.State.SetMode("Vim_Normal")
  send ^+p
  WinWaitActive, ahk_class TElParamDlg
  send !t
  send {text}binary  ; my template for pdf/epub file is binary
  send {enter 2}
  WinWaitActive, ahk_class TElWind
  Vim.SM.InvokeFileBrowser()
  send {right}
  MsgBox, 3,, Do you want to also delete the file?
  IfMsgBox, Cancel
    return
  if (KeepFile := IfMsgBox("No"))
    FilePath := WinGetTitle("ahk_class TFileBrowser")
  WinActivate, ahk_class TFileBrowser
  send {enter}
  WinWaitActive, ahk_class TInputDlg
  send {enter}
  WinWaitActive, ahk_class TMsgDialog
  if (!KeepFile) {
    send {text}n  ; not keeping the file in original position
    WinWaitClose
    WinWaitActive, ahk_class TMsgDialog
  }
  send {text}y  ; confirm to delete the file / confirm to keep the file
  WinWaitActive, ahk_class TElWind
  Vim.SM.Reload()
  if (KeepFile) {
    MsgBox, 3,, Do you want to add "IMPORTED_" prefix to the file?
    if (IfMsgBox("Yes")) {
      RegExMatch(FilePath, "[^\\]+(?=\.)", FileName)
      FileMove, % FilePath, % StrReplace(FilePath, FileName, "IMPORTED_" . FileName)
    }
  }
  if (!Vim.SM.AskPrio())
    return
return

ScriptSettings:
  Vim.Setting.ShowGui()
return

Bilibili:
  if (search := FindSearch("Bilibili", "Search:"))
    run % "https://search.bilibili.com/all?keyword=" . search
return

Libgen:
  if (search := FindSearch("Library Genesis", "Search:"))
    ; run % "http://libgen.is/search.php?req=" . search . "&lg_topic=libgen&open=0&view=simple&res=25&phrase=1&column=def"
    run % "https://libgen.li/index.php?req=" . search . "&columns%5B%5D=t&columns%5B%5D=a&columns%5B%5D=s&columns%5B%5D=y&columns%5B%5D=p&columns%5B%5D=i&objects%5B%5D=f&objects%5B%5D=e&objects%5B%5D=s&objects%5B%5D=a&objects%5B%5D=p&objects%5B%5D=w&topics%5B%5D=l&topics%5B%5D=c&topics%5B%5D=f&topics%5B%5D=a&topics%5B%5D=m&topics%5B%5D=r&topics%5B%5D=s&res=25&filesuns=all"
return

ImageGoogle:
  if (search := FindSearch("Image (Google)", "Search:"))
    run % "https://www.google.com/search?hl=en&tbm=isch&q=" . search
return

SearchLinkInYT:
  if (!link := Vim.SM.GetLink()) {
    Vim.SM.EditFirstQuestion()
    Vim.SM.WaitTextFocus()
    send ^{home}+{right}
    RegExMatch(Copy(, true), "(<A((.|\r\n)*)href="")\K[^""]+", link)
    send {esc}
  }
  SMTitle := WinGetTitle("ahk_class TElWind")
  if (link) {
    run % "https://www.youtube.com/results?search_query=" . EncodeDecodeURI(SMTitle)
    WinWaitActive, ahk_group Browser
    uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
    uiaBrowser.WaitPageLoad()
    uiaBrowser.WaitElementExist("ControlType=Text AND Name='Filters'")  ; wait till page is fully loaded
    auiaLinks := uiaBrowser.FindAllByType("Hyperlink")
    for i, v in auiaLinks {
      if (IfContains(v.CurrentValue, link)) {
        v.click()
        return
      }
    }
  } else {
    ToolTip("Not found.")
  }
return

WatchLaterYT:
  run https://www.youtube.com/playlist?list=WL
return

EditReference:
  Vim.SM.ElMenu()
  Send fe
Return

GetInfoFromContextMenu:
  run % A_ScriptDir . "\lib\util\Get Info from Context Menu.ahk"
return

GenerateTimeString:
  send % "{text}" . FormatTime(, "yyyyMMddHHmmss" . A_MSec)
return

BingChat:
  ClipSaved := link := "", wEdge := WinActive("ahk_exe msedge.exe"), ext := ".htm"
  if (WinActive("ahk_class TElWind")) {
    if (Vim.SM.IsBrowsing()) {
      link := Vim.SM.GetLink()
    } else if (Vim.SM.IsEditingText()) {
      link := Vim.SM.GetFilePath()
    }
  } else if (!wEdge && (w := WinActive("ahk_group Browser"))) {
    uiaBrowser := new UIA_Browser("ahk_id " . w)
    link := uiaBrowser.GetCurrentURL()
  } else {
    ClipSaved := ClipboardAll
    if (!text := Copy(false, true))
      text := Clipboard, ext := ".txt"
    if (text) {
      CurrTime := FormatTime(, "yyyy-MM-dd_HH:mm:ss:" . A_MSec)
      link := A_Temp . "\" . StrReplace(CurrTime, ":") . ext
      FileDelete % link
      FileAppend, % text, % link
    }
  }
  if (text || !wEdge) {
    run % "msedge.exe " . link
    WinWaitActive, ahk_exe msedge.exe
  }
  send ^+.
  ; UIA := UIA_Interface()
  ; el := UIA.ElementFromHandle(WinExist("ahk_exe msedge.exe"))
  ; el.WaitElementExist("ControlType=Button AND Name='^Discover'",, "regex").Click()
  if (ClipSaved)
    Clipboard := ClipSaved
return 

LinkToPreviousElement:
  send !c
  WinWaitActive, ahk_class TContents
  WinActivate, ahk_class TElWind
  Vim.SM.GoBack()
  Vim.SM.WaitFileLoad()
  Vim.SM.ElMenu()
  send ci  ; link contents
  WinWaitActive, ahk_class TContents
  sleep 100
  send {enter}
  WinActivate, ahk_class TElWind
  Goto, SMListLinks
return

AlwaysOnTop:
  WinSet, AlwaysOnTop, Toggle, A
return

OpenInAcrobat:
  send q^{t}{f9}
  if (path := Vim.SM.GetFilePath())
    run % "acrobat.exe " . path
return

Larousse:
  if (word := FindSearch("Larousse", "Word:"))
    run % "https://www.larousse.fr/dictionnaires/francais/" . word
return

GraecoLatinum:
  if (word := FindSearch("Graeco-Latinum", "Word:")) {
    run % "http://lexica.linguax.com/nlm.php?searchedGL=" . word
    run % "http://lexica.linguax.com/schrevel.php?searchedGL=" . word
  }
return

Linguee:
  if (word := FindSearch("Linguee", "Word:"))
    run % "https://www.linguee.com/search?query=" . word
return

MerriamWebster:
  if (word := FindSearch("Merriam-Webster", "Word:"))
    run % "https://www.merriam-webster.com/dictionary/" . word
return

WordSense:
  if (word := FindSearch("WordSense", "Word:"))
    run % "https://www.wordsense.eu/" . word . "/"
return

SetPlanPosition:
  WinGetPos, x, y, w, h, ahk_class TElWind
  WinMove, ahk_class TPlanDlg,, x, y, w, h
return

MakeHTMLUnique:
  ClipSaved := ClipboardAll
  Vim.SM.MoveToLast(false)
  AntiMerge := "<SPAN class=anti-merge>HTML made unique at " . GetDetailedTime() . "</SPAN>"
  Clip(AntiMerge,, false, "sm")
  Clipboard := ClipSaved
return

KillOutlook:
  process, close, Outlook.exe
return

RestartOneDrive:
  process, close, OneDrive.exe
  run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk
  WinWait, OneDrive ahk_class CabinetWClass ahk_exe explorer.exe
  WinClose
  WinActivate, % "ahk_id " . hWnd
return

RestartICloudDrive:
  process, close, iCloudDrive.exe
  process, close, iCloudServices.exe
  run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\iCloud\iCloud.lnk
  WinWait, iCloud ahk_class PreferencesWnd ahk_exe iCloud.exe
  WinClose
return

CalculateTodaysPassRate:
  ToolTip("Executing...", true)
  BlockInput, on
  Vim.SM.PostMsg(31)  ; export rep history
  WinWaitActive, ahk_class TFileBrowser
  TempPath := A_Temp . "\Repetition History_" . Vim.SM.GetCollName() . "_"
            . GetCurrTimeForFileName() ".txt"
  Vim.SM.FileBrowserSetPath(TempPath, true)
  WinWaitActive, Information ahk_class TMsgDialog
  send {enter}
  RepHistory := FileRead(TempPath)
  date := "Date=" . FormatTime(, "dd.MM.yyyy")
  dateRegEx := "Date=" . FormatTime(, "dd\.MM\.yyyy")
  StrReplace(RepHistory, date,, TodayRepCount)
  RegExReplace(RepHistory, dateRegEx . ".*?Grade=[3-5]",, TodayPassCount)
  BlockInput, off
  RemoveToolTip()
  msgbox % "Today's rep count: " . TodayRepCount
         . "`nToday's pass (grade > 3) count: " . TodayPassCount
         . "`nToday's pass rate: " . ForMat("{:g}", TodayPassCount / TodayRepCount * 100) . "%"
return

PerplexityAI:
  if (!search := FindSearch("Perplexity AI", "Search:"))
    return
  run https://www.perplexity.ai/
  WinWaitActive, ahk_group Browser
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  uiaBrowser.WaitPageLoad()
  uiaBrowser.WaitElementExist("ControlType=Edit AND Name='Ask anything...'").SetValue(search)
return

RetryAllSyncErrors:
  UIA := UIA_Interface()
  el := UIA.ElementFromHandle(WinActive("A"))
  while (dot := el.FindFirstBy("ControlType=MenuItem AND Name='More options menu icon'")) {
    dot.Click()
    el.FindFirstBy("ControlType=MenuItem AND Name='Retry' AND AutomationId='retry-id'").Click()
    sleep 100
    if (el.FindFirstBy("ControlType=Text AND Name='Looks fine'"))
      break
  }
  ToolTip("Finished.")
return

MassReplaceReg:
  find := ""
  replacement := ""
  if (!find && !replacement)
    return
  ; ControlSend, Edit1, % "{text}" . find, A
  loop {
    send !r
    WinWaitActive, ahk_class TInputDlg
    text := ControlGetText("TMemo1", "")
    if !(text ~= "^" . find)
      return
    RegExMatch(text, "^" . find . "\K(.*?)(#.*$)", v)
    if (v && !IfContains(v1, "%,:")) {
      NewText := "https://en.wiktionary.org/wiki/" . EncodeDecodeURI(v1) . v2
      if (IfContains(v1, "%") || (text != NewText))
        ControlSetText, TMemo1, % NewText
    }
    send !{enter}
    WinWaitActive, ahk_class TRegistryForm
    send {f3}
    WinWaitActive, ahk_class TProgressBox,, 0
    if (!ErrorLevel)
      WinWaitActive, ahk_class TRegistryForm
  }
return
