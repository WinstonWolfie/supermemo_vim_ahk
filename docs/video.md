# Incremental Video Workflows (SuperMemo + supermemo_vim_ahk)

This guide covers incremental video with SuperMemo: importing or linking a video, syncing your current playback time back into SuperMemo, and resuming later.

It covers both YouTube videos (in a browser) and local video files (e.g. via `mpv`).

Hotkey notation: `<C-A-s>` means Ctrl+Alt+S (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

## Quick Start

### What you need

- SuperMemo running (SM15-SM19)
- This script running and enabled (check tray icon)
- A video source:
  - YouTube in a supported browser (UI Automation), or
  - A local video file opened in `mpv` (recommended)

### Step 1: Create a source element

Create one SuperMemo element that represents the video. The element should have an HTML component (for markers).

- **YouTube**: see [YouTube](#youtube).
- **Local file**: see [Local Files](#local-files).

### Step 2: Start watching

Open the video from SuperMemo (or open it first, then import/link it).

### Step 3: Sync your place before leaving

While your browser tab (or `mpv`) is focused, sync a time stamp back into the source element:

- `<A-S-s>`: sync time stamp (keep browser/player open)
- `<C-A-s>`: sync time stamp and close browser/player
- `<C-S-A-s>`: sync time stamp and keep learning (return to SuperMemo and continue)

To clear a time stamp (set to `0:00`), use the Backtick variants:

- `<A-S-Backtick>` / `<C-A-Backtick>` / `<C-S-A-Backtick>`

### Step 4: Resume later

Navigate to the source element in SuperMemo and use:

- `p`: AutoPlay (open and resume based on the element's active marker)
- `P`: play in default system player / edit script component (useful for file/script-backed elements)

That's it! The sections below provide full details on each workflow.

---

## Prerequisites

- AutoHotkey v1.1.1+ (or the built `vim_ahk.exe`)
- SuperMemo running (SM15-SM19 are grouped as `ahk_group SM`)
- One of the following video sources:

| Source | Detection | Notes |
|--------|-----------|-------|
| YouTube (browser) | UI Automation (`UIA_Browser`) | Time detection can be sensitive to browser UI language/layout |
| Local file (`mpv`) | Clipboard time capture (optional) | Best results with an `mpv` time-copy script bound to `<C-c>` |

Marker storage/detection is shared across workflows; see `docs/markers.md` for details.

## Setup

### Make sure the script is enabled

Many workflows are gated by `Vim.State.Vim.Enabled`. If nothing happens, confirm the tray menu shows the script as enabled.

### Understand how video "markers" work

Video workflows store state in the source element's first HTML component, as the first content line:

- `SMVim time stamp: 1:23`
- `SMVim: Use online video progress` (YouTube-only)

Only the first marker is treated as active; avoid keeping multiple SMVim markers at the top of the same element (see `docs/markers.md`).

### Optional: configure mpv to copy the current time to the clipboard

When `mpv` is focused, the sync flow can try to read the current playback time by triggering a copy action and parsing the clipboard.

For best results:

- Install an `mpv` script that copies the current playback time to the clipboard.
- Bind it so that pressing `<C-c>` in `mpv` copies something like `01:23`.

Accepted clipboard formats (the script normalizes these):

- `1:23` / `01:23`
- `1:02:03` / `01:02:03`
- `1:23.456` (fractional seconds are trimmed)

Quick check:

1. Focus `mpv` and press `<C-c>`.
2. Paste into Notepad: you should see a timestamp (not a filename or URL).

If this is not configured (or times out), you'll see:

- `mpv-copyTime script not installed or timed out.`

and the script will prompt you to type the time stamp manually.

## Workflow: Incremental video (sync / clear time stamp)

These hotkeys work while your browser (or `mpv`) is focused, as long as SuperMemo is open with an element window available.

### Sync time stamp

- `<C-A-s>`: sync time stamp and close the tab/window
- `<A-S-s>`: sync time stamp and keep the tab/window open
- `<C-S-A-s>`: sync time stamp and keep learning

### Clear time stamp (set to `0:00`)

- `<C-A-Backtick>`: clear time stamp and close the tab/window
- `<A-S-Backtick>`: clear time stamp and keep the tab/window open
- `<C-S-A-Backtick>`: clear time stamp and keep learning

### What "sync" updates in SuperMemo

Depending on the element and the active video source, sync updates one of:

- A top-of-HTML marker: `SMVim time stamp: 1:23`
- For some YouTube/online templates, the Script component URL (e.g. add/update `&t=123s`)

If the script can't reliably read the time stamp, it prompts you to type it.

## YouTube

### Import the current YouTube video into SuperMemo

Context: browser focused; SuperMemo open with an element window.

- `<C-S-A-a>`: open the import GUI (priority, concept, tags, comment, etc.)
- `<C-A-a>`: fast import using defaults

If you use the GUI, YouTube-relevant options include:

- Import as online element (enables Script component URL workflow)
- Reset time stamp (start from `0:00`)
- Mark as use online progress (inserts `SMVim: Use online video progress`)

After import, you should get a SuperMemo element whose reference includes at least:

- `#Link: https://youtube.com/watch?v=...`
- `#Title: ...`

### Decide how you want to resume YouTube videos

Pick one resume mode per element:

- **Mode 1: time stamps (marker or Script URL `&t=`)**
  - Deterministic: your resume is based on the time you last synced.
  - Works best when imported as an online element (Script component with `url ...`).

- **Mode 2: YouTube's own watch progress**
  - Add the marker `SMVim: Use online video progress` (and keep it as the first marker).
  - When you play from SuperMemo, the script searches YouTube and opens the matching video, letting YouTube resume based on your account progress.

### Play/resume from SuperMemo

Context: SuperMemo element window focused (browsing mode, not editing text).

- `p`: runs SuperMemo's play action (`SM.AutoPlay()`)
  - If the active marker is `SMVim: Use online video progress`, it opens the video in your browser via a YouTube search and lets YouTube resume.
  - Otherwise it triggers SuperMemo's default play behavior for the element (often using the element's `#Link` / Script component).
- `P`: play in default system player / edit script component

### Mark an existing element as "use online video progress"

Context: SuperMemo element window focused; open Vim Commander (`<C-;>`).

1. Run `MarkAsOnlineProgress`.
2. The script inserts `SMVim: Use online video progress` at the top of the element's first HTML component.

### Handy YouTube helpers (Vim Commander)

- `yt <query>`: open YouTube search results
- `SearchLinkInYT`: search YouTube and try to click the current element's `#Link`
- `WatchLaterYT`: open your Watch Later playlist

## Local Files

### Create a source element for a local video

Context: SuperMemo focused; open Vim Commander (`<C-;>`).

1. Run `ImportFile`.
2. Follow the prompts.

This expects you have a SuperMemo template named `binary` (see `lib/bind/vim_command.ahk:580`).

### Open the local video from SuperMemo

Context: SuperMemo element window focused (browsing mode, not editing text).

- `P`: open the file ("View file") using your default system player
- `p`: SuperMemo AutoPlay (`SM.AutoPlay()` / `<C-F10>`)

Windows file associations determine which player opens the file (recommended: `mpv`).

### Note on resuming local files

The stored time stamp is primarily for "save your place" and display/copy. There is currently no reliable automatic "seek mpv to this time" step when reopening the file.

## Quick Reference

### From browser / mpv (SuperMemo must be open)

| Hotkey | Action |
|--------|--------|
| `<A-S-s>` | Sync time stamp (keep open) |
| `<C-A-s>` | Sync time stamp (close) |
| `<C-S-A-s>` | Sync time stamp and keep learning |
| `<A-S-Backtick>` | Clear time stamp (keep open) |
| `<C-A-Backtick>` | Clear time stamp (close) |
| `<C-S-A-Backtick>` | Clear time stamp and keep learning |

### From SuperMemo (browsing mode)

| Hotkey | Action |
|--------|--------|
| `p` | AutoPlay - open/resume video |
| `P` | View file / edit Script component |
| `<A-s>` | Copy marker content (time stamp, etc.) if present |

### From Vim Commander (SuperMemo)

| Command | Action |
|--------|--------|
| `ImportFile` | Create a source element for a local file |
| `MarkAsOnlineProgress` | Insert `SMVim: Use online video progress` marker |
| `yt <query>` | Open YouTube search |
| `WatchLaterYT` | Open Watch Later playlist |

## Troubleshooting

### Hotkeys do nothing

- Confirm the script is enabled (tray menu).
- Outside-SuperMemo video hotkeys require SuperMemo to be open with an element window (`ahk_class TElWind`).

### Sync updates the wrong element

- Keep the intended source element open while syncing.
- If you have multiple element windows:
  - For YouTube, the script may try to match by title/link and can prompt when mismatched.
  - For local files (e.g. `mpv`), sync does not match by filename; it updates the currently targeted SuperMemo element window.

### AutoPlay doesn't see the marker

- The marker is only detected if it's the first content in the first HTML component. If you've edited the HTML, re-sync so the marker is rewritten at the top.
- Avoid keeping multiple SMVim markers at the top of the same element (first line wins).

### YouTube time stamp not detected

- Click the YouTube player once so the controls/state are exposed to accessibility.
- If your browser UI language isn't English, the UIA pattern may not match; use the manual time stamp prompt.

### "mpv-copyTime script not installed or timed out."

- Install/configure an mpv time-copy script and bind it to `<C-c>`, or type the time stamp when prompted.

### "use online video progress" doesn't work

- Ensure `SMVim: Use online video progress` is the first content in the first HTML component (first line wins).
- Remove or move any `SMVim time stamp: ...` marker above it, or the script will treat the time stamp as active.
