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
        . "|Bilibili|AlwaysOnTop|Larousse|GraecoLatinum|LatinoGraecum|Linguee"
        . "|MerriamWebster|WordSense|RestartOneDrive|RestartICloudDrive|KillIE"
        . "|PerplexityAI|Lexico|Tatoeba|MD2HTML|CleanHTML|EPUB2TXT"
        . "|PasteCleanedClipboard|ArchiveToday|WolframAlpha"

  if (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) {
    list := "SetConceptHook|MemoriseChildren|" . list
    if (WinActive("ahk_class TElWind")) {
      list := "NukeHTML|ReformatVocab|ImportFile|EditReference|LinkToPreviousElement"
            . "|OpenInAcrobat|CalculateTodaysPassRate|AllLapsesToday"
            . "|ExternaliseRegistry|Comment|" . list
      if (Vim.SM.IsPassive(, -1))
        list := "ReformatScriptComponent|SearchLinkInYT|" . list
      if (Vim.SM.IsEditingText())
        list := "ClozeAndDone!|" . list
      if (Vim.SM.IsEditingHTML())
        list := "MakeHTMLUnique|CenterTexts|AlignTextsRight|AlignTextsLeft|ItalicText"
              . "|UnderscoreText|BoldText|" . list
    }
  } else if (WinActive("ahk_class TBrowser")) {  ; SuperMemo browser
    list := "MemoriseCurrentBrowser|SetBrowserPosition|MassReplaceReference"
          . "|MassProcessBrowser|" . list
  } else if (WinActive("ahk_group Browser")) {  ; web browsers
    list := "IWBPriorityAndConcept|IWBNewTopic|SaveFile|" . list
  } else if (WinActive("ahk_class TPlanDlg")) {  ; SuperMemo Plan window
    list := "SetPlanPosition|" . list
  } else if (WinActive("ahk_class TRegistryForm")) {  ; SuperMemo Registry window
    list := "MassReplaceRegistry|MassProcessRegistry|" . list
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
    Goto % RegExReplace(command, "\W")
  } else {
    if (IsUrl(command)) {
      if !(command ~= "^http")
        command := "http://" . command
      ShellRun(command)
    } else {
      ShellRun("https://www.google.com/search?q=" . EncodeDecodeURI(command))
    }
  }
return

FindSearch(Title, Prompt, Text:="", ForceText:=false) {
  if (!ForceText && (!Text := Trim(Copy())))
    Text := Text ? Text : Clipboard
  ret := InputBox(Title, Prompt,,,,,,,, Text)
  ; If the user closed the input box without submitting, return nothing
  return ErrorLevel ? "" : ret
}

WindowSpy:
  ShellRun("C:\Program Files\AutoHotkey\WindowSpy.ahk")
return

