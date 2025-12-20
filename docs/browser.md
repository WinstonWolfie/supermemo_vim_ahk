# Browser Workflows (SuperMemo + supermemo_vim_ahk)

This guide covers using a web browser with SuperMemo via `supermemo_vim_ahk`:

- Importing the current page into SuperMemo (offline copy or “online element”)
- Incremental web browsing (IWB): turning selected excerpts into new elements
- Extracting a selection into the *current* SuperMemo element
- Saving a “read point” marker so `p` (AutoPlay) can resume later
- Updating an existing element’s reference (`:r`) from browser metadata

Hotkey notation: `<C-A-s>` means Ctrl+Alt+S (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

Video sites (YouTube time stamps / online progress markers) are documented in `docs/video.md#youtube` (and the shared sync/clear hotkeys in `docs/video.md#workflow-incremental-video-sync--clear-time-stamp`).
Marker storage rules (first HTML line, precedence) are documented in `docs/markers.md`.

---

## Quick Start

A minimal workflow that “just works” for incremental reading in the browser.

### What you need

- AutoHotkey v1.1.1+ (or the built `vim_ahk.exe`)
- SuperMemo running (SM15–SM19)
- This script running and enabled (check tray icon)
- A supported browser in the foreground (Chrome / Edge / Firefox)
- An element window open in SuperMemo (`ahk_class TElWind`)

### Step 1: Create a “source element” for the page

In your browser, open the page you want to read and capture.

- Press `<C-A-a>` to import quickly (defaults)
- Or press `<C-S-A-a>` to import with options (recommended when you care about where it goes / tags / online vs offline)

This creates a new element with a SuperMemo reference block (`#Link`, `#Title`, …).

**Tip:** If you want `p` (AutoPlay) to reliably reopen the page later, import as an **online element** (script URL). See “Offline copy vs online element” below.

### Step 2: While reading, capture knowledge in one of two ways

- **IWB (excerpt → new element):** select a small excerpt and press `<C-S-A-b>`
  - Best when you want lots of small items.
- **Extract (excerpt → current element):** select text and press `<A-x>`
  - Best when you’re building extracts inside a single source element.

### Step 3: Save your place (read point marker)

On a normal (non-video) webpage:

1. Select a short, unique snippet close to where you stopped reading
2. Press `<A-S-s>` (Alt+Shift+S)

This writes an `SMVim read point: ...` marker into the element so you can resume later.

### Step 4: Resume later with AutoPlay

1. In SuperMemo, navigate to the source element
2. Press `p`

AutoPlay opens the page and offers to search for your saved read point snippet (browser Find).

If AutoPlay can’t open the page (missing script/binary component), use `gs` to open the element’s `#Link`, then manually search for the snippet.

---

## Prerequisites and mental model

### Supported browsers

Browser automation is UIA-based (`UIA_Browser`). The browser usually needs to be visible/foreground for URL/title detection, tab closing, and find/search operations.

Supported foreground browsers (in `ahk_group Browser`):
- Chrome (`chrome.exe`)
- Edge (`msedge.exe`)
- Firefox (`firefox.exe`)

### Offline copy vs online element

The import workflow can create two "styles" of elements:

1) **Offline copy (HTML captured into the element)**
- The element stores page HTML/text (selection, copy-all, or downloaded HTML depending on options).
- Good when you want an archived copy inside SuperMemo.
- Resume (`p`) may or may not be able to *open the page* automatically depending on your template/components.
  - You can always open the link with `gs`.

2) **Online element (script URL; minimal stored content)**
- The element stores a script component containing the URL, plus the reference block.
- Best for long incremental reading where you want to reopen the live page.
- This is the most reliable way to make `p` (AutoPlay) reopen the page for resume.

### What counts as an "online context"?

Some UI options and behaviors depend on whether the script thinks you're importing into an "online context". In user terms, you're in an online context if **either**:

- Your **current concept group** is `Online` or `Sources` (these are treated as "online" concepts), or
- Your **current collection** is one of the "online collections" hardcoded in the script (currently: `passive`, `singing`, `piano`, `calligraphy`, `drawing`, `bgm`, `music`).

User-visible effects:

