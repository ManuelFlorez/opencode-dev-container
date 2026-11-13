# OpenCode Dev Container

[![CI](https://github.com/ManuelFlorez/opencode-dev-container/actions/workflows/ci.yml/badge.svg)](https://github.com/ManuelFlorez/opencode-dev-container/actions/workflows/ci.yml)

[English](README_en.md) | [Español](README_es.md) | [Home](../README.md)

Docker image that prepares a ready-to-use development environment with
[OpenCode CLI](https://opencode.ai) and the [GitHub CLI](https://cli.github.com/),
designed for working with AI agents and managing GitHub repositories from an
isolated, reproducible container.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) installed and running.

## Image contents

- **Node.js** `26.13.0` (base `node:26.13.0-bookworm`).
- **GitHub CLI** (`gh`), installed from the official repository.
- **OpenCode CLI** (`opencode`), installed globally via npm.
- **jq**, **ripgrep**, **fzf**, **tmux** and **vim** for everyday development.
- Working directory: `/app`.
- Default shell: `bash`.

## Configuration

The project includes a `.env.example` file with the required variables. Copy it
to `.env` and fill in your real credentials:

```bash
cp .env.example .env
```

```env
OPENAI_API_KEY="your_openai_api_key_here"
GH_TOKEN="your_github_token_here"
```

- `OPENAI_API_KEY`: OpenAI provider API key used by OpenCode.
- `GH_TOKEN`: GitHub personal token used by the `gh` CLI.

## Usage

You can build the image locally or use the version published to the GitHub
Container Registry (GHCR):

```bash
docker pull ghcr.io/manuelflorez/opencode-dev-container:latest
```

### 1. Build the image

```bash
docker build -t opencode-dev .
```

Or, using the Makefile:

```bash
make build
```

### 2. Run the container

```bash
docker run -it --rm --env-file .env -v "${PWD}:/app" opencode-dev
```

Or:

```bash
make run
```

This opens a `bash` shell inside the container with:

- the variables from `.env` loaded,
- the current directory mounted at `/app`.

### 3. Authenticate GitHub (optional)

If you don't use `GH_TOKEN`, you can sign in interactively:

```bash
gh auth login
```

Check the authentication status with:

```bash
gh auth status
```

### 4. Start OpenCode

```bash
opencode
```

## Makefile

Run `make help` to list the available targets:

| Target | Description |
| --- | --- |
| `make build` | Build the Docker image. |
| `make run` | Run the container with `.env` and the current directory mounted. |
| `make check` | Validate required files and that `.env` is not tracked by git. |
| `make clean` | Remove the Docker image. |

## SSH keys (optional)

To let `git` and `gh` use your SSH keys inside the container, mount `~/.ssh`
read-only:

```bash
docker run -it --rm --env-file .env \
  -v "${PWD}:/app" \
  -v "$HOME/.ssh:/root/.ssh:ro" \
  opencode-dev
```

If your keys are passphrase-protected, forward your SSH agent instead:

```bash
docker run -it --rm --env-file .env \
  -v "${PWD}:/app" \
  -v "$SSH_AUTH_SOCK:/ssh-agent" \
  -e SSH_AUTH_SOCK=/ssh-agent \
  opencode-dev
```

Make sure the mounted keys have restrictive permissions (`chmod 600`).

## Windows PowerShell (optional)

On Windows 11 you can add PowerShell profile functions so that typing `opencode`
in any folder runs OpenCode inside the published image, with that folder
mounted at `/app`. The full script lives in
[`scripts/opencode-dev-profile.ps1`](../scripts/opencode-dev-profile.ps1) and is also available as a
[gist](https://gist.github.com/ManuelFlorez/f78609b4293ed09bc16798fff19b764d).

### 1. Allow your profile to run

PowerShell blocks `.ps1` scripts by default, including your profile. Allow
local scripts for your user (no admin needed):

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

If `Get-ExecutionPolicy -List` shows a value other than `Undefined` for
`MachinePolicy` or `UserPolicy`, the policy is enforced by Group Policy and
must be changed by your IT team.

### 2. Add the functions to your profile

```powershell
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
notepad $PROFILE
```

Paste the following, save, and reload with `. $PROFILE`:

```powershell
$OpenCodeImage   = "ghcr.io/manuelflorez/opencode-dev-container:1.0.0"
$OpenCodeEnvFile = "$HOME\.opencode-dev\.env"

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
```

### 3. Create the env file (optional)

The functions load `$HOME\.opencode-dev\.env` if it exists, kept outside your
projects so it is never committed by accident:

```powershell
New-Item -ItemType Directory -Force "$HOME\.opencode-dev" | Out-Null
New-Item -ItemType File -Force "$HOME\.opencode-dev\.env" | Out-Null
notepad "$HOME\.opencode-dev\.env"
```

Add your keys **without quotes** (`docker --env-file` keeps quotes as part of
the value):

```
OPENAI_API_KEY=your_openai_api_key_here
GH_TOKEN=ghp_your_token_here
```

Avoid `echo ... >` or `Out-File` in Windows PowerShell 5.1: they write UTF-16
or a BOM, which breaks the first variable. Notepad on Windows 11 saves UTF-8
without BOM.

### 4. Use it

```powershell
cd C:\path\to\your\project
opencode               # OpenCode in the current folder
opencode --version     # arguments are passed through to opencode
opencode-shell         # bash inside the container
```

Notes:

- Docker Desktop must be running (WSL2 backend).
- These functions take precedence over a native `opencode` install on Windows;
  rename them (e.g. `opencode-docker`) if you have both.
- To upgrade, change the image tag in `$OpenCodeImage` and run
  `docker pull` for the new tag.

## Security notes

- **Do not commit** the `.env` file with real keys to a public repository. It is
  already listed in `.gitignore`; share `.env.example` with example values instead.
- CI runs **gitleaks** to detect secrets in the repository history.
- Rotate any token you may have exposed by mistake.
- Use GitHub tokens with the minimum required permissions.

## Documentation

- [English documentation](README_en.md)
- [Documentación en español](README_es.md)
- [Project README](../README.md)

## License

Released under the [MIT License](../LICENSE).
