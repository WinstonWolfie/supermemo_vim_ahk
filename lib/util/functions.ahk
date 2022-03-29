ClipboardGet_HTML( byref Data ) {  ; https://www.autohotkey.com/boards/viewtopic.php?t=13063
 If CBID := DllCall( "RegisterClipboardFormat", Str,"HTML Format", UInt )
  If DllCall( "IsClipboardFormatAvailable", UInt,CBID ) <> 0
   If DllCall( "OpenClipboard", UInt,0 ) <> 0
    If hData := DllCall( "GetClipboardData", UInt,CBID, UInt )
       DataL := DllCall( "GlobalSize", UInt,hData, UInt )
     , pData := DllCall( "GlobalLock", UInt,hData, UInt )
     , Data := StrGet( pData, dataL, "UTF-8" )
     , DllCall( "GlobalUnlock", UInt,hData )
 DllCall( "CloseClipboard" )
Return dataL ? dataL : 0
}

ConvertHTML(str) {
	ClipSaved := ClipboardAll
	Clipboard := ""
	Clipboard := str
	ClipWait 10
	if ClipboardGet_HTML( Data ) {
		Clipboard := ClipSaved
		Return Data
	} else
		Clipboard := ClipSaved
}

CleanHTML(str) {
	; zzz in case you used f6 to remove format before
	; which would disable the tag by adding a zzz (like <FONT> -> <ZZZFONT>)
	str := RegExReplace(str, "is)( zzz| )style=""((?!BACKGROUND-IMAGE: url).)*?""")
	str := RegExReplace(str, "is)( zzz| )style='((?!BACKGROUND-IMAGE: url).)*?'")
	str := RegExReplace(str, "ism)<\/{0,1}(zzz|)font.*?>")
	str := RegExReplace(str, "is)<BR", "<P")
	str := RegExReplace(str, "i)<H5 dir=ltr align=left>")
	str := RegExReplace(str, "s)src=""file:\/\/\/.*?elements\/", "src=""file:///[PrimaryStorage]")
	str := RegExReplace(str, "i)\/svg\/", "/png/")
	Return str
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
                         . HtmlHead . "`r`n</head>`r`n<body>`r`n<!--StartFragment -->`r`n"
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

;#########################################################################################
;uri encode/decode by Titan
;Thread: http://www.autohotkey.com/forum/topic18876.html
;About: http://en.wikipedia.org/wiki/Percent_encoding
;two functions by titan: (slightly modified by infogulch)
; https://www.autohotkey.com/board/topic/29866-encoding-and-decoding-functions-v11/

Dec_Uri(str) 
{
   Loop
      If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
      Else Break
   Return, str
}

Enc_Uri(str) 
{
	f = %A_FormatInteger%
	SetFormat, Integer, Hex
	If RegExMatch(str, "^\w+:/{0,2}", pr)
		StringTrimLeft, str, str, StrLen(pr)
	StringReplace, str, str, `%, `%25, All
	Loop
		If RegExMatch(str, "i)[^\w\.~%/:]", char)
			StringReplace, str, str, %char%, % "%" . SubStr(Asc(char),3), All
		Else Break
	SetFormat, Integer, %f%
	Return, pr . str
}
;#########################################################################################

html_decode(html) {	
   ; original name: ComUnHTML() by 'Guest' from
   ; https://autohotkey.com/board/topic/47356-unhtm-remove-html-formatting-from-a-string-updated/page-2 
   html := RegExReplace(html, "\r?\n|\r", "<br>")  ; added this because original strips line breaks
   oHTML := ComObjCreate("HtmlFile") 
   oHTML.write(html)
   return % oHTML.documentElement.innerText 
}

ClickDPIAdjusted(coord_x, coord_y) {
    coord_x *= A_ScreenDPI / 96
    coord_y *= A_ScreenDPI / 96
    click, %coord_x% %coord_y%
}

StrReverse(String) {  ; https://www.autohotkey.com/boards/viewtopic.php?t=27215
	String .= "", DllCall("msvcrt.dll\_wcsrev", "Ptr", &String, "CDecl")
    return String
}