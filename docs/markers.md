# SMVim Markers (read points, page marks, time stamps)

Several workflows in this repo store lightweight "markers" inside a SuperMemo element so that `p` (AutoPlay) and related commands can resume where you left off.

This page defines what those markers are, where they are stored, and the rules the automation expects.

## Where markers are stored

- Markers are written into the element's **first HTML component**.
- The marker must be the **first content line** in that HTML component (top of the HTML).
- If you edit the HTML and move the marker below other content, the script may not detect it reliably.

## Marker types

- `SMVim read point: ...`
  - A short text snippet used for "resume by search" (PDFs, EPUBs, webpages).
- `SMVim page mark: ...`
  - A page number used for "resume by page jump" (PDF/DjVu).
- `SMVim time stamp: ...`
  - A timestamp like `1:23` or `1:02:03` used for "resume by time" (videos, sometimes audio).
- `SMVim: Use online video progress`
  - A YouTube-specific flag meaning "resume using the site's own watch progress" instead of a stored timestamp.

## Precedence / conflicts

- Detection is effectively "first line wins".
- If you have multiple SMVim markers, only the marker that appears first in the HTML is treated as active.
- Recommended: keep **at most one** SMVim marker at the top of the first HTML component.

## How to (re)write a marker

Markers are typically written/updated by the context-sensitive sync hotkeys (e.g. `<A-S-s>`, `<C-A-s>`, `<C-S-A-s>`) when a supported app is focused (browser/PDF reader/mpv/Calibre).

If the script prompts "Go to source and try again?":

- Use a "source element" whose first HTML component is empty (or contains only the SMVim marker).
- Or use import/IWB to create a fresh element, then keep that as the source element for subsequent extracts/markers.