- The import GUI may hide **Import as online element** (because it's already implied by your context).
- If you're doing IWB, choosing an online context is rejected (IWB is for offline-style excerpt elements).
- Online-element imports require a working **Script component** (see troubleshooting below).

Dev note: the core check is `SM.IsOnline(...)` in `lib/sm.ahk:455` (online concepts: `Online,Sources`; online collections list is hardcoded there too). The import GUI/context logic lives in `lib/bind/smvim_import.ahk`.

### URL normalization

When the script captures a URL, it often **normalizes** it (removes fragments `#...` for most sites, strips tracking query parameters on some sites, shortens YouTube URLs, etc.). This improves duplicate checking and keeps references clean, but it means the stored link may not exactly match your address bar.

### Reference metadata

During import / copy-link capture, the script tries to populate:
- `#Link`, `#Title`
- sometimes `#Source`, `#Author`, `#Date`
- optional `#Comment` (your tags/comment)

Metadata quality depends on the site and whether the script can access/copy the page.

---

## Workflow A: Import the current webpage into SuperMemo

Context: browser focused; SuperMemo open with an element window.

### Hotkeys

- `<C-A-a>`: fast import using defaults (no GUI)
- `<C-S-A-a>`: import with a GUI (priority/concept/tags/comment/options)

### What import does

- Captures the current page URL (normalized)
- Captures either:
  - your current selection (when applicable), or
  - the whole page (copy-all), or
  - downloaded HTML for certain sites (when “fullpage HTML” mode is enabled)
- Creates a new SuperMemo element and appends the SuperMemo reference block

### Duplicate checking

Import performs a URL duplicate check and may prompt you to continue if a potential duplicate is detected.

### Import GUI options (and when they appear)

The GUI is context-sensitive. You won’t always see all options.

Common fields (always shown in GUI import):
- **Priority**
- **Concept group**
- **Tags** (enter without `#`, separated by `;`; written into `#Comment:` and also used to link concepts)
- **Reference comment**
- **Close tab**

Options shown only in some contexts:

- **Import as online element**
  - Shown for non-IWB imports when you’re not already importing into an “online” context.
  - Recommended if you want reliable resume via `p`.

- **Import fullpage HTML**
  - Shown only when importing a **non-video** page **as an offline copy**.
  - When enabled, the script may download/copy the whole page rather than using your selection.

- **Reset time stamp** / **Mark as use online progress** (YouTube)
  - Shown for video/audio sites or when importing as an online element.
  - These belong to the video workflow; see `docs/video.md#youtube`.

### What you get

- A new element with:
  - HTML content (offline copy) **or** a script URL (online element)
  - A reference block such as:

```

#SuperMemo Reference:
#Link: [https://example.com/](https://example.com/)...
#Title: ...
#Source: ...
#Author: ...
#Date: ...
#Comment: ...

```

---

## Workflow B: Incremental web browsing (IWB) — excerpt → new element

Use this while reading: select a small excerpt, then quickly create a new element seeded with that excerpt plus a reference back to the source page.

Context: browser focused; selection required; SuperMemo open.

### Hotkey

- `<C-S-A-b>`: IWB (opens a small import GUI)

### Steps

1. Select a small excerpt on the page (keep it short).
2. Press `<C-S-A-b>`.
3. Optionally fill:
   - priority
   - concept group
   - tags (`;`-separated, without `#`)
   - comment
   - optional “Check duplication” (URL-based)
4. The script creates a new element for that excerpt and appends `#Link/#Title/...`.

**Note:** IWB is intended for offline-style excerpt elements. If you choose an “online” concept group, the script will ask you to choose again.

---

## Workflow C: Extract selection → current SuperMemo element

This is for building extracts inside the element you already have open in SuperMemo (often your “source element”).

Context: browser focused; SuperMemo element window exists.

### Hotkeys

| Hotkey | Behavior |
|--------|----------|
| `<A-x>` | Extract selection into current element; return to browser |
| `<A-S-x>` | Same, but prompts for priority |
| `<C-A-x>` | Extract selection; stay in SuperMemo afterwards |
| `<C-S-A-x>` | Priority prompt + stay in SuperMemo |

### Notes

- The browser extract path tries to preserve HTML formatting when possible and cleans it before pasting.
- The script may prompt you if the current SuperMemo element doesn’t look like the right “source element” for the current URL (it can offer to search/navigate).

### Empty extract: chapter/section marker (no selection)

If you press `<A-x>` with **no selection**, the script can still create a “chapter/section” marker element by prompting:

- `Extract chapter/section:`

This is the same feature described in `docs/readers.md` (“Empty extract”), and it works from the browser too.

---

## Workflow D: Save a read point marker (resume later)

This is the web equivalent of a PDF “read point”: save a short snippet, and later jump back to it via `p` (AutoPlay).

Context: browser focused; SuperMemo element window exists.

### Important behavior

- For normal web pages, **you must select text**.
- Only the **first line** of the selection is stored as the read point.
  - Select a short, unique phrase (avoid multi-line selections).

### Hotkeys

| Hotkey | Behavior |
|--------|----------|
| `<A-S-s>` | Save read point marker; keep tab open |
| `<C-A-s>` | Save marker and close the current tab |
| `<C-S-A-s>` | Save marker, close tab, and continue learning in SuperMemo |

### What gets written

The marker is written into the element’s **first HTML component** as the first line, e.g.:

```

SMVim read point: <your snippet>

```

Internally it’s wrapped in a highlight span, but you normally don’t need to care.

See `docs/markers.md` for marker precedence rules (first line wins; keep one marker at the top).

### If you didn’t select text

Depending on context (especially video/online), the same hotkeys may enter **timestamp** workflow instead of read-point workflow.

If you see prompts about a time stamp, you’re in the video/time-sync path — see `docs/video.md#workflow-incremental-video-sync--clear-time-stamp`.

---

## Workflow E: Resume (AutoPlay)

Context: SuperMemo element window focused (browsing mode).

- Press `p` to run AutoPlay.

AutoPlay:
1. Reads the first-line marker (read point / time stamp / online progress flag)
2. Opens the external content (usually via `Ctrl+F10` running a script/binary component)
3. Prompts you based on marker type:
   - **Read point:** asks if you want to search the snippet (browser Find)

### If AutoPlay doesn’t open the page

That usually means the element doesn’t have a script/binary component that opens the URL.

Options:
- Import as an **online element** next time (recommended)
- Or use `gs` to open the element’s `#Link`, then manually search for the snippet

---

## Workflow F: Update an element’s reference from the browser (`:r`)

This is for when you already have an element, but you want to populate/update `#Link/#Title/...` without importing content.

### Recommended “capture → apply” recipe

1) In the browser, press `<C-A-l>` (Ctrl+Alt+L)
- Copies the normalized URL to clipboard
- Captures browser metadata into the script’s `Browser.*` fields (title/source/author/date when available)

