# ============================================================
#  Codex 便携平台 — 停止脚本 (PowerShell)
# ============================================================

Set-Location $PSScriptRoot

Write-Host "[停止] 正在关闭 Codex 便携平台服务..." -ForegroundColor Cyan

# ── 停止 codex-bridge ──
Write-Host "[1/3] 停止 codex-bridge..."
Get-Process -Name "node" -ErrorAction SilentlyContinue | ForEach-Object {
    $proc = $_
    $cmd = (Get-WmiObject Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
    if ($cmd -match "proxy\.mjs") {
        Stop-Process -Id $proc.Id -Force
        Write-Host "      已停止 codex-bridge (PID: $($proc.Id))"
    }
}

# ── 停止 Docker 容器 ──
Write-Host "[2/3] 停止 Ollama..."
docker compose stop ollama 2>$null
Write-Host "[3/3] 停止 Open WebUI..."
docker compose stop open-webui 2>$null

Write-Host ""
Write-Host "[完成] 所有服务已停止" -ForegroundColor Green
Write-Host ""
Write-Host "提示: 如需清理容器: docker compose down"
Write-Host ""
