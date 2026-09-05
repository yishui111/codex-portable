@echo off
:: Codex CLI quick start script
:: Usage: codex.bat [deepseek|ollama]  - default deepseek

set "CODEX_HOME=%~dp0config"
set "OPENAI_API_KEY=sk-proxy-local-codex-portable-key-2026"

set PROFILE=deepseek
if /i "%~1"=="ollama" set PROFILE=ollama
if /i "%~1"=="deepseek" set PROFILE=deepseek

where codex >nul 2>&1
if %errorlevel% equ 0 (
    codex --profile %PROFILE%
) else (
    "C:\Users\Administrator\.workbuddy\binaries\node\versions\22.22.2\codex.cmd" --profile %PROFILE%
)
