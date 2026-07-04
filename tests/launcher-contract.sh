#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

export HOME="$tmp_dir/home"
export PATH="$HOME/.local/bin:$PATH"
export CAPTURE_FILE="$tmp_dir/capture.json"
mkdir -p "$HOME/.local/bin" "$HOME/.config/claude-glm" "$HOME/.claude/prompts"
cp "$repo_root/prompts/fable-provider-native-system.md" "$HOME/.claude/prompts/fable-provider-native-system.md"

cat >"$HOME/.config/claude-glm/env" <<'ENV'
export ANTHROPIC_AUTH_TOKEN="dummy"
export ANTHROPIC_BASE_URL="https://glm.example.invalid"
export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.2[1m]"
ENV
chmod 0600 "$HOME/.config/claude-glm/env"

cat >"$HOME/.local/bin/claude" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
python3 - "$CAPTURE_FILE" "$@" <<'PY'
import json
import os
import sys
keys = [
    "ANTHROPIC_AUTH_TOKEN",
    "ANTHROPIC_BASE_URL",
    "ANTHROPIC_DEFAULT_OPUS_MODEL",
    "ANTHROPIC_API_KEY",
    "CLAUDE_GLM_WRAPPER",
]
with open(sys.argv[1], "w", encoding="utf-8") as fh:
    json.dump({"args": sys.argv[2:], "env": {key: os.environ.get(key) for key in keys}}, fh, sort_keys=True)
PY
SH
chmod +x "$HOME/.local/bin/claude"

CLAUDE_GLM_NO_TMUX=1 "$repo_root/bin/claude-glm" --no-tmux probe

python3 - "$CAPTURE_FILE" "$HOME" <<'PY'
import json
import sys
from pathlib import Path
data = json.loads(Path(sys.argv[1]).read_text())
home = Path(sys.argv[2])
args = data["args"]
env = data["env"]

def require(condition, message):
    if not condition:
        raise SystemExit(message)

require("--no-tmux" not in args, "--no-tmux leaked to claude")
require("--system-prompt-file" in args, "system prompt file was not injected")
require(args[args.index("--system-prompt-file") + 1] == str(home / ".claude/prompts/fable-provider-native-system.md"), "wrong system prompt path")
require("--dangerously-skip-permissions" in args, "GLM launcher should preserve permissive local workflow default")
require("--model" in args and args[args.index("--model") + 1] == "opus", "default model should be opus")
require(args[-1] == "probe", "user argument not preserved")
require(env["ANTHROPIC_AUTH_TOKEN"] == "dummy", "provider token env not passed through")
require(env["ANTHROPIC_BASE_URL"] == "https://glm.example.invalid", "provider base URL env not passed through")
require(env["ANTHROPIC_DEFAULT_OPUS_MODEL"] == "glm-5.2[1m]", "opus model env not passed through")
require(env["ANTHROPIC_API_KEY"] is None, "ANTHROPIC_API_KEY should be unset when auth token is used")
require(env["CLAUDE_GLM_WRAPPER"] == "1", "wrapper marker missing")
print("glm launcher contract passed")
PY
