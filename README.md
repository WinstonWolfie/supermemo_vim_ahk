# supermemo_vim_ahk

Setting file to emulate vim with AutoHotkey, works with SuperMemo

# To Do

I apologise for still not *finished* writing a documentation (it's being written incrementally!), the keybinds are fairly similar to Vim, except `q` for extract and `z` for cloze, so you can do stuff like `zt.` to cloze until end of sentence, and `qip` to extract inner paragraph. Vim-Sneak plugin is added as well, so you can do `d2sth` to delete until the 2nd "th".

# Cheat sheet

Vim notations: 

- Capitalised letters need to be pressed with `Shift`, eg, `T = Shift + T`. CapsLock is disabled because [CapsLock.ahk](https://github.com/Vonng/Capslock) is included.
- `<C-{key}>` means `Ctrl + {key}`, eg, `<C-v>` = `Ctrl + V`.
- `<A-{key}>` means `Alt + {key}`, eg, `<A-s>` = `Ctrl + S`.

At any point the script goes wrong, you can press `<C-A-r>` (ie, `Ctrl + Alt + R`) to reload it.

## First steps

`h`: left

`j`: down

`k`: up

`l`: right

`w`: next word (= `Ctrl + Right`)

`b`: previous word (= `Ctrl + Left`)

`e`: end of current word

`ge`: end of previous word

`i`: go to insert mode (remember you can use [CapsLock.ahk](https://github.com/Vonng/Capslock) to fast navigate in insert mode (eg, `CapsLK + w` = `Ctrl + Right`, `CapsLK + b` = `Ctrl + Left` and so on)

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

`$`: go to the end of a line

`}`: jump entire paragraphs downwards

`{`: jump entire paragraphs upwards

`<C-d>`: go down 10 lines

`<C-u>`: go up 10 lines

`+`: go to the start of the nth next line

`-`: go to the start of the nth previous line