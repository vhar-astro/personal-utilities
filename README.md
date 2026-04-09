# personal-utilities

## Downgrade Claude

Scripts (`downgrade-claude/downgrade-claude.ps1` for Windows/PowerShell and `downgrade-claude/downgrade-claude.sh` for Unix shells) that pin Claude Code to a specific version and lock it in place by disabling the built-in auto-updater, plus a couple of runtime features.

### What the script does?

1. Installs a target version of Claude Code globally via `npm install -g @anthropic-ai/claude-code@<version>` (defaults to `2.1.81`).
2. Ensures `~/.claude/settings.json` exists (creates an empty `{}` file if missing).
3. Writes three environment variables into the `env` section of `~/.claude/settings.json` so they are applied every time Claude Code starts.
4. (Unix only) Repoints `~/.local/bin/claude` to the npm-installed binary so the newly installed version is actually the one that runs.
5. Verifies the installed version and the settings values.

### Environment variables set by the script

- **`DISABLE_AUTOUPDATER=1`** — Stops Claude Code from silently upgrading itself in the background. Without this, Claude Code will periodically pull the latest release, which defeats the purpose of pinning to a specific version. Setting it to `1` keeps the version you just installed exactly where it is until you decide to change it.

- **`CLAUDE_CODE_DISABLE_1M_CONTEXT=1`** — Disables the 1M-token extended context window. Useful if you want predictable, smaller context sizes (and the cost/latency profile that comes with them) instead of having Claude Code opportunistically expand context on supported models.

- **`CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`** — Disables adaptive/automatic extended thinking. With this flag set, Claude Code will not dynamically decide when to engage extended thinking, giving you more consistent and predictable behavior across turns.
