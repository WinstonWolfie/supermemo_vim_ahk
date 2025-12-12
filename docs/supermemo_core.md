# SuperMemo Core Concepts (modes, windows, states)

This guide explains the “core model” this repo uses for SuperMemo: which window types it recognizes, how it decides whether you’re browsing vs editing, and how Vim modes interact with SuperMemo’s own UI state.

Hotkey notation: `<C-A-s>` means Ctrl+Alt+S (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

---

## Prerequisites

- AutoHotkey v1.1.1+ (or the built `vim_ahk.exe`).
- SuperMemo running (this repo targets SM15–SM19).
- Script enabled (tray menu shows enabled).

---

## Quick Start (mental model)

### 1) There are *two* kinds of “modes”

1. **Vim mode (this script)**: `Vim_Normal`, `Insert`, `Visual`, etc.
2. **SuperMemo editing state (SuperMemo UI)**: whether the element window is:
   - browsing (no caret)
   - editing HTML
   - editing plain text
   - grading (grading buttons focused)

Most SuperMemo-specific bindings are gated on *both*:

- “Which Vim mode am I in?”
- “What is SuperMemo currently focused on?”

### 2) The element window is special

Most “SMVim” behavior is for the element window:

- `ahk_class TElWind`

Many keys only work there (especially in **browsing** state).

### 3) “Browsing vs editing” is determined by focus

In `TElWind`, the repo uses control-focus checks to decide:

- **Editing HTML**: focus on `Internet Explorer_Server...`
- **Editing plain text**: focus on `TMemo...` / `TRichEdit...`
- **Browsing**: `TElWind` active and neither of the above

---

## Windows SuperMemo-specific code recognizes

These are the most important SuperMemo window classes used by the bindings:

| Window | AHK class | Notes |
|---|---|---|
| Element window | `TElWind` | Main focus of SMVim (browsing/editing/grading). |
| Contents | `TContents` | Some navigation bindings and “open browser”. |
| Subset browser | `TBrowser` | SuperMemo’s subset elements window. |
| Plan | `TPlanDlg` | Plan navigation / edit-focus helpers. |
| Tasklist | `TTaskManager` | Task navigation / edit-focus helpers. |
| Registry | `TRegistryForm` | Concept/reference/other registries; used heavily by “link concept” + tagging. |

The state helpers are in `lib/sm.ahk:69` (editing/browsing/grading) and `lib/sm.ahk:99` (navigating windows).

---

## SuperMemo editing states (what the repo checks)

### Browsing state

You are “browsing” when:

- The element window is active (`TElWind`)
- There is no focused HTML/plain-text editor control

This is where most navigation keys (scrolling, link opening, AutoPlay) are active.

### Editing HTML

You are “editing HTML” when:

- `TElWind` is active and focus is on an `Internet Explorer_Server...` control

This enables HTML-specific workflows (parse HTML tags, link-under-caret helpers, LaTeX helpers, etc.).

### Editing plain text

You are “editing plain text” when:

- `TElWind` is active and focus is on `TMemo...` or `TRichEdit...`

Some HTML-only features won’t apply here.

### Grading state

You are “grading” when:

- `TElWind` is active and focus is on one of SuperMemo’s grading buttons (the script checks `TBitBtn4`–`TBitBtn9`)

This enables the SM-specific grading bindings (see `lib/bind/smvim_grading.ahk:1`).

---

## Vim “normal mode” vs “Insert mode” in SuperMemo

### What “Insert mode” means here

This repo’s `Insert` mode is not “SuperMemo editing state” by itself. It is the script’s mode where:

- letters behave more like normal typing
- fewer “Vim navigation” hotkeys fire

The script often switches to `Insert` automatically when:

- a SuperMemo dialog opens that expects typing (find boxes, input dialogs, plan edit controls, etc.)

See `lib/bind/smvim_enter_insert.ahk:1`.

### How you usually move between states

Common patterns in the element window:

- **Browse → edit**: `q` (edit question) / `a` (edit answer) / `i` (enter Insert)
- **Edit → browse**: `Esc` (exit editing and return to Vim normal mode)

When in doubt, press `Esc` once or twice.

---

## Prefix states: leader and `g`

When browsing in `TElWind`, there are two “prefix” mechanics:

- **Leader**: press `'` (single quote) to enter a leader state for certain bindings.
- **`g` prefix**: press `g` to enter a temporary `g`-state (then `gs`, `g0`, `gc`, etc.).

These are tracked in `Vim.State` (`lib/vim_state.ahk:1`) and used heavily in `lib/bind/smvim_browsing.ahk:1`.

Tip:

- If you pressed a prefix by accident, `Esc` resets back to normal.

---

## Esc behavior (important in SuperMemo)

This repo supports a SuperMemo-specific behavior where `Esc` can:

- send a real `Esc` to SuperMemo (to exit dialogs / exit editing)
- also return the script to `Vim_Normal`

This is controlled by the `SMVimSendEscInsert` setting (see `README.md`) and implemented in `lib/vim_state.ahk:113`.

Practical guidance:

- If you are editing text and want to “fully exit”: press `Esc` until the caret is gone and you’re back in browsing.
- If a SuperMemo modal dialog is open: `Esc` may close it *and* reset Vim mode.

---

## Navigation windows (“non-element” windows)

The repo treats certain SM windows as “navigating” contexts (Plan, Tasklist, Contents tree, subset browser grid, plus a few dialogs).

Why it matters:

- Some motion keys and normal-mode assumptions are disabled/adjusted in navigating windows to avoid breaking SuperMemo’s own controls.
- Enter/typing behavior often forces `Insert` mode so you can type in the focused grid/edit box.

If you get stuck in a Plan/Tasklist/edit box state:

- Press `Esc` to reset to `Vim_Normal`.

---

## Troubleshooting

- **Hotkeys don’t fire in SuperMemo**
  - Confirm script enabled.
  - Check you’re in the intended state (browsing vs editing); press `Esc` to reset.

- **A key meant for browsing triggers text edits**
  - You’re likely still “editing” (caret active). Exit with `Esc` until browsing state.

- **A key meant for editing does nothing**
  - You might be browsing (no caret). Enter editing via `q`/`a`/`i`.
