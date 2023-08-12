# supermemo_vim_ahk

Setting file to emulate vim with AutoHotkey, works with SuperMemo

# To Do

I apologise for still not *finished* writing a documentation (it's being written incrementally!), the keybinds are fairly similar to Vim, except `q` for extract and `z` for cloze, so you can do stuff like `zt.` to cloze until end of sentence, and `qip` to extract inner paragraph. Vim-Sneak plugin is added as well, so you can do `d2sth` to delete until the 2nd "th".

# Cheat sheet

Vim notations: 

- Capitalised letters need to be pressed with `Shift`, eg, `T = Shift + T`. CapsLock is disabled because [CapsLock.ahk](https://github.com/Vonng/Capslock) is included.
- `<C-{key}>` means `Ctrl + {key}`, eg, `<C-v>` = `Ctrl + V`.
- `<A-{key}>` means `Alt + {key}`, eg, `<A-s>` = `Ctrl + S`.
- Similarly, `<S-{key}>` means `Shift + {key}`, so `<C-S-A-a>` = `Ctrl + Shift + Alt + A`

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

`:`: go to command mode (does not need to press `Enter` after the letter, ie, the two keys `:F` are sufficient to initiate the cleaning HTML command)

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

### Additional searching in non-SuperMemo softwares (from the original [vim_ahk](https://github.com/rcmdnk/vim_ahk))

|Key/Commands|Function|
|:----------:|:-------|
|/| Start search (search box will be opened)|
|n/N| Search next/previous (Some applications support only next search)|
|*| Search the word under the cursor.|

## Move faster with counts

`{count}{motion}`: repeat {motion} {count} times

`2w`: jump to second word

`4f"`: jump to fourth occurrence of the `"` character

`3/cucumber`: jump to third match of "cucumber"

## Going outer spaces

### Editing

`gx`: going to the link under cursor (only works in HTML)

`gn`: open the text/HTML file in notepad

`gs` / `gf`: open the text/HTML file in VSCode

### Browsing (not focused to any text component)

`gs`: go to current reference link (`gS` to open it in IE)

`gn`: open the last focused text/HTML file in notepad

`gf`: open the last focused text/HTML file in VSCode

`gu`: click the "go to the source" button

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