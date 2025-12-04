# ========================================
# JarvisV3 - Docker Test Script
# ========================================
# This script builds the Docker image, runs it on a test port,
# checks that the UI is reachable, and then cleans up the container.
#
# It does NOT change any existing launcher behavior. Use this as a
# local "cloud simulation" check similar to Railway/Render.

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Constants
$projectRoot   = 'C:\Users\yosiw\Desktop\JarvisV3\JarvisV3'
$imageName     = 'jarvisv3-docker-test'
$containerName = 'jarvisv3-docker-test-container'
$hostPort      = 8585   # Host port we will hit in the browser
$containerPort = 8501   # Internal app port / PORT env inside container

Set-Location $projectRoot

Write-Host "=== JarvisV3 Docker test: build + run + health ===" -ForegroundColor Cyan
Write-Host "Project root: $projectRoot" -ForegroundColor Yellow
Write-Host "Image: $imageName" -ForegroundColor Yellow
Write-Host "Container: $containerName" -ForegroundColor Yellow
Write-Host "Host URL: http://localhost:$hostPort" -ForegroundColor Yellow
Write-Host "" 

# Helper: best-effort container removal
function Remove-ContainerIfExists {
    param([string]$Name)
    try {
        $id = docker ps -a --filter "name=$Name" --format "{{.ID}}" 2>$null
        if ($id) {
            Write-Host "Stopping existing container: $Name ($id)" -ForegroundColor Yellow
            try { docker stop $Name | Out-Null } catch {}
            try { docker rm $Name   | Out-Null } catch {}
            Write-Host "Existing container removed." -ForegroundColor Green
        }
    } catch {
        Write-Host "Warning: Unable to inspect/remove existing container ($Name)." -ForegroundColor DarkYellow
    }
}

# Helper: best-effort image removal
function Remove-ImageIfExists {
    param([string]$Name)
    try {
        $imgId = docker images -q $Name 2>$null
        if ($imgId) {
            Write-Host "Removing old image: $Name" -ForegroundColor Yellow
            try { docker rmi $Name -f | Out-Null } catch {
                Write-Host "Warning: Unable to remove old image $Name (it may be in use)." -ForegroundColor DarkYellow
            }
        }
    } catch {
        Write-Host "Warning: Unable to inspect/remove image ($Name)." -ForegroundColor DarkYellow
    }
}

# 1) Cleanup any previous test container/image (best effort)
Write-Host "[1/4] Cleaning up previous Docker test resources..." -ForegroundColor Cyan
Remove-ContainerIfExists -Name $containerName
# Optional: clear old test image; not strictly required
# Remove-ImageIfExists -Name $imageName
Write-Host "" 

# 2) Build image
Write-Host "[2/4] Building Docker image..." -ForegroundColor Cyan
try {
    docker build -t $imageName .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Docker build failed (exit code $LASTEXITCODE)." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Docker build threw an exception: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host "Image build completed." -ForegroundColor Green
Write-Host "" 

# 3) Run container
Write-Host "[3/4] Starting Docker container..." -ForegroundColor Cyan
$containerId = $null
try {
    $runCmd = @(
        'run', '-d',
        '--name', $containerName,
        '-p', "${hostPort}:${containerPort}",
        '-e', "PORT=${containerPort}",
        $imageName
    )
    $containerId = docker @runCmd 2>$null
} catch {
    Write-Host "ERROR: Failed to start container: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$containerId = ($containerId | Out-String).Trim()
if (-not $containerId) {
    Write-Host "ERROR: No container ID returned from docker run." -ForegroundColor Red
    exit 1
}
Write-Host "Container started: $containerId" -ForegroundColor Green

# 4) Health check + cleanup
$exitCode = 1
$url = "http://localhost:${hostPort}"

try {
    Write-Host "Waiting 20 seconds for JarvisV3 to start inside Docker..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20

    Write-Host "Checking UI at $url ..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "JarvisV3 Docker test: UI reachable at $url (StatusCode=200)" -ForegroundColor Green
            $exitCode = 0
        } else {
            Write-Host "JarvisV3 Docker test: unexpected status code $($response.StatusCode) from $url" -ForegroundColor Yellow
            $exitCode = 1
        }
    } catch {
        Write-Host "JarvisV3 Docker test: FAILED to reach $url - $($_.Exception.Message)" -ForegroundColor Red
        $exitCode = 1
    }
}
finally {
    Write-Host "[4/4] Cleaning up Docker container..." -ForegroundColor Cyan
    try {
        docker stop $containerName 2>$null | Out-Null
        docker rm   $containerName 2>$null | Out-Null
        Write-Host "Container cleaned up." -ForegroundColor Green
    } catch {
        Write-Host "Warning: Failed to stop/remove test container (it may already be gone)." -ForegroundColor DarkYellow
    }
}

exit $exitCode
