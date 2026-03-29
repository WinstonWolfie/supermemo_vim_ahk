# SuperMemo Navigation + Links (SuperMemo + supermemo_vim_ahk)

This guide covers the SuperMemo-specific “navigation layer” this repo adds: browsing-mode navigation in the element window, opening/copying links, and the Vimium-style link hinting system.

Hotkey notation: `<C-A-s>` means Ctrl+Alt+S (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

---

## Prerequisites

- AutoHotkey v1.1.1+ (or the built `vim_ahk.exe`).
- SuperMemo running, with an element window available (`ahk_class TElWind`).
- Script enabled (tray menu shows enabled).

## Quick Start

### 1) Get into the right state: “browsing mode”

Most navigation hotkeys in SuperMemo apply when:

- The active window is the SuperMemo element window (`ahk_class TElWind`)
- You are **not editing text** (no caret in HTML/TMemo/TRichEdit)

To get there:

1. Focus the element window.
2. Press `Esc` to exit editing (if needed).

### 2) Scroll like a browser

In the element window while browsing:

- `j` / `k`: scroll down/up
- `d` / `u`: page down/up
- `h` / `l`: horizontal scroll

### 3) Open links

- `gs`: open the element’s `#Link` in your default browser
- `gm`: open links found in the element’s `#Comment`
- `f`: show link hints; type the hint letters to open a link at the cursor target

---

## Leader key and `g` prefix (how “multi-key” navigation works)

While browsing, this repo uses two “prefix states”:

- **Leader**: press `'` (single quote) to enter a leader state for some commands (`lib/bind/smvim_browsing.ahk:5`).
- **`g` prefix**: press `g` to enter a temporary `g`-state (similar to Vim’s `g…` commands).

Practical tip:

- If something unexpected happens, press `Esc` to reset back to normal mode.

---

## Core navigation in the element window (browsing mode)

### Edit / component actions

| Key | Action |
|---|---|
| `q` | Edit the first question component |
| `a` | Edit the first answer component |
| `gc` | Next component |
| `gC` | Previous component |

### Element-level navigation

| Key | Action |
|---|---|
| `g0` | Go to the root element |
| `g$` | Go to the last element (SuperMemo “last”) |
| `r` | Reload/refresh in a “do the right thing” way (handles learning/grading cases) |

### Open the SuperMemo subset browser

| Key | Action |
|---|---|
| `b` | Open (or focus) the SuperMemo subset browser (`TBrowser`) |

---

## Links from inside SuperMemo

### Open/copy the element’s reference link

These work in the element window while browsing:

| Key | Action |
|---|---|
| `gs` | Open `#Link` in default browser |
| `gS` | Open `#Link` via the repo’s “IE” runner (legacy/compat mode) |
| `yy` | Copy `#Link` to clipboard |

### Open links from the reference comment

| Key | Action |
|---|---|
| `gm` | Open links found in `#Comment` |
| `gM` | Same, but via the “IE” runner |

Notes:

- `gs/gm` rely on the reference fields being present (`#Link:` and/or URLs in `#Comment:`).
- The “IE” runner is a compatibility path used by this repo; it may not work on all Windows setups.

---

## Vimium-style link hints (open/yank/jump)

When you’re browsing an HTML component inside SuperMemo, you can use hint overlays to open links without using the mouse.

### Open a link by hint

1. In SuperMemo browsing mode, press `f`.
2. You’ll see hint labels drawn over link/text targets.
3. Type the hint characters shown on the target you want.

### Variants

| Key | Action |
|---|---|
| `f` | Open link (default) |
| `F` | Open link in new tab (where supported) |
| `yf` | Yank/copy link URL (enter yank mode with `y`, then `f`) |

Behind the scenes:

- Hint generation and the key listener live in `lib/bind/smvim_browsing.ahk:113` and `lib/bind/smvim_key_listener.ahk:1`.
- The hint system uses UI Automation to enumerate text/link nodes, so very large HTML may refuse to generate hints (it will show “Text too long.”).

---

## Plan / Tasklist / Contents windows (minimal notes)

This repo also recognizes several non-element SuperMemo windows and provides light navigation support:

- Plan: `ahk_class TPlanDlg`
- Tasklist: `ahk_class TTaskManager`
- Contents: `ahk_class TContents`
- Subset browser: `ahk_class TBrowser`

If a key doesn’t work in those windows, press `Esc` (normal mode reset) and try again. Many generic Vim motions are intentionally limited outside the element window to avoid conflicting with native SuperMemo editing controls.

---

## Troubleshooting

- **Navigation keys do nothing**
  - Confirm the script is enabled (tray menu).
  - Make sure you’re in the SuperMemo element window and in browsing mode (press `Esc`).

- **`f` shows “Text too long.” / no hints**
  - The hinting system limits the number of UIA nodes it will enumerate for performance.
  - Try reducing the amount of visible content (collapse sections, switch component, or use `gs/gm/yy` instead).

- **`gs` says “Link not found.”**
  - The element might not have a `#Link:` in its reference. Add one (see `docs/browser.md` or use `:r` from `docs/supermemo_commander_and_commands.md`).
