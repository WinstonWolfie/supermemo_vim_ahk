#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
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

    RegExMatch(str, r := "i)^<strong><font color=""?blue""?>.*? : <\/font><\/strong>", SMSplit)
    if (SMSplit)
      str := RegExReplace(str, r, SMSplitPlaceHolder := GetDetailedTime())

    if (nuke) {
      ; Classes
      str := RegExReplace(str, "is)<[^>]+\K\sclass="".*?""(?=([^>]+)?>)")
      str := RegExReplace(str, "is)<[^>]+\K\sclass=[^ >]+(?=([^>]+)?>)")
    }

    if (LineBreak)
      str := RegExReplace(str, "i)<(BR|(\/)?DIV)", "<$2P")

    if (IfContains(url, "economist.com"))
      str := StrReplace(str, "<small", "<small class=uppercase")
      ; str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+font-family: var\(--ds-type-system-.*?-smallcaps\))(?=[^>]+>)", " class=uppercase ")

    ; Ilya Frank
    ; str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+COLOR: green)(?=[^>]+>)", " class=ilya-frank-translation ")

    ; Converts font-style to tags
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+font-style: italic)(?=[^>]+>)", " class=italic ")
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+font-weight: bold)(?=[^>]+>)", " class=bold ")
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+text-decoration: underline)(?=[^>]+>)", " class=underline ")

    ; For Dummies books
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?class=zcheltitalic(?=([^>]+)?>)", " class=italic")

    ; Styles and fonts
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?style="".*?""(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?style='.*?'(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?style=[^>]+(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<\/?(zzz)?(font|form)([^>]+)?>")

    ; SuperMemo uses IE7; svg was introduced in IE9
    str := RegExReplace(str, "is)<\/?(svg|path)([^>]+)?>")
    str := StrReplace(str, "https://wikimedia.org/api/rest_v1/media/math/render/svg/", "https://wikimedia.org/api/rest_v1/media/math/render/png/")

    ; Scripts
    str := RegExReplace(str, "is)<(zzz)?iframe([^>]+)?>.*?<\/(zzz)?iframe>")
    str := RegExReplace(str, "is)<(zzz)?button([^>]+)?>.*?<\/(zzz)?button>")
    str := RegExReplace(str, "is)<(zzz)?script([^>]+)?>.*?<\/(zzz)?script>")
    str := RegExReplace(str, "is)<(zzz)?input([^>]+)?>")
    str := RegExReplace(str, "is)<[^>]+\K\s(bgcolor|onerror|onload|onclick|onmouseover|onmouseout)="".*?""(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(bgcolor|onerror|onload|onclick|onmouseover|onmouseout)=[^ >]+(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(onmouseover|onmouseout)=[^;]+;(?=([^>]+)?>)")

    ; Remove empty paragraphs
    str := RegExReplace(str, "is)<p([^>]+)?>(&nbsp;|\s| )+<\/p>")
    str := RegExReplace(str, "is)<div([^>]+)?>(&nbsp;|\s| )+<\/div>")

    v := 1
    while (v)  ; remove <div></div>
      str := RegExReplace(str, "is)<div([^>]+)?>(\n+)?<\/div>",, v)

    if (SMSplit)
      str := StrReplace(str, SMSplitPlaceHolder, SMSplit)

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
