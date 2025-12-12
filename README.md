# supermemo_vim_ahk

Setting file to emulate vim with AutoHotkey, works with SuperMemo

# To Do

I apologise for still not finished writing a documentation (it's being written incrementally!), the keybinds are fairly similar to Vim, except `q` for extract and `z` for cloze, so you can do stuff like `zt.` to cloze until a full stop, and `qip` to extract inner paragraph. [vim-sneak](https://github.com/justinmk/vim-sneak) is added as well, so you can do `d2zth` to delete until the 2nd "th".

Financial incentives:) https://ko-fi.com/winstonwolfie or https://www.buymeacoffee.com/winstonwolfie

# Cheat sheet

Vim notations: 

- Capitalised letters need to be pressed with `Shift`, eg, `T = Shift + T`. CapsLock is disabled because [CapsLock.ahk](https://github.com/Vonng/Capslock) is included.

- `<C-{key}>` means `Ctrl + {key}`, eg, `<C-v>` = `Ctrl + V`.

- `<A-{key}>` means `Alt + {key}`, eg, `<A-s>` = `Alt + S`.

- Similarly, `<S-{key}>` means `Shift + {key}`, so `<C-S-A-a>` = `Ctrl + Shift + Alt + A`.

- `<CR>` means the `Enter` key.

- `<leader>` means the `'` key.

At any point the script goes wrong, you can press `<C-A-r>` (ie, `Ctrl + Alt + R`) to reload it.

Also see: [VSCode Vim cheat sheet](https://www.barbarianmeetscoding.com/boost-your-coding-fu-with-vscode-and-vim/cheatsheet/)

## First steps

### Motions

`h`: left

`j`: down

`k`: up

`l`: right

`w`: next word (= `Ctrl + Right`)

`b`: previous word (= `Ctrl + Left`)

`e`: end of current word

`ge`: end of previous word

### Going to other modes

`i`: go to insert mode (remember you can use [CapsLock.ahk](https://github.com/Vonng/Capslock) to fast navigate in insert mode (eg, `CapsLK + w` = `Ctrl + Right`, `CapsLK + b` = `Ctrl + Left` and so on)

`a`: go to insert mode after the cursor (append)

`v`: go to visual mode

`:`: go to command mode (does not need to press `Enter` after the letter, ie, the two keys `:F` are sufficient to initiate the cleaning HTML command). In SuperMemo there are additional `:` commands; see "SuperMemo only" below.

`<C-[>` / `CapsLock` / `Esc`: go back to normal mode (long pressing `<C-[>` sends the actual `<C-[>` keys)

## Find character(s)

`f{character}`: find next `{character}` (eg, `fe` goes to the next `e`)

`F{character}`: find previous `{character}`

`t{character}`: find next `{character}` but put caret before it

`T{character}`: find previous `{character}` but put caret before it

`s{2 characters}`: find next `{2 characters}` (use `z` for motions (eg, `dzth` deletes until the next occurrance of `th`))(inspired by [vim-sneak](https://github.com/justinmk/vim-sneak))

`S{2 characters}`: find previous `{2 characters}` (in visual it's `<A-s>` because `S` is taken by [vim-surround](https://github.com/tpope/vim-surround))

`;`: repeat last search of `f`, `t` or `s`  

`,`: repeat last search of `f`, `t` or `s` but reversed (so if you searched forward before, `,` lets you search backward)

## Move horizontally and vertically

`0` / `^`: go to the start of a line

`$` / `g_`: go to the end of a line

`}`: jump entire paragraphs downwards

`{`: jump entire paragraphs upwards

`<C-d>`: go down 10 lines

`<C-u>`: go up 10 lines

`+`: go to the start of the nth next line

`-`: go to the start of the nth previous line

## Searching

### In HTML only

`<C-A-f>`: search using IE's search window

### In both HTML and plain-text components (could fail in long articles!)

`/`: normal search (uses `F3` in HTML)

`?`: visual search (selects the first result and goes to visual mode)

`<A-/>`: cloze search (makes a cloze out of the first result)

`<A-S-/>`: cloze search but with a cloze hinter

`<C-A-/>`: cloze search and stay in the clozed item

`<C-S-A-/>`: cloze search hinter and stay in the clozed item

`gn`: repeat last search and go to visual mode

### Additional searching in non-SuperMemo softwares (from the original [vim_ahk](https://github.com/rcmdnk/vim_ahk))

|Key/Commands|Function|
|:----------:|:-------|
|/| Start search (search box will be opened)|
|n/N| Search next/previous (Some applications support only next search)|
|*| Search the word under the cursor.|

## Move faster with counts

`{count}{motion}`: repeat `{motion}` `{count}` times

`2w`: jump to second word

`4f"`: jump to fourth occurrence of the `"` character

`3/cucumber`: jump to third match of "cucumber"

## Going outer spaces

### Editing

`gx`: going to the link under cursor (only works in HTML)

`gs` / `gf`: open the current component's source file in Vim (requires `vim` in `PATH`; if focused on an image component, opens in Photoshop and requires `ps` in `PATH`)

`gt`: open the current component's source file in Notepad

### Browsing (not focused to any text component)

`gs`: go to current reference link (`gS` to open in Internet Explorer, if installed)

`gm`: go to the link found in comment (`gM` to open in Internet Explorer, if installed)

`gU`: click the "source" button (SuperMemo only)

## More motions

`gg`: go to the top

`{line}gg`: go to {line}

`{line}G`: go to {line} on screen

`G`: go to the end

## Vim operations

`{operator}{count}{motion}`: apply operator on bit of text covered by motion

`d`: delete

`c`: change

`y`: yank (copy)

`p`: p (paste text after the cursor)

`g~`: switch case

## Linewise operators

`dd`: delete a line

`cc`: change a line

`yy`: yank (copy) a line

`g~~`: switch case of a line

`>>`: shift paragraph right

`<<`: shift paragraph left

## Capital case (stronger version) operators

`D`: delete from cursor to the end of the line

`C`: change from cursor to the end of the line (like `D` but going to insert)

`Y`: yank (copy) a line. Like `yy`

`P`: put (paste) at the cursor

## Text objects

`{operator}a{text-object}`: apply operator to all text-object including trailing whitespace

`{operator}i{text-object}`: apply operator inside text-object

`diw`: delete inner word

`daw`: delete a word

`dis`: delete inner sentence

`das`: delete a sentence

`dip`: delete inner paragraph

`dap`: delete a paragraph

`di(dib`: delete inside parentheses

`da(dab`: delete text inside parentheses (including parentheses)

`di{diB`: delete inside braces

`da{daB`: delete text inside braces (including braces)

`di[`: delete inside brackets

`da[`: delete text inside brackets (including brackets)

`di"`: delete inside quotes

`da"`: delete a quoted text (including quotes)

`dit`: delete inside tag

`dat`: delete a tag (including tag)

`ciw`: same goes for other operators...

## Repeat last change

`.`: repeat the last change

## Character editing commands

`x`: delete a character after the cursor

`X`: delete character before the cursor

`~`: switch case of the character after the cursor

## Undo and redo

`u`: undo last change

`C-R`: redo last undo

`{count}u`: undo last {count} changes

## More ways to insert

`I`: go into insert mode at the beginning of a line

`A`: go into insert mode at the end of a line

`o`: insert new line below current line and go into insert mode

`O`: insert new line above current line and go into insert mode

## More ways to go to visual mode

`V`: go into line-wise visual mode

`C-V`: go into paragraph-wise visual mode

`{trigger visual mode}{motion}{operator}`: visual mode operates in kind of the opposite way to normal mode. First you specify the motion to select text, and then you apply the operator

## Operate on next search match

`{operator}gn`: apply operator on next match

`.`: after using {op}gn, the dot commant repeats the last change on the next match

## Copying and pasting

`y{motion}`: yank (copy) text covered by motion

`p`: put (paste) after cursor

`P`: paste at the cursor

`yy` / `Y`: copy line

`yyp` duplicate line

`ddp`: swap lines

`xp`: swap characters

## [vim-surround](https://github.com/tpope/vim-surround)

`ds`: delete surroundings, eg, `ds[` (delete the surrounding square brackets)

`cs`: change surroundings, eg, `cs*(` (change surrounding asterisks to parentheses)

`ys`: add surroundings, eg, `ysiw"` (add quotes to the current word)

`ds"`: delete surrounding quotes

`cs_ti<CR>`: change surrounding `_` for the `<i>` tag (= `cs_<i<CR>`)

`ysiw"`: surround word under the cursor with quotes

`S` (in visual mode): add surroundings, eg, `S}` (add curly brackets to the current selection)

## [vim-sneak](https://github.com/justinmk/vim-sneak)

`s{char}{char}`: jump to the next ocurrence of `{char}{char}`

`S{char}{char}`: jump to the previous ocurrence of `{char}{char}` (note: in visual mode it's `<A-s>` because `S` is taken by vim-surround)

`;`: go to next occurrence of `{char}{char}`

`,`: go to previous occurrence of `{char}{char}`

`{op}z{char}{char}`: apply operator on text traversed by vim sneak motion (`Z` if previous ocurrence)

## SuperMemo only

Note: in SuperMemo, `Esc` can be configured to also enter normal mode (see the `SMVimSendEscInsert` setting in the Settings UI).

Default supported SuperMemo executables: SM15-SM19.

### Browsing (not focused on any text component)

Hugely inspired by [Vimium](https://github.com/philc/vimium) keys.

Note: while browsing, most keys are passed through to SuperMemo so native SM shortcuts still work (see `lib/bind/smvim_browsing_pass.ahk`).

`gg`: go to top

`G`: go to bottom

`{count}gg`: go to the `{count}`th line (eg, `3gg` goes to the third line)

`gU`: click the source button

`gS`: open link in Internet Explorer (if installed)

`gs`: open link in default browser

`gM`: open link(s) from reference comment in Internet Explorer (if installed)

`gm`: open link(s) from reference comment in default browser

Note: IE-specific actions use `iexplore.exe`; if IE is removed/disabled on your system, use the default-browser variants instead.

`g0`: go to root element

`g$`: go to last element

`gc`: go to next component

`gC`: go to previous component

`h`: scroll left

`j` / `<C-e>`: scroll down

`k` / `<C-y>`: scroll up

`l`: scroll right

`d`: scroll down 2 times

`u`: scroll up 2 times

`0`: scroll to top left

`$`: scoll to top right

`r`: reload (go to top element and back)

`p`: AutoPlay (= `Ctrl + F10`), with SMVim marker support (see below)

`P`: open/play the current component's file (uses SuperMemo "view file"; may open in `mpv` or the script editor). If a `SMVim time stamp: ...` marker exists and `mpv` is opened, it attempts to start playback.

`n`: add topic (= `Alt + N`)

`N`: add item (= `Alt + A`)

`x`: delete element/component (= `Delete` key)

`<C-i>`: download images (= `Ctrl + F8`)

`f`: open links

`F`: open links in background

`<A-f>`: open multiple links

`<A-S-f>`: open links in IE

`<C-A-S-f>`: open multiple links in IE

While link hints are visible, type the hint to activate it. `Esc` / `Backspace` cancels.

Hint keys are generated from: `S A D J K L E W C M P G H`.

`yf`: copy links

`yv`: select texts

`yc`: go to texts

`X`: Done!

`J` / `ge`: go down elements

`K` / `gE`: go up elements

`gu` / `<A-u>`: go to parents

`H` / `<A-h>`: go back in history

`L` / `<A-l>`: go forward in history

`b`: open browser

`o`: open favourites

`t`: click first text component

`q`: click first question component

`a`: click first answer component

`yy`: copy reference link

`ye`: duplicate curernt element

`{count}g{`: go to the `{count}`th paragraph

`{count}g}`: go to the `{count}`th paraggraph on screen

`m`: set read point

`` ` ``: go to read point

`<A-m>`: clear read point

`<A-S-j>`: go to next sibling (= `Alt + Shift + PgDn`)

`<A-S-k>`: go to previous sibling (= `Alt + Shift + PgUp`)

`\`: SuperMemo search (= `Ctrl + F3`)

The entered query is saved as the “last search” for related search commands.

#### In plan window

`s`: switch plans

`b`: begin (= `Alt + B`)

#### In tasklist window

`s`: switch tasklists

### Command mode (`:`) in SuperMemo

These are additional SuperMemo-only `:` commands (in the element window/contents/browser, depending on command):

|Key/Commands|Function|
|:----------:|:-------|
|`:b`|Remove all text **b**efore cursor (SuperMemo)|
|`:a`|Remove all text **a**fter cursor (SuperMemo)|
|`:f`|Clean **f**ormat (uses `F6`)|
|`:F`|Clean HTML directly in source (may rewrite the underlying HTML file)|
|`:l`|List links|
|`:L`|Link concept|
|`:o`|C**o**mpress images (SuperMemo commander)|
|`:r`|Set **r**eference metadata/link from clipboard/browser info|
|`:i`|Learn outstanding **i**tems only|
|`:I`|Learn current element's outstanding child **i**tem|
|`:n`|Neural review children|
|`:c`|Learn children|
|`:C`|Add new concept|

### Normal mode, editing

`H`: click the top of the text

`M`: click the middle of the text

`L`: click the bottom of the text

`{count}<leader>q`: Add `>` to `{count}` lines (useful for email replies)

`gx`: open hyperlink in current caret position

`<leader>u`: copy hyperlink in current caret position (HTML only)

`gf`: open current component's source file in Vim (if focused on an image component, opens in Photoshop; requires `ps` in [PATH](https://en.wikipedia.org/wiki/PATH_(variable)))

`gt`: open current component's source file in Notepad

`>>`: increase indent

`<<`: decrease indent

`gU`: click the source button

`<leader><A-{number}>` / `{Numpad}`: [Naess's priority script](https://raw.githubusercontent.com/rajlego/supermemo-ahk/main/naess%20priorities%2010-25-2020.png)

`<C-.>`: set interval to `1`

`<C-{number}>` / `<C-Numpad{number}>`: set a random interval range (Naess-style bins)

### Visual mode

`.`: selected text becomes \[...\] (in HTML this inserts `<span class="Cloze">[...]</span>` and parses HTML)

`<C-h>`: parse HTML (= `Ctrl + Shift + 1`)

`<A-a>`: add HTML tag

`m`: highlight (**m**ark)

`q`: extract (**q**uote)

`Q`: extract with priority

`<C-q>`: extract and return to the source element

`z`: cloze

`<C-z>`: cloze and return to the source element

`Z`: cloze hinter

`<CapsLock-z>`: cloze and delete \[...\]

Note: in plain-text components, visual `m` wraps the selection in `*...*` (instead of using HTML highlighting).

`H`: select until the top of the text on screen

`M`: select until the middle of the text on screen

`L`: select until the bottom of the text on screen

### Shortcuts (any mode would do)

`<C-A-.>`: find \[...\] and insert

`<C-A-c>`: change default concept group

`<C-f2>`: go neural

`<C-;>`: open "Vim Commander" (a GUI command palette; available outside SuperMemo too, but has extra SuperMemo-only commands when focused on SuperMemo windows)

Some SuperMemo-only Commander commands include:

- In `TElWind` / `TContents`: `SetConceptHook`, `MemoriseChildren`
- In `TElWind` (element window): `NukeHTML`, `ReformatVocab`, `ImportFile`, `EditReference`, `LinkToPreviousElement`, `OpenInAcrobat`, `CalculateTodaysPassRate`, `AllLapsesToday`, `ExternaliseRegistry`, `Comment`, `Tag`, `Untag`
- In `TElWind` when the element is online: `ReformatScriptComponent`, `SearchLinkInYT`, `MarkAsOnlineProgress`
- In `TElWind` when editing: `ClozeAndDone!` (when editing any text), plus HTML-only helpers like `MakeHTMLUnique`, `CenterTexts`, `AlignTextsRight`, `AlignTextsLeft`, `ItalicText`, `UnderscoreText`, `BoldText`
- In `TBrowser` (SuperMemo browser): `MemoriseCurrentBrowser`, `SetBrowserPosition`, `MassReplaceReference`, `MassProcessBrowser`, `Tag`, `Untag`
- In `TPlanDlg` (plan): `SetPlanPosition`
- In `TRegistryForm` (registry): `MassReplaceRegistry`, `MassProcessRegistry`

The Commander list is built dynamically based on the active window/context (`lib/bind/vim_command.ahk`).

Additional SuperMemo-only shortcuts not listed above:

- `<A-z>`: cloze (quick cloze helper)
- `<C-A-m>`: click "Start" (UIA; intended for embedded/online video components)
- `<C-A-Space>`: toggle video UI/group (UIA; intended for embedded/online video components)
- `<C-A-/>`: cloze search and stay in the clozed item
- `<C-S-A-/>`: cloze search hinter and stay in the clozed item
- `<C-A-S-l>`: insert numbered list (HTML toolbar)
- `<C-S-f12>`: confirm "bomb format" prompt (sends `Enter`)

#### Import / extraction (outside SuperMemo)

These work from a browser/PDF reader/Word/etc while SuperMemo is open:

Currently includes explicit support for common browsers (Chrome/Firefox/etc), SumatraPDF, Acrobat, Calibre ebook viewer, MS Word, and WinDjView.

`<A-S-d>`: check duplicates in SuperMemo (uses selected text if any, otherwise uses the current URL)

`<A-x>` / `<A-S-x>` / `<C-A-x>` / `<C-S-A-x>`: extract selection into SuperMemo (variants change flow, e.g. priority prompt / whether you return to the previous app)

`<C-A-a>` / `<C-S-A-a>`: import current webpage/video into SuperMemo (shows an import GUI for priority/concept/tags/comment/etc)

`<C-S-A-b>`: incremental web browsing (IWB) import from selected text (opens the same import GUI as above, but seeded from clipboard/selection)

If you trigger an extract with no selection, it can prompt for a chapter/section title and create an element accordingly.

#### PDFs (read point / page mark)

The same hotkeys used for “Incremental video” also handle PDFs when your active window is a supported PDF reader (SumatraPDF/Acrobat/WinDjView).

This script can write SMVim markers into the *first* line of an element’s HTML (must be first to be detected by AutoPlay):

- `SMVim read point: ...`
- `SMVim page mark: ...`
- `SMVim time stamp: ...`
- `SMVim: Use online video progress`

See `docs/readers.md` for the full PDF workflow details.

Docs overview (recommended starting point): `docs/index.md`.

#### Incremental video

`<C-A-s>`: sync time stamp (closes browser tab / player window)

`<A-S-s>`: sync time stamp (keeps browser tab open)

`<C-S-A-s>`: sync time stamp and keep learning

`<C-A-Backtick>` / `<A-S-Backtick>` / `<C-S-A-Backtick>`: clear time stamp (same close/keep/keep-learning variants)

These also work with `mpv` (and can copy the current `mpv` time if you have an `mpv-copyTime` script installed; otherwise it prompts for a time stamp).

#### LaTeX

`<C-A-l>`: convert selected LaTeX to an image (or image back to LaTeX)
See `docs/latex.md` for details.

#### Templates

`<C-A-p>`: convert element to a plain-text template

`<C-A-i>`: convert element to the "item" template

#### Linking helpers

`<C-A-g>`: copy current element number as `#12345` (for linking)

`<C-A-k>`: hyperlink selected text to either a URL in clipboard or to the element number copied by `<C-A-g>`

#### Plan window power features

`<A-a>`: insert/append an "activity" entry via a small GUI

In plan window, `d` then `j/k` moves the drag slot; `p`/`P` puts after/before.

In plan window, `<A-r>` refreshes the current view (useful when the plan UI gets stale).

In plan window, `<A-t>` shows totals and `<A-d>` shows delays.

In plan window, `<C-b>` begins and saves; `<C-A-b>` begins+saves and can also cancel the alarm flow.

#### Scripts / titles

`<A-S-c>`: clone the current script component (if possible)

`<C-A-t>`: edit element title

In SuperMemo element window, `<A-s>` copies marker content if a marker exists (e.g. `SMVim read point/page mark/time stamp: ...`); otherwise it falls back to SuperMemo’s normal `<A-s>` behavior.

Some workflows create/read special markers at the top of an element (e.g. `SMVim time stamp: ...`, `SMVim: Use online video progress`); these can affect play/autoplay behavior.

#### Grading

When grading buttons are focused, `s/d/f/g` grades `2/3/4/5` and advances to the next repetition.

(`RC`: right Ctrl; `RS`: right Shift; `RA`: right Alt)

`<RC-RS-BS> / <RA-RS-BS>`: delete element and keep learning

`<RC-RS-\> / <RA-RS-\>`: Done! and keep learning

`<C-A-S-g>`: change current element's concept group
