# autoSDD v6.1 — OpenCode Instructions

> This file is read by OpenCode via contextPaths. It adapts the autoSDD pipeline for OpenCode's tooling.
> Claude Code CLI uses hooks (.claude/settings.json) — this file is only for OpenCode.

---

## Mandatory Behaviors (NON-NEGOTIABLE)

These replace the Claude Code hooks. Enforce them on EVERY interaction:

### On Every User Prompt (replaces UserPromptSubmit hook)

Before processing any user message:

1. Read PROGRESS.md to restore context
2. Apply orchestrator rules:
   - **INLINE**: coordination, git ops, 1-file edits, reads 1-3 files
   - **DELEGATE**: 2+ files, 4+ reads, tests/builds, multi-step execution
   - **ALWAYS DELEGATE**: 2+ independent parallel tasks (use Task tool with subagent_type="general")
   - **Event-driven ONLY**: Never sleep/poll. Use Bash for builds, Task tool for parallel work

### After Every Task Tool Returns (replaces SubagentStop hook)

When a Task (sub-agent) completes:

1. Update PROGRESS.md with task result (DONE/FAILED/PARTIAL + 1-line note)
2. If you haven't asked the user a feedback question this version yet — ask one NOW

### Before Context Compaction (replaces PreCompact hook)

When the conversation is getting long and compaction seems imminent:

1. Update PROGRESS.md with ALL in-flight task states and decisions
2. Save knowledge to context files (`context/appVersions/knowledge/`)
3. If feedback.md hasn't been generated yet, note 'PENDING' in PROGRESS.md

### Before Responding to User (replaces Stop hook)

Before you finish responding:

1. Check: Is PROGRESS.md current?
2. Check: Has feedback.md been generated for this version?
3. Check: Are there pending observations to save?

### After Compaction (recovery)

After any compaction:
1. Read PROGRESS.md (your state anchor)
2. Read current version's prompt.md
3. Resume from where PROGRESS.md says

---

## Pipeline (autoSDD v6.1)

ALL prompts go through autoSDD unless `[raw]`, `[no-sdd]`, or `skip autosdd`.

### Steps

0. **VERSION INIT** — Run `scripts/version-init.sh` to create version folder + reset PROGRESS.md
0.5. **CONTEXT SCOUT** — Use Task tool with subagent_type="explore" to gather relevant context quickly
1. **TRIAGE** — Clarity: HIGH=proceed, MEDIUM=ask 1-3 things, LOW=stop
2. **ROUTE** — DEV/DEBUG/REVIEW/RESEARCH
3. **PLAN (CREA)** — Build prompt.md with CREA structure
4. **DELEGATE** — Task tool with appropriate subagent_type + clear instructions
5. **COLLECT** — Validate results, update PROGRESS.md
6. **CLOSE VERSION** — Generate feedback.md
7. **KNOWLEDGE UPDATE** — Update context files

### Skill Routing

| Context | Skill/Approach |
|---------|----------------|
| UI pages (.tsx/.vue) | `frontend-design` patterns |
| Admin/dashboard | `interface-design` patterns |
| API routes, validation | `error-handling-patterns` patterns |
| DB schema, .prisma | `postgresql-table-design` patterns |
| Tests (.test., .spec.) | `e2e-testing-patterns` patterns |
| Browser automation | Playwright (ALWAYS --headed) |
| PR creation | Git workflow |
| Security, 5+ files | Thorough review |

### Model Strategy (OpenCode)

When using Task tool, prefer:
- **explore** subagent: For code exploration and quick searches
- **general** subagent: For implementation, multi-step tasks

The orchestrator (main session) coordinates and delegates.

---

## Knowledge Caching (replaces Engram MCP)

Engram MCP is NOT available in OpenCode. Use file-based knowledge caching instead:

- **Read**: Before reading 4+ files, check `context/appVersions/` for cached maps
- **Write**: After understanding a flow, save a 20-line map to `context/appVersions/knowledge/`
- **Format**: `Purpose → Files → Flow (step1→step2→step3) → Key decisions → Gotchas`

---

## Core Rules

1. **DELEGATE** — never write 2+ files inline. Use Task tool for delegation.
2. **VERSION FIRST** — before planning, create `context/appVersions/vX.Y.Z/` + save `original_prompt.md`
3. **PROGRESS.md is sacred** — update at every step
4. **Feedback after every task** — ask user ≥1 strategic question
5. **Read CLAUDE.md and AGENTS.md** for project-specific conventions
6. **Read context/guidelines.md** for technical rules before coding