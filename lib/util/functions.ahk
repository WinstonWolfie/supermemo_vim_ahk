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

ClickDPIAdjusted(coord_x, coord_y) {
    coord_x *= A_ScreenDPI / 96
    coord_y *= A_ScreenDPI / 96
    click, %coord_x% %coord_y%
}

StrReverse(String) { ; https://www.autohotkey.com/boards/viewtopic.php?t=27215
	String .= "", DllCall("msvcrt.dll\_wcsrev", "Ptr", &String, "CDecl")
    return String
}