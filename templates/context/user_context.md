# Contexto de Usuario — [TU NOMBRE]

> **Propósito**: Documento vivo que describe quién sos, cómo trabajás, qué preferís, y cómo colaborar con vos de forma efectiva. Completá las secciones marcadas con [COMPLETAR].

---

## Identidad

- **Nombre**: [TU NOMBRE COMPLETO]
- **Email**: [TU EMAIL]
- **Ubicación**: [TU CIUDAD / PAÍS]
- **Timezone**: [Ej: America/Bogota (UTC-5)]
- **GitHub**: [TU USUARIO DE GITHUB]

## Roles

- **[TU ROL]** en [TU EMPRESA / PROYECTO]
- **Áreas**: [COMPLETAR — Frontend / Backend / Full-stack / DevOps / etc.]
- **Nivel**: [Junior / Semi-Senior / Senior / Tech Lead]

## Experiencia Técnica

- **Backend**: [Ej: Node.js, Express, TypeScript, Sequelize, PostgreSQL]
- **Frontend**: [Ej: Vue 3, React, Tailwind CSS, Vite]
- **Infraestructura**: [Ej: AWS, Docker, GitHub Actions]
- **AI/Dev Tools**: Claude Code or OpenCode, autoSDD v6.1, Engram memory (Claude Code only — use file-based caching in OpenCode)
- [COMPLETAR — agregá o quitá según tu experiencia real]

## Equipo y Organización

- **Tamaño del equipo**: [Ej: 3 developers, 1 PM]
- **Metodología**: [Ej: Kanban / Scrum / ad-hoc]
- **Tool de gestión**: [Ej: Linear / Jira / Notion / GitHub Issues]

### Workflow de Desarrollo (Branching)
```
1. Recibir asignación de issue
2. Crear feature branch (ej: feat/BEM-374-nombre-corto)
3. Desarrollar y testear localmente
4. PR → rama de staging / sandbox
5. Testing en staging
6. PR → main/master
7. Code review
8. Merge y deploy
```

## Estilo de Trabajo

- [COMPLETAR — describí cómo preferís trabajar con la IA]
- Ejemplo: "Doy contexto extenso y espero que la IA lo retenga"
- Ejemplo: "Prefiero respuestas cortas y directas"
- Ejemplo: "Me gusta entender el WHY, no solo el WHAT"

## Preferencias de Comunicación

- **Idioma**: [Español / English / Mixed]
- **Estilo de respuesta**: [COMPLETAR — preferís respuestas detalladas o concisas?]
- **Profundidad técnica**: [COMPLETAR — te gustan explicaciones técnicas profundas?]

## Hardware y Plan

- **AI Plan**: [COMPLETAR — Claude Pro / Claude Max / API]
- **OS**: [COMPLETAR — Windows / macOS / Linux]
- **Shell**: [COMPLETAR — Bash / PowerShell / Zsh]
- **Package Manager**: [npm / pnpm / yarn / bun]
- **Editor**: Claude Code CLI + [VS Code / Cursor / otro]

## Preferencias No Negociables

- NUNCA agregar "Co-Authored-By" ni atribución de IA a commits — solo conventional commits
- NUNCA hacer build después de cambios — CI/CD lo maneja
- Usar bat/rg/fd/sd/eza — NUNCA cat/grep/find/sed/ls
- Siempre prefijar comandos con `rtk` para optimización de tokens (solo Claude Code CLI). En OpenCode, `rtk` no está disponible — usar comandos directamente
- TypeScript strict, `interface` sobre `type`, sin `any`
- Código en inglés, UI en [idioma del proyecto]
- Cuando hacés una pregunta, STOP y esperá — nunca continuár ni asumir respuestas
- Verificar claims técnicos antes de afirmarlos

---

*Personalizado por: [TU NOMBRE] — [FECHA]*
