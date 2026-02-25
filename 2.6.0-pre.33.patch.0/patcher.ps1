<#
.SYNOPSIS
    Cursor Layout Menu Patcher - Restores the full "Change Layout" menu
    (Agent, Editor, Zen, Browser + all toggles).

.DESCRIPTION
    Patches the workbench.desktop.main.js in-place to disable the
    "hide_layout_extended" feature gate that hides Zen/Browser presets
    and all individual toggle switches.

    Also updates the checksum in product.json so Cursor accepts the
    patched file.

.PARAMETER Restore
    Restore the backup instead of applying the patch.

.PARAMETER Path
    Custom path to Cursor installation (default: C:\Program Files\cursor).

.EXAMPLE
    .\patcher.ps1
    Patch the current Cursor installation.

.EXAMPLE
    .\patcher.ps1 -Restore
    Restore the original file from backup.

.EXAMPLE
    .\patcher.ps1 -Path "D:\Tools\Cursor"
    Patch a custom Cursor installation path.
#>

param(
    [switch]$Restore,
    [string]$Path = ""
)

# no -Path? auto-detect installs and run for each
if ([string]::IsNullOrWhiteSpace($Path)) {
    function Get-DetectedCursorInstallations {
        $candidates = @(
            (Join-Path $env:LOCALAPPDATA "Programs\cursor"),
            "C:\Program Files\cursor"
        ) | Select-Object -Unique

        $detected = @()
        foreach ($candidate in $candidates) {
            $workbench = Join-Path $candidate "resources\app\out\vs\workbench\workbench.desktop.main.js"
            $product = Join-Path $candidate "resources\app\product.json"
            if ((Test-Path $workbench) -and (Test-Path $product)) {
                $detected += $candidate
            }
        }
        return $detected
    }

    $installs = Get-DetectedCursorInstallations
    if ($installs.Count -eq 0) {
        Write-Host "ERROR: No Cursor installation found in common paths." -ForegroundColor Red
        Write-Host "Tried:" -ForegroundColor Yellow
        Write-Host "  - $env:LOCALAPPDATA\Programs\cursor" -ForegroundColor Yellow
        Write-Host "  - C:\Program Files\cursor" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "Detected Cursor installations:" -ForegroundColor Cyan
    foreach ($install in $installs) {
        Write-Host "  - $install" -ForegroundColor Gray
    }
    Write-Host ""

    $hadFailure = $false
    foreach ($install in $installs) {
        Write-Host "=======================================" -ForegroundColor Cyan
        Write-Host " Processing: $install" -ForegroundColor Cyan
        Write-Host "=======================================" -ForegroundColor Cyan

        $args = @("-ExecutionPolicy", "Bypass", "-File", $PSCommandPath, "-Path", $install)
        if ($Restore) { $args += "-Restore" }

        & powershell @args
        if ($LASTEXITCODE -ne 0) {
            $hadFailure = $true
            Write-Host "FAILED for: $install (exit code $LASTEXITCODE)" -ForegroundColor Red
        } else {
            Write-Host "Done for: $install" -ForegroundColor Green
        }
        Write-Host ""
    }

    if ($hadFailure) { exit 1 }
    exit 0
}

$ErrorActionPreference = "Stop"
$TargetDir = Join-Path $Path "resources\app\out\vs\workbench"
$TargetFile = Join-Path $TargetDir "workbench.desktop.main.js"
$ProductJsonFile = Join-Path $Path "resources\app\product.json"
$NlsMessagesFile = Join-Path $Path "resources\app\out\nls.messages.json"
$BackupPattern = "workbench.desktop.main.js.backup.*"
$ProductBackupPattern = "product.json.backup.*"
$NlsBackupPattern = "nls.messages.json.backup.*"
$BootstrapDir = Join-Path $Path "resources\app\out\vs\code\electron-sandbox\workbench"
$BootstrapFile = Join-Path $BootstrapDir "workbench.js"
$BootstrapBackupPattern = "workbench.js.backup.*"

# workbench patches: force new layout style, unlock Zen/Browser + toggles
# same-length patches preserve source maps; AllowLengthMismatch=true patches are for 2.6+ structural changes

# nls: swap "corrupt" dialog text
$NlsCorruptPatch = @{
    Search  = '"Your {0} installation appears to be corrupt. Please reinstall."'
    Replace = '"Layout Patcher active. Checksums modified. No reinstall needed. Leave a star on GitHub <3"'
}

# 2.5.x patches (same-length)
$Patches = @(
    @{
        Name    = "useLegacyLayoutStyle"
        Search  = 'useLegacyLayoutStyle(){return this.chatEditorGroupService!==void 0}'
        Replace = 'useLegacyLayoutStyle(){return!1/*patched:force new style*/        }'
    },
    @{
        Name    = "shouldHideExtendedLayoutControls"
        Search  = 'shouldHideExtendedLayoutControls(){return this.experimentService.checkFeatureGate("hide_layout_extended")}'
        Replace = 'shouldHideExtendedLayoutControls(){return!1/*patched:unlock full layout menu*/                           }'
    },
    @{
        Name    = "hide_layout_extended_direct"
        Search  = 'de=bb("hide_layout_extended")'
        Replace = 'de=()=>!1/*patched:ext     */'
    },
    @{
        Name    = "hide_layout_extended_config"
        Search  = 'hide_layout_extended:{client:!0,default:!1}'
        Replace = 'hide_layout_extended:{client:!1,default:!1}'
    },
    # 2.6.x patches
    @{
        Name    = "hide_layout_extended_config_2_6"
        Search  = 'hide_layout_extended:{client:!0,default:!0}'
        Replace = 'hide_layout_extended:{client:!1,default:!1}'
    },
    @{
        # Makes determineLayoutMatch() recognise Zen/Browser as default presets (same-length: Bfw == LNa)
        Name    = "getDefaultLayouts_LNa"
        Search  = 'getDefaultLayouts(){return Bfw}'
        Replace = 'getDefaultLayouts(){return LNa}'
    },
    @{
        # Adds Zen + Browser tiles to the mode-grid in renderModeGrid() (2.6: only Agent+Editor were rendered)
        Name                = "renderModeGrid_zen_browser"
        AllowLengthMismatch = $true
        Search  = 'this.modeGridElement.appendChild(s)}updateAddButtonVisibility'
        Replace = 'this.modeGridElement.appendChild(s);const X2=LNa[2],X3=LNa[3];const Z0=this.createModeOption({label:_(2961,null),isSelected:n.type==="default"&&n.layout.id==="default-zen",renderIcon:o=>this.renderZenModeIcon(o),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:"zen"}),this.updateTileSelection(null,"zen"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(X2),this.refreshToggleStates()}});this.modeGridElement.appendChild(Z0);const B0=this.createModeOption({label:_(2962,null),isSelected:n.type==="default"&&n.layout.id==="default-browser",renderIcon:o=>this.renderBrowserModeIcon(o),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:"browser"}),this.updateTileSelection(null,"browser"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(X3),this.refreshToggleStates()}});this.modeGridElement.appendChild(B0)}updateAddButtonVisibility'
    },
    @{
        # Restores toggle rows (Agents/Chat/Editors/Panel/Sidebar + Sidebar Position) to buildContent()
        # In 2.6 Cursor stripped buildContent() down to just the 2-tile grid + settings link.
        Name                = "buildContent_toggles"
        AllowLengthMismatch = $true
        Search  = 'buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage();const e=this.createModeToggle();n.appendChild(e),n.appendChild(this.createDivider()),this.appendCursorSettingsButton(n)}'
        Replace = 'buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage();const e=this.createModeToggle();n.appendChild(e),n.appendChild(this.createDivider());const i=this.createSection(n);const s=this.createToggleRow({label:"Agents",getValue:()=>this.layoutService.isVisible("workbench.parts.unifiedsidebar"),onToggle:p=>this.setAgentsVisible(p)});this.agentsToggleWrapperElement=s,i.appendChild(s),i.appendChild(this.createToggleRow({label:"Chat",getValue:()=>this.isAgentLayoutActive()&&this.chatEditorGroupService?this.chatEditorGroupService.hasVisibleChat():this.layoutService.isVisible("workbench.parts.auxiliarybar"),onToggle:async p=>{this.isAgentLayoutActive()&&this.chatEditorGroupService?this.chatEditorGroupService.hasVisibleChat()!==p&&(p?this.chatEditorGroupService.getHiddenChatComposerIds().length>0?(await this.chatEditorGroupService.showChatEditorGroup(),this.layoutService.setPartHidden(!1,"workbench.parts.auxiliarybar")):await this.commandService.executeCommand("workbench.action.toggleAuxiliaryBar"):await this.chatEditorGroupService.hideChatEditorGroup()):await this.ensureCommandState(p,()=>this.layoutService.isVisible("workbench.parts.auxiliarybar"),"workbench.action.toggleAuxiliaryBar")}}));const o=this.createToggleRow({label:"Editors",getValue:()=>this.layoutService.isVisible("workbench.parts.editor",Bi),onToggle:p=>this.setEditorsVisible(p)});this.editorsToggleWrapperElement=o,i.appendChild(o),i.appendChild(this.createToggleRow({label:"Panel",getValue:()=>this.layoutService.isVisible("workbench.parts.panel"),onToggle:p=>this.ensureCommandState(p,()=>this.layoutService.isVisible("workbench.parts.panel"),"workbench.action.togglePanel")})),i.appendChild(this.createToggleRow({label:"Sidebar",getValue:()=>this.layoutService.isVisible("workbench.parts.sidebar"),onToggle:p=>this.ensureCommandState(p,()=>this.layoutService.isVisible("workbench.parts.sidebar"),"workbench.action.toggleSidebarVisibility")})),n.appendChild(this.createDivider());const a=this.createSection(n);a.appendChild(this.createSubmenuRow({label:this.getSidebarPositionLabel(),getValue:()=>this.getSidebarLocation(),options:this.getSidebarPositionOptionDefinitions(),onSelect:async p=>{this.isAgentLayoutActive()?await this.agentLayoutService.setUnifiedSidebarLocation(p):await this.setSidebarPositionForCurrentWindow(p),this.updateSidebarPositionOptions(),this.renderModeGrid()},registerOption:p=>this.sidebarPositionOptions.push(p),onValueElementCreated:p=>this.sidebarPositionValueElement=p,onLabelElementCreated:p=>this.sidebarPositionLabelElement=p})),a.appendChild(this.createDivider()),this.appendCursorSettingsButton(n)}'
    }
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    if ([string]::IsNullOrEmpty($Color)) { $Color = "White" }
    Write-Host $Message -ForegroundColor $Color
}

function Test-CursorNotRunning {
    $processes = Get-Process -Name "Cursor" -ErrorAction SilentlyContinue
    if ($processes) {
        Write-ColorOutput "ERROR: Cursor is still running. Please close Cursor completely first." "Red"
        Write-ColorOutput "Tip: Check Task Manager for 'Cursor' processes (there may be several)." "Yellow"
        exit 1
    }
}

function Get-LatestBackup {
    param([string]$Dir, [string]$Pattern)
    $backups = Get-ChildItem -Path $Dir -Filter $Pattern -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending
    if ($backups.Count -eq 0) { return $null }
    return $backups[0]
}

function Get-WorkbenchBackupWithPatchTargets {
    param([string]$Dir, [string]$Pattern)

    $backups = Get-ChildItem -Path $Dir -Filter $Pattern -ErrorAction SilentlyContinue |
        Sort-Object @{ Expression = "Length"; Descending = $true }, @{ Expression = "LastWriteTime"; Descending = $true }

    foreach ($backup in $backups) {
        try {
            $content = [System.IO.File]::ReadAllText($backup.FullName, [System.Text.Encoding]::UTF8)
            # valid for 2.5 (has shouldHideExtendedLayoutControls) OR 2.6 (has getDefaultLayouts/buildContent_toggles target)
            if ($content.Contains("hide_layout_extended") -and (
                $content.Contains("shouldHideExtendedLayoutControls") -or
                $content.Contains("getDefaultLayouts(){return") -or
                $content.Contains("buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage()")
            )) {
                return $backup
            }
        }
        catch {
            continue
        }
    }

    return $null
}

function Compute-FileChecksum {
    param([string]$FilePath)
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hash = $sha256.ComputeHash($bytes)
    $sha256.Dispose()
    $b64 = [System.Convert]::ToBase64String($hash)
    # base64url: + -> -, / -> _, strip =
    $b64url = $b64.Replace('+', '-').Replace('/', '_').TrimEnd('=')
    return $b64url
}

function Update-ProductJsonChecksum {
    param(
        [string]$ChecksumKey,
        [string]$NewChecksum
    )

    $productContent = [System.IO.File]::ReadAllText($ProductJsonFile, [System.Text.Encoding]::UTF8)

    $escapedKey = [regex]::Escape($ChecksumKey)
    $pattern = "(`"$escapedKey`"\s*:\s*`")[^`"]*(`")"
    $replacement = "`${1}$NewChecksum`${2}"

    $newContent = [regex]::Replace($productContent, $pattern, $replacement)

    if ($newContent -eq $productContent) {
        Write-ColorOutput "WARNING: Could not find checksum for '$ChecksumKey' in product.json." "Yellow"
        return $false
    }

    [System.IO.File]::WriteAllText($ProductJsonFile, $newContent, [System.Text.UTF8Encoding]::new($false))
    return $true
}

function Request-DisableAutoUpdates {
    Write-Host ""
    Write-ColorOutput "If auto-updates stay enabled, Cursor will re-download when it detects corruption." "Yellow"
    do {
        $response = Read-Host "Disable auto-updates? (y/n)"
        $r = $response.Trim().ToLowerInvariant()
    } while ($r -ne "y" -and $r -ne "n" -and $r -ne "yes" -and $r -ne "no")
    return ($r -eq "y" -or $r -eq "yes")
}

function Set-CursorUpdateSettings {
    # patched checksums = "corrupt" to Cursor -> it re-downloads. disable updates.
    $settingsPath = Join-Path $env:APPDATA "Cursor\User\settings.json"
    $settingsDir = Split-Path $settingsPath -Parent
    if (-not (Test-Path $settingsDir)) {
        New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
    }

    $obj = $null
    if (Test-Path $settingsPath) {
        try {
            $content = [System.IO.File]::ReadAllText($settingsPath, [System.Text.Encoding]::UTF8)
            $obj = $content | ConvertFrom-Json -ErrorAction Stop
        } catch {
            $obj = New-Object PSObject
        }
    }
    if (-not $obj) { $obj = New-Object PSObject }

    $obj | Add-Member -NotePropertyName "update.mode" -NotePropertyValue "none" -Force
    $obj | Add-Member -NotePropertyName "update.enableWindowsBackgroundUpdates" -NotePropertyValue $false -Force
    $json = $obj | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($settingsPath, $json, [System.Text.UTF8Encoding]::new($false))
}

function Update-ProductJsonChecksumWithFallback {
    param(
        [string[]]$ChecksumKeys,
        [string]$NewChecksum,
        [string]$DisplayName
    )

    foreach ($key in $ChecksumKeys) {
        if (Update-ProductJsonChecksum -ChecksumKey $key -NewChecksum $NewChecksum) {
            if ($key -ne $ChecksumKeys[0]) {
                Write-ColorOutput "Note: Updated fallback checksum key '$key' for $DisplayName." "Yellow"
            }
            return $true
        }
    }

    Write-ColorOutput "WARNING: Could not update checksum for '$DisplayName'." "Yellow"
    return $false
}

function Get-PatchClassification {
    param([string]$Content)

    $result = @{
        ToApply        = @()
        AlreadyApplied = @()
        Broken         = @()
    }

    foreach ($p in $Patches) {
        if ($Content.Contains($p.Replace)) {
            $result.AlreadyApplied += $p.Name
        }
        elseif ($Content.Contains($p.Search)) {
            $result.ToApply += $p
        }
        else {
            $result.Broken += $p.Name
        }
    }

    return $result
}

# --- RESTORE ---
function Invoke-Restore {
    Write-ColorOutput "=== Cursor Layout Patcher - Restore ===" "Cyan"
    Write-ColorOutput ""

    if (-not (Test-Path $TargetDir)) {
        Write-ColorOutput "ERROR: Cursor installation not found at: $Path" "Red"
        exit 1
    }

    Test-CursorNotRunning

    $wbBackup = Get-LatestBackup -Dir $TargetDir -Pattern $BackupPattern
    if (-not $wbBackup) {
        Write-ColorOutput "ERROR: No workbench backup found in: $TargetDir" "Red"
        exit 1
    }

    Write-ColorOutput "Restoring workbench from: $($wbBackup.Name)" "Yellow"
    try {
        Copy-Item -Path $wbBackup.FullName -Destination $TargetFile -Force
        Write-ColorOutput "Restored workbench.desktop.main.js" "Green"

        # product.json
        $pjDir = Split-Path $ProductJsonFile -Parent
        $pjBackup = Get-LatestBackup -Dir $pjDir -Pattern $ProductBackupPattern
        if ($pjBackup) {
            Copy-Item -Path $pjBackup.FullName -Destination $ProductJsonFile -Force
            Write-ColorOutput "Restored product.json" "Green"
        }

        # nls
        $nlsDir = Split-Path $NlsMessagesFile -Parent
        $nlsBackup = Get-LatestBackup -Dir $nlsDir -Pattern $NlsBackupPattern
        if ($nlsBackup -and (Test-Path $NlsMessagesFile)) {
            Copy-Item -Path $nlsBackup.FullName -Destination $NlsMessagesFile -Force
            Write-ColorOutput "Restored nls.messages.json" "Green"
        }

        Write-ColorOutput ""
        Write-ColorOutput "Successfully restored. You can now start Cursor." "Green"
    }
    catch {
        Write-ColorOutput "ERROR: $($_.Exception.Message)" "Red"
        Write-ColorOutput "Run the script as Administrator." "Yellow"
        exit 1
    }
}

# --- PATCH ---
function Invoke-Patch {
    Write-ColorOutput "=== Cursor Layout Menu Patcher ===" "Cyan"
    Write-ColorOutput "Patches useLegacyLayoutStyle + hide_layout_extended to unlock the full menu." "Gray"
    Write-ColorOutput ""

    if (-not (Test-Path $TargetFile)) {
        Write-ColorOutput "ERROR: Workbench file not found: $TargetFile" "Red"
        exit 1
    }
    if (-not (Test-Path $ProductJsonFile)) {
        Write-ColorOutput "ERROR: product.json not found: $ProductJsonFile" "Red"
        exit 1
    }

    Test-CursorNotRunning

    Write-ColorOutput "Reading workbench.desktop.main.js..." "Gray"
    $content = [System.IO.File]::ReadAllText($TargetFile, [System.Text.Encoding]::UTF8)
    $fileSize = (Get-Item $TargetFile).Length
    Write-ColorOutput "File size: $([math]::Round($fileSize / 1MB, 1)) MB" "Gray"

    $classification = Get-PatchClassification -Content $content
    $patchesToApply = $classification.ToApply
    $alreadyApplied = $classification.AlreadyApplied
    $broken = $classification.Broken

    foreach ($name in $alreadyApplied) {
        Write-ColorOutput "  Already patched: $name" "Gray"
    }

    # bundled/old workbench overwrote us? recover from backup that has patch targets
    $looksLikeBundledMismatch = ($patchesToApply.Count -eq 0 -and $broken.Count -gt 0 -and ($alreadyApplied -contains "useLegacyLayoutStyle"))
    if ($looksLikeBundledMismatch) {
        $recoveryBackup = Get-WorkbenchBackupWithPatchTargets -Dir $TargetDir -Pattern $BackupPattern
        if ($recoveryBackup) {
            Write-ColorOutput "" 
            Write-ColorOutput "Detected incompatible bundled/old workbench. Recovering from backup..." "Yellow"
            Copy-Item -Path $recoveryBackup.FullName -Destination $TargetFile -Force
            Write-ColorOutput "Recovered: $($recoveryBackup.Name)" "Green"

            $content = [System.IO.File]::ReadAllText($TargetFile, [System.Text.Encoding]::UTF8)
            $fileSize = (Get-Item $TargetFile).Length
            Write-ColorOutput "Recovered file size: $([math]::Round($fileSize / 1MB, 1)) MB" "Gray"

            $classification = Get-PatchClassification -Content $content
            $patchesToApply = $classification.ToApply
            $alreadyApplied = $classification.AlreadyApplied
            $broken = $classification.Broken

            foreach ($name in $alreadyApplied) {
                Write-ColorOutput "  Already patched: $name" "Gray"
            }
        }
    }

    # bootstrap (workbench.js) might need restore from old patcher
    $bootstrapNeedsFix = $false
    $bootstrapBackup = Get-LatestBackup -Dir $BootstrapDir -Pattern $BootstrapBackupPattern
    if ($bootstrapBackup) {
        $currentBsSize = (Get-Item $BootstrapFile).Length
        if ($currentBsSize -ne $bootstrapBackup.Length) {
            $bootstrapNeedsFix = $true
        }
    }

    # "all already applied" if nothing left to apply and at least one patch was found
    $allDone = ($patchesToApply.Count -eq 0 -and $alreadyApplied.Count -gt 0)

    if ($allDone -and -not $bootstrapNeedsFix) {
        Write-ColorOutput ""
        Write-ColorOutput "All patches already applied! The full layout menu should be available." "Green"
        if (Request-DisableAutoUpdates) {
            Set-CursorUpdateSettings
            Write-ColorOutput "Auto-updates disabled." "Gray"
        }
        Write-ColorOutput "If it's not working, try: .\patcher.ps1 -Restore, then run the patcher again." "Yellow"
        exit 0
    }

    if ($allDone -and $bootstrapNeedsFix) {
        Write-ColorOutput ""
        Write-ColorOutput "JS patches already applied, but workbench.js bootstrap needs fixing..." "Yellow"
    }

    if ($broken.Count -gt 0) {
        Write-ColorOutput ""
        Write-ColorOutput "WARNING: Patch targets not found for: $($broken -join ', ')" "Yellow"
        Write-ColorOutput "These may have been changed by a Cursor update." "Yellow"
        if ($patchesToApply.Count -eq 0) {
            if ($alreadyApplied.Count -gt 0) {
                # Patches that were found are already applied; broken ones don't exist in this version
                Write-ColorOutput "All found patches are already applied (broken targets don't exist in this version)." "Green"
            } else {
                Write-ColorOutput "ERROR: No patches can be applied." "Red"
                Write-ColorOutput "Try: .\patcher.ps1 -Restore, then update Cursor, then patch again." "Yellow"
                exit 1
            }
        }
        Write-ColorOutput "Continuing with remaining patches..." "Yellow"
    }

    # verify lengths (same-length patches preserve source maps; AllowLengthMismatch skips the check)
    foreach ($p in $patchesToApply) {
        if (-not $p.AllowLengthMismatch -and $p.Search.Length -ne $p.Replace.Length) {
            Write-ColorOutput "INTERNAL ERROR: Patch '$($p.Name)' has mismatched lengths (search=$($p.Search.Length), replace=$($p.Replace.Length))." "Red"
            exit 1
        }
    }

    # backup
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $nlsBackupPath = $null
    try {
        $wbBackupPath = Join-Path $TargetDir "workbench.desktop.main.js.backup.$timestamp"
        Copy-Item -Path $TargetFile -Destination $wbBackupPath -Force
        Write-ColorOutput "Backup: $wbBackupPath" "Gray"

        $pjDir = Split-Path $ProductJsonFile -Parent
        $pjBackupPath = Join-Path $pjDir "product.json.backup.$timestamp"
        Copy-Item -Path $ProductJsonFile -Destination $pjBackupPath -Force
        Write-ColorOutput "Backup: $pjBackupPath" "Gray"

        if (Test-Path $NlsMessagesFile) {
            $nlsDir = Split-Path $NlsMessagesFile -Parent
            $nlsBackupPath = Join-Path $nlsDir "nls.messages.json.backup.$timestamp"
            Copy-Item -Path $NlsMessagesFile -Destination $nlsBackupPath -Force
            Write-ColorOutput "Backup: $nlsBackupPath" "Gray"
        }
    }
    catch {
        Write-ColorOutput "ERROR creating backup: $($_.Exception.Message)" "Red"
        Write-ColorOutput "Run the script as Administrator." "Yellow"
        exit 1
    }

    try {
        Write-ColorOutput ""
        Write-ColorOutput "Applying patches..." "Yellow"

        $patchedContent = $content
        foreach ($p in $patchesToApply) {
            $patchedContent = $patchedContent.Replace($p.Search, $p.Replace)
            Write-ColorOutput "  Patched: $($p.Name)" "Green"
        }

        # write if changed
        if ($patchedContent -ne $content) {
            [System.IO.File]::WriteAllText($TargetFile, $patchedContent, [System.Text.UTF8Encoding]::new($false))
        }

        # nls: corrupt -> star on github
        if (Test-Path $NlsMessagesFile) {
            $nlsContent = [System.IO.File]::ReadAllText($NlsMessagesFile, [System.Text.Encoding]::UTF8)
            if ($nlsContent.Contains($NlsCorruptPatch.Search)) {
                $nlsContent = $nlsContent.Replace($NlsCorruptPatch.Search, $NlsCorruptPatch.Replace)
                [System.IO.File]::WriteAllText($NlsMessagesFile, $nlsContent, [System.Text.UTF8Encoding]::new($false))
                Write-ColorOutput "  Patched: corrupt message -> dev-friendly (nls.messages.json)" "Green"
            } elseif (-not $nlsContent.Contains($NlsCorruptPatch.Replace)) {
                Write-ColorOutput "  Note: nls corrupt message not found (may differ in this Cursor version)" "Yellow"
            }
        }

        # bootstrap got overwritten? restore from backup
        Write-ColorOutput ""
        $bootstrapBackup = Get-LatestBackup -Dir $BootstrapDir -Pattern $BootstrapBackupPattern
        if ($bootstrapBackup) {
            $currentBootstrapSize = (Get-Item $BootstrapFile).Length
            $backupBootstrapSize = $bootstrapBackup.Length
            if ($currentBootstrapSize -ne $backupBootstrapSize) {
                Write-ColorOutput "Restoring workbench.js bootstrap from backup (old patcher replaced it)..." "Yellow"
                Copy-Item -Path $bootstrapBackup.FullName -Destination $BootstrapFile -Force
                Write-ColorOutput "  Restored: workbench.js ($backupBootstrapSize bytes)" "Green"
            } else {
                Write-ColorOutput "workbench.js bootstrap is correct." "Gray"
            }
        }

        # product.json checksums
        Write-ColorOutput ""
        Write-ColorOutput "Updating checksums in product.json..." "Yellow"

        $wbChecksum = Compute-FileChecksum -FilePath $TargetFile
        Update-ProductJsonChecksumWithFallback -ChecksumKeys @(
            "vs/workbench/workbench.desktop.main.js",
            "out/vs/workbench/workbench.desktop.main.js"
        ) -NewChecksum $wbChecksum -DisplayName "workbench.desktop.main.js" | Out-Null
        Write-ColorOutput "  workbench.desktop.main.js: $wbChecksum" "Gray"

        $bsChecksum = Compute-FileChecksum -FilePath $BootstrapFile
        Update-ProductJsonChecksumWithFallback -ChecksumKeys @(
            "vs/code/electron-sandbox/workbench/workbench.js",
            "out/vs/code/electron-sandbox/workbench/workbench.js"
        ) -NewChecksum $bsChecksum -DisplayName "workbench.js" | Out-Null
        Write-ColorOutput "  workbench.js: $bsChecksum" "Gray"

        Write-ColorOutput "Checksums updated." "Green"

        # cache clear
        Write-ColorOutput ""
        $cursorCacheRoot = Join-Path $env:APPDATA "Cursor"
        $cacheFolders = @("Code Cache", "Cache", "CachedData")
        foreach ($folder in $cacheFolders) {
            $cachePath = Join-Path $cursorCacheRoot $folder
            if (Test-Path $cachePath) {
                try {
                    Remove-Item -Path $cachePath -Recurse -Force -ErrorAction Stop
                    Write-ColorOutput "Cleared cache: $folder" "Gray"
                } catch {
                    Write-ColorOutput "Warning: Could not clear $folder - $($_.Exception.Message)" "Yellow"
                }
            }
        }

        # optional: disable updates
        if (Request-DisableAutoUpdates) {
            Set-CursorUpdateSettings
            Write-ColorOutput "Auto-updates disabled." "Gray"
        }

        Write-ColorOutput ""
        Write-ColorOutput "=======================================" "Green"
        Write-ColorOutput " Patch applied successfully!" "Green"
        Write-ColorOutput "=======================================" "Green"
        Write-ColorOutput ""
        Write-ColorOutput "Start Cursor and click the gear icon (top right)." "Cyan"
        Write-ColorOutput "You should now see:" "Cyan"
        Write-ColorOutput "  - 4 layout presets: Agent, Editor, Zen, Browser" "Cyan"
        Write-ColorOutput "  - Toggle switches: Agents, Chat, Editors, Panel, Sidebar" "Cyan"
        Write-ColorOutput "  - Agent Sidebar position (Left/Right)" "Cyan"
        Write-ColorOutput "  - Status Bar toggle" "Cyan"
        Write-ColorOutput "  - Cursor Settings shortcut" "Cyan"
        Write-ColorOutput ""
        Write-ColorOutput "After each Cursor update, run the patcher again." "Yellow"
    }
    catch {
        Write-ColorOutput "ERROR applying patch: $($_.Exception.Message)" "Red"
        Write-ColorOutput "Restoring from backup..." "Yellow"
        Copy-Item -Path $wbBackupPath -Destination $TargetFile -Force
        Copy-Item -Path $pjBackupPath -Destination $ProductJsonFile -Force
        if ($nlsBackupPath -and (Test-Path $nlsBackupPath)) {
            Copy-Item -Path $nlsBackupPath -Destination $NlsMessagesFile -Force
        }
        Write-ColorOutput "Backup restored. The patch was not applied." "Yellow"
        exit 1
    }
}

# --- MAIN ---
if ($Restore) {
    Invoke-Restore
} else {
    Invoke-Patch
}
