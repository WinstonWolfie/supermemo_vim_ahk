# SMVim Markers (read points, page marks, time stamps)

Several workflows in this repo store lightweight "markers" inside a SuperMemo element so that `p` (AutoPlay) and related commands can resume where you left off.

This page defines what those markers are, where they are stored, and the rules the automation expects.

## Where markers are stored

- Markers are written into the element's **first HTML component**.
- The marker must be the **first detected text item** at the top of that HTML component.
- Detection is stricter than a casual "first line wins" rule: the code only inspects the first UIA text item, and if that first detected item is not an SMVim marker, marker detection stops.

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

- Only the first detected SMVim marker is treated as active.
- If some other text comes before the marker, the marker is ignored.
- Recommended: keep **at most one** SMVim marker at the very top of the first HTML component.

## How to (re)write a marker

Markers are typically written/updated by the context-sensitive sync hotkeys (for example `<A-S-s>`, `<C-A-s>`, `<C-S-A-s>`) when a supported app is focused (browser/PDF reader/mpv/Calibre).

If the script prompts "Go to source and try again?":

- Keep the top of the first HTML component clean enough for marker updates.
- For reader/local-file source elements, the simplest setup is an otherwise empty first HTML component with only the marker at the top.
- For browser/online elements, a reference block or imported content can exist **below** the marker, but nothing should appear above it.
