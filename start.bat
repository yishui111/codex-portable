@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================================
::  Codex 便携平台 — 一键启动脚本
::  用法:
::    start.bat           → 启动全部（Ollama + bridge + WebUI）
::    start.bat ollama    → 仅启动 Ollama（本地模型）
::    start.bat deepseek  → 仅启动 bridge（DeepSeek 线上 API）
::    start.bat webui     → 仅启动 Open WebUI（聊天界面）
::    start.bat help      → 帮助
:: ============================================================

cd /d "%~dp0"

set MODE=%~1
if "%MODE%"=="" set MODE=all

:: ── 帮助 ──────────────────────────────────────────────────
if /i "%MODE%"=="help" (
    echo.
    echo ╔══════════════════════════════════════════════════════╗
    echo ║     Codex 便携平台 — AI 编程助手 + 聊天界面            ║
    echo ╠══════════════════════════════════════════════════════╣
    echo ║  用法:                                                ║
    echo ║    start.bat           启动全部服务                    ║
    echo ║    start.bat ollama    仅启动 Ollama ^(本地模型^)      ║
    echo ║    start.bat deepseek  仅启动 bridge ^(线上 API^)      ║
    echo ║    start.bat webui     仅启动 Open WebUI ^(聊天界面^)  ║
    echo ╠══════════════════════════════════════════════════════╣
    echo ║  服务地址:                                            ║
    echo ║    聊天界面  → http://localhost:3002                  ║
    echo ║    代理服务  → http://localhost:4000                  ║
    echo ║    本地模型  → http://localhost:11434                 ║
    echo ╠══════════════════════════════════════════════════════╣
    echo ║  切换模型:                                            ║
    echo ║    codex --profile deepseek  使用 DeepSeek 线上       ║
    echo ║    codex --profile ollama    使用本地 qwen2.5:7b      ║
    echo ╚══════════════════════════════════════════════════════╝
    echo.
    exit /b 0
)

:: ── 检查 Docker ────────────────────────────────────────────
if /i "%MODE%"=="deepseek" goto :check_node
:check_docker
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker 未运行，请先启动 Docker Desktop
    exit /b 1
)

:: ============================================================
::  阶段 1: 启动 Ollama
:: ============================================================
if /i "%MODE%"=="deepseek" goto :phase_bridge
if /i "%MODE%"=="webui" goto :phase_webui

:phase_ollama
echo.
echo ========== 启动 Ollama 本地模型 ==========

:: 加载镜像
docker image inspect ollama/ollama:latest >nul 2>&1
if %errorlevel% neq 0 (
    if exist "ollama-image.tar" (
        echo [加载] 正在加载 Ollama 镜像 (约 2-3 分钟)...
        docker load -i ollama-image.tar
        echo [完成] 镜像加载成功
    ) else (
        echo [提示] ollama-image.tar 不存在，将从网络拉取...
        docker pull ollama/ollama:latest
    )
)

:: 启动容器
echo [启动] Ollama 容器...
docker compose up -d ollama
if %errorlevel% neq 0 (
    echo [错误] Ollama 启动失败
    exit /b 1
)
echo [OK] Ollama 已启动 (端口 11434)

:: 检查模型
timeout /t 3 >nul
docker exec ollama ollama list 2>nul | findstr "qwen2.5:7b" >nul
if %errorlevel% neq 0 (
    echo [提示] qwen2.5:7b 模型数据可能在加载中，请稍候...
) else (
    echo [OK] qwen2.5:7b 模型已就绪
)

if /i "%MODE%"=="ollama" goto :done_ollama

:: ============================================================
::  阶段 2: 启动 codex-bridge
:: ============================================================
:phase_bridge

:: 检查 Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Node.js，请安装 Node.js v18+
    echo        下载: https://nodejs.org
    exit /b 1
)

echo.
echo ========== 启动 codex-bridge 代理 ==========

:: 检查 Codex CLI
codex --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [安装] Codex CLI 未安装，正在安装...
    npm install -g @openai/codex
    echo [完成] Codex CLI 安装成功
)

:: 启动代理
cd /d "%~dp0codex-bridge"
netstat -ano 2>nul | findstr ":4000.*LISTENING" >nul
if %errorlevel% equ 0 (
    echo [跳过] 端口 4000 已被占用，bridge 已在运行
) else (
    if not exist ".env" (
        echo [错误] .env 文件不存在，请先配置
        exit /b 1
    )
    start "Codex Bridge" /MIN cmd /c "node --env-file=.env proxy.mjs"
    echo [OK] codex-bridge 已在后台启动 (端口 4000)
    timeout /t 3 >nul
)
cd /d "%~dp0"

if /i "%MODE%"=="deepseek" goto :done_deepseek

:: ============================================================
::  阶段 3: 启动 Open WebUI
:: ============================================================
:phase_webui

echo.
echo ========== 启动 Open WebUI 聊天界面 ==========

:: 加载镜像
docker image inspect ghcr.io/open-webui/open-webui:main >nul 2>&1
if %errorlevel% neq 0 (
    if exist "open-webui-image.tar" (
        echo [加载] 正在加载 Open WebUI 镜像 (约 2-3 分钟)...
        docker load -i open-webui-image.tar
        echo [完成] 镜像加载成功
    ) else (
        echo [提示] open-webui-image.tar 不存在，将从网络拉取...
        docker pull ghcr.io/open-webui/open-webui:main
    )
)

:: 启动容器
docker compose up -d open-webui
if %errorlevel% neq 0 (
    echo [错误] Open WebUI 启动失败
    exit /b 1
)
echo [OK] Open WebUI 已启动 (端口 3002)

:: ============================================================
::  完成
:: ============================================================
:show_info
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║            启动成功!                                  ║
echo ╠══════════════════════════════════════════════════════╣
echo ║  🤖 Open WebUI:    http://localhost:3002              ║
echo ║  🔌 Bridge 代理:   http://localhost:4000              ║
echo ║  🐪 Ollama 本地:   http://localhost:11434             ║
echo ╠══════════════════════════════════════════════════════╣
echo ║  终端使用:                                            ║
echo ║    codex --profile deepseek   线上 DeepSeek           ║
echo ║    codex --profile ollama     本地 qwen2.5:7b         ║
echo ╠══════════════════════════════════════════════════════╣
echo ║  管理面板添加 DeepSeek:                                ║
echo ║    Open WebUI → 管理员设置 → 外部连接                  ║
echo ║    API地址: http://host.docker.internal:4000/v1        ║
echo ║    API密钥: sk-proxy-local-codex-portable-key-2026    ║
echo ╚══════════════════════════════════════════════════════╝
echo.
echo [提示] 设置环境变量: set CODEX_HOME=%~dp0config
echo.
exit /b 0

:done_ollama
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  Ollama 本地模型已启动!                               ║
echo ║  模型: qwen2.5:7b (7.6B)                             ║
echo ║  API:  http://localhost:11434                        ║
echo ║  使用: codex --profile ollama                        ║
echo ╚══════════════════════════════════════════════════════╝
echo.
exit /b 0

:done_deepseek
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  codex-bridge 代理已启动!                             ║
echo ║  代理地址: http://localhost:4000                      ║
echo ║  使用: codex --profile deepseek                      ║
echo ╚══════════════════════════════════════════════════════╝
echo.
exit /b 0
