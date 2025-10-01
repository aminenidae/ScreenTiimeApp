# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a BMad Method installation - an AI-driven agile development framework that provides specialized agent personas for software planning and development. The framework uses slash commands to activate different agent roles (PM, Architect, Developer, QA, etc.) with specific capabilities and workflows.

## Architecture

### Core Structure

The BMad system is organized into several key directories:

- **`.bmad-core/`** - Core framework files (tasks, templates, agents, checklists, data, workflows)
- **`.bmad-creative-writing/`** - Creative writing extension for BMad
- **`.bmad-infrastructure-devops/`** - Infrastructure/DevOps extension for BMad
- **`.claude/commands/BMad/`** - Claude Code slash command definitions
- **`.cursor/rules/bmad/`** - Cursor IDE agent rules (`.mdc` files)
- **`docs/`** - Project documentation (PRD, architecture, stories, QA assessments)
- **`node_modules/`** - Dependencies including `@anthropic-ai/claude-code`

### Agent System

BMad uses a dependency-based agent system where each agent:
- Has a YAML configuration defining persona, commands, and dependencies
- Only loads resources it needs to minimize context
- Maps dependencies to `.bmad-core/{type}/{name}` (e.g., tasks, templates, checklists)
- Should NOT load external files during activation - only when executing specific commands

### Key Agents

- **Analyst** - Market research, competitor analysis, project briefs
- **PM** - PRD creation and management
- **Architect** - System design, architecture documents, tech stack selection
- **UX Expert** - Frontend specs, UI/UX design
- **Scrum Master (SM)** - Story drafting from epics
- **Developer (Dev)** - Code implementation following story tasks
- **QA (Quinn)** - Test architecture, risk assessment, quality gates
- **Product Owner (PO)** - Document alignment, sharding, validation
- **BMad-Master** - Multi-purpose agent for web use (can do all tasks except story implementation)

## Project Configuration

### Core Config (`.bmad-core/core-config.yaml`)

```yaml
prd:
  prdFile: docs/prd.md
  prdSharded: true
  prdShardedLocation: docs/prd

architecture:
  architectureFile: docs/architecture.md
  architectureSharded: true
  architectureShardedLocation: docs/architecture

devLoadAlwaysFiles:
  - docs/architecture/coding-standards.md
  - docs/architecture/tech-stack.md
  - docs/architecture/source-tree.md

devStoryLocation: docs/stories
slashPrefix: BMad
```

**Critical**: The `devLoadAlwaysFiles` list defines files the dev agent must ALWAYS load. These should be lean, focused documents containing standards the agent needs enforced.

## Development Workflow

### Planning Phase (Web UI or IDE)

1. **Optional Research** - Analyst: brainstorming, market research, competitor analysis
2. **Project Brief** - Analyst creates brief
3. **PRD Creation** - PM creates PRD with FRs, NFRs, epics, stories
4. **Optional UX** - UX Expert creates frontend spec
5. **Architecture** - Architect creates architecture from PRD (+ UX spec if exists)
6. **Optional Early QA** - QA provides test architecture input on high-risk areas
7. **Document Alignment** - PO runs master checklist
8. **Document Sharding** - PO shards PRD and Architecture into epics/stories

### Development Cycle (IDE)

1. **Story Creation** - SM drafts next story from sharded epic + architecture
2. **Optional Risk/Design** - QA runs `*risk` and `*design` on high-risk stories
3. **Optional PO Validation** - PO validates story against artifacts
4. **Implementation** - Dev executes tasks sequentially with tests
5. **Optional Mid-Dev QA** - QA runs `*trace` or `*nfr` for early validation
6. **Validations** - Dev runs all tests, linting, type checks
7. **Ready for Review** - Dev marks story ready, adds notes
8. **QA Review** - QA runs `*review` for comprehensive assessment + quality gate
9. **Commit** - Commit changes BEFORE proceeding
10. **Optional Gate Update** - QA runs `*gate` to update status if needed
11. **Story Complete** - Mark done, repeat cycle

## Common Commands

### Running Claude Code

```bash
npm run claude    # Launch Claude Code CLI
```

### Agent Activation (Claude Code)

```bash
/analyst      # Market research, briefs
/pm           # PRD creation
/architect    # Architecture design
/ux-expert    # Frontend specs
/sm           # Story drafting
/dev          # Code implementation
/qa           # Test architecture, quality gates
/po           # Document validation, sharding
/bmad-master  # Multi-purpose (web only)
```

### Key Agent Commands

