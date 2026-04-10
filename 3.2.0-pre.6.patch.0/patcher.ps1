<#
.SYNOPSIS
    Cursor Layout Menu Patcher for 3.2.0-pre.6 - Restores the full "Change Layout" menu.

.DESCRIPTION
    Patches workbench.desktop.main.js for Cursor 3.2.0-pre.6.
    i18n E(). y5S (layouts), Fh (clear), sF (layoutEnum), sB (settings cmd), fi (StorageScope), opener FR + k5S.
    Zen "Zen"; Browser E(2964). Agent/Editor E(2942)/E(2943). Footer E(2939) → patched "Cursor Settings" + keybinding.
    Opener: layer:-24 removed; createInstance(k5S,...).render(U); tail N,x. Minified names differ from 3.1.0-pre.25 (cFS/Mh/ZB/nB/wi/AR/pFS).
    Add-layout tile: !isApplyingLayout && under cap. cursor-old: same E(n) index ≠ same string — use the patch for your exact version.
#>

param(
    [switch]$Restore,
    [string]$Path = ""
)

if ([string]::IsNullOrWhiteSpace($Path)) {
    function Get-DetectedCursorInstallations {
        $candidates = @(
            (Join-Path $env:LOCALAPPDATA "Programs\cursor"),
            "C:\Program Files\cursor"
        ) | Select-Object -Unique
        $detected = @()
        foreach ($candidate in $candidates) {
            $wb = Join-Path $candidate "resources\app\out\vs\workbench\workbench.desktop.main.js"
            $pj = Join-Path $candidate "resources\app\product.json"
            if ((Test-Path $wb) -and (Test-Path $pj)) { $detected += $candidate }
        }
        return $detected
    }
    $installs = Get-DetectedCursorInstallations
    if ($installs.Count -eq 0) { Write-Host "ERROR: No Cursor installation found." -ForegroundColor Red; exit 1 }
    Write-Host "Detected: $($installs -join ', ')" -ForegroundColor Cyan
    foreach ($inst in $installs) {
        Write-Host "`n=== $inst ===" -ForegroundColor Cyan
        & powershell -ExecutionPolicy Bypass -File $PSCommandPath -Path $inst @(if($Restore){'-Restore'})
        if ($LASTEXITCODE -ne 0) { exit 1 }
    }
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

$NlsCorruptPatch = @{
    Search  = '"Your {0} installation appears to be corrupt. Please reinstall."'
    Replace = '"Layout Patcher active. Checksums modified. No reinstall needed. Leave a star on GitHub <3"'
}

# 3.2.0-pre.6: y5S=2 layouts, Fh=clear, sF=layoutEnum, sB=cmd, k5S=createInstance, fi=StorageScope, openerCheck=FR (getAnchor:()=>O)
$Patches = @(
    @{
        Name                = "getDefaultLayouts_4layouts"
        AllowLengthMismatch = $true
        Search  = 'getDefaultLayouts(){return y5S}'
        Replace = 'getDefaultLayouts(){return[...y5S,{id:"default-zen",name:"Zen",state:{agentsVisible:!1,chatVisible:!1,editorsVisible:!0,panelVisible:!1,panelMaximized:!1,sidebarVisible:!1,sidebarLocation:"left",partWidths:{}},type:"default"},{id:"default-browser",name:E(2964,null),state:{agentsVisible:!1,chatVisible:!0,editorsVisible:!0,panelVisible:!1,sidebarVisible:!1,sidebarLocation:"left",partWidths:{},panelMaximized:!1},type:"default"}]}'
    },
    @{
        Name                = "renderModeGrid_320p6"
        AllowLengthMismatch = $true
        Search  = 'renderModeGrid(){if(this.skipModeGridRenderOnce){this.skipModeGridRenderOnce=!1;return}if(!this.modeGridElement)return;this.closeSavedLayoutContextMenu(),Fh(this.modeGridElement);const n=this.getSidebarLocation(),e=n==="left",t=n==="right",i=this.getDefaultLayouts(),r=this.createModeOption({label:E(2942,null),isSelected:e,renderIcon:o=>this.renderAgentModeIcon(o),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:sF.Agent}),this.updateTileSelection(null,"agent"),this.skipModeGridRenderOnce=!0,await this.handleLayoutOptionSelection(i[0]),this.refreshToggleStates()}});this.modeGridElement.appendChild(r);const s=this.createModeOption({label:E(2943,null),isSelected:t,renderIcon:o=>this.renderEditorModeIcon(o),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:sF.Editor}),this.updateTileSelection(null,"editor"),this.skipModeGridRenderOnce=!0,await this.handleLayoutOptionSelection(i[1]),this.refreshToggleStates()}});this.modeGridElement.appendChild(s)}updateAddButtonVisibility'
        Replace = 'renderModeGrid(){if(this.skipModeGridRenderOnce){this.skipModeGridRenderOnce=!1;return}if(!this.modeGridElement)return;this.closeSavedLayoutContextMenu(),Fh(this.modeGridElement);const n=this.determineLayoutMatch(void 0,{ignorePartWidths:!0}),e=n.type==="default"&&n.layout.id==="default-agent",t=n.type==="default"&&n.layout.id==="default-editor",i=n.type==="default"&&n.layout.id==="default-zen",r=n.type==="default"&&n.layout.id==="default-browser",s=n.type==="custom"?n.layout.id:void 0,o=this.getDefaultLayouts(),a=this.createModeOption({label:E(2942,null),isSelected:e,renderIcon:l=>this.renderAgentModeIcon(l),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:sF.Agent}),this.updateTileSelection(null,"agent"),this.skipModeGridRenderOnce=!0,await this.handleLayoutOptionSelection(o[0]),this.refreshToggleStates()}});this.modeGridElement.appendChild(a);const l=this.createModeOption({label:E(2943,null),isSelected:t,renderIcon:u=>this.renderEditorModeIcon(u),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:sF.Editor}),this.updateTileSelection(null,"editor"),this.skipModeGridRenderOnce=!0,await this.handleLayoutOptionSelection(o[1]),this.refreshToggleStates()}});this.modeGridElement.appendChild(l);const u=this.createModeOption({label:"Zen",isSelected:i,renderIcon:d=>this.renderZenModeIcon(d),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:"zen"}),this.updateTileSelection(null,"zen"),this.skipModeGridRenderOnce=!0,await this.handleLayoutOptionSelection(o[2]),this.refreshToggleStates()}});this.modeGridElement.appendChild(u);const d=this.createModeOption({label:E(2964,null),isSelected:r,renderIcon:m=>this.renderBrowserModeIcon(m),onClick:async()=>{this.analyticsService.trackEvent("agent_layout.switch_layout",{selectedLayout:"browser"}),this.updateTileSelection(null,"browser"),this.skipModeGridRenderOnce=!0,await this.handleLayoutOptionSelection(o[3]),await this.commandService.executeCommand("workbench.action.focusOrOpenBrowserEditor"),this.refreshToggleStates()}});this.modeGridElement.appendChild(d);const m=!1;if(!m){const p=12,g=16,f=this.customLayouts.slice(0,p);for(const A of f){const C=this.createSavedLayoutTile(A,s===A.id);this.modeGridElement.appendChild(C)}const x=o.length+f.length,I=!this.isApplyingLayout&&x<g;if(I){const B=this.createAddLayoutTile();this.modeGridElement.appendChild(B)}}}updateAddButtonVisibility'
    },
    @{
        Name                = "render_no_compact_and_zindex"
        AllowLengthMismatch = $true
        Search  = 'this.element.className="agent-layout-quick-menu agent-layout-quick-menu--compact",n.appendChild(this.element),this.buildContent'
        Replace = 'this.element.className="agent-layout-quick-menu",n.appendChild(this.element),(()=>{try{const cv=this.element.closest?.(".context-view");cv&&(cv.style.zIndex="2500")}catch{}})(),this.buildContent'
    },
    @{
        Name                = "opener_no_layer_320p6"
        AllowLengthMismatch = $true
        Search  = '{getAnchor:()=>O,anchorAlignment:1,anchorPosition:0,layer:-24,render:U=>{try{const q=FR(a,u)?S:void 0;return i.createInstance(k5S,s,o,a,l,u,d,h,f,p,g,i,_,q,N,x).render(U)}catch(q){throw q}}'
        Replace = '{getAnchor:()=>O,anchorAlignment:1,anchorPosition:0,render:U=>{try{const q=FR(a,u)?S:void 0;return i.createInstance(k5S,s,o,a,l,u,d,h,f,p,g,i,_,q,N,x).render(U)}catch(q){throw q}}'
    },
    @{
        Name                = "buildContent_full_320p6"
        AllowLengthMismatch = $true
        Search  = 'buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage();const e=this.createModeToggle();n.appendChild(e),n.appendChild(this.createDivider()),this.appendGlassWindowButton(n)&&n.appendChild(this.createDivider()),this.appendCursorSettingsButton(n)}'
        Replace = 'buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage();const e=this.createModeToggle();n.appendChild(e),n.appendChild(this.createDivider());const t=this.createSection(n),i=this.isUnifiedSidebarVisible(),r=this.createToggleRow({label:"Agents",icon:this.getCodiconClass(this.getPanelBaseIcon(this.getUnifiedSidebarLocation(),!i)),keybinding:this.getKeybindingLabel("workbench.action.toggleUnifiedSidebar"),getValue:()=>this.layoutService.isVisible("workbench.parts.unifiedsidebar"),onToggle:s=>this.setAgentsVisible(s),onIconElementCreated:s=>{this.agentsToggleIconElement=s,this.updateAgentsToggleIcon()}});this.agentsToggleWrapperElement=r,t.appendChild(r),t.appendChild(this.createToggleRow({label:"Chat",icon:"codicon-chat-rounded",keybinding:this.getKeybindingLabel("workbench.action.toggleAuxiliaryBar"),getValue:()=>this.chatEditorGroupService?this.chatEditorGroupService.hasVisibleChat():this.layoutService.isVisible("workbench.parts.auxiliarybar"),onToggle:async s=>{this.chatEditorGroupService?this.chatEditorGroupService.hasVisibleChat()!==s&&(s?this.chatEditorGroupService.hasChatEditors()?(await this.chatEditorGroupService.ensureChatVisibleOrCreate(),this.layoutService.setPartHidden(!1,"workbench.parts.auxiliarybar")):await this.commandService.executeCommand("workbench.action.toggleAuxiliaryBar"):await this.chatEditorGroupService.hideChatEditorGroup()):await this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.auxiliarybar"),"workbench.action.toggleAuxiliaryBar")}}));const o=this.createToggleRow({label:"Editors",icon:"codicon-file-rounded",keybinding:this.getKeybindingLabel("workbench.action.toggleEditorVisibility"),getValue:()=>this.layoutService.isVisible("workbench.parts.editor",fi),onToggle:s=>this.setEditorsVisible(s)});this.editorsToggleWrapperElement=o,t.appendChild(o),t.appendChild(this.createToggleRow({label:"Panel",icon:this.getPanelToggleIconClass(),keybinding:this.getKeybindingLabel("workbench.action.togglePanel"),getValue:()=>this.layoutService.isVisible("workbench.parts.panel"),onToggle:s=>this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.panel"),"workbench.action.togglePanel"),onIconElementCreated:s=>{this.panelToggleIconElement=s,this.updatePanelToggleIcon()}})),t.appendChild(this.createToggleRow({label:"Sidebar",icon:this.getCodiconClass(this.getPanelBaseIcon(this.getSidebarIconDirection(),!this.isSidebarVisible())),keybinding:this.getKeybindingLabel("workbench.action.toggleSidebarVisibility"),getValue:()=>this.layoutService.isVisible("workbench.parts.sidebar"),onToggle:s=>this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.sidebar"),"workbench.action.toggleSidebarVisibility"),onIconElementCreated:s=>{this.sidebarToggleIconElement=s,this.updateSidebarToggleIcon()}})),n.appendChild(this.createDivider());const a=this.createSection(n);a.appendChild(this.createSubmenuRow({label:this.getSidebarPositionLabel(),getValue:()=>this.getSidebarLocation(),options:this.getSidebarPositionOptionDefinitions(),onSelect:async s=>{await this.agentLayoutService.setUnifiedSidebarLocation(s),this.updateSidebarPositionOptions(),this.renderModeGrid()},registerOption:s=>this.sidebarPositionOptions.push(s),onValueElementCreated:s=>this.sidebarPositionValueElement=s,onLabelElementCreated:s=>this.sidebarPositionLabelElement=s})),a.appendChild(this.createDivider());if(this.isTitlebarVisibilityControlEnabled()){const s=this.createToggleRow({label:"Title Bar",getValue:()=>this.getTitlebarVisibility()==="show",onToggle:async c=>{const h=c?"show":"hide";await this.setTitlebarVisibilityPreference(h)}});this.titlebarVisibilityWrapperElement=s,a.appendChild(s)}a.appendChild(this.createToggleRow({label:"Status Bar",keybinding:this.getKeybindingLabel("workbench.action.toggleStatusbarVisibility"),getValue:()=>this.layoutService.isVisible("workbench.parts.statusbar",fi),onToggle:s=>this.ensureCommandState(s,()=>this.layoutService.isVisible("workbench.parts.statusbar",fi),"workbench.action.toggleStatusbarVisibility")})),n.appendChild(this.createDivider()),this.appendCursorSettingsButton(n),this.appendGlassWindowButton(n)}'
    },
    @{
        Name                = "appendCursorSettingsButton_keybinding_320p6"
        AllowLengthMismatch = $true
        Search  = 'appendCursorSettingsButton(n){const e=document.createElement("button");e.type="button",e.className="agent-layout-quick-menu__footer-link";const t=document.createElement("span");t.className="agent-layout-quick-menu__label",t.textContent=E(2939,null),e.appendChild(t),e.addEventListener("click",i=>{i.stopPropagation(),this.commandService.executeCommand(sB).finally(()=>this.onRequestClose())}),n.appendChild(e)}'
        Replace = 'appendCursorSettingsButton(n){const e=document.createElement("button");e.type="button",e.className="agent-layout-quick-menu__footer-link";const t=document.createElement("span");t.className="agent-layout-quick-menu__label",t.textContent="Cursor Settings",e.appendChild(t);const i=this.getKeybindingLabel(sB);if(i){const r=document.createElement("span");r.className="agent-layout-quick-menu__keybinding",r.textContent=i,e.appendChild(r)}e.addEventListener("click",o=>{o.stopPropagation(),this.commandService.executeCommand(sB).finally(()=>this.onRequestClose())}),n.appendChild(e)}'
    }
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    if ([string]::IsNullOrEmpty($Color)) { $Color = "White" }
    Write-Host $Message -ForegroundColor $Color
}
function Test-CursorNotRunning {
    if (Get-Process -Name "Cursor" -ErrorAction SilentlyContinue) {
        Write-ColorOutput "ERROR: Close Cursor completely first." "Red"
        exit 1
    }
}
function Get-LatestBackup {
    param($Dir, $Pattern)
    $b = Get-ChildItem $Dir -Filter $Pattern -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    if ($b -and $b.Count -gt 0) { return $b[0] }
    return $null
}
function Get-WorkbenchBackupWithPatchTargets {
    param($Dir, $Pattern)
    foreach ($bu in (Get-ChildItem $Dir -Filter $Pattern -ErrorAction SilentlyContinue | Sort-Object Length -Descending)) {
        $txt = [IO.File]::ReadAllText($bu.FullName, [Text.Encoding]::UTF8)
        if ($txt.Contains("getDefaultLayouts(){return") -or $txt.Contains("buildContent(n){this.customLayouts=this.loadCustomLayoutsFromStorage()")) { return $bu }
    }
    return $null
}
function Compute-FileChecksum {
    param([string]$FilePath)
    $bytes  = [System.IO.File]::ReadAllBytes($FilePath)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hash   = $sha256.ComputeHash($bytes)
    $sha256.Dispose()
    $b64 = [System.Convert]::ToBase64String($hash)
    return $b64.Replace('+', '-').Replace('/', '_').TrimEnd('=')
}
function Update-ProductJsonChecksum { param($ChecksumKey, $NewChecksum)
    $content = [IO.File]::ReadAllText($ProductJsonFile, [Text.Encoding]::UTF8)
    $pat = "(`"$([regex]::Escape($ChecksumKey))`"\s*:\s*`")[^`"]*(`")"
    if ($content -notmatch $pat) { Write-ColorOutput "WARNING: Could not update $ChecksumKey" "Yellow"; return $false }
    $new = [regex]::Replace($content, $pat, "`${1}$NewChecksum`${2}")
    if ($new -eq $content) { return $true }
    [IO.File]::WriteAllText($ProductJsonFile, $new, [Text.UTF8Encoding]::new($false))
    $true
}
function Update-ProductJsonChecksumWithFallback { param($ChecksumKeys, $NewChecksum, $DisplayName)
    foreach ($k in $ChecksumKeys) { if (Update-ProductJsonChecksum $k $NewChecksum) { return $true } }
    Write-ColorOutput "WARNING: Could not update $DisplayName" "Yellow"; $false
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
function Get-PatchClassification { param($Content)
    $to = @(); $done = @(); $broken = @()
    foreach ($p in $Patches) {
        if ($Content.Contains($p.Replace)) { $done += $p.Name }
        elseif ($Content.Contains($p.Search)) { $to += $p }
        else { $broken += $p.Name }
    }
    @{ ToApply = $to; AlreadyApplied = $done; Broken = $broken }
}

function Invoke-Restore {
    Write-ColorOutput "=== Restore ===" "Cyan"
    Test-CursorNotRunning
    $wb = Get-LatestBackup $TargetDir $BackupPattern
    if (!$wb) { Write-ColorOutput "ERROR: No backup found." "Red"; exit 1 }
    Copy-Item $wb.FullName $TargetFile -Force
    Write-ColorOutput "Restored: $($wb.Name)" "Green"
    $pj = Get-LatestBackup (Split-Path $ProductJsonFile -Parent) $ProductBackupPattern
    if ($pj) { Copy-Item $pj.FullName $ProductJsonFile -Force; Write-ColorOutput "Restored product.json" "Green" }
    if (Test-Path $NlsMessagesFile) { $nls = Get-LatestBackup (Split-Path $NlsMessagesFile -Parent) $NlsBackupPattern; if ($nls) { Copy-Item $nls.FullName $NlsMessagesFile -Force } }
    Write-ColorOutput "Done. Start Cursor." "Green"
}

function Invoke-Patch {
    Write-ColorOutput "=== Cursor Layout Patcher (3.2.0-pre.6) ===" "Cyan"
    if (!(Test-Path $TargetFile)) { Write-ColorOutput "ERROR: Workbench not found." "Red"; exit 1 }
    if (!(Test-Path $ProductJsonFile)) { Write-ColorOutput "ERROR: product.json not found." "Red"; exit 1 }
    Test-CursorNotRunning

    $content = [IO.File]::ReadAllText($TargetFile, [Text.Encoding]::UTF8)
    $cls = Get-PatchClassification $content
    $toApply = $cls.ToApply
    $done = $cls.AlreadyApplied
    $broken = $cls.Broken

    foreach ($n in $done) { Write-ColorOutput "  Already: $n" "Gray" }

    if ($toApply.Count -eq 0 -and $broken.Count -gt 0 -and $done.Count -gt 0) {
        $rec = Get-WorkbenchBackupWithPatchTargets $TargetDir $BackupPattern
        if ($rec) {
            Write-ColorOutput "Recovering from backup (version mismatch)..." "Yellow"
            Copy-Item $rec.FullName $TargetFile -Force
            $content = [IO.File]::ReadAllText($TargetFile, [Text.Encoding]::UTF8)
            $cls = Get-PatchClassification $content
            $toApply = $cls.ToApply
            $done = $cls.AlreadyApplied
            $broken = $cls.Broken
        }
    }

    if ($toApply.Count -eq 0 -and $done.Count -gt 0) {
        Write-ColorOutput "`nAll patches applied." "Green"
        Request-DisableAutoUpdates
        exit 0
    }

    if ($broken.Count -gt 0) {
        Write-ColorOutput "`nWARNING: Targets not found: $($broken -join ', ')" "Yellow"
        if ($toApply.Count -eq 0) { Write-ColorOutput "Use patcher for your Cursor version." "Red"; exit 1 }
    }

    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $wbPath = Join-Path $TargetDir "workbench.desktop.main.js.backup.$ts"
    $pjPath = Join-Path (Split-Path $ProductJsonFile -Parent) "product.json.backup.$ts"
    Copy-Item $TargetFile $wbPath -Force
    Copy-Item $ProductJsonFile $pjPath -Force
    $nlsPath = $null
    if (Test-Path $NlsMessagesFile) { $nlsPath = Join-Path (Split-Path $NlsMessagesFile -Parent) "nls.messages.json.backup.$ts"; Copy-Item $NlsMessagesFile $nlsPath -Force }

    try {
        $patched = $content
        foreach ($p in $toApply) { $patched = $patched.Replace($p.Search, $p.Replace); Write-ColorOutput "  Patched: $($p.Name)" "Green" }
        if ($patched -ne $content) { [IO.File]::WriteAllText($TargetFile, $patched, [Text.UTF8Encoding]::new($false)) }

        if (Test-Path $NlsMessagesFile) {
            $nls = [IO.File]::ReadAllText($NlsMessagesFile, [Text.Encoding]::UTF8)
            if ($nls.Contains($NlsCorruptPatch.Search)) { $nls = $nls.Replace($NlsCorruptPatch.Search, $NlsCorruptPatch.Replace); [IO.File]::WriteAllText($NlsMessagesFile, $nls, [Text.UTF8Encoding]::new($false)); Write-ColorOutput "  Patched nls" "Green" }
        }

        $bs = Get-LatestBackup $BootstrapDir $BootstrapBackupPattern
        if ($bs -and (Test-Path $BootstrapFile) -and ((Get-Item $BootstrapFile).Length -ne $bs.Length)) { Copy-Item $bs.FullName $BootstrapFile -Force; Write-ColorOutput "  Restored workbench.js" "Green" }

        $wbSum = Compute-FileChecksum -FilePath $TargetFile
        Update-ProductJsonChecksumWithFallback @("vs/workbench/workbench.desktop.main.js","out/vs/workbench/workbench.desktop.main.js") $wbSum "workbench" | Out-Null
        if (Test-Path $BootstrapFile) {
            $bsSum = Compute-FileChecksum -FilePath $BootstrapFile
            Update-ProductJsonChecksumWithFallback @("vs/code/electron-sandbox/workbench/workbench.js","out/vs/code/electron-sandbox/workbench/workbench.js") $bsSum "workbench.js" | Out-Null
        }

        $cursorAppData = Join-Path $env:APPDATA "Cursor"
        foreach ($cf in @("Code Cache","Cache","CachedData")) {
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
