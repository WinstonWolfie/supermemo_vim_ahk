#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
; `;::Vim.State.SetMode("Command") ;(;)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command"))
w::Vim.State.SetMode("Command_w")
q::Vim.State.SetMode("Command_q")
h::
  Send {F1}
  Vim.State.SetMode("Vim_Normal")
Return
CapsLock & m::
BS::Vim.State.SetMode("Vim_Normal")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command_w"))
Return::
  Send ^s
  Vim.State.SetMode("Vim_Normal")
Return

q::
  Send ^s^w
  Vim.State.SetMode("Insert")
Return

Space::  ; save as
  Send !fa
  Vim.State.SetMode("Insert")
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Command_q"))
Return::
  Send ^w
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

  List := "Plan||Wiktionary|WebSearch|YT|Settings|MoveMouseToCaret"
        . "|WaybackMachine|DefineGoogle|YouGlish|KillOutlook|DeepL"
        . "|WindowSpy|BingChat|CopyTitle|CopyHTML|Forvo|SciHub|AccViewer"
        . "|TranslateGoogle|ClearClipboard|Forcellini|RAE|OALD"
        . "|AlatiusLatinMacronizer|UIAViewer|Libgen|ImageGoogle|WatchLaterYT"
        . "|CopyWindowPosition|ZLibrary|GetInfoFromContextMenu|GenerateTimeString"
        . "|Bilibili|AlwaysOnTop|Larousse|GraecoLatinum|LatinoGraecum|Linguee"
        . "|MerriamWebster|WordSense|RestartOneDrive|RestartICloudDrive|KillIE"
        . "|PerplexityAI|Lexico|Tatoeba|MD2HTML|CleanHTML|EPUB2TXT"
        . "|PasteCleanedClipboard|ArchiveToday|WolframAlpha|PasteHTML"
        . "|AnnasArchive"

  if (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) {
    List := "SetConceptHook|MemoriseChildren|" . List
    if (WinActive("ahk_class TElWind")) {
      List := "NukeHTML|ReformatVocab|ImportFile|EditReference|LinkToPreviousElement"
            . "|OpenInAcrobat|CalculateTodaysPassRate|AllLapsesToday"
            . "|ExternaliseRegistry|Comment|Tag|" . List
      if (SM.IsOnline(, -1))
        List := "ReformatScriptComponent|SearchLinkInYT|MarkAsOnlineProgress|" . List
      if (SM.IsEditingText())
        List := "ClozeAndDone!|" . List
      if (SM.IsEditingHTML())
        List := "MakeHTMLUnique|CenterTexts|AlignTextsRight|AlignTextsLeft|ItalicText"
              . "|UnderscoreText|BoldText|" . List
    }
  } else if (WinActive("ahk_class TBrowser")) {  ; SuperMemo browser
    List := "MemoriseCurrentBrowser|SetBrowserPosition|MassReplaceReference"
          . "|MassProcessBrowser|" . List
  } else if (WinActive("ahk_group Browser")) {  ; web browsers
    List := "IWBPriorityAndConcept|IWBNewTopic|SaveFile|" . List
  } else if (WinActive("ahk_class TPlanDlg")) {  ; SuperMemo Plan window
    List := "SetPlanPosition|" . List
  } else if (WinActive("ahk_class TRegistryForm")) {  ; SuperMemo Registry window
    List := "MassReplaceRegistry|MassProcessRegistry|" . List
  } else if (WinActive("Google Drive error List ahk_exe GoogleDriveFS.exe")) {  ; Google Drive errors
    List := "RetryAllSyncErrors|" . List
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
  if (IfContains("|" . List . "|", "|" . Command . "|")) {
    WinActivate % "ahk_id " . hWnd
    Goto % RegExReplace(Command, "\W")
  } else {
    aCommand := StrSplit(Command, " ")
    if (aCommand[1] = "yt") {
      ShellRun("https://www.youtube.com/results?search_query=" . EncodeDecodeURI(RegExReplace(Command, "i)^yt ")))
    } else if (aCommand[1] = "def") {
      Command := EncodeDecodeURI(RegExReplace(Command, "i)^def "))
      ShellRun("https://www.google.com/search?hl=en-uk&q=define " . Command . "&forcedict=" . Command . "&dictcorpus=en-uk&expnd=1&gl=gb")
    } else if (aCommand[1] = "wkt") {
      ShellRun("https://www.google.com/search?q=wiktionary " . EncodeDecodeURI(RegExReplace(Command, "i)^wkt ")))
    } else if (aCommand[1] = "pplx") {
      ShellRun("https://www.perplexity.ai/search?q=" . EncodeDecodeURI(RegExReplace(Command, "i)^pplx ")) . "&focus=internet&copilot=true")
    } else if (aCommand[1] = "tag") {
      Tags := RegExReplace(Command, "i)^tag "), EditRefComment := true
      wSMElWind := ""
      if (WinActive("ahk_group Browser")) {
        Browser.GetInfo(, false,, false, false, false)
        wSMElWind := SM.FindMatchTitleColl(Browser.Title)
        Browser.Clear()
      }
      if (!wSMElWind)
        wSMElWind := "ahk_class TElWind"
      Goto SMTagEntered
    } else if (IsUrl(Command)) {
      if !(Command ~= "^http")
        Command := "http://" . Command
      ShellRun(Command)
    } else {
      ShellRun("https://www.google.com/search?q=" . EncodeDecodeURI(Command))
    }
  }
return

FindSearchIB(Title, Prompt, Text:="", ForceText:=false, Width:="192", Height:="128") {
  if (!ForceText && (!Text := FindSearch()))
    Text := Text ? Text : Clipboard
  ret := InputBox(Title, Prompt,, Width, Height,,,,, Text)
  ; If the user closed the input box without submitting, return nothing
  return ErrorLevel ? "" : Trim(ret)
}

FindSearch() {
  global Vim
  BlockInput, On
  if (WinActive("ahk_class TElWind")) {
    SM.CtrlF3()
    WinWaitActive, ahk_class TInputDlg
    Text := ControlGetText("TMemo1")
    Text := StrReplace(Text, "©", "`n")
    WinClose
  } else {
    Text := Copy()
  }
  BlockInput, Off
  return Trim(Text)
}

