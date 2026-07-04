#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
CLAUDE_GLM_ENV="${CLAUDE_GLM_ENV_FILE:-$HOME/.config/claude-glm/env}"
PROMPT="${CLAUDE_GLM_SYSTEM_PROMPT_FILE:-$HOME/.claude/prompts/fable-provider-native-system.md}"

ok() { printf 'OK: %s\n' "$1"; }
warn() { printf 'WARN: %s\n' "$1" >&2; }
fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

command -v claude >/dev/null 2>&1 && ok "found claude" || warn "missing claude"
command -v python3 >/dev/null 2>&1 && ok "found python3" || warn "missing python3"
[[ -x "$BIN_DIR/claude-glm" ]] && ok "launcher is executable: $BIN_DIR/claude-glm" || warn "launcher missing or not executable: $BIN_DIR/claude-glm"
[[ -f "$CLAUDE_GLM_ENV" ]] && ok "private GLM env exists: $CLAUDE_GLM_ENV" || warn "private GLM env missing: $CLAUDE_GLM_ENV"
[[ -f "$PROMPT" ]] && ok "system prompt exists: $PROMPT" || fail "system prompt missing: $PROMPT"

for hook in plan-mode-guard.py plan-file-mirror.py plan-gap-goal-hook.py plan-gap-stop-hook.py plan-mode-context-hook.py; do
  path="$HOME/.claude/hooks/$hook"
  if [[ -x "$path" ]]; then
    HOOK_PATH="$path" python3 -B <<'PY'
import os
from pathlib import Path
path = Path(os.environ["HOOK_PATH"])
compile(path.read_text(), str(path), "exec")
PY
    ok "hook syntax is valid: $path"
  else
    warn "hook missing or not executable: $path"
  fi
done

printf '\nDoctor checks finished.\n'
