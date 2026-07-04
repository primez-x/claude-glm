# Claude Code Instructions for This Repository

This repository is a public release package for the `claude-glm` launcher and supporting prompt/hooks.

## Public-Repo Safety

- Never commit environment files, provider auth JSON, private keys, tokens, transcripts, logs, or machine-local caches.
- Keep examples credential-free. Use environment variable names such as `ANTHROPIC_AUTH_TOKEN`, never real values.
- Do not copy `~/.config/claude-glm/env` into this repo.
- Run `./scripts/verify-release.sh` before committing or pushing.
- If installer behavior changed, also run `./scripts/install.sh --dry-run` and `./scripts/doctor.sh`.

## Scope

- Launcher lives in `bin/`.
- Provider-native prompt lives in `prompts/`.
- Claude hooks live in `hooks/`.
- Release scripts live in `scripts/`.
