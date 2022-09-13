class VimAbout Extends VimGui {
  __New(vim) {
    this.Vim := vim

    this.Version := ""
    this.Date := ""
    this.Author := ""
    this.Description := ""
    this.Homepage := ""

    base.__New(vim, "Vim Ahk")
  }

  MakeGui() {
    global VimHomepage, VimAboutOK, VimScriptPath
    gui, % this.Hwnd ":-MinimizeBox"
    gui, % this.Hwnd ":-Resize"
    gui, % this.Hwnd ":Add", Text, , % "Vim Ahk (vim_ahk):`n" this.Description
    gui, % this.Hwnd ":Font", Underline
    gui, % this.Hwnd ":Add", Text, Y+0 cBlue vVimHomepage, Homepage
    VimGuiAboutOpenHomepage := ObjBindMethod(this, "OpenHomepage")
    GuiControl, +G, VimHomepage, % VimGuiAboutOpenHomepage
    gui, % this.Hwnd ":Font", Norm
    gui, % this.Hwnd ":Add", Text, , % "Author: " this.Author
    gui, % this.Hwnd ":Add", Text, , % "Version: " this.Version
    gui, % this.Hwnd ":Add", Text, Y+0, % "Last update: " this.Date
    gui, % this.Hwnd ":Add", Text, , Script path:`n%VimScriptPath%
    gui, % this.Hwnd ":Add", Text, , % "Setting file:`n" this.Vim.Ini.Ini
    gui, % this.Hwnd ":Add", Button, +HwndOK X200 W100 Default vVimAboutOK, &OK
    this.HwndAll.Push(OK)
    ok := ObjBindMethod(this, "OK")
    GuiControl, +G, VimAboutOK, % ok
  }

  OpenHomepage() {
    this.Vim.VimToolTip.RemoveToolTip()
    Run % this.Homepage
  }
}
