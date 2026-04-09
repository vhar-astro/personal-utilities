#!/usr/bin/env bash
set -euo pipefail

TARGET_VERSION="${1:-2.1.81}"
PACKAGE="@anthropic-ai/claude-code@${TARGET_VERSION}"
SETTINGS_FILE="${HOME}/.claude/settings.json"

echo "[1/5] Installing Claude Code ${TARGET_VERSION} via npm..."
npm install -g "${PACKAGE}"

echo "[2/5] Ensuring ~/.claude/settings.json exists..."
mkdir -p "${HOME}/.claude"
if [ ! -f "${SETTINGS_FILE}" ]; then
  echo '{}' > "${SETTINGS_FILE}"
fi

echo "[3/5] Disabling Claude auto-updater in settings..."
tmp="$(mktemp)"
jq '.env = ((.env // {}) + {"DISABLE_AUTOUPDATER":"1","CLAUDE_CODE_DISABLE_1M_CONTEXT":"1","CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING":"1"})' "${SETTINGS_FILE}" > "${tmp}"
mv "${tmp}" "${SETTINGS_FILE}"

echo "[4/5] Repointing ~/.local/bin/claude to npm-installed CLI..."
mkdir -p "${HOME}/.local/bin"
NPM_PREFIX="$(npm prefix -g)"
NPM_CLAUDE="${NPM_PREFIX}/bin/claude"
if [ ! -e "${NPM_CLAUDE}" ]; then
  echo "ERROR: npm claude binary not found at ${NPM_CLAUDE}"
  exit 1
fi
ln -sfn "${NPM_CLAUDE}" "${HOME}/.local/bin/claude"

echo "[5/5] Verifying..."
echo "claude path: $(readlink -f "${HOME}/.local/bin/claude" || true)"
echo "claude version: $(claude --version)"
echo "DISABLE_AUTOUPDATER: $(jq -r '.env.DISABLE_AUTOUPDATER // "missing"' "${SETTINGS_FILE}")"

echo "Done."
