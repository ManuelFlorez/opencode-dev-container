# OpenCode Dev Container

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

### 1. Construir la imagen

```bash
docker build -t opencode-dev .
```

### 2. Ejecutar el contenedor

```bash
docker run -it --rm --env-file .env -v "${PWD}:/app" opencode-dev
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

## Notas de seguridad

- **No subas** el archivo `.env` con claves reales a un repositorio público.
  Ya está incluido en `.gitignore`; comparte un `.env.example` con valores de
  ejemplo en su lugar.
- Rota cualquier token que hayas expuesto por error.
- Usa tokens de GitHub con el mínimo de permisos necesarios.

## Documentación

- [Documentación en inglés](README_en.md)
- [README del proyecto (inglés)](../README.md)
