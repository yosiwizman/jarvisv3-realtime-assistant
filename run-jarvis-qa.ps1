# ========================================
# JarvisV3 - One-Shot QA Helper
# ========================================
# This script runs a small set of non-destructive checks:
# - Environment file and env var name check (via print-jarvis-env.ps1)
# - Local desktop start/health/stop check
# - Docker test script (cloud-style simulation)
#
# It does not change any configuration or secrets, and it never prints
# environment variable values.

$ErrorActionPreference = 'Stop'

# Resolve project root based on this script's location
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) {
    $projectRoot = Split-Path -Parent $scriptPath
} else {
    $projectRoot = Get-Location
}

Set-Location $projectRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   JarvisV3 QA helper starting" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Project root: $projectRoot" -ForegroundColor Yellow
Write-Host "" 

# Track results
$envFilePresent = Test-Path (Join-Path $projectRoot '.env')
$envNamesCheckPassed = $true
$localHealthPassed = $true
$dockerTestPassed = $true

# ----------------------------------------
# [1/3] Environment variables check
# ----------------------------------------
Write-Host "[1/3] Environment variables check" -ForegroundColor Cyan

if ($envFilePresent) {
    Write-Host "Found .env file in project root." -ForegroundColor Green
} else {
    Write-Host "No .env file found in project root (Env vars file present: No)." -ForegroundColor Yellow
}

$printEnvScript = Join-Path $projectRoot 'print-jarvis-env.ps1'
if (Test-Path $printEnvScript) {
    try {
        & $printEnvScript
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Env var names helper exited with code $LASTEXITCODE." -ForegroundColor Yellow
            $envNamesCheckPassed = $false
        }
    } catch {
        Write-Host "Env var names check FAILED: $($_.Exception.Message)" -ForegroundColor Red
        $envNamesCheckPassed = $false
    }
} else {
    Write-Host "print-jarvis-env.ps1 not found; skipping env name check." -ForegroundColor Yellow
    $envNamesCheckPassed = $false
}

Write-Host "" 

# ----------------------------------------
# [2/3] Local desktop start / health / stop
# ----------------------------------------
Write-Host "[2/3] Local desktop start/health/stop" -ForegroundColor Cyan

$localHealthPassed = $true
$runScript = Join-Path $projectRoot 'run-jarvis.ps1'
$stopScript = Join-Path $projectRoot 'stop-jarvis.ps1'

if (-not (Test-Path $runScript)) {
    Write-Host "run-jarvis.ps1 not found; cannot perform local start check." -ForegroundColor Red
    $localHealthPassed = $false
} elseif (-not (Test-Path $stopScript)) {
    Write-Host "stop-jarvis.ps1 not found; cannot perform local stop check." -ForegroundColor Red
    $localHealthPassed = $false
} else {
    try {
        Write-Host "Starting Jarvis via run-jarvis.ps1 in a separate PowerShell window..." -ForegroundColor Yellow
        $startArgs = @('-NoLogo','-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$runScript`"")
        $runProc = Start-Process -FilePath 'powershell.exe' -ArgumentList $startArgs -WindowStyle Normal -PassThru

        Write-Host "Waiting 25 seconds for Jarvis to start on http://localhost:8501 ..." -ForegroundColor Yellow
        Start-Sleep -Seconds 25

        try {
            $resp = Invoke-WebRequest -Uri 'http://localhost:8501' -UseBasicParsing -TimeoutSec 10
            if ($resp.StatusCode -eq 200) {
                Write-Host "Local health check: UI reachable at http://localhost:8501 (StatusCode=200)" -ForegroundColor Green
            } else {
                Write-Host "Local health check returned unexpected status code $($resp.StatusCode)." -ForegroundColor Yellow
                $localHealthPassed = $false
            }
        } catch {
            Write-Host "Local health check FAILED: $($_.Exception.Message)" -ForegroundColor Red
            $localHealthPassed = $false
        }
    } catch {
        Write-Host "Failed to start run-jarvis.ps1: $($_.Exception.Message)" -ForegroundColor Red
        $localHealthPassed = $false
    } finally {
        Write-Host "Attempting to stop Jarvis via stop-jarvis.ps1..." -ForegroundColor Yellow
        try {
            & $stopScript
        } catch {
            Write-Host "Warning: stop-jarvis.ps1 reported an error: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    }
}

Write-Host "" 

# ----------------------------------------
# [3/3] Docker local test (cloud simulation)
# ----------------------------------------
Write-Host "[3/3] Docker local test (cloud simulation)" -ForegroundColor Cyan

$dockerTestPassed = $true
$dockerTestScript = Join-Path $projectRoot 'test-jarvis-docker.ps1'

if (Test-Path $dockerTestScript) {
    try {
        & $dockerTestScript
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Docker test script completed successfully." -ForegroundColor Green
        } else {
            Write-Host "Docker test script FAILED with exit code $LASTEXITCODE." -ForegroundColor Red
            $dockerTestPassed = $false
        }
    } catch {
        Write-Host "Docker test script threw an error: $($_.Exception.Message)" -ForegroundColor Red
        $dockerTestPassed = $false
    }
} else {
    Write-Host "test-jarvis-docker.ps1 not found; skipping Docker test." -ForegroundColor Yellow
    $dockerTestPassed = $false
}

Write-Host "" 

# ----------------------------------------
# Summary
# ----------------------------------------
Write-Host "JarvisV3 QA summary:" -ForegroundColor Cyan
Write-Host ("- Env vars file present: " + ($(if ($envFilePresent) { 'Yes' } else { 'No' })))
Write-Host ("- Env var names check: " + ($(if ($envNamesCheckPassed) { 'PASS' } else { 'FAIL' })))
Write-Host ("- Local start/health: " + ($(if ($localHealthPassed) { 'PASS' } else { 'FAIL' })))
Write-Host ("- Docker test script: " + ($(if ($dockerTestPassed) { 'PASS' } else { 'FAIL' })))

if (-not $envFilePresent -or -not $envNamesCheckPassed -or -not $localHealthPassed -or -not $dockerTestPassed) {
    Write-Host "" 
    Write-Host "One or more checks FAILED. Please review the messages above before releasing." -ForegroundColor Red
    exit 1
} else {
    Write-Host "" 
    Write-Host "All QA checks passed." -ForegroundColor Green
    exit 0
}
