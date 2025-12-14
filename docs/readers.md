# External Reader Workflows (SuperMemo + supermemo_vim_ahk)

This guide covers incremental reading from external readers (PDF, EPUB, DjVu) with SuperMemo: extracting text, saving your reading position, and resuming where you left off.

Hotkey notation: `<C-A-s>` means Ctrl+Alt+S (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

## Quick Start

This section is a self-contained guide to get you productive with incremental reading from external files (PDF, EPUB, DjVu).

### What you need

- SuperMemo running (SM15–SM19)
- SumatraPDF (recommended), Adobe Acrobat, WinDjView, or Calibre
- This script running and enabled (check tray icon)
- A SuperMemo template named `binary` (required for ImportFile command)

### Step 1: Create a source element

You need a SuperMemo element that links to your file (PDF, EPUB, etc.). The easiest way:

1. In SuperMemo, press `<C-;>` to open Vim Commander
2. Type `ImportFile` and press Enter
3. In SuperMemo's file browser, select the file you want to import
4. When prompted "Do you want to also delete the file?", choose:
   - **No**: keep the original file where it is
   - **Yes**: delete the original after SuperMemo imports it
   - **Cancel**: abort the automation (you can still import manually in SuperMemo)

This creates an element with an HTML component (for markers) and a binary component (the file).

**Important**: Treat the source element's **first HTML component** as *reserved for SMVim markers*.
Leave it empty (or containing only an `SMVim ...` marker at the very top).
Don't type the PDF title or notes into that HTML component, or `<A-x>` / `<A-S-s>` will prompt "Go to source and try again?" and may overwrite that content.
Put titles in the **element title** instead, and keep notes in a different component if needed.

If you don't have a `binary` template, manually create an element with an HTML component and attach the file via a binary or script component.

### Step 2: Open the file

With your source element focused in SuperMemo in browsing mode (no text cursor active - press Escape to exit editing mode):

- Press `p` to open the file in your reader

If there's a saved position, you'll be prompted to jump to it.

Acrobat note: if your PDFs open in Acrobat and you saved a **page mark**, use `<C-;>` → `OpenInAcrobat` to enable the Acrobat page-jump logic.

### Step 3: Read and extract

While reading in your external reader:

1. Select text you want to extract
2. Press `<A-x>` to send it to SuperMemo as a new extract

The script copies your selection, switches to SuperMemo, pastes it, and runs SuperMemo's extract command. Your reader auto-highlights the extracted text (if configured).

### Step 4: Save your position before closing

Before leaving your reader:

- **With text selected**: Press `<A-S-s>` to save a "read point" (the selected text becomes a search target)
- **Without selection (PDF/DjVu readers)**: Press `<A-S-s>` to save a "page mark" (current page number)
- **EPUB/Calibre note**: Calibre doesn't support page marks in this workflow. Always select a short phrase before pressing `<A-S-s>` so a read point is saved (otherwise you'll see "No text selected.").

The marker is written into your source element's HTML component.

### Step 5: Resume later

1. Navigate to your source element in SuperMemo
2. Press `p`
3. The file opens and you're prompted to jump to your saved position

That's it! The sections below provide full details on each feature.

---

## Prerequisites

- AutoHotkey v1.1.1+ (or the built `vim_ahk.exe`)
- SuperMemo running (SM15–SM19 are grouped as `ahk_group SM`)
- A supported external reader:

| Reader | Detection | Notes |
|--------|-----------|-------|
| SumatraPDF | `ahk_class SUMATRA_PDF_FRAME` | Recommended; full feature support |
| Adobe Acrobat | `ahk_class AcrobatSDIWindow` | Read point: best-effort (`Ctrl+F` search). Page mark: supported, but AutoPlay page-jump requires `OpenInAcrobat`. |
| WinDjView | `ahk_exe WinDjView.exe` | For DjVu files; page mark supported. Read point: best-effort (depends on text layer/find). |
| Calibre | `ahk_exe ebook-viewer.exe` | For EPUB files; read point supported. Page mark not supported (selection required). |
| MS Word | `ahk_exe WINWORD.exe` | Extract only; no marker sync |

