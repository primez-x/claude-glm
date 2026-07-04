# claude-glm

`claude-glm` is a public, copyable setup for running Claude Code against a provider-native GLM route using Claude Code's Opus slot.

This repo intentionally ships templates, a launcher, hooks, prompts, and verification scripts only. It does not include provider env files, auth JSON, private keys, transcripts, tokens, or machine-local caches.

## What Is Included

- `bin/claude-glm` - Claude Code launcher for GLM sessions.
- `prompts/fable-provider-native-system.md` - provider-native system prompt.
- `hooks/` - shared Claude plan-mode, plan-file, and persisted plan-goal hooks.
- `config/claude/settings.hooks.example.json` - hook registration example.
- `scripts/install.sh` - idempotent local installer.
- `scripts/doctor.sh` - local installation checks.
- `scripts/verify-release.sh` - maintainer verification before publishing.

## Requirements

- Claude Code CLI available as `claude`.
- Python 3.
- `tmux` if you want automatic tmux session management.
- A local GLM env file at `~/.config/claude-glm/env` containing your private provider values. This file is never committed.

Example private env file shape:

```bash
ANTHROPIC_AUTH_TOKEN="your-private-token"
ANTHROPIC_BASE_URL="https://your-provider.example"
ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.2[1m]"
```

## Quick Start

```bash
git clone git@github.com:primez-x/claude-glm.git
cd claude-glm
./scripts/verify-release.sh
./scripts/install.sh --force
claude-glm
```

The installer copies the launcher into `~/.local/bin`, installs the system prompt into `~/.claude/prompts`, installs Claude hooks into `~/.claude/hooks`, and registers the hooks in `~/.claude/settings.json`.

## Safety Defaults

- The launcher reads provider secrets from `~/.config/claude-glm/env` at runtime. The env file is not installed or committed.
- The launcher injects the provider-native system prompt unless you override `CLAUDE_GLM_SYSTEM_PROMPT_FILE`.
- Plan mode is guarded by a `PreToolUse` hook that fails closed for mutations while allowing bounded read-only exploration.
- Accepted-plan implementation is guarded by persisted Claude goal hooks under `~/.claude/goals`; the Stop hook blocks completion until the final answer contains a Plan Gap Check or a clear blocked-state report.
- `.gitignore` excludes auth files, env files, transcripts, key material, token caches, logs, and common runtime state.

## Verification

Run this before publishing changes:

```bash
./scripts/verify-release.sh
```

Run this after installing on a user machine:

```bash
./scripts/doctor.sh
```
