# ========================================
# JarvisV3 Stop Script (Panic Button)
# ========================================
# Safely stops the Jarvis/Streamlit server if it is running.
#
# Behavior:
# - Looks for python/pythonw processes running `streamlit run app.py`.
# - Also checks for any process listening on port 8501.
# - Attempts a graceful Stop-Process first, then a force kill as fallback.
# - Provides clear console messages about what it is doing.
# - Finally checks http://localhost:8501 to confirm the port is free.

$ErrorActionPreference = 'Stop'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   JarvisV3 Stop Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" 

# Helper: safely get processes via CIM
function Get-JarvisProcessCandidates {
    $candidates = @()

    # 1) Find python processes whose command line looks like `streamlit run app.py`
    try {
        $pythonProcs = Get-CimInstance Win32_Process -Filter "Name='python.exe' OR Name='pythonw.exe'" -ErrorAction Stop
        foreach ($p in $pythonProcs) {
            $cmd = $p.CommandLine
            if ($cmd -and ($cmd -match '(?i)streamlit.+run.+app\.py')) {
                $candidates += [PSCustomObject]@{
                    Pid         = [int]$p.ProcessId
                    Name        = $p.Name
                    CommandLine = $cmd
                    Source      = 'CommandLine'
                }
            }
        }
    } catch {
        Write-Host "Warning: Unable to inspect python processes via CIM ("$_")." -ForegroundColor Yellow
    }

    # 2) Find any process listening on port 8501 (Streamlit default)
    try {
        $conns = Get-NetTCPConnection -LocalPort 8501 -State Listen -ErrorAction Stop
        foreach ($c in $conns) {
            $procId = [int]$c.OwningProcess
            if (-not ($candidates | Where-Object { $_.Pid -eq $procId })) {
                $name = $null
                $cmd  = $null
                try {
                    $wmi = Get-CimInstance Win32_Process -Filter "ProcessId=$procId" -ErrorAction Stop
                    $name = $wmi.Name
                    $cmd  = $wmi.CommandLine
                } catch {
                    # Best-effort only
                }

                $candidates += [PSCustomObject]@{
                    Pid         = $procId
                    Name        = $name
                    CommandLine = $cmd
                    Source      = 'Port8501'
                }
            }
        }
    } catch {
        Write-Host "Warning: Unable to inspect TCP connections on port 8501 ("$_")." -ForegroundColor Yellow
    }

    # De-duplicate by PID
    $candidates | Sort-Object Pid -Unique
}

Write-Host "Searching for Jarvis/Streamlit processes..." -ForegroundColor Yellow
$candidates = Get-JarvisProcessCandidates

if (-not $candidates -or $candidates.Count -eq 0) {
    Write-Host "No Jarvis/Streamlit process is currently running." -ForegroundColor Green
    Write-Host "" 
    return
}

Write-Host "Found $($candidates.Count) candidate process(es)." -ForegroundColor Yellow

foreach ($procInfo in $candidates) {
    $procId = $procInfo.Pid
    $name   = $procInfo.Name
    $cmd    = $procInfo.CommandLine
    $src    = $procInfo.Source

    Write-Host "----------------------------------------" -ForegroundColor DarkCyan
    Write-Host "Stopping Jarvis process PID=$procId (Name=$name, Source=$src)" -ForegroundColor Yellow
    if ($cmd) {
        Write-Host "  Command: $cmd" -ForegroundColor DarkGray
    }

    try {
        Stop-Process -Id $procId -ErrorAction Stop
        Write-Host "  -> Stopped gracefully." -ForegroundColor Green
    } catch {
        Write-Host "  -> Graceful stop failed, attempting force kill..." -ForegroundColor Yellow
        try {
            Stop-Process -Id $procId -Force -ErrorAction Stop
            Write-Host "  -> Force-killed process PID=$procId." -ForegroundColor Red
        } catch {
            Write-Host "  -> ERROR: Unable to stop process PID=$procId ("$_")." -ForegroundColor Red
        }
    }
}

Write-Host "" 
Write-Host "Waiting a few seconds to let ports close..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Final check: see if http://localhost:8501 is still responding
Write-Host "Checking http://localhost:8501..." -ForegroundColor Yellow

$portFree = $false
try {
    $response = Invoke-WebRequest -Uri 'http://localhost:8501' -TimeoutSec 5 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "WARNING: http://localhost:8501 is still responding. Another process may be using this port." -ForegroundColor Yellow
    } else {
        $portFree = $true
    }
} catch {
    $portFree = $true
}

if ($portFree) {
    Write-Host "Port 8501 is now free. Jarvis/Streamlit should be fully stopped." -ForegroundColor Green
}

Write-Host "" 
Write-Host "JarvisV3 stop script finished." -ForegroundColor Cyan
