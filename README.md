# Cursor Layout Menu Patcher

<div align="center">

[![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat-square&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat-square&logo=powershell&logoColor=white)](https://docs.microsoft.com/powershell)
[![Cursor](https://img.shields.io/badge/Cursor%20Stable%202.5.25-000000?style=flat-square&logo=cursor)](https://cursor.com)
[![VS Code](https://img.shields.io/badge/VS%20Code-1.105.1-007ACC?style=flat-square&logo=visualstudiocode)](https://code.visualstudio.com)
[![Electron](https://img.shields.io/badge/Electron-39.4.0-47848F?style=flat-square&logo=electron)](https://electronjs.org)
[![Node](https://img.shields.io/badge/Node.js-22.22.0-339933?style=flat-square&logo=nodedotjs)](https://nodejs.org)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](https://opensource.org/licenses/MIT)

![Patched layout menu](https://raw.githubusercontent.com/universeitde/cursor-legacyui-patcher/refs/heads/main/assets/patched_screenshot.png)

</div>

Restores the full **Change Layout** menu in Cursor: Agent, Editor, Zen, Browser + toggles removed in newer versions.

**Foreword:** This project restores layout options we miss. We ask Cursor for their understanding and hope these options will be available natively one day. Thank you for the IDE.

## Features

- **Presets**: Agent, Editor, Zen, Browser
- **Toggles**: Agents, Chat, Editors, Panel, Sidebar, Status Bar
- **Agent Sidebar** position (Left/Right)
- **Settings** shortcut + **Add** btn

## Requirements

- **Windows** (PowerShell)
- **Cursor** installed (`%LOCALAPPDATA%\Programs\cursor` or `C:\Program Files\cursor`)
- Patches in-place, no extra deps

## Quick Start

1. **Close Cursor** completely (check Task Manager)
2. **Pick your Cursor version** – go into the matching folder (e.g. `2.5.22\`)
3. **Run** `run-patcher.bat` (or `.\patcher.ps1`)
4. **Start Cursor**, gear icon top right → full layout menu

Admin only needed for system install (`C:\Program Files\cursor`). User install (`%LOCALAPPDATA%\Programs\cursor`) runs without elevation.

> **Version note**: Use the patcher from the folder that matches your Cursor version. If your version has no folder yet, an existing one may work, but it is untested.

## Options

```powershell
# Restore original
.\patcher.ps1 -Restore

# Custom path
.\patcher.ps1 -Path "D:\Tools\Cursor"
```

## Supported Versions

| Version | Folder | Status |
|---------|--------|--------|
| 2.5.22 | `2.5.22/` | Tested |
| … | *add new version folders as needed* | |

## Technical Details

- **Target**: `resources\app\out\vs\workbench\workbench.desktop.main.js`
- **Backup**: `workbench.desktop.main.js.backup.{timestamp}` auto-created
- **Auto-updates**: Patcher offers to disable. Cursor re-downloads on checksum mismatch. Re-enable in settings or delete `update.mode` from `%APPDATA%\Cursor\User\settings.json`.
- **"Corrupt" dialog**: Swapped for *"Layout Patcher active. Checksums modified. No reinstall needed. Leave a star on GitHub <3"*

## After Updates

Cursor updates overwrite the patch. Just run the patcher again.

## Troubleshooting

If problems occur: **reinstall Cursor** – this fixes most issues.

## Contributing

Contributions are welcome. Possible ways to help:

- **Pull requests** – fixes, improvements, or support for new Cursor versions (e.g. new version folders with updated patch patterns).
- **Port to macOS** – this patcher is Windows-only; a Mac port (e.g. shell script or small app) would be a great addition.
- **Docs, issues, ideas** – open an issue to discuss or suggest something.

Fork the repo, make your changes, and open a pull request. Please keep version-specific logic in the matching version folder.

## Thanks

Thank you to [Cursor](https://cursor.com) for the IDE — we really appreciate it. We hope you’ll understand this patcher; we’d love to see these layout options and the checksum handling as native settings instead.

## Disclaimer

Use at your own risk. Not official Cursor.
