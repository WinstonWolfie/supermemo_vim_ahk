ClipboardGet_HTML( byref Data ) { ; https://www.autohotkey.com/boards/viewtopic.php?t=13063
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
   html := RegExReplace(html, "\r?\n|\r", "<br>") ; added this because original strips line breaks
   oHTML := ComObjCreate("HtmlFile") 
   oHTML.write(html)
   return % oHTML.documentElement.innerText 
}

ClickDPIAdjusted(coord_x, coord_y) {
    coord_x *= A_ScreenDPI / 96
    coord_y *= A_ScreenDPI / 96
    click, %coord_x% %coord_y%
}

StrReverse(String) { ; https://www.autohotkey.com/boards/viewtopic.php?t=27215
	String .= "", DllCall("msvcrt.dll\_wcsrev", "Ptr", &String, "CDecl")
    return String
}