WindowSpy:
  ShellRun("C:\Program Files\AutoHotkey\WindowSpy.ahk")
return

WebSearch:
  Search := FindSearch()
  Gui, WebSearch:Add, Text,, &Search:
  Gui, WebSearch:Add, Edit, vSearch w136 r1 -WantReturn, % Search
  Gui, WebSearch:Add, Text,, &Language Code:
  List := "en-uk||en-us|es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr|zh-hk|zh"
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
  LinkCount := ObjCount(aLinks := GetAllLinks(Search))
  if (LinkCount > 0) {
    if (LinkCount == 1) {
      MB := MsgBox(3,, "Text contains url. Run it?")
    } else if (LinkCount > 1) {
      MB := MsgBox(3,, "Text contains multiple urls. Run them?")
    }
    if (MB = "Yes") {
      for i, v in aLinks
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
    SetToolTip("Current caret position: " . A_CaretX . " " . A_CaretY)
  } else {
    SetToolTip("Caret not found.")
  }
return

WaybackMachine:
  if (WinActive("ahk_group Browser")) {
    uiaBrowser := new UIA_Browser("A")
    Url := FindSearchIB("Wayback Machine", "URL:", uiaBrowser.GetCurrentURL(), true)
  } else if (WinActive("ahk_class TElWind")) {
    Url := FindSearchIB("Wayback Machine", "URL:", SM.GetLink(), true)
  } else if (!Url := FindSearchIB("Wayback Machine", "URL:")) {
    return
  }
  if (Url)
    ShellRun("https://web.archive.org/web/*/" . Url)
return

DeepL:
  if (Text := FindSearchIB("DeepL Translate", "Text:",,, 256))
    ShellRun("https://www.deepl.com/en/translator#?/en/" . EncodeDecodeURI(Text))
Return

YouGlish:
  Gui, YouGlish:Add, Text,, &Search:
  Gui, YouGlish:Add, Edit, vSearch w136 r1 -WantReturn, % FindSearch()
  Gui, YouGlish:Add, Text,, &Language:
  List := "English||Spanish|French|Italian|Japanese|German|Russian|Greek|Hebrew"
        . "|Arabic|Polish|Portuguese|Korean|Turkish|American Sign Language|Dutch"
  Gui, YouGlish:Add, Combobox, vLanguage gAutoComplete w136, % List
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
  if (Language == "American Sign Language")
    Language := "signlanguage"
  ShellRun("https://youglish.com/pronounce/" . EncodeDecodeURI(Search) . "/" . StrLower(Language))
Return

KillIE:
  while (WinExist("ahk_exe iexplore.exe"))
    process, close, iexplore.exe
return

DefineGoogle:
  Gui, GoogleDefine:Add, Text,, &Search:
  Gui, GoogleDefine:Add, Edit, vSearch w136 r1 -WantReturn, % FindSearch()
  Gui, GoogleDefine:Add, Text,, &Language Code:
  List := "en-uk||en-us|es|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr|zh-hk|zh"
  Gui, GoogleDefine:Add, Combobox, vLangCode gAutoComplete w136, % List
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
  Search := EncodeDecodeURI(Search)
  if (LangCode) {
    Define := "define", Add := ""
    if (LangCode = "fr") {
      Define := "définis"
    } else if (LangCode = "it") {
      Define := "definisci"
    } else if (LangCode = "en-uk") {
      Add := "&gl=gb"
    } else if (LangCode = "en-us") {
      Add := "&gl=us"
    }
    ShellRun("https://www.google.com/search?hl=" . LangCode . "&q=" . Define . " "
           . Search . "&forcedict=" . Search . "&dictcorpus=" . LangCode . "&expnd=1" . Add)
  } else {
    ShellRun("https://www.google.com/search?q=define " . Search)
  }
return

ClozeAndDone:
  if (!Copy())
    return
  SM.Cloze()
  if (SM.WaitClozeProcessing() == -1)  ; warning on trying to cloze on items
    return
  Send ^+{Enter}
  WinWaitNotActive, ahk_class TElWind  ; "Do you want to remove all element contents from the collection?"
  Send {Enter}
  WinWaitNotActive, ahk_class TElWind  ; wait for "Delete element?"
  Send {Enter}
  Vim.State.SetNormal()
return

Wiktionary:
  Gui, Wiktionary:Add, Text,, &Word:
  Gui, Wiktionary:Add, Edit, vWord w136 r1 -WantReturn, % FindSearch()
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
    ShellRun("https://www.google.com/search?hl=en&q=Wiktionary " . EncodeDecodeURI(Word))
  } else {
    Language := StrReplace(Language, " ", "_")
    if (Language == "Latin")
      Word := RemoveLatinMacrons(Word)
    ShellRun("https://en.wiktionary.org/wiki/" . Word . "#" . Language)
  }
return

CopyTitle:
  SetToolTip("Copied " . Clipboard := WinGetTitle("A"))
return

CopyHTML:
  ClipSaved := ClipboardAll
  if (!Clipboard := Copy(false, true)) {
    Clipboard := ClipSaved
    return
  }
  SetToolTip("Copying successful.")
return

