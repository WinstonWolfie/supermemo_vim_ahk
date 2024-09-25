#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
class Browser {
  __New() {
    this.Months := "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)"
  }

  Clear() {
    ; DO NOT add critical here
    this.Title := this.Url := this.Source := this.Date := this.Comment := this.TimeStamp := this.Author := this.FullTitle := ""
  }

  GetGuiaBrowser() {
    global guiaBrowser := (guiaBrowser.BrowserId == WinActive("A")) ? guiaBrowser : new UIA_Browser("A")
  }

  ParseUrl(Url) {
    if (!Url)
      return
    PoundSymbList := "wiktionary.org/wiki,workflowy.com,korean.dict.naver.com/koendict"
    if (!IfContains(Url, PoundSymbList))
      Url := RegExReplace(Url, "#.*")
    ; Remove everything after "?"
    QuestionMarkList := "baike.baidu.com,bloomberg.com,substack.com,netflix.com/watch"
    if (IfContains(Url, QuestionMarkList)) {
      Url := RegExReplace(Url, "\?.*")
    } else if (IfContains(Url, "youtube.com/watch")) {
      Url := StrReplace(Url, "app=desktop&"), Url := RegExReplace(Url, "&.*")
    } else if (IfContains(Url, "bilibili.com")) {
      Url := RegExReplace(Url, "(\?(?!p=\d+)|&).*")
      Url := RegExReplace(Url, "\/(?=\?p=\d+)")
    ; } else if (IfContains(Url, "netflix.com/watch")) {
    ;   Url := RegExReplace(Url, "\?trackId=.*")
    } else if (IfContains(Url, "finance.yahoo.com")) {
      Url := RegExReplace(Url, "\?.*")
      if !(Url ~= "\/$")
        Url := Url . "/"
    } else if (IfContains(Url, "dle.rae.es")) {
      Url := StrReplace(Url, "?m=form")
    }
    return Url
  }

