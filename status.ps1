# ============================================================
#  Codex 便携平台 — 状态检查 (PowerShell)
# ============================================================

Set-Location $PSScriptRoot

Write-Host ""
Write-Host "  Codex 便携平台 — 服务状态"

# ── Ollama ──
$ollamaRunning = docker ps --format "{{.Names}}" 2>$null | Select-String "ollama"
$ollamaStatus = if ($ollamaRunning) { "运行中" } else { "未运行" }
Write-Host "  Ollama (端口 11434):      $ollamaStatus"

# ── Open WebUI ──
$webuiRunning = docker ps --format "{{.Names}}" 2>$null | Select-String "open-webui"
$webuiStatus = if ($webuiRunning) { "运行中" } else { "未运行" }
Write-Host "  Open WebUI (端口 3001):   $webuiStatus"

# ── codex-bridge ──
$port4000 = Get-NetTCPConnection -LocalPort 4000 -ErrorAction SilentlyContinue
$bridgeStatus = if ($port4000) { "运行中" } else { "未运行" }
Write-Host "  codex-bridge (端口 4000): $bridgeStatus"

# ── Ollama 模型 ──
if ($ollamaRunning) {
    Write-Host ""
    Write-Host "  已安装模型:"
    $models = docker exec ollama ollama list 2>$null
    if ($models) {
        $models | ForEach-Object { Write-Host "    $_" }
    }
}

# ── Node.js ──
$nodeVersion = node --version 2>$null
if ($nodeVersion) { Write-Host "  Node.js: $nodeVersion" } else { Write-Host "  Node.js: 未安装" }

# ── Codex CLI ──
$codexVersion = codex --version 2>$null
if ($codexVersion) { Write-Host "  Codex CLI: $codexVersion" } else { Write-Host "  Codex CLI: 未安装" }

Write-Host ""
