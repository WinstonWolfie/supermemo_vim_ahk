; https://github.com/Vonng/Capslock
;=====================================================================o
;                   Feng Ruohang's AHK Script                         | 
;                      CapsLock Enhancement                           |
;---------------------------------------------------------------------o
; Description:                                                        |
;    This Script is wrote by Feng Ruohang via AutoHotKey Script. It   |
; Provieds an enhancement towards the "Useless Key" CapsLock, and     |
; turns CapsLock into an useful function Key just like Ctrl and Alt   |
; by combining CapsLock with almost all other keys in the keyboard.   |
;---------------------------------------------------------------------o
; Use it whatever and wherever you like. Hope it help                 |
;=====================================================================o

;=====================================================================o
;                       CapsLock Switcher:                           ;|
;---------------------------------o-----------------------------------o
;                    CapsLock + ` | {CapsLock}                       ;|
;---------------------------------o-----------------------------------o
CapsLock & `::                                                       ;|
GetKeyState, CapsLockState, CapsLock, T                              ;|
if CapsLockState = D                                                 ;|
    SetCapsLockState, AlwaysOff                                      ;|
else                                                                 ;|
    SetCapsLockState, AlwaysOn                                       ;|
KeyWait, ``                                                          ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                         CapsLock Escaper:                          ;|
;----------------------------------o----------------------------------o
;                        CapsLock  |  {ESC}                          ;|
;----------------------------------o----------------------------------o
CapsLock::send {ESC}                                                 ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                    CapsLock Direction Navigator                    ;|
;-----------------------------------o---------------------------------o
;                      CapsLock + h |  Left                          ;|
;                      CapsLock + j |  Down                          ;|
;                      CapsLock + k |  Up                            ;|
;                      CapsLock + l |  Right                         ;|
;                      Ctrl, Alt Compatible                          ;|
;-----------------------------------o---------------------------------o
CapsLock & h::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        send {Left}                                                  ;|
    else                                                             ;|
        send +{Left}                                                 ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        send ^{Left}                                                 ;|
    else                                                             ;|
        send +^{Left}                                                ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & j::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        send {Down}                                                  ;|
    else                                                             ;|
        send +{Down}                                                 ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        send ^{Down}                                                 ;|
    else                                                             ;|
        send +^{Down}                                                ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & k::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        send {Up}                                                    ;|
    else                                                             ;|
        send +{Up}                                                   ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        send ^{Up}                                                   ;|
    else                                                             ;|
        send +^{Up}                                                  ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & l::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        send {Right}                                                 ;|
    else                                                             ;|
        send +{Right}                                                ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        send ^{Right}                                                ;|
    else                                                             ;|
        send +^{Right}                                               ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                     CapsLock Home/End Navigator                    ;|
;-----------------------------------o---------------------------------o
;                      CapsLock + i |  Home                          ;|
;                      CapsLock + o |  End                           ;|
;                      Ctrl, Alt Compatible                          ;|
;-----------------------------------o---------------------------------o
CapsLock & i::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        send {Home}                                                  ;|
    else                                                             ;|
        send +{Home}                                                 ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        send ^{Home}                                                 ;|
    else                                                             ;|
        send +^{Home}                                                ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & o::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        send {End}                                                   ;|
    else                                                             ;|
        send +{End}                                                  ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        send ^{End}                                                  ;|
    else                                                             ;|
        send +^{End}                                                 ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                      CapsLock Page Navigator                       ;|
;-----------------------------------o---------------------------------o
;                      CapsLock + u |  PageUp                        ;|
;                      CapsLock + p |  PageDown                      ;|
;                      Ctrl, Alt Compatible                          ;|
;-----------------------------------o---------------------------------o
CapsLock & u::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        send {PgUp}                                                  ;|
    else                                                             ;|
        send +{PgUp}                                                 ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        send ^{PgUp}                                                 ;|
    else                                                             ;|
        send +^{PgUp}                                                ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & p::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        send {PgDn}                                                  ;|
    else                                                             ;|
        send +{PgDn}                                                 ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        send ^{PgDn}                                                 ;|
    else                                                             ;|
        send +^{PgDn}                                                ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                     CapsLock Mouse Controller                      ;|
