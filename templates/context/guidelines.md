# Project Guidelines

> **Propósito**: Convenciones no negociables, patrones y reglas arquitectónicas para este proyecto. El orquestador DEBE leer y hacer cumplir estas reglas en cada tarea. Los sub-agentes las reciben vía prompts estructurados con CREA.

---

## Rol

Sos un desarrollador full-stack senior construyendo software de producción. Escribís código limpio, type-safe y performante siguiendo los patrones establecidos. Priorizás seguridad, consistencia con el código existente, y mantenibilidad a través del equipo.

---

## 1. Stack Tecnológico

> **Completar esta sección con el stack real del proyecto.** Lo que sigue son convenciones genéricas para proyectos TypeScript/Node.js — adaptalo a tu realidad.

### Backend (Node.js / Express)

| Capa | Tecnología | Notas |
|------|-----------|-------|
| Runtime | Node.js 20+ | ESM modules (`"type": "module"`) |
| Framework | Express 5 | o Fastify / Hono según el proyecto |
| Lenguaje | TypeScript 5 strict | `noUnusedLocals`, `noUnusedParameters`, `noImplicitAny` |
| Validación | Zod 4 | En CADA endpoint — códigos de error, no texto |
| ORM / Query | [Sequelize / Prisma / Drizzle / kysely] | Según el proyecto |
| Base de datos | [MySQL / PostgreSQL / SQLite] | Según el proyecto |
| Auth | JWT (jsonwebtoken) | + MFA opcional |
| Testing | Vitest + Supertest | Tests E2E colocados como `*.e2e.test.ts` |
| Linter | ESLint 10 + Prettier | Import sorting obligatorio |

### Frontend

| Capa | Tecnología | Notas |
|------|-----------|-------|
| Framework | [Vue 3 / React / SvelteKit] | Según el proyecto |
| Bundler | Vite 5 | Build tool estándar |
| Estado | [Pinia / Zustand / Vuex / Redux] | Según el framework |
| Estilos | Tailwind CSS 3+ | Utility-first preferido |
| TypeScript | 5 strict | Tipado completo obligatorio en archivos nuevos |

### Infraestructura

| Componente | Servicio |
|-----------|---------|
| Cloud | [AWS / GCP / Vercel / Railway / Fly.io] |
| CI/CD | GitHub Actions |
| Logs | [Axiom / Datadog / Logtail / consola] |
| Deploy | [según el proyecto] |

---

## 2. Convenciones de Código

### Reglas Universales

- **Idioma del código**: Inglés (variables, funciones, tipos, comentarios, commits)
- **Idioma de la UI**: [Español / inglés] según el proyecto
- **TypeScript strict mode**: `interface` sobre `type`, sin `any`, sin `as unknown`
- **Versiones exactas** en package.json (sin `^`) — evita sorpresas en CI
- **Conventional commits**: Sin atribución de IA (sin "Co-Authored-By")
- **Nunca buildear** después de cambios — CI lo maneja
- **CLI tools**: `bat`/`rg`/`fd`/`sd`/`eza` — nunca `cat`/`grep`/`find`/`sed`/`ls`
- **RTK prefix**: Siempre prefijar comandos de shell con `rtk` para optimización de tokens
- **Preferir Tailwind**: Clases utility sobre estilos inline o CSS/SCSS custom. Solo custom CSS cuando Tailwind no puede expresar el estilo o es significativamente más conveniente
- **Performance > Estética**: Nunca sacrificar velocidad de carga por efectos visuales. Animaciones con propiedades GPU-aceleradas (`transform`, `opacity`). Respetar `prefers-reduced-motion`

### Convenciones Backend

