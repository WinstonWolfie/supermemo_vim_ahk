# References, Tags, and Concepts (SuperMemo + supermemo_vim_ahk)

This guide explains how this repo reads/writes SuperMemo references (`#Link`, `#Title`, etc.), how “tags” work (and where they’re stored), and how tags map to **concept linking** in SuperMemo.

Hotkey notation: `<C-A-s>` means Ctrl+Alt+S (C=Ctrl, A=Alt, S=Shift). See `README.md` for full reference.

---

## Prerequisites

- AutoHotkey v1.1.1+ (or the built `vim_ahk.exe`).
- SuperMemo running, with an element window available (`ahk_class TElWind`).
- Script enabled (tray menu shows enabled).

---

## Quick Start

### 1) Ensure an element has a usable reference link

Fastest workflow (no import needed):

1. Copy a URL to your clipboard.
2. In SuperMemo element window, press `Esc` (browsing mode).
3. Press `:` then `r` (`:r`).

Result: the reference is prepended with `#Link:` (and often other metadata if available).

### 2) Add tags that also link concepts

1. In SuperMemo element window, open Vim Commander: `<C-;>`.
2. Run `Tag`.
3. Enter tags without `#`, separated by `;` (example: `neuro; hippocampus; paper`).
4. Optionally check “Also add to reference comment”.

Result:

- Each tag is linked as a concept (concept registry link).
- Optionally the tags are appended into `#Comment:` as `#tag` tokens.

### 3) Remove tags (untag)

There isn’t a “Untag GUI” in the current workflow. Instead, use Vim Commander’s typed command:

1. Press `<C-;>`.
2. Type: `untag neuro;hippocampus`
3. Press Enter.

Result:

- The concepts are unlinked.
- The `#tag` tokens are removed from `#Comment:` (when applicable).

---

## The SuperMemo reference block (what this repo expects)

Many workflows in this repo rely on SuperMemo’s “reference block” in an element, which typically contains lines like:

- `#SuperMemo Reference:`
- `#Link: ...`
- `#Title: ...`
- `#Source: ...`
- `#Author: ...`
- `#Date: ...`
- `#Comment: ...`

This repo both:

- **Reads** these fields (e.g. to open/copy links from within SuperMemo).
- **Writes** these fields during import, `:r`, tagging, and comment editing.

---

## How `#Link` and `#Comment` are used

### `#Link` powers `gs` / `yy` and many import flows

In SuperMemo browsing mode:

- `gs` opens the element’s `#Link` in your default browser.
- `yy` copies the element’s `#Link` to clipboard.

If an element doesn’t have a `#Link`, those actions can’t work (you’ll see “Link not found.”).

### `#Comment` is where tags live (as hashtags)

When this repo “adds tags to comment”, it stores them inside the reference comment line:

- `#Comment: ... #tag1 #tag2 ...`

Notes:

- Spaces in tag names are converted to `_` for the hashtag form (e.g. `machine learning` → `#machine_learning`).
- The repo also supports links inside `#Comment`; `gm` opens any URLs it finds there.

---

## `:r` — Set reference metadata from clipboard + captured browser info

**Trigger**: in `TElWind`, press `:` then `r`.

What `:r` does (high-level):

1. Opens SuperMemo’s reference editor.
2. Prepends reference fields based on:
   - the current clipboard (URL becomes `#Link:`)
   - any captured browser metadata stored in `Browser.*` (`#Title/#Source/#Author/#Date/#Comment`)
3. Submits the reference change.

Practical guidance:

- If you only want to set the link: copy the desired URL immediately before running `:r`.
- If you previously ran a browser import/capture workflow, `:r` may also fill title/source/author/date/comment based on what was captured.

---

## Tagging and concept linking

### What “link concept” means here

In SuperMemo, linking a concept associates the current element with that concept via the concept registry.

This repo provides:

- `:L` (capital L): link concept (opens concept registry flow)
- Vim Commander `Tag` / `untag ...`: batch link/unlink concepts based on your tag list

### Tagging (link concepts + optional hashtags)

**Trigger**: Vim Commander (`<C-;>`) → `Tag`.

Inputs:

- Tags are separated by `;`
- Enter tags without `#`
- Example: `calculus; limits; epsilon delta`

Effects:

1. Links each tag as a concept (concept registry action).
2. If you check “Also add to reference comment”, it appends `#tag` tokens to `#Comment:`.

### Untagging (unlink concepts + remove hashtags)

**Trigger**: Vim Commander (`<C-;>`) then type:

- `untag tag1;tag2;tag3`

Effects:

1. Unlinks each tag as a concept.
2. Removes the matching `#tag` tokens from `#Comment:` (when present).

---

## Editing `#Comment` directly (reference comment)

If you want to set or replace the entire `#Comment:` line:

1. Press `<C-;>` to open Vim Commander.
2. Run `Comment`.
3. Enter the new comment text.

Tip:

- If you use tags heavily, it’s usually better to use `Tag`/`untag` rather than manually editing `#Comment:` (so concept links stay consistent).

---

## Advanced notes

### URLs with `#...` fragments (SM19 quirks)

SuperMemo 19 can be inconsistent about `#fragment` URLs in certain reference/registry flows. This repo includes special handling for some `#` URLs when writing references.

If you see behavior like:

- link gets truncated at `#`
- reference registry prompts appear unexpectedly

Try:

- Re-run `:r` after copying the URL again.
- Use `#Comment:` to store the full URL for sites you care about (some flows do this automatically for specific domains).

---

## Troubleshooting

- **`gs` / `yy` says “Link not found.”**
  - The element likely has no `#Link:`. Add one with `:r` or re-import from the source.

- **Tagging didn’t add hashtags into `#Comment:`**
  - In the `Tag` GUI, ensure “Also add to reference comment” is checked.

- **I removed a `#tag` manually but it still seems “linked”**
  - Hashtags in `#Comment:` and concept links are separate. Use `untag ...` so the concept link is removed too.

- **Untag didn’t remove a hashtag**
  - Tag names with spaces are stored as underscores in hashtags (`#my_tag`). Use the same base tag text; the script normalizes spaces for hashtag matching.
