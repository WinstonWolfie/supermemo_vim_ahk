class VimHTML{
  __New(Vim) {
    this.Vim := Vim
  }

  ClipboardGet_HTML( byref Data ) { ; www.autohotkey.com/forum/viewtopic.php?p=392624#392624
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

  Clean(Str) {
    ; zzz in case you used f6 to remove format before,
    ; which disables the tag by adding zzz (e.g. <FONT> -> <ZZZFONT>)
    Str := RegExReplace(Str, "is)( zzz| )style=""((?!BACKGROUND-IMAGE: url).)*?""")
    Str := RegExReplace(Str, "is)( zzz| )style='((?!BACKGROUND-IMAGE: url).)*?'")
    Str := RegExReplace(Str, "ism)<\/{0,1}(zzz|)font.*?>")
    Str := RegExReplace(Str, "is)<BR", "<P")
    Str := RegExReplace(Str, "i)<H5 dir=ltr align=left>")
    Str := RegExReplace(Str, "s)src=""file:\/\/\/.*?elements\/", "src=""file:///[PrimaryStorage]")
    Str := RegExReplace(Str, "i)\/svg\/", "/png/")
    Str := RegExReplace(Str, "i)\n<P.*>&nbsp;<\/P>")
    Str := RegExReplace(Str, "i)\n<DIV.*>&nbsp;<\/DIV>")
    Return Str
  }
}
