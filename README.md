# Swarn — Multi-Agent Game Development System

## Overview

**Swarn** — мульти-агентная система для разработки игр с 21 специализированным агентом и DAG-оркестратором.

## Architecture

```
User
    ↓
Orchestrator (DAG Pipeline)
    ↓
┌─────────────────────────────────────────────────────────────┐
│  Stage 1: Concept                                           │
│  ├─ Market Analyst (N1) ──▶ Niche Analyst (N11)             │
│  │                          ↓                               │
│  │                      Niche Monitor (N12, bg)             │
│  └─▶ Game Concept Designer (N2)                             │
├─────────────────────────────────────────────────────────────┤
│  Stage 2: Architecture                                      │
│  ├─ Game Architect (N3)                                     │
│  └─ Senior TypeScript Dev (N15)                             │
├─────────────────────────────────────────────────────────────┤
│  Stage 3: Parallel Development (max 6)                      │
│  ├─ Game Developer (N4) ──▶ Phaser Code Reviewer (N13)      │
│  ├─ UI/UX Designer (N5)                                     │
│  ├─ Level Designer (N6)                                     │
│  ├─ Audio Engineer (N7)                                     │
│  ├─ Asset Manager (N8)                                      │
│  └─ Documentation (N17)                                     │
├─────────────────────────────────────────────────────────────┤
│  Stage 4: Quality & Optimization                            │
│  ├─ QA Tester (N9)                                          │
│  ├─ Performance Profiler (N10)                              │
│  ├─ Phaser Performance Profiler (N14)                       │
│  └─ Localization (N18)                                      │
├─────────────────────────────────────────────────────────────┤
│  Stage 5: Release                                           │
│  ├─ Git/DevOps (N16)                                        │
│  ├─ Marketing/Launch (N19)                                  │
│  └─ Support (N20, background)                               │
├─────────────────────────────────────────────────────────────┤
│  Support: Learning Agent (background)                       │
└─────────────────────────────────────────────────────────────┘
```

## Agents (21)

### Stage 1: Concept
| ID | Agent | Description |
|----|-------|-------------|
| N1 | market-analyst | Market analysis, competitors, trends |
| N11 | niche-analyst | Deep niche analysis, SWOT, ROI |
| N12 | niche-monitor | Niche monitoring (background) |
| N2 | game-concept-designer | GDD, game concept |

### Stage 2: Architecture
| ID | Agent | Description |
|----|-------|-------------|
| N3 | game-architect | Technical spec, patterns |
| N15 | senior-typescript-game-developer | Architecture review, TypeScript best practices |

### Stage 3: Parallel Development
| ID | Agent | Description |
|----|-------|-------------|
| N4 | game-developer | Core logic, physics, AI |
| N5 | ui-ux-designer | Interfaces, menus, HUD |
| N6 | level-designer | Levels, balance, progression |
| N7 | audio-engineer | Sound effects, music |
| N8 | asset-manager | Sprites, animations, assets |
| N13 | phaser-code-reviewer | Code review for Phaser 3 |
| N17 | documentation | API docs, README, guides |

### Stage 4: Quality & Optimization
| ID | Agent | Description |
|----|-------|-------------|
| N9 | qa-tester | Unit tests, integration tests |
| N10 | performance-profiler | FPS, memory, optimization |
| N14 | phaser-performance-profiler | Phaser-specific profiling |
| N18 | localization | i18n, translations (5 languages) |

### Stage 5: Release
| ID | Agent | Description |
|----|-------|-------------|
| N16 | git-devops | Git, CI/CD, build automation |
| N19 | marketing-launch | ASO, promo, launch |
| N20 | support | Support, community (background) |

### Support
| ID | Agent | Description |
|----|-------|-------------|
| — | learning-agent | Result analysis, knowledge-base updates |

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/your-username/Swarn.git
cd Swarn
```

### 2. Set up your game project

```powershell
# Windows
.\setup.ps1 -GamePath "C:\path\to\my-game"

# Or manually set environment variables
set SWARN_HOME=%CD%
set GAME_PROJECT=C:\path\to\my-game
```

```bash
# Linux/Mac
export SWARN_HOME=$(pwd)
export GAME_PROJECT=/path/to/my-game
```

### 3. Run pipeline

```bash
qwen agent run orchestrator
```

See [USAGE.md](USAGE.md) for detailed instructions.

## Configuration

- **config/orchestrator-config.json** — Main pipeline config
- **config/example-external-project.json** — Example for external projects
- **.qwen/agents/** — Agent files
- **knowledge-base/** — Knowledge base and cases
- **artifacts/** — Output artifacts by stage

### Path Configuration

Paths are configured via environment variables or `project_paths` in config:

```json
{
  "project_paths": {
    "swarn_home": "${SWARN_HOME:-.}",
    "game_project": "${GAME_PROJECT:-../game}"
  }
}
```

## Status

- [x] 21 agents created
- [x] DAG orchestrator configured
- [x] Knowledge base integrated
- [x] Self-learning system
- [x] Test run Stage 1 completed

## License

MIT
