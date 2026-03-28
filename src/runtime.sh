#!/usr/bin/env bash

SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "$SCRIPT_ROOT/_helper.sh"

export ENVIRONMENT_DIR="${ENVIRONMENT_DIR:-$(cd "$SCRIPT_ROOT/.." && pwd)}"
export CONFIGS_DIR="${CONFIGS_DIR:-$SCRIPT_ROOT/configs}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export ENVIRONMENT_CONFIG_DIR="${ENVIRONMENT_CONFIG_DIR:-$XDG_CONFIG_HOME/environment}"
export ENVIRONMENT_STATE_DIR="${ENVIRONMENT_STATE_DIR:-$XDG_STATE_HOME/environment}"
export ENVIRONMENT_CONFIG_FILE="${ENVIRONMENT_CONFIG_FILE:-$ENVIRONMENT_CONFIG_DIR/config.env}"
export ENVIRONMENT_INSTALL_STATE_FILE="${ENVIRONMENT_INSTALL_STATE_FILE:-$ENVIRONMENT_STATE_DIR/install.env}"

load_environment_config() {
  if [ -f "$ENVIRONMENT_CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$ENVIRONMENT_CONFIG_FILE"
  fi

  if [ -f "$ENVIRONMENT_INSTALL_STATE_FILE" ]; then
    # shellcheck disable=SC1090
    source "$ENVIRONMENT_INSTALL_STATE_FILE"
  fi
}

ensure_environment_state_dirs() {
  mkdir -p "$ENVIRONMENT_CONFIG_DIR" "$ENVIRONMENT_STATE_DIR"
}

persist_environment_install_state() {
  ensure_environment_state_dirs

  cat > "$ENVIRONMENT_INSTALL_STATE_FILE" <<EOF
export ENVIRONMENT_DIR="$ENVIRONMENT_DIR"
export ENVIRONMENT_BRANCH="${ENVIRONMENT_BRANCH:-$(git -C "$ENVIRONMENT_DIR" branch --show-current 2>/dev/null || printf 'main')}"
EOF
}

load_environment_config
