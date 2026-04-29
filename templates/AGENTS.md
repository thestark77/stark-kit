# [Nombre del Proyecto] — Definiciones de Agentes

> Configuraciones de agentes especializados para este proyecto. Referenciado por `@AGENTS.md` en el `CLAUDE.md` raíz.
>
> **Instrucciones para adaptar**: Reemplazá los agentes de ejemplo con los que tu proyecto necesita. Eliminá los que no apliquen. Agregá los que falten.

---

## Cómo Definir un Agente

Cada agente debe especificar:
- **Descripción**: qué hace este agente, en qué se especializa
- **Archivos de contexto**: qué leer antes de ejecutar (máximo 3-4 archivos)
- **Reglas clave**: las 5-7 convenciones más importantes para este dominio

---

## backend-dev

**Descripción**: Agente de desarrollo backend — API REST/GraphQL, validación, modelos, integraciones con servicios externos.

**Archivos de contexto**:
- `backend/CLAUDE.md` — convenciones y comandos del backend
- `context/guidelines.md` — reglas técnicas del proyecto

**Reglas clave**:
- Validación Zod en CADA endpoint via helper centralizado
- Respuestas via helper de respuesta — nunca `res.json()` directamente
- Lanzar errores tipados — capturados por middleware centralizado
- Path aliases: `@/app/*`, `@/config/*`, `@/helpers/*`, `@/models/*`
- Soft deletes donde corresponda (`deletedAt` timestamp)
- Sin `any` en TypeScript — `unknown` con narrowing si es necesario

---

## frontend-dev

**Descripción**: Agente de desarrollo frontend — componentes, páginas, estado, routing, i18n.

**Archivos de contexto**:
- `frontend/CLAUDE.md` — convenciones y comandos del frontend
- `context/guidelines.md` — reglas técnicas del proyecto

**Reglas clave**:
- Requests centralizados via composable/service — nunca fetch directo en componentes
- TypeScript estricto en archivos nuevos — no `any`
- Estado global via store (Pinia/Zustand) — no prop drilling profundo
- UI en [idioma del proyecto], código en inglés
- Tailwind utility classes — CSS custom solo cuando es necesario
- Accesibilidad básica: roles ARIA, `alt` en imágenes, contraste suficiente

---

## fullstack-dev

**Descripción**: Agente para features que cruzan backend y frontend — útil en proyectos pequeños o tareas integradas.

**Archivos de contexto**:
- `context/guidelines.md` — reglas técnicas del proyecto
- `context/user_context.md` — perfil del usuario/equipo

**Reglas clave**:
- Empezar siempre por el contrato de la API (tipos/schema) antes de implementar
- Mantener consistencia de tipos entre backend y frontend (tipos compartidos si aplica)
- Todas las reglas de backend-dev y frontend-dev aplican en sus dominios respectivos

---

## test-agent

**Descripción**: Agente especializado en escribir tests E2E, de integración y unitarios.

**Archivos de contexto**:
- `context/guidelines.md` — requisitos de testing (Sección 5)

**Reglas clave**:
- Tests colocados junto a la feature: `{domain}/e2e.test.ts`
- Vitest con globals, timeout 30s mínimo para tests E2E
- Tests contra base de datos REAL (o contenedor local) — no mocks de DB
- Testear happy paths y critical paths únicamente — sin sobreingeniería
- Usar Supertest para aserciones HTTP en backend

---

## [AGENTE CUSTOM — EJEMPLO: infra-dev]

**Descripción**: [Describir qué hace este agente]

**Archivos de contexto**:
- [Archivo 1]
- [Archivo 2]

**Reglas clave**:
- [Regla 1]
- [Regla 2]
- [Regla 3]

> Copiá este bloque para agregar más agentes específicos a tu proyecto.

---

## Compartido — Todos los Agentes

Estas reglas aplican a TODOS los agentes sin excepción:

### Conocimiento Colectivo

Cuando el usuario dice **"FEEDBACK DE USO"**, guiarlo a través de `feedback/FEEDBACK_TEMPLATE.md` para reportar problemas o mejoras con el setup de IA, luego ayudarlo a crear un PR al repo de stark-kit.

Cuando el usuario dice **"DESCUBRIMIENTO"**, guiarlo a través de `feedback/DISCOVERY_TEMPLATE.md` para documentar conocimiento del proyecto descubierto durante la sesión. Ayudarlo a crear un PR proponiendo actualizaciones específicas a los archivos de contexto. Así el equipo construye inteligencia colectiva.

### Reglas Operacionales

- Base de datos LOCAL: leer, escribir, borrar libremente
- Iniciar servidor de dev y testear con Playwright o curl
- Pedir contexto adicional proactivamente — screenshots, logs, registros de DB
- Preguntar antes de suponer en decisiones con alto impacto
- Verificar claims técnicos antes de afirmarlos
- Leer CLAUDE.md del sub-proyecto antes de escribir código
