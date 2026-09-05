@echo off
chcp 65001 >nul
:: Codex portable platform - show status
cd /d "%~dp0"
call status.bat