Forvo:
  if (Word := FindSearchIB("Forvo", "Word:"))
    ShellRun("https://forvo.com/search/" . Word . "/")
return

SetConceptHook:
  if (WinActive("ahk_class TElWind")) {
    Send !c
    WinWaitActive, ahk_class TContents
  }
  if (ControlGetFocus("A") == "TVTEdit1")
    Send {Enter}
  ControlFocusWait("TVirtualStringTree1", "A")
  Send {AppsKey}ce
  WinWaitActive, ahk_class TMsgDialog  ; either asking for confirmation or "no change"
  Send {Enter}
  ControlSend, TVirtualStringTree1, {Esc}, ahk_class TContents
  SetToolTip("Hook set."), Vim.State.SetMode("Vim_Normal")
Return

AccViewer:
  ShellRun(A_ScriptDir . "\lib\util\AccViewer Source.ahk")
return

UIAViewer:
  ShellRun(A_ScriptDir . "\lib\util\UIAViewer.ahk")
return

TranslateGoogle:
  if (Text := FindSearchIB("Google Translate", "Text:",,, 256))
    ShellRun("https://translate.google.com/?sl=auto&tl=en&text=" . EncodeDecodeURI(Text) . "&op=translate")
return

ClearClipboard:
  run % ComSpec . " /c echo off | clip"
return

MemoriseChildren:
  SM.OpenBrowser()
  SM.WaitBrowser()
  Goto MemoriseCurrentBrowser
return

MemoriseCurrentBrowser:
  Send {AppsKey}cn  ; find pending elements
  SM.WaitBrowser()
  Send {AppsKey}ple  ; remember
return

Forcellini:
  if (Word := FindSearchIB("Forcellini", "Word:"))
    ShellRun("http://lexica.linguax.com/forc2.php?searchedLG=" . RemoveLatinMacrons(Word))
return

RAE:
  if (Word := FindSearchIB("RAE", "Word:"))
    ShellRun("https://dle.rae.es/" . Word . "?m=form")
return

OALD:
  if (Word := FindSearchIB("Oxford Advanced Learner's Dictionary", "Word:"))
    ShellRun("https://www.oxfordlearnersdictionaries.com/definition/english/" . Word)
return

AlatiusLatinMacronizer:
  if (!Latin := FindSearchIB("Alatius: a Latin macronizer", "Latin:"))
    return
  ShellRun("https://alatius.com/macronizer/")
  WinWaitActive, ahk_group Browser
  uiaBrowser := new UIA_Browser("A")
  uiaBrowser.WaitPageLoad()
  uiaBrowser.WaitElementExist("ControlType=Edit AND Framework=Chrome").SetValue(Latin)
  uiaBrowser.WaitElementExist("ControlType=Button AND Name='Submit'").Click()
return

SetBrowserPosition:
  WinMove, ahk_class TBrowser,, 0, 0, 846, 680
return

; Personal: reformat my old incremental video topics
ReformatScriptComponent:
  ClipSaved := ClipboardAll
  WinWaitActive, ahk_class TElWind
  if (ContLearn := SM.IsLearning())
    Send !g
  SM.ExitText()
  WinClip.Clear()
  Send ^a^x
  ClipWait
  aOriginalText := StrSplit(Clipboard, "`n`r")
  Browser.Url := Trim(aOriginalText[1], " `r`n"), Browser.Title := WinGetTitle("A")
  Browser.TimeStamp := Trim(aOriginalText[2], " `r`n")
  if (IfContains(Browser.Url, "youtube.com")) {
    YTTime := Browser.TimeStamp ? "&t=" . Browser.GetSecFromTime(Browser.TimeStamp) . "s" : ""
    Browser.Source := "YouTube"
    if (YTTime) {
      Send ^t{f9}  ; opens script editor
      WinWaitActive, ahk_class TScriptEditor
      ControlSetText, TMemo1, % ControlGetText("TMemo1") . YTTime
      Send !o{Esc}  ; close script editor
    }
  }
  Gosub SMSetLinkFromClipboard
  Send {Esc}
  if (ContLearn)
    SM.Learn()
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
return

CopyWindowPosition:
  WinGetPos, x, y, w, h, A
  SetToolTip("Copied " . Clipboard := "Window's position: x = " . x . " y = " . y . " w = " . w . " h = " . h)
return

MassReplaceReference:
  find := ""
  replacement := ""
  if (!find && !replacement)
    return
  loop {
    WinActivate, ahk_class TElWind
    SM.WaitFileLoad()
    SM.EditRef()
    WinWaitActive, ahk_class TInputDlg
    if (IfContains(ref := ControlGetText("TMemo1"), find)) {
      ControlSetText, TMemo1, % StrReplace(ref, find, replacement)
    } else {
      return
    }
    Send !{Enter}
    WinWaitActive, ahk_class TChoicesDlg,, 0
    if (!ErrorLevel)
      Send {Down}{Enter}
    WinActivate, ahk_class TBrowser
    Send {Down}
  }
return

SciHub:
  if (!Text := FindSearchIB("Sci-Hub", "Search:"))
    return
  if (RegExMatch(Text, "https:\/\/doi\.org\/([^ ]+)", v)) {
    ShellRun("https://sci-hub.hkvisa.net/" . v1)
  ; https://www.crossref.org/blog/dois-and-matching-regular-expressions/
  } else if (RegExMatch(Text, "i)10.\d{4,9}/[-._;()/:A-Z0-9]+", v)) {
    ShellRun("https://sci-hub.hkvisa.net/" . v)
  } else {
    ShellRun("https://sci-hub.hkvisa.net/")
    WinWaitActive, ahk_group Browser
    uiaBrowser := new UIA_Browser("A")
    uiaBrowser.WaitPageLoad()
    el := uiaBrowser.WaitElementExist("ControlType=Edit AND Name='enter URL, PMID / DOI or search string'")
    el.GetCurrentPatternAs("Value").SetValue(Text)
    uiaBrowser.WaitElementExist("ControlType=Text AND Name='open'").Click()
  }
