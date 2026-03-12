<#
.SYNOPSIS
    Cursor Layout Menu Patcher for 2.6.12 - Restores the full "Change Layout" menu
    (Agent, Editor, Zen, Browser + all toggles).

.DESCRIPTION
    Patches the workbench.desktop.main.js in-place for Cursor 2.6.12 (stable).
    Restores Zen/Browser presets and individual toggle switches.
    2.6.12 uses: wyw (2 layouts, Zen+Browser via spread), nh, F0, ki, HP, $F, Eyw.
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

# 2.6.12 patches. wyw=2 layouts (no K2a), inject Zen+Browser via spread. nh=clear, F0=layout enum, ki=StorageScope, HP=cmd, $F/Eyw=opener.
$Patches = @(
    @{
        Name                = "getDefaultLayouts_4layouts"
        AllowLengthMismatch = $true
        Search  = 'getDefaultLayouts(){return wyw}'
        Replace = 'getDefaultLayouts(){return[...wyw,{id:"default-zen",name:_(3183,null),state:{agentsVisible:!1,chatVisible:!1,editorsVisible:!0,panelVisible:!1,panelMaximized:!1,sidebarVisible:!1,sidebarLocation:"left",partWidths:{}},type:"default"},{id:"default-browser",name:_(3184,null),state:{agentsVisible:!1,chatVisible:!1,editorsVisible:!1,panelVisible:!1,panelMaximized:!1,sidebarVisible:!1,sidebarLocation:"left",partWidths:{}},type:"default"}]}'
    },
    @{
        Name                = "renderModeGrid_2612"
        AllowLengthMismatch = $true
        Search  = 'renderModeGrid(){if(this.skipModeGridRenderOnce){this.skipModeGridRenderOnce=!1;return}if(!this.modeGridElement)return;this.closeSavedLayoutContextMenu(),nh(this.modeGridElement);const n=this.determineLayoutMatch(void 0,{ignorePartWidths:!0}),e=n.type==="default"&&n.layout.id==="default-agent",t=n.type==="default"&&n.layout.id==="default-editor",i=this.getDefaultLayouts(),r=this.createModeOption({label:_(2940,null),isSelected:e,renderIcon:o=>this.renderAgentModeIcon(o),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:F0.Agent}),this.updateTileSelection(null,"agent"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(i[0]),this.refreshToggleStates()}});this.modeGridElement.appendChild(r);const s=this.createModeOption({label:_(2941,null),isSelected:t,renderIcon:o=>this.renderEditorModeIcon(o),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:F0.Editor}),this.updateTileSelection(null,"editor"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(i[1]),this.refreshToggleStates()}});this.modeGridElement.appendChild(s)}updateAddButtonVisibility'
        Replace = 'renderModeGrid(){if(this.skipModeGridRenderOnce){this.skipModeGridRenderOnce=!1;return}if(!this.modeGridElement)return;this.closeSavedLayoutContextMenu(),nh(this.modeGridElement);const n=this.determineLayoutMatch(void 0,{ignorePartWidths:!0}),e=n.type==="default"&&n.layout.id==="default-agent",t=n.type==="default"&&n.layout.id==="default-editor",i=n.type==="default"&&n.layout.id==="default-zen",r=n.type==="default"&&n.layout.id==="default-browser",s=n.type==="custom"?n.layout.id:void 0,o=this.getDefaultLayouts(),a=this.createModeOption({label:_(2940,null),isSelected:e,renderIcon:l=>this.renderAgentModeIcon(l),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:F0.Agent}),this.updateTileSelection(null,"agent"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(o[0]),this.refreshToggleStates()}});this.modeGridElement.appendChild(a);const l=this.createModeOption({label:_(2941,null),isSelected:t,renderIcon:u=>this.renderEditorModeIcon(u),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:F0.Editor}),this.updateTileSelection(null,"editor"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(o[1]),this.refreshToggleStates()}});this.modeGridElement.appendChild(l);const u=this.createModeOption({label:_(3183,null),isSelected:i,renderIcon:d=>this.renderZenModeIcon(d),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:"zen"}),this.updateTileSelection(null,"zen"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(o[2]),this.refreshToggleStates()}});this.modeGridElement.appendChild(u);const d=this.createModeOption({label:_(3184,null),isSelected:r,renderIcon:m=>this.renderBrowserModeIcon(m),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:"browser"}),this.updateTileSelection(null,"browser"),this.skipModeGridRenderOnce=!0,await this.ensureAgentLayoutEnabled(),await this.handleLayoutOptionSelection(o[3]),await this.commandService.executeCommand("workbench.action.focusOrOpenBrowserEditor"),this.refreshToggleStates()}});this.modeGridElement.appendChild(d);const m=this.isEmptyWindow();if(!m){const p=12,g=16,f=this.customLayouts.slice(0,p);for(const A of f){const C=this.createSavedLayoutTile(A,s===A.id);this.modeGridElement.appendChild(C)}const x=o.length+f.length,I=n.type==="unsaved"&&this.isAgentLayoutActive()&&!this.isApplyingLayout&&x<g;if(I){const B=this.createAddLayoutTile();this.modeGridElement.appendChild(B)}}}updateAddButtonVisibility'
    },
    @{
        Name                = "render_no_compact"
        AllowLengthMismatch = $true
        Search  = 'this.element.className="agent-layout-quick-menu agent-layout-quick-menu--compact",n.appendChild(this.element),this.buildContent'
        Replace = 'this.element.className="agent-layout-quick-menu",n.appendChild(this.element),this.buildContent'
    },
    @{
        Name                = "opener_no_layer"
        AllowLengthMismatch = $true
        Search  = '{getAnchor:()=>$,anchorAlignment:1,anchorPosition:0,layer:-24,render:H=>{try{const W=$F(a,u)?C:void 0;return i.createInstance(Eyw'
        Replace = '{getAnchor:()=>$,anchorAlignment:1,anchorPosition:0,render:H=>{try{const W=$F(a,u)?C:void 0;return i.createInstance(Eyw'
    },
    @{
        Name                = "buildContent_full_2612"
        AllowLengthMismatch = $true
        Search  = 'buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage();const e=this.createModeToggle();n.appendChild(e),n.appendChild(this.createDivider()),this.appendCursorSettingsButton(n)}'
        Replace = 'buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage();const e=this.createModeToggle();n.appendChild(e),n.appendChild(this.createDivider());const t=this.createSection(n),i=this.isUnifiedSidebarVisible(),r=this.createToggleRow({label:"Agents",icon:this.getCodiconClass(this.getPanelBaseIcon(this.getUnifiedSidebarLocation(),!i)),keybinding:this.getKeybindingLabel("workbench.action.toggleUnifiedSidebar"),getValue:()=>this.layoutService.isVisible("workbench.parts.unifiedsidebar"),onToggle:s=>this.setAgentsVisible(s),onIconElementCreated:s=>{this.agentsToggleIconElement=s,this.updateAgentsToggleIcon()}});this.agentsToggleWrapperElement=r,t.appendChild(r),t.appendChild(this.createToggleRow({label:"Chat",icon:"codicon-chat-rounded",keybinding:this.getKeybindingLabel("workbench.action.toggleAuxiliaryBar"),getValue:()=>this.isAgentLayoutActive()&&this.chatEditorGroupService?this.chatEditorGroupService.hasVisibleChat():this.layoutService.isVisible("workbench.parts.auxiliarybar"),onToggle:async s=>{this.isAgentLayoutActive()&&this.chatEditorGroupService?this.chatEditorGroupService.hasVisibleChat()!==s&&(s?this.chatEditorGroupService.getHiddenChatComposerIds().length>0?(await this.chatEditorGroupService.showChatEditorGroup(),this.layoutService.setPartHidden(!1,"workbench.parts.auxiliarybar")):await this.commandService.executeCommand("workbench.action.toggleAuxiliaryBar"):await this.chatEditorGroupService.hideChatEditorGroup()):await this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.auxiliarybar"),"workbench.action.toggleAuxiliaryBar")}}));const o=this.createToggleRow({label:"Editors",icon:"codicon-file-rounded",keybinding:this.getKeybindingLabel("workbench.action.toggleEditorVisibility"),getValue:()=>this.layoutService.isVisible("workbench.parts.editor",ki),onToggle:s=>this.setEditorsVisible(s)});this.editorsToggleWrapperElement=o,t.appendChild(o),t.appendChild(this.createToggleRow({label:"Panel",icon:this.getPanelToggleIconClass(),keybinding:this.getKeybindingLabel("workbench.action.togglePanel"),getValue:()=>this.layoutService.isVisible("workbench.parts.panel"),onToggle:s=>this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.panel"),"workbench.action.togglePanel"),onIconElementCreated:s=>{this.panelToggleIconElement=s,this.updatePanelToggleIcon()}})),t.appendChild(this.createToggleRow({label:"Sidebar",icon:this.getCodiconClass(this.getPanelBaseIcon(this.getSidebarIconDirection(),!this.isSidebarVisible())),keybinding:this.getKeybindingLabel("workbench.action.toggleSidebarVisibility"),getValue:()=>this.layoutService.isVisible("workbench.parts.sidebar"),onToggle:s=>this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.sidebar"),"workbench.action.toggleSidebarVisibility"),onIconElementCreated:s=>{this.sidebarToggleIconElement=s,this.updateSidebarToggleIcon()}})),n.appendChild(this.createDivider());const a=this.createSection(n);a.appendChild(this.createSubmenuRow({label:this.getSidebarPositionLabel(),getValue:()=>this.getSidebarLocation(),options:this.getSidebarPositionOptionDefinitions(),onSelect:async s=>{this.isAgentLayoutActive()?await this.agentLayoutService.setUnifiedSidebarLocation(s):await this.setSidebarPositionForCurrentWindow(s),this.updateSidebarPositionOptions(),this.renderModeGrid()},registerOption:s=>this.sidebarPositionOptions.push(s),onValueElementCreated:s=>this.sidebarPositionValueElement=s,onLabelElementCreated:s=>this.sidebarPositionLabelElement=s})),a.appendChild(this.createDivider());a.appendChild(this.createToggleRow({label:"Inline Diffs",getValue:()=>{const st=this.storageService??this._storageService;return st?!st.getBoolean("cursor/noInlineDiffs",-1,!1):!1},onToggle:s=>{const st=this.storageService??this._storageService;st&&st.store("cursor/noInlineDiffs",!s,-1,0)}}));if(this.isTitlebarVisibilityControlEnabled()){const s=this.createToggleRow({label:"Title Bar",getValue:()=>this.getTitlebarVisibility()==="show",onToggle:async c=>{const h=c?"show":"hide";await this.setTitlebarVisibilityPreference(h)}});this.titlebarVisibilityWrapperElement=s,a.appendChild(s)}a.appendChild(this.createToggleRow({label:"Status Bar",keybinding:this.getKeybindingLabel("workbench.action.toggleStatusbarVisibility"),getValue:()=>this.layoutService.isVisible("workbench.parts.statusbar",ki),onToggle:s=>this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.statusbar",ki),"workbench.action.toggleStatusbarVisibility")})),n.appendChild(this.createDivider()),this.appendCursorSettingsButton(n)}'
    },
    @{
        Name                = "appendCursorSettingsButton_keybinding_2612"
        AllowLengthMismatch = $true
        Search  = 'appendCursorSettingsButton(n){const e=document.createElement("button");e.type="button",e.className="agent-layout-quick-menu__footer-link";const t=document.createElement("span");t.className="agent-layout-quick-menu__label",t.textContent=_(2939,null),e.appendChild(t),e.addEventListener("click",i=>{i.stopPropagation(),this.commandService.executeCommand(HP).finally(()=>this.onRequestClose())}),n.appendChild(e)}'
        Replace = 'appendCursorSettingsButton(n){const e=document.createElement("button");e.type="button",e.className="agent-layout-quick-menu__footer-link";const t=document.createElement("span");t.className="agent-layout-quick-menu__label",t.textContent="Cursor Settings",e.appendChild(t);const i=this.getKeybindingLabel(HP);if(i){const r=document.createElement("span");r.className="agent-layout-quick-menu__keybinding",r.textContent=i,e.appendChild(r)}e.addEventListener("click",o=>{o.stopPropagation(),this.commandService.executeCommand(HP).finally(()=>this.onRequestClose())}),n.appendChild(e)}'
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
    param([string]$ChecksumKey, [string]$NewChecksum)
    $content = [System.IO.File]::ReadAllText($ProductJsonFile, [System.Text.Encoding]::UTF8)
    $pattern = "(`"$([regex]::Escape($ChecksumKey))`"\s*:\s*`")[^`"]*(`")"
    $newContent = [regex]::Replace($content, $pattern, "`${1}$NewChecksum`${2}")
    if ($newContent -eq $content) {
        Write-ColorOutput "WARNING: Could not update checksum for $ChecksumKey" "Yellow"
        return $false
    }
    [System.IO.File]::WriteAllText($ProductJsonFile, $newContent, [System.Text.UTF8Encoding]::new($false))
    return $true
}

function Update-ProductJsonChecksumWithFallback {
    param([string[]]$ChecksumKeys, [string]$NewChecksum, [string]$DisplayName)
    foreach ($key in $ChecksumKeys) {
        if (Update-ProductJsonChecksum -ChecksumKey $key -NewChecksum $NewChecksum) {
            return $true
        }
    }
    Write-ColorOutput "WARNING: Could not update $DisplayName checksum" "Yellow"
    return $false
}

function Request-DisableAutoUpdates {
    do { $r = (Read-Host "Disable auto-updates? (y/n)").Trim().ToLowerInvariant() } while ($r -notmatch '^(y|n|yes|no)$')
    if ($r -match '^(y|yes)$') {
        $p = Join-Path $env:APPDATA "Cursor\User\settings.json"
        $dir = Split-Path $p -Parent
        if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
        $obj = if (Test-Path $p) { try { Get-Content $p -Raw | ConvertFrom-Json } catch { [pscustomobject]@{} } } else { [pscustomobject]@{} }
        $obj | Add-Member -MemberType NoteProperty -Name "update.mode" -Value "none" -Force
        $obj | Add-Member -MemberType NoteProperty -Name "update.enableWindowsBackgroundUpdates" -Value $false -Force
        $obj | ConvertTo-Json -Depth 100 | Set-Content $p -Encoding UTF8
        Write-ColorOutput "Auto-updates disabled." "Gray"
    }
}

function Get-PatchClassification {
    param([string]$Content)
    $toApply = @()
    $alreadyApplied = @()
    $broken = @()

    foreach ($p in $Patches) {
        if ($Content.Contains($p.Replace)) {
            $alreadyApplied += $p.Name
        }
        elseif ($Content.Contains($p.Search)) {
            $toApply += $p
        }
        else {
            $broken += $p.Name
        }
    }

    return @{ ToApply = $toApply; AlreadyApplied = $alreadyApplied; Broken = $broken }
}

function Invoke-Restore {
    Write-ColorOutput "=== Restore ===" "Cyan"
    Test-CursorNotRunning

    $wb = Get-LatestBackup -Dir $TargetDir -Pattern $BackupPattern
    if (!$wb) {
        Write-ColorOutput "ERROR: No backup found." "Red"
        exit 1
    }

    Copy-Item $wb.FullName $TargetFile -Force
    Write-ColorOutput "Restored: $($wb.Name)" "Green"

    $pj = Get-LatestBackup -Dir (Split-Path $ProductJsonFile -Parent) -Pattern $ProductBackupPattern
    if ($pj) {
        Copy-Item $pj.FullName $ProductJsonFile -Force
        Write-ColorOutput "Restored product.json" "Green"
    }

    if (Test-Path $NlsMessagesFile) {
        $nls = Get-LatestBackup -Dir (Split-Path $NlsMessagesFile -Parent) -Pattern $NlsBackupPattern
        if ($nls) { Copy-Item $nls.FullName $NlsMessagesFile -Force }
    }

    Write-ColorOutput "Done. Start Cursor." "Green"
}

function Invoke-Patch {
    Write-ColorOutput "=== Cursor Layout Patcher (2.6.12) ===" "Cyan"

    if (!(Test-Path $TargetFile)) {
        Write-ColorOutput "ERROR: Workbench not found." "Red"
        exit 1
    }
    if (!(Test-Path $ProductJsonFile)) {
        Write-ColorOutput "ERROR: product.json not found." "Red"
        exit 1
    }

    Test-CursorNotRunning

    $content = [System.IO.File]::ReadAllText($TargetFile, [System.Text.Encoding]::UTF8)
    $cls = Get-PatchClassification -Content $content
    $toApply = $cls.ToApply
    $alreadyApplied = $cls.AlreadyApplied
    $broken = $cls.Broken

    foreach ($n in $alreadyApplied) { Write-ColorOutput "  Already: $n" "Gray" }

    if ($toApply.Count -eq 0 -and $broken.Count -gt 0 -and $alreadyApplied.Count -gt 0) {
        $rec = Get-WorkbenchBackupWithPatchTargets -Dir $TargetDir -Pattern $BackupPattern
        if ($rec) {
            Write-ColorOutput "Recovering from backup (version mismatch)..." "Yellow"
            Copy-Item $rec.FullName $TargetFile -Force
            $content = [System.IO.File]::ReadAllText($TargetFile, [System.Text.Encoding]::UTF8)
            $cls = Get-PatchClassification -Content $content
            $toApply = $cls.ToApply
            $alreadyApplied = $cls.AlreadyApplied
            $broken = $cls.Broken
        }
    }

    if ($toApply.Count -eq 0 -and $alreadyApplied.Count -gt 0) {
        Write-ColorOutput "`nAll patches applied." "Green"
        Request-DisableAutoUpdates
        exit 0
    }

    if ($broken.Count -gt 0) {
        Write-ColorOutput "`nWARNING: Targets not found: $($broken -join ', ')" "Yellow"
        if ($toApply.Count -eq 0) {
            Write-ColorOutput "Use patcher for your Cursor version." "Red"
            exit 1
        }
    }

    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $wbPath = Join-Path $TargetDir "workbench.desktop.main.js.backup.$ts"
    $pjPath = Join-Path (Split-Path $ProductJsonFile -Parent) "product.json.backup.$ts"
    Copy-Item $TargetFile $wbPath -Force
    Copy-Item $ProductJsonFile $pjPath -Force
    $nlsPath = $null
    if (Test-Path $NlsMessagesFile) {
        $nlsPath = Join-Path (Split-Path $NlsMessagesFile -Parent) "nls.messages.json.backup.$ts"
        Copy-Item $NlsMessagesFile $nlsPath -Force
    }

    try {
        $patched = $content
        foreach ($p in $toApply) {
            $patched = $patched.Replace($p.Search, $p.Replace)
            Write-ColorOutput "  Patched: $($p.Name)" "Green"
        }
        if ($patched -ne $content) {
            [System.IO.File]::WriteAllText($TargetFile, $patched, [System.Text.UTF8Encoding]::new($false))
        }

        if (Test-Path $NlsMessagesFile) {
            $nls = [System.IO.File]::ReadAllText($NlsMessagesFile, [System.Text.Encoding]::UTF8)
            if ($nls.Contains($NlsCorruptPatch.Search)) {
                $nls = $nls.Replace($NlsCorruptPatch.Search, $NlsCorruptPatch.Replace)
                [System.IO.File]::WriteAllText($NlsMessagesFile, $nls, [System.Text.UTF8Encoding]::new($false))
                Write-ColorOutput "  Patched nls" "Green"
            }
        }

        $bs = Get-LatestBackup -Dir $BootstrapDir -Pattern $BootstrapBackupPattern
        if ($bs -and (Test-Path $BootstrapFile) -and ((Get-Item $BootstrapFile).Length -ne $bs.Length)) {
            Copy-Item $bs.FullName $BootstrapFile -Force
            Write-ColorOutput "  Restored workbench.js" "Green"
        }

        $wbSum = Compute-FileChecksum -FilePath $TargetFile
        Update-ProductJsonChecksumWithFallback -ChecksumKeys @("vs/workbench/workbench.desktop.main.js", "out/vs/workbench/workbench.desktop.main.js") -NewChecksum $wbSum -DisplayName "workbench" | Out-Null

        if (Test-Path $BootstrapFile) {
            $bsSum = Compute-FileChecksum -FilePath $BootstrapFile
            Update-ProductJsonChecksumWithFallback -ChecksumKeys @("vs/code/electron-sandbox/workbench/workbench.js", "out/vs/code/electron-sandbox/workbench/workbench.js") -NewChecksum $bsSum -DisplayName "workbench.js" | Out-Null
        }

        $cursorAppData = Join-Path $env:APPDATA "Cursor"
        foreach ($cf in @("Code Cache", "Cache", "CachedData")) {
            $cp = Join-Path $cursorAppData $cf
            if (Test-Path $cp) { Remove-Item $cp -Recurse -Force -ErrorAction SilentlyContinue }
        }

        Request-DisableAutoUpdates

        Write-ColorOutput "`n=======================================" "Green"
        Write-ColorOutput " Patch applied!" "Green"
        Write-ColorOutput "=======================================" "Green"
        Write-ColorOutput "`nStart Cursor, click gear icon (top right)." "Cyan"
    }
    catch {
        Write-ColorOutput "ERROR: $($_.Exception.Message)" "Red"
        Copy-Item $wbPath $TargetFile -Force
        Copy-Item $pjPath $ProductJsonFile -Force
        if ($nlsPath -and (Test-Path $nlsPath)) { Copy-Item $nlsPath $NlsMessagesFile -Force }
        exit 1
    }
}

if ($Restore) { Invoke-Restore } else { Invoke-Patch }
