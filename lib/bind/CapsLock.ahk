#Requires AutoHotkey v1.1.1+  
; https://github.com/Vonng/Capslock
#if (Vim.State.Vim.Enabled && (GetKeyState("LWin", "P") || GetKeyState("RWin", "P")))
CapsLock & j::WinMinimize, A
CapsLock & k::
  hWnd := WinActive("A")
  send #{Down}  ; refresh window
  KeyWait CapsLock
  KeyWait LWin
  KeyWait RWin
  KeyWait k
  WinMaximize, % "ahk_id " . hWnd
return

#if (Vim.State.Vim.Enabled)
CapsLock & `::
GetKeyState, CapsLockState, CapsLock, T
if CapsLockState = D
  SetCapsLockState, AlwaysOff
else
  SetCapsLockState, AlwaysOn
KeyWait, ``
return

CapsLock::Send {ESC}

CapsLock & h::
if GetKeyState("control") = 0
{
  if GetKeyState("alt") = 0
    Send {Left}
  else
    Send +{Left}
  return
}
else {
  if GetKeyState("alt") = 0
    Send ^{Left}
  else
    Send +^{Left}
  return
}
return

CapsLock & j::
if GetKeyState("control") = 0
{
  if GetKeyState("alt") = 0
    Send {Down}
  else
    Send +{Down}
  return
}
else {
  if GetKeyState("alt") = 0
    Send ^{Down}
  else
    Send +^{Down}
  return
}
return

CapsLock & k::
if GetKeyState("control") = 0
{
  if GetKeyState("alt") = 0
    Send {Up}
  else
    Send +{Up}
  return
}
else {
  if GetKeyState("alt") = 0
    Send ^{Up}
  else
    Send +^{Up}
  return
}
return

CapsLock & l::
if GetKeyState("control") = 0
{
  if GetKeyState("alt") = 0
    Send {Right}
  else
    Send +{Right}
  return
}
else {
  if GetKeyState("alt") = 0
    Send ^{Right}
  else
    Send +^{Right}
  return
}
return


CapsLock & i::
if GetKeyState("control") = 0
{
  if GetKeyState("alt") = 0
    Send {Home}
  else
    Send +{Home}
  return
}
else {
  if GetKeyState("alt") = 0
    Send ^{Home}
  else
    Send +^{Home}
  return
}
return

CapsLock & o::
if GetKeyState("control") = 0
{
  if GetKeyState("alt") = 0
    Send {End}
  else
    Send +{End}
  return
}
else {
  if GetKeyState("alt") = 0
    Send ^{End}
  else
    Send +^{End}
  return
}
return


CapsLock & u::
if GetKeyState("control") = 0
{
  if GetKeyState("alt") = 0
    Send {PgUp}
  else
    Send +{PgUp}
  return
}
else {
  if GetKeyState("alt") = 0
    Send ^{PgUp}
  else
    Send +^{PgUp}
  return
}
return

CapsLock & p::
if GetKeyState("control") = 0
{
  if GetKeyState("alt") = 0
    Send {PgDn}
  else
    Send +{PgDn}
  return
}
else {
  if GetKeyState("alt") = 0
    Send ^{PgDn}
  else
    Send +^{PgDn}
  return
}
return

CapsLock & Up::
CapsLock & NumpadUp::  MouseMove, 0, -10, 0, R
CapsLock & Down::
CapsLock & NumpadDown::  MouseMove, 0, 10, 0, R
CapsLock & Left::
CapsLock & NumpadLeft::  MouseMove, -10, 0, 0, R
CapsLock & Right::
CapsLock & NumpadRight:: MouseMove, 10, 0, 0, R

CapsLock & Enter::
SendEvent {Blind}{LButton down}
KeyWait Enter
SendEvent {Blind}{LButton up}
return

NotCtrlDelWnd() {
  return ((WinActive("ahk_group SM") && !SM.IsEditingHTML())
       || WinActive("ahk_exe AutoHotkey.exe")
       || WinActive("ahk_class CabinetWClass ahk_exe explorer.exe"))
}

CapsLock & ,::Send {Del}
CapsLock & .::Send % (NotCtrlDelWnd()) ? "^+{Right}{Del}" : "^{Del}"
CapsLock & m::Send {BS}
CapsLock & n::Send % (NotCtrlDelWnd()) ? "^+{Left}{BS}" : "^{BS}"

CapsLock & w::
	if GetKeyState("alt")
		Send ^+{Right}
	else
		Send ^{Right}
return

CapsLock & b::
	if GetKeyState("alt")
		Send ^+{Left}
	else
		Send ^{Left}
return

CapsLock & F1::Send {Volume_Mute}
CapsLock & F2::Send {Volume_Down}
CapsLock & F3::Send {Volume_Up}
CapsLock & F4::Send {Media_Play_Pause}
CapsLock & F5::Send {Media_Next}
CapsLock & F6::Send {Media_Stop}

CapsLock & s::
  Send {Ins}
  if (Vim.IsVimGroup())
    Vim.State.SetMode("Insert")
return

CapsLock & g::
  Send {AppsKey}
  if (Vim.IsVimGroup())
    Vim.State.SetMode("Insert")
return

CapsLock & tab::Send !{tab}!f4::

CapsLock & q::
  if (WinActive("ahk_class TElWind") && (SM.IsLearning() == 1)) {
    SM.GoHome()
    SM.WaitFileLoad()
  }
  if (A_ThisLabel == "!f4")
    Send !{f4}
  if (A_ThisLabel == "CapsLock & q")
    WinClose, A
  if (WinActive("ahk_exe HiborClient.exe")) {
    WinWaitActive, ahk_class MsgBoxWindow ahk_exe HiborClient.exe,, 0
    if (!ErrorLevel)
      Send {Enter}
  }
return
