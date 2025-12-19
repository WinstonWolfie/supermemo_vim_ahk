# Beginner Vim Guide (SuperMemo + supermemo_vim_ahk)

This is a beginner-oriented guide to “Vim in SuperMemo” as implemented by **supermemo_vim_ahk** (AutoHotkey v1).
It teaches *only* the Vim basics that matter **inside SuperMemo** and **in this repo’s workflows**:

- Vim modes as they behave here (Normal / Insert / Visual / `:` Command)
- The **critical SuperMemo distinction**: *browsing vs editing* (caret vs no caret)
- The two prefix systems you’ll use constantly: **`g`** and **leader `'`**
- The SuperMemo-specific actions you’ll actually do every day:
  - open links
  - extract (`q`) and cloze (`z`)
  - resume reading/watching with markers + `p` (AutoPlay)
  - use Vim Commander (`<C-;>`) and `:` commands

If you want the full map of docs, start at `docs/index.md`.
If you want the full keybinding cheat sheet, see `README.md`.

---

## Hotkey notation

- `<C-x>` = Ctrl + x  
- `<A-x>` = Alt + x  
- `<S-x>` = Shift + x  
- `<C-S-A-a>` = Ctrl + Shift + Alt + a  
- `<leader>` in this repo = the **single quote** key: `'`

---

## Quick Start

A short “do this once” loop that will make the rest of the repo feel obvious.

### 1) Get into the correct baseline state

1. Focus a SuperMemo **element window** (`ahk_class TElWind`)
2. Press `Esc` until:
   - you see **no text caret** inside the component (**browsing state**), and
   - you are in **Vim normal mode** (tray icon should reflect it)

If anything ever feels “stuck”, `Esc` is the universal reset.

### 2) Browse and navigate like a browser

While **browsing** (no caret):

- `j` / `k` scroll down / up
- `d` / `u` scroll down / up (bigger step than j/k)
- `gg` go to top (Vim-style)
- `G` go to bottom (Vim-style)
- `g0` go to root element
- `r` reload (smart “refresh” that tries to do the right thing in learning/grading too)

### 3) Open links without touching the mouse

- `gs` opens the element’s `#Link` in your default browser
- `gm` opens URLs found in the element’s `#Comment`
- `f` shows **hint overlays** (Vimium-style); type the hint letters to open a target

If you see **“Link not found.”**, the element probably has no `#Link:` yet — use `:r` (see below).

### 4) Enter editing and type

To actually edit content, you must enter **SuperMemo editing**:

- `q` = edit the **first question** component
- `a` = edit the **first answer** component
- then `i` = enter Insert mode (type normally)

To exit editing and go back to browsing:

- `Esc` (often once or twice)

### 5) Do the two SuperMemo power moves: extract (`q`) and cloze (`z`)

Once you have a caret and you’re editing text:

- `v` to select (Visual mode)
- select something
- press:
  - `q` to **Extract**
  - `z` to **Cloze**

That’s the core “Vim” workflow inside SuperMemo in this repo.

### 6) Resume reading/watching using `p`

The repo’s incremental reading/video workflows store a marker inside your element.
To resume later:

- Go to the **source element** in SuperMemo (browsing mode)
- Press `p` (**AutoPlay**)

You’ll be prompted to jump/search based on the marker type.

---

## The single most important concept: two layers of “mode”

In this repo you always have **two independent states**:

### A) Vim mode (this script)

- **Normal**: keys are commands (navigate, open links, extract/cloze operators)
- **Insert**: keys are typing (less Vim interception)
- **Visual**: you’re selecting text (then you act on that selection)
- **Command**: `:` mode (SuperMemo-only single-letter commands)

### B) SuperMemo editing state (SuperMemo UI)

- **Browsing**: *no caret* in the component (navigation + AutoPlay live here)
- **Editing HTML**: caret inside an HTML component
- **Editing plain text**: caret inside a TMemo/TRichEdit component
- **Grading**: grading buttons focused (repo has special grading bindings)

