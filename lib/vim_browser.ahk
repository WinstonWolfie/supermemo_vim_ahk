class VimBrowser {
  __New(Vim) {
    this.Vim := Vim
    this.FullPageCopyTimeout := 2.5
  }

  Clear() {
    this.title := this.url := this.source := this.date := this.comment := this.VidTime := this.author := this.FullTitle := ""
    global guiaBrowser := ""
  }

  GetInfo(RestoreClip:=true, CopyFullPage:=true, PressButton:=true) {
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global guiaBrowser
    if (!guiaBrowser)
      guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
    this.GetUrl()
    if (PressButton)
      gosub PressBrowserBtn
    this.GetTitleSourceDate(false, CopyFullPage)
    if (RestoreClip)
      Clipboard := ClipSaved
  }

  ParseUrl(url) {
    url := RegExReplace(url, "#.*")
    if (IfContains(url, "youtube.com/watch")) {
      url := StrReplace(url, "app=desktop&")
      url := RegExReplace(url, "&.*")
    } else if (IfContains(url, "bilibili.com/video")) {
      url := RegExReplace(url, "(\?(?!p=[0-9]+)|&).*")
    } else if (IfContains(url, "netflix.com/watch")) {
      url := RegExReplace(url, "\?trackId=.*")
    } else if (IfContains(url, "baike.baidu.com")) {
      url := RegExReplace(url, "\?.*")
    }
    return url
  }

  GetTitleSourceDate(RestoreClip:=true, CopyFullPage:=true, FullPageText:="", GetUrl:=true) {
    this.FullTitle := this.FullTitle ? this.FullTitle : this.RemoveBrowserName(WinGetTitle())
    this.Title := this.title ? this.title : this.FullTitle
    if (GetUrl)
      this.url := this.url ? this.url : this.GetUrl()

    ; Sites that have source in their title
    if (this.Title ~= "^很帅的日报") {
      this.Date := RegExReplace(this.Title, "^很帅的日报 ")
      this.Title := "很帅的日报"
    } else if (this.title ~= "^Frontiers \| ") {
      this.source := "Frontiers"
      this.title := RegExReplace(this.title, "^Frontiers \| ")
    } else if (this.title ~= "^NIMH » ") {
      this.source := "NIMH"
      this.title := RegExReplace(this.title, "^NIMH » ")
    } else if (this.title ~= "^• Discord \| ") {
      this.source := "Discord"
      this.title := RegExReplace(this.title, "^• Discord \| ")
    } else if (this.title ~= "^italki - ") {
      this.source := "italki"
      this.title := RegExReplace(this.title, "^italki - ")

    } else if (this.Title ~= "_百度知道$") {
      this.Source := "百度知道"
      this.Title := RegExReplace(this.Title, "_百度知道$")
    } else if (this.Title ~= "-新华网$") {
      this.Source := "新华网"
      this.Title := RegExReplace(this.Title, "-新华网$")
    } else if (this.title ~= ": MedlinePlus Medical Encyclopedia$") {
      this.source := "MedlinePlus Medical Encyclopedia"
      this.title := RegExReplace(this.title, ": MedlinePlus Medical Encyclopedia$")
    } else if (this.title ~= " - supermemo\.guru$") {
      this.source := "SuperMemo Guru"
      this.title := RegExReplace(this.title, " - supermemo\.guru$")
    } else if (this.title ~= "_英为财情Investing.com$") {
      this.source := "英为财情"
      this.title := RegExReplace(this.title, "_英为财情Investing.com$")
    } else if (this.title ~= " \| OSUCCC - James$") {
      this.source := "OSUCCC - James"
      this.title := RegExReplace(this.title, " \| OSUCCC - James$")
    } else if (this.title ~= " · GitBook$") {
      this.source := "GitBook"
      this.title := RegExReplace(this.title, " · GitBook$")
    } else if (this.title ~= " \| SLEEP \| Oxford Academic$") {
      this.source := "SLEEP | Oxford Academic"
      this.title := RegExReplace(this.title, " \| SLEEP \| Oxford Academic$")
    } else if (this.title ~= " \| Microbiome \| Full Text$") {
      this.source := "Microbiome"
      this.title := RegExReplace(this.title, " \| Microbiome \| Full Text$")
    } else if (this.title ~= "-清华大学医学院$") {
      this.source := "清华大学医学院"
      this.title := RegExReplace(this.title, "-清华大学医学院$")
    } else if (this.title ~= "- 雪球$") {
      this.source := "雪球"
      this.title := RegExReplace(this.title, "- 雪球$")
    } else if (this.title ~= "\| Neuron Glia Biology \| Cambridge Core$") {
      this.source := "Neuron Glia Biology | Cambridge Core"
      this.title := RegExReplace(this.title, "\| Neuron Glia Biology \| Cambridge Core$")

    } else if (IfContains(this.Url, "reddit.com")) {
      RegExMatch(this.Url, "reddit\.com\/\Kr\/[^\/]+", Source)
      this.source := source, this.Title := RegExReplace(this.Title, " : " . StrReplace(Source, "r/") . "$")

    ; Sites that don't include source in the title
    } else if (IfContains(this.Url, "dailystoic.com")) {
      this.Source := "Daily Stoic"
    } else if (IfContains(this.Url, "healthline.com")) {
      this.Source := "Healthline"
    } else if (IfContains(this.Url, "webmd.com")) {
      this.Source := "WebMD"
    } else if (IfContains(this.Url, "medicalnewstoday.com")) {
      this.Source := "Medical News Today"
    } else if (IfContains(this.Url, "investopedia.com")) {
      this.Source := "Investopedia"
    } else if (IfContains(this.Url, "universityhealthnews.com")) {
      this.source := "University Health News"
    } else if (IfContains(this.url, "verywellmind.com")) {
      this.source := "Verywell Mind"
    } else if (IfContains(this.url, "cliffsnotes.com")) {
      this.source := "CliffsNotes"
    } else if (IfContains(this.url, "w3schools.com")) {
      this.source := "W3Schools"
    } else if (IfContains(this.url, "news-medical.net")) {
      this.source := "News-Medical"
    } else if (IfContains(this.url, "ods.od.nih.gov")) {
      this.source := "National Institutes of Health: Office of Dietary Supplements"
    } else if (IfContains(this.url, "vandal.elespanol.com")) {
      this.source := "Vandal"
    } else if (IfContains(this.url, "fidelity.com")) {
      this.source := "Fidelity International"
    } else if (IfContains(this.Url, "github.com")) {
      this.source := "Github"

    ; Sites that should be skipped
    SkippedList := "mp.weixin.qq.com,blackrock.com,superdatascience.com"
    } else if (IfContains(this.Url, SkippedList)) {
      ret := ""

    ; Sites that require special attention
    } else if (IfContains(this.url, "youtube.com/watch")) {
      this.source := "YouTube"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(this.title, RestoreClip)))) {
        this.VidTime := this.MatchVidTime(this.title, FullPageText)
        this.date := this.MatchYTDate(FullPageText)
        if (author := this.MatchYTAuthor(FullPageText))
          this.author := author
      }
      this.title := RegExReplace(this.title, " - YouTube$")
    } else if (this.title ~= "_哔哩哔哩_bilibili$") {
      this.Source := "哔哩哔哩"
      if (IfContains(this.url, "bilibili.com/video")
       && CopyFullPage
       && (FullPageText || (FullPageText := this.GetFullPage(this.title, RestoreClip)))) {
        this.VidTime := this.MatchVidTime(this.title)
        this.date := this.MatchBLDate(FullPageText)
        if (author := this.MatchBLAuthor(FullPageText))
          this.author := author
      }
      this.Title := RegExReplace(this.Title, "_哔哩哔哩_bilibili$")
    } else if (this.title ~= " 在线播放 - 小宝影院 - 在线视频$") {
      this.Source := "小宝影院"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(this.title, RestoreClip))))
        this.VidTime := this.MatchVidTime(this.title, FullPageText)
      this.Title := RegExReplace(this.Title, " 在线播放 - 小宝影院 - 在线视频$")
    } else if (this.title ~= "-在线播放 - 唐人街影院-海外华人影视网站-在线高清播放$") {
      this.source := "唐人街影院"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(this.title, RestoreClip))))
        this.VidTime := this.MatchVidTime(this.title, FullPageText)
      this.title := RegExReplace(this.title, "-在线播放 - 唐人街影院-海外华人影视网站-在线高清播放$")
    } else if (IfContains(this.url, "en.wikipedia.org")) {
      this.Source := "Wikipedia"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(this.title, RestoreClip)))) {
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v)
        this.date := v1
      }
      this.title := RegExReplace(this.title, " - Wikipedia$")
    } else if (IfContains(this.url, "en.wiktionary.org")) {
      this.Source := "Wiktionary"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(this.title, RestoreClip)))) {
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v)
        this.date := v1
      }
      this.title := RegExReplace(this.title, " - Wiktionary$")
    } else if (this.Title ~= "_百度百科$") {
      this.Source := "百度百科"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(this.title, RestoreClip)))) {
        RegExMatch(FullPageText, "最近更新：.*（(.*)）", v)
        this.date := v1
      }
      this.Title := RegExReplace(this.Title, "_百度百科$")
    } else if (IfContains(this.url, "zh.wikipedia.org")) {
      this.Source := "维基百科"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(this.title, RestoreClip)))) {
        RegExMatch(FullPageText, "本页面最后修订于(.*?) \(", v)
        this.date := v1
      }
      this.title := RegExReplace(this.title, " - 维基百科，自由的百科全书$")
    } else if (IfContains(this.url, "es.wikipedia.org")) {
      this.Source := "Wikipedia"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(this.title, RestoreClip)))) {
        RegExMatch(FullPageText, "Esta página se editó por última vez el (.*?) a las ", v)
        this.date := v1
      }
      this.title := RegExReplace(this.title, " - Wikipedia, la enciclopedia libre$")

    ; Try to use - or | to find source
    } else {
      ReversedTitle := StrReverse(this.Title)
      if (IfContains(ReversedTitle, " | ")
       && (!IfContains(ReversedTitle, " - ")
        || InStr(ReversedTitle, " | ") < InStr(ReversedTitle, " - "))) {  ; used to find source
        separator := " | "
      } else if (IfContains(ReversedTitle, " - ")) {
        separator := " - "
      } else if (IfContains(ReversedTitle, " – ")) {
        separator := " – "  ; sites like BetterExplained
      } else if (IfContains(ReversedTitle, " — ")) {
        separator := " — "
      } else if (IfContains(ReversedTitle, " -- ")) {
        separator := " -- "
      } else if (IfContains(ReversedTitle, " • ")) {
        separator := " • "
      }
      pos := separator ? InStr(StrReverse(this.Title), separator) : 0
      if (pos) {
        TitleLength := StrLen(this.Title) - pos - StrLen(separator) + 1
        this.Source := SubStr(this.Title, TitleLength + 1, StrLen(this.Title))
        this.Source := StrReplace(this.Source, separator,,, 1)
        this.Title := SubStr(this.Title, 1, TitleLength)
      }
    }
    if (RestoreClip)
      Clipboard := ClipSaved
    return ret
  }

  GetFullPage(title:="", RestoreClip:=true) {
    title := title ? title : this.RemoveBrowserName(WinGetTitle())
    if (this.IsVidSite(title) == 2) {
      global guiaBrowser
      if (!guiaBrowser)
        guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
      return guiaBrowser.FindAll(guiaBrowser.TextControlCondition)
    }
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global WinClip
    WinClip.Clear()
    send {CtrlDown}a{Ins}{CtrlUp}{Esc}
    ClipWait % this.FullPageCopyTimeout
    text := Clipboard
    if (RestoreClip)
      Clipboard := ClipSaved
    return text
  }

  GetSecFromTime(TimeStamp) {
    if (!TimeStamp)
      return 0
    TimeArr := StrSplit(TimeStamp, ":")
    TimeArr := RevArr(TimeArr)
    TimeArr[3] := TimeArr[3] ? TimeArr[3] : 0
    return TimeArr[1] + TimeArr[2] * 60 + TimeArr[3] * 3600
  }

  GetVidTime(title:="", FullPageText:="", RestoreClip:=true) {
    title := title ? title : this.RemoveBrowserName(WinGetTitle())
    if (!this.IsVidSite(title))
      return
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global WinClip
    WinClip.Clear()
    VidTime := this.MatchVidTime(title, FullPageText)
    if (RestoreClip)
      Clipboard := ClipSaved
    return VidTime
  }

  GetUrl() {
    global guiaBrowser
    if (!guiaBrowser)
      guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
    url := guiaBrowser.GetCurrentURL()
    return this.ParseUrl(url)
  }

  MatchYTAuthor(text) {
    ; RegExMatch(text, "i)SAVE(\r\n){3}\K.*", YTSource)
    RegExMatch(text, ".*(?=\r\n.*subscribers)", YTSource)
    return YTSource
  }

  MatchYTDate(text) {
    RegExMatch(text, "views +?((Streamed live|Premiered) on )?\K[0-9]+ \w+ [0-9]+", date)
    return date
  }

  MatchBLAuthor(text) {
    RegExMatch(text, "m)^.*(?=\r\n 发消息)", BLSource)
    return BLSource
  }

  MatchBLDate(text) {
    RegExMatch(text, "\n\K[0-9]{4}-[0-9]{2}-[0-9]{2}", date)
    return date
  }

  MatchXBTime(text) {
    RegExMatch(text, "[0-9:]+(?=\r\n \/ )", VidTime)
    return VidTime
  }

  MatchVidTime(title:="", FullPageText:="", RestoreClip:=true) {
    title := title ? title : this.RemoveBrowserName(WinGetTitle())
    if (!BL := (title ~= "_哔哩哔哩_bilibili$"))
      FullPageText := FullPageText ? FullPageText : this.GetFullPage(title, RestoreClip)
    if (title ~= " - YouTube$") {
      RegExMatch(FullPageText, "\r\n([0-9:]+) \/ ([0-9:]+)", v)
      ; v1 = v2 means at end of video
      VidTime := (v1 == v2) ? "0:00" : v1
    } else if (BL) {
      global guiaBrowser
      if (!guiaBrowser)
        guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
      FullPageText := guiaBrowser.FindAll(guiaBrowser.TextControlCondition)
    }
    if (BL || (this.IsVidSite(title) == 2)) {
      for i, v in FullPageText {
        if (v.CurrentName ~= "^(\d{2}:)?\d{2}:\d{2}$") {
          VidTime := v.CurrentName
          break
        }
      }
    }
    return VidTime
  }

  RunInIE(url) {
    if ((url ~= "file:\/\/") && (url ~= "#.*"))
      url := RegExReplace(url, "#.*")
    if (!el := WinExist("ahk_class IEFrame ahk_exe iexplore.exe")) {
      ie := ComObjCreate("InternetExplorer.Application")
      ie.Visible := true
      ie.Navigate(url)
    } else {
      if (ControlGetText("Edit1", "ahk_class IEFrame ahk_exe iexplore.exe")) {  ; current page is not new tab page
        ; UIA := UIA_Interface()
        ; el := UIA.ElementFromHandle(el)
        ; el.FindFirstBy("ControlType=Button AND Name='New tab (Ctrl+T)'").Click()
        ControlSend, ahk_parent, {CtrlDown}t{CtrlUp}, ahk_class IEFrame ahk_exe iexplore.exe
        ControlTextWait("Edit1", "", "ahk_class IEFrame ahk_exe iexplore.exe")
      }
      ControlSetText, Edit1, % url, ahk_class IEFrame ahk_exe iexplore.exe
      ControlSend, Edit1, {enter}, ahk_class IEFrame ahk_exe iexplore.exe
      WinActivate, ahk_class IEFrame ahk_exe iexplore.exe
    }
  }

  RemoveBrowserName(title) {
    return RegExReplace(title, "( - Google Chrome| — Mozilla Firefox|( and [0-9]+ more pages?)? - [^-]+ - Microsoft​ Edge)$")
  }

  IsVidSite(title:="") {
    title := title ? title : this.RemoveBrowserName(WinGetTitle())
    if (title ~= "( - YouTube|_哔哩哔哩_bilibili)$") {
      return 1
    } else if (title ~= "( 在线播放 - 小宝影院 - 在线视频|-在线播放 - 唐人街影院-海外华人影视网站-在线高清播放)$") {
      return 2
    }
  }

  Highlight() {
    send !+h
    sleep 100
    ; ControlSend doesn't work reliably because browser can't highlight in background
		; ControlSend, ahk_parent, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}, % "ahk_id " . WinGet()
    ; ControlSend, ahk_parent, {AltDown}{ShiftDown}h{AltUp}{ShiftUp}, % "ahk_id " . WinGet()
  }

  ClickBtn() {
    this.url := this.url ? this.url : this.GetUrl()
    if (IfContains(this.url, "youtube.com/watch")) {
      global guiaBrowser
      if (!guiaBrowser)
        guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
      if (!btn := guiaBrowser.FindFirstBy("ControlType=Button AND Name='Show more' AND AutomationId='expand'"))
        btn := guiaBrowser.FindFirstBy("ControlType=Text AND Name='Show more'")
      if (btn) {
        btn.click(500)
        send ^{home}
      }
    }
  }
}

PressBrowserBtn:
  Vim.Browser.ClickBtn()
  PressBrowserBtnDone := true
return