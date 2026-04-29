@AGENTS.md

# [Nombre del Proyecto] — Plataforma de Software

[Descripción breve del proyecto — qué hace, para quién, tecnologías principales]

## Leer Antes de Codear

| Documento | Propósito |
|----------|---------|
| `context/guidelines.md` | **Constitución** — stack, convenciones, patrones, seguridad, testing |
| `context/user_context.md` | **Perfil de Usuario** — identidad, preferencias, estilo de trabajo |

## Routing de Sub-Proyectos

Si el proyecto es un monorepo, cada sub-proyecto tiene su propio CLAUDE.md. **Siempre leer el archivo del sub-proyecto relevante antes de codear.**

| Sub-Proyecto | CLAUDE.md | Propósito |
|-------------|-----------|---------|
| Backend | `backend/CLAUDE.md` | API · Node.js · TypeScript |
| Frontend | `frontend/CLAUDE.md` | SPA / SSR · Vue/React |
| [Otro] | `[otro]/CLAUDE.md` | [descripción] |

> Si es un proyecto de un solo repositorio, eliminar esta tabla y documentar stack y comandos directamente aquí.

## Routing de Skills por Contexto

| Patrón de Contexto | Skill | Cuándo activar |
|-------------------|-------|---------------|
| Páginas UI (.tsx/.vue) | `frontend-design` | UI nuevas o rediseño |
| Dashboards / admin | `interface-design` | Paneles internos |
| API routes, validación | `error-handling-patterns` | Endpoints y manejo de errores |
| Schema DB (.prisma, migrations) | `postgresql-table-design` | Diseño de tablas |
| Tests (.test., .spec., e2e) | `e2e-testing-patterns` | Creación de tests |
| Automatización de browser | `playwright-cli` | Siempre con --headed |
| Creación de PR | `branch-pr` | Workflow de PR |
| Seguridad, 5+ archivos | `judgment-day` | Review adversarial |

## Team Knowledge Sharing — Proposals

When the user says **"FEEDBACK DE USO"** or **"DESCUBRIMIENTO"**, follow this exact workflow:

### 1. Guide the user

- **FEEDBACK DE USO** → Read `feedback/FEEDBACK_TEMPLATE.md` and walk the user through each section (problem, context, expected vs actual, proposed solution, priority).
- **DESCUBRIMIENTO** → Read `feedback/DISCOVERY_TEMPLATE.md` and walk the user through each section (what was discovered, which context file it affects, proposed change as a prompt, evidence, impact).

### 2. Build the proposal file

Create a single `.md` file with the filled-out template. The file name format is:

```
proposals/{github-username}-{short-slug}.md
```

Example: `proposals/juandev-cache-invalidation-bug.md`

### 3. Create the PR

```bash
# Clone this project's kit repo to a temp dir
git clone https://github.com/{kit-repo}.git /tmp/{repo-name}
cd /tmp/{repo-name}

# Create branch and add the proposal file
git checkout -b proposal/{github-username}-{short-slug}
cp {proposal-file} proposals/
git add proposals/
git commit -m "proposal: {short description}"
git push -u origin proposal/{github-username}-{short-slug}

# Create PR
gh pr create --title "Proposal: {short description}" --body "$(cat <<'EOF'
## Tipo
- [ ] FEEDBACK DE USO — problema o mejora de herramientas
- [ ] DESCUBRIMIENTO — conocimiento del proyecto

## Resumen
{1-2 sentences}

Propuesto por @{github-username}
EOF
)"
```

### 4. Share the PR URL with the user

The proposal file is the ONLY change in the PR. No code modifications. When the team merges the PR, the `.md` file gets added to the `proposals/` folder as a record.

## Libertad Operacional del Agente

- **Base de datos LOCAL es tuya**: crear, leer, actualizar, borrar datos libremente
- **Iniciar servidor de dev** y testear features via Playwright o curl
- **Preguntar antes de suponer**: Si preguntas aclaratorias aumentarían significativamente el éxito, PREGUNTAR PRIMERO
- **Sugerir mejoras**: Proponer proactivamente mejoras
- **Leer CLAUDE.md del sub-proyecto**: Siempre leer las convenciones relevantes antes de codear
- **Pedir contexto adicional proactivamente**: En cualquier momento — especialmente ANTES de empezar — pedir ejemplos de logs, registros de DB, respuestas de API, screenshots, o cualquier contexto que ayude a entregar mejores resultados

## autoSDD v5.3 — Pipeline Activo (NO REMOVER)

TODOS los prompts pasan por autoSDD salvo `[raw]`, `[no-sdd]`, o `skip autosdd`.

### Reglas Core
1. **DELEGAR** — nunca escribir 2+ archivos inline. Leer SKILL.md Sección 1.
2. **VERSION PRIMERO** — antes de planificar, crear `context/appVersions/vX.Y.Z/` + guardar `original_prompt.md`
3. **PROGRESS.md es sagrado** — actualizar en cada paso. Es el ancla de supervivencia ante compactación.
4. **Feedback después de cada tarea** — hacer al usuario ≥1 pregunta estratégica. Persistir respuestas.

### Pipeline
`VERSION INIT → TRIAGE → ROUTE → PLAN (CREA) → DELEGATE → COLLECT → CLOSE → KNOWLEDGE UPDATE`

### Routing (si X → usar skill Y)
| Contexto | Skill |
|---------|-------|
| UI pública (.tsx/.vue pages) | `frontend-design` |
| UI admin/dashboard | `interface-design` |
| API routes, validación | `error-handling-patterns` |
| Schema DB, .prisma | `postgresql-table-design` |
| Tests (.test., .spec.) | `e2e-testing-patterns` |
| Automatización browser | `playwright-cli` (SIEMPRE --headed) |
| Creación de PR | `branch-pr` |
| Seguridad, 5+ archivos | `judgment-day` |

**Screenshots**: TODAS las capturas de Playwright → `context/appVersions/vX.Y.Z/screenshots/` (versión actual). Nunca en otro lugar.

### Knowledge Caching (ahorra tokens)
Antes de leer 4+ archivos → revisar Engram `knowledge/{project}/{topic}` para mapas en caché.
Después de entender un flujo → guardar un mapa de 20 líneas en Engram.

### Compaction Recovery (leer esto DESPUÉS de cualquier compactación)
1. Leer `PROGRESS.md` (ancla de estado)
2. Leer el `prompt.md` de la versión actual
3. `mem_context()` + `mem_search("session/{project}")`
4. Retomar desde donde dice PROGRESS.md

### Hooks
- **SubagentStop**: Actualizar PROGRESS.md + guardar observación + revisar deuda de feedback
- **PreCompact**: Guardar TODO el estado en PROGRESS.md + Engram AHORA (compactación inminente)
- **Stop**: Verificar que feedback.md fue generado + PROGRESS.md está actualizado
- **UserPromptSubmit**: Resetear debounce del stop-hook

### gentle-ai (foundation opcional)
Provee: Engram MCP · fases SDD · persona · model-assignments · branch-pr · judgment-day
autoSDD funciona sin él (modo degradado).

Leer framework completo: `~/.claude/skills/autosdd/SKILL.md`