The same key can behave differently depending on both layers.

**Rule of thumb**
- If you see a caret → you are “editing”.
- If you do not see a caret → you are “browsing”.

For the official model of these states, see `docs/supermemo_core.md`.

---

## Normal mode in SuperMemo browsing

This is where “SuperMemo-as-a-browser” lives.

### Getting into browsing mode

Press `Esc` until the caret disappears.

### Essential browsing keys

| Key | What it does (in this repo) |
|---|---|
| `j` / `k` | Scroll down / up |
| `d` / `u` | Scroll down / up (bigger step than j/k) |
| `gg` / `G` | Top / bottom |
| `r` | Reload (smart refresh) |
| `p` | AutoPlay (marker-aware resume) |
| `n` / `N` | Add topic / add item |
| `x` | Delete element/component |
| `b` | Open (or focus) SuperMemo subset browser |
| `yy` | Copy the element’s `#Link` |
| `m` | Set read point (inside SuperMemo) |
| `` ` `` | Jump to read point |
| `<A-m>` | Clear read point |
| `t` | Click first text component |
| `\` | SuperMemo search (Ctrl+F3) |

For a deeper navigation walkthrough, see `docs/supermemo_navigation.md`.

---

## Editing mode: Normal vs Insert

### Enter editing (caret appears)

In the element window:

- `q` → edit first question
- `a` → edit first answer

### Insert mode: type normally

- `i` → switch to Insert mode (typing)
- `Esc` → back to Normal mode (and often exits editing too, depending on SM state)

### Why Insert mode sometimes “appears automatically”

This repo auto-switches to Insert mode when SuperMemo opens dialogs or fields that expect typing (plan edits, input dialogs, task manager fields, etc.).
That behavior is intentional: it prevents Vim-style navigation keys from breaking typing fields.

If you finish typing and want your navigation keys back:

- press `Esc`

---

## Search in SuperMemo (quick)

You can trigger a search UI directly from the element window:

- `/` opens the search dialog
- `?` opens search and goes to Visual after the match
- `<A-/>` variants can cloze the first match (see `README.md` if you want those)

If you’re browsing (no caret), the search flow automatically jumps into the first question component before searching.

---

## Grading mode (when the grading buttons are focused)

When SuperMemo’s grading buttons are focused, the following keys grade and advance:

- `s` = grade 2
- `d` = grade 3
- `f` = grade 4
- `g` = grade 5

If these keys do nothing, make sure the grading buttons (not the text component) are focused.

---

## Visual mode: select → act

Visual mode is your “highlight something and do a SuperMemo action” mode.

### Enter / exit visual

- `v` → Visual mode
- `Esc` → exit visual back to Normal

### Beginner actions you’ll use immediately

While selecting text (Visual mode):

| Key | Action |
|---|---|
| `q` | Extract selection |
| `z` | Cloze selection |
| `m` | Highlight selection (HTML uses highlight; plain text wraps in `*...*`) |

There are more visual helpers (HTML tag parsing, cloze placeholder insertion, etc.), but you can ignore them until you want speed.

---

## The SuperMemo twist: `q` = Extract, `z` = Cloze

In this repo, `q` and `z` are “operator modes” that drive SuperMemo’s core workflows:

- `q` = extract
- `z` = cloze

### The easiest beginner path: Visual selection

1. Enter editing (caret visible)
2. `v` to select
3. `q` to Extract **or** `z` to Cloze

### The “Vim-ish” path: operate on a motion or text object

If you’re comfortable with Vim motions/text objects, you can do things like:

- `qip` = extract inner paragraph  
- `ziw` = cloze inner word  
- `zt.` = cloze until the next period (works because this repo includes “sneak”-style character motions)

(These examples are mentioned in `README.md` and are the intended “power user” workflow.)

If you’re new: don’t force it. Visual selection covers 90% of real-world use.

---

## Prefix keys: `g` and leader `'`