return

YT:
  if (Text := FindSearchIB("YouTube", "Search:"))
    ShellRun("https://www.youtube.com/results?search_query=" . EncodeDecodeURI(Text))
return

; Personal: reformat my old vocabulary items
ReformatVocab:
  Vim.State.SetMode("Vim_Normal")
  if (!SM.DoesTextExist())
    return
  ClipSaved := ClipboardAll
  SM.EditFirstQuestion()
  if (!SM.WaitTextFocus())
    return
  Send ^a
  if (!data := Copy(false, true)) {
    Clipboard := ClipSaved
    return
  }
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
  if (Text := FindSearchIB("Z-Library", "Search:"))
    ShellRun("https://singlelogin.re/s/?q=" . EncodeDecodeURI(Text))
return

AnnasArchive:
  if (Text := FindSearchIB("Anna’s Archive", "Search:"))
    ShellRun("https://annas-archive.org/search?q=" . EncodeDecodeURI(Text))
return

ImportFile:
  Vim.State.SetMode("Vim_Normal")
  Send ^+p
  WinWaitActive, ahk_class TElParamDlg
  Send !t
  Send {text}binary  ; my template for pdf/epub file is binary
  Send {Enter 2}
  WinWaitActive, ahk_class TElWind
  SM.EditFirstQuestion()
  Send {Ctrl Down}tq{Ctrl Up}
  SM.WaitFileBrowser()
  Send {Right}
  MB := MsgBox(3,, "Do you want to also delete the file?")
  if (MB = "Cancel")
    return
  if (KeepFile := (MB = "No"))
    FilePath := WinGetTitle("ahk_class TFileBrowser")
  WinActivate, ahk_class TFileBrowser
  Send {Enter}
  WinWaitActive, ahk_class TInputDlg
  Send {Enter}
  WinWaitActive, ahk_class TMsgDialog
  if (!KeepFile) {
    Send {text}n  ; not keeping the file in original position
    WinWaitClose
    WinWaitActive, ahk_class TMsgDialog
  }
  Send {text}y  ; confirm to delete the file / confirm to keep the file
  WinWaitActive, ahk_class TElWind
  RegExMatch(FilePath, "[^\\]+(?=\.)", FileName)
  if (KeepFile && !(FileName ~= "^IMPORTED_")) {
    if (MsgBox(3,, "Do you want to add ""IMPORTED_"" prefix to the file?") = "Yes")
      FileMove, % FilePath, % StrReplace(FilePath, FileName, "IMPORTED_" . FileName)
  }
  SM.AskPrio()
return

Settings:
  Vim.Setting.ShowGui()
return

Bilibili:
  if (search := FindSearchIB("Bilibili", "Search:"))
    ShellRun("https://search.bilibili.com/all?keyword=" . search)
return

Libgen:
  if (search := FindSearchIB("Library Genesis", "Search:")) {
    ShellRun("http://libgen.is/search.php?req=" . search . "&lg_topic=libgen&open=0&view=simple&res=25&phrase=1&column=def")
    ShellRun("https://libgen.li/index.php?req=" . search . "&columns%5B%5D=t&columns%5B%5D=a&columns%5B%5D=s&columns%5B%5D=y&columns%5B%5D=p&columns%5B%5D=i&objects%5B%5D=f&objects%5B%5D=e&objects%5B%5D=s&objects%5B%5D=a&objects%5B%5D=p&objects%5B%5D=w&topics%5B%5D=l&topics%5B%5D=c&topics%5B%5D=f&topics%5B%5D=a&topics%5B%5D=m&topics%5B%5D=r&topics%5B%5D=s&res=25&filesuns=all")
  }
return

ImageGoogle:
  Gui, ImageGoogle:Add, Text,, &Search:
  Gui, ImageGoogle:Add, Edit, vSearch w136 r1 -WantReturn, % FindSearch()
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
  if ((!Link := SM.GetLink()) && SM.DoesHTMLExist()) {
    SM.EditFirstQuestion()
    SM.WaitTextFocus()
    Send ^{Home}+{Right}
    RegExMatch(Copy(, true), "(<A((.|\r\n)*)href="")\K[^""]+", Link)
    Send {Esc}
  }
  if (!Link || !Browser.SearchInYT(WinGetTitle("ahk_class TElWind"), Link))
    SetToolTip("Not found.")
return

WatchLaterYT:
  ShellRun("https://www.youtube.com/playlist?list=WL")
return

EditReference:
  SM.EditRef()
Return

GetInfoFromContextMenu:
  ShellRun(A_ScriptDir . "\lib\util\Get Info from Context Menu.ahk")
return

GenerateTimeString:
  Send % "{text}" . FormatTime(, "yyyyMMddHHmmss" . A_MSec)
return

