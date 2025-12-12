# LaTeX (SuperMemo + supermemo_vim_ahk)

This guide covers converting LaTeX text into an image (and converting the image back to LaTeX) inside SuperMemo HTML components.

Hotkey notation: `<C-A-l>` means Ctrl+Alt+L (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

## Quick Start

### Convert LaTeX text -> image

1. In SuperMemo, click into an HTML component so the text cursor is active (HTML editing mode).
2. Select the LaTeX text you want to convert (e.g. `$x^2$`, `\(...\)`, `\[...\]`).
3. Press `<C-A-l>`.

The script downloads a PNG, saves it into your collection under `...\elements\LaTeX\`, and inserts an `<img ...>` tag into the HTML.

### Convert image -> LaTeX (and delete the image file)

1. In SuperMemo HTML editing mode, select the image created by the conversion.
2. Press `<C-A-l>`.

The script extracts the formula from the image `alt=` (or `title=`), copies the LaTeX to your clipboard, and deletes the PNG file from disk.

## Notes

- Works only in SuperMemo when an HTML component is focused (`SM.IsEditingHTML()`); it will not trigger in browsing mode.
- Requires internet access at runtime (it downloads from `https://latex.vimsky.com/...`).
- The LaTeX formula is stored in the image tag (as `alt="..."`) so it can be recovered later.
- The script normalizes common LaTeX wrappers copied from sites like Wikipedia/LibreTexts (e.g. strips `\(...\)`, `\[...\]`, `{\displaystyle ...}`).
- It also writes/updates a hidden “anti-merge” marker in the HTML. If you want it invisible, add this to your SuperMemo stylesheet:
  - `.anti-merge { position: absolute; left: -9999px; top: -9999px; }`

## Troubleshooting

### `<C-A-l>` does nothing

- Make sure the caret is in an HTML component (click into the HTML).
- If you’re in browsing mode, enter editing mode first (the binding is gated on `SM.IsEditingHTML()`).

### “Text not found.”

- You need a non-empty selection (either LaTeX text, or the `<img>`).

### No image appears / conversion hangs

- Network access may be blocked, or `latex.vimsky.com` may be unreachable.
- The downloaded file is saved under your collection’s `elements\\LaTeX\\`; check that folder for the PNG.

### Image -> LaTeX returns empty

- The script expects the image tag to contain `alt=` (or `title=`) with the formula. This is guaranteed for images created by `<C-A-l>`.

## Quick Reference

| Hotkey | Context | Action |
|--------|---------|--------|
| `<C-A-l>` | SuperMemo, HTML editing, selection is text | Convert LaTeX text to image |
| `<C-A-l>` | SuperMemo, HTML editing, selection is an `<img>` | Copy LaTeX to clipboard and delete the image file |

