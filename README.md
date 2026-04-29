<p align="center">
  <img src="https://img.shields.io/badge/stark--kit-v1.0-blue?style=for-the-badge" alt="version" />
  <img src="https://img.shields.io/badge/autoSDD-v5.3-green?style=for-the-badge" alt="autoSDD" />
  <img src="https://img.shields.io/badge/skills-15%2B-purple?style=for-the-badge" alt="skills" />
  <img src="https://img.shields.io/badge/plugins-5-orange?style=for-the-badge" alt="plugins" />
</p>

<h1 align="center">stark-kit</h1>

<p align="center">
  <strong>Entorno de desarrollo con IA, listo para instalar en un solo comando.</strong><br/>
  autoSDD + skills + plugins + Engram + hooks -- todo configurado y funcionando.
</p>

<p align="center">
  <a href="#-instalacion">Instalacion</a> . <a href="#-que-incluye">Que incluye</a> . <a href="#-post-instalacion">Post-instalacion</a> . <a href="#-como-usar-claude-code">Uso diario</a> . <a href="#-troubleshooting">Troubleshooting</a>
</p>

---

## Tabla de Contenido

- [Que es stark-kit](#-que-es-stark-kit)
- [Requisitos previos](#-requisitos-previos)
- [Instalacion](#-instalacion)
- [Que hace el instalador (paso a paso)](#-que-hace-el-instalador-paso-a-paso)
- [Post-instalacion](#-post-instalacion)
- [Estructura del proyecto resultante](#-estructura-del-proyecto-resultante)
- [Lo que queda instalado](#-lo-que-queda-instalado)
  - [autoSDD v5.3](#autosdd-v53)
  - [Skills (15+)](#skills-instaladas-15)
  - [Plugins (5)](#plugins-instalados-5)
- [Captura de audio con IA (SuperWhisper)](#-captura-de-audio-con-ia-superwhisper)
- [Sistema de Feedback Participativo](#-sistema-de-feedback-participativo)
- [Como usar Claude Code con este setup](#-como-usar-claude-code-con-este-setup)
- [Troubleshooting](#-troubleshooting)
- [Proyectos relacionados](#-proyectos-relacionados)
- [Contributing / Feedback](#-contributing--feedback)
- [Licencia](#-licencia)

---

## Que es stark-kit

**stark-kit** es un instalador automatizado que configura un entorno completo de desarrollo con IA para cualquier proyecto. En un solo comando vas a tener:

- **autoSDD v5.3** -- Framework de desarrollo autonomo que orquesta sub-agentes de IA
- **15+ skills de desarrollo** -- Desde prompt engineering hasta diseno de interfaces
- **5 plugins de Claude Code** -- Powerline, Engram, code review, y mas
- **Engram MCP** -- Memoria persistente entre sesiones
- **Templates genericos** -- CLAUDE.md, AGENTS.md, guidelines, user_context -- listos para personalizar

Existen dos versiones del kit:

| Kit | Repo | Descripcion |
|-----|------|-------------|
| **stark-kit** | [thestark77/stark-kit](https://github.com/thestark77/stark-kit) | Version generica -- solo framework, sin contexto empresarial (esta) |
| **be-code-kit** | [thestark77/be-code-kit](https://github.com/thestark77/be-code-kit) | Version especifica para Bemovil -- incluye contexto de negocio, repos, env templates |

> Si eres parte del equipo Bemovil, usa **be-code-kit**. Si quieres el framework limpio para tu propio proyecto, esta es tu version.

---

## Requisitos previos

| # | Requisito | Verificacion | Descarga |
|---|-----------|-------------|----------|
| 1 | **Node.js 18+** | `node --version` | [nodejs.org](https://nodejs.org) |
| 2 | **Git** | `git --version` | [git-scm.com/downloads](https://git-scm.com/downloads) |
| 3 | **Claude Code CLI** | `claude --version` | `npm install -g @anthropic-ai/claude-code` |
| 4 | **pnpm** (recomendado) | `pnpm --version` | `npm install -g pnpm` |

### Sobre Claude Code CLI

Claude Code requiere un **plan Claude Pro ($20 USD/mes)** o acceso a la API de Anthropic.

```bash
# Instalar Claude Code CLI globalmente
npm install -g @anthropic-ai/claude-code

# Verificar instalacion
claude --version

# Primera vez: te va a pedir autenticarte con tu cuenta de Anthropic
claude
```

---

## Instalacion

### Linux / macOS / WSL / Git Bash

```bash
git clone https://github.com/thestark77/stark-kit.git
cd stark-kit
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/thestark77/stark-kit.git
cd stark-kit
.\install.ps1
```

### Directorio de destino personalizado

Por defecto el instalador usa el directorio actual de trabajo. Puedes especificar otro:

```bash
bash install.sh /ruta/a/mi/proyecto
```

> Si el directorio ya existe y tiene archivos, el instalador te pregunta si quieres **actualizar** -- solo sobreescribe archivos de configuracion (CLAUDE.md, context/, .claude/) sin tocar tu codigo.

---

## Que hace el instalador (paso a paso)

El instalador ejecuta **6 pasos** en secuencia:

<details>
<summary><strong>Paso 0 -- Verifica requisitos</strong></summary>

Chequea que tengas instalados:
- `git` -- control de versiones
- `claude` -- Claude Code CLI
- `npm` o `pnpm` -- gestor de paquetes

Si falta alguno, el instalador se detiene y te indica como instalarlo.
</details>

<details>
<summary><strong>Paso 1 -- Prepara el directorio de destino</strong></summary>

- Valida si el directorio existe y si tiene contenido
- Si esta vacio, lo crea sin preguntar
- Si ya tiene archivos, te pregunta si quieres continuar en **modo actualizacion**
</details>

<details>
<summary><strong>Paso 2 -- Copia archivos de configuracion</strong></summary>

Copia desde `templates/` al directorio destino:
- `CLAUDE.md` -- Configuracion principal de la IA, routing de skills, convenciones
- `AGENTS.md` -- Template de agentes especializados (para que lo personalices)
- `PROGRESS.md` -- Estado del desarrollo (lo usa autoSDD)
- `.gitignore` -- Ignora node_modules, .env, builds, etc.
- `.claude/settings.json` -- Hooks y permisos del proyecto
- `context/guidelines.md` -- Convenciones tecnicas genericas
- `context/user_context.md` -- Tu perfil de desarrollador (personalizable)
</details>

<details>
<summary><strong>Paso 3 -- Crea estructura base</strong></summary>

Crea los directorios `src/` y `tests/` como punto de partida. Adapta la estructura a las necesidades de tu proyecto.
</details>

<details>
<summary><strong>Paso 4 -- Instala autoSDD v5.3</strong></summary>

Descarga y ejecuta el instalador interactivo de autoSDD. Selecciona al menos **"claude-code"** como agente destino.

autoSDD instala automaticamente:
- Skills compartidas (prompt-engineering, error-handling, etc.)
- Engram MCP (memoria persistente)
- Protocolos compartidos (RTK, persona, model-assignments)
</details>

<details>
<summary><strong>Paso 5 -- Instala skills y plugins adicionales</strong></summary>

Instala skills extras:
- Caveman (comunicacion ultra-comprimida)
- Vercel React best practices
- shadcn component management
- SDD Agent Team (branch-pr, judgment-day)
- David Castagneto skills

Y los 5 plugins de Claude Code (powerline, engram, frontend-design, code-review, code-simplifier).
</details>

<details>
<summary><strong>Paso 6 -- Inicializa repositorio git</strong></summary>

Inicializa un repo Git en la carpeta destino con los archivos de configuracion, y crea la carpeta `context/appVersions/v0.1.0/` para el versionado de autoSDD.
</details>

---

## Post-instalacion

### 1. Personaliza los archivos de contexto

```bash
# Edita las guidelines con el stack de TU proyecto
context/guidelines.md

# Completa tu perfil de desarrollador
context/user_context.md
```

### 2. Adapta CLAUDE.md y AGENTS.md

El `CLAUDE.md` que viene es un template generico. Personalizalo con:
- El nombre y descripcion de tu proyecto
- Las tablas de routing de skills segun tu stack
- Los sub-proyectos (si es un monorepo)

El `AGENTS.md` incluye ejemplos de como definir agentes. Reemplazalos con los de tu proyecto.

### 3. Verifica la instalacion

```bash
cd tu-proyecto
claude
# Deberia arrancar Claude Code con autoSDD activo
# Prueba con: "que skills tengo disponibles?"
```

---

## Estructura del proyecto resultante

```
tu-proyecto/
|-- CLAUDE.md                      # Configuracion principal de IA
|-- AGENTS.md                      # Definiciones de agentes especializados
|-- PROGRESS.md                    # Estado del desarrollo (autoSDD)
|-- .gitignore                     # Ignora .env, node_modules, builds
|
|-- .claude/
|   +-- settings.json              # Hooks y permisos del proyecto
|
|-- context/
|   |-- guidelines.md              # Convenciones tecnicas (personalizable)
|   |-- user_context.md            # Tu perfil de desarrollador
|   +-- appVersions/               # Versiones de desarrollo (autoSDD)
|       +-- v0.1.0/                # Primera version
|
|-- feedback/                       # Templates para el sistema de proposals
|   |-- FEEDBACK_TEMPLATE.md        # Plantilla para problemas con herramientas
|   +-- DISCOVERY_TEMPLATE.md       # Plantilla para descubrimientos del proyecto
|
|-- proposals/                      # PRs mergeadas quedan aca como registro
|
|-- src/                            # Tu codigo fuente
+-- tests/                          # Tus tests
```

> Esta es una estructura minima. Adaptala al layout de tu proyecto.

---

## Lo que queda instalado

### autoSDD v5.3

**Framework de desarrollo autonomo** que transforma a Claude Code en un orquestador inteligente que delega trabajo a sub-agentes especializados.

| Aspecto | Detalle |
|---------|---------|
| **Repo** | [github.com/thestark77/autosdd](https://github.com/thestark77/autosdd) |
| **Version** | 5.3 |
| **Ubicacion** | `~/.claude/skills/autosdd/SKILL.md` |
| **Activacion** | Automatica en cada conversacion de Claude Code |
| **Desactivacion** | Prefija tu mensaje con `[raw]`, `[no-sdd]`, o `skip autosdd` |

#### Pipeline de autoSDD

```
VERSION INIT -> TRIAGE -> ROUTE -> PLAN (CREA) -> DELEGATE -> COLLECT -> CLOSE -> KNOWLEDGE UPDATE
```

1. **VERSION INIT** -- Crea `context/appVersions/vX.Y.Z/` y guarda el prompt original
2. **TRIAGE** -- Clasifica la complejidad de la tarea
3. **ROUTE** -- Selecciona el skill apropiado segun el contexto
4. **PLAN (CREA)** -- Crea un `prompt.md` estructurado con Contexto, Requisitos, Especificaciones, Accion
5. **DELEGATE** -- Lanza sub-agentes con skill injection (el orquestador **nunca** escribe codigo directamente)
6. **COLLECT** -- Recoge resultados de los sub-agentes
7. **CLOSE** -- Cierra la version con changelog
8. **KNOWLEDGE UPDATE** -- Actualiza Engram con lo aprendido

#### Regla fundamental

> **El orquestador DELEGA. Nunca escribe codigo fuente directamente.** Si ves que Claude escribe mas de 2 archivos inline, algo esta mal.

---

### Skills instaladas (15+)

| Skill | Fuente | Proposito |
|-------|--------|-----------|
| `prompt-engineering-patterns` | autoSDD | Patrones avanzados de prompting para LLMs |
| `frontend-design` | autoSDD | Interfaces frontend production-grade |
| `interface-design` | autoSDD | Diseno de dashboards y paneles admin |
| `error-handling-patterns` | autoSDD | Patrones de manejo de errores multi-lenguaje |
| `e2e-testing-patterns` | autoSDD | Testing E2E con Playwright/Cypress |
| `playwright-cli` | autoSDD | Automatizacion de browser |
| `claude-md-improver` | autoSDD | Auditoria y mejora de archivos CLAUDE.md |
| `branch-pr` | [gentleman-programming/sdd-agent-team](https://github.com/gentleman-programming/sdd-agent-team) | Workflow de creacion de PRs |
| `judgment-day` | [gentleman-programming/sdd-agent-team](https://github.com/gentleman-programming/sdd-agent-team) | Code review adversarial paralelo |
| `caveman` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Comunicacion ultra-comprimida (ahorra tokens) |
| `caveman-review` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Code review comprimido |
| `compress` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Compresion de archivos de memoria |
| `vercel-react-best-practices` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | Patrones de React/Next.js de Vercel |
| `postgresql-table-design` | autoSDD | Diseno de esquemas PostgreSQL |
| `shadcn` | [shadcn-ui/ui](https://github.com/shadcn-ui/ui) | Gestion de componentes shadcn |
| `skill-creator` | autoSDD | Creacion de nuevas skills |
| `knowledge-graph` | autoSDD | Grafos de conocimiento visuales |

---

### Plugins instalados (5)

| Plugin | Descripcion |
|--------|-------------|
| **claude-powerline** | Status line visual en la terminal -- muestra branch, modelo, tokens |
| **engram** | Memoria persistente MCP -- recuerda decisiones, convenciones, bugs entre sesiones |
| **frontend-design** | Plugin de diseno UI -- genera interfaces de alta calidad |
| **code-review** | Review de codigo automatizado sobre PRs |
| **code-simplifier** | Simplificacion y refactoring de codigo |

---

## Captura de audio con IA (SuperWhisper)

Una de las herramientas mas potentes del workflow no es codigo -- es **hablarle a la IA en vez de escribir**. Es mucho mas rapido dictar un prompt complejo que tipearlo.

### Recomendacion: SuperWhisper

[SuperWhisper](https://superwhisper.com) es una app de escritorio que captura tu voz y la convierte en texto formateado usando IA.

| Aspecto | Detalle |
|---------|---------|
| **Plataformas** | macOS, Windows |
| **Precio** | ~$5 USD/mes con descuento estudiantil |
| **Descarga** | [superwhisper.com](https://superwhisper.com) |
| **Funcion** | Dictar -> IA limpia el texto -> se pega automaticamente |

#### Que hace SuperWhisper por ti

- Elimina muletillas ("eh", "este", "o sea")
- Formatea el texto correctamente (puntuacion, parrafos)
- Aplica correcciones ortograficas
- Funciona en cualquier app del sistema (Slack, VS Code, browser, terminal)

### Alternativa gratuita: ChatGPT / Claude por voz

Si no tienes licencia de SuperWhisper, puedes usar cualquier chat con IA que tenga input de voz:

1. Abre **ChatGPT** o **Claude** en el browser
2. Usa el boton de **input de voz** para dictar
3. Copia el resultado y pegalo donde lo necesites

<details>
<summary><strong>Prompt de formateo de audio (espanol)</strong></summary>

```
# Prompt en espanol (USAR SOLO PARA TEXTO EN ESPANOL)

## ROL
Eres un asistente de transcripcion de voz profesional. Tu unica funcion es tomar audio dictado en espanol y convertirlo en texto limpio, bien puntuado y correctamente formateado.

## REGLAS ABSOLUTAS

1. Solo formatear -- NO respondas, NO comentes, NO agregues informacion. Solo devuelve el texto limpio.
2. Mantener el contenido exacto -- No cambies el significado, no agregues ni quites ideas.
3. Corregir errores de dictado -- Arregla muletillas, repeticiones, falsos inicios.
4. Puntuacion correcta -- Agrega puntos, comas, signos de interrogacion/exclamacion.
5. Parrafos naturales -- Separa en parrafos cuando hay cambio de tema.
6. Espanol neutro -- Mantener el estilo del hablante, corregir errores gramaticales.
7. Terminos tecnicos -- Escribirlos correctamente (TypeScript, no "tai script"; API, no "a pe i").
8. NO usar markdown salvo que el hablante lo pida.
9. NO agregar titulos ni encabezados salvo que el hablante los dicte.
10. Si el audio es una instruccion para IA, formatearlo como tal pero sin ejecutarlo.

## FORMATO DE SALIDA

- Texto limpio, sin comillas envolventes
- Un parrafo por idea principal
- Sin bullet points salvo que el hablante los dicte
- Sin emojis salvo que el hablante los mencione
```

</details>

---

## Sistema de Feedback Participativo

El kit incluye **dos sistemas** para que todo el equipo contribuya. Ambos funcionan igual: la IA te guia para crear un **archivo `.md`** con tu feedback o descubrimiento, y lo sube como PR al repo correspondiente. Ese archivo va a la carpeta `proposals/` con tu nombre de GitHub.

**La PR contiene SOLO ese archivo** -- no modifica codigo ni configuracion. El equipo revisa, vota, y cuando se aprueba, queda como registro permanente y se aplica al proyecto.

### 1. Feedback de Herramientas -- "FEEDBACK DE USO"

Para reportar problemas o mejoras sobre las herramientas de IA (skills, plugins, configuracion).

**Flujo:**

1. **Escribe "FEEDBACK DE USO"** en tu sesion de Claude Code
2. **La IA te guia** por la plantilla (`feedback/FEEDBACK_TEMPLATE.md`)
3. **Se genera un archivo** `proposals/{tu-github}-{descripcion-corta}.md`
4. **Se crea una PR** en el repo del kit
5. **El equipo revisa y vota** en la PR

### 2. Descubrimientos del Proyecto -- "DESCUBRIMIENTO"

Cada desarrollador, en sus sesiones diarias, **descubre cosas sobre el proyecto** que no estaban documentadas. Este sistema captura ese conocimiento.

**Flujo:**

1. **Escribe "DESCUBRIMIENTO"** en tu sesion de Claude Code
2. **La IA te guia** por la plantilla (`feedback/DISCOVERY_TEMPLATE.md`)
3. **Se genera un archivo** `proposals/{tu-github}-{descripcion-corta}.md` que incluye:
   - Que se descubrio
   - Que archivo de contexto deberia actualizarse
   - El prompt/texto propuesto como cambio
   - La evidencia de como se descubrio
4. **Se crea una PR** en el repo del kit
5. **El equipo revisa y vota** -- si tiene sentido, se mergea
6. **El conocimiento se integra** -- toda IA de todo el equipo se beneficia

> **Cada descubrimiento que compartes hace que la IA sea mas inteligente para TODO el equipo.**

### Templates y carpeta de proposals

- `feedback/FEEDBACK_TEMPLATE.md` -- Plantilla para problemas con herramientas
- `feedback/DISCOVERY_TEMPLATE.md` -- Plantilla para descubrimientos
- `proposals/` -- Carpeta donde quedan los archivos mergeados como registro permanente

---

## Como usar Claude Code con este setup

### Flujo diario de trabajo

```bash
# 1. Abre la terminal en la carpeta del proyecto
cd tu-proyecto

# 2. Arranca Claude Code
claude

# 3. autoSDD se activa automaticamente
#    La IA ya conoce las convenciones y tiene acceso a los skills.

# 4. Pide lo que necesites
#    autoSDD va a: crear version -> planificar -> delegar -> ejecutar
```

### Tips de uso

| Situacion | Que hacer |
|-----------|-----------|
| Tarea compleja (nuevo feature) | Deja que autoSDD orqueste -- describe el resultado esperado |
| Pregunta rapida | Prefija con `[raw]` para saltear autoSDD |
| Revisar codigo | Usa el plugin `code-review` sobre un PR |
| Buscar un skill | Pregunta "que skills tengo disponibles?" |
| Memoria entre sesiones | Engram guarda automaticamente |
| Browser testing | Siempre con `--headed` para ver el navegador |

### Comandos especiales dentro de Claude Code

| Comando | Efecto |
|---------|--------|
| `[raw]` (prefijo) | Desactiva autoSDD para esa pregunta |
| `[no-sdd]` (prefijo) | Igual que `[raw]` |
| `skip autosdd` (prefijo) | Igual que `[raw]` |
| `FEEDBACK DE USO` | Reporta problemas/mejoras sobre las herramientas de IA |
| `DESCUBRIMIENTO` | Documenta algo importante que descubriste sobre el proyecto |

---

## Troubleshooting

<details>
<summary><strong>"autoSDD no se activa"</strong></summary>

**Causa**: La skill de autoSDD no se instalo correctamente.

**Solucion**:
1. Verifica que existe `~/.claude/skills/autosdd/SKILL.md`
2. Si no existe, reinstala:
   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh)
   ```
3. Reinicia Claude Code
</details>

<details>
<summary><strong>"Playwright error: browser not found"</strong></summary>

**Causa**: Los browsers de Playwright no estan instalados.

**Solucion**:
```bash
npm install -g playwright
playwright install chromium
```
</details>

<details>
<summary><strong>"Claude Code pide autenticacion"</strong></summary>

**Causa**: Primera ejecucion o token expirado.

**Solucion**: Segui las instrucciones en pantalla para autenticarte con tu cuenta de Anthropic.
</details>

<details>
<summary><strong>"El instalador falla en Windows"</strong></summary>

**Causa**: Estas usando CMD en vez de PowerShell o Git Bash.

**Solucion**: Usa una de estas opciones:
- **PowerShell**: `.\install.ps1`
- **Git Bash**: `bash install.sh`
- **WSL**: `bash install.sh`
</details>

---

## Proyectos relacionados

| Proyecto | Repo | Descripcion |
|----------|------|-------------|
| **autoSDD** | [github.com/thestark77/autosdd](https://github.com/thestark77/autosdd) | Framework de desarrollo autonomo para agentes de IA |
| **be-code-kit** | [github.com/thestark77/be-code-kit](https://github.com/thestark77/be-code-kit) | Version con contexto Bemovil (skills, repos, env, business logic) |

---

## Contributing / Feedback

1. **Sistema de feedback** -- Escribe "FEEDBACK DE USO" en tu sesion de Claude Code
2. **PRs directos** -- Si sabes que cambiar, manda un PR
3. **Issues** -- Reporta bugs o sugerencias en [github.com/thestark77/stark-kit/issues](https://github.com/thestark77/stark-kit/issues)

> Si algo no funciona, si encuentras una mejor forma de hacer algo -- **dilo**.

---

## Licencia

MIT

---

<p align="center">
  <sub>Creado con Claude Code por <a href="https://github.com/thestark77">thestark77</a></sub>
</p>