BingChat:
  ClipSaved := Link := ""
  wEdge := WinActive("ahk_exe msedge.exe")
  ext := ".htm"  ; by default the text will be copied with its format retained
  if (WinActive("ahk_class TElWind")) {
    if (SM.IsBrowsing()) {
      Link :=SM.GetLink()
    } else if (SM.IsEditingText()) {
      Link :=SM.GetFilePath()
    }
  } else if (!wEdge && (hWnd := WinActive("ahk_group Browser"))) {
    uiaBrowser := new UIA_Browser("ahk_id " . hWnd)
    Link :=uiaBrowser.GetCurrentURL()
  } else {
    ClipSaved := ClipboardAll
    if (!Text := Copy(false, true))  ; HTML not found
      Text := Clipboard, ext := ".txt"
    if (Text) {
      Link :=A_Temp . "\" . GetCurrTimeForFileName() . ext
      FileDelete % Link
      FileAppend, % Text, % Link
    }
  }
  if (Text || !wEdge) {
    ShellRun("msedge.exe", Link)
    WinWaitActive, ahk_exe msedge.exe
  }
  Send ^+.
  if (ClipSaved)
    Clipboard := ClipSaved
  if (Link) {
    uiaBrowser := new UIA_Browser("A")
    uiaBrowser.WaitPageLoad()
    FileDelete % Link
  }
return 

LinkToPreviousElement:
  Send !c
  WinWaitActive, ahk_class TContents
  WinActivate, ahk_class TElWind
  SM.GoBack()
  SM.WaitFileLoad()
  SM.LinkContents()
  WinWaitActive, ahk_class TContents
  Send {Enter}+{Enter}
  SM.WaitFileLoad()
  WinWaitActive, ahk_class TElWind
  SM.ListLinks()
return

AlwaysOnTop:
  WinSet, AlwaysOnTop, Toggle, A
return

OpenInAcrobat:
  Send q^{t}{f9}
  if (path := SM.GetFilePath())
    ShellRun("acrobat.exe", path)
return

Larousse:
  if (word := FindSearchIB("Larousse", "Word:"))
    ShellRun("https://www.larousse.fr/dictionnaires/francais/" . word)
return

GraecoLatinum:
  if (word := FindSearchIB("Graeco-Latinum", "Word:")) {
    ShellRun("http://lexica.linguax.com/nlm.php?searchedGL=" . word)
    ShellRun("http://lexica.linguax.com/schrevel.php?searchedGL=" . word)
  }
return

LatinoGraecum:
  if (word := FindSearchIB("Latino-Graecum", "Word:")) {
    ShellRun("http://lexica.linguax.com/nlm.php?searchedLG=" . word)
    ShellRun("http://lexica.linguax.com/schrevel.php?searchedLG=" . word)
  }
return

Linguee:
  if (word := FindSearchIB("Linguee", "Word:"))
    ShellRun("https://www.linguee.com/search?query=" . word)
return

MerriamWebster:
  if (word := FindSearchIB("Merriam-Webster", "Word:")) {
    ShellRun("https://www.merriam-webster.com/dictionary/" . word)
    ShellRun("https://www.britannica.com/dictionary/" . word)
  }
return

WordSense:
  if (word := FindSearchIB("WordSense", "Word:"))
    ShellRun("https://www.wordsense.eu/" . word . "/")
return

SetPlanPosition:
  WinGetPos, x, y, w, h, ahk_class TElWind
  WinMove, ahk_class TPlanDlg,, x, y, w, h
return

MakeHTMLUnique:
  ClipSaved := ClipboardAll
  SM.MoveToLast(false)
  Clip("<SPAN class=anti-merge>HTML made unique at " . GetDetailedTime() . "</SPAN>",, false, "sm")
  Clipboard := ClipSaved, Vim.State.SetMode("Vim_Normal")
return

KillOutlook:
  Process, Close, Outlook.exe
return

RestartOneDrive:
  Process, Close, OneDrive.exe
  ShellRun("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk")
  WinWait, ahk_class CabinetWClass ahk_exe explorer.exe,, 10
  if (!ErrorLevel)
    WinClose
return

RestartICloudDrive:
  Process, Close, iCloudDrive.exe
  Process, Close, iCloudServices.exe
  ShellRun("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\iCloud\iCloud.lnk")
  WinWait, iCloud ahk_class PreferencesWnd ahk_exe iCloud.exe
  WinClose
return

CalculateTodaysPassRate:
  SetToolTip("Executing..."), pidSM := WinGet("PID", "ahk_class TElWind")
  BlockInput, On
  SM.PostMsg(31)  ; export rep history
  WinWaitActive, ahk_class TFileBrowser
  TempPath := A_Temp . "\Repetition History_" . SM.GetCollName() . "_"
            . GetCurrTimeForFileName() ".txt"
  SM.FileBrowserSetPath(TempPath, true)
  WinWaitActive % "Information ahk_class TMsgDialog ahk_pid " . pidSM
  Send {Enter}
  RepHistory := FileReadAndDelete(TempPath)
  DateRegEx := "Date=" . FormatTime(, "dd\.MM\.yyyy")
  RegExReplace(RepHistory, "s)\nItem #[\d,]+: [^\n]+\n[^\n]+" . DateRegEx
                         . "[^\n]+Grade=[0-5]",, TodayRepCount)
  RegExReplace(RepHistory, "s)\nItem #[\d,]+: [^\n]+\n[^\n]+" . DateRegEx
                         . "[^\n]+Grade=[3-5]",, TodayPassCount)
  BlockInput, Off
  MsgBox % "Today's repetition count: " . TodayRepCount
         . "`nToday's pass (grade > 3) count: " . TodayPassCount
         . "`nToday's pass rate: " . Format("{:g}", TodayPassCount / TodayRepCount * 100) . "%"
return

