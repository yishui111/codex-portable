@echo off
chcp 65001 >nul
:: Codex portable platform - start all services
cd /d "%~dp0"
call start.bat
