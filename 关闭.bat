@echo off
chcp 65001 >nul
:: Codex portable platform - stop all services
cd /d "%~dp0"
call stop.bat
