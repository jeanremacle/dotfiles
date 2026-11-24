#!/usr/bin/env zsh
# claude-aliases.zsh — shell helpers for Claude Code with the ai-framework hub.
# Source it from ~/.zshrc:
#   source "$HOME/git/dotfiles/claude/claude-aliases.zsh"
#
# Repo locations (override before sourcing if your clones live elsewhere):
#   AI_FRAMEWORK_HOME     the ai-framework hub (skills, bootstrap, permission profiles)
#   PERSONAL_SKILLS_HOME  the personal-skills repo
#   AI_DEVBOX_HOME        the ai-devbox repo (1Password op-run wrappers)
#
# NOTE: never set CLAUDE_CONFIG_DIR here — Claude Code reads it to relocate ~/.claude.

export AI_FRAMEWORK_HOME="${AI_FRAMEWORK_HOME:-$HOME/git/ai-framework}"
export PERSONAL_SKILLS_HOME="${PERSONAL_SKILLS_HOME:-$HOME/git/personal-skills}"
export AI_DEVBOX_HOME="${AI_DEVBOX_HOME:-$HOME/git/ai-devbox}"

# ---------------------------------------------------------------------------
# claude-sync: link the hub's skills (core, eng, stack) + global CLAUDE.md/rules into
# ~/.claude, then the personal skills when that repo is cloned. The hub's selection file
# (~/.config/ai-framework/config.yaml) applies when present. Pass --dry-run to preview.
# ---------------------------------------------------------------------------
claude-sync() {
  "$AI_FRAMEWORK_HOME/session/bootstrap.sh" --symlink --with-stack --global-config "$@" || return
  if [[ -x "$PERSONAL_SKILLS_HOME/install.sh" ]]; then
    "$PERSONAL_SKILLS_HOME/install.sh" --symlink "$@"
  fi
}
alias claude-sync-dry='claude-sync --dry-run'

# ---------------------------------------------------------------------------
# claude-profile <name>: copy a hub permission profile into the current project's
# .claude/settings.local.json (refuses to overwrite an existing one).
# ---------------------------------------------------------------------------
claude-profile() {
  local profile="$AI_FRAMEWORK_HOME/profiles/$1.json"
  if [[ -z "$1" || ! -f "$profile" ]]; then
    [[ -n "$1" ]] && echo "Profile not found: $1"
    echo "Usage: claude-profile <profile-name>"
    echo "Available profiles:"
    for f in "$AI_FRAMEWORK_HOME"/profiles/*.json; do
      echo "  $(basename "$f" .json)"
    done
    return 1
  fi
  if [[ -e .claude/settings.local.json ]]; then
    echo "Refusing to overwrite existing .claude/settings.local.json (remove it first)."
    return 1
  fi
  mkdir -p .claude
  cp "$profile" .claude/settings.local.json
  echo "Activated profile: $1"
}

# ---------------------------------------------------------------------------
# 1Password-injected cloud CLIs (aws-op, az-op, oci-op), kept in the private ai-devbox
# repo because their op:// references name vault items.
# ---------------------------------------------------------------------------
if [[ -f "$AI_DEVBOX_HOME/workstation/onepassword/op-wrappers.zsh" ]]; then
  source "$AI_DEVBOX_HOME/workstation/onepassword/op-wrappers.zsh"
fi
