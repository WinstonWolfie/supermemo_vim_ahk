#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
class VimBrowser {
  __New(Vim) {
    this.Vim := Vim
  }

  Clear() {
    this.Title := this.Url := this.Source := this.Date := this.Comment := this.VidTime := this.Author := this.FullTitle := ""
    global guiaBrowser := ""
  }

  GetInfo(RestoreClip:=true, CopyFullPage:=true, PressButton:=true) {
    global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
    this.Url := this.GetParsedUrl()
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
    this.Title := this.Title ? this.Title : this.FullTitle
    if (GetUrl)
      this.Url := this.Url ? this.Url : this.GetParsedUrl()

    if (this.Title ~= " - YouTube$")
      this.Title := RegExReplace(this.Title, "^\(\d+\) ")

    ; Sites that should be skipped
    SkippedList := "wind.com.cn,thepokerbank.com"
    if (IfContains(this.Url, SkippedList)) {
      return

    ; Sites that have source in their title
    } else if (this.Title ~= "^很帅的日报") {
      this.Date := RegExReplace(this.Title, "^很帅的日报 "), this.Title := "很帅的日报"
    } else if (this.Title ~= "^Frontiers \| ") {
      this.Source := "Frontiers", this.Title := RegExReplace(this.Title, "^Frontiers \| ")
    } else if (this.Title ~= "^NIMH » ") {
      this.Source := "NIMH", this.Title := RegExReplace(this.Title, "^NIMH » ")
    } else if (this.Title ~= "^(• )?Discord \| ") {
      this.Title := RegExReplace(this.Title, "^(• )?Discord \| "), RegexMatch(this.Title, "^.* \| (.*)$", v), this.Source := "Discord: " . v1
      this.Title := RegexReplace(this.Title , "^.*\K \| .*$")
    } else if (this.Title ~= "^italki - ") {
      this.Source := "italki", this.Title := RegExReplace(this.Title, "^italki - ")
    } else if (this.Title ~= "^CSOP - Products - ") {
      this.Source := "CSOP Asset Management", this.Title := RegExReplace(this.Title, "^CSOP - Products - ")
    ; } else if (this.Title ~= "^GitHub - ") {
      ; this.Source := "GitHub", this.Title := RegExReplace(this.Title, "^GitHub - ")
    } else if (this.Title ~= "^ArtStation - ") {
      this.Source := "ArtStation", this.Title := RegExReplace(this.Title, "^ArtStation - ")
    } else if (this.Title ~= "^Art... When I Feel Like It - ") {
      this.Source := "Art... When I Feel Like It ", this.Title := RegExReplace(this.Title, "^Art... When I Feel Like It - ")
    } else if (this.Title ~= "^Henry George Liddell, Robert Scott, An Intermediate Greek-English Lexicon, ") {
      this.Author := "Henry George Liddell, Robert Scott", this.Source := "An Intermediate Greek-English Lexicon", this.Title := RegExReplace(this.Title, "^Henry George Liddell, Robert Scott, An Intermediate Greek-English Lexicon, ")

    } else if (this.Title ~= "_百度知道$") {
      this.Source := "百度知道", this.Title := RegExReplace(this.Title, "_百度知道$")
    } else if (this.Title ~= "-新华网$") {
      this.Source := "新华网", this.Title := RegExReplace(this.Title, "-新华网$")
    } else if (this.Title ~= ": MedlinePlus Medical Encyclopedia$") {
      this.Source := "MedlinePlus Medical Encyclopedia", this.Title := RegExReplace(this.Title, ": MedlinePlus Medical Encyclopedia$")
    } else if (this.Title ~= "_英为财情Investing.com$") {
      this.Source := "英为财情", this.Title := RegExReplace(this.Title, "_英为财情Investing.com$")
    } else if (this.Title ~= " \| OSUCCC - James$") {
      this.Source := "OSUCCC - James", this.Title := RegExReplace(this.Title, " \| OSUCCC - James$")
    } else if (this.Title ~= " · GitBook$") {
      this.Source := "GitBook", this.Title := RegExReplace(this.Title, " · GitBook$")
    } else if (this.Title ~= " \| SLEEP \| Oxford Academic$") {
      this.Source := "SLEEP | Oxford Academic", this.Title := RegExReplace(this.Title, " \| SLEEP \| Oxford Academic$")
    } else if (this.Title ~= " \| Microbiome \| Full Text$") {
      this.Source := "Microbiome", this.Title := RegExReplace(this.Title, " \| Microbiome \| Full Text$")
    } else if (this.Title ~= "-清华大学医学院$") {
      this.Source := "清华大学医学院", this.Title := RegExReplace(this.Title, "-清华大学医学院$")
    } else if (this.Title ~= "- 雪球$") {
      this.Source := "雪球", this.Title := RegExReplace(this.Title, "- 雪球$")
    } else if (this.Title ~= " - Podcasts - SuperDataScience \| Machine Learning \| AI \| Data Science Career \| Analytics \| Success$") {
      this.Source := "SuperDataScience", this.Title := RegExReplace(this.Title, " - Podcasts - SuperDataScience \| Machine Learning \| AI \| Data Science Career \| Analytics \| Success$")
    } else if (this.Title ~= " \| Definición \| Diccionario de la lengua española \| RAE - ASALE$") {
      this.Source := "Diccionario de la lengua española | RAE - ASALE", this.Title := RegExReplace(this.Title, " \| Diccionario de la lengua española \| RAE - ASALE$")
    } else if (this.Title ~= " • Zettelkasten Method$") {
      this.Source := "Zettelkasten Method", this.Title := RegExReplace(this.Title, " • Zettelkasten Method$")
    } else if (this.Title ~= " on JSTOR$") {
      this.Source := "JSTOR", this.Title := RegExReplace(this.Title, " on JSTOR$")
    } else if (this.Title ~= " - Queensland Brain Institute - University of Queensland$") {
      this.Source := "Queensland Brain Institute - University of Queensland", this.Title := RegExReplace(this.Title, " - Queensland Brain Institute - University of Queensland$")
    } else if (this.Title ~= " \| BMC Neuroscience \| Full Text$") {
      this.Source := "BMC Neuroscience", this.Title := RegExReplace(this.Title, " \| BMC Neuroscience \| Full Text$")
    } else if (this.Title ~= " \| MIT News \| Massachusetts Institute of Technology$") {
      this.Source := "MIT News | Massachusetts Institute of Technology", this.Title := RegExReplace(this.Title, " \| MIT News \| Massachusetts Institute of Technology$")
    } else if (this.Title ~= " - StatPearls - NCBI Bookshelf$") {
      this.Source := "StatPearls - NCBI Bookshelf", this.Title := RegExReplace(this.Title, " - StatPearls - NCBI Bookshelf$")
    } else if (this.Title ~= "：剑桥词典$") {
      this.Source := "剑桥词典", this.Title := RegExReplace(this.Title, "：剑桥词典$")

    } else if (RegExMatch(this.Title, " \| (.*) \| Cambridge Core$", v)) {
      this.Source := v1 . " | Cambridge Core", this.Title := RegExReplace(this.Title, "\| (.*) \| Cambridge Core$")
    } else if (RegExMatch(this.Title, " \| (.*) \| Fandom$", v)) {
      this.Source := v1 . " | Fandom", this.Title := RegExReplace(this.Title, " \| (.*) \| Fandom$")
    } else if (RegExMatch(this.Title, " \| (.*) \| The Guardian$", v)) {
      this.Source := v1 . " | The Guardian", this.Title := RegExReplace(this.Title, " \| (.*) \| The Guardian$")
    } else if (RegExMatch(this.Title, " - (.*) \| OpenStax$", v)) {
      this.Source := v1 . " | OpenStax", this.Title := RegExReplace(this.Title, " - (.*) \| OpenStax$")
    } else if (RegExMatch(this.Title, " : Free Download, Borrow, and Streaming : Internet Archive$", v)) {
      this.Source := "Internet Archive", this.Title := RegExReplace(this.Title, "( : .*?)? : Free Download, Borrow, and Streaming : Internet Archive$")
      if (RegexMatch(this.FullTitle, " : (.*?) : Free Download, Borrow, and Streaming : Internet Archive$", v))
        this.Author := v1

    } else if (this.Title ~= " \/ Twitter$") {
      this.Source := "Twitter", this.Title := RegExReplace(this.Title, """ \/ Twitter$")
      RegExMatch(this.Title, "^(.*) on Twitter: """, v), this.Author := v1
      this.Title := RegExReplace(this.Title,  "^.* on Twitter: """)

    } else if (RegExMatch(this.Title, " \| by (.*?) \| ((.*?) \| )?Medium$", v)) {
      this.Source := "Medium", this.Title := RegExReplace(this.Title, " \| by .*? \| Medium$"), this.Author := v1

    } else if (IfContains(this.Url, "reddit.com")) {
      RegExMatch(this.Url, "reddit\.com\/\Kr\/[^\/]+", v), this.Source := v, this.Title := RegExReplace(this.Title, " : " . StrReplace(v, "r/") . "$")

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
      this.Source := "University Health News"
    } else if (IfContains(this.Url, "verywellmind.com")) {
      this.Source := "Verywell Mind"
    } else if (IfContains(this.Url, "cliffsnotes.com")) {
      this.Source := "CliffsNotes", this.Title := RegExReplace(this.Title, " \| CliffsNotes$")
    } else if (IfContains(this.Url, "w3schools.com")) {
      this.Source := "W3Schools"
    } else if (IfContains(this.Url, "news-medical.net")) {
      this.Source := "News-Medical"
    } else if (IfContains(this.Url, "ods.od.nih.gov")) {
      this.Source := "National Institutes of Health: Office of Dietary Supplements"
    } else if (IfContains(this.Url, "vandal.elespanol.com")) {
      this.Source := "Vandal"
    } else if (IfContains(this.Url, "fidelity.com")) {
      this.Source := "Fidelity International"
    } else if (IfContains(this.Url, "eliteguias.com")) {
      this.Source := "Eliteguias"
    } else if (IfContains(this.Url, "byjus.com")) {
      this.Source := "BYJU'S"
    } else if (IfContains(this.Url, "blackrock.com")) {
      this.Source := "BlackRock"
    } else if (IfContains(this.Url, "growbeansprout.com")) {
      this.Source := "Beansprout"
    } else if (IfContains(this.Url, "researchgate.net")) {
      this.Source := "ResearchGate"
    } else if (IfContains(this.Url, "neuroscientificallychallenged.com")) {
      this.Source := "Neuroscientifically Challenged"
    } else if (IfContains(this.Url, "bachvereniging.nl")) {
      this.Source := "Netherlands Bach Society"
    } else if (IfContains(this.Url, "tutorialspoint.com")) {
      this.Source := "Tutorials Point"
    } else if (IfContains(this.Url, "fourminutebooks.com")) {
      this.Source := "Four Minute Books"
    } else if (IfContains(this.Url, "forvo.com")) {
      this.Source := "Forvo"
    } else if (IfContains(this.Url, "gutenberg.org")) {
      this.Source := "Project Gutenberg"
    } else if (IfContains(this.Url, "finty.com")) {
      this.Source := "Finty"

    ; Sites that require special attention
    ; Video sites
    } else if (IfContains(this.Url, "youtube.com/watch")) {
      this.Source := "YouTube", this.Title := RegExReplace(this.Title, " - YouTube$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        this.VidTime := this.MatchVidTime(this.FullTitle, FullPageText), this.Date := this.MatchYTDate(FullPageText), this.Author := this.MatchYTVidAuthor(FullPageText)
    } else if (IfContains(this.Url, "youtube.com/playlist")) {
      this.Source := "YouTube", this.Title := RegExReplace(this.Title, " - YouTube$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        this.Author := this.MatchYTPLAuthor(FullPageText)
    } else if (this.Title ~= "_哔哩哔哩_bilibili$") {
      this.Source := "哔哩哔哩", this.Title := RegExReplace(this.Title, "_哔哩哔哩_bilibili$")
      if (IfContains(this.Url, "bilibili.com/video") && CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        this.VidTime := this.MatchVidTime(this.FullTitle), this.Date := this.MatchBLDate(FullPageText), this.Author := this.MatchBLAuthor(FullPageText)
    } else if (this.Title ~= "-bilibili-哔哩哔哩$") {
      this.Source := "哔哩哔哩", this.Title := RegExReplace(this.Title, "-bilibili-哔哩哔哩$")
      if (this.Title ~= "-纪录片-全集-高清独家在线观看$")
        this.Source .= "：纪录片", this.Title := RegExReplace(this.Title, "-纪录片-全集-高清独家在线观看$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        this.VidTime := this.MatchVidTime(this.FullTitle, FullPageText)
    } else if (this.Title ~= " 在线播放 - 小宝影院 - 在线视频$") {
      this.Source := "小宝影院", this.Title := RegExReplace(this.Title, " 在线播放 - 小宝影院 - 在线视频$")
      if (CopyFullPage)
        this.VidTime := this.MatchVidTime(this.FullTitle)
    } else if (this.Title ~= "-在线播放 - 唐人街影院-海外华人影视网站-在线高清播放$") {
      this.Source := "唐人街影院", this.Title := RegExReplace(this.Title, "-在线播放 - 唐人街影院-海外华人影视网站-在线高清播放$")
      if (CopyFullPage)
        this.VidTime := this.MatchVidTime(this.FullTitle)
    } else if (RegExMatch(this.Title, "^Watch (.*) HD online$", v)) {
      this.Source := "MoviesJoy", this.Title := v1
      if (RegExMatch(this.Title, " (\d+)$", v))
        this.Date := v1, this.Title := RegExReplace(this.Title, " (\d+)$")
      if (CopyFullPage)
        this.VidTime := this.MatchVidTime(this.FullTitle)

    ; Wikipedia or wiki format websites
    } else if (this.Title ~= " - supermemo\.guru$") {
      this.Source := "SuperMemo Guru", this.Title := RegExReplace(this.Title, " - supermemo\.guru$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - SuperMemopedia$") {
      this.Source := "SuperMemopedia", this.Title := RegExReplace(this.Title, " - SuperMemopedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (IfContains(this.Url, "en.wikipedia.org")) {
      this.Source := "Wikipedia", this.Title := RegExReplace(this.Title, " - Wikipedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Simple English Wikipedia, the free encyclopedia$") {
      this.Source := "Simple English Wikipedia", this.Title := RegExReplace(this.Title, " - Simple English Wikipedia, the free encyclopedia")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last changed on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Wiktionary, the free dictionary$") {
      this.Source := "Wiktionary", this.Title := RegExReplace(this.Title, " - Wiktionary, the free dictionary$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (IfContains(this.Url, "en.wikiversity.org")) {
      this.Source := "Wikiversity", this.Title := RegExReplace(this.Title, " - Wikiversity$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Wikisource, the free online library$") {
      this.Source := "Wikisource", this.Title := RegExReplace(this.Title, " - Wikisource, the free online library$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - 维基百科，自由的百科全书$") {
      this.Source := "维基百科", this.Title := RegExReplace(this.Title, " - 维基百科，自由的百科全书$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "本页面最后修订于(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 维基文库，自由的图书馆$") {
      this.Source := "维基文库", this.Title := RegExReplace(this.Title, " - 维基文库，自由的图书馆$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此页面最后编辑于(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 维基词典，自由的多语言词典$") {
      this.Source := "维基词典", this.Title := RegExReplace(this.Title, " - 维基词典，自由的多语言词典$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此页面最后编辑于(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - Wikipedia, la enciclopedia libre$") {
      this.Source := "Wikipedia", this.Title := RegExReplace(this.Title, " - Wikipedia, la enciclopedia libre$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Esta página se editó por última vez el (.*?) a las ", v), this.Date := v1
    } else if (this.Title ~= " - Wikcionario, el diccionario libre$") {
      this.Source := "Wikcionario", this.Title := RegExReplace(this.Title, " - Wikcionario, el diccionario libre$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Esta página se editó por última vez el (.*?) a las ", v), this.Date := v1
    } else if (IfContains(this.Url, "it.wikipedia.org")) {
      this.Source := "Wikipedia", this.Title := RegExReplace(this.Title, " - Wikipedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Questa pagina è stata modificata per l'ultima volta il (.*?) alle", v), this.Date := v1
    } else if (IfContains(this.Url, "ja.wikipedia.org")) {
      this.Source := "ウィキペディア", this.Title := RegExReplace(this.Title, " - Wikipedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "最終更新 (.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - Vicipaedia$") {
      this.Source := "Vicipaedia", this.Title := RegExReplace(this.Title, " - Vicipaedia$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Novissima mutatio die (.*?) hora", v), this.Date := v1
    } else if (IfContains(this.Url, "github.com")) {
      this.Source := "GitHub", this.Title := RegExReplace(this.Title, "^GitHub - "), this.Title := RegExReplace(this.Title, " · GitHub$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Latest commit .*? on (.*)", v), this.Date := v1

    ; Others
    } else if (this.Title ~= "_百度百科$") {
      this.Source := "百度百科", this.Title := RegExReplace(this.Title, "_百度百科$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "s)最近更新：.*（(.*)）", v), this.Date := v1
    } else if (IfContains(this.Url, "zhuanlan.zhihu.com")) {
      this.Source := "知乎", this.Title := RegExReplace(this.Title, " - 知乎$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "(编辑|发布)于 (.*?) ", v), this.Date := v2
    } else if (IfContains(this.Url, "economist.com")) {
      this.Source := "The Economist", this.Title := RegExReplace(this.Title, " \| The Economist$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "\r\n(\w+ \d+\w+ \d+)( \| .*)?\r\n\r\n", v), this.Date := v1
    } else if (IfContains(this.Url, "investopedia.com")) {
      this.Source := "Investopedia"
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Updated (.*)", v), this.Date := v1
    } else if (IfContains(this.Url, "mp.weixin.qq.com")) {
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, " ([0-9]{4}-[0-9]{2}-[0-9]{2}) ", v), this.Date := v1
    } else if (this.Title ~= " \| Britannica$") {
      this.Source := "Britannica", this.Title := RegExReplace(this.Title, " \| Britannica$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Last Updated: (.*) • ", v), this.Date := v1
      
    ; Special cases
    } else if (this.Title ~= " - YouTube$") {  ; for getting title for timestamp syncing with SM
      this.Source := "YouTube", this.Title := RegExReplace(this.Title, " - YouTube$")

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
    global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
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
      global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
      VidTime := guiaBrowser.FindFirstByName("^(\d{1,2}:)?\d{1,2}:\d{1,2}$",, "regex").CurrentName
    } else {
      ; For now, all websites can use this function in case there are videos in them
      global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
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
    return RegExReplace(WinGetTitle("A"), "( - Google Chrome| — Mozilla Firefox|( and \d+ more pages?)? - [^-]+ - Microsoft​ Edge)$")
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

  Highlight(CollName:="", PlainText:="") {
    CollName := CollName ? CollName : this.Vim.SM.GetCollName()
    if (RegexMatch(PlainText, "(\[\d+\])+$|\[\d+\]: \d+$", v)) {
      this.Url := this.Url ? this.Url : this.GetParsedUrl()
      if (IfContains(this.Url, "wikipedia.org"))
        send % "+{left " . StrLen(v) . "}"
    }
    ; ControlSend doesn't work reliably because browser can't highlight in background
    if (CollName = "zen") {
      send ^+h
    } else {
      send !+h
    }
    sleep 500  ; time for visual feedback
  }

  ClickBtn() {
    critical
    this.Url := this.Url ? this.Url : this.GetParsedUrl()
    if (IfContains(this.Url, "youtube.com/watch")) {
      global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
      if (!btn := guiaBrowser.FindFirstBy("ControlType=Button AND Name='...more' AND AutomationId='expand'"))
        btn := guiaBrowser.FindFirstBy("ControlType=Text AND Name='...more'")
      if (btn) {
        btn.FindByPath("P3").click()  ; click the description box, so the webpage doesn't scroll down
      } else {
        el := guiaBrowser.FindFirstBy("ControlType=Text AND Name='^\d+(\.\d+)?(K|M|B)? views'",, "regex")
        if (el.FindByPath("+1").Name == "•") {  ; not video time from the current video (instead, suggestion box)
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
return