;-----------------------------------o---------------------------------o
;                   CapsLock + Up   |  Mouse Up                      ;|
;                   CapsLock + Down |  Mouse Down                    ;|
;                   CapsLock + Left |  Mouse Left                    ;|
;                  CapsLock + Right |  Mouse Right                   ;|
;    CapsLock + Enter(Push Release) |  Mouse Left Push(Release)      ;|
;-----------------------------------o---------------------------------o
CapsLock & Up::                                                      ;|
CapsLock & NumpadUp::    MouseMove, 0, -10, 0, R                     ;|
CapsLock & Down::                                                    ;|
CapsLock & NumpadDown::  MouseMove, 0, 10, 0, R                      ;|
CapsLock & Left::                                                    ;|
CapsLock & NumpadLeft::  MouseMove, -10, 0, 0, R                     ;|
CapsLock & Right::                                                   ;|
CapsLock & NumpadRight:: MouseMove, 10, 0, 0, R                      ;|
;-----------------------------------o                                ;|
CapsLock & Enter::                                                   ;|
SendEvent {Blind}{LButton down}                                      ;|
KeyWait Enter                                                        ;|
SendEvent {Blind}{LButton up}                                        ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                           CapsLock Deletor                         ;|
;-----------------------------------o---------------------------------o
;                     CapsLock + n  |  Ctrl + Delete (Delete a Word) ;|
;                     CapsLock + m  |  Delete                        ;|
;                     CapsLock + ,  |  BackSpace                     ;|
;                     CapsLock + .  |  Ctrl + BackSpace              ;|
;-----------------------------------o---------------------------------o
CapsLock & ,::send {Del}                                             ;|
CapsLock & .::send ^+{right}{bs}                                     ;|
CapsLock & m::send {BS}                                              ;|
CapsLock & n::send ^+{left}{bs}                                      ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                            CapsLock Editor                         ;|
;-----------------------------------o---------------------------------o
;                     CapsLock + w  |  Ctrl + Right(Move as [vim: w]);|
;                     CapsLock + b  |  Ctrl + Left (Move as [vim: b]);|
;-----------------------------------o---------------------------------o
CapsLock & w::                                                       ;|
	if GetKeyState("alt")                                            ;|
		send ^+{Right}                                               ;|
	else                                                             ;|
		send ^{right}                                                ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & b::                                                       ;|
	if GetKeyState("alt")                                            ;|
		send ^+{left}                                                ;|
	else                                                             ;|
		send ^{Left}                                                 ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                       CapsLock Media Controller                    ;|
;-----------------------------------o---------------------------------o
;                    CapsLock + F1  |  Volume_Mute                   ;|
;                    CapsLock + F2  |  Volume_Down                   ;|
;                    CapsLock + F3  |  Volume_Up                     ;|
;                    CapsLock + F3  |  Media_Play_Pause              ;|
;                    CapsLock + F5  |  Media_Next                    ;|
;                    CapsLock + F6  |  Media_Stop                    ;|
;-----------------------------------o---------------------------------o
CapsLock & F1::send {Volume_Mute}                                    ;|
CapsLock & F2::send {Volume_Down}                                    ;|
CapsLock & F3::send {Volume_Up}                                      ;|
CapsLock & F4::send {Media_Play_Pause}                               ;|
CapsLock & F5::send {Media_Next}                                     ;|
CapsLock & F6::send {Media_Stop}                                     ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                      CapsLock Window Controller                    ;|
;-----------------------------------o---------------------------------o
;                     CapsLock + s  |  Ctrl + Tab (Swith Tag)        ;|
;                     CapsLock + q  |  Alt + F4   (Close Window)     ;|
;                     CapsLock + g  |  AppsKey    (Menu Key)         ;|
;-----------------------------------o---------------------------------o
CapsLock & s::                                                       ;|
    send {ins}                                                       ;|
    if (Vim.IsVimGroup())                                            ;|
        Vim.State.SetMode("Insert")                                  ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & q::send !{f4}                                             ;|
;-----------------------------------o                                ;|
CapsLock & g::                                                       ;|
    send {AppsKey}                                                   ;|
    if (Vim.IsVimGroup())                                            ;|
        Vim.State.SetMode("Insert")                                  ;|
return                                                               ;|
;---------------------------------------------------------------------o