- **Path aliases**: Usar siempre `@/app/*`, `@/config/*`, `@/helpers/*`, `@/models/*`, `@/routes/*` (configurar en tsconfig.json y bundler)
- **Formato de respuesta**: Helper centralizado para respuestas — nunca `res.json()` directamente
- **Error handling**: Errores tipados lanzados desde handlers — capturados por middleware centralizado
- **Códigos de error**: Claves i18n (ej: `auth.incorrect.userOrPassword`), no texto hardcodeado
- **Validación**: Schema Zod al inicio de cada handler, validado antes de ejecutar lógica de negocio
- **Patrón de handler (objetivo)**:
  ```typescript
  import { z } from 'zod';

  const schema = z.object({
    email: z.string().email(),
    password: z.string().min(8),
  });

  export default async function handler(req: Request, res: Response) {
    const data = validate(schema, req.body); // lanza error tipado si falla
    // ... lógica de negocio ...
    respond(res, result);
  }
  ```
- **Soft deletes**: `deletedAt` timestamp en lugar de borrado físico cuando corresponda
- **Separación write/read**: Soportar réplicas de lectura cuando la escala lo requiera

### Convenciones Frontend

- **Requests centralizados**: Método o composable único para todas las llamadas al backend
- **Estructura de componentes**: `src/components/`, `src/views/`, `src/layouts/`
- **Estado global**: Store dedicado (Pinia/Zustand) — no prop drilling profundo
- **Routing guards**: Middleware/guards para proteger rutas autenticadas
- **i18n**: Archivos de traducción en `src/i18n/` o `src/locales/`

---

## 3. Patrones de Arquitectura

### Backend: Estructura por Dominio

```
src/
├── app/                    # Dominio de la aplicación
│   ├── auth/               # Autenticación
│   ├── users/              # Gestión de usuarios
│   ├── [domain]/           # Cada dominio en su carpeta
│   │   ├── route.ts        # Handler del endpoint
│   │   ├── schema.ts       # Zod schemas
│   │   ├── service.ts      # Lógica de negocio
│   │   └── e2e.test.ts     # Tests colocados
│   └── types.d.ts          # Tipos compartidos
├── config/                 # Configuración (env, DB, etc.)
├── helpers/                # Utilidades compartidas
├── middleware/             # Express middleware
├── models/                 # Modelos de datos / ORM
└── index.ts                # Entry point
```

### Backend: Error Handling Centralizado

```
Request → Express → controller → try/catch
                                    ├── AppError (status + code) → respond() con código de error
                                    └── Error desconocido → respond() con 500 + "server.error"
```

Clases de error recomendadas: `NotFoundError`, `BadRequestError`, `UnauthorizedError`, `ForbiddenError`, `ConflictError`, `InternalError`

### Frontend: Estructura de Componente

```typescript
// Patrón preferido (Vue 3 Composition API)
<script setup lang="ts">
import { ref, computed } from 'vue'

interface Props { ... }
const props = defineProps<Props>()
const emit = defineEmits<{ ... }>()

// lógica del componente
</script>

<template>
  <!-- template limpio, sin lógica compleja -->
</template>
```

---

## 4. Reglas de Seguridad

- **Validación de inputs**: Zod en CADA endpoint — sin excepciones
- **Hashing de passwords**: bcrypt con salt rounds ≥ 12
- **JWT**: Tokens validados en middleware antes de llegar al handler. Refresh tokens con rotación
- **CORS**: Configurar orígenes explícitos — no `*` en producción
- **Secret scanning**: GitHub Action con `detect-secrets` en cada push
- **Rate limiting**: `express-rate-limit` o similar en endpoints públicos y de auth
- **Sin secretos hardcodeados**: Todas las credenciales en `.env`, validadas por Zod en `config/env.ts`
- **Headers de seguridad**: `helmet` en Express para headers HTTP de seguridad
- **SQL injection**: Queries parametrizadas vía ORM — nunca interpolación de strings
- **OWASP Top 10**: Revisar cada feature nueva contra las vulnerabilidades más comunes:
  - A01: Broken Access Control → verificar permisos en cada endpoint
  - A02: Cryptographic Failures → TLS, hashing correcto, no MD5/SHA1 para passwords
  - A03: Injection → ORM parameterizado, Zod en inputs
  - A05: Security Misconfiguration → CORS restrictivo, headers, env vars
  - A07: Auth Failures → JWT seguro, rate limiting, no credenciales en logs