WebSearch:
  Search := Trim(Copy())
  Gui, WebSearch:Add, Text,, &Search:
  Gui, WebSearch:Add, Edit, vSearch w136 r1 -WantReturn, % Search
  Gui, WebSearch:Add, Text,, &Language Code:
  List := "en||es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr|zh-hk|zh"
  Gui, WebSearch:Add, Combobox, vLangCode gAutoComplete w136, % List
  Gui, WebSearch:Add, Button, Default, &Search
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
  if (DoesTextContainUrl(Search, v)) {
    MsgBox, 3,, Text has url. Run it?
    if (IfMsgBox("Yes")) {
      ShellRun(v)
      return
    }
  }
  if (IsUrl(Search)) {
    if !(Search ~= "^http")
      Search := "http://" . Search
    ShellRun(Search)
  } else {
    ShellRun("https://www.google.com/search?hl=" . LangCode . "&q=" . EncodeDecodeURI(Search))
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
  WinWaitActive % "ahk_id " . hWnd
  if (WinActive("ahk_group Browser")) {
    uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
    url := FindSearch("Wayback Machine", "URL:", uiaBrowser.GetCurrentURL())
  } else if (WinActive("ahk_class TElWind")) {
    url := FindSearch("Wayback Machine", "URL:", Vim.SM.GetLink(), true)
  } else if (!url := FindSearch("Wayback Machine", "URL:")) {
    return
  }
  if (url)
    ShellRun("https://web.archive.org/web/*/" . url)
return

DeepL:
  if (text := FindSearch("DeepL Translate", "Text:"))
    ShellRun("https://www.deepl.com/en/translator#?/en/" . text)
Return

YouGlish:
  search := Trim(Copy())
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
  ShellRun("https://youglish.com/pronounce/" . search . "/" . StrLower(language))
Return

KillIE:
  while (WinExist("ahk_exe iexplore.exe"))
    process, close, iexplore.exe
return

DefineGoogle:
  search := Trim(Copy())
  Gui, GoogleDefine:Add, Text,, &Search:
  Gui, GoogleDefine:Add, Edit, vSearch w136 r1 -WantReturn, % search
  Gui, GoogleDefine:Add, Text,, &Language Code:
  list := "en-uk||en-us|es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr|zh-hk|zh"
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
    } else if (LangCode = "en-uk") {
      add := "&gl=gb"
    } else if (LangCode = "en-us") {
      add := "&gl=us"
    }
    ShellRun("https://www.google.com/search?hl=" . LangCode . "&q=" . define . " "
           . search . "&forcedict=" . search . "&dictcorpus=" . LangCode . "&expnd=1" . add)
  } else {
    ShellRun("https://www.google.com/search?q=define " . search)
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
  Word := Trim(Copy())
  Gui, Wiktionary:Add, Text,, &Word:
  Gui, Wiktionary:Add, Edit, vWord w136 r1 -WantReturn, % Word
  Gui, Wiktionary:Add, Text,, &Language:
  List := "Spanish||English|French|Italian|Japanese|German|Russian|Greek|Hebrew"
        . "|Arabic|Polish|Portuguese|Korean|Turkish|Latin|Ancient Greek|Chinese"
        . "|Catalan"
  Gui, Wiktionary:Add, Combobox, vLanguage gAutoComplete w136, % List
  Gui, Wiktionary:Add, Checkbox, vGoogle, &Google
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
  if (Google) {
    ShellRun("https://www.google.com/search?hl=en&q=Wiktionary " . Language . " " . EncodeDecodeURI(word))
  } else {
    if (Language == "Ancient Greek")
      Language := "Ancient_Greek"
    if (Language == "Latin")
      word := RemoveLatinMacrons(word)
    ShellRun("https://en.wiktionary.org/wiki/" . Word . "#" . Language)
  }
return

CopyTitle:
  ToolTip("Copied " . Clipboard := WinGetTitle("A"))
return

CopyHTML:
  ClipSaved := ClipboardAll
  if (!Clipboard := Copy(false, true))
    Goto RestoreClipReturn
  ToolTip("Copying successful.")
return

Forvo:
  Word := Trim(Copy())
  Gui, Forvo:Add, Text,, &Word:
  Gui, Forvo:Add, Edit, vWord w136 r1 -WantReturn, % Word
  Gui, Forvo:Add, Text,, &Language Code:
  List := "en||es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr"
  Gui, Forvo:Add, Combobox, vLangCode gAutoComplete w136, % List
  Gui, Forvo:Add, Button, Default, &Search
  Gui, Forvo:Show,, Forvo
  SetDefaultKeyboard(0x0409)  ; English-US
Return

ForvoGuiEscape:
ForvoGuiClose:
  Gui, Destroy
return

ForvoButtonSearch:
  Gui, Submit
  Gui, Destroy
  ShellRun("http://forvo.com/word/" . Word . "/#" . LangCode)
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
  ToolTip("Hook set."), Vim.State.SetMode("Vim_Normal")
Return

AccViewer:
  ShellRun(A_ScriptDir . "\lib\util\AccViewer Source.ahk")
return

UIAViewer:
  ShellRun(A_ScriptDir . "\lib\util\UIAViewer.ahk")
return

TranslateGoogle:
  if (text := FindSearch("Google Translate", "Text:"))
    ShellRun("https://translate.google.com/?sl=auto&tl=en&text=" . text . "&op=translate")
return

ClearClipboard:
  run % ComSpec . " /c echo off | clip"
return

MemoriseChildren:
  Vim.SM.OpenBrowser()
  Vim.SM.WaitBrowser()
  Goto MemoriseCurrentBrowser
return

MemoriseCurrentBrowser:
  send {AppsKey}cn  ; find pending elements
  Vim.SM.WaitBrowser()
  send {AppsKey}ple  ; remember
return

Forcellini:
  if (word := FindSearch("Forcellini", "Word:"))
    ShellRun("http://lexica.linguax.com/forc2.php?searchedLG=" . RemoveLatinMacrons(word))
return

RAE:
  if (word := FindSearch("RAE", "Word:"))
    ShellRun("https://dle.rae.es/" . word . "?m=form")
return

OALD:
  if (word := FindSearch("Oxford Advanced Learner's Dictionary", "Word:"))
    ShellRun("https://www.oxfordlearnersdictionaries.com/definition/english/" . word)
return

AlatiusLatinMacronizer:
  if (!Latin := FindSearch("Alatius: a Latin macronizer", "Latin:"))
    return
  ShellRun("https://alatius.com/macronizer/")
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
  Vim.Browser.Url := Trim(aOriginalText[1], " `r`n"), Vim.Browser.Title := WinGetTitle("A")
  Vim.Browser.VidTime := Trim(aOriginalText[2], " `r`n")
  if (IfContains(Vim.Browser.Url, "youtube.com")) {
    YTTime := Vim.Browser.VidTime ? "&t=" . Vim.Browser.GetSecFromTime(Vim.Browser.VidTime) . "s" : ""
    Vim.Browser.Source := "YouTube"
    if (YTTime) {
      send ^t{f9}  ; opens script editor
      WinWaitActive, ahk_class TScriptEditor
      ControlSetText, TMemo1, % ControlGetText("TMemo1", "A") . YTTime
      send !o{esc}  ; close script editor
    }
  } else {
    Vim.Browser.Title := Vim.Browser.VidTime . " | " . Vim.Browser.Title
  }
  WinClip.Clear()
  Clipboard := Vim.Browser.Url
  ClipWait
  Gosub SMSetLinkFromClipboard
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

MassReplaceReference:
  find := ""
  replacement := ""
  if (!find && !replacement)
    return
  loop {
    WinActivate, ahk_class TElWind
    Vim.SM.WaitFileLoad()
    Vim.SM.EditRef()
    WinWaitActive, ahk_class TInputDlg
    if (IfContains(ref := ControlGetText("TMemo1"), find)) {
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
  if (!text := FindSearch("Sci-Hub", "Search:"))
    return
  if (RegExMatch(text, "https:\/\/doi\.org\/([^ ]+)", v)) {
    ShellRun("https://sci-hub.hkvisa.net/" . v1)
  ; https://www.crossref.org/blog/dois-and-matching-regular-expressions/
  } else if (RegExMatch(text, "i)10.\d{4,9}/[-._;()/:A-Z0-9]+", v)) {
    ShellRun("https://sci-hub.hkvisa.net/" . v)
  } else {
    ShellRun("https://sci-hub.hkvisa.net/")
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
    ShellRun("https://www.youtube.com/results?search_query=" . EncodeDecodeURI(text))
return

; Personal: reformat my old vocabulary items
ReformatVocab:
  Vim.State.SetMode("Vim_Normal")
  if (!Vim.SM.DoesTextExist())
    return
  ClipSaved := ClipboardAll
  Vim.SM.EditFirstQuestion()
  if (!Vim.SM.WaitTextFocus())
    return
  send ^a
  if (!data := Copy(false, true))
    Goto RestoreClipReturn
  data := StrLower(SubStr(data, 1, 1)) . SubStr(data, 2)  ; make the first letter lower case
  data := RegExReplace(data, "(\.<BR>""|(\. ?<BR>)?(\r\n<P><\/P>)?\r\n<P>‘|\. \r\n<P><\/P>)", "<P>")
  data := RegExReplace(data, "(""|\.?’)", "</P>")
  data := StrReplace(data, "<P></P>")
  SynPos := RegExMatch(data, "<(P|BR)>(Similar|Synonyms)")
  def := SubStr(data, 1, SynPos - 1)
  SynAndAnt := SubStr(data, SynPos)
  SynAndAnt := StrReplace(SynAndAnt, "; ", ", ")
  SynAndAnt := RegExReplace(SynAndAnt, "(<BR>)?(\n)?((Similar:?)<BR>|Synonyms ?(\r\n)?(<\/P>\r\n<P>|<BR>))", "<P>syn: ")
  SynAndAnt := RegExReplace(SynAndAnt, "(Opposite:?|Opuesta)<BR>", "ant: ")
  Clip(def . SynAndAnt,, false, "sm")
  Clipboard := ClipSaved
return

ZLibrary:
  if (!text := FindSearch("Z-Library", "Search:"))
    return
  ; RIP z-lib
  ; ShellRun("https://z-lib.org/")
  ; ShellRun("https://lib-rc5t5df46yl4ghwlnyuzt52y.mountain.pm/s/?q=" . text)
  ShellRun("https://singlelogin.re/s/?q=" . text)

  ; Telegram
  ; ShellRun("https://web.telegram.org/z/#1788460589")

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
  RegExMatch(FilePath, "[^\\]+(?=\.)", FileName)
  if (KeepFile && !(FileName ~= "^IMPORTED_")) {
    MsgBox, 3,, Do you want to add "IMPORTED_" prefix to the file?
    if (IfMsgBox("Yes"))
      FileMove, % FilePath, % StrReplace(FilePath, FileName, "IMPORTED_" . FileName)
  }
  Vim.SM.AskPrio()
return

ScriptSettings:
  Vim.Setting.ShowGui()
return

Bilibili:
  if (search := FindSearch("Bilibili", "Search:"))
    ShellRun("https://search.bilibili.com/all?keyword=" . search)
return

Libgen:
  if (search := FindSearch("Library Genesis", "Search:")) {
    ShellRun("http://libgen.is/search.php?req=" . search . "&lg_topic=libgen&open=0&view=simple&res=25&phrase=1&column=def")
    ShellRun("https://libgen.li/index.php?req=" . search . "&columns%5B%5D=t&columns%5B%5D=a&columns%5B%5D=s&columns%5B%5D=y&columns%5B%5D=p&columns%5B%5D=i&objects%5B%5D=f&objects%5B%5D=e&objects%5B%5D=s&objects%5B%5D=a&objects%5B%5D=p&objects%5B%5D=w&topics%5B%5D=l&topics%5B%5D=c&topics%5B%5D=f&topics%5B%5D=a&topics%5B%5D=m&topics%5B%5D=r&topics%5B%5D=s&res=25&filesuns=all")
  }
return

ImageGoogle:
  Search := Trim(Copy())
  Gui, ImageGoogle:Add, Text,, &Search:
  Gui, ImageGoogle:Add, Edit, vSearch w136 r1 -WantReturn, % Search
  Gui, ImageGoogle:Add, Text,, &Language Code:
  List := "en||es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr|zh-hk|zh"
  Gui, ImageGoogle:Add, Combobox, vLangCode gAutoComplete w136, % List
  Gui, ImageGoogle:Add, Button, Default, &Search
  Gui, ImageGoogle:Show,, Image (Google)
  SetDefaultKeyboard(0x0409)  ; English-US
Return

ImageGoogleGuiEscape:
ImageGoogleGuiClose:
  Gui, Destroy
return

ImageGoogleButtonSearch:
  Gui, Submit
  Gui, Destroy
  ShellRun("https://www.google.com/search?hl=" . LangCode . "&tbm=isch&q=" . search)
return

SearchLinkInYT:
  if ((!link := Vim.SM.GetLink()) && Vim.SM.DoesHTMLExist()) {
    Vim.SM.EditFirstQuestion()
    Vim.SM.WaitTextFocus()
    send ^{home}+{right}
    RegExMatch(Copy(, true), "(<A((.|\r\n)*)href="")\K[^""]+", link)
    send {esc}
  }
  if (link) {
    ShellRun("https://www.youtube.com/results?search_query=" . EncodeDecodeURI(WinGetTitle("ahk_class TElWind")))
    WinWaitActive, ahk_group Browser
    sleep 400
    uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
    uiaBrowser.WaitPageLoad()
    uiaBrowser.WaitElementExist("ControlType=Text AND Name='Filters'")  ; wait till page is fully loaded
    auiaLinks := uiaBrowser.FindAllByType("Hyperlink")
    link := RegExReplace(link, "https:\/\/(www\.)?")
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
  ShellRun("https://www.youtube.com/playlist?list=WL")
return

EditReference:
  Send !{f10}fe
Return

GetInfoFromContextMenu:
  ShellRun(A_ScriptDir . "\lib\util\Get Info from Context Menu.ahk")
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
      link := A_Temp . "\" . GetCurrTimeForFileName() . ext
      FileDelete % link
      FileAppend, % text, % link
    }
  }
  if (text || !wEdge) {
    ShellRun("msedge.exe " . link)
    WinWaitActive, ahk_exe msedge.exe
  }
  send ^+.
  if (ClipSaved)
    Clipboard := ClipSaved
return 

LinkToPreviousElement:
  send !c
  WinWaitActive, ahk_class TContents
  WinActivate, ahk_class TElWind
  Vim.SM.GoBack()
  Vim.SM.WaitFileLoad()
  send !{f10}ci  ; link contents
  WinWaitActive, ahk_class TContents
  send {enter}+{enter}
  Vim.SM.WaitFileLoad()
  WinWaitActive, ahk_class TElWind
  Goto SMListLinks
return

AlwaysOnTop:
  WinSet, AlwaysOnTop, Toggle, A
return

OpenInAcrobat:
  send q^{t}{f9}
  if (path := Vim.SM.GetFilePath())
    ShellRun("acrobat.exe", path)
return

Larousse:
  if (word := FindSearch("Larousse", "Word:"))
    ShellRun("https://www.larousse.fr/dictionnaires/francais/" . word)
return

GraecoLatinum:
  if (word := FindSearch("Graeco-Latinum", "Word:")) {
    ShellRun("http://lexica.linguax.com/nlm.php?searchedGL=" . word)
    ShellRun("http://lexica.linguax.com/schrevel.php?searchedGL=" . word)
  }
return

LatinoGraecum:
  if (word := FindSearch("Latino-Graecum", "Word:")) {
    ShellRun("http://lexica.linguax.com/nlm.php?searchedLG=" . word)
    ShellRun("http://lexica.linguax.com/schrevel.php?searchedLG=" . word)
  }
return

Linguee:
  if (word := FindSearch("Linguee", "Word:"))
    ShellRun("https://www.linguee.com/search?query=" . word)
return

MerriamWebster:
  if (word := FindSearch("Merriam-Webster", "Word:")) {
    ShellRun("https://www.merriam-webster.com/dictionary/" . word)
    ShellRun("https://www.britannica.com/dictionary/" . word)
  }
return

WordSense:
  if (word := FindSearch("WordSense", "Word:"))
    ShellRun("https://www.wordsense.eu/" . word . "/")
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
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
return

KillOutlook:
  process, close, Outlook.exe
return

RestartOneDrive:
  Process, Close, OneDrive.exe
  ShellRun("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk")
  WinWait, ahk_class CabinetWClass ahk_exe explorer.exe,, 10
  if (!ErrorLevel)
    WinClose
return

RestartICloudDrive:
  process, close, iCloudDrive.exe
  process, close, iCloudServices.exe
  ShellRun("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\iCloud\iCloud.lnk")
  WinWait, iCloud ahk_class PreferencesWnd ahk_exe iCloud.exe
  WinClose
return

CalculateTodaysPassRate:
  ToolTip("Executing...", true), pidSM := WinGet("PID", "ahk_class TElWind")
  BlockInput, on
  Vim.SM.PostMsg(31)  ; export rep history
  WinWaitActive, ahk_class TFileBrowser
  TempPath := A_Temp . "\Repetition History_" . Vim.SM.GetCollName() . "_"
            . GetCurrTimeForFileName() ".txt"
  Vim.SM.FileBrowserSetPath(TempPath, true)
  WinWaitActive % "Information ahk_class TMsgDialog ahk_pid " . pidSM
  send {enter}
  RepHistory := FileReadAndDelete(TempPath)
  DateRegEx := "Date=" . FormatTime(, "dd\.MM\.yyyy")
  RegExReplace(RepHistory, "s)\nItem #[\d,]+: [^\n]+\n[^\n]+" . DateRegEx
                         . "[^\n]+Grade=[0-5]",, TodayRepCount)
  RegExReplace(RepHistory, "s)\nItem #[\d,]+: [^\n]+\n[^\n]+" . DateRegEx
                         . "[^\n]+Grade=[3-5]",, TodayPassCount)
  BlockInput, off
  RemoveToolTip()
  msgbox % "Today's repetition count: " . TodayRepCount
         . "`nToday's pass (grade > 3) count: " . TodayPassCount
         . "`nToday's pass rate: " . Format("{:g}", TodayPassCount / TodayRepCount * 100) . "%"
return

PerplexityAI:
  search := Trim(Copy())
  Gui, PerplexityAI:Add, Text,, &Search:
  Gui, PerplexityAI:Add, Edit, vSearch w136 r1 -WantReturn, % search
  Gui, PerplexityAI:Add, Text,, &Focus:
  list := "internet||scholar|writing|wolfram|youtube|reddit"
  Gui, PerplexityAI:Add, Combobox, vFocus gAutoComplete w136, % list
  Gui, PerplexityAI:Add, CheckBox, vCopilot Checked, &Copilot
  Gui, PerplexityAI:Add, Button, default, &Search
  Gui, PerplexityAI:Show,, Perplexity AI
  SetDefaultKeyboard(0x0409)  ; English-US
Return

PerplexityAIGuiEscape:
PerplexityAIGuiClose:
  Gui, Destroy
return

PerplexityAIButtonSearch:
  Gui, Submit
  Gui, Destroy
  ShellRun("https://www.perplexity.ai/search?q=" . EncodeDecodeURI(search) . "&focus=" . focus
         . "&copilot=" . (copilot ? "true" : "false"))
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

MassReplaceRegistry:
  find := "https://finance.yahoo.com/quote/"
  replacement := ""
  if (!find && !replacement)
    return
  ; ControlSend, Edit1, % "{text}" . find, A
  loop {
    send !r
    WinWaitActive, ahk_class TInputDlg
    text := ControlGetText("TMemo1")
    ; if (InStr(text, find) != 1)
    ;   return
    if ((InStr(text, find) != 1) || (text ~= "\/$"))
      return
    ; ControlSetText, TMemo1, % StrReplace(text, find, replacement)
    ControlSetText, TMemo1, % text . "/"
    send !{enter}
    WinWaitActive, ahk_class TRegistryForm
    ControlSetText, Edit1  ; clear
    send {down}
  }
  ; loop {
  ;   ControlSend, Edit1, % "{text}" . find, A
  ;   Gosub SMRegAltG
  ;   WinWaitActive, ahk_class TElWind
  ;   Vim.SM.EditRef()
  ;   WinWaitActive, ahk_class TInputDlg
  ;   text := ControlGetText("TMemo1")
  ;   if (!IfContains(text, find))
  ;     return
  ;   text := RegExReplace(text, "#Source: " . find . "(.*)", "#Author: $1")
  ;   text .= "`r`n#Source: YouTube"
  ;   ControlSetText, TMemo1, % text
  ;   send !{enter}
  ;   WinWaitActive, ahk_class TElWind
  ;   ; WinWaitActive, ahk_class TChoicesDlg,, 0.3
  ;   ; if (!ErrorLevel)
  ;   ;   send {down}{enter}
  ;   Vim.SM.PostMsg(154)
  ;   WinWaitActive, ahk_class TRegistryForm
  ;   ControlSetText, Edit1  ; clear
  ; }
return

MassProcessRegistry:
  find := "https://finance.yahoo.com/quote/"
  replacement := ""
  if (!find && !replacement)
    return
  ; ControlSend, Edit1, % "{text}" . find, A
  loop {
    send !r
    WinWaitActive, ahk_class TInputDlg
    text := ControlGetText("TMemo1")
    ; if (InStr(text, find) != 1)
    ;   return
    if ((InStr(text, find) != 1) || (text ~= "\/$"))
      return
    ; ControlSetText, TMemo1, % StrReplace(text, find, replacement)
    ControlSetText, TMemo1, % text . "/"
    send !{enter}
    WinWaitActive, ahk_class TRegistryForm
    ControlSetText, Edit1  ; clear
    send {down}
  }
  ; loop {
  ;   ControlSend, Edit1, % "{text}" . find, A
  ;   Gosub SMRegAltG
  ;   WinWaitActive, ahk_class TElWind
  ;   Vim.SM.EditRef()
  ;   WinWaitActive, ahk_class TInputDlg
  ;   text := ControlGetText("TMemo1")
  ;   if (!IfContains(text, find))
  ;     return
  ;   text := RegExReplace(text, "#Source: " . find . "(.*)", "#Author: $1")
  ;   text .= "`r`n#Source: YouTube"
  ;   ControlSetText, TMemo1, % text
  ;   send !{enter}
  ;   WinWaitActive, ahk_class TElWind
  ;   ; WinWaitActive, ahk_class TChoicesDlg,, 0.3
  ;   ; if (!ErrorLevel)
  ;   ;   send {down}{enter}
  ;   Vim.SM.PostMsg(154)
  ;   WinWaitActive, ahk_class TRegistryForm
  ;   ControlSetText, Edit1  ; clear
  ; }
return

AllLapsesToday:
  ToolTip("Executing...", true), pidSM := WinGet("PID", "ahk_class TElWind")
  BlockInput, on
  Vim.SM.PostMsg(31)  ; export rep history
  WinWaitActive, ahk_class TFileBrowser
  TempPath := A_Temp . "\Repetition History_" . Vim.SM.GetCollName() . "_"
            . t := GetCurrTimeForFileName() . ".txt"
  TempOutputPath := A_Temp . "\All Lapses Today_" . Vim.SM.GetCollName() . "_"
                  . t . ".txt"
  Vim.SM.FileBrowserSetPath(TempPath, true)
  WinWaitActive % "Information ahk_class TMsgDialog ahk_pid " . pidSM
  send {enter}
  RepHistory := FileReadAndDelete(TempPath)
  dateRegEx := "Date=" . FormatTime(, "dd\.MM\.yyyy")
  pos := 1, v1 := ""
  while (pos := RegExMatch(RepHistory, "s)\nItem #[\d,]+: ([^\n]+)\n[^\n]+"
                                     . dateRegEx . "[^\n]+Grade=[0-2]", v, pos + StrLen(v1)))
    FileAppend, % v1 . "`n", % TempOutputPath
  ShellRun(TempOutputPath)
  BlockInput, off
  RemoveToolTip()
return

Lexico:
  if (word := FindSearch("Lexico", "Word:"))
    ShellRun("https://web.archive.org/web/*/www.lexico.com/definition/" . word)
return

ExternaliseRegistry:
  ; Images, Sounds, Binary, Video
  for i, v in [156, 157, 171, 170] {  ; sm19
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm18.exe")
      v++
    Vim.SM.PostMsg(v)
    WinWaitActive, ahk_class TRegistryForm
    if (IfContains(WinGetTitle(), "(0 members)")) {
      WinClose
      continue
    }
    send {down}
    if (IfContains(WinGetTitle(), "Video Registry"))
      ControlTextWaitExist("Edit1",,,,, 1500)
    send {AppsKey}tt
    WinWaitActive, ahk_class TMsgDialog
    send {enter}
    WinWaitActive, ahk_class TMsgDialog
    send {enter}
    WinWaitActive, ahk_class TProgressBox,, 0
    if (!ErrorLevel)
      WinWaitClose
    WinWaitActive, ahk_class TRegistryForm
    WinClose
  }
  Vim.State.SetMode("Vim_Normal")
return

AlignTextsLeft:
CenterTexts:
AlignTextsRight:
  if (A_ThisLabel == "AlignTextsLeft") {
    n := 15
  } else if (A_ThisLabel == "CenterTexts") {
    n := 16
  } else if (A_ThisLabel == "AlignTextsRight") {
    n := 17
  }
  Vim.SM.EditBar(n), Vim.State.SetMode("Vim_Normal")
return

BoldText:
ItalicText:
UnderscoreText:
  if (A_ThisLabel == "BoldText") {
    send ^b
  } else if (A_ThisLabel == "ItalicText") {
    send ^i
  } else if (A_ThisLabel == "UnderscoreText") {
    send ^u
  }
  Vim.State.SetMode("Vim_Normal")
return

Tatoeba:
  if (word := FindSearch("Tatoeba", "Word:"))
    ShellRun("https://tatoeba.org/en/sentences/search?query=" . word)
return

MD2HTML:
  Vim.State.SetMode("Vim_Normal")
  ClipSaved := ClipboardAll
  if (!MD := Copy(false))
    Goto RestoreClipReturn
  TempMDPath := A_Temp . "\" . (t := GetCurrTimeForFileName()) . "_md.md"
  FileDelete % TempMDPath
  FileAppend, % MD, % TempMDPath
  TempHTMLPath := A_Temp . "\" . t . "_html.html"
  FileAppend,, % TempHTMLPath
  ShellRun("pandoc", TempMDPath . " -s -o " . TempHTMLPath)
  loop {
    if (t := FileRead(TempHTMLPath))
      break
    sleep 100
  }
  RegExMatch(t, "s)<body>\K.*(?=<\/body>)", v)
  WinWaitActive % "ahk_id " . hWnd
  Clip(v,, false, Vim.SM.IsEditingHTML() ? "sm" : Vim.IsHTML())
  Clipboard := ClipSaved
return

CleanHTML:
  if (HTMLPath := FindSearch("Clean HTML", "Path:")) {
    HTML := FileRead(HTMLPath)
    FileDelete % HTMLPath
    FileAppend, % Vim.HTML.Clean(HTML), % HTMLPath
    ToolTip("Completed.")
  } else {
    ToolTip("Not found.")
  }
return

SaveFile:
  uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
  url := uiaBrowser.GetCurrentURL(true)
  if (r := RegExMatch(url, "\/[^\/\.]+\.[^\/\.]+$", v))
    UrlDownloadToFile, % url, % FilePath := "d:" . v
  if (!r || ErrorLevel) {
    ToolTip("Failed.")
    return
  }
  SplitPath, FilePath, name, dir, ext, NameNoExt
  if (ext = "ogg")
    RunWait, % "cmd /c ffmpeg -i """ . FilePath . """ -acodec libmp3lame """ . dir . "\" . NameNoExt . ".mp3"" && del """ . FilePath . """",, Hide
  ToolTip("Success.")
return

EPUB2TXT:
  if (EpubPath := FindSearch("EPUB2TXT", "Path:")) {
    TxtPath := StrReplace(EpubPath, ".epub", ".txt")
    RunWait, % "pandoc -f epub -t plain -o """ . TxtPath . """ """ . EpubPath . """",, Hide
    ToolTip("Completed.")
  } else {
    ToolTip("Not found.")
  }
return

PasteCleanedClipboard:
  Vim.HTML.ClipboardGet_HTML(data)
  RegExMatch(data, "SourceURL:(.*)", v)
  RegExMatch(data, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", data)
  data := Vim.HTML.Clean(data,,, v1)
  Clip(data,,, (Vim.SM.IsEditingHTML() ? "sm" : true))
return

ArchiveToday:
  WinWaitActive % "ahk_id " . hWnd
  if (WinActive("ahk_group Browser")) {
    uiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
    url := FindSearch("Archive Today", "URL:", uiaBrowser.GetCurrentURL(), true)
  } else if (WinActive("ahk_class TElWind")) {
    url := FindSearch("Archive Today", "URL:", Vim.SM.GetLink(), true)
  } else if (!url := FindSearch("Today", "URL:")) {
    return
  }
  if (url)
    ShellRun("https://archive.today/?run=1&url=" . url)
return

WolframAlpha:
  if (text := FindSearch("WolframAlpha", "Text:"))
    ShellRun("https://www.wolframalpha.com/input?input=" . EncodeDecodeURI(text))
Return

Comment:
  Vim.SM.EditRef()
  WinWaitActive, ahk_class TInputDlg
  Ref := ControlGetText("TMemo1")
  RegExMatch(Ref, "#Comment: (.*)|$", v), PrevComment := v1
  Comment := InputBox("Comment", "Set comment:",,,,,,,, PrevComment)
  WinWaitActive, ahk_class TInputDlg
  if (Comment) {
    Ref := "#Comment: " . Comment . "`r`n" . Ref
  } else {
    Ref := RegExReplace(Ref, "#Comment:.*")
  }
  ControlSetText, TMemo1, % Ref
  send ^{enter}
  WinWaitClose
return

MassProcessBrowser:
  loop {
      SMTitle := WinGetTitle("ahk_class TElWind")
      if (RegExMatch(SMTitle, "^((?:\d{1,2}:)?\d{1,2}:\d{1,2}) \| ", v)) {
          WinActivate, ahk_class TElWind
          if (v1) {
            Critical
            Clip("SMVim time stamp: " . v1,, false)
          }
          send {esc}
          Vim.SM.WaitTextExit()
          sleep 100
          ; MsgBox, 3,, Continue?
        ; if (IfMsgBox("Yes"))
          Vim.SM.SetTitle(RegExReplace(SMTitle, "^((?:\d{1,2}:)?\d{1,2}:\d{1,2}) \| "))
      }
    WinActivate, ahk_class TBrowser
    send {down}
    Vim.SM.WaitFileLoad()
  }
return
