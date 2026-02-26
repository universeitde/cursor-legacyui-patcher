# Cursor Layout Menu Patcher



[![Windows 10 | 11](https://img.shields.io/badge/Windows_10_%7C_11-0078D6?style=flat&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Cursor 2.5+ | 2.6.0-pre.43](https://img.shields.io/badge/Cursor_2.5%2B_%7C_2.6.0--pre.43-000000?style=flat&logo=cursor&logoColor=white)](https://cursor.com)
[![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=flat&logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Patched layout menu



Restores the full **Change Layout** menu in Cursor: Agent, Editor, Zen, Browser + toggles removed in newer versions.

**Foreword:** This project restores layout options we miss. We ask Cursor for their understanding and hope these options will be available natively one day. Thank you for the IDE. 

**Updates:** Cursor is currently making massive changes to the editor; if you’re on the latest nightly, the patch may take a bit longer to support your version-we’ll catch up as soon as we can.

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
2. **Pick your Cursor version** – go into the matching folder (e.g. `2.6.0-pre.33.patch.0\`)
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


| Version   | Folder                              | Status   |
| --------- | ----------------------------------- | -------- |
| 2.6.0-pre.43 | `2.6.0-pre.43.patch.0/`          | Tested ✅ |
| 2.6.0-pre | `2.6.0-pre.33.patch.0/`             | Tested ✅ |
| 2.5.25    | `2.5.25/`                           | Tested ✅ |
| …         | *add new version folders as needed* |          |


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