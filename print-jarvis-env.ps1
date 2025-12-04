# ========================================
# JarvisV3 - Environment Variable Helper
# ========================================
# This script prints the NAMES of Jarvis-related environment
# variables that are currently defined in the local .env file.
# It NEVER prints the values.

$ErrorActionPreference = 'Stop'

# Try to resolve the project root based on this script's location
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) {
    $projectRoot = Split-Path -Parent $scriptPath
} else {
    $projectRoot = Get-Location
}

$envFile = Join-Path $projectRoot '.env'

if (-not (Test-Path $envFile)) {
    Write-Host "No .env file found in $projectRoot." -ForegroundColor Yellow
    Write-Host "Create one (for example by copying .env.example) and try again." -ForegroundColor Yellow
    exit 0
}

# Known Jarvis environment variables (keep in sync with JARVIS_CLOUD_ENV_VARS.md)
$knownVars = @(
    'OPENAI_API_KEY',
    'OPENAI_MODEL',
    'VOICE',
    'VAD',
    'DEVICE',
    'INCLUDE_DATE',
    'INCLUDE_TIME',
    'FUNCTION_CALLING',
    'INITIAL_PROMPT'
)

$lines = Get-Content -Path $envFile -ErrorAction Stop
$present = @()

foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if (-not $trimmed) { continue }
    if ($trimmed.StartsWith('#')) { continue }

    $eqIndex = $trimmed.IndexOf('=')
    if ($eqIndex -lt 1) { continue }

    $name = $trimmed.Substring(0, $eqIndex).Trim()
    if ($knownVars -contains $name) {
        if (-not ($present -contains $name)) {
            $present += $name
        }
    }
}

Write-Host "Jarvis env variables currently defined in .env:" -ForegroundColor Cyan

if ($present.Count -eq 0) {
    Write-Host "- (none of the known Jarvis variables are set yet)" -ForegroundColor Yellow
} else {
    foreach ($name in $present) {
        Write-Host "- $name" -ForegroundColor Green
    }
}