PerplexityAI:
  if ((!Search := Trim(Copy())) && SM.IsEditingHTML()) {
    Send ^{f7}  ; save read point
    SM.SaveHTML()  ; path may be updated
    WinWaitActive, ahk_class TElWind
    Search := "File path from SMVim script: " . SM.GetFilePath()
  }
  Gui, PerplexityAI:Add, Text,, &Search:
  Gui, PerplexityAI:Add, Edit, vSearch w200 r1 -WantReturn, % Search
  Gui, PerplexityAI:Add, Text,, &Focus:
  list := "internet||scholar|writing|wolfram|youtube|reddit"
  Gui, PerplexityAI:Add, Combobox, vFocus gAutoComplete w200, % list
  Gui, PerplexityAI:Add, CheckBox, vCopilot Checked, &Copilot
  Gui, PerplexityAI:Add, Text,, &Attach the above text and ask:
  list := "summarize|what is the conclusion?|check this file for mistakes"
  Gui, PerplexityAI:Add, Combobox, vAddSearch gAutoComplete w200, % list
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
  if (AddSearch || (Search ~= "^File path from SMVim script: ")) {
    ShellRun("https://www.perplexity.ai/")
    WinWaitActive, ahk_group Browser
    uiaBrowser := new UIA_Browser("A")
    uiaBrowser.WaitPageLoad()

    uiaBrowser.WaitElementExist("ControlType=Text AND Name='Focus'").Click()
    if (Focus == "internet") {
      uiaBrowser.WaitElementExist("ControlType=Text AND Name='All'").Click()
    } else if (Focus == "scholar") {
      uiaBrowser.WaitElementExist("ControlType=Text AND Name='Academic'").Click()
    } else if (Focus == "writing") {
      uiaBrowser.WaitElementExist("ControlType=Text AND Name='Writing'").Click()
    } else if (Focus == "wolfram") {
      uiaBrowser.WaitElementExist("ControlType=Text AND Name='Wolfram|Alpha'").Click()
    } else if (Focus == "youtube") {
      uiaBrowser.WaitElementExist("ControlType=Text AND Name='YouTube'").Click()
    } else if (Focus == "reddit") {
      uiaBrowser.WaitElementExist("ControlType=Text AND Name='Reddit'").Click()
    }

    TempFilePath := ""
    if (Search ~= "^File path from SMVim script: ") {
      FilePath := RegExReplace(Search, "^File path from SMVim script: ")
    } else {
      TempFilePath := A_Temp . "\" . GetCurrTimeForFileName() . ".txt"
      FileDelete % TempFilePath
      FileAppend, % Search, % FilePath := TempFilePath
    }
    uiaBrowser.WaitElementExist("ControlType=Text AND Name='Attach'").Click()
    WinWaitActive, ahk_class #32770
    ControlSetText, Edit1, % FilePath
    Send {Enter}
    WinWaitNotActive
    uiaBrowser.WaitElementExist("ControlType=Text AND Name='Uploading...'")
    if (AddSearch) {
      uiaBrowser.WaitElementExist("ControlType=Edit AND Name='Ask anything...'").SetValue(AddSearch)
      uiaBrowser.WaitElementNotExist("ControlType=Text AND Name='Uploading...'")
      Send {Enter}
    }
    if (TempFilePath)
      FileDelete % TempFilePath
  } else {
    ShellRun("https://www.perplexity.ai/search?q=" . EncodeDecodeURI(Search) . "&focus=" . Focus
           . "&copilot=" . (Copilot ? "true" : "false"))
  }
return

RetryAllSyncErrors:
  UIA := UIA_Interface(), el := UIA.ElementFromHandle(WinActive("A"))
  while (dot := el.FindFirstBy("ControlType=MenuItem AND Name='More options menu icon'")) {
    dot.Click()
    el.FindFirstBy("ControlType=MenuItem AND Name='Retry' AND AutomationId='retry-id'").Click()
    Sleep 100
    if (el.FindFirstBy("ControlType=Text AND Name='Looks fine'"))
      Break
  }
  SetToolTip("Finished.")
return

MassReplaceRegistry:
  find := "https://finance.yahoo.com/quote/"
  replacement := ""
  if (!find && !replacement)
    return
  ; ControlSend, Edit1, % "{text}" . find, A
  loop {
    Send !r
    WinWaitActive, ahk_class TInputDlg
    Text := ControlGetText("TMemo1")
    ; if (InStr(Text, find) != 1)
    ;   return
    if ((InStr(Text, find) != 1) || (Text ~= "\/$"))
      return
    ; ControlSetText, TMemo1, % StrReplace(Text, find, replacement)
    ControlSetText, TMemo1, % Text . "/"
    Send !{Enter}
    WinWaitActive, ahk_class TRegistryForm
    ControlSetText, Edit1  ; clear
    Send {Down}
  }
  ; loop {
  ;   ControlSend, Edit1, % "{text}" . find, A
  ;   SM.RegAltG()
  ;   WinWaitActive, ahk_class TElWind
  ;   SM.EditRef()
  ;   WinWaitActive, ahk_class TInputDlg
  ;   Text := ControlGetText("TMemo1")
  ;   if (!IfContains(Text, find))
  ;     return
  ;   Text := RegExReplace(Text, "#Source: " . find . "(.*)", "#Author: $1")
  ;   Text .= "`r`n#Source: YouTube"
  ;   ControlSetText, TMemo1, % Text
  ;   Send !{Enter}
  ;   WinWaitActive, ahk_class TElWind
  ;   ; WinWaitActive, ahk_class TChoicesDlg,, 0.3
  ;   ; if (!ErrorLevel)
  ;   ;   Send {Down}{Enter}
  ;   SM.PostMsg(154)
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
    Send !r
    WinWaitActive, ahk_class TInputDlg
    Text := ControlGetText("TMemo1")
    ; if (InStr(Text, find) != 1)
    ;   return
    if ((InStr(Text, find) != 1) || (Text ~= "\/$"))
      return
    ; ControlSetText, TMemo1, % StrReplace(Text, find, replacement)
    ControlSetText, TMemo1, % Text . "/"
    Send !{Enter}
    WinWaitActive, ahk_class TRegistryForm
    ControlSetText, Edit1  ; clear
    Send {Down}
  }
  ; loop {
  ;   ControlSend, Edit1, % "{text}" . find, A
  ;   SM.RegAltG()
  ;   WinWaitActive, ahk_class TElWind
  ;   SM.EditRef()
  ;   WinWaitActive, ahk_class TInputDlg
  ;   Text := ControlGetText("TMemo1")
  ;   if (!IfContains(Text, find))
  ;     return
  ;   Text := RegExReplace(Text, "#Source: " . find . "(.*)", "#Author: $1")
  ;   Text .= "`r`n#Source: YouTube"
  ;   ControlSetText, TMemo1, % Text
  ;   Send !{Enter}
  ;   WinWaitActive, ahk_class TElWind
  ;   ; WinWaitActive, ahk_class TChoicesDlg,, 0.3
  ;   ; if (!ErrorLevel)
  ;   ;   Send {Down}{Enter}
  ;   SM.PostMsg(154)
  ;   WinWaitActive, ahk_class TRegistryForm
  ;   ControlSetText, Edit1  ; clear
  ; }
