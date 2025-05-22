#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && SM.IsEditingHTML())
^!l::
  ContLearn := SM.IsGrading() ? 1 : SM.IsLearning()
  Item := (ContLearn == 1) ? true : false
  CurrTimeDisplay := GetDetailedTime()
  CurrTimeFileName := RegExReplace(CurrTimeDisplay, ",? |:", "-")
  ClipSaved := ClipboardAll
  KeyWait Alt
  KeyWait Ctrl
  Text := Copy(false, true)
  if ((Text = "") || (Text ~= "^\s+$")) {
    SetToolTip("Text not found.")
    Clipboard := ClipSaved
    return
  }

  if (!IfContains(Text, "<IMG")) {  ; text
    SetToolTip("LaTeX to image converting...")
    Send {BS}^{f7}  ; set read point
    LatexFormula := Trim(ProcessLatexFormula(Clipboard), "$")

    ; After almost a year since I wrote this script, I finially figured out this f**ker website encodes the formula twice. Well, I suppose I don't use math that often in SM
    LatexFormula := EncodeDecodeURI(EncodeDecodeURI(LatexFormula))
    LatexLink := "https://latex.vimsky.com/test.image.latex.php?fmt=png&val=%255Cdpi%257B150%257D%2520%255Cbg_white%2520%255Chuge%2520" . LatexFormula . "&dl=1"

    ; This website seems to be better? (2024-05-20)
    ; LatexLink := "https://latex.codecogs.com/png.image?\dpi{300}" . LatexFormula
    ; LatexFormula := EncodeDecodeURI(LatexFormula)

    LatexFolderPath := SM.GetCollPath(Text := WinGetText("ahk_class TElWind"))
                     . SM.GetCollName(Text) . "\elements\LaTeX"
    LatexPath := LatexFolderPath . "\" . CurrTimeFileName . ".png"
    SetTimer, DownloadLatex, -1
    InsideHTMLPath := "file:///[PrimaryStorage]LaTeX\" . CurrTimeFileName . ".png"
    FileCreateDir % LatexFolderPath
    LatexPlaceHolder := GetDetailedTime()
    Clip("<img alt=""" . LatexFormula . """ src=""" . InsideHTMLPath . """>" . LatexPlaceHolder,, false, true)
    if (ContLearn == 1) {  ; item and "Show answer"
      Send {Esc}
      SM.WaitTextExit()
    }
    SM.SaveHTML()
    SM.WaitHTMLFocus()
    HTML := FileRead(HTMLPath := SM.LoopForFilePath(false))
    HTML := StrReplace(HTML, LatexPlaceHolder)

    /*
      Recommended css setting for anti-merge class:
      .anti-merge {
        position: absolute;
        left: -9999px;
        top: -9999px;
      }
    */

    AntiMerge := "<SPAN class=anti-merge>Last LaTeX to image conversion at " . CurrTimeDisplay . "</SPAN>"
    HTML := RegExReplace(HTML, "<SPAN class=anti-merge>Last LaTeX to image conversion at .*?(<\/SPAN>|$)", AntiMerge, v)
    if (!v)
      HTML .= "`n" . AntiMerge
    SM.EmptyHTMLComp()
    WinWaitActive, ahk_class TElWind
    SM.WaitTextFocus()
    x := A_CaretX, y := A_CaretY
    Send ^{Home}
    WaitCaretMove(x, y, 700)
    Clip(HTML,, false, "sm")
    if (ContLearn == 1) {  ; item and "Show answer"
      Send {Esc}
      SM.WaitTextExit()
    }
    SM.SaveHTML()
    if (Item) {
      WinWaitActive, ahk_class TElWind
      Send ^+{f7}  ; clear read point
    }
    Vim.State.SetMode("Vim_Normal")

  } else {  ; image
    SetToolTip("Image to LaTeX converting...")
    Send {BS}  ; otherwise might contain unwanted format
    RegExMatch(Text, "alt=""(.*?)""", v)
    if (!v)
      RegExMatch(Text, "alt=(.*?) ", v)
    if (!v1) {
      RegExMatch(Text, "title=""(.*?)""", v)
      if (!v)
        RegExMatch(Text, "title=(.*?) ", v)
    }
    LatexFormula := EncodeDecodeURI(EncodeDecodeURI(v1, false), false)
    LatexFormula := ProcessLatexFormula(LatexFormula)
    RegExMatch(Text, "src=""(.*?)""", v)
    if (!v)
      RegExMatch(Text, "src=(.*?) ", v)
    LatexPath := StrReplace(v1, "file:///")
    LatexFormula := StrReplace(LatexFormula, "&amp;", "&")
    LatexFormula := StrReplace(LatexFormula, "&#10;", " ")
    LatexFormula := Trim(LatexFormula, "$")  ; for websites like The Art of Problem Solving
    Clip(LatexFormula, true, false)
    FileDelete % LatexPath
    Vim.State.SetMode("Vim_Visual")
  }
  Clipboard := ClipSaved
return

ProcessLatexFormula(LatexFormula) {
  LatexFormula := RegExReplace(LatexFormula, "{\\(display|text)style |\\(display|text)style{ ?",, v)  ; from Wikipedia, Wikibooks, Better Explained, etc
  if (v)
    LatexFormula := RegExReplace(LatexFormula, "}$")
  LatexFormula := RegExReplace(LatexFormula, "\\\(\\(displaystyle)?",, v)  ; from LibreTexts
  if (v)
    LatexFormula := RegExReplace(LatexFormula, "\)$")
  LatexFormula := StrReplace(LatexFormula, "{\ce ",, v)  ; from Wikipedia's chemistry formulae
  if (v)
    LatexFormula := RegExReplace(LatexFormula, "}$")
  LatexFormula := RegExReplace(LatexFormula, "^\\\[|\\\]$")  ; removing start \[ and end ]\ (in Better Explained)
  LatexFormula := RegExReplace(LatexFormula, "^\\\(|\\\)$")  ; removing start \( and end )\ (in LibreTexts)
  return Trim(LatexFormula)
}

DownloadLatex:
  UrlDownloadToFile, % LatexLink, % LatexPath
return

