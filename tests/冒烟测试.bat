@echo off
chcp 65001 >nul
:: Codex portable platform - smoke test (read-only)
cd /d "%~dp0\.."
echo ========== Codex 便携平台 冒烟测试 ==========
echo.
echo [1/4] Node.js ...
node --version >nul 2>&1 && (for /f "tokens=*" %%v in ('node --version') do echo   [OK] %%v) || echo   [失败] 未安装 Node.js
echo.
echo [2/4] Docker ...
docker info >nul 2>&1 && echo   [OK] Docker 守护进程运行中 || echo   [失败] Docker 未运行，请先启动 Docker Desktop
echo.
echo [3/4] 服务端口 ...
netstat -ano 2>nul | findstr ":3001.*LISTENING" >nul && echo   [OK] 聊天界面 3001 已监听 || echo   [未起] 聊天界面 3001
netstat -ano 2>nul | findstr ":4000.*LISTENING" >nul && echo   [OK] 代理 4000 已监听 || echo   [未起] 代理 4000
netstat -ano 2>nul | findstr ":11434.*LISTENING" >nul && echo   [OK] Ollama 11434 已监听 || echo   [未起] Ollama 11434
echo.
echo [4/4] Codex CLI ...
codex --version >nul 2>&1 && (for /f "tokens=*" %%v in ('codex --version') do echo   [OK] %%v) || echo   [提示] codex 不在 PATH，请运行 setup.bat 或用 codex.bat
echo.
echo ========== 冒烟测试结束 ==========
