@echo off
chcp 65001 >nul

:: ============================================================
::  Codex 便携平台 — 状态检查
:: ============================================================

cd /d "%~dp0"

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  Codex 便携平台 — 服务状态                            ║
echo ╠══════════════════════════════════════════════════════╣

:: ── Ollama 状态 ──────────────────────────────────────────
set OLLAMA_STATUS=未运行
docker ps --format "{{.Names}}" 2>nul | findstr "ollama" >nul
if %errorlevel% equ 0 (
    set OLLAMA_STATUS=运行中
)
echo ║  Ollama ^(端口 11434^):    !OLLAMA_STATUS!

:: ── Open WebUI 状态 ──────────────────────────────────────
set WEBUI_STATUS=未运行
docker ps --format "{{.Names}}" 2>nul | findstr "open-webui" >nul
if %errorlevel% equ 0 (
    set WEBUI_STATUS=运行中
)
echo ║  Open WebUI ^(端口 3002^): !WEBUI_STATUS!

:: ── codex-bridge 状态 ────────────────────────────────────
set BRIDGE_STATUS=未运行
netstat -ano 2>nul | findstr ":4000.*LISTENING" >nul
if %errorlevel% equ 0 (
    set BRIDGE_STATUS=运行中
)
echo ║  codex-bridge ^(端口 4000^): !BRIDGE_STATUS!

:: ── Ollama 模型列表 ──────────────────────────────────────
docker ps --format "{{.Names}}" 2>nul | findstr "ollama" >nul
if %errorlevel% equ 0 (
    echo ╠══════════════════════════════════════════════════════╣
    echo ║  已安装模型:                                         ║
    docker exec ollama ollama list 2>nul
)

:: ── Node.js 版本 ─────────────────────────────────────────
echo ╠══════════════════════════════════════════════════════╣
node --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('node --version') do echo ║  Node.js:              %%v
) else (
    echo ║  Node.js:              未安装
)

:: ── Codex CLI 版本 ───────────────────────────────────────
codex --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('codex --version') do echo ║  Codex CLI:            %%v
) else (
    echo ║  Codex CLI:            未安装
)

echo ╚══════════════════════════════════════════════════════╝
echo.
echo 提示: 如服务未运行，请执行 start.bat
echo.
