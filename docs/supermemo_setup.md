# SuperMemo Setup Prereqs (for supermemo_vim_ahk)

This guide explains the SuperMemo-side setup that the scripts assume. It's intentionally practical: what must exist, why it's required, and what breaks if it doesn't.

If you already use custom template names or concept groups, you can either:
- Create aliases (templates/concepts with the expected names), or
- Edit the script to match your naming. Where names are hardcoded is noted below.

---

## 1) Required templates (hardcoded names)

### A. `binary` (required for `ImportFile`)
Why: The `ImportFile` command sends the template name `binary` before attaching a file.
Used by: PDF/EPUB/DjVu/video source elements, incremental reading, AutoPlay.
Must include:
- HTML component (first HTML component is reserved for SMVim markers)
- Binary component (stores the file)

If missing: `ImportFile` fails or uses the wrong template, and AutoPlay wont open files reliably.

---

### B. `YouTube` (optional, but used by an older Ctrl+N path)
Why: When importing a YouTube URL through that Ctrl+N flow, the script sets template `YouTube`.
If you dont use this flow: you can ignore this.
If you do: create `YouTube` or rename it in the script.

---

### C. `classic` and `item` (optional shortcuts)
Why: `<C-A-p>` converts to template `classic` (authors plain-text template), and `<C-A-i>` converts to `item`.
If you use these shortcuts: create templates with those names or change them in the script.

---

## 2) Concept groups expected by name

Some workflows rely on concept names (hardcoded). The workflow-critical ones are:

- `Online`
- `Sources`

Why it matters:
- `SM.IsOnline(...)` treats `Online` and `Sources` as the concept-level online contexts.
- If you import into `Online`/`Sources`, the script treats it as an online element and expects a Script component.

`ToDo` is also preloaded in the import GUI's concept dropdown, but it is **not** part of `SM.IsOnline(...)` detection.

If `Online`/`Sources` are missing: online-element options wont show correctly or will behave inconsistently.

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
- The top of the first HTML component must stay reserved for the marker.
- For reader/local-file source elements, the simplest setup is an otherwise empty first HTML component.
- For browser/online imports, a reference block or imported content can live below the marker, but dont put your own notes above it.

Why: the automation checks that the marker is still the first detected content. If it isnt, youll see "Go to source and try again?" or have markers ignored/overwritten.

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
   - `Online`, `Sources` (workflow-critical)
   - `ToDo` (optional; only preloaded in the import GUI)

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
