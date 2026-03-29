# SuperMemo Setup Prereqs (for supermemo_vim_ahk)

This guide explains the SuperMemo-side setup that the scripts assume. Its intentionally practical: what must exist, why its required, and what breaks if it doesnt.

If you already use custom template names or concept groups, you can either:
- Create aliases (templates/concepts with the expected names), or
- Edit the script to match your naming. Where names are hardcoded is noted below.

---

## 1) Required templates (names are case-sensitive)

### A. `binary` (required for `ImportFile`)
Why: The `ImportFile` command sets the elements template to `binary` before attaching a file.
Used by: PDF/EPUB/DjVu/video source elements, incremental reading, AutoPlay.
Must include:
- HTML component (first HTML component is reserved for SMVim markers)
- Binary component (stores the file)

If missing: `ImportFile` fails or uses the wrong template, and AutoPlay wont open files reliably.

---

### B. `YouTube` (optional, but used by a specific path)
Why: When importing a YouTube URL through the Ctrl+N flow, the script sets template `YouTube`.
If you dont use this flow: you can ignore this.
If you do: create `YouTube` or rename it in the script.

---

### C. `classic` and `item` (optional shortcuts)
Why: `<C-A-p>` converts to template `classic` (authors plain-text template), and `<C-A-i>` converts to `item`.
If you use these shortcuts: create templates with those names or change them in the script.

---

## 2) Concept groups expected by name

Some workflows rely on concept names (hardcoded). Create these concept groups, or rename in code:

- `Online`
- `Sources`
- `ToDo`

Why it matters:
- The import GUI uses these for online/offline context.
- If you import into `Online`/`Sources`, the script treats it as an online element and expects a Script component.

If missing: online-element options wont show correctly or will behave inconsistently.

---

## 3) Default templates per concept (important for online imports)

When you import as an online element, the script does not explicitly set a template name (except in the YouTube Ctrl+N path). It relies on SuperMemos default template for the selected concept group.

### Recommended defaults
- `Online` / `Sources` concepts: default template must include a Script component
  (because the script writes `rl <url>` into the script editor).
- Offline reading concepts: default template should include HTML (for markers) and optionally binary if you attach files manually.

If missing Script on online concepts: youll see "Script component not found." during import, and AutoPlay wont open web sources reliably.

---

## 4) Source element HTML rules (markers)

Many features (read points, page marks, time stamps, "Use online progress") store markers in the first HTML component of a source element.

Rules:
- The first HTML component must be empty or contain only the marker at the very top.
- Dont put titles or notes in that first HTML component.

Why: The automation checks that the first HTML is clean and that the marker is the first content. If it isnt, youll see "Go to source and try again?" or have markers overwritten.

---

## 5) Script/binary component required for AutoPlay (`p`)

AutoPlay opens external content via `Ctrl+F10`, which triggers:
- a Script component (for URLs), or
- a Binary component (for attached files)

If the element has neither, AutoPlay cant open anything.

---

## 6) Online context detection (collections)

The script also treats certain collections as online contexts (hardcoded list).
Current list: `passive, singing, piano, calligraphy, drawing, bgm, music`.

Why it matters: This changes which import options appear and how the script behaves.
If your online collections have different names, adjust the list in the code.

---

## Quick checklist

1) Templates:
   - `binary` (HTML + binary)
   - `YouTube` (optional)
   - `classic` and `item` (optional shortcuts)

2) Concept groups:
   - `Online`, `Sources`, `ToDo`

3) Default templates:
   - `Online` / `Sources` -> template with Script component

4) Source element rule:
   - First HTML component reserved for markers only

---

## Where these assumptions live (for customization)

If you want to change names instead of creating them:
- Online concepts list and online collections: `lib/sm.ahk`
- Import GUI concept lists: `lib/bind/smvim_import.ahk`
- `ImportFile` uses `binary`: `lib/bind/vim_command.ahk`
- Plain-text shortcut uses `classic`: `lib/bind/smvim_shortcut.ahk`
- Item shortcut uses `item`: `lib/bind/smvim_shortcut.ahk`