These are the two “multi-key” systems you’ll use constantly.

### `g` prefix: navigation + “go/open” actions

In **browsing mode**, press `g` then one of these keys:

| Keys | Meaning |
|---|---|
| `gs` | Open the element’s `#Link` |
| `gm` | Open URLs in `#Comment` |
| `g0` | Go to root element |
| `g$` | Go to last element |
| `gc` / `gC` | Next / previous component |
| `gU` | Click the “Source” button (where available) |

In **editing HTML**, `gx` opens the hyperlink under the caret (handy for HTML-heavy sources).

If you hit `g` by accident, press `Esc` to cancel/reset.

### Leader `'`: “unlock extra shortcuts” state

Press `'` (single quote) **while browsing** (no caret). For a short time you’re in a “leader state” and some extra bindings become available without stealing common keys from SuperMemo. If you press `'` while editing, it will just type a quote.

Beginner-relevant leader uses:

- In **HTML editing**: `'u` copies the hyperlink under the caret
- In **HTML editing**: `'q` adds `>` quote prefixes (useful for email-style quoting)
- Leader also gates the “priority/interval” hotkeys when you’re not already learning/grading.

If leader feels “sticky”, press `Esc` to reset.

---

## The two command surfaces: Vim Commander vs `:` commands

This repo gives you two ways to run SuperMemo-specific tools.

### 1) Vim Commander: `<C-;>`

Think “command palette”.

1. Press `<C-;>`
2. Type to filter
3. Enter to run

What appears depends on what window is focused (element window, browser, plan, registry, etc.).

Beginner-friendly Commander commands:

- `ImportFile` (create a source element for PDFs/EPUBs/videos)
- `OpenInAcrobat` (force Acrobat and enable Acrobat page-jump logic)
- `Tag` / `Comment` (reference/tag workflows)
- `NukeHTML` (aggressive HTML cleanup — use later, carefully)

Full list + explanation: `docs/supermemo_commander_and_commands.md`.

### 2) `:` command mode (inside SuperMemo)

This is “ex” command mode, but simplified:

- In a SuperMemo element window, in normal mode, press `:`
- Then press **one letter** (no Enter needed)

Beginner `:` commands worth remembering:

| Command | What it does |
|---|---|
| `:r` | Set/update reference (`#Link`, `#Title`, etc.) from clipboard + captured browser metadata |
| `:f` | Clean format (SuperMemo F6 flow; safer) |
| `:F` | Clean HTML on disk (more aggressive; HTML only) |
| `:o` | Compress images (SuperMemo commander action) |
| `:l` / `:L` | List links / link concept |

If you only learn one: learn `:r`. It fixes “Link not found” problems fast.

---

## The incremental workflow loop (web, PDFs/EPUBs, video)

Most of this repo’s “magic” is one repeating loop:

1. Create a **source element** in SuperMemo for the thing you’re consuming (page/file/video).
2. While reading/watching externally, **extract** highlights into SuperMemo.
3. Before leaving, **sync a marker** (read point / page mark / time stamp).
4. Later, in SuperMemo, press `p` (**AutoPlay**) to resume.

### The marker rule that matters

Markers are stored in the element’s **first HTML component** and must be the **first line**.

Keep the source element’s first HTML component **empty** (or containing only the marker).
If you put your own notes/title there, the automation may prompt:

- “Go to source and try again?”

Marker definitions and precedence: `docs/markers.md`.

---

## Workflow A: Incremental web reading

Full detail: `docs/browser.md`.

### Create the source element

In your browser:

- `<C-A-a>` = fast import
- `<C-S-A-a>` = import with options (recommended)

This creates an element with `#Link/#Title/...`.

### Extract while reading

- Select text in the browser
- Press `<A-x>` to extract into the current SuperMemo element

### Save your place (read point marker)

On a normal webpage:

