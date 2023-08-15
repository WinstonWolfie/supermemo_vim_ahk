class VimBrowser {
  __New(Vim) {
    this.Vim := Vim
  }

  Clear() {
    this.title := this.url := this.source := this.date := this.comment := this.VidTime := this.author := this.FullTitle := ""
    global guiaBrowser := ""
  }

  GetInfo(RestoreClip:=true, CopyFullPage:=true, PressButton:=true) {
    global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
    this.url := this.GetParsedUrl()
    if (PressButton)
      this.ClickBtn()
    this.GetTitleSourceDate(RestoreClip, CopyFullPage)
  }

  ParseUrl(url) {
    url := RegExReplace(url, "#.*")
    ; Remove everything after "?"
    QuestionMarkList := "baike.baidu.com,bloomberg.com"
    if (IfContains(url, QuestionMarkList)) {
      url := RegExReplace(url, "\?.*")
    } else if (IfContains(url, "youtube.com/watch")) {
      url := StrReplace(url, "app=desktop&"), url := RegExReplace(url, "&.*")
    } else if (IfContains(url, "bilibili.com")) {
      url := RegExReplace(url, "(\?(?!p=\d+)|&).*")
      url := RegExReplace(url, "\/(?=\?p=\d+)")
    } else if (IfContains(url, "netflix.com/watch")) {
      url := RegExReplace(url, "\?trackId=.*")
    } else if (IfContains(url, "finance.yahoo.com")) {
      url := RegExReplace(url, "\?p=.*|\/$")
    } else if (IfContains(url, "dle.rae.es")) {
      url := StrReplace(url, "?m=form")
    }
    return url
  }

  GetTitleSourceDate(RestoreClip:=true, CopyFullPage:=true, FullPageText:="", GetUrl:=true) {
    this.FullTitle := this.FullTitle ? this.FullTitle : this.GetFullTitle()
    this.Title := this.title ? this.title : this.FullTitle
    if (GetUrl)
      this.url := this.url ? this.url : this.GetParsedUrl()

    if (this.title ~= " - YouTube$")
      this.title := RegExReplace(this.title, "^\(\d+\) ")

    ; Sites that should be skipped
    SkippedList := "wind.com.cn,thepokerbank.com"
    if (IfContains(this.Url, SkippedList)) {
      return

    ; Sites that have source in their title
    } else if (this.Title ~= "^很帅的日报") {
      this.Date := RegExReplace(this.Title, "^很帅的日报 "), this.Title := "很帅的日报"
    } else if (this.title ~= "^Frontiers \| ") {
      this.source := "Frontiers", this.title := RegExReplace(this.title, "^Frontiers \| ")
    } else if (this.title ~= "^NIMH » ") {
      this.source := "NIMH", this.title := RegExReplace(this.title, "^NIMH » ")
    } else if (this.title ~= "^• Discord \| ") {
      this.source := "Discord", this.title := RegExReplace(this.title, "^• Discord \| ")
    } else if (this.title ~= "^italki - ") {
      this.source := "italki", this.title := RegExReplace(this.title, "^italki - ")
    } else if (this.title ~= "^CSOP - Products - ") {
      this.source := "CSOP Asset Management", this.title := RegExReplace(this.title, "^CSOP - Products - ")
    ; } else if (this.title ~= "^GitHub - ") {
      ; this.source := "GitHub", this.title := RegExReplace(this.title, "^GitHub - ")
    } else if (this.title ~= "^ArtStation - ") {
      this.source := "ArtStation", this.title := RegExReplace(this.title, "^ArtStation - ")
    } else if (this.title ~= "^Art... When I Feel Like It - ") {
      this.source := "Art... When I Feel Like It ", this.title := RegExReplace(this.title, "^Art... When I Feel Like It - ")
    } else if (this.title ~= "^Henry George Liddell, Robert Scott, An Intermediate Greek-English Lexicon, ") {
      this.author := "Henry George Liddell, Robert Scott", this.source := "An Intermediate Greek-English Lexicon", this.title := RegExReplace(this.title, "^Henry George Liddell, Robert Scott, An Intermediate Greek-English Lexicon, ")

    } else if (this.Title ~= "_百度知道$") {
      this.Source := "百度知道", this.Title := RegExReplace(this.Title, "_百度知道$")
    } else if (this.Title ~= "-新华网$") {
      this.Source := "新华网", this.Title := RegExReplace(this.Title, "-新华网$")
    } else if (this.title ~= ": MedlinePlus Medical Encyclopedia$") {
      this.source := "MedlinePlus Medical Encyclopedia", this.title := RegExReplace(this.title, ": MedlinePlus Medical Encyclopedia$")
    } else if (this.title ~= "_英为财情Investing.com$") {
      this.source := "英为财情", this.title := RegExReplace(this.title, "_英为财情Investing.com$")
    } else if (this.title ~= " \| OSUCCC - James$") {
      this.source := "OSUCCC - James", this.title := RegExReplace(this.title, " \| OSUCCC - James$")
    } else if (this.title ~= " · GitBook$") {
      this.source := "GitBook", this.title := RegExReplace(this.title, " · GitBook$")
    } else if (this.title ~= " \| SLEEP \| Oxford Academic$") {
      this.source := "SLEEP | Oxford Academic", this.title := RegExReplace(this.title, " \| SLEEP \| Oxford Academic$")
    } else if (this.title ~= " \| Microbiome \| Full Text$") {
      this.source := "Microbiome", this.title := RegExReplace(this.title, " \| Microbiome \| Full Text$")
    } else if (this.title ~= "-清华大学医学院$") {
      this.source := "清华大学医学院", this.title := RegExReplace(this.title, "-清华大学医学院$")
    } else if (this.title ~= "- 雪球$") {
      this.source := "雪球", this.title := RegExReplace(this.title, "- 雪球$")
    } else if (this.title ~= " - Podcasts - SuperDataScience \| Machine Learning \| AI \| Data Science Career \| Analytics \| Success$") {
      this.source := "SuperDataScience", this.title := RegExReplace(this.title, " - Podcasts - SuperDataScience \| Machine Learning \| AI \| Data Science Career \| Analytics \| Success$")
    } else if (this.title ~= " \| Definición \| Diccionario de la lengua española \| RAE - ASALE$") {
      this.source := "Diccionario de la lengua española | RAE - ASALE", this.title := RegExReplace(this.title, " \| Diccionario de la lengua española \| RAE - ASALE$")
    } else if (this.title ~= " • Zettelkasten Method$") {
      this.source := "Zettelkasten Method", this.title := RegExReplace(this.title, " • Zettelkasten Method$")
    } else if (this.title ~= " on JSTOR$") {
      this.source := "JSTOR", this.title := RegExReplace(this.title, " on JSTOR$")
    } else if (this.title ~= " - Queensland Brain Institute - University of Queensland$") {
      this.source := "Queensland Brain Institute - University of Queensland", this.title := RegExReplace(this.title, " - Queensland Brain Institute - University of Queensland$")
    } else if (this.title ~= " \| BMC Neuroscience \| Full Text$") {
      this.source := "BMC Neuroscience", this.title := RegExReplace(this.title, " \| BMC Neuroscience \| Full Text$")
    } else if (this.title ~= " \| MIT News \| Massachusetts Institute of Technology$") {
      this.source := "MIT News | Massachusetts Institute of Technology", this.title := RegExReplace(this.title, " \| MIT News \| Massachusetts Institute of Technology$")
    } else if (RegExMatch(this.title, " \| (.*) \| Cambridge Core$", v)) {
      this.source := v1 . " | Cambridge Core", this.title := RegExReplace(this.title, "\| (.*) \| Cambridge Core$")
    } else if (RegExMatch(this.title, " \| (.*) \| Fandom$", v)) {
      this.source := v1 . " | Fandom", this.title := RegExReplace(this.title, " \| (.*) \| Fandom$")
    } else if (RegExMatch(this.title, " \| (.*) \| The Guardian$", v)) {
      this.source := v1 . " | The Guardian", this.title := RegExReplace(this.title, " \| (.*) \| The Guardian$")
    } else if (RegExMatch(this.title, " - (.*) \| OpenStax$", v)) {
      this.source := v1 . " | OpenStax", this.title := RegExReplace(this.title, " - (.*) \| OpenStax$")

    } else if (this.title ~= " \/ Twitter$") {
      this.source := "Twitter", this.title := RegExReplace(this.title, """ \/ Twitter$")
      RegExMatch(this.title, "^(.*) on Twitter: """, v), this.author := v1
      this.title := RegExReplace(this.title,  "^.* on Twitter: """)

    } else if (RegExMatch(this.title, " \| by (.*?) \| ((.*?) \| )?Medium$", v)) {
      this.source := "Medium", this.title := RegExReplace(this.title, " \| by .*? \| Medium$"), this.author := v1

    } else if (IfContains(this.Url, "reddit.com")) {
      RegExMatch(this.Url, "reddit\.com\/\Kr\/[^\/]+", v), this.source := v, this.Title := RegExReplace(this.Title, " : " . StrReplace(v, "r/") . "$")

    } else if (IfContains(this.Url, "podcasts.google.com")) {
      RegExMatch(this.Title, "^(.*) - ", v), this.Author := v1, this.Title := RegExReplace(this.Title, "^(.*) - "), this.Source := "Google Podcasts"

    ; Sites that don't include source in the title
    } else if (IfContains(this.Url, "dailystoic.com")) {
      this.Source := "Daily Stoic"
    } else if (IfContains(this.Url, "healthline.com")) {
      this.Source := "Healthline"
    } else if (IfContains(this.Url, "webmd.com")) {
      this.Source := "WebMD"
    } else if (IfContains(this.Url, "medicalnewstoday.com")) {
      this.Source := "Medical News Today"
    } else if (IfContains(this.Url, "universityhealthnews.com")) {
      this.source := "University Health News"
    } else if (IfContains(this.url, "verywellmind.com")) {
      this.source := "Verywell Mind"
    } else if (IfContains(this.url, "cliffsnotes.com")) {
      this.source := "CliffsNotes", this.title := RegExReplace(this.title, " \| CliffsNotes$")
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
    } else if (IfContains(this.Url, "eliteguias.com")) {
      this.source := "Eliteguias"
    } else if (IfContains(this.Url, "byjus.com")) {
      this.source := "BYJU'S"
    } else if (IfContains(this.Url, "blackrock.com")) {
      this.source := "BlackRock"
    } else if (IfContains(this.Url, "growbeansprout.com")) {
      this.source := "Beansprout"
    } else if (IfContains(this.Url, "researchgate.net")) {
      this.source := "ResearchGate"
    } else if (IfContains(this.Url, "neuroscientificallychallenged.com")) {
      this.source := "Neuroscientifically Challenged"
    } else if (IfContains(this.Url, "bachvereniging.nl")) {
      this.source := "Netherlands Bach Society"
    } else if (IfContains(this.Url, "tutorialspoint.com")) {
      this.source := "Tutorials Point"
    } else if (IfContains(this.Url, "fourminutebooks.com")) {
      this.source := "Four Minute Books"
    } else if (IfContains(this.Url, "forvo.com")) {
      this.source := "Forvo"
    } else if (IfContains(this.Url, "gutenberg.org")) {
      this.source := "Project Gutenberg"
    } else if (IfContains(this.Url, "finty.com")) {
      this.source := "Finty"

    ; Sites that require special attention
    ; Video sites
    } else if (IfContains(this.url, "youtube.com/watch")) {
      this.source := "YouTube", this.title := RegExReplace(this.title, " - YouTube$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        this.VidTime := this.MatchVidTime(this.FullTitle, FullPageText), this.date := this.MatchYTDate(FullPageText), this.author := this.MatchYTVidAuthor(FullPageText)
    } else if (IfContains(this.url, "youtube.com/playlist")) {
      this.source := "YouTube", this.title := RegExReplace(this.title, " - YouTube$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        this.author := this.MatchYTPLAuthor(FullPageText)
    } else if (this.title ~= "_哔哩哔哩_bilibili$") {
      this.Source := "哔哩哔哩", this.Title := RegExReplace(this.Title, "_哔哩哔哩_bilibili$")
      if (IfContains(this.url, "bilibili.com/video") && CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        this.VidTime := this.MatchVidTime(this.FullTitle), this.date := this.MatchBLDate(FullPageText), this.author := this.MatchBLAuthor(FullPageText)
    } else if (this.title ~= "-bilibili-哔哩哔哩$") {
      this.source := "哔哩哔哩", this.title := RegExReplace(this.title, "-bilibili-哔哩哔哩$")
      if (this.title ~= "-纪录片-全集-高清独家在线观看$")
        this.source .= "：纪录片", this.title := RegExReplace(this.title, "-纪录片-全集-高清独家在线观看$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        this.VidTime := this.MatchVidTime(this.FullTitle, FullPageText)
    } else if (this.title ~= " 在线播放 - 小宝影院 - 在线视频$") {
      this.Source := "小宝影院", this.Title := RegExReplace(this.Title, " 在线播放 - 小宝影院 - 在线视频$")
      if (CopyFullPage)
        this.VidTime := this.MatchVidTime(this.FullTitle)
    } else if (this.title ~= "-在线播放 - 唐人街影院-海外华人影视网站-在线高清播放$") {
      this.source := "唐人街影院", this.title := RegExReplace(this.title, "-在线播放 - 唐人街影院-海外华人影视网站-在线高清播放$")
      if (CopyFullPage)
        this.VidTime := this.MatchVidTime(this.FullTitle)
    } else if (RegExMatch(this.title, "^Watch (.*) HD online$", v)) {
      this.source := "MoviesJoy", this.title := v1
      if (RegExMatch(this.title, " (\d+)$", v))
        this.date := v1, this.title := RegExReplace(this.title, " (\d+)$")
      if (CopyFullPage)
        this.VidTime := this.MatchVidTime(this.FullTitle)

    ; Wikipedia or wiki format websites
    } else if (this.title ~= " - supermemo\.guru$") {
      this.source := "SuperMemo Guru", this.title := RegExReplace(this.title, " - supermemo\.guru$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.date := v1
    } else if (this.title ~= " - SuperMemopedia$") {
      this.source := "SuperMemopedia", this.title := RegExReplace(this.title, " - SuperMemopedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.date := v1
    } else if (IfContains(this.url, "en.wikipedia.org")) {
      this.Source := "Wikipedia", this.title := RegExReplace(this.title, " - Wikipedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.date := v1
    } else if (this.title ~= " - Wiktionary, the free dictionary$") {
      this.Source := "Wiktionary", this.title := RegExReplace(this.title, " - Wiktionary, the free dictionary$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.date := v1
    } else if (IfContains(this.url, "en.wikiversity.org")) {
      this.Source := "Wikiversity", this.title := RegExReplace(this.title, " - Wikiversity$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.date := v1
    } else if (this.title ~= " - Wikisource, the free online library$") {
      this.Source := "Wikisource", this.title := RegExReplace(this.title, " - Wikisource, the free online library$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.date := v1
    } else if (this.title ~= " - 维基百科，自由的百科全书$") {
      this.Source := "维基百科", this.title := RegExReplace(this.title, " - 维基百科，自由的百科全书$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "本页面最后修订于(.*?) \(", v), this.date := v1
    } else if (this.title ~= " - 维基文库，自由的图书馆$") {
      this.Source := "维基文库", this.title := RegExReplace(this.title, " - 维基文库，自由的图书馆$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此页面最后编辑于(.*?) \(", v), this.date := v1
    } else if (this.title ~= " - 维基词典，自由的多语言词典$") {
      this.Source := "维基词典", this.title := RegExReplace(this.title, " - 维基词典，自由的多语言词典$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此页面最后编辑于(.*?) \(", v), this.date := v1
    } else if (this.title ~= " - Wikipedia, la enciclopedia libre$") {
      this.Source := "Wikipedia", this.title := RegExReplace(this.title, " - Wikipedia, la enciclopedia libre$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Esta página se editó por última vez el (.*?) a las ", v), this.date := v1
    } else if (this.title ~= " - Wikcionario, el diccionario libre$") {
      this.Source := "Wikcionario", this.title := RegExReplace(this.title, " - Wikcionario, el diccionario libre$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Esta página se editó por última vez el (.*?) a las ", v), this.date := v1
    } else if (IfContains(this.url, "it.wikipedia.org")) {
      this.Source := "Wikipedia", this.title := RegExReplace(this.title, " - Wikipedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Questa pagina è stata modificata per l'ultima volta il (.*?) alle", v), this.date := v1
    } else if (IfContains(this.url, "ja.wikipedia.org")) {
      this.Source := "ウィキペディア", this.title := RegExReplace(this.title, " - Wikipedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "最終更新 (.*?) \(", v), this.date := v1
    } else if (this.title ~= " - Vicipaedia$") {
      this.Source := "Vicipaedia", this.title := RegExReplace(this.title, " - Vicipaedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Novissima mutatio die (.*?) hora", v), this.date := v1
    } else if (IfContains(this.url, "github.com")) {
      this.Source := "GitHub", this.title := RegExReplace(this.title, "^GitHub - "), this.title := RegExReplace(this.title, " · GitHub$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Latest commit .*? on (.*)", v), this.date := v1

    ; Others
    } else if (this.Title ~= "_百度百科$") {
      this.Source := "百度百科", this.Title := RegExReplace(this.Title, "_百度百科$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "最近更新：.*（(.*)）", v), this.date := v1
    } else if (IfContains(this.url, "zhuanlan.zhihu.com")) {
      this.Source := "知乎", this.title := RegExReplace(this.title, " - 知乎$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "(编辑|发布)于 (.*?) ", v), this.date := v2
    } else if (IfContains(this.url, "economist.com")) {
      this.Source := "The Economist", this.title := RegExReplace(this.title, " \| The Economist$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "\r\n(\w+ \d+\w+ \d+)( \| .*)?\r\n\r\n", v), this.date := v1
    } else if (IfContains(this.Url, "investopedia.com")) {
      this.Source := "Investopedia"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Updated (.*)", v), this.date := v1
    } else if (IfContains(this.Url, "mp.weixin.qq.com")) {
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, " ([0-9]{4}-[0-9]{2}-[0-9]{2}) ", v), this.date := v1
      
    ; Special cases
    } else if (this.title ~= " - YouTube$") {  ; for getting title for timestamp syncing with SM
      this.source := "YouTube", this.title := RegExReplace(this.title, " - YouTube$")

    } else {
      ReversedTitle := StrReverse(this.Title)
      if (IfContains(ReversedTitle, " | ") && (!IfContains(ReversedTitle, " - ") || (InStr(ReversedTitle, " | ") < InStr(ReversedTitle, " - ")))) {
        separator := " | "
      } else if (IfContains(ReversedTitle, " – ")) {
        separator := " – "  ; sites like BetterExplained
      } else if (IfContains(ReversedTitle, " - ")) {
        separator := " - "
      } else if (IfContains(ReversedTitle, " — ")) {
        separator := " — "
      } else if (IfContains(ReversedTitle, " -- ")) {
        separator := " -- "
      } else if (IfContains(ReversedTitle, " • ")) {
        separator := " • "
      }
      if (pos := separator ? InStr(ReversedTitle, separator) : 0) {
        TitleLength := StrLen(this.Title) - pos - StrLen(separator) + 1
        this.Source := SubStr(this.Title, TitleLength + 1, StrLen(this.Title))
        this.Source := StrReplace(this.Source, separator,,, 1)
        this.Title := SubStr(this.Title, 1, TitleLength)
      }
    }
  }

  GetFullPage(RestoreClip:=true) {
    if (RestoreClip)
      ClipSaved := ClipboardAll
    CopyAll()
    text := Clipboard
    if (RestoreClip)
      Clipboard := ClipSaved
    return text
  }

  GetSecFromTime(TimeStamp) {
    if (!TimeStamp)
      return 0
    aTime := RevArr(StrSplit(TimeStamp, ":"))
    aTime[3] := aTime[3] ? aTime[3] : 0
    return aTime[1] + aTime[2] * 60 + aTime[3] * 3600
  }

  GetVidTime(title:="", FullPageText:="", RestoreClip:=true) {
    title := title ? title : this.GetFullTitle()
    return this.MatchVidTime(title, FullPageText, RestoreClip)
  }

  GetParsedUrl() {
    global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
    return this.ParseUrl(guiaBrowser.GetCurrentURL())
  }

  MatchYTVidAuthor(text) {
    RegExMatch(text, ".*(?=\r\n.*subscribers)", v)
    return v
  }

  MatchYTPLAuthor(text) {
    RegExMatch(text, "(.*)\r\n\d+ videos", v)
    return v1
  }

  MatchYTDate(text) {
    RegExMatch(text, "views +?((Streamed live|Premiered) on )?\K(\d+ \w+ \d+|\w+ \d+, \d+)", v)
    return v
  }

  MatchBLAuthor(text) {
    RegExMatch(text, "m)^.*(?=\r\n 发消息)", v)
    return v
  }

  MatchBLDate(text) {
    RegExMatch(text, "(.*) \d\d:\d\d:\d\d", v)
    return v1
  }

  MatchVidTime(title:="", FullPageText:="", RestoreClip:=true) {
    title := title ? title : this.GetFullTitle()
    if (title ~= " - YouTube$") {
      if (FullPageText := FullPageText ? FullPageText : this.GetFullPage(RestoreClip)) {
        RegExMatch(FullPageText, "\r\n([0-9:]+) \/ ([0-9:]+)", v)
        ; v1 = v2 means at end of video
        VidTime := (v1 == v2) ? "0:00" : v1
      }
    } else if (IfIn(this.IsVidSite(title), "2,3")) {
      global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
      VidTime := guiaBrowser.FindFirstByName("^(\d{1,2}:)?\d{1,2}:\d{1,2}$",, "regex").CurrentName
    } else {
      ; For now, all websites can use this function in case there are videos in them
      global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
      VidTime := guiaBrowser.FindFirstByName("^(\d{1,2}:)?\d{1,2}:\d{1,2}$",, "regex").CurrentName
    }
    return RegExReplace(VidTime, "^0(?=\d)")
  }

  RunInIE(url) {
    if ((url ~= "file:\/\/") && (url ~= "#.*"))
      url := RegExReplace(url, "#.*")
    wIE := "ahk_class IEFrame ahk_exe iexplore.exe"
    if (!el := WinExist(wIE)) {
      ie := ComObjCreate("InternetExplorer.Application")
      ie.Visible := true
      ie.Navigate(url)
    } else {
      if (ControlGetText("Edit1", wIE)) {  ; current page is not new tab page
        ControlSend, ahk_parent, {CtrlDown}t{CtrlUp}, % wIE
        ControlTextWait("Edit1", "", wIE)
      }
      ControlSetText, Edit1, % url, % wIE
      ControlSend, Edit1, {enter}, % wIE
    }
    WinActivate, % wIE
  }

  GetFullTitle() {
    return RegExReplace(WinGetTitle(), "( - Google Chrome| — Mozilla Firefox|( and \d+ more pages?)? - [^-]+ - Microsoft​ Edge)$")
  }

  IsVidSite(title:="") {
    title := title ? title : this.GetFullTitle()
    if (title ~= " - YouTube$") {  ; video time can be in url and ^a covers the video time
      return 1
    } else if (title ~= "(_哔哩哔哩_bilibili|-bilibili-哔哩哔哩)$") {  ; video time can be in url but ^a doesn't cover video time
      return 2
    } else if (title ~= "(^Watch .* HD online$|( 在线播放 - 小宝影院 - 在线视频|-在线播放 - 唐人街影院-海外华人影视网站-在线高清播放|-555电影| – NO视频| \| 91美剧网| \| FMovies)$)") {  ; video time can't be in url and ^a doesn't cover video time
      return 3
    }
  }

  Highlight(CollName:="") {
    CollName := CollName ? CollName : this.Vim.SM.GetCollName()
    ; ControlSend doesn't work reliably because browser can't highlight in background
    if (CollName = "zen") {
      send ^+h
    } else {
      send !+h
    }
    sleep 200
  }

  ClickBtn() {
    critical
    this.url := this.url ? this.url : this.GetParsedUrl()
    if (IfContains(this.url, "youtube.com/watch")) {
      global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
      if (!btn := guiaBrowser.FindFirstBy("ControlType=Button AND Name='...more' AND AutomationId='expand'"))
        btn := guiaBrowser.FindFirstBy("ControlType=Text AND Name='...more'")
      if (btn) {
        btn.FindByPath("P3").click()  ; click the description box, so the webpage doesn't scroll down
      } else {
        el := guiaBrowser.FindFirstBy("ControlType=Text AND Name='^\d+(\.\d+)?(K|M|B)? views'",, "regex")
        if (el.FindByPath("+1").Name == "•") {
          return false
        } else {
          el.click()
        }
      }
    } else {
      return false
    }
    return true
  }
}

PressBrowserBtn:
  Vim.Browser.ClickBtn()
  PressBrowserBtnDone := true
return