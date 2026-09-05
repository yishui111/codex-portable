@echo off
chcp 65001 >nul

:: ============================================================
::  Codex 便携平台 — 停止脚本
:: ============================================================

cd /d "%~dp0"

echo [停止] 正在关闭 Codex 便携平台服务...

:: ── 停止 codex-bridge ────────────────────────────────────
echo [1/3] 停止 codex-bridge 代理...
for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr ":4000.*LISTENING"') do (
    taskkill /PID %%a /F >nul 2>&1
)
echo       codex-bridge 已停止

:: ── 停止 Docker 容器 ──────────────────────────────────────
echo [2/3] 停止 Ollama...
docker compose stop ollama 2>nul
echo [3/3] 停止 Open WebUI...
docker compose stop open-webui 2>nul

echo.
echo [完成] 所有服务已停止
echo.
echo 提示: 如需清理容器和数据卷: docker compose down -v
