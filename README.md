# Cursor Layout Patcher

Restores the full **Change Layout** menu (Agent, Editor, Zen, Browser, toggles, and related options).  
Patches `workbench.desktop.main.js` and updates checksums in `product.json` (and optionally `nls.messages.json`).

## Quick info

- **Reference (old menu still visible):** `C:\Program Files\cursor-old` (if you have it installed).
- **Typical current install (per-user):** `%LOCALAPPDATA%\Programs\cursor`.

**Before patching:** **Quit Cursor completely**, then run `run-patcher.bat` in the matching folder (or run `patcher.ps1` with PowerShell).

---

## Patchers by Cursor version

**Stable (release):** the current **release** version this repo tracks is **3.0.9** → use **`3.0.9.patch.0\`**.

**Nightly (pre / Insiders):** the latest **nightly** (pre) build covered here is **2.7.0-pre.180** → use **`2.7.0-pre.180.patch.0\`**.

There are two “current” patch folders on purpose (different channels). Pick the one that matches your installed `product.json` → `version`.

Sorted with **newest first** below. Folders under `Outdated\` are archived / superseded patch sets; they still work if your installed Cursor version **exactly** matches that row.

| Cursor version | Channel | Status | Folder |
|----------------|---------|--------|--------|
| **3.0.9** | Release (stable) | Current | `3.0.9.patch.0\` |
| **2.7.0-pre.180** | Nightly (pre) | Current | `2.7.0-pre.180.patch.0\` |
| 2.7.0-pre.177 | Nightly | Outdated | `Outdated/2.7.0-pre.177.patch.0\` |
| 2.7.0-pre.176 | Outdated | `Outdated/2.7.0-pre.176.patch.0\` |
| 2.7.0-pre.172 | Outdated | `Outdated/2.7.0-pre.172.patch.0\` |
| 2.7.0-pre.168 | Outdated | `Outdated/2.7.0-pre.168.patch.0\` |
| 2.7.0-pre.162 | Outdated | `Outdated/2.7.0-pre.162.patch.0\` |
| 2.7.0-pre.158 | Outdated | `Outdated/2.7.0-pre.158.patch.0\` |
| 2.7.0-pre.151 | Outdated | `Outdated/2.7.0-pre.151.patch.0\` |
| 2.7.0-pre.148 | Outdated | `Outdated/2.7.0-pre.148.patch.0\` |
| 2.7.0-pre.145 | Outdated | `Outdated/2.7.0-pre.145.patch.0\` |
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

- **Use the patcher that matches your exact Cursor version and channel** (see `product.json` → `version` or *About*): **3.0.9** for the stable release, **2.7.0-pre.180** for the latest nightly build covered here. The wrong patch set may report “Targets not found” or break the workbench bundle.
- **Outdated** only means a newer patch folder exists in this repo for that line; an older folder is still valid if your app is still on that version.
- From **2.7.0-pre.87** onward, stock `buildContent` includes **`appendGlassWindowButton`** (e.g. “Open Glass Window” in newer builds). Current patch sets keep that call at the end of `buildContent`.

---

*A short plain-text summary also lives in `README.txt`.*
