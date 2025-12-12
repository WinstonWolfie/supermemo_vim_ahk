# HTML Maintenance in SuperMemo (SuperMemo + supermemo_vim_ahk)

This guide covers the SuperMemo-specific HTML maintenance tools in this repo: when to use “clean format” vs “rewrite HTML on disk”, how to keep HTML stable for automation, and how to avoid SuperMemo’s “HTML merging” behavior.

Hotkey notation: `<C-A-s>` means Ctrl+Alt+S (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

---

## Prerequisites

- AutoHotkey v1.1.1+ (or the built `vim_ahk.exe`).
- SuperMemo running, with an element window available (`ahk_class TElWind`).
- You’re working with an **HTML component** (some tools don’t apply to plain-text components).

## Quick Start

### 1) Clean visual formatting (safe, UI-level)

In a SuperMemo element window:

1. Press `Esc` to ensure you’re not editing text (browsing mode).
2. Press `:` then `f` (`:f`).

This runs SuperMemo’s **F6 clean format** flow (retains tables) and is the first thing to try when pasted HTML looks messy.

### 2) Aggressively clean the underlying HTML source file (power tool)

Only for HTML components (not plain text):

1. Press `Esc` to exit editing.
2. Press `:` then `F` (`:F`) or run `NukeHTML` from Vim Commander (`<C-;>` → `NukeHTML`).

This rewrites the HTML source file on disk using `SM.CleanHTML(...)` and then refreshes the component.

---

## At a glance

| Goal | Recommended tool |
|---|---|
| Normalize messy formatting (safe) | `:f` |
| Rewrite broken/overgrown HTML (aggressive) | `:F` / `NukeHTML` |
| Prevent “HTML merge” oddities | `MakeHTMLUnique` |
| Reduce image storage | `:o` |

## Why HTML maintenance matters in this repo

Several SuperMemo workflows here depend on predictable HTML structure:

- SMVim markers are detected at the top of the first HTML component (`docs/markers.md`).
- Import/extract workflows may inject classed spans like `extract`, `cloze`, `highlight`.
- Link hinting uses UIA to enumerate “Text” nodes and hyperlink values.

If HTML becomes extremely messy (or if a component is unexpectedly plain text), these automations can fail or behave inconsistently.

---

## Tools and what they do

### `:f` — Clean format (SuperMemo UI)

**Trigger**: `:` then `f` in the element window (`lib/bind/smvim_command.ahk:24`).

What it does:

- Uses SuperMemo’s built-in formatting cleanup (F6) to normalize formatting.
- Intended to preserve tables and keep the component semantically similar.

Use when:

- You pasted rich HTML and want it “normalized” without rewriting files on disk.

Avoid when:

- You specifically need to remove odd tags/styles that F6 doesn’t touch, or the HTML is corrupted.

### `:F` / `NukeHTML` — Rewrite HTML on disk (two levels)

**Triggers**:

- `:` then `F` in an element window (`lib/bind/smvim_command.ahk:28`)
- Vim Commander: `<C-;>` → `NukeHTML` (`lib/bind/vim_command.ahk:62`)

What it does (high-level):

- Ensures you’re editing an HTML component (switches components if needed).
- Finds the underlying HTML file path for the current component.
- Runs `SM.CleanHTML(...)` over the full HTML text, then writes the cleaned HTML back to the same file.
- Refreshes the HTML component in SuperMemo.

Important behavior:

- It will **modify files inside your collection** (the element’s stored HTML file).
- `:F` is the “clean” variant: it rewrites HTML but generally **preserves `class=...` attributes** (so cloze/extract/highlight spans can survive).
- `NukeHTML` is the “nuke” variant: it rewrites HTML and **removes class attributes** broadly (and will prompt if it detects known SuperMemo-related classes).

Use when:

- `:F`: the HTML has become unmanageable (nested spans/styles, broken tags, copied-from-PDF weirdness) but you still want to keep meaningful class-based markup.
- `NukeHTML`: you want a “start over” cleanup and you don’t care about preserving class-based markup in the current component.

Avoid when:

- `:F`: you’re not sure which component you’re cleaning; switch to the correct component first.
- `NukeHTML`: you rely on classed spans for workflows (cloze/extract/highlight/markers) and want them preserved.

### `MakeHTMLUnique` — Anti-merge marker (avoid SM auto-merging)

**Trigger**: Vim Commander: `<C-;>` → `MakeHTMLUnique` (available when editing HTML; see `lib/bind/vim_command.ahk:783`).

What it does:

- Inserts an “anti-merge” span at the end of the HTML:
  - `<SPAN class=anti-merge>HTML made unique at ...</SPAN>`

Why it exists:

- In some SuperMemo flows, HTML can end up identical enough that SM behaves as if content is “mergeable” or collapses changes in a confusing way.
- This gives the HTML a unique fingerprint without affecting visible rendering (assuming you hide `.anti-merge` via CSS).

Recommended CSS (if you use anti-merge regularly):

```css
.anti-merge {
  position: absolute;
  left: -9999px;
  top: -9999px;
}
```

### `:o` — Compress images

**Trigger**: `:` then `o` (`lib/bind/smvim_command.ahk:55`).

What it does:

- Opens SuperMemo commander and runs the “Compress images” action.

Use when:

- You imported large images (web imports, pasted screenshots) and want to reduce storage size.

---

## Safety checklist (before using aggressive HTML cleaning)

- Confirm you’re on an **HTML component** (not plain text).
- If you care about resuming markers (`SMVim ...`), confirm the marker is still the first content line after cleaning (see `docs/markers.md`).
- If you’re unsure, duplicate the element first (in browsing mode: `ye` duplicates the current element via `SM.Duplicate()` in `lib/bind/smvim_browsing.ahk:365`).

---

## Troubleshooting

- **`:F` says “This script only works on HTML.”**
  - You’re in a plain-text component or there is no HTML component. Switch components (`gc` / `gC` while in SuperMemo browsing mode) and retry.

- **Cleaning “breaks” cloze/extract formatting**
  - Some formatting depends on classed spans. If you need those preserved, prefer `:f` over `:F`, or run `:F` only after you’re done extracting/clozing.

- **Markers stop working after cleaning**
  - Markers must be the first content in the first HTML component. Re-sync the marker (from the relevant external app) so it gets rewritten at the top.
