# ========================================
# JarvisV3 Startup Script
# ========================================
# This script handles all setup and runs the Jarvis assistant
# Double-click this file to start Jarvis!

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   🤖 Starting JarvisV3 Assistant" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the script directory (project root)
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

Write-Host "📁 Project directory: $ProjectRoot" -ForegroundColor Yellow
Write-Host ""

# ========================================
# Step 1: Check for .env file
# ========================================
if (-Not (Test-Path ".env")) {
    Write-Host "⚠️  WARNING: .env file not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create a .env file based on .env.example:" -ForegroundColor Yellow
    Write-Host "  1. Copy .env.example to .env" -ForegroundColor Yellow
    Write-Host "  2. Edit .env and add your OpenAI API key" -ForegroundColor Yellow
    Write-Host "  3. Run this script again" -ForegroundColor Yellow
    Write-Host ""
    
    $createEnv = Read-Host "Would you like me to create .env from .env.example now? (y/n)"
    if ($createEnv -eq "y" -or $createEnv -eq "Y") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ Created .env file. Please edit it and add your OpenAI API key, then run this script again." -ForegroundColor Green
        Write-Host ""
        Write-Host "Press any key to open .env in notepad..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        notepad.exe ".env"
    }
    
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "✅ Found .env configuration file" -ForegroundColor Green
Write-Host ""

# ========================================
# Step 2: Check Python installation
# ========================================
Write-Host "🔍 Checking Python installation..." -ForegroundColor Yellow

try {
    $pythonVersion = & python --version 2>&1
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Python is not installed or not in PATH!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Python 3.11 or higher from:" -ForegroundColor Yellow
    Write-Host "  https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""

# ========================================
# Step 3: Check/Create Virtual Environment
# ========================================
if (Test-Path "venv") {
    Write-Host "✅ Virtual environment exists" -ForegroundColor Green
} else {
    Write-Host "📦 Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ ERROR: Failed to create virtual environment!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    Write-Host "✅ Virtual environment created" -ForegroundColor Green
}

Write-Host ""

# ========================================
# Step 4: Activate Virtual Environment
# ========================================
Write-Host "🔄 Activating virtual environment..." -ForegroundColor Yellow

$venvActivate = Join-Path $ProjectRoot "venv\Scripts\Activate.ps1"

if (Test-Path $venvActivate) {
    & $venvActivate
    Write-Host "✅ Virtual environment activated" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: Cannot find activation script!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""

# ========================================
# Step 5: Install/Update Dependencies
# ========================================
Write-Host "📦 Checking dependencies..." -ForegroundColor Yellow

# Check if requirements.txt exists
if (-Not (Test-Path "requirements.txt")) {
    Write-Host "❌ ERROR: requirements.txt not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Always ensure pip is up to date
Write-Host "  → Upgrading pip..." -ForegroundColor Gray
python -m pip install --upgrade pip --quiet

# Install dependencies
Write-Host "  → Installing dependencies from requirements.txt..." -ForegroundColor Gray
python -m pip install -r requirements.txt --quiet

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  WARNING: Some dependencies may have failed to install" -ForegroundColor Yellow
    Write-Host "  This may affect functionality, especially audio features" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Note: PyAudio may require additional system setup on Windows" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
}

Write-Host ""

# ========================================
# Step 6: Launch Jarvis
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   🚀 Launching Jarvis Assistant..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The app will open in your default web browser." -ForegroundColor Yellow
Write-Host "If it doesn't open automatically, navigate to:" -ForegroundColor Yellow
Write-Host "  http://localhost:8501" -ForegroundColor White
Write-Host ""
Write-Host "To stop Jarvis, press Ctrl+C in this window." -ForegroundColor Yellow
Write-Host ""

# Small delay to let user read the messages
Start-Sleep -Seconds 2

# Run Streamlit
streamlit run app.py

# ========================================
# Cleanup
# ========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   👋 Jarvis has been stopped" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
