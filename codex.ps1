# Codex CLI quick start script (PowerShell)
# Usage: .\codex.ps1 [deepseek|ollama]  - default deepseek

$env:CODEX_HOME = "$PSScriptRoot\config"
$env:OPENAI_API_KEY = "sk-proxy-local-codex-portable-key-2026"

$profile = if ($args[0] -eq "ollama") { "ollama" } else { "deepseek" }

$codexCmd = Get-Command codex -ErrorAction SilentlyContinue
if ($codexCmd) {
    & $codexCmd.Source --profile $profile
} else {
    & "C:\Users\Administrator\.workbuddy\binaries\node\versions\22.22.2\codex.cmd" --profile $profile
}
