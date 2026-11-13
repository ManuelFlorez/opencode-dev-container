# OpenCode Dev Container

[![CI](https://github.com/ManuelFlorez/opencode-dev-container/actions/workflows/ci.yml/badge.svg)](https://github.com/ManuelFlorez/opencode-dev-container/actions/workflows/ci.yml)

[English](README_en.md) | Español | [Inicio](../README.md)

Imagen Docker que prepara un entorno de desarrollo listo para usar con
[OpenCode CLI](https://opencode.ai) y el [GitHub CLI](https://cli.github.com/),
pensada para trabajar con agentes de IA y gestionar repositorios de GitHub desde
un contenedor aislado y reproducible.

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) instalado y funcionando.

## Contenido de la imagen

- **Node.js** `26.13.0` (base `node:26.13.0-bookworm`).
- **GitHub CLI** (`gh`), instalado desde el repositorio oficial.
- **OpenCode CLI** (`opencode`), instalado globalmente vía npm.
- **jq**, **ripgrep**, **fzf**, **tmux** y **vim** para el trabajo diario.
- Directorio de trabajo: `/app`.
- Shell por defecto: `bash`.

## Configuración

El proyecto incluye un archivo `.env.example` con las variables necesarias.
Cópialo a `.env` y rellena tus credenciales reales:

```bash
cp .env.example .env
```

```env
OPENAI_API_KEY="tu_clave_aqui"
GH_TOKEN="tu_token_de_github_aqui"
```

- `OPENAI_API_KEY`: clave de API del proveedor de OpenAI usada por OpenCode.
- `GH_TOKEN`: token personal de GitHub usado por el CLI `gh`.

## Uso

Puedes construir la imagen localmente o usar la versión publicada en el
GitHub Container Registry (GHCR):

```bash
docker pull ghcr.io/manuelflorez/opencode-dev-container:latest
```

### 1. Construir la imagen

```bash
docker build -t opencode-dev .
```

O, usando el Makefile:

```bash
make build
```

### 2. Ejecutar el contenedor

```bash
docker run -it --rm --env-file .env -v "${PWD}:/app" opencode-dev
```

O:

```bash
make run
```

Esto abre una shell `bash` dentro del contenedor, con:

- las variables del `.env` cargadas,
- el directorio actual montado en `/app`.

### 3. Autenticar GitHub (opcional)

Si no usas `GH_TOKEN`, puedes iniciar sesión de forma interactiva:

```bash
gh auth login
```

Comprueba el estado de la autenticación con:

```bash
gh auth status
```

### 4. Iniciar OpenCode

```bash
opencode
```

## Makefile

Ejecuta `make help` para listar los objetivos disponibles:

| Objetivo | Descripción |
| --- | --- |
| `make build` | Construye la imagen Docker. |
| `make run` | Ejecuta el contenedor con `.env` y el directorio actual montado. |
| `make check` | Valida los archivos necesarios y que `.env` no esté versionado. |
| `make clean` | Elimina la imagen Docker. |

## Llaves SSH (opcional)

Para que `git` y `gh` usen tus llaves SSH dentro del contenedor, monta `~/.ssh`
en modo solo lectura:

```bash
docker run -it --rm --env-file .env \
  -v "${PWD}:/app" \
  -v "$HOME/.ssh:/root/.ssh:ro" \
  opencode-dev
```

Si tus llaves tienen passphrase, reenvía tu agente SSH en su lugar:

```bash
docker run -it --rm --env-file .env \
  -v "${PWD}:/app" \
  -v "$SSH_AUTH_SOCK:/ssh-agent" \
  -e SSH_AUTH_SOCK=/ssh-agent \
  opencode-dev
```

Asegúrate de que las llaves montadas tengan permisos restrictivos (`chmod 600`).

## Windows PowerShell (opcional)

En Windows 11 puedes añadir funciones a tu perfil de PowerShell para que, al
escribir `opencode` en cualquier carpeta, se ejecute OpenCode dentro de la
imagen publicada, con esa carpeta montada en `/app`. El script completo está en
[`scripts/opencode-dev-profile.ps1`](../scripts/opencode-dev-profile.ps1) y también está disponible como
[gist](https://gist.github.com/ManuelFlorez/f78609b4293ed09bc16798fff19b764d).

### 1. Permitir que se ejecute el perfil

PowerShell bloquea por defecto los scripts `.ps1`, incluido tu perfil. Permite
los scripts locales para tu usuario (no requiere administrador):

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Si `Get-ExecutionPolicy -List` muestra un valor distinto de `Undefined` en
`MachinePolicy` o `UserPolicy`, la política está impuesta por Group Policy y
debe cambiarla tu equipo de TI.

### 2. Añadir las funciones al perfil

```powershell
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
notepad $PROFILE
```

Pega lo siguiente, guarda y recarga con `. $PROFILE`:

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

### 3. Crear el archivo de entorno (opcional)

Las funciones cargan `$HOME\.opencode-dev\.env` si existe; está fuera de tus
proyectos para que nunca se suba por accidente:

```powershell
New-Item -ItemType Directory -Force "$HOME\.opencode-dev" | Out-Null
New-Item -ItemType File -Force "$HOME\.opencode-dev\.env" | Out-Null
notepad "$HOME\.opencode-dev\.env"
```

Añade tus claves **sin comillas** (`docker --env-file` conserva las comillas
como parte del valor):

```
OPENAI_API_KEY=tu_api_key_de_openai
GH_TOKEN=ghp_tu_token
```

Evita `echo ... >` u `Out-File` en Windows PowerShell 5.1: escriben en UTF-16
o con BOM, lo que rompe la primera variable. El Bloc de notas de Windows 11
guarda en UTF-8 sin BOM.

### 4. Uso

```powershell
cd C:\ruta\a\tu\proyecto
opencode               # OpenCode en la carpeta actual
opencode --version     # los argumentos se pasan a opencode
opencode-shell         # bash dentro del contenedor
```

Notas:

- Docker Desktop debe estar en ejecución (backend WSL2).
- Estas funciones tienen prioridad sobre una instalación nativa de `opencode`
  en Windows; renómbralas (por ejemplo `opencode-docker`) si tienes ambas.
- Para actualizar, cambia el tag de la imagen en `$OpenCodeImage` y ejecuta
  `docker pull` con el nuevo tag.

## Notas de seguridad

- **No subas** el archivo `.env` con claves reales a un repositorio público.
  Ya está incluido en `.gitignore`; comparte un `.env.example` con valores de
  ejemplo en su lugar.
- El CI ejecuta **gitleaks** para detectar secretos en el historial del repositorio.
- Rota cualquier token que hayas expuesto por error.
- Usa tokens de GitHub con el mínimo de permisos necesarios.

## Documentación

- [Documentación en inglés](README_en.md)
- [README del proyecto (inglés)](../README.md)

## Licencia

Distribuido bajo la [Licencia MIT](../LICENSE).