Marker storage/detection is shared across workflows; see `docs/markers.md` for details.

## Setup

### Creating a source element

These workflows require a SuperMemo element with:

1. **An HTML component** - markers are written into the **first HTML component**, and the marker must be the **first content** in that component (keep it otherwise empty)
2. **A way to open the file** - either:
   - A binary component containing the file, or
   - A script component with a `file://...` path

**Using ImportFile (recommended)**:

1. Press `<C-;>` to open Vim Commander
2. Type `ImportFile` and press Enter
3. In SuperMemo's file browser (`TFileBrowser`), select the file you want to import
4. Answer the script prompt "Do you want to also delete the file?"

This sets the element template to `binary` and walks you through file attachment (see `lib/bind/vim_command.ahk:580`).

**Requirement**: You need a SuperMemo template named `binary`. Create one if it doesn't exist. **Important**: The template name must be exactly `binary` (case-sensitive) as the automation hardcodes this name.

**Manual setup**: If you already have an element for your file, ensure it has an HTML component.
The automation expects the **first HTML component** to be empty (or to contain only an `SMVim ...` marker at the very top).
If you put anything else there (e.g., the PDF title as the first line), you'll likely see a "Go to source and try again?" prompt during extraction/marker syncing.

### Reader-specific setup

**SumatraPDF** (recommended):

The automation uses Sumatra's built-in controls:
- `Edit1`: Page number field
- `Edit2`: Find/search field

Ensure these fields are visible and focusable. If Sumatra is configured to hide the toolbar, page jumping and read point searching won't work.

**Adobe Acrobat**:

The script uses UI Automation to find the page number control. It looks for:
- A UIA element with `ControlType=Edit AND Name='Page Number'`
- Fallback: `AVQuickToolsTopBarCluster` path

Different Acrobat versions may have different UI layouts. If page jumping doesn't work, you may need to adjust `GetAcrobatPageBtn()` in `lib/lib.ahk:1117`.

**Acrobat page marks and AutoPlay**: Page marks can be saved from Acrobat, but AutoPlay will only offer to jump to a saved **page mark** when the PDF was launched via the `OpenInAcrobat` command (it runs `SM.AutoPlay(true)` and enables the Acrobat UIA page control logic). If you open PDFs in Acrobat via default associations using `p`, page-mark jumping is not triggered.

**WinDjView**:

