# Update Jarvis V3 desktop shortcut and test launch
# - Deletes obsolete convert-logo-to-ico.ps1 if present
# - Updates existing desktop shortcut properties and icon
# - Verifies shortcut fields
# - Launches Jarvis via the shortcut and checks http://localhost:8501
# - Detects if any new visible PowerShell window appears during launch
# - Exits cleanly (no infinite loops, no hanging commands)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$projectRoot   = 'C:\Users\yosiw\Desktop\JarvisV3\JarvisV3'
$shortcutPath  = 'C:\Users\yosiw\Desktop\Jarvis V3.lnk'
$obsoleteScript = Join-Path $projectRoot 'convert-logo-to-ico.ps1'

$scriptWasDeleted = $false
$shortcutExists   = $false
$jarvisRunning    = $false
$newVisiblePS     = $false

Write-Host '===== STEP 1: Cleanup obsolete icon script =====' -ForegroundColor Cyan
if (Test-Path $obsoleteScript) {
    Remove-Item $obsoleteScript -Force
    $scriptWasDeleted = $true
    Write-Host "Deleted obsolete script: $obsoleteScript" -ForegroundColor Yellow
} else {
    Write-Host "Obsolete script not found (nothing to delete): $obsoleteScript" -ForegroundColor Gray
}

Write-Host "" 
Write-Host '===== STEP 2: Update desktop shortcut properties and icon =====' -ForegroundColor Cyan

try {
    $shell = New-Object -ComObject WScript.Shell
} catch {
    Write-Host 'ERROR: Failed to create WScript.Shell COM object.' -ForegroundColor Red
    throw
}

if (Test-Path $shortcutPath) {
    $shortcutExists = $true
    $shortcut = $shell.CreateShortcut($shortcutPath)

    # Required properties
    $shortcut.TargetPath      = 'C:\Windows\System32\wscript.exe'
    $vbsPath                  = Join-Path $projectRoot 'launch-jarvis-hidden.vbs'
    $shortcut.Arguments       = '"' + $vbsPath + '"'
    $shortcut.WorkingDirectory = $projectRoot

    # Icon from shell32.dll, try preferred index then fallbacks
    $iconCandidates = @(167, 43, 220)
    foreach ($idx in $iconCandidates) {
        try {
            $shortcut.IconLocation = "C:\\Windows\\System32\\shell32.dll,$idx"
            break
        } catch {
            # Try next index
        }
    }

    $shortcut.Save()
    Write-Host 'Shortcut updated successfully.' -ForegroundColor Green
} else {
    Write-Host "Shortcut not found: $shortcutPath" -ForegroundColor Red
}

Write-Host "" 
Write-Host '===== STEP 3: Verify shortcut and test Jarvis launch =====' -ForegroundColor Cyan

if ($shortcutExists) {
    # 3.1 Read back shortcut values
    $verifyShortcut = $shell.CreateShortcut($shortcutPath)

    Write-Host "ShortcutExists: True"
    Write-Host "TargetPath: $($verifyShortcut.TargetPath)"
    Write-Host "Arguments: $($verifyShortcut.Arguments)"
    Write-Host "WorkingDirectory: $($verifyShortcut.WorkingDirectory)"
    Write-Host "IconLocation: $($verifyShortcut.IconLocation)"

    # Helper to count visible PowerShell console windows
    function Get-VisiblePowerShellCount {
        try {
            @(Get-Process -Name 'powershell' -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }).Count
        } catch {
            0
        }
    }

    $visiblePSBefore = Get-VisiblePowerShellCount

    # 3.2 Launch Jarvis via the shortcut
    Write-Host "`nLaunching Jarvis via shortcut..." -ForegroundColor Yellow
    Start-Process -FilePath $shortcutPath

    Write-Host 'Waiting 20 seconds for Jarvis to start...' -ForegroundColor Gray
    Start-Sleep -Seconds 20

    # 3.3 Check HTTP endpoint
    try {
        $response = Invoke-WebRequest -Uri 'http://localhost:8501' -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            $jarvisRunning = $true
        }
    } catch {
        $jarvisRunning = $false
    }

    Write-Host "JarvisRunning: $jarvisRunning"

    # 3.4 Detect new visible PowerShell windows
    $visiblePSAfter = Get-VisiblePowerShellCount
    if ($visiblePSAfter -gt $visiblePSBefore) {
        $newVisiblePS = $true
    } else {
        $newVisiblePS = $false
    }

    Write-Host "NewVisiblePowerShellWindowDuringLaunch: $newVisiblePS"
} else {
    Write-Host 'ShortcutExists: False' -ForegroundColor Red
}

Write-Host "" 
Write-Host '===== STEP 4: FINAL REPORT =====' -ForegroundColor Magenta
Write-Host 'Obsolete Script:' -ForegroundColor Yellow
Write-Host "  - convert-logo-to-ico.ps1 deleted: $scriptWasDeleted"

Write-Host "`nShortcut Configuration:" -ForegroundColor Yellow
Write-Host "  - Shortcut Path: $shortcutPath"
if ($shortcutExists) {
    Write-Host "  - TargetPath: $($verifyShortcut.TargetPath)"
    Write-Host "  - Arguments: $($verifyShortcut.Arguments)"
    Write-Host "  - WorkingDirectory: $($verifyShortcut.WorkingDirectory)"
    Write-Host "  - IconLocation: $($verifyShortcut.IconLocation)"
}

Write-Host "`nLaunch Test:" -ForegroundColor Yellow
Write-Host "  - JarvisRunning: $jarvisRunning"
Write-Host "  - NewVisiblePowerShellWindowDuringLaunch: $newVisiblePS"

Write-Host "`nScript completed and exiting cleanly." -ForegroundColor Green

if ($shell) {
    try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null } catch {}
}
