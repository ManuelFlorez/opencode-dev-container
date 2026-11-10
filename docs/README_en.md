# OpenCode Dev Container

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

### 1. Build the image

```bash
docker build -t opencode-dev .
```

### 2. Run the container

```bash
docker run -it --rm --env-file .env -v "${PWD}:/app" opencode-dev
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

## Security notes

- **Do not commit** the `.env` file with real keys to a public repository. It is
  already listed in `.gitignore`; share `.env.example` with example values instead.
- Rotate any token you may have exposed by mistake.
- Use GitHub tokens with the minimum required permissions.

## Documentation

- [English documentation](README_en.md)
- [Documentación en español](README_es.md)
- [Project README](../README.md)
