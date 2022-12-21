class VimBrowser {
  __New(Vim) {
    this.Vim := Vim
    this.FullPageCopyTimeout := 2.5
  }

  Clear() {
    this.title := this.url := this.source := this.date := this.VidTime := this.comment := this.VidSite := ""
    global guiaBrowser := ""
  }

  GetInfo(RestoreClip:=true, CopyFullPage:=true, PressButton:=true) {
    this.clear()
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
    this.GetUrl(, false)
    if (PressButton)
      gosub PressYTShowMoreButton
    this.GetTitleSourceDate(false, CopyFullPage)
    if (RestoreClip)
      Clipboard := ClipSaved
  }

  ParseUrl(url) {
    url := RegExReplace(url, "#.*")
    if (InStr(url, "youtube.com/watch")) {
      url := StrReplace(url, "app=desktop&")
      url := RegExReplace(url, "&.*")
    } else if (InStr(url, "bilibili.com/video")) {
      url := RegExReplace(url, "(\?(?!p=[0-9]+)|&).*")
    } else if (InStr(url, "netflix.com/watch")) {
      url := RegExReplace(url, "\?trackId=.*")
    } else if (InStr(url, "baike.baidu.com")) {
      url := RegExReplace(url, "\?.*")
    }
    return url
  }

  GetTitleSourceDate(RestoreClip:=true, CopyFullPage:=true) {
    this.Title := this.RemoveBrowserName(WinGetTitle())
    this.VidSite := this.IsVidSite(this.title)
    this.url := this.url ? this.url : this.GetUrl(, RestoreClip)

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
    } else if (this.title ~= "^Discord \| ") {
      this.source := "Discord"
      this.title := RegExReplace(this.title, "^Discord \| ")
    } else if (this.title ~= "^italki - ") {
      this.source := "italki"
      this.title := RegExReplace(this.title, "^italki - ")

    } else if (this.Title ~= "_百度百科$") {
      this.Source := "百度百科"
      this.Title := RegExReplace(this.Title, "_百度百科$")
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
    } else if (this.title ~= " -- ScienceDaily$") {
      this.source := "ScienceDaily"
      this.title := RegExReplace(this.title, " -- ScienceDaily$")
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

    } else if (IfContains(this.Url, "reddit.com")) {
      RegExMatch(this.Url, "reddit\.com\/\Kr\/[^\/]+", Source)
      this.source := source
      this.Title := RegExReplace(this.Title, " : " . StrReplace(Source, "r/") . "$")
    } else if (IfContains(this.Url, "github.com")) {
      this.Source := "Github"
      if (RegExMatch(this.url, "github\.com\/.+?\/(.+?)(\/|$)", v))
        this.source .= ": " . v1

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

    ; Sites that should be skipped
    SkippedList := "mp.weixin.qq.com,blackrock.com,superdatascience.com"
    } else if (IfContains(this.Url, SkippedList)) {
      return

    ; Sites that require special attention
    } else if (IfContains(this.url, "youtube.com/watch")) {
      this.source := "YouTube"
      this.title := RegExReplace(this.title, " - YouTube$")
      if (CopyFullPage && (text := this.GetFullPage(" - YouTube", RestoreClip))) {
        this.VidTime := this.MatchYTTime(text)
        this.date := this.MatchYTDate(text)
        if (source := this.MatchYTSource(text))
          this.source .= ": " . source
      }
    } else if (this.url ~= "bilibili.com/video") {
      this.Source := "哔哩哔哩"
      this.Title := RegExReplace(this.Title, "_哔哩哔哩_bilibili$")
      if (CopyFullPage && (text := this.GetFullPage("_哔哩哔哩_bilibili", RestoreClip))) {
        this.VidTime := this.MatchBLTime(text)
        this.date := this.MatchBLDate(text)
        if (source := this.MatchBLSource(text))
          this.source .= "：" . source
      }

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
      }
      pos := separator ? InStr(StrReverse(this.Title), separator) : 0
      if (pos) {
        TitleLength := StrLen(this.Title) - pos - StrLen(separator) + 1
        this.Source := SubStr(this.Title, TitleLength + 1, StrLen(this.Title))
        this.Source := StrReplace(this.Source, separator,,, 1)
        this.Title := SubStr(this.Title, 1, TitleLength)
      }
    }
  }

  GetFullPage(title:="", RestoreClip:=true) {
    title := title ? title : this.RemoveBrowserName(WinGetTitle())
    if (RestoreClip)
      ClipSaved := ClipboardAll
    if (BL := RegExMatch(title, "_哔哩哔哩_bilibili$")) {
      send ^{home}
      MouseGetPos, XSaved, YSaved
      MouseMove, % A_ScreenWidth / 2, % A_ScreenHeight / 2
      sleep 20
    }
    global WinClip
    WinClip.Clear()
    send ^a^{ins}
    ClipWait % this.FullPageCopyTimeout
    send {esc}
    text := Clipboard
    if (BL)
      MouseMove, XSaved, YSaved
    if (RestoreClip)
      Clipboard := ClipSaved
    return text
  }

  GetSecFromTime(TimeStamp) {
    TimeArr := StrSplit(TimeStamp, ":")
    TimeArr := RevArr(TimeArr)
    TimeArr[3] := TimeArr[3] ? TimeArr[3] : 0
    return (TimeArr[1] + TimeArr[2] * 60 + TimeArr[3] * 3600)
  }

  ; GetAddressBarUrl(method:=1) {
  ;   if (method) {
  ;     guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
  ;     return guiaBrowser.GetCurrentURL(true)
  ;   } else {
  ;     hwnd := hwnd ? hwnd : WinGet()
  ;     if (browser = "chrome" || WinActive("ahk_exe chrome.exe")) {
  ;       accAddressBar := Acc_Get("Object", "4.1.1.2.1.2.5.3",, "ahk_id " . hwnd)
  ;     } else if (browser = "edge" || WinActive("ahk_exe msedge.exe")) {
  ;       accAddressBar := Acc_Get("Object", "4.1.1.4.1.2.5.4",, "ahk_id " . hwnd)
  ;     }
  ;     return accAddressBar.accValue(0)
  ;   }
  ; }

  GetVidTime(title:="", FullPageText:="", RestoreClip:=true) {
    title := title ? title : this.RemoveBrowserName(WinGetTitle())
    if (!this.IsVidSite(title))
      return
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global WinClip
    WinClip.Clear()
    FullPageText := FullPageText ? FullPageText : this.GetFullPage(title, false)
    if (title ~= " - YouTube$") {
      VidTime := this.MatchYTTime(FullPageText)
    } else if (title ~= "_哔哩哔哩_bilibili$") {
      VidTime := this.MatchBLTime(FullPageText)
    }
    if (RestoreClip)
      Clipboard := ClipSaved
    return this.VidTime := VidTime
  }

  GetUrl(method:=1, RestoreClip:=true) {
    if (!method) {
      this.title := this.title ? this.title : this.RemoveBrowserName(WinGetTitle())
      if (this.title = "New Tab")
        return
      send {f6}^l^l  ; go to address bar; twice ^l to update link
      sleep 100
      if (RestoreClip)
        ClipSaved := ClipboardAll
      global WinClip
      WinClip.Clear()
      while (!Clipboard) {
        send ^l^c
        ClipWait 0.2
      }
      this.url := this.ParseUrl(Clipboard)
      send {esc}
      if (RestoreClip)
        Clipboard := ClipSaved
      return this.url
    } else {
      global guiaBrowser
      if (!guiaBrowser)
        guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
      url := guiaBrowser.GetCurrentURL()
      return this.url := this.ParseUrl(url)
    }
  }

  MatchYTTime(text) {
    RegExMatch(text, "\r\n([0-9:]+) \/ ([0-9:]+)", VidTime)
    if (VidTime1 == VidTime2)  ; at end of video
      VidTime1 := "0:00"
    return VidTime1
  }

  MatchYTSource(text) {
    ; RegExMatch(text, "i)SAVE(\r\n){3}\K.*", YTSource)
    RegExMatch(text, ".*(?=\r\n.*subscribers)", YTSource)
    return YTSource
  }

  MatchYTDate(text) {
    RegExMatch(text, "views +?((Streamed live|Premiered) on )?\K[0-9]+ \w+ [0-9]+", date)
    return date
  }

  MatchBLTime(text) {
    RegExMatch(text, "\r\n\K[0-9:]+(?= \/ )", VidTime)
    return VidTime
  }

  MatchBLSource(text) {
    RegExMatch(text, "m)^.*(?=\r\n 发消息)", BLSource)
    return BLSource
  }

  MatchBLDate(text) {
    RegExMatch(text, "\n\K[0-9]{4}-[0-9]{2}-[0-9]{2}", date)
    return date
  }

  RunInIE(url) {
    if (!el := WinExist("ahk_class IEFrame ahk_exe iexplore.exe")) {
      ie := ComObjCreate("InternetExplorer.Application")
      ie.Visible := true
      ie.Navigate(url)
    } else {
      if (ControlGetText("Edit1", "ahk_class IEFrame ahk_exe iexplore.exe")) {  ; current page is not new tab page
        UIA := UIA_Interface()
        el := UIA.ElementFromHandle(el)
        el.FindFirstBy("ControlType=Button AND Name='New tab (Ctrl+T)'").Click()
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
    return RegExMatch(title, "( - YouTube|_哔哩哔哩_bilibili)$")
  }

  Highlight() {
    send !+h  ; more robust than ControlSend
    sleep 20
  }

  GetYTShowMoreButton() {
    this.url := this.url ? this.url : this.GetUrl()
    if (!IfContains(this.url, "youtube.com/watch"))
      return
    global guiaBrowser
    if (!guiaBrowser)
      guiaBrowser := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
    if (!Button := guiaBrowser.FindFirstBy("ControlType=Button AND Name='Show more' AND AutomationId='expand'"))
      Button := guiaBrowser.FindFirstBy("ControlType=Text AND Name='Show more'")
    return Button
  }
}

PressYTShowMoreButton:
  if (button := vim.Browser.GetYTShowMoreButton()) {
    button.click(400)
    send ^{home}
  }
  PressYTShowMoreButtonDone := true
return