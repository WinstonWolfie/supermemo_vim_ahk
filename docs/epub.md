# Calibre Quick Start

This is a quick setup guide for using Calibre Ebook Viewer with SuperMemo. For full workflow documentation, see [`docs/readers.md`](readers.md).

## What you need

- Calibre installed (specifically **Ebook Viewer**)
- SuperMemo running with an element window open
- This script running and enabled

## One-time setup: bind highlight to `q`

For auto-highlight to work after extraction, configure Calibre:

1. In Calibre Ebook Viewer, open **Preferences** → **Keyboard shortcuts**
2. Find the action that creates an annotation/highlight
3. Bind it to `q`

Without this binding, extraction still works but Calibre won't mark what you extracted.

## Core hotkeys

All these hotkeys work the same across PDF readers, EPUB readers, etc. See [`docs/readers.md`](readers.md) for full details.

| Hotkey | Action |
|--------|--------|
| `<A-x>` | Extract selection to SuperMemo |
| `<A-S-s>` | Save read point (selected text) |
| `p` (from SuperMemo) | Open file and jump to saved position |

## Workflow summary

1. **Prepare source element**: In SuperMemo, use `<C-;>` → `ImportFile` to attach your `.epub` to the current element
2. **Create a standard SuperMemo reference**: right after import, use SuperMemo's normal reference workflow so the element shows `#SuperMemo Reference:`
3. **Open and read**: Press `p` from SuperMemo to open in Calibre
4. **Extract**: Select text, press `<A-x>`
5. **Save position**: Before closing, select distinctive text and press `<A-S-s>`
6. **Resume**: Return to the element in SuperMemo, press `p`, confirm to search read point

Why step 2 is necessary: `ImportFile` attaches the EPUB, but it does not create the SuperMemo reference block. In the reader workflow, the first extract/read-point sync expects that normal reference-backed state to already exist. 

## EPUB to TXT conversion

Convert EPUB to plain text:

1. Open Vim Commander (`<C-;>`)
2. Run `EPUB2TXT`
3. Enter the path to your `.epub` file

Requires `pandoc` on your `PATH`.

## Full documentation

For extraction variants, priority prompts, marker storage details, and troubleshooting, see [`docs/readers.md`](readers.md).
