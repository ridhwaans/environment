#!/usr/bin/env bash

set -e

echo "ADJUSTED_ID: $ADJUSTED_ID"

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")
echo "SCRIPT_ROOT: $SCRIPT_ROOT"
source $SCRIPT_ROOT/_helper.sh

for arg in "$@"; do
  case "$arg" in
    --appearance-defaults)
      export INSTALL_APPEARANCE_DEFAULTS=true
      ;;
    --no-appearance-defaults)
      export INSTALL_APPEARANCE_DEFAULTS=false
      ;;
    *)
      echo "Unknown install option: $arg"
      exit 1
      ;;
  esac
done

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export DOTFILES_DIR=${DOTFILES_DIR:-$HOME/Source/dotfiles}
export APPEARANCE_DIR=${APPEARANCE_DIR:-$HOME/Source/appearance}
export INSTALL_APPEARANCE_DEFAULTS=${INSTALL_APPEARANCE_DEFAULTS:-true}
export CONFIGS_DIR=$DOTFILES_DIR
export PATH="$XDG_BIN_HOME:$PATH"

for script in "$SCRIPT_ROOT/install/common-utils.sh" "$SCRIPT_ROOT/install/appearance.sh" "$SCRIPT_ROOT/install/dotfiles.sh" "$SCRIPT_ROOT/configs.sh" "$SCRIPT_ROOT/install/defaults.sh"; do
  echo "Running $(basename "$script")..."
  bash "$script"
done