return

AllLapsesToday:
  SetToolTip("Executing..."), pidSM := WinGet("PID", "ahk_class TElWind")
  BlockInput, On
  SM.PostMsg(31)  ; export rep history
  WinWaitActive, ahk_class TFileBrowser
  TempPath := A_Temp . "\Repetition History_" . SM.GetCollName() . "_"
            . t := GetCurrTimeForFileName() . ".txt"
  TempOutputPath := A_Temp . "\All Lapses Today_" . SM.GetCollName() . "_"
                  . t . ".txt"
  SM.FileBrowserSetPath(TempPath, true)
  WinWaitActive % "Information ahk_class TMsgDialog ahk_pid " . pidSM
  Send {Enter}
  RepHistory := FileReadAndDelete(TempPath)
  DateRegEx := "Date=" . FormatTime(, "dd\.MM\.yyyy")
  pos := 1, v1 := ""
  while (pos := RegExMatch(RepHistory, "s)\nItem #[\d,]+: ([^\n]+)\n[^\n]+"
                                     . DateRegEx . "[^\n]+Grade=[0-2]", v, pos + StrLen(v1)))
    FileAppend, % v1 . "`n", % TempOutputPath
  ShellRun(TempOutputPath)
  BlockInput, Off
return

Lexico:
  if (word := FindSearchIB("Lexico", "Word:"))
    ShellRun("https://web.archive.org/web/*/www.lexico.com/definition/" . word)
return