---

## 5. Convenciones de Testing

### Backend

```bash
rtk vitest run                    # Correr todos los tests
rtk vitest --coverage             # Tests con reporte de cobertura
rtk tsc --noEmit                  # Type checking sin compilar
rtk eslint ./src                  # Lint
```

- Tests colocados con features: `app/{domain}/e2e.test.ts`
- Vitest con globals, sin isolation (`--no-isolate`), timeout 30s
- Tests contra base de datos REAL (o contenedor local) — no mocks de DB
- Testear happy paths y critical paths — no sobreingeniería
- Cobertura mínima objetivo: 70% en lógica de negocio crítica

### Frontend

```bash
rtk vue-tsc --noEmit              # TypeScript check (Vue)
rtk tsc --noEmit                  # TypeScript check (React/genérico)
rtk eslint ./src                  # Lint
rtk vitest run                    # Unit/component tests
```

### CI/CD Pipeline (GitHub Actions)

| Workflow | Trigger | Propósito |
|----------|---------|-----------|
| `lint.yml` | Push/PR | ESLint check |
| `typecheck.yml` | Push/PR | TypeScript check |
| `test.yml` | Push/PR | Tests automatizados |
| `secret-scan.yml` | Push/PR | detect-secrets scan |
| `deploy.yml` | Tag `v*.*.*` | Deploy a producción |

### Convención de Deploy

- Tags con `-` sufijo (ej: `v1.2.3-beta`) → Staging / Sandbox
- Tags sin `-` (ej: `v1.2.3`) → Producción

---

## 6. Git Workflow

### Branching

```
main / master          ← producción estable
  └── develop          ← integración (opcional, según tamaño del equipo)
       └── feat/ISSUE-123-descripcion-corta
       └── fix/ISSUE-456-descripcion-corta
       └── chore/actualizar-dependencias
```

### Conventional Commits

```
feat(auth): agregar login con Google OAuth
fix(api): corregir validación de email en registro
chore(deps): actualizar zod a v4
refactor(users): extraer lógica de validación a helper
test(auth): agregar tests para refresh token
docs(api): actualizar doc.md de endpoint /users
```

Reglas:
- Descripción en presente imperativo
- Sin mayúscula inicial
- Sin punto al final
- Scope opcional pero recomendado
- Sin "Co-Authored-By" ni atribución de IA

### Pull Requests

- Título = mensaje de commit principal (conventional)
- Descripción: qué cambia, por qué, cómo testear
- Al menos 1 reviewer antes de mergear a main
- CI debe pasar antes del merge (lint, typecheck, tests)
- Squash merge recomendado para mantener historia limpia

---

## 7. Gotchas y Advertencias Técnicas

> Completar esta sección con gotchas específicos del proyecto a medida que los descubrás.

1. **TypeScript paths**: Asegurate de configurar `paths` en `tsconfig.json` Y en `vite.config.ts` / `tsup.config.ts` — solo uno no alcanza
2. **ESM + CJS**: Node.js con `"type": "module"` rompe algunos paquetes legacy — verificar compatibilidad antes de agregar dependencias
3. **Zod v4**: La API cambió respecto a v3. `.parse()` lanza, `.safeParse()` devuelve `{ success, data, error }`. No mezclar versiones entre proyectos del monorepo
4. **Variables de entorno en frontend**: Las variables VITE_* se embeben en el bundle en build time — nunca poner secretos ahí
5. **Prisma migrations en CI**: `prisma migrate deploy` (no `dev`) en CI — `dev` es interactivo y puede crear migraciones no deseadas
6. **Race conditions en tests concurrentes**: Si los tests comparten estado en DB, usar transacciones o rollback por test para evitar flakiness
7. **`any` en TypeScript**: Prohibido. Si ves `any`, refactorizá. Si viene de una librería sin tipos, usar `unknown` y narrowing explícito

---

*Última actualización: [FECHA]*
