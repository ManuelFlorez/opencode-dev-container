# OpenCode Dev Container - PowerShell profile functions
# Repo: https://github.com/ManuelFlorez/opencode-dev-container
#
# Install:
#   1. Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
#   2. notepad $PROFILE   (paste this file's contents and save)
#   3. . $PROFILE
#
# Usage (from any project folder):
#   opencode          -> runs OpenCode with the current folder mounted at /app
#   opencode <args>   -> arguments are passed through to opencode
#   opencode-shell    -> bash inside the container

$OpenCodeImage   = "ghcr.io/manuelflorez/opencode-dev-container:1.0.0"
$OpenCodeEnvFile = "$HOME\.opencode-dev\.env"   # OPENAI_API_KEY=... / GH_TOKEN=... (no quotes)

function Invoke-OpenCodeContainer {
    $dockerArgs = @(
        "run", "-it", "--rm",
        "-v", "$((Get-Location).Path):/app",
        "-w", "/app"
    )
    if (Test-Path $OpenCodeEnvFile) { $dockerArgs += @("--env-file", $OpenCodeEnvFile) }

    docker @dockerArgs $OpenCodeImage @args
}

function opencode       { Invoke-OpenCodeContainer opencode @args }
function opencode-shell { Invoke-OpenCodeContainer bash }
