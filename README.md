# Cursor Layout Patcher

Restores the full **Change Layout** menu (Agent, Editor, Zen, Browser, toggles, and related options).  
Patches `workbench.desktop.main.js` and updates checksums in `product.json` (and optionally `nls.messages.json`).

## Quick info

- **Reference (old menu still visible):** `C:\Program Files\cursor-old` (if you have it installed).
- **Typical current install (per-user):** `%LOCALAPPDATA%\Programs\cursor`.

**Before patching:** **Quit Cursor completely**, then run `run-patcher.bat` in the matching folder (or run `patcher.ps1` with PowerShell).

---

## Patchers by Cursor version

Sorted with **newest first**. Folders under `Outdated\` are archived / superseded patch sets; they still work if your installed Cursor version **exactly** matches that row.

| Cursor version | Status | Folder |
|----------------|--------|--------|
| **2.7.0-pre.145** | Current | `2.7.0-pre.145.patch.0\` |
| 2.7.0-pre.140 | Outdated | `Outdated/2.7.0-pre.140.patch.0\` |
| 2.7.0-pre.133 | Outdated | `Outdated/2.7.0-pre.133.patch.0\` |
| 2.7.0-pre.124 | Outdated | `Outdated/2.7.0-pre.124.patch.0\` |
| 2.7.0-pre.119 | Outdated | `Outdated/2.7.0-pre.119.patch.0\` |
| 2.7.0-pre.113 | Outdated | `Outdated/2.7.0-pre.113.patch.0\` |
| 2.7.0-pre.105 | Outdated | `Outdated/2.7.0-pre.105.patch.0\` |
| 2.7.0-pre.87 | Outdated | `Outdated/2.7.0-pre.87.patch.0\` |
| 2.7.0-pre.84 | Outdated | `Outdated/2.7.0-pre.84.patch.0\` |
| 2.7.0-pre.78 | Outdated | `Outdated/2.7.0-pre.78.patch.0\` |
| 2.7.0-pre.73 | Outdated | `Outdated/2.7.0-pre.73.patch.0\` |
| 2.7.0-pre.67 | Outdated | `Outdated/2.7.0-pre.67.patch.0\` |
| 2.7.0-pre.63 | Outdated | `Outdated/2.7.0-pre.63.patch.0\` |
| 2.7.0-pre.61 | Outdated | `Outdated/2.7.0-pre.61.patch.0\` |
| 2.7.0-pre.60 | Outdated | `Outdated/2.7.0-pre.60.patch.0\` |
| 2.7.0-pre.59 | Outdated | `Outdated/2.7.0-pre.59.patch.0\` |
| 2.7.0-pre.55 | Outdated | `Outdated/2.7.0-pre.55.patch.0\` |
| 2.7.0-pre.53 | Outdated | `Outdated/2.7.0-pre.53.patch.0\` |
| 2.7.0-pre.45 | Outdated | `Outdated/2.7.0-pre.45.patch.0\` |
| 2.7.0-pre.43 | Outdated | `Outdated/2.7.0-pre.43.patch.0\` |
| 2.7.0-pre.41 | Outdated | `Outdated/2.7.0-pre.41.patch.0\` |
| 2.7.0-pre.35 | Outdated | `Outdated/2.7.0-pre.35.patch.0\` |
| 2.7.0-pre.31 | Outdated | `Outdated/2.7.0-pre.31.patch.0\` |
| 2.7.0-pre.27 | Outdated | `Outdated/2.7.0-pre.27.patch.0\` |
| 2.7.0-pre.18 | Outdated | `Outdated/2.7.0-pre.18.patch.0\` |
| 2.7.0-pre.17 | Outdated | `Outdated/2.7.0-pre.17.patch.0\` |
| 2.7.0-pre.16 | Outdated | `Outdated/2.7.0-pre.16.patch.0\` |
| 2.7.0-pre.1 | Outdated | `Outdated/2.7.0-pre.1.patch.0\` |
| **2.6.19** | Current | `2.6.19.patch.0\` |
| **2.6.18** | Current | `2.6.18.patch.0\` |
| 2.6.13 | Outdated | `Outdated/2.6.13.patch.0\` |
| 2.6.12 | Outdated | `Outdated/2.6.12.patch.0\` |
| 2.6.8 | Outdated | `Outdated/2.6.8.patch.0\` |
| 2.6.0-pre.43 | Outdated | `Outdated/2.6.0-pre.43.patch.0\` |
| 2.6.0-pre.33 | Outdated | `Outdated/2.6.0-pre.33.patch.0\` |
| 2.5.26 | Outdated | `Outdated/2.5.26\` |
| 2.5.25 | Outdated | `Outdated/2.5.25\` |

### Other (no fixed version in table)

| Description | Files |
|-------------|-------|
| Generic / legacy patcher in the repo root (not tied to a row above) | `patcher.ps1`, `run-patcher.bat` |

---

## Notes

- **Use the patcher that matches your exact Cursor version** (see `product.json` → `version` or *About*). The wrong patch set may report “Targets not found” or break the workbench bundle.
- **Outdated** only means a newer patch folder exists in this repo; an older folder is still valid if your app is still on that version.
- From **2.7.0-pre.87** onward, stock `buildContent` includes **`appendGlassWindowButton`** (e.g. “Open Glass Window” in newer builds). Current patch sets keep that call at the end of `buildContent`.

---

*A short plain-text summary also lives in `README.txt`.*