All agent commands require `*` prefix (e.g., `*help`).

**Developer (`/dev`)**:
- `*develop-story` - Implement story by executing tasks sequentially
- `*run-tests` - Execute linting and tests
- `*review-qa` - Apply QA fixes from review
- `*exit` - Exit dev persona

**QA (`/qa`)**:
- `*risk` - Risk profiling (before dev starts)
- `*design` - Test strategy design (before dev starts)
- `*trace` - Requirements tracing (during dev)
- `*nfr` - NFR assessment (during dev)
- `*review` - Comprehensive review (after dev complete)
- `*gate` - Update quality gate status

**Scrum Master (`/sm`)**:
- `*draft` - Draft next story from epic

**Product Owner (`/po`)**:
- `*shard-prd` - Shard PRD into epics
- `*shard-architecture` - Shard architecture
- `*validate` - Validate story against artifacts

**Architect (`/architect`)**:
- `*create-backend-architecture`
- `*create-brownfield-architecture`
- `*create-front-end-architecture`
- `*create-full-stack-architecture`
- `*document-project`

## File Conventions

### Story Files
- Location: `docs/stories/`
- Format: YAML with specific sections
- Dev can ONLY edit: Task checkboxes, Dev Agent Record sections, Agent Model Used, Debug Log, Completion Notes, File List, Change Log, Status
- Dev CANNOT edit: Story, Acceptance Criteria, Dev Notes, Testing sections

### QA Outputs
- Assessments: `docs/qa/assessments/{epic}.{story}-{type}-{YYYYMMDD}.md`
- Gates: `docs/qa/gates/{epic}.{story}-{slug}.yml`
- Types: `risk`, `test-design`, `trace`, `nfr`

### Document Structure
```
docs/
├── prd.md                    # Main PRD
├── architecture.md           # Main architecture
├── prd/                      # Sharded PRD epics
├── architecture/             # Sharded architecture sections
│   ├── coding-standards.md
│   ├── tech-stack.md
│   └── source-tree.md
├── stories/                  # User stories
├── qa/
│   ├── assessments/         # QA analysis documents
│   └── gates/               # Quality gate decisions
```

## Critical Development Rules

### For Dev Agent
1. **Context Management** - Story has ALL info needed. NEVER load PRD/architecture/other docs unless explicitly directed
2. **File Updates** - ONLY update authorized story sections (checkboxes, Dev Agent Record, status)
3. **Task Execution** - Read task → Implement → Write tests → Run validations → Mark complete (checkbox `[x]`) → Update File List → Repeat
4. **Blocking Conditions** - HALT for: unapproved dependencies, ambiguity, 3+ failures, missing config, failing regression
5. **Ready Criteria** - Code matches requirements + all validations pass + follows standards + File List complete
6. **Completion** - All tasks `[x]` + all tests pass + File List complete + run story-dod-checklist → set status "Ready for Review" → HALT

### For QA Agent (Test Architect)
- **Advisory Authority** - Provides recommendations, not blocking enforcement (unless team policy)
- **Active Refactoring** - Improves code directly when safe during reviews
- **Quality Gates** - PASS/CONCERNS/FAIL decisions based on deterministic rules
- **Risk Scoring** - Probability × Impact (1-9 scale): ≥9 triggers FAIL, ≥6 triggers CONCERNS
- **Test Standards** - No flaky tests, no hard waits, stateless, parallel-safe, self-cleaning

### For All Agents
1. Read entire agent file before activating
2. Load `bmad-core/core-config.yaml` during activation
3. Greet with name/role, run `*help`, then HALT
4. Only load dependency files when executing specific commands
5. agent.customization field always takes precedence
6. Tasks with `elicit=true` REQUIRE user interaction
7. Stay in character until `*exit`

## Special Modes

- **YOLO Mode** - Rapid generation with minimal interaction (toggle with `*yolo`)
- **Incremental Mode** - Step-by-step with user input (default)

## Technical Preferences

The file `.bmad-core/data/technical-preferences.md` contains project-specific preferences that bias PM and Architect decisions. When creating web bundles, include this content.

## Important Notes

- **Commit Policy** - NEVER commit unless explicitly asked
- **Regression Testing** - ALWAYS run full test suite and linting before marking ready
- **Context Efficiency** - Keep files lean, load only what's needed
- **Agent Selection** - Use appropriate agent for each task
- **Story Status** - Stories must be "Approved" (not "Draft") before dev begins
- **Web vs IDE** - BMad-Orchestrator is for web only, use specialized agents in IDE