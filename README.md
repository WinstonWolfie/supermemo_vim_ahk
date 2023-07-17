# supermemo_vim_ahk

Setting file to emulate vim with AutoHotkey, works with SuperMemo

# To Do

I apologise for still not *finished* writing a documentation (it's being written incrementally!), the keybinds are fairly similar to Vim, except `q` for extract and `z` for cloze, so you can do stuff like `zt.` to cloze until end of sentence, and `qip` to extract inner paragraph. Vim-Sneak plugin is added as well, so you can do `d2sth` to delete until the 2nd "th".

# Cheat sheet

(Capitalised letters need to be pressed with `Shift`, eg, `T = Shift + t`)

At any point the script goes wrong, you can press `Ctrl + Alt + r` to reload it.

## First steps

`h`: left

`j`: down

`k`: up

`l`: right

`w`: next word (= `Ctrl + Right`)

`b`: previous word (= `Ctrl + Left`)

`e`: end of current word

`ge`: end of previous word

`i`: go to insert mode ([CapsLock.ahk](https://github.com/Vonng/Capslock) is included and can be used to fast navigate in insert mode (eg, `CapsLK + w` = `Ctrl + Right`, `CapsLK + b` = `Ctrl + Left` and so on)

`Ctrl + [` / `CapsLock` / `Esc`: go back to normal mode (long pressing `Ctrl + [` sends the actual `Ctrl + [` keys)

## Search for stuff

`f{character}`: find next {character} (eg, `fe` goes to the next `e`)

`F{character}`: find previous {character}

`t{character}`: find next {character} but put caret before it

`T{character}`: find previous {character} but put caret before it

`s{2 characters}`: find next {2 characters} (inspired by [vim-sneak](https://github.com/justinmk/vim-sneak))(use `z` for motions (eg, `dzth` deletes until the next occurrance of `th`))

`S{2 characters}`: find previous {2 characters} (in visual it's `Alt+s` because S is taken by [vim-surround](https://github.com/tpope/vim-surround))

`;`: repeat last search of f, t or s  

`,`: repeat last search of f, t or s but reversed (so if you search forward, `,` lets you search backward)