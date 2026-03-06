# dotfiles

Portable Claude Code configuration for all machines and projects.

## What's included

| File | Purpose |
|------|---------|
| `claude/CLAUDE.md` | Global instructions: identity, writing style, tools, workflow (ACE), technical lessons |
| `claude/settings.json` | Plugins (9 enabled), effort level (high), dangerous mode skip |
| `claude/settings.local.json` | Auto-allow permission patterns for common CLI tools |

## What stays local (never committed)

- `~/.claude/config.json` (API key)
- `~/.claude/projects/` (per-project memory, session transcripts)
- `~/.claude/history.jsonl`, `cache/`, `backups/`, `plugins/` (auto-managed)

## Install

```bash
git clone https://github.com/deluair/dotfiles ~/dotfiles
cd ~/dotfiles
bash install.sh
```

On a new machine, set your API key separately:

```bash
claude login
```

## Per-project setup

Each project should have its own `CLAUDE.md` at the repo root with project-specific instructions. The global `CLAUDE.md` applies everywhere; project-level ones add context for that codebase.

## Plugins

- context7: Library documentation lookup
- firecrawl: Web scraping, search, research
- frontend-design: Production-grade UI generation
- code-review: PR review
- feature-dev: Guided feature development
- commit-commands: Git commit, push, PR workflows
- github: GitHub integration
- skill-creator: Custom skill creation
- superpowers: Enhanced capabilities
