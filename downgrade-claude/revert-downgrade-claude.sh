#!/usr/bin/env bash
set -euo pipefail

PACKAGE="@anthropic-ai/claude-code@latest"
SETTINGS_FILE="${HOME}/.claude/settings.json"

echo "[1/4] Updating Claude Code to latest via npm..."
npm install -g "${PACKAGE}"

echo "[2/4] Removing envs from settings.json..."
if [ -f "${SETTINGS_FILE}" ]; then
  tmp="$(mktemp)"
  jq 'if .env then
        .env |= (del(.DISABLE_AUTOUPDATER, .CLAUDE_CODE_DISABLE_1M_CONTEXT, .CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING))
        | if (.env | length) == 0 then del(.env) else . end
      else . end' "${SETTINGS_FILE}" > "${tmp}"
  mv "${tmp}" "${SETTINGS_FILE}"
else
  echo "settings.json not found, skipping."
fi

echo "[3/4] Repointing ~/.local/bin/claude to npm-installed CLI..."
mkdir -p "${HOME}/.local/bin"
NPM_PREFIX="$(npm prefix -g)"
NPM_CLAUDE="${NPM_PREFIX}/bin/claude"
if [ ! -e "${NPM_CLAUDE}" ]; then
  echo "ERROR: npm claude binary not found at ${NPM_CLAUDE}"
  exit 1
fi
ln -sfn "${NPM_CLAUDE}" "${HOME}/.local/bin/claude"

echo "[4/4] Verifying..."
echo "claude path: $(readlink -f "${HOME}/.local/bin/claude" || true)"
echo "claude version: $(claude --version)"
if [ -f "${SETTINGS_FILE}" ]; then
  echo "DISABLE_AUTOUPDATER: $(jq -r '.env.DISABLE_AUTOUPDATER // "removed"' "${SETTINGS_FILE}")"
  echo "CLAUDE_CODE_DISABLE_1M_CONTEXT: $(jq -r '.env.CLAUDE_CODE_DISABLE_1M_CONTEXT // "removed"' "${SETTINGS_FILE}")"
  echo "CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING: $(jq -r '.env.CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING // "removed"' "${SETTINGS_FILE}")"
fi

echo "Done."
