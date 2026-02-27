<#
.SYNOPSIS
    Cursor Layout Menu Patcher - Restores the full "Change Layout" menu
    (Agent, Editor, Zen, Browser + all toggles).

.DESCRIPTION
    Patches the workbench.desktop.main.js in-place to restore the full
    layout menu with Zen/Browser presets and individual toggle switches.

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

# nls: swap "corrupt" dialog text
$NlsCorruptPatch = @{
    Search  = '"Your {0} installation appears to be corrupt. Please reinstall."'
    Replace = '"Layout Patcher active. Checksums modified. No reinstall needed. Leave a star on GitHub <3"'
}

# 2.7.0-pre.1 patches.
# Key differences vs pre.43: NAw (2 layouts) -> U2a (4), th (not Xd), AS (not wS), Ei (not xi), GP (not HP), $Aw (not BAw).
$Patches = @(
    @{
        # U2a is the full 4-layout array. Same-length swap (both 3 chars).
        Name    = "getDefaultLayouts_U2a"
        Search  = 'getDefaultLayouts(){return NAw}'
        Replace = 'getDefaultLayouts(){return U2a}'
    },
    @{
        # Adds Zen + Browser tiles, custom layout tiles, and Add button. th=clear, AS=layout enum.
        Name                = "renderModeGrid_27"
        AllowLengthMismatch = $true
        Search  = 'renderModeGrid(){if(this.skipModeGridRenderOnce){this.skipModeGridRenderOnce=!1;return}if(!this.modeGridElement)return;this.closeSavedLayoutContextMenu(),th(this.modeGridElement);const n=this.determineLayoutMatch(void 0,{ignorePartWidths:!0}),e=n.type==="default"&&n.layout.id==="default-agent",t=n.type==="default"&&n.layout.id==="default-editor",i=this.getDefaultLayouts(),r=this.createModeOption({label:_(2940,null),isSelected:e,renderIcon:o=>this.renderAgentModeIcon(o),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:AS.Agent}),this.updateTileSelection(null,"agent"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(i[0]),this.refreshToggleStates()}});this.modeGridElement.appendChild(r);const s=this.createModeOption({label:_(2941,null),isSelected:t,renderIcon:o=>this.renderEditorModeIcon(o),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:AS.Editor}),this.updateTileSelection(null,"editor"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(i[1]),this.refreshToggleStates()}});this.modeGridElement.appendChild(s)}updateAddButtonVisibility'
        Replace = 'renderModeGrid(){if(this.skipModeGridRenderOnce){this.skipModeGridRenderOnce=!1;return}if(!this.modeGridElement)return;this.closeSavedLayoutContextMenu(),th(this.modeGridElement);const n=this.determineLayoutMatch(void 0,{ignorePartWidths:!0}),e=n.type==="default"&&n.layout.id==="default-agent",t=n.type==="default"&&n.layout.id==="default-editor",i=n.type==="default"&&n.layout.id==="default-zen",r=n.type==="default"&&n.layout.id==="default-browser",s=n.type==="custom"?n.layout.id:void 0,o=this.getDefaultLayouts(),a=this.createModeOption({label:_(2940,null),isSelected:e,renderIcon:l=>this.renderAgentModeIcon(l),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:AS.Agent}),this.updateTileSelection(null,"agent"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(o[0]),this.refreshToggleStates()}});this.modeGridElement.appendChild(a);const l=this.createModeOption({label:_(2941,null),isSelected:t,renderIcon:u=>this.renderEditorModeIcon(u),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:AS.Editor}),this.updateTileSelection(null,"editor"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(o[1]),this.refreshToggleStates()}});this.modeGridElement.appendChild(l);const u=this.createModeOption({label:_(3183,null),isSelected:i,renderIcon:d=>this.renderZenModeIcon(d),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:"zen"}),this.updateTileSelection(null,"zen"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(o[2]),this.refreshToggleStates()}});this.modeGridElement.appendChild(u);const d=this.createModeOption({label:_(3184,null),isSelected:r,renderIcon:m=>this.renderBrowserModeIcon(m),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:"browser"}),this.updateTileSelection(null,"browser"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(o[3]),await this.commandService.executeCommand("workbench.action.focusOrOpenBrowserEditor"),this.refreshToggleStates()}});this.modeGridElement.appendChild(d);const m=this.isEmptyWindow();if(!m){const p=12,g=16,f=this.customLayouts.slice(0,p);for(const A of f){const C=this.createSavedLayoutTile(A,s===A.id);this.modeGridElement.appendChild(C)}const x=o.length+f.length,I=n.type==="unsaved"&&this.isAgentLayoutActive()&&!this.isApplyingLayout&&x<g;if(I){const B=this.createAddLayoutTile();this.modeGridElement.appendChild(B)}}}updateAddButtonVisibility'
    },
    @{
        # Remove --compact: restores 244px width and 4-column grid.
        Name                = "render_no_compact"
        AllowLengthMismatch = $true
        Search  = 'this.element.className="agent-layout-quick-menu agent-layout-quick-menu--compact",n.appendChild(this.element),this.buildContent'
        Replace = 'this.element.className="agent-layout-quick-menu",n.appendChild(this.element),this.buildContent'
    },
    @{
        # Remove layer:-24 from showContextView. $Aw is the layout menu class in 2.7.
        Name                = "opener_no_layer"
        AllowLengthMismatch = $true
        Search  = '{getAnchor:()=>$,anchorAlignment:1,anchorPosition:0,layer:-24,render:H=>{try{const W=FF(a,u)?C:void 0;return i.createInstance($Aw'
        Replace = '{getAnchor:()=>$,anchorAlignment:1,anchorPosition:0,render:H=>{try{const W=FF(a,u)?C:void 0;return i.createInstance($Aw'
    },
    @{
        # Lower layout menu z-index so Rename/Delete context menu (mentions) appears on top.
        Name                = "layout_menu_lower_zindex"
        AllowLengthMismatch = $true
        Search  = 'this.element.className="agent-layout-quick-menu",n.appendChild(this.element),this.buildContent'
        Replace = 'this.element.className="agent-layout-quick-menu",n.appendChild(this.element),(()=>{try{const cv=this.element.closest?.(".context-view");cv&&(cv.style.zIndex="2500")}catch{}})(),this.buildContent'
    },
    @{
        # Restore full toggle rows. Ei (not xi) for layoutService.isVisible in 2.7.
        Name                = "buildContent_full_27"
        AllowLengthMismatch = $true
        Search  = 'buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage();const e=this.createModeToggle();n.appendChild(e),n.appendChild(this.createDivider()),this.appendCursorSettingsButton(n)}'
        Replace = 'buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage();const e=this.createModeToggle();n.appendChild(e),n.appendChild(this.createDivider());const t=this.createSection(n),i=this.isUnifiedSidebarVisible(),r=this.createToggleRow({label:"Agents",icon:this.getCodiconClass(this.getPanelBaseIcon(this.getUnifiedSidebarLocation(),!i)),keybinding:this.getKeybindingLabel("workbench.action.toggleUnifiedSidebar"),getValue:()=>this.layoutService.isVisible("workbench.parts.unifiedsidebar"),onToggle:s=>this.setAgentsVisible(s),onIconElementCreated:s=>{this.agentsToggleIconElement=s,this.updateAgentsToggleIcon()}});this.agentsToggleWrapperElement=r,t.appendChild(r),t.appendChild(this.createToggleRow({label:"Chat",icon:"codicon-chat-rounded",keybinding:this.getKeybindingLabel("workbench.action.toggleAuxiliaryBar"),getValue:()=>this.isAgentLayoutActive()&&this.chatEditorGroupService?this.chatEditorGroupService.hasVisibleChat():this.layoutService.isVisible("workbench.parts.auxiliarybar"),onToggle:async s=>{this.isAgentLayoutActive()&&this.chatEditorGroupService?this.chatEditorGroupService.hasVisibleChat()!==s&&(s?this.chatEditorGroupService.getHiddenChatComposerIds().length>0?(await this.chatEditorGroupService.showChatEditorGroup(),this.layoutService.setPartHidden(!1,"workbench.parts.auxiliarybar")):await this.commandService.executeCommand("workbench.action.toggleAuxiliaryBar"):await this.chatEditorGroupService.hideChatEditorGroup()):await this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.auxiliarybar"),"workbench.action.toggleAuxiliaryBar")}}));const o=this.createToggleRow({label:"Editors",icon:"codicon-file-rounded",keybinding:this.getKeybindingLabel("workbench.action.toggleEditorVisibility"),getValue:()=>this.layoutService.isVisible("workbench.parts.editor",Ei),onToggle:s=>this.setEditorsVisible(s)});this.editorsToggleWrapperElement=o,t.appendChild(o),t.appendChild(this.createToggleRow({label:"Panel",icon:this.getPanelToggleIconClass(),keybinding:this.getKeybindingLabel("workbench.action.togglePanel"),getValue:()=>this.layoutService.isVisible("workbench.parts.panel"),onToggle:s=>this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.panel"),"workbench.action.togglePanel"),onIconElementCreated:s=>{this.panelToggleIconElement=s,this.updatePanelToggleIcon()}})),t.appendChild(this.createToggleRow({label:"Sidebar",icon:this.getCodiconClass(this.getPanelBaseIcon(this.getSidebarIconDirection(),!this.isSidebarVisible())),keybinding:this.getKeybindingLabel("workbench.action.toggleSidebarVisibility"),getValue:()=>this.layoutService.isVisible("workbench.parts.sidebar"),onToggle:s=>this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.sidebar"),"workbench.action.toggleSidebarVisibility"),onIconElementCreated:s=>{this.sidebarToggleIconElement=s,this.updateSidebarToggleIcon()}})),n.appendChild(this.createDivider());const a=this.createSection(n);a.appendChild(this.createSubmenuRow({label:this.getSidebarPositionLabel(),getValue:()=>this.getSidebarLocation(),options:this.getSidebarPositionOptionDefinitions(),onSelect:async s=>{this.isAgentLayoutActive()?await this.agentLayoutService.setUnifiedSidebarLocation(s):await this.setSidebarPositionForCurrentWindow(s),this.updateSidebarPositionOptions(),this.renderModeGrid()},registerOption:s=>this.sidebarPositionOptions.push(s),onValueElementCreated:s=>this.sidebarPositionValueElement=s,onLabelElementCreated:s=>this.sidebarPositionLabelElement=s})),a.appendChild(this.createDivider());try{const Ae=Bi("diffDecorationVisibilityService");a.appendChild(this.createToggleRow({label:"Inline Diffs",getValue:()=>!this.instantiationService.get(Ae).getNoInlineDiffsSetting(),onToggle:s=>this.instantiationService.get(Ae).setNoInlineDiffsSetting(!s)}))}catch{}if(this.isTitlebarVisibilityControlEnabled()){const s=this.createToggleRow({label:"Title Bar",getValue:()=>this.getTitlebarVisibility()==="show",onToggle:async c=>{const h=c?"show":"hide";await this.setTitlebarVisibilityPreference(h)}});this.titlebarVisibilityWrapperElement=s,a.appendChild(s)}a.appendChild(this.createToggleRow({label:"Status Bar",keybinding:this.getKeybindingLabel("workbench.action.toggleStatusbarVisibility"),getValue:()=>this.layoutService.isVisible("workbench.parts.statusbar",Ei),onToggle:s=>this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.statusbar",Ei),"workbench.action.toggleStatusbarVisibility")})),n.appendChild(this.createDivider()),this.appendCursorSettingsButton(n)}'
    },
    @{
        # GP (not HP) - restore "Cursor Settings" label + keybinding display.
        Name                = "appendCursorSettingsButton_keybinding_27"
        AllowLengthMismatch = $true
        Search  = 'appendCursorSettingsButton(n){const e=document.createElement("button");e.type="button",e.className="agent-layout-quick-menu__footer-link";const t=document.createElement("span");t.className="agent-layout-quick-menu__label",t.textContent=_(2939,null),e.appendChild(t),e.addEventListener("click",i=>{i.stopPropagation(),this.commandService.executeCommand(GP).finally(()=>this.onRequestClose())}),n.appendChild(e)}'
        Replace = 'appendCursorSettingsButton(n){const e=document.createElement("button");e.type="button",e.className="agent-layout-quick-menu__footer-link";const t=document.createElement("span");t.className="agent-layout-quick-menu__label",t.textContent="Cursor Settings",e.appendChild(t);const i=this.getKeybindingLabel(GP);if(i){const r=document.createElement("span");r.className="agent-layout-quick-menu__keybinding",r.textContent=i,e.appendChild(r)}e.addEventListener("click",o=>{o.stopPropagation(),this.commandService.executeCommand(GP).finally(()=>this.onRequestClose())}),n.appendChild(e)}'
    },
    @{
        # For already-patched: add Inline Diffs toggle between Agent Sidebar and Status Bar.
        Name                = "buildContent_add_inline_diffs"
        AllowLengthMismatch = $true
        Search  = 'a.appendChild(this.createDivider());if(this.isTitlebarVisibilityControlEnabled()){const s=this.createToggleRow({label:"Title Bar",getValue:()=>this.getTitlebarVisibility()==="show",onToggle:async c=>{const h=c?"show":"hide";await this.setTitlebarVisibilityPreference(h)}});this.titlebarVisibilityWrapperElement=s,a.appendChild(s)}a.appendChild(this.createToggleRow({label:"Status Bar"'
        Replace = 'a.appendChild(this.createDivider());try{const Ae=Bi("diffDecorationVisibilityService");a.appendChild(this.createToggleRow({label:"Inline Diffs",getValue:()=>!this.instantiationService.get(Ae).getNoInlineDiffsSetting(),onToggle:s=>this.instantiationService.get(Ae).setNoInlineDiffsSetting(!s)}))}catch{}if(this.isTitlebarVisibilityControlEnabled()){const s=this.createToggleRow({label:"Title Bar",getValue:()=>this.getTitlebarVisibility()==="show",onToggle:async c=>{const h=c?"show":"hide";await this.setTitlebarVisibilityPreference(h)}});this.titlebarVisibilityWrapperElement=s,a.appendChild(s)}a.appendChild(this.createToggleRow({label:"Status Bar"'
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
            if ($content.Contains("getDefaultLayouts(){return") -or $content.Contains("buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage()")) {
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

        $pjDir = Split-Path $ProductJsonFile -Parent
        $pjBackup = Get-LatestBackup -Dir $pjDir -Pattern $ProductBackupPattern
        if ($pjBackup) {
            Copy-Item -Path $pjBackup.FullName -Destination $ProductJsonFile -Force
            Write-ColorOutput "Restored product.json" "Green"
        }

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
    Write-ColorOutput "=== Cursor Layout Menu Patcher (2.7.0-pre.1) ===" "Cyan"
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

    $looksLikeBundledMismatch = ($patchesToApply.Count -eq 0 -and $broken.Count -gt 0 -and $alreadyApplied.Count -gt 0)
    if ($looksLikeBundledMismatch) {
        $recoveryBackup = Get-WorkbenchBackupWithPatchTargets -Dir $TargetDir -Pattern $BackupPattern
        if ($recoveryBackup) {
            Write-ColorOutput ""
            Write-ColorOutput "Detected incompatible bundled/old workbench. Recovering from backup..." "Yellow"
            Copy-Item -Path $recoveryBackup.FullName -Destination $TargetFile -Force
            Write-ColorOutput "Recovered: $($recoveryBackup.Name)" "Green"

            $content = [System.IO.File]::ReadAllText($TargetFile, [System.Text.Encoding]::UTF8)
            $fileSize = (Get-Item $TargetFile).Length
            $classification = Get-PatchClassification -Content $content
            $patchesToApply = $classification.ToApply
            $alreadyApplied = $classification.AlreadyApplied
            $broken = $classification.Broken
        }
    }

    $allDone = ($patchesToApply.Count -eq 0 -and $alreadyApplied.Count -gt 0)

    if ($allDone) {
        Write-ColorOutput ""
        Write-ColorOutput "All patches already applied! The full layout menu should be available." "Green"
        if (Request-DisableAutoUpdates) {
            Set-CursorUpdateSettings
        }
        exit 0
    }

    if ($broken.Count -gt 0) {
        Write-ColorOutput ""
        Write-ColorOutput "WARNING: Patch targets not found for: $($broken -join ', ')" "Yellow"
        Write-ColorOutput "Your Cursor version may differ. Use the patcher from the folder matching your version." "Yellow"
        if ($patchesToApply.Count -eq 0) {
            Write-ColorOutput "ERROR: No patches can be applied. Try: .\patcher.ps1 -Restore" "Red"
            exit 1
        }
    }

    foreach ($p in $patchesToApply) {
        if (-not $p.AllowLengthMismatch -and $p.Search.Length -ne $p.Replace.Length) {
            Write-ColorOutput "INTERNAL ERROR: Patch '$($p.Name)' has mismatched lengths." "Red"
            exit 1
        }
    }

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
        }
    }
    catch {
        Write-ColorOutput "ERROR creating backup: $($_.Exception.Message)" "Red"
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

        if ($patchedContent -ne $content) {
            [System.IO.File]::WriteAllText($TargetFile, $patchedContent, [System.Text.UTF8Encoding]::new($false))
        }

        if (Test-Path $NlsMessagesFile) {
            $nlsContent = [System.IO.File]::ReadAllText($NlsMessagesFile, [System.Text.Encoding]::UTF8)
            if ($nlsContent.Contains($NlsCorruptPatch.Search)) {
                $nlsContent = $nlsContent.Replace($NlsCorruptPatch.Search, $NlsCorruptPatch.Replace)
                [System.IO.File]::WriteAllText($NlsMessagesFile, $nlsContent, [System.Text.UTF8Encoding]::new($false))
                Write-ColorOutput "  Patched: corrupt message (nls.messages.json)" "Green"
            }
        }

        $bootstrapBackup = Get-LatestBackup -Dir $BootstrapDir -Pattern $BootstrapBackupPattern
        if ($bootstrapBackup -and (Test-Path $BootstrapFile) -and ((Get-Item $BootstrapFile).Length -ne $bootstrapBackup.Length)) {
            Copy-Item -Path $bootstrapBackup.FullName -Destination $BootstrapFile -Force
            Write-ColorOutput "  Restored: workbench.js bootstrap" "Green"
        }

        Write-ColorOutput ""
        Write-ColorOutput "Updating checksums in product.json..." "Yellow"

        $wbChecksum = Compute-FileChecksum -FilePath $TargetFile
        Update-ProductJsonChecksumWithFallback -ChecksumKeys @("vs/workbench/workbench.desktop.main.js", "out/vs/workbench/workbench.desktop.main.js") -NewChecksum $wbChecksum -DisplayName "workbench" | Out-Null

        $bsChecksum = Compute-FileChecksum -FilePath $BootstrapFile
        Update-ProductJsonChecksumWithFallback -ChecksumKeys @("vs/code/electron-sandbox/workbench/workbench.js", "out/vs/code/electron-sandbox/workbench/workbench.js") -NewChecksum $bsChecksum -DisplayName "workbench.js" | Out-Null

        $cursorCacheRoot = Join-Path $env:APPDATA "Cursor"
        foreach ($folder in @("Code Cache", "Cache", "CachedData")) {
            $cachePath = Join-Path $cursorCacheRoot $folder
            if (Test-Path $cachePath) { Remove-Item -Path $cachePath -Recurse -Force -ErrorAction SilentlyContinue }
        }

        if (Request-DisableAutoUpdates) { Set-CursorUpdateSettings }

        Write-ColorOutput ""
        Write-ColorOutput "=======================================" "Green"
        Write-ColorOutput " Patch applied successfully!" "Green"
        Write-ColorOutput "=======================================" "Green"
        Write-ColorOutput ""
        Write-ColorOutput "Start Cursor and click the gear icon (top right)." "Cyan"
        Write-ColorOutput "After each Cursor update, run the patcher again." "Yellow"
    }
    catch {
        Write-ColorOutput "ERROR: $($_.Exception.Message)" "Red"
        Copy-Item -Path $wbBackupPath -Destination $TargetFile -Force
        Copy-Item -Path $pjBackupPath -Destination $ProductJsonFile -Force
        if ($nlsBackupPath -and (Test-Path $nlsBackupPath)) { Copy-Item -Path $nlsBackupPath -Destination $NlsMessagesFile -Force }
        exit 1
    }
}

if ($Restore) { Invoke-Restore } else { Invoke-Patch }
