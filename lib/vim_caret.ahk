class VimCaret {
  __New(vim) {
    global VimScriptPath
    this.Vim := vim
    this.caretwidths := {"Normal": 10
                 , "Visual": 10
                 , "Insert": 1
                 , "Default": 1}
  }

  SetCaret(Mode="") {
    if (this.Vim.Conf["VimChangeCaretWidth"]["val"] == 0)
      return
    width :=
    if (this.Vim.State.IsCurrentVimMode("Vim_Normal") || Mode = "Normal") {
      width := this.caretwidths["Normal"]
    } else if (this.Vim.State.StrIsInCurrentVimMode("Visual") || Mode = "Visual") {
      width := this.caretwidths["Visual"]
    } else if (this.Vim.State.StrIsInCurrentVimMode("Insert") || Mode = "Insert") {
      width := this.caretwidths["Insert"]
    } else {
      width := this.caretwidths["Default"]
    }
    this.SetCaretWidth(width, true)
  }

  ; Expects argument "width" in hex
  SetCaretWidth(width) {
    CARETWIDTH := width
    ; SPI = SystemParametersInfo
    SPI_SETCARETWIDTH := 0x2007
    SPIF_UPDATEINIFILE := 0x01
    SPIF_SENDCHANGE := 0x02
    fWinIni := SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
    DllCall("SystemParametersInfo", UInt,SPI_SETCARETWIDTH, UInt,0, UInt,CARETWIDTH, UInt,fWinIni)
    this.SwitchToSameWindow()
  }

  SwitchToSameWindow(WinTitle:="") {
    if (WinTitle) {
      WinActivate % WinTitle
    } else {
      ; Get ID of active window
      WinTitle := "ahk_id " . WinGet()
    }
    ; Activate desktop
    ; WinActivate, ahk_class WorkerW  ; doesn't work in Win 11
    WinActivate, ahk_class Progman
    WinActivate % WinTitle
  }
}

