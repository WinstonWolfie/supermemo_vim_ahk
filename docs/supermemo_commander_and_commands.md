# Vim Commander + `:` Commands (SuperMemo + supermemo_vim_ahk)

This guide covers the two “command surfaces” this repo provides when working in SuperMemo:

- **Vim Commander**: a GUI command palette (`<C-;>`) whose command list changes based on the active window/context.
- **`:` command mode**: Vim-like “ex” commands inside SuperMemo element windows (and a few other SM windows).

Hotkey notation: `<C-A-s>` means Ctrl+Alt+S (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

---

## Prerequisites

- AutoHotkey v1.1.1+ (or the built `vim_ahk.exe`).
- SuperMemo running (this repo targets SM15–SM19).
- Script enabled (tray menu shows enabled).

## Quick Start

### 1) Open Vim Commander

1. Focus any window (SuperMemo, browser, etc.)
2. Press `<C-;>`
3. Type to filter, press Enter to execute

The command list is **context-dependent**. When you are focused on SuperMemo windows, you’ll see extra SuperMemo-only commands.

### 2) Use `:` command mode inside SuperMemo

1. Focus a SuperMemo element window (`ahk_class TElWind`)
2. Ensure you are in Vim normal mode (press `Esc`)
3. Press `:` to enter command mode
4. Press one of the command keys (examples: `r`, `F`, `l`)

---

## Vim Commander (GUI command palette)

**Trigger**: `<C-;>` (implemented in `lib/bind/vim_command.ahk:40`)

### How the command list is built

Vim Commander always shows a base set of commands (web helpers, utilities), then prepends extra items depending on the active window:

- Element window: `ahk_class TElWind`
- Contents window: `ahk_class TContents`
- Browser window (SuperMemo subset browser): `ahk_class TBrowser`
- Plan window: `ahk_class TPlanDlg`
- Registry window: `ahk_class TRegistryForm`
- Web browser windows: `ahk_group Browser`

### SuperMemo element window commands (most important)

When focused on the element window (`TElWind`), you’ll typically see commands like:

| Command | What it does |
|---|---|
| `ImportFile` | Creates/updates an element for a local file using the `binary` template (source element for PDFs/EPUB/videos). |
| `OpenInAcrobat` | Opens the attached file/path in Acrobat (useful for PDF workflows). |
| `NukeHTML` | Aggressively rewrite/clean the underlying HTML source file (the “nuke” variant removes many `class=...` attributes; see `docs/supermemo_html_maintenance.md`). |
| `ReformatVocab` | Runs a vocabulary reformat routine (collection-specific). |
| `EditReference` | Opens the element reference editor. |
| `LinkToPreviousElement` | Creates a link to the previous element (workflow helper). |
| `Comment` / `Tag` / `Untag` | Reference/comment/tag helpers. |
| `ExternaliseRegistry` | Externalizes several registries in bulk (images/sounds/binary/video). |
| `CalculateTodaysPassRate` / `AllLapsesToday` | Exports repetition history and computes daily stats. |

Notes:

- Many of these commands depend on SuperMemo UI state (editing vs browsing) and will switch components or open dialogs.
- Some commands are intentionally “power-user” and will show confirmation dialogs (or rely on SuperMemo’s own confirmations).

### "Online element" commands (YouTube / script component workflows)

When your **current collection** is detected as online, Vim Commander also includes:

| Command | What it does |
|---|---|
| `ReformatScriptComponent` | Rewrites script component content in a consistent style (collection-specific). |
| `SearchLinkInYT` | Searches for the element's `#Link` on YouTube. |
| `MarkAsOnlineProgress` | Inserts `SMVim: Use online video progress` marker at top of HTML (see `docs/video.md`). |

Notes (user perspective):

- These commands are meant for elements where your source is effectively a URL-backed/script-backed item (common for YouTube and "online element" imports).
- If you imported a page as an online element but you don't see these commands, it's likely because the current Commander "online" detection is **collection-based** in the current code, not purely "does this element have a Script component?". In that case, the underlying workflows can still work; you just won't see these helper commands in the palette.

Dev note: the Commander list is built in `lib/bind/vim_command.ahk`, and the current online check used there is `SM.IsOnline(, -1)` (see `lib/sm.ahk:455` for what that returns).

### SuperMemo Browser / Plan / Registry commands (high-level)

Depending on the focused window, you’ll see additional commands like:

- `TBrowser`: `MassProcessBrowser`, `MassReplaceReference`, tagging helpers
- `TPlanDlg`: `SetPlanPosition`
- `TRegistryForm`: `MassReplaceRegistry`, `MassProcessRegistry`

---

## `:` command mode (SuperMemo element windows)

**Trigger**: `:` while in Vim normal mode (implemented in `lib/bind/vim_command.ahk:2` + SM-specific bindings in `lib/bind/smvim_command.ahk:1`).

These are “single-letter” commands; you press `:` then the command key.

### Reference & linking

| Command | Action |
|---|---|
| `:r` | Set reference metadata/link from clipboard and captured browser info (writes `#Link`, `#Title`, etc). |
| `:l` | List links (SuperMemo UI command). |
| `:L` | Link concept (SuperMemo UI command). |

### HTML maintenance & formatting

| Command | Action |
|---|---|
| `:f` | Clean format using `F6` (retains tables; relies on SM UI). |
| `:F` | Clean HTML directly in the underlying source file (rewrites HTML on disk). |
| `:o` | Compress images (runs SuperMemo commander action). |

For the “rewrite HTML on disk” workflow and safety notes, see `docs/supermemo_html_maintenance.md`.

### Editing helpers (within the element)

| Command | Action |
|---|---|
| `:b` | Remove all text **before** cursor (SuperMemo). |
| `:a` | Remove all text **after** cursor (SuperMemo). |

### Learning helpers

| Command | Action |
|---|---|
| `:i` | Learn outstanding **items only**. |
| `:I` | Learn the current element’s outstanding child item. |
| `:n` | Neural review children. |
| `:c` | Learn children. |
| `:C` | Add new concept. |

---

## Common recipes

### Recipe: Populate `#Link`/`#Title` quickly (without importing the page)

1. In your browser, copy a URL to clipboard (or use a browser-capture hotkey if you use one).
2. In SuperMemo element window, press `Esc` (ensure browsing/normal mode).
3. Press `:` then `r` (`:r`).

Result: the element reference gets `#Link:` (and often `#Title:` and other metadata if available).

### Recipe: One-stop “do a thing” menu (when you forget a command)

1. Press `<C-;>` to open Vim Commander.
2. Start typing: `import`, `nuke`, `acrobat`, `tag`, etc.
3. Press Enter.

---

## Troubleshooting

- **Vim Commander opens but doesn’t show SuperMemo commands**
  - Ensure the active window is a SuperMemo window (`TElWind`, `TContents`, `TBrowser`, etc.).
  - Many commands are gated behind “SuperMemo is open + element window exists”.

- **A command seems to do nothing**
  - Make sure the script is enabled (tray menu).
  - Some commands require SuperMemo to be in browsing mode; press `Esc` to exit editing.

- **`:r` sets a wrong link/title**
  - `:r` may use both clipboard and “captured browser info” stored in `Browser.*`.
  - If you recently captured browser info and then copied something else, clear/re-copy the URL you want and run `:r` again.
