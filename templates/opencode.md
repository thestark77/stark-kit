# autoSDD v6.1 — OpenCode Instructions

> This file is loaded by OpenCode via the `instructions` field in opencode.json.
> Do NOT read CLAUDE.md — it contains Claude Code-specific hooks incompatible with OpenCode.
> This file adapts the autoSDD pipeline for OpenCode's tooling.
> Engram MCP is configured globally for OpenCode with semantic search (embeddings) enabled.

---

## Project Info

@AGENTS.md

See the project's AGENTS.md for agent definitions and shared rules.
See `context/guidelines.md` for technical conventions.
See `context/user_context.md` for user preferences.

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
   - **Event-driven ONLY**: NEVER use sleep, setInterval, polling loops, or any form of waiting. When a build or long process is running, use Bash and check results. When you need parallel work, use Task tool with subagent_type="general". NEVER block the conversation waiting for something.

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

OpenCode has 5 built-in agents. Model assignments are configured in `opencode.json` (see `context/models.json` for presets):

- **build** (main session): Orchestrator — coordinates, delegates, makes decisions
- **general** (sub-agent): Implementation — reads code, executes multi-step tasks
- **explore** (sub-agent): Context scout — quick code exploration and searches
- **title** (session titles): Cheapest model, generates session titles
- **compaction** (context compaction): Saves conversation state before compaction

When using Task tool, prefer:
- **explore** subagent: For code exploration and quick searches
- **general** subagent: For implementation, multi-step tasks
- **NO polling/sleep**: OpenCode has no "Monitor" or "Background Agent" tool. NEVER use sleep loops, setInterval, or polling. Use Bash for commands and Task tool for parallel sub-agents.

### autoSDD Role → OpenCode Agent Mapping

Resolve the model from `context/models.json` active preset. OpenCode maps roles to agent types:

| autoSDD Role | subagent_type | Model tier |
|---|---|---|
| context-scout | explore | cheapest (haiku-tier) |
| version-close | explore | cheapest (haiku-tier) |
| knowledge-update | explore | cheapest (haiku-tier) |
| precompact-save | (compaction agent) | cheapest (haiku-tier) |
| prompt-analyst | explore | cheapest (haiku-tier) |
| sdd-apply, sdd-verify, sdd-* | general | default (sonnet-tier) |
| feedback-report, knowledge-graph | general | default (sonnet-tier) |

Utility/mechanical tasks use `explore` (cheaper model). Implementation tasks use `general`.

---

## Knowledge (Engram MCP with Semantic Search)

Engram MCP is configured as a local MCP server in OpenCode's global config (`~/.config/opencode/opencode.json`). It provides `mem_save`, `mem_search`, `mem_context`, and `mem_session_summary` tools with **semantic search enabled** (OpenRouter embeddings: `openai/text-embedding-3-small`).

### When to use Engram

- **mem_search**: Before starting work, search for relevant past decisions, bugs, patterns — supports cross-language semantic matching
- **mem_save**: After important decisions, bug fixes, discoveries, or user preferences — proactive, don't wait to be asked
- **mem_context**: At session start or after compaction — recover previous session context
- **mem_session_summary**: Before ending a session — summarize what was accomplished

### How to call

Use the `engram` MCP tools directly in OpenCode:
- `engram__mem_search` — semantic + keyword search across all memories
- `engram__mem_save` — save a new memory observation
- `engram__mem_context` — get recent context for the current project
- `engram__mem_session_summary` — save a session summary

### Also keep file-based knowledge

In addition to Engram, maintain `context/appVersions/knowledge/` as a secondary reference:
- **Read**: Before reading 4+ files, check both `mem_search` and `context/appVersions/` for cached maps
- **Write**: After understanding a flow, save to both Engram AND `context/appVersions/knowledge/`

---

## What's Different from Claude Code

| Feature | Claude Code | OpenCode |
|---------|------------|----------|
| Hooks | `.claude/settings.json` | None (enforced in this file) |
| Sub-agents | `Agent({ model: "{role}" })` | Task tool with subagent_type |
| Memory | Engram MCP (`mem_save/search/context`) | Engram MCP (configured globally) — same tools, semantic search enabled |
| Model switching | `model: "opus"/"sonnet"/"haiku"` | `context/models.json` presets → `opencode.json` agents |
| Pre-compaction save | PreCompact hook | "Before Context Compaction" section above (manual) |
| Post-sub-agent check | SubagentStop hook | "After Every Task" section above (manual) |
| Orchestrator reminder | UserPromptSubmit hook | "On Every User Prompt" section above (manual) |
| Wait for builds/processes | Monitor tool or Background Agent | Use Bash tool — run command, check exit code, read output directly |
| Long-running async tasks | Background Agent (Claude Code) | Task tool with subagent_type="general" — fire and monitor |

---

## What OpenCode Doesn't Have

OpenCode has **no** Monitor tool, Background Agent, or any polling/sleep mechanism. This means:
- **NEVER** use `sleep`, `setInterval`, or polling loops to wait for builds or processes
- Use **Bash** tool to run commands — check the exit code and output directly
- Use **Task tool** with `subagent_type="general"` for parallel work — fire and monitor results
- There is no way to "wait in the background" — all work is synchronous and event-driven

---

## Core Rules

1. **Delegation**: `sdd-orchestrator.md` is authoritative — autoSDD does NOT override or duplicate. Use Task tool for delegation.
2. **VERSION FIRST** — before planning, create `context/appVersions/vX.Y.Z/` + save `original_prompt.md`
3. **PROGRESS.md is sacred** — update at every step
4. **Feedback after every task** — ask user ≥1 strategic question
5. **Read AGENTS.md** for project-specific agent definitions and shared rules
6. **Read context/guidelines.md** for technical rules before coding
7. **Do NOT read CLAUDE.md** — it contains Claude Code-specific hooks and Agent() calls incompatible with OpenCode