  GetInfo(RestoreClip:=true, GetFullPage:=true, FullPageText:="", GetUrl:=true, GetDate:=true, GetTimeStamp:=true, FullPageHTML:="") {
    this.FullTitle := this.FullTitle ? this.FullTitle : this.GetFullTitle()
    this.Title := this.FullTitle
    if (GetUrl)
      this.Url := this.Url ? this.Url : this.GetUrl()

    ; Sites that should be skipped
    SkippedList := "wind.com.cn,thepokerbank.com,tutorial.math.lamar.edu,sites.google.com/view/musicalharmonysite"
    if (IfContains(this.Url, SkippedList)) {
      return

    ; Source at the start
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
    } else if (this.Title ~= "^ArtStation - ") {
      this.Source := "ArtStation", this.Title := RegExReplace(this.Title, "^ArtStation - ")
    } else if (this.Title ~= "^Art... When I Feel Like It - ") {
      this.Source := "Art... When I Feel Like It ", this.Title := RegExReplace(this.Title, "^Art... When I Feel Like It - ")
    } else if (this.Title ~= "^Henry George Liddell, Robert Scott, An Intermediate Greek-English Lexicon, ") {
      this.Author := "Henry George Liddell, Robert Scott", this.Source := "An Intermediate Greek-English Lexicon", this.Title := RegExReplace(this.Title, "^Henry George Liddell, Robert Scott, An Intermediate Greek-English Lexicon, ")
    } else if (RegExMatch(this.Title, "i)^The Project Gutenb(?:e|u)rg eBook of (.*?),? by (.*?)\.?$", v)) {
      this.Author := v2, this.Source := "Project Gutenberg", this.Title := v1
    } else if (this.Title ~= "^綠角財經筆記: ") {
      this.Source := "綠角財經筆記", this.Title := RegExReplace(this.Title, "^綠角財經筆記: ")

    ; Source at the end
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
    } else if (this.Title ~= " - The Skeptic's Dictionary - Skepdic\.com$") {
      this.Source := "The Skeptic's Dictionary", this.Title := RegExReplace(this.Title, " - The Skeptic's Dictionary - Skepdic\.com$")
    } else if (this.Title ~= "-格隆汇$") {
      this.Source := "格隆汇", this.Title := RegExReplace(this.Title, "-格隆汇$")
    } else if (this.Title ~= "：劍橋詞典$") {
      this.Source := "劍橋詞典", this.Title := RegExReplace(this.Title, "：劍橋詞典$")
    } else if (this.Title ~= " - Treccani - Treccani - Treccani$") {
      this.Source := "Treccani", this.Title := RegExReplace(this.Title, " - Treccani - Treccani - Treccani$")
    } else if (this.Title ~= " \(豆瓣\)$") {
      this.Source := "豆瓣", this.Title := RegExReplace(this.Title, " \(豆瓣\)$")
    } else if (IfContains(this.Url, "meta.wikimedia.org")) {
      this.Source := "Meta-Wiki", this.Title := RegExReplace(this.Title, " - Meta$")
    } else if (this.Title ~= " \| definition of .*? by Medical dictionary$") {
      this.Source := "The Free Dictionary"

    ; Source in the middle
    } else if (RegExMatch(this.Title, " \| (.*) \| Cambridge Core$", v)) {
      this.Source := v1 . " | Cambridge Core", this.Title := RegExReplace(this.Title, "\| (.*) \| Cambridge Core$")
    } else if (RegExMatch(this.Title, " \| (.*) \| The Guardian$", v)) {
      this.Source := v1 . " | The Guardian", this.Title := RegExReplace(this.Title, " \| (.*) \| The Guardian$")
    } else if (RegExMatch(this.Title, " - (.*) \| OpenStax$", v)) {
      this.Source := v1 . " | OpenStax", this.Title := RegExReplace(this.Title, " - (.*) \| OpenStax$")
    } else if (RegExMatch(this.Title, " : Free Download, Borrow, and Streaming : Internet Archive$", v)) {
      this.Source := "Internet Archive", this.Title := RegExReplace(this.Title, "( : .*?)? : Free Download, Borrow, and Streaming : Internet Archive$")
      if (RegexMatch(this.FullTitle, " : (.*?) : Free Download, Borrow, and Streaming : Internet Archive$", v))
        this.Author := v1
    } else if (this.Title ~= " \/ X$") {
      this.Source := "X", this.Title := RegExReplace(this.Title, """ \/ X$")
      RegExMatch(this.Title, "^(.*) on X: """, v), this.Author := v1
      this.Title := RegExReplace(this.Title,  "^.* on X: """)
    } else if (RegExMatch(this.Title, "^Git - (.*?) Documentation$", v)) {
      this.Source := "Git - Documentation", this.Title := v1
    } else if (RegExMatch(this.Title, "'(.*?)': Naver Korean-English Dictionary", v)) {
      this.Source := "Naver Korean-English Dictionary", this.Title := v1
    } else if (IfContains(this.Url, "reddit.com")) {
      RegExMatch(this.Url, "reddit\.com\/\Kr\/[^\/]+", v), this.Source := v, this.Title := RegExReplace(this.Title, " : " . v . "$")
    } else if (IfContains(this.Url, "podcasts.google.com")) {
      RegExMatch(this.Title, "^(.*) - ", v), this.Author := v1, this.Title := RegExReplace(this.Title, "^(.*) - "), this.Source := "Google Podcasts"

    ; Download to get the date (Fandom/Wiki websites)
    } else if (RegExMatch(this.Title, " \| (.*) \| Fandom$", v)) {
      this.Source := v1 . " | Fandom", this.Title := RegExReplace(this.Title, " \| (.*) \| Fandom$")
      if (GetFullPage && GetDate) {
        this.Url := this.Url ? this.Url : this.GetUrl()
        TempHTML := GetSiteHTML(this.Url . "?action=history")
        RegExMatch(TempHTML, "<h4 class=""mw-index-pager-list-header-first mw-index-pager-list-header"">(.*?)<\/h4>", v)
        this.Date := v1
      }
    } else if (this.Title ~= " - TV Tropes$") {
      this.Source := "TV Tropes", this.Title := RegExReplace(this.Title, " - TV Tropes$")
      if (GetFullPage && GetDate) {
        this.Url := this.Url ? this.Url : this.GetUrl()
        RegExMatch(this.Url, "https:\/\/tvtropes\.org\/pmwiki\/pmwiki\.php\/(.*?)\/(.*?)($|\?)", v)
        TempHTML := GetSiteHTML("https://tvtropes.org/pmwiki/article_history.php?article=" . v1 . "." . v2)
        RegExMatch(TempHTML, "<a href=""\/pmwiki\/article_history\.php\?article=" . v1 . "\." . v2 . ".*?#edit.*?>(\w+ \d+\w+ \d+)", v)
        this.Date := v1
      }

    ; No source in the title
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
    } else if (IfContains(this.Url, "finty.com")) {
      this.Source := "Finty"
    } else if (IfContains(this.Url, "theconversation.com")) {
      this.Source := "The Conversation"
    } else if (IfContains(this.Url, "examine.com")) {
      this.Source := "Examine"
    } else if (IfContains(this.Url, "corporatefinanceinstitute.com")) {
      this.Source := "Corporate Finance Institute"
    } else if (IfContains(this.Url, "cnrtl.fr/definition")) {
      this.Source := "Trésor de la langue française informatisé"
    } else if (IfContains(this.Url, "books.openbookpublishers.com")) {
      this.Source := "Open Book Publishers"
    } else if (IfContains(this.Url, "morningbrew.com")) {
      this.Source := "Morning Brew"
    } else if (IfContains(this.Url, "aastocks.com")) {
      this.Source := "AASTOCKS"
    } else if (IfContains(this.Url, "verywellhealth.com")) {
      this.Source := "Verywell Health"

    ; Video/audio
    } else if (IfContains(this.Url, "youtube.com/watch")) {
      this.Source := "YouTube", this.Title := RegExReplace(this.Title, " - YouTube$")
      if (GetFullPage) {
        if (GetDate) {
          global guiaBrowser
          this.GetGuiaBrowser()
          if (!btn := guiaBrowser.FindFirstBy("ControlType=Button AND Name='...more' AND AutomationId='expand'"))
            btn := guiaBrowser.FindFirstBy("ControlType=Text AND Name='...more'")
          if (btn)
            btn.FindByPath("P2").Click()  ; click the description box, so the webpage doesn't scroll down
          RegExMatch(FullPageText := this.GetFullPage(RestoreClip), "views +?(\r\n)?((Streamed live|Premiered) (on )?)?\K(\d+ \w+ \d+|\w+ \d+, \d+)", Date), this.Date := Date
          if (btn) {
            if (!btn := guiaBrowser.FindFirstBy("ControlType=Button AND Name='Show less' AND AutomationId='collapse'")) {  ; clicked before
              guiaBrowser.FindFirstBy("ControlType=Text AND Name='Show less'").Click()  ; this doesn't scroll
            } else {
              btn.Click()
              WinActivate, % "ahk_id " . guiaBrowser.BrowserId
              global ImportCloseTab
              if (!ImportCloseTab) {
                Sleep 700
                Send ^{Home}
              }
            }
          }

          ; Get page source HTML, takes extremely long time
          ; RegExMatch(GetSiteHTML(this.Url), """publishDate"":{""simpleText"":""(.*?)""}", v), this.Date := RegExReplace(v1, "(Streamed live|Premiered) on ")
        }
        if (!FullPageText)
          FullPageText := this.GetFullPage(RestoreClip)
        if (this.Title ~= "^\(\d+\) ")
          RegExMatch(FullPageText, "(.*)\r\n\r\n.*\r\n.* subscribers", v), this.Title := v1
        if (GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(this.FullTitle, FullPageText, RestoreClip)
        RegExMatch(FullPageText, ".*(?=\r\n.* subscribers)", Author), this.Author := Author
      }
    } else if (IfContains(this.Url, "youtube.com/playlist")) {
      this.Source := "YouTube", this.Title := RegExReplace(this.Title, " - YouTube$")
      if (GetFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "(.*)\r\n\d+ videos", v), this.Author := v1
    } else if (this.Title ~= "_哔哩哔哩_bilibili$") {
      this.Source := "哔哩哔哩", this.Title := RegExReplace(this.Title, "_哔哩哔哩_bilibili$")
      if (IfContains(this.Url, "bilibili.com/video")) {
        if (GetFullPage && GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
        if (GetFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
          if (GetDate)
            RegExMatch(FullPageText, "(\d{4}-\d{2}-\d{2}) \d{2}:\d{2}:\d{2}", v), this.Date := v1
          RegExMatch(FullPageText, "m)^.*(?=\r\n 发消息)", Author), this.Author := Author
        }
      }
    } else if (this.Title ~= "-bilibili-哔哩哔哩$") {
      this.Source := "哔哩哔哩", this.Title := RegExReplace(this.Title, "-bilibili-哔哩哔哩$")
      if (this.Title ~= "-纪录片-全集-高清独家在线观看$")
        this.Source .= "：纪录片", this.Title := RegExReplace(this.Title, "-纪录片-全集-高清独家在线观看$")
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (this.Url ~= "moviesjoy\.(.*?)\/watch") {
      RegExMatch(this.Title, "^Watch (.*?) HD online$", v)
      this.Source := "MoviesJoy", this.Title := v1
      if (RegExMatch(this.Title, " (\d+)$", v))
        this.Date := v1, this.Title := RegExReplace(this.Title, " (\d+)$")
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (IfContains(this.Url, "dopebox.to")) {
      RegExMatch(this.Title, "^Watch Free (.*?) (Full Movies|TV Shows) Online$", v)
      this.Source := "DopeBox", this.Title := v1
      if (RegExMatch(this.Title, " (\d+)$", v) && (v2 == "Full Movies"))
        this.Date := v1, this.Title := RegExReplace(this.Title, " (\d+)$")
      if (GetFullPage) {
        if (GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
        if (GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
          RegExMatch(FullPageText, "Released: (\d{4})-\d{2}-\d{2}", v), this.Date := v1
      }
    } else if (RegExMatch(this.Title, "^Watch (.*?) online free on 9anime$", v)) {
      this.Source := "9anime", this.Title := v1
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (RegExMatch(this.Title, "^Watch full (.*?) english sub \| Kissasian$", v)) {
      this.Source := "Kissasian", this.Title := v1
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (RegExMatch(this.Title, "^Watch (.*?) English Sub/Dub online Free on HiAnime\.to$", v)) {
      this.Source := "HiAnime", this.Title := v1
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (this.Title ~= "-免费在线观看-爱壹帆$") {
      this.Source := "爱壹帆", this.Title := RegExReplace(this.Title, "-免费在线观看-爱壹帆$")
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (this.Title ~= "_高清在线观看 – NO视频$") {
      this.Source := "NO视频", this.Title := RegExReplace(this.Title, "_高清在线观看 – NO视频$")
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (this.Title ~= "_[^_]+ - 喜马拉雅$") {
      this.Source := "喜马拉雅", this.Title := RegExReplace(this.Title, "_[^_]+ - 喜马拉雅$")
      if (IfContains(this.Url, "ximalaya.com/sound")) {
        if (GetFullPage && GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
        if (GetFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
          if (GetDate)
            RegExMatch(FullPageText, "\d{4}-\d{2}-\d{2}", Date), this.Date := Date
          RegExMatch(FullPageText, "声音主播\r\n\K.*", Author), this.Author := Author
        }
      }
    } else if (this.Title == "Netflix") {
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (this.Title ~= " - Animelon$") {
      this.Source := "Animelon", this.Title := RegExReplace(this.Title, " - Animelon$")
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (this.Title ~= " on Vimeo$") {
      this.Source := "Vimeo", this.Title := RegExReplace(this.Title, " on Vimeo$")
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
    } else if (this.Title ~= " - video Dailymotion$") {
      this.Source := "Dailymotion", this.Title := RegExReplace(this.Title, " - video Dailymotion$")
      if (GetFullPage && GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
      if (GetFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
        if (GetDate) {
          FullPageHTML := FullPageHTML ? FullPageHTML : GetSiteHTML(this.Url ? this.Url : this.GetUrl())
          RegExMatch(FullPageHTML, "<meta property=""video:release_date"" content=""(\d{4}-\d{2}-\d{2}).*?""  \/>", v), this.Date := v1
        }
        RegExMatch(FullPageText, "(.*)\r\n\r\nFollow", v), this.Author := v1
      }

    ; Wikipedia or wiki format websites
    } else if (this.Title ~= " - supermemo\.guru$") {
      this.Source := "SuperMemo Guru", this.Title := RegExReplace(this.Title, " - supermemo\.guru$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - SuperMemopedia$") {
      this.Source := "SuperMemopedia", this.Title := RegExReplace(this.Title, " - SuperMemopedia$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - SuperMemo Help$") {
      this.Source := "SuperMemo Help", this.Title := RegExReplace(this.Title, " - SuperMemo Help$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (IfContains(this.Url, "en.wikipedia.org")) {
      this.Source := "Wikipedia", this.Title := RegExReplace(this.Title, " - Wikipedia$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Simple English Wikipedia, the free encyclopedia$") {
      this.Source := "Simple English Wikipedia", this.Title := RegExReplace(this.Title, " - Simple English Wikipedia, the free encyclopedia")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last changed on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Wiktionary, the free dictionary$") {
      this.Source := "Wiktionary", this.Title := RegExReplace(this.Title, " - Wiktionary, the free dictionary$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Wikizionario$") {
      this.Source := "Wikizionario", this.Title := RegExReplace(this.Title, " - Wikizionario$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Questa pagina è stata modificata per l'ultima volta il (.*?) alle", v), this.Date := v1
    } else if (IfContains(this.Url, "en.wikiversity.org")) {
      this.Source := "Wikiversity", this.Title := RegExReplace(this.Title, " - Wikiversity$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Wikisource, the free online library$") {
      this.Source := "Wikisource", this.Title := RegExReplace(this.Title, " - Wikisource, the free online library$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Wikibooks, open books for an open world$") {
      this.Source := "Wikibooks", this.Title := RegExReplace(this.Title, " - Wikibooks, open books for an open world$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - ProofWiki$") {
      this.Source := "ProofWiki", this.Title := RegExReplace(this.Title, " - ProofWiki$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last modified on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Citizendium$") {
      this.Source := "Citizendium", this.Title := RegExReplace(this.Title, " - Citizendium$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last modified (.*?), (.*?)\.", v), this.Date := v2
    } else if (this.Title ~= " - 维基百科，自由的百科全书$") {
      this.Source := "维基百科", this.Title := RegExReplace(this.Title, " - 维基百科，自由的百科全书$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "本页面最后修订于(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 維基大典$") {
      this.Source := "維基大典", this.Title := RegExReplace(this.Title, " - 維基大典$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此頁(.*?) （", v), this.Date := v1
    } else if (this.Title ~= " - 維基百科，自由的百科全書$") {
      this.Source := "維基百科", this.Title := RegExReplace(this.Title, " - 維基百科，自由的百科全書$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "本頁面最後修訂於(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 維基詞典，自由的多語言詞典$") {
      this.Source := "維基詞典", this.Title := RegExReplace(this.Title, " - 維基詞典，自由的多語言詞典$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此頁面最後編輯於 (.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 維基百科，自由嘅百科全書$") {
      this.Source := "維基百科", this.Title := RegExReplace(this.Title, " - 維基百科，自由嘅百科全書$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "呢版上次改係(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 维基文库，自由的图书馆$") {
      this.Source := "维基文库", this.Title := RegExReplace(this.Title, " - 维基文库，自由的图书馆$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此页面最后编辑于(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 維基文庫，自由的圖書館$") {
      this.Source := "維基文庫", this.Title := RegExReplace(this.Title, " - 維基文庫，自由的圖書館$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此頁面最後編輯於(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 维基词典，自由的多语言词典$") {
      this.Source := "维基词典", this.Title := RegExReplace(this.Title, " - 维基词典，自由的多语言词典$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此页面最后编辑于(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - Wikipedia, la enciclopedia libre$") {
      this.Source := "Wikipedia", this.Title := RegExReplace(this.Title, " - Wikipedia, la enciclopedia libre$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Esta página se editó por última vez el (.*?) a ", v), this.Date := v1
    } else if (this.Title ~= " — Wikipédia$") {
      this.Source := "Wikipédia", this.Title := RegExReplace(this.Title, " — Wikipédia$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "La dernière modification de cette page a été faite .*? (\d+ .*? \d+) à", v), this.Date := v1
    } else if (this.Title ~= " - Wikcionario, el diccionario libre$") {
      this.Source := "Wikcionario", this.Title := RegExReplace(this.Title, " - Wikcionario, el diccionario libre$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Esta página se editó por última vez el (.*?) a ", v), this.Date := v1
    } else if (this.Title ~= " - Viquipèdia, l'enciclopèdia lliure$") {
      this.Source := "Viquipèdia", this.Title := RegExReplace(this.Title, " - Viquipèdia, l'enciclopèdia lliure$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "La pàgina va ser modificada per darrera vegada el (.*?) a ", v), this.Date := v1
    } else if (this.Title ~= " - Vicipaedia$") {
      this.Source := "Vicipaedia", this.Title := RegExReplace(this.Title, " - Vicipaedia$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Novissima mutatio die (.*?) hora", v), this.Date := v1
    } else if (IfContains(this.Url, "it.wikipedia.org")) {
      this.Source := "Wikipedia", this.Title := RegExReplace(this.Title, " - Wikipedia$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Questa pagina è stata modificata per l'ultima volta il (.*?) alle", v), this.Date := v1
    } else if (IfContains(this.Url, "ja.wikipedia.org")) {
      this.Source := "ウィキペディア", this.Title := RegExReplace(this.Title, " - Wikipedia$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "最終更新 (.*?) \(", v), this.Date := v1
    } else if (IfContains(this.Url, "fr.wikisource.org")) {
      this.Source := "Wikisource", this.Title := RegExReplace(this.Title, " - Wikisource$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "La dernière modification de cette page a été faite le (.*?) à ", v), this.Date := v1

    ; Other websites that can get date by copying full page
    } else if (IfContains(this.Url, "github.com")) {
      this.Source := "GitHub", this.Title := RegExReplace(this.Title, "^GitHub - "), this.Title := RegExReplace(this.Title, " · GitHub$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Latest commit .*? on (.*)", v), this.Date := v1
    } else if (this.Title ~= "_百度百科$") {
      this.Source := "百度百科", this.Title := RegExReplace(this.Title, "_百度百科$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "s)最近更新：.*（(.*)）", v), this.Date := v1
    } else if (IfContains(this.Url, "zhuanlan.zhihu.com")) {
      this.Source := "知乎", this.Title := RegExReplace(this.Title, " - 知乎$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "(编辑|发布)于 (.*?) ", v), this.Date := v2
    } else if (IfContains(this.Url, "economist.com")) {
      this.Source := "The Economist", this.Title := RegExReplace(this.Title, " \| The Economist$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, this.Months . " \d{1,2}(st|nd|rd|th) \d{4}", v), this.Date := v
    } else if (IfContains(this.Url, "investopedia.com")) {
      this.Source := "Investopedia"
      if (GetFullPage) {
        FullPageHTML := FullPageHTML ? FullPageHTML : GetSiteHTML(this.Url ? this.Url : this.GetUrl())
        if (GetDate) {
          ; RegExMatch(FullPageText, "Updated (.*)", v), this.Date := v1
          RegExMatch(FullPageHTML, "<div class=""mntl-attribution__item-date"">Updated (.*?)<\/div>", v), this.Date := v1
        }
        RegExMatch(FullPageHTML, "<meta name=""sailthru.author"" content=""(.*?)"" \/>", v), this.Author := v1
      }
    } else if (IfContains(this.Url, "mp.weixin.qq.com")) {
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
        if (RegExMatch(FullPageText, "Modified on (\d{4}-\d{2}-\d{2})", v)) {
          this.Date := v1
        } else if (RegExMatch(FullPageText, " (\d{4}-\d{2}-\d{2}) \d{2}:\d{2}", v)) {
          this.Date := v1
        }
      }
    } else if (this.Title ~= " \| Britannica$") {
      this.Source := "Britannica", this.Title := RegExReplace(this.Title, " \| Britannica$")
      if (GetFullPage) {
        FullPageHTML := FullPageHTML ? FullPageHTML : GetSiteHTML(this.Url ? this.Url : this.GetUrl())
        if (GetDate) {
          ; RegExMatch(FullPageText, "Last Updated: (.*) • ", v), this.Date := v1
          RegExMatch(FullPageHTML, "<time datetime="".*?"" >(.*?)<\/time>", v), this.Date := v1
          if (!this.Date)
            RegExMatch(GetSiteHTML(this.Url . "/additional-info"), "<td data-type=""date"" class=""text-nowrap"">\s+(.*?)<\/td>", v), this.Date := v1
        }
        RegExMatch(FullPageHTML, "<div class=""editor-title .*?"">(.*?)<\/div>", v), this.Author := v1
        if (this.Author == "The Editors of Encyclopaedia Britannica")
          this.Author := ""
      }
    } else if (RegExMatch(this.Title, " \| a podcast by (.*)$", v)) {
      this.Author := v1, this.Source := "PodBean", this.Title := RegExReplace(this.Title, " \| a podcast by (.*)$")
    } else if (IfContains(this.Url, "podbean.com")) {
      this.Source := "PodBean"
      RegExMatch(this.Title, " \| (.*?)$", v), this.Author := v1
      this.Title := RegExReplace(this.Title, " \| (.*?)$")
      if (IfContains(this.Url, "podbean.com/e") && GetFullPage && (GetDate || GetTimeStamp) && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
        if (GetDate)
          RegExMatch(FullPageText, this.Months . " \d{2}, \d{4}", v), this.Date := v
        if (GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(this.FullTitle,, RestoreClip)
      }
    } else if (this.Title ~= " - GeeksforGeeks$") {
      this.Source := "GeeksforGeeks", this.Title := RegExReplace(this.Title, " - GeeksforGeeks$")
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Last Updated : (.*)", v), this.Date := v1
    } else if (RegExMatch(this.Title, "- (.*?) \(podcast\) \| Listen Notes$", v)) {
      this.Author := v1, this.Source := "Listen Notes", this.Title := RegExReplace(this.Title, "- .*? \(podcast\) \| Listen Notes$")
      if (GetFullPage && (GetDate || GetTimeStamp) && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
        if (GetDate)
          RegExMatch(FullPageText, this.Months . "\. \d{1,2}, \d{4}", v), this.Date := v
        if (GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(this.FullTitle, FullPageText, RestoreClip)
      }
    } else if (RegExMatch(this.Title, " \| by (.*?) \| ((.*?) \| )?Medium$", v)) {
      this.Source := "Medium", this.Title := RegExReplace(this.Title, " \| by .*? \| Medium$"), this.Author := v1
      if (GetFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, this.Months . " \d{1,2}, \d{4}", v), this.Date := v

    } else {
      ReversedTitle := StrReverse(this.Title)
      if (IfContains(ReversedTitle, " | ") && (!IfContains(ReversedTitle, " - ") || (InStr(ReversedTitle, " | ") < InStr(ReversedTitle, " - ")))) {
        Separator := " | "
      } else if (IfContains(ReversedTitle, " – ")) {
        Separator := " – "  ; sites like BetterExplained
      } else if (IfContains(ReversedTitle, " - ")) {
        Separator := " - "
      } else if (IfContains(ReversedTitle, " — ")) {
        Separator := " — "
      } else if (IfContains(ReversedTitle, " -- ")) {
        Separator := " -- "
      } else if (IfContains(ReversedTitle, " • ")) {
        Separator := " • "
      }
      if (pos := Separator ? InStr(ReversedTitle, Separator) : 0) {
        TitleLength := StrLen(this.Title) - pos - StrLen(Separator) + 1
        this.Source := SubStr(this.Title, TitleLength + 1, StrLen(this.Title))
        this.Source := StrReplace(this.Source, Separator,,, 1)
        this.Title := SubStr(this.Title, 1, TitleLength)
      }
    }
  }

  GetFullPage(RestoreClip:=true) {
    if (RestoreClip) {
      global WinClip
      WinClip.Snap(data)
    }
    this.ActivateBrowser()
    CopyAll()
    Text := Clipboard
    if (RestoreClip)
      WinClip.Restore(data)
    return Text
  }

  GetSecFromTime(TimeStamp) {
    if (!TimeStamp)
      return 0
    aTime := RevArr(StrSplit(TimeStamp, ":"))
    aTime[3] := aTime[3] ? aTime[3] : 0
    return aTime[1] + aTime[2] * 60 + aTime[3] * 3600
  }

  GetUrl(Parsed:=true) {
    global guiaBrowser
    this.GetGuiaBrowser()
    Url := guiaBrowser.GetCurrentURL()
    return Parsed ? this.ParseUrl(Url) : Url
  }

  GetTimeStamp(Title:="", FullPageText:="", RestoreClip:=true) {
    Title := Title ? Title : this.GetFullTitle()
    if (Title ~= " - YouTube$") {
      if (FullPageText := FullPageText ? FullPageText : this.GetFullPage(RestoreClip)) {
        RegExMatch(FullPageText, "\r\n([0-9:]+) \/ ([0-9:]+)", v)
        ; v1 == v2 means at end of video
        TimeStamp := (v1 == v2) ? "0:00" : v1
      }
    } else if (Title ~= "- .*? \(podcast\) \| Listen Notes$") {
      if (FullPageText := FullPageText ? FullPageText : this.GetFullPage(RestoreClip))
        RegExMatch(FullPageText, "\d\.\dx\r\n\K.*", TimeStamp)
    } else {
      global guiaBrowser
      this.GetGuiaBrowser()
      if (Title ~= "_[^_]+ - 喜马拉雅$") {
        TimeStamp := guiaBrowser.FindFirstByName("^\d{2}:\d{2}:\d{2}$",, "regex").CurrentName
      } else {
        TimeStamp := guiaBrowser.FindFirstByName("^(\d{1,2}:)?\d{1,2}:\d{1,2}$",, "regex").CurrentName
      }
    }
    TimeStamp := RegExReplace(TimeStamp, "^00:(?=\d{2}:\d{2})")
    TimeStamp := RegExReplace(TimeStamp, "^0(?=\d)")
    return TimeStamp
  }

  RunInIE(Url) {
    if ((Url ~= "file:\/\/") && (Url ~= "#.*"))
      Url := RegExReplace(Url, "#.*")
    wIE := "ahk_class IEFrame ahk_exe iexplore.exe"
    if (!el := WinExist(wIE)) {
      ie := ComObjCreate("InternetExplorer.Application")
      ie.Visible := true
      ie.Navigate(Url)
    } else {
      if (ControlGetText("Edit1", wIE)) {  ; current page is not new tab page
        ControlSend, ahk_parent, {Ctrl Down}t{Ctrl Up}, % wIE
        ControlTextWait("Edit1", "", wIE)
      }
      ControlSetText, Edit1, % Url, % wIE
      ControlSend, Edit1, {Enter}, % wIE
    }
    WinActivate, % wIE
  }

  GetFullTitle(w:="") {
    Title := w ? WinGetTitle(w) : WinGetTitle("ahk_group Browser")
    return RegExReplace(Title, "( - Google Chrome| — Mozilla Firefox|( and \d+ more pages?)? - [^-]+ - Microsoft​ Edge)$")
  }

  IsVideoOrAudioSite(Title:="", w:="") {
    Title := Title ? Title : this.GetFullTitle(w)
    ; Return 1 if time stamp can be in url and ^a covers the time stamp
    if (Title ~= " - YouTube$") {
      return 1
    ; Return 2 if time stamp can be in url but ^a doesn't cover time stamp
    } else if (Title ~= "(_哔哩哔哩_bilibili|-bilibili-哔哩哔哩)$") {
      return 2
    ; Return 3 if time stamp can't be in url and ^a doesn't cover time stamp
    } else if (Title ~= "^(Netflix|Watch full .*? english sub \| Kissasian|Watch .*? HD online|Watch Free .*? Full Movies Online|Watch .*? online free on 9anime|Watch .*? Sub/Dub online Free on HiAnime\.to)$") {
      return 3
    } else if (Title ~= "(-免费在线观看-爱壹帆|_[^_]+ - 喜马拉雅|_高清在线观看 – NO视频| - Animelon| on Vimeo| - video Dailymotion)$") {
      return 3
    }
  }

  Highlight(CollName:="", PlainText:="", Url:="") {
    this.ActivateBrowser()
    global SM
    CollName := CollName ? CollName : SM.GetCollName()
    Sent := False

    if (RegexMatch(PlainText, "(?<!\s)(?<!\d)(\d+,?)+\.$", v)) {
      if (Sent := IfContains(Url := Url ? Url : this.GetUrl(), "fr.wikipedia.org"))
        Send % "+{Left " . StrLen(v) . "}"
    }

    if (RegexMatch(PlainText, "\.\K(\d+​)+\d+$", v)) {
      if (Sent := IfContains(Url := Url ? Url : this.GetUrl(), "es.wikipedia.org"))
        Send % "+{Left " . StrLen(v) . "}"
    }

    if (!Sent && RegexMatch(PlainText, "(\[(\d+|note \d+|citation needed)\])+(。|.)?$|\[\d+\]: \d+(。|.)?$|(?<=\.)\d+$", v)) {
      if (Sent := IfContains(Url ? Url : this.GetUrl(), "wikipedia.org,wikiquote.org"))
        Send % "+{Left " . StrLen(v) . "}"
    }

    if (!Sent && RegexMatch(PlainText, "\d+$", v)) {
      if (IfContains(Url, "investopedia.com"))
        Send % "+{Left " . StrLen(v) . "}"
    }

    ; ControlSend doesn't work reliably because browser can't highlight in background
    if (CollName = "zen") {
      Send ^+h
    } else {
      Send !+h
    }
    Sleep 700  ; time for visual feedback
  }

  ActivateBrowser(wBrowser:="ahk_group Browser") {
    if (!WinActive(wBrowser))
      WinActivate, % wBrowser
  }

  SearchInYT(Title, Link) {
    ShellRun("https://www.youtube.com/results?search_query=" . EncodeDecodeURI(Title))
    WinWaitActive, ahk_group Browser
    Sleep 400
    global guiaBrowser
    this.GetGuiaBrowser()
    guiaBrowser.WaitPageLoad()
    guiaBrowser.WaitElementExist("ControlType=Text AND Name='Filters'")  ; wait till page is fully loaded
    auiaLinks := guiaBrowser.FindAllByType("Hyperlink")
    Link := RegExReplace(Link, "https:\/\/(www\.)?")
    for i, v in auiaLinks {
      if (IfContains(v.CurrentValue, Link)) {
        v.Click()
        return true
      }
    }
  }

  TimeStampToUrl(Url, TimeStamp) {
    Sec := this.GetSecFromTime(TimeStamp)
    if (IfContains(Url, "youtube.com")) {
      Url := RegExReplace(Url, "&t=.*?s|$", "&t=" . Sec . "s",, 1)
    } else if (IfContains(Url, "bilibili.com")) {
      if (Url ~= "\?p=\d+") {
        Url := RegExReplace(Url, "&t=.*|$", "&t=" . Sec,, 1)
      } else {
        Url := RegExReplace(Url, "\?t=.*|$", "?t=" . Sec,, 1)
      }
    } else {
      Url := ""
    }
    return Url
  }
}
