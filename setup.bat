@echo off
chcp 65001 >nul

:: ============================================================
::  Codex 便携平台 — 环境设置脚本
::  首次使用前运行此脚本设置环境变量
:: ============================================================

cd /d "%~dp0"

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  Codex 便携平台 — 环境设置                            ║
echo ╠══════════════════════════════════════════════════════╣

:: ── 检查 Node.js ──
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ║  [错误] Node.js 未安装                                ║
    echo ║  请从 https://nodejs.org 下载安装 Node.js v18+       ║
    echo ╚══════════════════════════════════════════════════════╝
    exit /b 1
)
for /f "tokens=*" %%v in ('node --version') do echo ║  Node.js:    %%v

:: ── 检查 Docker ──
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ║  [警告] Docker 未安装，本地模型功能不可用               ║
) else (
    for /f "tokens=*" %%v in ('docker --version') do echo ║  Docker:     %%v
)

:: ── 安装 Codex CLI ──
echo ╠══════════════════════════════════════════════════════╣
echo ║  [安装] Codex CLI...
codex --version >nul 2>&1
if %errorlevel% neq 0 (
    npm install -g @openai/codex 2>&1
    if %errorlevel% equ 0 (
        echo ║  Codex CLI 安装成功!                              ║
    ) else (
        echo ║  Codex CLI 安装失败，请手动执行:                   ║
        echo ║    npm install -g @openai/codex                   ║
    )
) else (
    echo ║  Codex CLI 已安装                                   ║
)

:: ── 设置 CODEX_HOME ──
echo ╠══════════════════════════════════════════════════════╣
set "CODEX_HOME=%~dp0config"
echo ║  CODEX_HOME 已设置为:                                 ║
echo ║  %CODEX_HOME%

:: ── 用户级环境变量 ──
setx CODEX_HOME "%CODEX_HOME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo ║  [OK] 已写入用户级环境变量                          ║
) else (
    echo ║  [提示] 无法写入环境变量，请手动设置:                 ║
    echo ║    setx CODEX_HOME "%CODEX_HOME%"                ║
)

:: ── npm 全局路径提示 ──
echo ╠══════════════════════════════════════════════════════╣
echo ║  下一步:                                             ║
echo ║  1. start.bat     启动服务                           ║
echo ║  2. codex          开始使用 Codex                     ║
echo ╚══════════════════════════════════════════════════════╝
echo.
echo [提示] 如果 codex 命令不可用，请关闭并重新打开终端
echo.