2) In SuperMemo, enter command mode (`:`), then press `r`
- Writes a reference block into the element’s reference fields using:
  - URL from clipboard
  - cached `Browser.Title/Source/Author/Date/Comment` (if available)

**Tip:** Run `:r` immediately after `<C-A-l>` for best results (metadata is cached and cleared after reference update).

---

## Quick reference

### From the browser (SuperMemo must be open)

| Hotkey | Action |
|--------|--------|
| `<C-A-a>` | Import current page (fast) |
| `<C-S-A-a>` | Import current page (GUI) |
| `<C-S-A-b>` | IWB: selection → new element (GUI) |
| `<A-x>` | Extract selection into current element |
| `<A-S-s>` | Save read point marker (non-video pages; selection required) |
| `<C-A-s>` | Save marker + close tab |
| `<C-S-A-s>` | Save marker + close tab + keep learning |
| `<A-S-d>` | Duplicate check (selection; in browser may fall back to URL) |
| `<C-A-l>` | Copy parsed URL + capture metadata (use before `:r`) |

### From SuperMemo (browsing mode)

| Key | Action |
|-----|--------|
| `p` | AutoPlay (resume using marker) |
| `gs` | Open element `#Link` in default browser |
| `gm` | Open links found in `#Comment` |
| `yy` | Copy element `#Link` |
| `:` then `r` | Update reference from clipboard + captured metadata |

---

## Troubleshooting

### Hotkeys do nothing
- Script disabled (tray icon/menu)
- SuperMemo not open, or no element window exists (`ahk_class TElWind`)
- Browser not foreground / not in the supported browser group

### “Url not found.” / wrong URL captured
- Make sure the browser window is active and not minimized
- Click the page once, then retry (UIA sometimes needs focus)

### Import prompts “Continue import?”
- Import does a duplicate check by URL. Choose Yes to proceed, No/Cancel to stop.

### “Go to source and try again?” prompt
- The script expects to write markers/extracts into a “clean” source element (empty HTML or only a marker).
- Keep a dedicated source element for the page, and put extracts in child elements.

### I pressed `<A-S-s>` and got asked for a time stamp
- You likely didn’t select text, or you’re on a video/online context where the same keys sync time stamps.
- For normal web-page read points: select a short snippet first.

### AutoPlay (`p`) doesn't open the page
- Import as an **online element** so the element has a script URL that `Ctrl+F10` can open.
- Or use `gs` as a manual fallback.

### AutoPlay (`p`) doesn't see the read point
- The marker must be the first line in the element's first HTML component. If you edited HTML and moved it down, re-save/sync the marker so it's back on top.

### "Script component not found." during import
- This happens when importing as an **online element** but your SuperMemo template doesn't provide a Script component that the automation can edit.
- Fix: adjust your template for your online source elements (often the `Online` / `Sources` concepts' default templates) so it includes a Script component, or import as an offline copy instead.

Dev note: the online import branch tries to open the Script component editor and write `rl <url>`; if the script editor window doesn't appear, it aborts with this message (`lib/bind/smvim_import.ahk`).
