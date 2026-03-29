# Docs Index (SuperMemo + supermemo_vim_ahk)

This folder documents the SuperMemo-specific workflows and “quality of life” features provided by this repo.

If you’re unsure where to start: read `supermemo_core.md`, then use the “I want to…” sections below to pick a deep dive.

Hotkey notation: `<C-A-s>` means Ctrl+Alt+S (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

---

## How to use these docs

There are two big halves to this project:

1. **Inside SuperMemo** (navigation, editing helpers, reference/tagging, command palette, HTML maintenance).
2. **SuperMemo + external tools** (browser/PDF/video/EPUB workflows that create extracts, sync markers, and resume later).

Most users bounce between the two:

- External app → extract/marker into a SuperMemo “source element”
- SuperMemo → process, cloze, tag, clean HTML, navigate
- Later → `p` AutoPlay uses the marker to resume in the external app

---

## Start here (foundations)

- `beginner_vim_guide.md` — beginner-oriented Vim-in-SuperMemo guide: modes, browsing vs editing, `g`/`'`, and the incremental reading/video loop.
- `supermemo_core.md` — the core model: SuperMemo window types, browsing vs editing vs grading, how Vim mode interacts with SM state, leader/`g` prefixes, Esc behavior.
- `supermemo_setup.md` — required SuperMemo setup (templates, concept groups, defaults) and why certain features depend on them.
- `markers.md` — the marker system (`SMVim read point/page mark/time stamp/...`) that powers resume/AutoPlay across tools.

If you only read two docs first, read those.

---

## I want to… (external tools → SuperMemo)

### Read PDFs / EPUBs / DjVu and extract incrementally

- `readers.md` — full external reader workflows (SumatraPDF/Acrobat/WinDjView/Calibre/Word): extracting, syncing read points/page marks, resuming via AutoPlay.
- `epub.md` — Calibre quick start (EPUB highlight binding + core flow).

Key ideas:

- Create a **source element** for the file (often via Vim Commander `ImportFile`).
- Use `<A-x>` in the reader to extract selection into SuperMemo.
- Use `<A-S-s>` in the reader to write a marker; later press `p` in SuperMemo to resume.

### Read the web and do incremental web browsing (IWB)

- `browser.md` — importing pages, IWB excerpt → new elements, extracting selection → current element, saving read-point markers for resume.

### Watch videos (YouTube or local files) and sync time stamps

- `video.md` — combined incremental video workflows: importing/linking, syncing/clearing time stamps, and resuming behavior.

---

## I want to… (inside SuperMemo)

### Navigate faster in SuperMemo and open/copy links

- `supermemo_navigation.md` — browsing-mode navigation, `gs/gm/yy`, and Vimium-style link hints (`f`, `F`, `yf`).

### Use the command palette and `:` commands

- `supermemo_commander_and_commands.md` — Vim Commander (`<C-;>`) + `:` command mode, what commands appear in which windows, and common recipes.

### Keep HTML stable / clean up messy imports

- `supermemo_html_maintenance.md` — `:f` vs `:F` vs `NukeHTML`, “anti-merge” markers, compress images, and safety notes.

### Manage references, tags, and concept links

- `supermemo_references_tags_concepts.md` — `:r`, `#Link/#Title/#Comment`, tags-as-hashtags, concept linking via `Tag` / `untag ...`, and “Comment” editing.

### Convert LaTeX ↔ images inside SuperMemo

- `latex.md` — LaTeX-to-image conversion (and reverse) in HTML components.

---

## “When should I read a deep dive?”

Use these as “just in time” references:

- If you see **“Link not found.”**: go to `supermemo_references_tags_concepts.md` (your element probably lacks a `#Link:`).
- If **AutoPlay doesn’t resume**: go to `markers.md` (marker placement rules) and the relevant workflow doc (`readers.md`, `browser.md`, or `video.md`).
- If HTML becomes **unmanageable / weird formatting**: go to `supermemo_html_maintenance.md`.
- If you forget “what command does what”: go to `supermemo_commander_and_commands.md`.

---

## Key entry points (things you’ll use constantly)

These are not meant to be exhaustive—just the “map legend”:

| Entry point | Where | What it’s for |
|---|---|---|
| `Esc` | SuperMemo | Reset: exit editing, return to `Vim_Normal`. |
| `p` | SuperMemo browsing mode | AutoPlay + marker-aware resume into external apps. |
| `<A-x>` | External apps | Extract selection into SuperMemo (with variants). |
| `<A-S-s>` | External apps | Sync marker (read point/page mark/time stamp) into the source element. |
| `<C-;>` | Anywhere | Vim Commander (command palette; context-dependent). |
| `:` | SuperMemo element window | Command mode (`:r`, `:F`, etc.). |

---

## Troubleshooting (docs-level)

- If a workflow “does nothing”, check:
  - Script enabled (tray menu).
  - SuperMemo is open and an element window exists (`TElWind`).
  - You’re in the expected state (browsing vs editing vs grading). `Esc` usually fixes it.

When you still can’t tell why a key isn’t firing, `supermemo_core.md` is the best place to debug the “what state am I in?” question.
