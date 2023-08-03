class VimHTML {
  __New(Vim) {
    this.Vim := Vim
  }

  ClipboardGet_HTML( byref Data ) {  ; www.autohotkey.com/forum/viewtopic.php?p=392624#392624
   If CBID := DllCall( "RegisterClipboardFormat", Str,"HTML Format", UInt )
    If DllCall( "IsClipboardFormatAvailable", UInt,CBID ) <> 0
     If DllCall( "OpenClipboard", UInt,0 ) <> 0
      If hData := DllCall( "GetClipboardData", UInt,CBID, UInt )
         DataL := DllCall( "GlobalSize", UInt,hData, UInt )
       , pData := DllCall( "GlobalLock", UInt,hData, UInt )
       , VarSetCapacity( data, dataL * ( A_IsUnicode ? 2 : 1 ) ), StrGet := "StrGet"
       , A_IsUnicode ? Data := %StrGet%( pData, dataL, 0 )
                     : DllCall( "lstrcpyn", Str,Data, UInt,pData, UInt,DataL )
       , DllCall( "GlobalUnlock", UInt,hData )
   DllCall( "CloseClipboard" )
   Return dataL ? dataL : 0
  }

  Clean(str, nuke:=false, LineBreak:=false, Url:="") {
    ; zzz in case you used f6 in SuperMemo to remove format before,
    ; which disables the tag by adding zzz (eg, <FONT> -> <ZZZFONT>)

    ; All attributes removal detects for <> surrounding
    ; however, sometimes if a text attribute is used, and it has HTML tag
    ; style and others removal might not be working
    ; Example: https://www.scientificamerican.com/article/can-newborn-neurons-prevent-addiction/
    ; This will likely not be fixed

    ToolTip("Cleaning HTML...", true)

    if (nuke) {
      ; Classes
      str := RegExReplace(str, "is)<([^<>]+)?\K class="".*?""(?=([^<>]+)?>)")
      str := RegExReplace(str, "is)<([^<>]+)?\K class=[^ >]+(?=([^<>]+)?>)")
    }

    if (LineBreak)
      str := RegExReplace(str, "i)<(BR|DIV)", "<P")

    if (IfContains(url, "economist.com"))
      str := RegExReplace(str, "is)(<[^\/]+? .*?font-family: var\(--ds-type-system-.*?-smallcaps\).*?)>", "$1 class=uppercase>")

    ; Converts font-style to tags
    str := RegExReplace(str, "is)(<[^\/]+? .*?font-style: italic.*?)>", "$1 class=italic>")
    str := RegExReplace(str, "is)(<[^\/]+? .*?font-weight: bold.*?)>", "$1 class=bold>")

    ; Styles and fonts
    str := RegExReplace(str, "is)<([^<>]+)?\K (zzz)?style="".*?""(?=([^<>]+)?>)")
    str := RegExReplace(str, "is)<([^<>]+)?\K (zzz)?style='.*?'(?=([^<>]+)?>)")
    str := RegExReplace(str, "is)<\/?(zzz)?(font|form)( .*?)?>")

    ; Scripts
    str := RegExReplace(str, "is)<(zzz)?iframe( .*?)?>.*?<\/(zzz)?iframe>")
    str := RegExReplace(str, "is)<(zzz)?button( .*?)?>.*?<\/(zzz)?button>")
    str := RegExReplace(str, "is)<(zzz)?script( .*?)?>.*?<\/(zzz)?script>")
    str := RegExReplace(str, "is)<(zzz)?input( .*?)?"">")
    str := RegExReplace(str, "is)<([^<>]+)?\K (bgColor|onError|onLoad|onClick)="".*?""(?=([^<>]+)?>)")
    str := RegExReplace(str, "is)<([^<>]+)?\K (bgColor|onError|onLoad|onClick)=[^ >]+(?=([^<>]+)?>)")
    str := RegExReplace(str, "is)<([^<>]+)?\K (onMouseOver|onMouseOut)=.*?;(?=([^<>]+)?>)")

    str := RegExReplace(str, "is)<p( [^>]+)?>(&nbsp;|\s| )<\/p>")

    RemoveToolTip()
    return str
  }

  ; https://www.autohotkey.com/boards/viewtopic.php?t=80706
  SetClipboardHTML(HtmlBody, HtmlHead:="", AltText:="") {       ; v0.67 by SKAN on D393/D42B
  Local  F, Html, pMem, Bytes, hMemHTM:=0, hMemTXT:=0, Res1:=1, Res2:=1   ; @ tiny.cc/t80706
  Static CF_UNICODETEXT:=13,   CFID:=DllCall("RegisterClipboardFormat", "Str","HTML Format")

  If ! DllCall("OpenClipboard", "Ptr",A_ScriptHwnd)
    Return 0
  Else DllCall("EmptyClipboard")

  If (HtmlBody!="")
  {
    Html     := "Version:0.9`r`nStartHTML:00000000`r`nEndHTML:00000000`r`nStartFragment"
        . ":00000000`r`nEndFragment:00000000`r`n<!DOCTYPE>`r`n<html>`r`n<head>`r`n"
              ; . HtmlHead . "`r`n</head>`r`n<body>`r`n<!--StartFragment-->`r`n"
              . HtmlHead . "`r`n</head>`r`n<body>`r`n<!--StartFragment-->"
                . HtmlBody . "<!--EndFragment-->`r`n</body>`r`n</html>"
                ; . HtmlBody . "`r`n<!--EndFragment-->`r`n</body>`r`n</html>"

    Bytes    := StrPut(Html, "utf-8")
    hMemHTM  := DllCall("GlobalAlloc", "Int",0x42, "Ptr",Bytes+4, "Ptr")
    pMem     := DllCall("GlobalLock", "Ptr",hMemHTM, "Ptr")
    StrPut(Html, pMem, Bytes, "utf-8")

    F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","<html>", "Ptr") - pMem
    StrPut(Format("{:08}", F), pMem+23, 8, "utf-8")
    F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","</html>", "Ptr") - pMem
    StrPut(Format("{:08}", F), pMem+41, 8, "utf-8")
    F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","<!--StartFra", "Ptr") - pMem
    StrPut(Format("{:08}", F), pMem+65, 8, "utf-8")
    F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","<!--EndFragm", "Ptr") - pMem
    StrPut(Format("{:08}", F), pMem+87, 8, "utf-8")

    DllCall("GlobalUnlock", "Ptr",hMemHTM)
    Res1  := DllCall("SetClipboardData", "Int",CFID, "Ptr",hMemHTM)
  }

  If (AltText!="")
  {
    Bytes    := StrPut(AltText, "utf-16")
    hMemTXT  := DllCall("GlobalAlloc", "Int",0x42, "Ptr",(Bytes*2)+8, "Ptr")
    pMem     := DllCall("GlobalLock", "Ptr",hMemTXT, "Ptr")
    StrPut(AltText, pMem, Bytes, "utf-16")
    DllCall("GlobalUnlock", "Ptr",hMemTXT)
    Res2  := DllCall("SetClipboardData", "Int",CF_UNICODETEXT, "Ptr",hMemTXT)
  }

  DllCall("CloseClipboard")
  hMemHTM := hMemHTM ? DllCall("GlobalFree", "Ptr",hMemHTM) : 0

  Return (Res1 & Res2)
  }
}
