# Harness Engineer Skill

**Name:** harness-engineer  
**Purpose:** Build comprehensive engineering scaffolding for AI-collaborative projects  
**Triggers:** New project setup, scaffold requests, repo modernization for agent-friendly workflows

---

## Overview

This skill constructs a reliable **Agent Harness**—constraints, templates, and feedback loops—enabling consistent AI collaboration across sessions. The harness prevents context loss, reduces repeated mistakes, and establishes normalized workflows.

---

## Trigger Conditions

**Execute when:**
- User explicitly requests "scaffolding / init / setup harness / engineering governance"
- Starting a new project or converting existing repos for agent collaboration
- User reports "Claude forgets progress after restart" or "same errors repeat"
- Establishing standardized workflows for repetitive tasks

**Skip when:**
- Single-session Q&A or minor edits without structural intent
- Complete harness already exists (CLAUDE.md, input/backlog.md, status.md, learnings.md, README.md, docs/, notes/) and no audit requested

---

## Execution Modes

Use **Glob detection** first to categorize:

| Mode | Condition | Action |
|------|-----------|--------|
| `init` | Directory empty or most scaffolding missing | Build complete harness; copy + substitute templates |
| `audit` | Partial scaffolding exists or explicit audit request | Report present/missing/inconsistent items; no writes |
| `migrate` | User requests structure change (e.g., `.agent/` → `.claude/`) | Execute only on explicit instruction |

---

## Five Dimensions

### 1. **Context Map** (CLAUDE.md as Index)
One-page Agent reference linking to detailed docs. Contains: project tagline, tech stack, prohibitions (in Traditional Chinese), and pointers to `/docs/architecture.md`, `learnings.md`, `status.md`, `input/backlog.md`.

### 2. **Modular Skills**
Separate skill directories for high-frequency tasks. YAML metadata + SKILL.md + scripts/templates. Progressive disclosure avoids overwhelming long documents.

### 3. **Mechanical Enforcement**
Hook templates (PreToolUse, PostToolUse, Stop, UserPromptSubmit) enforce guardrails automatically. Non-compliant actions exit with code 2 + error feedback. *Provide templates only; user enables in settings.json.*

### 4. **MCP Connectivity**
External resources (Jira, databases, logs) accessed via MCP servers returning structured data, not guessed APIs.

### 5. **Self-Improving Loop**
`learnings.md` (persistent experience) + `eval.json` (binary verification) enable continuous refinement. Stop hook writes lessons back after task completion.

---

## Core Scaffolding Artifacts

### Step 1: `input/backlog.md` (Single Source of Truth)
**Combined planning and tracking hub.** Contains:
- **Project Objectives** — goals and acceptance criteria
- **Phase Plan** — Phase 1–N with deliverables, estimates, blockers
- **Backlog table** — ID / Description / Status (⬜🔨✅🚫⏸) / Dependencies / Completion Date
- **Open Questions**

**Rules:**
- Status changes only here; other docs contain specs only, no checkboxes
- Replaces the former root-level `plan.md` — all planning lives in `input/`
- The `input/` directory is the single planning hub; add additional input files as needed (e.g., `input/requirements.md`, `input/constraints.md`)

### Step 2: `status.md`
Session recovery pointer. Format: current work item ID + next instruction. No checkbox lists.  
**Inquiry:** Should this be in `.gitignore` (personal) or tracked (team-shared)?

### Step 3: `learnings.md` (Agent-Focused)
Format: `[YYYY-MM-DD] Situation → Error → Root Cause → Avoidance Rule`  
Agents read on session start to prevent repeated mistakes.

### Step 4: `README.md` (Human-Readable)
One-sentence intro, installation reference, start/stop methods, directory tree, links to `/docs/`.  
**Rule:** If > 200 lines, externalize to `/docs/` and link from README.

### Step 5: Four Directories
- `/input/` — Planning hub: backlog, requirements, constraints, and all upstream inputs
- `/docs/` — Architecture, APIs, deployment, troubleshooting
- `/notes/` — Presentation materials for `pptx-generator` (dated topic markdown with prompt history, dependencies, outcomes)
- `/status-history/` — Archived checkpoints

---

## Migration: plan.md → input/backlog.md

When auditing a project that still has a root-level `plan.md`:
1. Move phase plan content into the **Phase Plan** section of `input/backlog.md`
2. Move work items into the **Backlog table**
3. Delete `plan.md` from root
4. Update `CLAUDE.md` pointers from `plan.md` → `input/backlog.md`

---

## pptx-generator Integration

`/notes/` markdown (named `YYYYMMDD-topic.md`) feeds presentation generation. Required fields:
- Title / one-sentence positioning
- Initial prompt (project driver)
- Process prompt summary (turning points)
- Package dependencies (package.json / requirements.txt excerpts)
- Skill dependencies (which .claude/skills or .agent/skills used)
- Quantified outcomes (metrics, screenshots)

---

## Execution Checklist (Output to User)

```markdown
## Harness Implementation Checklist

- [ ] CLAUDE.md (Agent map)
- [ ] input/backlog.md (planning hub + single work item source)
- [ ] status.md (current pointer + next step)
- [ ] learnings.md (Agent experience log)
- [ ] README.md (human reference)
- [ ] docs/ (documentation directory)
- [ ] notes/ (pptx-generator materials)
- [ ] status-history/ (archived checkpoints)
- [ ] .claude/hooks/ (templates copied; user enables in settings)
- [ ] .gitignore (status.md exclusion preference confirmed)
- [ ] Initial commit: `chore: bootstrap harness via harness-engineer skill`
```

---

## Language Constraint

All agent output, file content written to projects, and user-facing messages **must be in Traditional Chinese (繁體中文)** unless the project's CLAUDE.md explicitly specifies otherwise. This applies to:
- CLAUDE.md, status.md, learnings.md, README.md content
- Checklist output, next steps, deferred items
- Inline comments and section headers within generated files

The SKILL.md itself (this file) may remain in English as it is skill metadata.

---

## Output Format

**1. 已建立項目**  
List files actually written with paths.

**2. 下一步**（最多三項）  
E.g., "填寫 input/backlog.md Phase 1 目標," "啟用 stop-status-snapshot hook," "設定專案 MCP server."

**3. 延後事項**  
Audit findings or user-declined options.

---

## Template Variables

Placeholders substituted by rendering:
- `{{PROJECT_NAME}}` — Project name
- `{{PROJECT_TAGLINE}}` — One-sentence positioning
- `{{TODAY}}` — Today (YYYY-MM-DD)
- `{{TECH_STACK}}` — Technology stack
- `{{AUTHOR}}` — Author (default: Golden)

---

## Pre-Execution Questions (init mode)

1. Project name?
2. One-sentence tagline?
3. Technology stack?
4. Include status.md in .gitignore? (personal vs. team-shared preference)