- Page mark works via `Edit1` (reliable)
- Read point is best-effort: AutoPlay uses a generic `Ctrl+F` search and depends on the DjVu's text layer and WinDjView's find behavior (scanned/image-heavy DjVu often won't work)

**Calibre Ebook Viewer**:

For auto-highlight to work after extraction, bind `q` to create an annotation/highlight:

1. In Calibre Ebook Viewer, open Preferences → Keyboard shortcuts
2. Find the action that creates an annotation/highlight
3. Bind it to `q`

Without this binding, extraction still works but Calibre won't mark what you extracted.

**Marker note**: Calibre only supports read points in this workflow—page marks aren't available, so you must select text before syncing.

## Opening Files (AutoPlay)

**Context**: SuperMemo element window focused, browsing mode (not editing text).

Press `p` to run `SM.AutoPlay()` (`lib/bind/smvim_browsing.ahk:148`). This:

1. Reads any SMVim marker from the element's HTML
2. Opens the file via `Ctrl+F10` (triggers script/binary component)
3. When the file opens, prompts you based on marker type:
   - **Read point**: "Do you want to search read point?" — searches for the saved text
   - **Page mark**: "Do you want to go to page mark?" — jumps to the saved page

**Reader behaviors**:

| Reader | Read point | Page mark |
|--------|------------|-----------|
| SumatraPDF | Fills `Edit2` (internal), presses Enter | Fills `Edit1` (internal), presses Enter |
| Calibre | `Ctrl+F`, pastes text, Enter×2 | Not supported |
| WinDjView | `Ctrl+F`, pastes text, Enter (best-effort) | Fills `Edit1` (internal), presses Enter |
| Acrobat | `Ctrl+F`, pastes text, Enter (best-effort) | UIA page control jump (only in `OpenInAcrobat` mode) |

**OpenInAcrobat command**: If you want to force opening in Acrobat regardless of default associations (and enable Acrobat page-mark jumping), use Vim Commander (`<C-;>`) and type `OpenInAcrobat`. This extracts the file path and runs `acrobat.exe <path>`.

## Reading & Extracting

### Basic extraction

**Context**: External reader focused, text selected, SuperMemo running with element window.

Press `<A-x>` to extract the selected text into SuperMemo.

What happens:
1. Script copies your selection (HTML when available, plain text for PDFs)
2. Switches to SuperMemo element window
3. Pastes the text
4. Runs SuperMemo's extract command (`Alt+X`)
5. Returns focus to your reader

**Extraction variants**:

| Hotkey | Shift | Ctrl | Behavior |
|--------|-------|------|----------|
| `<A-x>` | — | — | Basic extract, returns to reader |
| `<A-S-x>` | Yes | — | Prompts for priority before extracting |
| `<C-A-x>` | — | Yes | Stays in SuperMemo after extract |
| `<C-S-A-x>` | Yes | Yes | Priority prompt + stays in SuperMemo |

Code: `lib/bind/smvim_import.ahk:34-289` (developer reference)

### Empty extract (chapter/section markers)

If you press `<A-x>` **without** a selection, you can create a chapter or section marker:

1. A dialog prompts for "Extract chapter/section:"
2. Enter a section name (e.g., "Chapter 3" or "sect: Introduction")
3. The script duplicates the current element with that title
4. For Wikipedia URLs with `sect: ` prefix, it appends the section to the URL's `#` fragment

This is useful for creating navigation elements within a document without extracting actual text.

### Auto-annotation

After extracting, the script sends a highlight command to your reader so you can visually track what you've extracted:

| Reader | Key sent | Effect |
|--------|----------|--------|
| SumatraPDF | `a` | Triggers annotation/highlight (requires Sumatra config) |
| Calibre | `q` | Highlight (requires Calibre shortcut config) |
| WinDjView | `Ctrl+H` | Opens annotation dialog, presses Enter |
| MS Word | `Ctrl+Alt+H` | Highlight selection |
| Acrobat | `AppsKey` then `h` | Context menu → Highlight |

**SumatraPDF note**: If `a` triggers an unexpected action, you can:
1. Rebind Sumatra's `a` key to your preferred highlight action
2. Accept the keypress as-is
3. Remove the `Send {text}a` line in `lib/bind/smvim_import.ahk:201`

### Duplicate checking

**Context**: External reader focused, SuperMemo running.

Press `<A-S-d>` to check if the selected text (or URL) already exists in your collection.

- With selection: searches for that text in SuperMemo
- Without selection: **browser only** (falls back to the current URL). In readers (Sumatra/Acrobat/Calibre/WinDjView/Word) it requires a selection; otherwise shows "Text not found."

This helps avoid creating duplicate extracts (`lib/bind/smvim_import.ahk:9-32`).

## Saving Your Position

### Read point vs page mark

The script supports two marker types for saving your position:

| Marker | When created | How it resumes | Best for |
|--------|--------------|----------------|----------|
| **Read point** | Text selected when syncing | Searches for that text | Precise positioning; text-heavy PDFs |
| **Page mark** | No selection when syncing (Sumatra/WinDjView/Acrobat) | Jumps to page number | Quick saves; image-heavy PDFs; DjVu |

**Practical guidance**:
- **Read point** is more precise but requires the exact text to exist and be searchable. If the PDF's text layer is poor or the text spans pages, searching may fail.
- **Page mark** is simpler and usually works (in supported readers), but only gets you to the page, not the exact paragraph.
- **Read point storage is first-line only**: Only the first line of the copied selection is stored as the read point—select a short, unique snippet (avoid multi-line selections).

**Tip**: For most PDFs, read point works well. For scanned books or DjVu files, use page mark.

### Sync hotkeys

**Context**: External reader focused, SuperMemo element window exists.

| Hotkey | Behavior |
|--------|----------|
| `<A-S-s>` (Alt+Shift+S) | Sync marker; in Sumatra also saves annotations |
| `<C-A-s>` (Ctrl+Alt+S) | Sync marker and close reader window |
| `<C-S-A-s>` (Ctrl+Shift+Alt+S) | Sync marker and continue learning in SuperMemo |

What happens:
1. If text is selected → copies it as a read point
2. If no selection → reads page number from `Edit1` (Sumatra/WinDjView) or UIA (Acrobat)
3. Switches to SuperMemo
4. Writes the marker as the first line of the HTML component

Code: `lib/bind/vim_shortcut.ahk:288-420` (developer reference)

### What gets written

The marker appears in your element's HTML as:

```
SMVim read point: <your selected text>
```
or
```
SMVim page mark: 42
```

Internally, it's wrapped in a highlight span: `<SPAN class=Highlight>SMVim read point</SPAN>: ...`

**Important**: The marker must remain the first content in the HTML component. If you edit the HTML and move it down, `AutoPlay` won't detect it. Re-sync to fix.

## Sumatra-Specific Features

### Z mode (annotation workflow)

SumatraPDF has a special "Z mode" for annotation sessions. All keys below require Shift (capital letters):

| Key | Context | Action |
|-----|---------|--------|
| `Z` (Shift+Z) | Normal mode, no control focused | Enter Z mode |
| `Z` (Shift+Z) | Already in Z mode | Save annotations, close tab, exit Z mode |
| `Q` (Shift+Q) | In Z mode | Close tab without saving, exit Z mode |

Use Z mode when you want to annotate freely, then save everything at once.

Code: `lib/bind/vim_shortcut.ahk:208-223` (developer reference)

### Page and find field shortcuts

**When no control is focused**:

| Hotkey | Action |
|--------|--------|
| `<A-p>` | Focus page number field (`Edit1`) |
| `<C-A-f>` | Copy selection to find field (`Edit2`), search, select all |

**When page field (`Edit1`) is focused**:

| Hotkey | Action |
|--------|--------|
| `<A-p>` | Paste clipboard into field, press Enter (jump to page from clipboard) |
| `<C-A-p>` | Copy current page as `pNN` format (e.g., `p42`) |

**When find field (`Edit2`) is focused**:

| Hotkey | Action |
|--------|--------|
| `<C-f>` | Paste clipboard into field, press Enter (search clipboard text) |
| `<C-A-f>` | Press Enter, select all |

Code: `lib/bind/vim_shortcut.ahk:225-272` (developer reference)

### Acrobat page field

| Hotkey | Action |
|--------|--------|
| `<A-p>` | Click page number control (via UIA), enter insert mode |
| `<A-p>` `<A-p>` (double-tap within 400ms) | Click control, select all, paste clipboard, press Enter |

Code: `lib/bind/vim_shortcut.ahk:237-251` (developer reference)

## Utilities

### EPUB to TXT conversion

Convert an EPUB file to plain text using `pandoc`:

1. Open Vim Commander (`<C-;>`)
2. Run `EPUB2TXT`
3. Enter the path to the `.epub` file

This produces a `.txt` file beside the original `.epub`.

**Requirement**: `pandoc` must be installed and available on your `PATH`.

## Quick Reference

### From external reader (SuperMemo must be open)

| Hotkey | Action |
|--------|--------|
| `<A-x>` | Extract selection to SuperMemo |
| `<A-S-x>` | Extract with priority prompt |
| `<C-A-x>` | Extract, stay in SuperMemo |
| `<C-S-A-x>` | Extract with priority, stay in SuperMemo |
| `<A-S-s>` | Sync read point/page mark |
| `<C-A-s>` | Sync and close reader |
| `<C-S-A-s>` | Sync and continue learning |
| `<A-S-d>` | Check for duplicates in SuperMemo |

### From SuperMemo (browsing mode)

| Hotkey | Action |
|--------|--------|
| `p` | AutoPlay — open file and jump to marker |
| `<C-;>` → `ImportFile` | Create source element for file |
| `<C-;>` → `OpenInAcrobat` | Open current element's file in Acrobat |

### SumatraPDF-specific

| Hotkey | Action |
|--------|--------|
| `Z` | Enter annotation mode |
| `ZZ` | Save annotations and close (in Z mode) |
| `ZQ` | Discard and close (in Z mode) |
| `<A-p>` | Focus page field / paste+go if focused |
| `<C-A-p>` | Copy page as `pNN` |
| `<C-A-f>` | Search selection in find box |
| `<C-f>` (in find field) | Paste clipboard and search |

## Troubleshooting

### Hotkeys do nothing

- **Script not enabled**: Check the tray icon/menu. Many reader hotkeys require `Vim.State.Vim.Enabled`.
- **No element window**: Reader-side hotkeys require SuperMemo to be open with an element window (`ahk_class TElWind`). Open any element first.
- **Wrong focus**: Some hotkeys only work when specific controls are (or aren't) focused. For Sumatra, try clicking in the document area first.

### ImportFile imports the wrong file

`ImportFile` is automated: after you answer "Do you want to also delete the file?", it sends Enter to SuperMemo's file browser to accept the *currently selected* file. If the file browser opens with an old selection, it may import that file unless you select the correct one first.

If you press **Cancel** on the delete prompt, the script stops and leaves you in SuperMemo's file browser so you can pick the file and import manually.

### AutoPlay doesn't see the marker

- **Marker not first**: The marker is only detected if it's the first content in the HTML component. If you've edited the HTML, re-sync with `<A-S-s>`.
- **Wrong element**: Make sure you're on the source element, not an extract. Source elements typically have the filename or "Concept:" in the title, while extracts show the extracted text as their title.
- **No script/binary component**: AutoPlay needs a way to open the file. Check the element has a binary or script component.

### Extraction doesn't work

- **No selection**: You must have text selected in your reader.
- **PDF text layer issues**: Some scanned PDFs have no selectable text. Use OCR or a different PDF.
- **SuperMemo busy**: Wait for any dialogs to close before extracting.

### Page jump/search doesn't work

**SumatraPDF**:
- **Toolbar must be visible**: If Sumatra's toolbar is hidden (View → Hide Toolbar), page jump and search won't work. The script needs access to the `Edit1` (page) and `Edit2` (find) fields in the toolbar.
- Try `<A-p>` to manually focus the page field

**Acrobat**:
- **Page mark doesn't jump when using `p`**: Use Vim Commander (`<C-;>`) → `OpenInAcrobat` to enable Acrobat page-mark jumping, or use Sumatra for the most reliable page jumping.
- **Page jump fails in OpenInAcrobat**: Ensure the "Page Number" tool is visible in the Acrobat toolbar. The automation relies on finding this UIA element.
- The script looks for a UIA element named `Page Number`
- Different Acrobat versions may have different UI layouts
- Check `GetAcrobatPageBtn()` in `lib/lib.ahk:1117` if issues persist

**WinDjView**:
- Page mark should work; ensure the page field (`Edit1`) is accessible
- Read point search is best-effort and depends on the DjVu text layer and WinDjView's find behavior; use page marks for scanned DjVu

### Read point search fails

- The PDF's text may not match exactly (different encoding, hyphenation, line breaks)
- Try a shorter, more unique selection for the read point
- Consider using page mark instead for problematic PDFs

### Duplicate checking doesn't work

- In readers, `<A-S-d>` requires a selection; without one it shows "Text not found."
- In browsers, `<A-S-d>` can fall back to the current URL.

### "Go to source and try again?" prompt

This appears when the current element's **first HTML component** isn't empty or doesn't contain just a marker (a common cause is typing the PDF title/notes into the source element's HTML). Extraction and marker sync temporarily paste into (and/or rewrite) this component, so the script warns before it proceeds.

Options:
- **Yes**: Navigate to the parent/source element and retry
- **No**: Execute in the current element anyway (marker may conflict with existing content)
- **Cancel**: Abort the operation

For cleanest workflow, keep source elements with empty HTML (or only the marker). Put titles in the element title, and keep notes in a different component if you want to preserve them.