ExternaliseRegistry:
  ; Images, Sounds, Binary, Video
  for i, v in [156, 157, 171, 170] {  ; sm19
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm18.exe")
      v++
    SM.PostMsg(v)
    WinWaitActive, ahk_class TRegistryForm
    if (IfContains(WinGetTitle(), "(0 members)")) {
      WinClose
      Continue
    }
    Send {Down}
    if (IfContains(WinGetTitle(), "Video Registry"))
      ControlTextWaitExist("Edit1",,,,, 1500)
    Send {AppsKey}tt
    WinWaitActive, ahk_class TMsgDialog
    Send {Enter}
    WinWaitActive, ahk_class TMsgDialog
    Send {Enter}
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
  SM.EditBar(n), Vim.State.SetNormal()
return

BoldText:
ItalicText:
UnderscoreText:
  if (A_ThisLabel == "BoldText") {
    Send ^b
  } else if (A_ThisLabel == "ItalicText") {
    Send ^i
  } else if (A_ThisLabel == "UnderscoreText") {
    Send ^u
  }
  Vim.State.SetNormal()
return

Tatoeba:
  if (word := FindSearchIB("Tatoeba", "Word:"))
    ShellRun("https://tatoeba.org/en/sentences/search?query=" . word)
return

MD2HTML:
  Vim.State.SetMode("Vim_Normal")
  ClipSaved := ClipboardAll
  if (!MD := Copy(false)) {
    Clipboard := ClipSaved
    return
  }
  TempMDPath := A_Temp . "\" . (t := GetCurrTimeForFileName()) . "_md.md"
  FileDelete % TempMDPath
  FileAppend, % MD, % TempMDPath
  TempHTMLPath := A_Temp . "\" . t . "_html.html"
  FileAppend,, % TempHTMLPath
  ShellRun("pandoc", TempMDPath . " -s -o " . TempHTMLPath)
  loop {
    if (t := FileRead(TempHTMLPath))
      Break
    Sleep 100
  }
  RegExMatch(t, "s)<body>\K.*(?=<\/body>)", v)
  WinWaitActive % "ahk_id " . hWnd
  Clip(v,, false, SM.IsEditingHTML() ? "sm" : Vim.IsHTML())
  Clipboard := ClipSaved
return

CleanHTML:
  if (HTMLPath := FindSearchIB("Clean HTML", "Path:")) {
    FileAppend, % SM.CleanHTML(FileReadAndDelete(HTMLPath)), % HTMLPath
    SetToolTip("Completed.")
  } else {
    SetToolTip("Not found.")
  }
return

SaveFile:
  uiaBrowser := new UIA_Browser("A")
  Url := uiaBrowser.GetCurrentURL(true)
  if (r := RegExMatch(Url, "\/[^\/\.]+\.[^\/\.]+$", v))
    UrlDownloadToFile, % Url, % FilePath := "d:" . v
  if (!r || ErrorLevel) {
    SetToolTip("Failed.")
    return
  }
  SplitPath, FilePath, name, dir, ext, NameNoExt
  if (ext = "ogg")
    RunWait, % "cmd /c ffmpeg -i """ . FilePath . """ -acodec libmp3lame """ . dir . "\" . NameNoExt . ".mp3"" && del """ . FilePath . """",, Hide
  SetToolTip("Success.")
return

EPUB2TXT:
  if (EpubPath := FindSearchIB("EPUB2TXT", "Path:")) {
    TxtPath := StrReplace(EpubPath, ".epub", ".txt")
    RunWait, % "pandoc -f epub -t plain -o """ . TxtPath . """ """ . EpubPath . """",, Hide
    SetToolTip("Completed.")
  } else {
    SetToolTip("Not found.")
  }
return

PasteCleanedClipboard:
  ClipboardGet_HTML(HTML)
  HTML := SM.CleanHTML(GetClipHTMLBody(HTML),,, GetClipLink(HTML))
  Clip(HTML,,, (SM.IsEditingHTML() ? "sm" : true))
  Vim.State.SetNormal(), HTML := ""
return

ArchiveToday:
  WinWaitActive % "ahk_id " . hWnd
  if (WinActive("ahk_group Browser")) {
    uiaBrowser := new UIA_Browser("A")
    Url := FindSearchIB("Archive Today", "URL:", uiaBrowser.GetCurrentURL(), true)
  } else if (WinActive("ahk_class TElWind")) {
    Url := FindSearchIB("Archive Today", "URL:", SM.GetLink(), true)
  } else if (!Url := FindSearchIB("Today", "URL:")) {
    return
  }
  if (Url)
    ShellRun("https://archive.today/?run=1&url=" . Url)
return

WolframAlpha:
  if (Text := FindSearchIB("WolframAlpha", "Text:"))
    ShellRun("https://www.wolframalpha.com/input?input=" . EncodeDecodeURI(Text))
Return

Comment:
  SM.EditRef()
  WinWaitActive, ahk_class TInputDlg
  Ref := ControlGetText("TMemo1")
  RegExMatch(Ref, "#Comment: (.*)|$", v), PrevComment := v1
  Comment := InputBox(, "Set comment:",,,,,,,, PrevComment)
  WinWaitActive, ahk_class TInputDlg
  if (ErrorLevel) {
    WinClose
    return
  }
  if (Comment) {
    Ref := "#Comment: " . Comment . "`r`n" . Ref
  } else {
    Ref := RegExReplace(Ref, "#Comment:.*")
  }
  ControlSetText, TMemo1, % Ref
  Send ^{Enter}
  WinWaitClose
  Vim.State.SetNormal()
return

MassProcessBrowser:
  loop {
    Send +{Enter}
    WinWaitActive, ahk_class TElWind
    Send ^+{f12}
    WinWaitActive, ahk_class TMsgDialog
    Send {Enter}
    WinWaitClose
    SM.EditFirstQuestion()
    SM.WaitHTMLFocus()
    Send ^{Home}^+{Right 3}!{f12}rh
    Sleep 100
    Send {Esc}
    SM.WaitTextExit()
    WinActivate, ahk_class TBrowser
    Send {Down}
    SM.WaitFileLoad()
  }
return

MarkAsOnlineProgress:
  SM.EditFirstQuestion()
  for i, v in % SM.GetTextArray() {
    FirstText := v.Name
    if (FirstText == "#SuperMemo Reference:")
      FirstText := ""
    Break
  }
  SM.WaitHTMLFocus()
  Send ^{Home}
  if (FirstText && (FirstText != "SMVim: Use online video progress")) {
    FirstText := ""
    Send {Enter}{Up}
  }
  if (!FirstText)
    Clip("<SPAN class=Highlight>SMVim: Use online video progress</SPAN>",,, "sm")
  SM.ExitText(), Vim.State.SetMode("Vim_Normal")
return

Tag:
  Gui, SMTag:Add, Text,, &Add tags (without # and use `; to separate):
  Gui, SMTag:Add, Edit, vTags w350 r1 -WantReturn
  Gui, SMTag:Add, Checkbox, vEditRefComment Checked, Also add to reference &comment
  Gui, SMTag:Add, Button, Default, &Tag
  Gui, SMTag:Show,, Tag
  SetDefaultKeyboard(0x0409)  ; English-US
Return

SMTagGuiEscape:
SMTagGuiClose:
  Vim.State.SetMode("Vim_Normal")
  Gui, Destroy
return

SMTagButtonTag:
  Gui, Submit
  Gui, Destroy
SMTagEntered:
  Vim.State.SetMode("Vim_Normal")
  wSMElWind := (A_ThisLabel == "SMTagEntered") ? wSMElWind : "ahk_class TElWind"
  SM.LinkConcepts(aTags := StrSplit(Tags, ";"), wSMElWind)
  if (EditRefComment) {
    SM.EditRef(wSMElWind)
    WinWait, % "ahk_class TInputDlg ahk_pid " . WinGet("PID", wSMElWind)
    Ref := ControlGetText("TMemo1")
    RegExMatch(Ref, "#Comment: (.*)|$", v), Comment := v1
    loop % aTags.MaxIndex() {
      Tag := StrReplace(aTags[A_Index], " ", "_")
      if (!IfContains(Comment, "#" . Tag))
        Comment .= " #" . Tag
    }
    Ref := "#Comment: " . Comment . "`n" . Ref
    ControlSetText, TMemo1, % Ref
    ControlSend, TMemo1, {Ctrl Down}{Enter}{Ctrl Up}  ; submit
    WinWaitClose
  }
  SetToolTip("Tagging finished.")
return

PasteHTML:
  ClipHTML := GetClipHTMLBody()
  WinClip.Clear()
  Clipboard := ClipHTML
  ClipWait
  Send ^v
  ClipHTML := ""
return
