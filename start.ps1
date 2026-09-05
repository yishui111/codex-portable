# ============================================================
#  Codex Portable Platform - One-click Start Script (PowerShell)
#  Usage:
#    .\start.ps1           -> Start all (Ollama + bridge + WebUI)
#    .\start.ps1 deepseek  -> Start bridge only (DeepSeek API)
#    .\start.ps1 ollama    -> Start Ollama only (local model)
#    .\start.ps1 webui     -> Start Open WebUI only
# ============================================================

param([string]$Mode = "all")

# Resolve script directory (compatible with older PowerShell)
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
Set-Location $ScriptDir

if ($Mode -eq "help") {
    Write-Host ""
    Write-Host "  Codex Portable Platform - AI Coding Assistant"
    Write-Host ""
    Write-Host "  Usage:"
    Write-Host "    .\start.ps1           Start all services"
    Write-Host "    .\start.ps1 deepseek  Start bridge only (online API)"
    Write-Host "    .\start.ps1 ollama    Start Ollama only (local model)"
    Write-Host "    .\start.ps1 webui     Start Open WebUI only"
    Write-Host ""
    Write-Host "  Switch model:"
    Write-Host "    codex --profile deepseek  Use DeepSeek online"
    Write-Host "    codex --profile ollama    Use local qwen2.5:7b"
    Write-Host ""
    exit 0
}

# ── Check Docker ──
if ($Mode -eq "all" -or $Mode -eq "ollama" -or $Mode -eq "webui") {
    $dockerRunning = docker info 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
        exit 1
    }

    # ── Load Ollama image ──
    $imageExists = docker image inspect ollama/ollama:latest 2>$null
    if ($LASTEXITCODE -ne 0) {
        if (Test-Path "ollama-image.tar") {
            Write-Host "[First Run] Loading Ollama image (~2-5 min)..." -ForegroundColor Yellow
            docker load -i ollama-image.tar
            Write-Host "[OK] Ollama image loaded" -ForegroundColor Green
        } else {
            Write-Host "[Info] ollama-image.tar not found, pulling from network..." -ForegroundColor Yellow
            docker pull ollama/ollama:latest
        }
    }

    # ── Start Ollama ──
    Write-Host "[Starting] Ollama local model service..." -ForegroundColor Cyan
    docker compose up -d ollama
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Ollama failed to start" -ForegroundColor Red
        exit 1
    }

    # ── Pull model ──
    Write-Host "[Check] Verifying qwen2.5:7b model..."
    $modelList = docker exec ollama ollama list 2>$null
    if ($modelList -notmatch "qwen2.5:7b") {
        Write-Host "[First Run] Downloading qwen2.5:7b model (~4.7GB)..." -ForegroundColor Yellow
        docker exec ollama ollama pull qwen2.5:7b
        Write-Host "[OK] Model downloaded" -ForegroundColor Green
    } else {
        Write-Host "[OK] qwen2.5:7b model ready" -ForegroundColor Green
    }

    if ($Mode -eq "ollama") {
        Write-Host ""
        Write-Host "  Ollama local model started!" -ForegroundColor Green
        Write-Host "  Model: qwen2.5:7b (7.6B)"
        Write-Host "  Usage: codex --profile ollama"
        Write-Host "  API:   http://localhost:11434"
        Write-Host ""
        exit 0
    }
}

# ── Check Node.js ──
$nodeVersion = node --version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Node.js not found. Please install Node.js v18+" -ForegroundColor Red
    Write-Host "        Download: https://nodejs.org"
    exit 1
}

# ── Check Codex CLI ──
$codexVersion = codex --version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[Info] Codex CLI not installed, installing..." -ForegroundColor Yellow
    npm install -g @openai/codex
    Write-Host "[OK] Codex CLI installed" -ForegroundColor Green
}

# ── Start codex-bridge ──
Write-Host "[Starting] codex-bridge proxy service (port 4000)..." -ForegroundColor Cyan
$bridgePath = Join-Path $ScriptDir "codex-bridge"

# Fallback if $ScriptDir was empty
if (-not $bridgePath -or -not (Test-Path $bridgePath)) {
    $bridgePath = Join-Path (Get-Location).Path "codex-bridge"
}
if (-not (Test-Path $bridgePath)) {
    Write-Host "[ERROR] codex-bridge directory not found at: $bridgePath" -ForegroundColor Red
    exit 1
}

$envPath = Join-Path $bridgePath ".env"
if (-not (Test-Path $envPath)) {
    Write-Host "[ERROR] codex-bridge\.env not found" -ForegroundColor Red
    Write-Host "        Copy env.example to .env and fill in DeepSeek API Key"
    exit 1
}

# Check if port 4000 is already in use
$portInUse = Get-NetTCPConnection -LocalPort 4000 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "[Skip] Port 4000 already in use, bridge may already be running" -ForegroundColor Yellow
} else {
    Write-Host "[Info] Bridge path: $bridgePath"
    try {
        $proc = Start-Process -FilePath "node" -ArgumentList "--env-file=.env","proxy.mjs" -WorkingDirectory $bridgePath -WindowStyle Minimized -PassThru -ErrorAction Stop
        Write-Host "[OK] codex-bridge started in background (PID: $($proc.Id))" -ForegroundColor Green
        Start-Sleep -Seconds 2
    } catch {
        Write-Host "[ERROR] Failed to start codex-bridge: $_" -ForegroundColor Red
        Write-Host "        Manual start: cd $bridgePath; node --env-file=.env proxy.mjs" -ForegroundColor Yellow
        exit 1
    }
}

Set-Location $ScriptDir

# ── WebUI section ──
if ($Mode -eq "all" -or $Mode -eq "webui") {
    Write-Host ""
    Write-Host "[Starting] Open WebUI chat interface..." -ForegroundColor Cyan

    # Load image
    $imageExists = docker image inspect ghcr.io/open-webui/open-webui:main 2>$null
    if ($LASTEXITCODE -ne 0) {
        if (Test-Path "open-webui-image.tar") {
            Write-Host "[First Run] Loading Open WebUI image (~2-3 min)..." -ForegroundColor Yellow
            docker load -i open-webui-image.tar
            Write-Host "[OK] Image loaded" -ForegroundColor Green
        } else {
            Write-Host "[Info] Image not found locally, pulling from network..." -ForegroundColor Yellow
            docker pull ghcr.io/open-webui/open-webui:main
        }
    }

    docker compose up -d open-webui
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Open WebUI failed to start" -ForegroundColor Red
        exit 1
    }
    Write-Host "[OK] Open WebUI started (port 3001)" -ForegroundColor Green
}

# ── Done ──
Write-Host ""
Write-Host "  =================================================" -ForegroundColor Green
Write-Host "   Startup Complete!" -ForegroundColor Green
Write-Host "  =================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Open WebUI:     http://localhost:3001"
Write-Host "  Bridge Proxy:   http://localhost:4000"
Write-Host "  Ollama API:     http://localhost:11434"
Write-Host ""
Write-Host "  Usage:"
Write-Host "    `$env:CODEX_HOME = `"$ScriptDir\config`""
Write-Host "    codex --profile deepseek   Online DeepSeek API"
Write-Host "    codex --profile ollama     Local qwen2.5:7b"
Write-Host "    codex                      Default (DeepSeek)"
Write-Host ""
Write-Host "  [Tip] Set CODEX_HOME environment variable first!"
Write-Host ""
