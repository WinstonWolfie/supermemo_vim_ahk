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

  ; Semi-"transcribed" from this quicker script:
  ; https://getquicker.net/Sharedaction?code=859bda04-fe78-4385-1b37-08d88a0dba1c
  Clean(str, nuke:=false) {
    ; zzz in case you used f6 in SuperMemo to remove format before,
    ; which disables the tag by adding zzz (e.g. <FONT> -> <ZZZFONT>)
    str := RegExReplace(str, "i)(zzz)?style="".*?""")
    str := RegExReplace(str, "i)(zzz)?style='.*?'")
    str := RegExReplace(str, "ism)<\/?(zzz)?font.*?>")
    str := RegExReplace(str, "i)<P( .*?>|>)(<BR>)+<\/P>")
    str := RegExReplace(str, "s)src=""file:\/\/\/.*?elements\/", "src=""file:///[PrimaryStorage]")
    str := RegExReplace(str, "i)<P( .*?>|>)(&nbsp;)+<\/P>")
    str := RegExReplace(str, "i)<DIV( .*?>|>)(&nbsp;)+<\/DIV>")
    str := RegExReplace(str, "i)<(zzz)?iframe( .*?>|>).*?<\/(zzz)?iframe>")
    str := RegExReplace(str, "i)<(zzz)?button( .*?>|>).*?<\/(zzz)?button>")
    if (nuke) {
      str := RegExReplace(str, "i)class=[^ >]+")
      str := RegExReplace(str, "i)class=""[^""]+""")
    }
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
              ; . HtmlHead . "`r`n</head>`r`n<body>`r`n<!--StartFragment -->`r`n"
              . HtmlHead . "`r`n</head>`r`n<body>`r`n<!--StartFragment -->"
                . HtmlBody . "`r`n<!--EndFragment -->`r`n</body>`r`n</html>"

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