1. Select a short, unique snippet near where you stopped
2. Press `<A-S-s>`

### Resume later

In SuperMemo, on the source element:

- `p` → AutoPlay opens the page and offers to search the snippet

---

## Workflow B: Incremental PDFs / EPUBs / DjVu

Full detail: `docs/readers.md` (Calibre quick start: `docs/epub.md`).

### Create the source element (recommended)

In SuperMemo:

1. `<C-;>` → run `ImportFile`
2. Select the PDF/EPUB/DjVu

This expects a SuperMemo template named **`binary`**.

### Open and resume

On the source element (browsing mode):

- `p` → opens the file in your reader and offers to jump/search (if a marker exists)

### Extract

In your reader:

- Select text
- `<A-x>` to extract

### Save your place

- If you **select text**: `<A-S-s>` saves a **read point**
- If you **don’t select text** (PDF/DjVu readers that support it): `<A-S-s>` saves a **page mark**

---

## Workflow C: Incremental video (YouTube or local files)

Full detail: `docs/video.md`.

### Create a source element

- **YouTube**: import from browser (`<C-A-a>` / `<C-S-A-a>`)
- **Local files**: `<C-;>` → `ImportFile`

### Sync your time stamp

While the browser tab or `mpv` is focused:

- `<A-S-s>` sync time stamp (keep open)
- `<C-A-s>` sync time stamp and close
- `<C-S-A-s>` sync and keep learning

To clear the time stamp (set to `0:00`), use the Backtick versions:

- `<A-S-Backtick>` / `<C-A-Backtick>` / `<C-S-A-Backtick>`

### Resume later

From the SuperMemo source element:

- `p` = AutoPlay (marker-aware)
- `P` = view file / play in default player / edit script component (context dependent)
- `<A-s>` = copy marker content if a marker exists (read point / page mark / time stamp)

---

## Troubleshooting

### “My keys do nothing.”
Check these in order:

1. **Script enabled?** (tray menu should say enabled)
2. **Are you in the element window?** (`TElWind`)
3. **Are you in browsing vs editing correctly?**
   - If you expected navigation: press `Esc` until there’s **no caret**
4. **Are you stuck in a prefix state (`g` or `'`)?**
   - Press `Esc` to reset

If everything is truly broken, reload the script:

- `<C-A-r>` (Ctrl+Alt+R)

### “Link not found.” when I use `gs` or `yy`
The element likely has no `#Link:`.

Fix:

1. Copy the URL to clipboard
2. In SuperMemo: `:` then `r` (`:r`)

More: `docs/supermemo_references_tags_concepts.md`.

### AutoPlay (`p`) doesn’t resume where I left off
Common causes:

- You synced a marker, but it isn’t the **first line** in the **first HTML component**.
- You’re on an extract child element, not the source element.
- The element has no script/binary component to open the external content.

Fix:

- Re-sync the marker from the external app (`<A-S-s>`)
- Keep the first HTML component reserved for the marker (`docs/markers.md`)

### Link hints (`f`) says “Text too long.” or shows no hints
The hint system uses UI Automation and has limits for performance.

Fallbacks:

- Use `gs` / `gm` / `yy`
- Switch component (`gc`) or reduce visible HTML length

### “Go to source and try again?”
Your current element’s first HTML component isn’t in the expected “source element” shape.

Best practice:

- Keep a dedicated source element whose first HTML component is empty (or only the marker).
- Put titles in the element title, and notes in another component.

More: `docs/readers.md` and `docs/markers.md`.

---

## Next steps

- If you want the “full map”, read `docs/index.md`.
- If you want a deeper understanding of states/modes, read `docs/supermemo_core.md`.
- If you want the keybinding encyclopedia, read `README.md`.
- If you want the external workflows:
  - Web: `docs/browser.md`
  - PDFs/EPUBs/DjVu: `docs/readers.md`
  - Video: `docs/video.md`
