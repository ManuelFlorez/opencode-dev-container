# OpenCode Dev Container

[![CI](https://github.com/ManuelFlorez/opencode-dev-container/actions/workflows/ci.yml/badge.svg)](https://github.com/ManuelFlorez/opencode-dev-container/actions/workflows/ci.yml)

English | [Español](docs/README_es.md)

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
Container Registry (GHCR). The package is private, so sign in first with a token
that has the `read:packages` scope:

```bash
echo "$GH_TOKEN" | docker login ghcr.io -u <your-github-user> --password-stdin
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

## Security notes

- **Do not commit** the `.env` file with real keys to a public repository. It is
  already listed in `.gitignore`; share `.env.example` with example values instead.
- CI runs **gitleaks** to detect secrets in the repository history.
- Rotate any token you may have exposed by mistake.
- Use GitHub tokens with the minimum required permissions.

## Documentation

- [English documentation](docs/README_en.md)
- [Documentación en español](docs/README_es.md)

## License

Released under the [MIT License](LICENSE).
