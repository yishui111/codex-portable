@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
:: ============================================================
::  Codex 便携平台 - 新机导入脚本
::  用途: 把复制到新电脑的整个文件夹快速就位并启动
:: ============================================================
cd /d "%~dp0"
set MODE=%~1
if "%MODE%"=="" set MODE=all
echo.
echo ============================================================
echo   Codex 便携平台 - 新机导入脚本
echo ============================================================
echo.
echo [1/5] 检查 Node.js ...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [错误] Node.js 未安装或不在 PATH 中
    echo   [提示] 请从 https://nodejs.org 安装 Node.js v18+，装完重开本脚本
) else (
    for /f "tokens=*" %%v in ('node --version') do echo   [OK] Node.js %%v
    npm --version >nul 2>&1
    if %errorlevel% equ 0 (
        for /f "tokens=*" %%v in ('npm --version') do echo   [OK] npm %%v
    ) else (
        echo   [错误] npm 不可用
    )
)
echo.
echo [2/5] 检查 Docker ...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [错误] Docker 未安装或不在 PATH 中
    echo   [提示] 请安装 Docker Desktop 并启动，再运行本脚本
) else (
    for /f "tokens=*" %%v in ('docker --version') do echo   [OK] %%v
    docker info >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [OK] Docker 守护进程已运行
    ) else (
        echo   [警告] Docker 守护进程未运行，请先启动 Docker Desktop
    )
)
echo.
if /i "%MODE%"=="check" goto :done
echo [3/5] 检查并导入 Docker 镜像 ...
if exist "ollama-image.tar" (
    docker image inspect ollama/ollama:latest >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [OK] Ollama 镜像已存在，跳过
    ) else (
        echo   [导入] ollama-image.tar，可能需要几分钟...
        docker load -i ollama-image.tar >nul 2>&1
        if %errorlevel% equ 0 ( echo   [OK] Ollama 镜像导入成功 ) else ( echo   [错误] Ollama 镜像导入失败 )
    )
) else (
    echo   [提示] 未找到 ollama-image.tar，将在启动时从网络拉取
)
if exist "open-webui-image.tar" (
    docker image inspect ghcr.io/open-webui/open-webui:main >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [OK] Open WebUI 镜像已存在，跳过
    ) else (
        echo   [导入] open-webui-image.tar，可能需要几分钟...
        docker load -i open-webui-image.tar >nul 2>&1
        if %errorlevel% equ 0 ( echo   [OK] Open WebUI 镜像导入成功 ) else ( echo   [错误] Open WebUI 镜像导入失败 )
    )
) else (
    echo   [提示] 未找到 open-webui-image.tar，将在启动时从网络拉取
)
echo.
echo [4/5] 设置 CODEX_HOME 环境变量 ...
set "CODEX_HOME=%~dp0config"
setx CODEX_HOME "%CODEX_HOME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] CODEX_HOME 已写入: %CODEX_HOME%
) else (
    echo   [提示] 写入失败，请手动执行:
    echo        setx CODEX_HOME "%CODEX_HOME%"
)
echo.
echo [5/5] 检查 codex-bridge API 配置 ...
if exist "codex-bridge\.env" (
    findstr /i /c:"DEEPSEEK_API_KEY=sk-" "codex-bridge\.env" >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [OK] 已发现 DeepSeek API Key
    ) else (
        echo   [提示] codex-bridge\.env 里未找到有效的 DEEPSEEK_API_KEY
    )
) else (
    echo   [提示] 未找到 codex-bridge\.env
)
echo   [提示] PROXY_AUTH_KEY 默认: sk-proxy-local-codex-portable-key-2026
echo   [提示] Open WebUI 管理后台可添加底座连接:
echo        API地址: http://host.docker.internal:4000/v1
echo        API密钥: sk-proxy-local-codex-portable-key-2026
:done
echo.
echo ============================================================
if /i "%MODE%"=="check" (
    echo   [完成] 环境检查结束
) else (
    echo   [完成] 新机导入完成
)
echo ============================================================
echo.
if /i not "%MODE%"=="check" (
    echo 下一步:
    echo   1. 首次使用请运行 setup.bat 安装 Codex CLI
    echo   2. 运行 start.bat 一键启动全部服务
    echo   3. 终端使用: codex --profile deepseek 或 codex --profile ollama
)
echo.
echo [提示] 若 codex 命令不可用，请关闭并重新打开终端
echo.
endlocal
exit /b 0